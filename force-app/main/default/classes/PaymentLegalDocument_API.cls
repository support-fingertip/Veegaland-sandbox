@RestResource(urlMapping='/PaymentLegalDocumetAPI/*')
global without sharing class PaymentLegalDocument_API {
    
    
    @HttpPost
    global static void getMyPropertiesDcoumentDetail() {
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the JSON body
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='PaymentLegalDocument_API';
        log.Request__c =requestBody;
        
        try{   
            MyPropertiesDetailWrapper proj = (MyPropertiesDetailWrapper) JSON.deserialize(requestBody, MyPropertiesDetailWrapper.class);
            String userId = proj.userId;
            String projectId = proj.projectId;
            String unitNUmber = proj.unitNumber;
            
            if (String.isBlank(userId) || String.isBlank(projectId) ) {
                log.response__c = 'UserId or projectId Should not be blank.';
                log.Status__c ='SUCCESS';
                insert log;
                
                sendErrorResponse('Please Send correct Data');
                return;
            }
            List<Customer_Master__c> cmList = [ SELECT Id, Email__c, Password__c, First_Name__c, Last_Name__c, Phone__c,Name  FROM Customer_Master__c  WHERE Name = :userId AND isActive__c = TRUE LIMIT 1 ];
            
            if (cmList.isEmpty()) {
                log.response__c = 'Customer Not Found';
                log.Status__c ='SUCCESS';
                insert log;
                
                sendErrorResponse('User Not Found in System');
                return;
            }
            Project__c project = [ SELECT Id, Name, Project__c, Display_in_Home__c,Display_in_Banner__c,projectSubImage__c,ProjectImage__c,BannerImage__c,BHK_Type__c,
                                  Area_Name__c,Locality_Name__c ,WorkProgress__c,Project_description__c,
                                  (SELECT Id, Name, AmenityImage__c FROM Amenities__r) FROM Project__c WHERE Project_Id__c = :projectId LIMIT 1  ];
            
            if (project == null) {
                log.response__c = 'Project Not Found';
                log.Status__c = 'SUCCESS';
                insert log;
                sendErrorResponse('Project Not Found');
                return;
            }
            List<Booking__c> bookingList = new List<Booking__c>();
            if(!cmList.isEmpty() && project.Project__c != null){
                Plot__c unit = [select id,BHK_Type__c,No_of_Indivisual_Car_Parking__c,Built_up_area__c,Unit_Type__c from Plot__c where Name =: unitNUmber];
                system.debug(cmList[0].id);
                bookingList = [select id,Project__c,Plot__c,No_of_Indivisual_Car_Parking__c,Total__c from Booking__c where Customer_Master__c =: cmList[0].id AND Project__c =: project.Project__c AND Plot__c=:unit.Id limit 1];
                if (bookingList.isEmpty()) {
                    log.response__c = 'No Booking Found in System';
                    log.Status__c ='SUCCESS';
                    insert log;
                    
                    sendErrorResponse('No Booking Found in System');
                    return;
                }
                
                List<Demand_Raised__c> latestdemand = [select id,Current_Demand_amount__c,Previous_pendings__c,Due_Date__c from Demand_Raised__c WHERE Booking__c=: bookingList[0].id order by CreatedDate DESC]  ;          
                List<Receipt__c> lstrecpt = [select id from Receipt__c where Booking__c=:  bookingList[0].id order by CreatedDate DESC limit 1];
                
                List<Unit_Type__c> unittyplst = [select id from Unit_Type__c where Id =:unit.Unit_Type__c limit 1];
                PropertyResponse response = new PropertyResponse();
                response.success = true;
                response.message = '';
                response.data = new DataWrapper();
                
                response.data.documents = new List<DocumentInfo>();
                List<DocumentInfo> lst = new List<DocumentInfo>();
                
                system.debug(unittyplst[0].id);
                List<ContentDocumentLink> docLinksp = [ SELECT ContentDocumentId  FROM ContentDocumentLink  WHERE LinkedEntityId =:unittyplst[0].id  ];
                system.debug(docLinksp.size());
                List<Id> docIdsp = new List<Id>();
                for (ContentDocumentLink link : docLinksp) {
                    docIdsp.add(link.ContentDocumentId);
                }
                System.debug(docIdsp.size());
                if (!docIdsp.isEmpty()) {
                    List<ContentVersion> versions = [ SELECT Id, Title, FileExtension, ContentDocumentId  FROM ContentVersion  WHERE IsLatest = true AND ContentDocumentId IN :docIdsp];
                    Set<id> cdid = new Set<id>();
                    
                    for (ContentVersion cv : versions) {
                        cdid.add(cv.id);
                        
                    }
                    
                    List<ContentDistribution> cdlsy =[select id,DistributionPublicUrl,ContentDownloadUrl,ContentVersion.Title,ContentVersion.FileExtension,createdDate from ContentDistribution where ContentVersionId IN :cdid];
                    
                    System.debug(cdlsy.size());
                    List<String> projectdrwaing = new List<String>();
                    for(ContentDistribution cd : cdlsy){
                        system.debug(cd.DistributionPublicUrl);
                        String pd = cd.DistributionPublicUrl;
                        //projectdrwaing.add(pd);
                        
                        String picUrl = '';
                            picUrl =  cd.ContentDownloadUrl.replace('download/?' , 'renditionDownload?rendition=ORIGINAL_Jpg&');
                            picUrl = picUrl.replace('&ids' , '&versionId');
                           projectdrwaing.add(picUrl);
                         
                      /*  DocumentInfo docInfo = new DocumentInfo(
                            cd.Id,  // DocumentId (use ContentDistribution Id here)
                            cd.ContentVersion.Title + '.' + cd.ContentVersion.FileExtension, // DocumentName
                            String.valueOf(cd.CreatedDate),  // DocumentDate
                            cd.ContentDownloadUrl  // DocumentLink
                        );
                        lst.add(docInfo);
                        */
                        
                    }
                    
                         response.data.projectsDrawings=projectdrwaing;
                    
                }
                
                Set<Id> linkedId = new Set<Id>();
                linkedId.add(bookingList[0].id);
                linkedId.add(unittyplst[0].id);
              //  linkedId.add(latestdemand[0].id);
                For(Demand_Raised__c dd : latestdemand){
                     linkedId.add(dd.id);
               
                    
                }
                
              //  linkedId.add(lstrecpt[0].id);
                
                List<ContentDocumentLink> docLinks = [ SELECT ContentDocumentId  FROM ContentDocumentLink  WHERE LinkedEntityId IN: linkedId  ];
                
                List<Id> docIds = new List<Id>();
                for (ContentDocumentLink link : docLinks) {
                    docIds.add(link.ContentDocumentId);
                }
                
                
                if (!docIds.isEmpty()) {
                    // Get latest ContentVersion for each document
                    List<ContentVersion> versions = [ SELECT Id, Title, FileExtension, ContentDocumentId  FROM ContentVersion  WHERE IsLatest = true AND ContentDocumentId IN :docIds];
                    Set<id> cdid = new Set<id>();
                    
                    for (ContentVersion cv : versions) {
                        cdid.add(cv.id);
                        
                    }
                    
                    List<ContentDistribution> cdlsy =[select id,DistributionPublicUrl,ContentDownloadUrl,ContentVersion.Title,ContentVersion.FileExtension,createdDate from ContentDistribution where ContentVersionId IN :cdid];
                    
                    
                    for(ContentDistribution cd : cdlsy){
                        
                        if(cd.ContentVersion.Title.Contains('Registered Agreement') || cd.ContentVersion.Title.Contains('Registered Sale Deed') /*|| cd.ContentVersion.Title.Contains('Receipt')|| cd.ContentVersion.Title.Contains('Demand Note')*/||
                          cd.ContentVersion.Title.Contains('Tripartite agreement') || cd.ContentVersion.Title.Contains('NOC') || cd.ContentVersion.Title.Contains('Signed Handover')|| cd.ContentVersion.Title.Contains('Land Tax')||
                           cd.ContentVersion.Title.Contains('Possession certificate') || cd.ContentVersion.Title.Contains('Building certificate') || cd.ContentVersion.Title.Contains('Encumbrance certificate')|| cd.ContentVersion.Title.Contains('Sample Sale Agreement')
                          
                          ){
                            
                            DocumentInfo docInfo = new DocumentInfo(
                                cd.Id,  // DocumentId (use ContentDistribution Id here)
                                cd.ContentVersion.Title + '.' + cd.ContentVersion.FileExtension, // DocumentName
                                String.valueOf(cd.CreatedDate),  // DocumentDate
                                cd.ContentDownloadUrl  // DocumentLink
                            );
                            lst.add(docInfo);
                        }
                        
                    }
                    
                    
                    
                    
                }
                response.data.documents = lst;
                response.data.totalCount = lst.size();
                
                if(lst.size()>0){
                    sendResponse(response); 
                }
                
            }
        }
        Catch (Exception e){
            log.response__c = e.getStackTraceString();
            log.Status__c ='FAIL';
            log.Error_Message__c = e.getMessage();
            insert log;
            // sendErrorResponse('Error: ' + e.getMessage());
            
        }
        
    }
    public class MyPropertiesDetailWrapper {
        public String userId;
        public String projectId;
        public String unitNumber;
        
    }
    public class PropertyResponse {
        public Boolean success;
        public String message;
        public DataWrapper data;
    }
    
    public class DataWrapper {
        public List<DocumentInfo> documents;
         public List<String> projectsDrawings;
        public Integer totalCount;
    }
    
    public class DocumentInfo {
        public String documentId;
        public String documentName;
        public String documentDate;
        public String documentLink;
        
        public DocumentInfo(String documentId, String documentName, String documentDate, String documentLink) {
            this.documentId = documentId;
            this.documentName = documentName;
            this.documentDate = documentDate;
            this.documentLink = documentLink;
        }
    }
    
    // Helper methods for sending responses
    private static void sendResponse(PropertyResponse response) {
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
        
    }
    
    
    private static void sendErrorResponse(String message) {
        RestContext.response.statusCode = 400;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'status' => false,
                'message' => message
                }));
    }
}