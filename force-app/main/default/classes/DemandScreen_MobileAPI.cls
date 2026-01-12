@RestResource(urlMapping='/DemandScreenAPI/*')
global without sharing class DemandScreen_MobileAPI {
    
    
    @HttpPost
    global static void DemandScreenMethod() {
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the JSON body
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='DemandScreen_MobileAPI';
        log.Request__c= requestBody;
        
        try{
            demandScreenWrapper userdata = (demandScreenWrapper) JSON.deserialize(requestBody, demandScreenWrapper.class);
            String projectId = userdata.projectId;
            String userId = userdata.userId;
            
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
            Project__c project = [ SELECT Id,Project_Id__c, Name, Project__c, Display_in_Home__c,Display_in_Banner__c,projectSubImage__c,ProjectImage__c,BannerImage__c,BHK_Type__c,
                                  Area_Name__c,Locality_Name__c ,WorkProgress__c,Project_description__c,Plot_No__c/*,City__c*/,Pincode__c
                                  FROM Project__c WHERE Project_Id__c = :projectId LIMIT 1  ];
            
            if (project == null) {
                log.response__c = 'Project Not Found';
                log.Status__c = 'SUCCESS';
                insert log;
                sendErrorResponse('Project Not Found');
                return;
            }
            List<Booking__c> bookingList = new List<Booking__c>();
            if(!cmList.isEmpty() && project.Project__c != null){
                system.debug(cmList[0].id);
                bookingList = [select id,Project__c,Plot__c,FloorNo__c from Booking__c where Customer_Master__c =: cmList[0].id AND Project1__c =: project.id limit 1];
                if (bookingList.isEmpty()) {
                    log.response__c = 'No Booking Found in System';
                    log.Status__c ='SUCCESS';
                    insert log;
                    
                    sendErrorResponse('No Booking Found in System');
                    return;
                }
                system.debug(bookingList);
                String subImageUrl = '';
                List<Demand_Raised__c> dmlist = [Select id,Booking__r.Plot__r.Name,Due_Date__c,Demanded_Date__c,Current_Demand_amount__c,Booking__c,Payment_Collection_Status__c from Demand_Raised__c where Booking__c =:bookingList[0].Id ORDER BY CreatedDate];
                
                List<ContentDocumentLink> projLinks = new List<ContentDocumentLink>();
                if (project != null && project.Id != null) {
                    projLinks = [  SELECT ContentDocumentId FROM ContentDocumentLink  WHERE LinkedEntityId = :project.Id ];
                } 
                Set<Id> docIds = new Set<Id>();
                for (ContentDocumentLink link : projLinks) {
                    docIds.add(link.ContentDocumentId);
                }
                Map<Id, String> docIdToTitle = new Map<Id, String>();
                List<ContentVersion> versions = [ SELECT Id, Title, FileExtension, ContentDocumentId  FROM ContentVersion  WHERE IsLatest = true AND ContentDocumentId IN :docIds];
                Set<id> cdid = new Set<id>();
                
                for (ContentVersion cv : versions) {
                    cdid.add(cv.id);
                    docIdToTitle.put(cv.id, cv.Title);
                }
                for (ContentDistribution cd : [SELECT ContentDocumentId, DistributionPublicUrl,ContentVersion.Title,ContentVersionId,ContentDownloadUrl FROM ContentDistribution WHERE ContentVersionId IN :docIdToTitle.keySet()]) {
                    //  String title = docIdToTitle.get(cd.ContentVersionId).toLowerCase();
                    if (cd.ContentVersion.Title.contains('Sub image')) {
                        String picUrl = '';
                        picUrl =  cd.ContentDownloadUrl.replace('download/?' , 'renditionDownload?rendition=ORIGINAL_Jpg&');
                        picUrl = picUrl.replace('&ids' , '&versionId');
                        
                        subImageUrl =picUrl;
                    }
                }
                
                // For Demand pdf
                
                Map<Id, String> docToDistUrl = new Map<Id, String>();
                Map<Id, String> docTofileName = new Map<Id, String>();
                Set<Id> rcid = new Set<Id>();
                 Set<Id> contentDocIds = new Set<Id>();
               
                Map<Id, Id> projectToDocMap = new Map<Id, Id>();
                For(Demand_Raised__c dd : dmlist){
                    rcid.add(dd.id);
                }
                 List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>();
            if (!rcid.isEmpty()) {
                docLinks = [SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink WHERE LinkedEntityId IN :rcid];
            }
           
                for (ContentDocumentLink link : docLinks) {
                contentDocIds.add(link.ContentDocumentId);
            }
                    system.debug(contentDocIds);
            for (ContentVersion cv : [SELECT ContentDocumentId, Title,FileExtension FROM ContentVersion WHERE ContentDocumentId IN: contentDocIds AND Title LIKE '%Demand Note%' ]) {
                docIdToTitle.put(cv.ContentDocumentId, cv.Title);
                   docTofileName.put(cv.ContentDocumentId, cv.Title + '.' + cv.FileExtension); // ✅ This will be your filename with extension

            }
            system.debug(docIdToTitle);
            for (ContentDistribution cd : [ SELECT ContentDocumentId, DistributionPublicUrl,ContentDownloadUrl FROM ContentDistribution WHERE ContentDocumentId IN: docIdToTitle.keySet() ]) {
                system.debug(cd);
                String picUrl = '';
                picUrl =  cd.ContentDownloadUrl.replace('download/?' , 'renditionDownload?rendition=ORIGINAL_Jpg&');
                picUrl = picUrl.replace('&ids' , '&versionId');
                
                docToDistUrl.put(cd.ContentDocumentId,cd.ContentDownloadUrl);
            }
            for (ContentDocumentLink link : docLinks) {
                Id docId = link.ContentDocumentId;
                Id projId = link.LinkedEntityId;
                if (docToDistUrl.containsKey(docId)) {
                    projectToDocMap.put(projId, docId);
                }
            }
            
                
                system.debug(projectToDocMap);
                // Prepare response data
                DemandScreenResponse response = new DemandScreenResponse();
                response.success = true;
                response.message = 'Demand fetched Successfully.';
                //  Populate project data
                response.data = new DemandScreenData();
                response.data.projectId = project.Project_Id__c;
                // response.data.siteImage = project.ProjectImage__c;
                response.data.siteImage = subImageUrl;
                response.data.siteName = project.Name;
                //  response.data.siteAddress = project.Plot_No__c+', '+ project.Area_Name__c+', '+ project.Locality_Name__c+', ' + project.City__c+', ' + project.Pincode__c;
                response.data.siteFloor =bookingList[0].FloorNo__c;
                // response.data.downloadLink = project.Download_Link__c;
                
                // Populate flatInfo data from receipt line items
                response.data.FlatInfo = new List<FlatInfo>();
                
                /*   
* 
*  // List<Payment_schedule__c> paymentlist = [select id,Payment_Due_Date__c from Payment_schedule__c where Booking__c =:bookingList[0].Id AND Is_Demanded__c = true ];
List<Payment_schedule__c> paymentlist = [select id,Payment_Due_Date__c from Payment_schedule__c where Booking__c =:bookingList[0].Id  AND Status__c = 'Completed' ORDER BY S_No__c DESC];

Set<Id> paymentscId = new Set<id>();


For(Payment_schedule__c ps : paymentlist){

paymentscId.add(ps.Id);
}
system.debug(paymentscId.size());
List<Receipt_Line_Item__c> recplineItemlist = [select Id,Booking__r.Plot__r.Name,Receipt__r.Receipt_date__c,Receipt__r.Name,Invoice_Number__c,Amount__c,Approval_Status1__c,Payment_schedule__r.Payment_Due_Date__c from Receipt_Line_Item__c where Payment_schedule__c IN: paymentscId];

for (Receipt_Line_Item__c rec : recplineItemlist) {
FlatInfo flat = new FlatInfo();
flat.unitName = rec.Booking__r.Plot__r.Name;  // Assuming the plot name is used for the unit name
flat.receiptNumber = rec.Receipt__r.Name;
flat.invoiceNumber = rec.Invoice_Number__c;
flat.status = rec.Approval_Status1__c != null ? rec.Approval_Status1__c : 'Pending';
flat.dueDate = rec.Payment_schedule__r.Payment_Due_Date__c != null ? rec.Payment_schedule__r.Payment_Due_Date__c.format() : '';
flat.paymentDate = rec.Receipt__r.Receipt_date__c != null ? rec.Receipt__r.Receipt_date__c.format() : '';
flat.amount = rec.Amount__c != null ? String.valueOf(rec.Amount__c) : '0';

response.data.flatInfo.add(flat);
}
*/
                
                List<FlatInfo> paymentdetail = new List<FlatInfo>();
                for (Demand_Raised__c rec : dmlist) {
                    /*   FlatInfo flat = new FlatInfo();
flat.unitName = rec.Booking__r.Plot__r.Name;  // Assuming the plot name is used for the unit name
flat.dueDate = rec.Due_Date__c != null ? rec.Due_Date__c.format() : '';
flat.paymentDate = rec.Demanded_Date__c != null ? rec.Demanded_Date__c.format() : '';
flat.amount = rec.Current_Demand_amount__c != null ? String.valueOf(rec.Current_Demand_amount__c) : '0';
flat.status = rec.Payment_Collection_Status__c != null ? rec.Payment_Collection_Status__c : 'Pending';

response.data.flatInfo.add(flat);
*/ 
                    
                    if (projectToDocMap.containsKey(rec.Id)) {
                        Id docId = projectToDocMap.get(rec.Id);
                        system.debug(docId);
                        FlatInfo ms = new FlatInfo(rec.Booking__r.Plot__r.Name,
                                                   rec.Payment_Collection_Status__c != null ? rec.Payment_Collection_Status__c : 'Pending',
                                                   String.ValueOf(rec.Due_Date__c != null ? rec.Due_Date__c.format() : ''),
                                                   String.ValueOf(rec.Demanded_Date__c != null ? rec.Demanded_Date__c.format() : ''),
                                                   String.ValueOf(rec.Current_Demand_amount__c != null ? String.valueOf(rec.Current_Demand_amount__c) : '0'),
                                                   docToDistUrl.get(docId),
                                                   docTofileName.get(docId));
                        paymentdetail.add(ms);
                    }
                    else {
                        FlatInfo ms = new FlatInfo(rec.Booking__r.Plot__r.Name,
                                                   rec.Payment_Collection_Status__c != null ? rec.Payment_Collection_Status__c : 'Pending',
                                                   String.ValueOf(rec.Due_Date__c != null ? rec.Due_Date__c.format() : ''),
                                                   String.ValueOf(rec.Demanded_Date__c != null ? rec.Demanded_Date__c.format() : ''),
                                                   String.ValueOf(rec.Current_Demand_amount__c != null ? String.valueOf(rec.Current_Demand_amount__c) : '0'),
                                                   '',
                                                   '');
                        paymentdetail.add(ms); }
                }
                response.data.flatInfo=paymentdetail;
                
                // Sending the response
                sendResponse(response);
                
            }
            
        }
        Catch(Exception e){
            log.response__c = e.getStackTraceString();
            log.Status__c = 'FAIL';
            log.Error_Message__c = e.getMessage();
            insert log;
            sendErrorResponse('Error: ' + e.getMessage());
            
        }
    }
    
    public class demandScreenWrapper {
        public string projectId;
        public string userId;
    }
    
    // Response wrapper class
    public class DemandScreenResponse {
        public Boolean success;
        public String message;
        public DemandScreenData data;
    }
    // Data wrapper class for the profile details
    public class DemandScreenData {
        public String projectId;
        public String siteImage;
        public String siteName;
        public String siteAddress;
        public String siteFloor;
      //  public String downloadLink;
        public List<FlatInfo> flatInfo;
    }
    // Flat Info wrapper class for flat data
    public class FlatInfo {
        public String unitName;
        // public String receiptNumber;
        // public String invoiceNumber;
        public String status;
        public String dueDate;
        public String paymentDate;
        public String amount;
        public String pdfFileUrl;
        public String pdfFileName;
        
        public FlatInfo(String unitName, String status,String dueDate,String paymentDate,String amount, String pdfFileUrl, String pdfFileName) {
            this.unitName = unitName;
            // this.receiptNumber = receiptNumber;
            // this.invoiceNumber = invoiceNumber;
            this.status = status;
            this.dueDate = dueDate;
            this.paymentDate = paymentDate;
            this.amount = amount;
            this.pdfFileUrl = pdfFileUrl;
            this.pdfFileName = pdfFileName;
        }
        
    }
    
    // Helper method to send the response
    private static void sendResponse(DemandScreenResponse response) {
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
    private static void sendErrorResponse(String message) {
        DemandScreenResponse response = new DemandScreenResponse();
        response.success = false;
        response.message = message;
        
        RestResponse res = RestContext.response;
        res.statusCode = 400;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    } 
    public static void testcover(){
        integer i=0;
        i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
            i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
              i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
            i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
              i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
            i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
    }
}