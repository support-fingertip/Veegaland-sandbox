@RestResource(urlMapping='/SupportListAPI/*')
global without sharing class SupportList_MobileAPI {
    
    @HttpPost
    global static void getMyPropertiesDetail() {
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the JSON body
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='SupportList_MobileAPI';
        log.Request__c = requestBody;
        
        try{
            SupportlistWrapper proj = (SupportlistWrapper) JSON.deserialize(requestBody, SupportlistWrapper.class);
            String userId = proj.userId;
            Integer pageSize = proj.pageSize;
            
            
            if (String.isBlank(userId)  ) {
                log.response__c = 'UserId should not be blank';
                log.Status__c ='SUCCESS';
                insert log;
                sendErrorResponse('UserId should not be blank');
                return;
            }
            List<Customer_Master__c> cmList = [ SELECT Id, Email__c, Password__c, First_Name__c, Last_Name__c, Phone__c,Name  FROM Customer_Master__c  WHERE Name = :userId AND isActive__c = TRUE LIMIT 1 ];
            if (!cmList.isEmpty()) {
                List<Support_Request__c> srlist = [select id,Feedback__c,Concern_Sub_Type__c,Status__c,Support_Type__c,Priority_List__c,ConcernList__c,Nature_Of_Concern__c,Description__c,ticketImage__c,Name from Support_Request__c where Customer_Master__c =:cmList[0].id Order By CreatedDate DESC limit 10 OFFSET : pageSize];
                
                Map<Id, List<String>> supportRequestToImagesMap = new Map<Id, List<String>>();
                
                //For adding the support image
                Set<Id> srid = new Set<Id>();
                for (Support_Request__c pr : srlist) {
                    srid.add(pr.Id);
                }
                
                
                Map<Id, Id> projectToDocMap = new Map<Id, Id>();
                  Map<Id, String> docIdToTitle = new Map<Id, String>();
                Map<Id, List<String>> docToDistUrl = new Map<Id, List<String>>();
                
              List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>();
                if(!srid.isEmpty()){
                    
                     docLinks = [ SELECT ContentDocumentId, LinkedEntityId   FROM ContentDocumentLink WHERE LinkedEntityId IN :srid];
                Set<Id> contentDocIds = new Set<Id>();
                for (ContentDocumentLink link : docLinks) {
                    contentDocIds.add(link.ContentDocumentId);
                }
                
                for (ContentDistribution dist : [ SELECT ContentDocumentId, DistributionPublicUrl,ContentDownloadUrl FROM ContentDistribution WHERE ContentDocumentId IN :contentDocIds ]) {
                    if (!docToDistUrl.containsKey(dist.ContentDocumentId)) {
                        docToDistUrl.put(dist.ContentDocumentId, new List<String>());
                    }
                    
                    String picUrl = '';
                    picUrl =  dist.ContentDownloadUrl.replace('download/?' , 'renditionDownload?rendition=ORIGINAL_Jpg&');
                    picUrl = picUrl.replace('&ids' , '&versionId');
                    docToDistUrl.get(dist.ContentDocumentId).add(picUrl);
                    
                }
                for (ContentDocumentLink link : docLinks) {
                    Id docId = link.ContentDocumentId;
                    Id projId = link.LinkedEntityId;
                    if (docToDistUrl.containsKey(docId)) {
                        projectToDocMap.put(projId, docId);
                    }
                }
                
                
               
                    
                }
                
                
                
                // Prepare the response
                SupportListResponse response = new SupportListResponse();
                response.success = true;
                response.message = '';
                response.data = new SupportListData();
                
                // Populate the supportRequestList
                response.data.supportRequestList = new List<SupportRequestInfo>();
                
                for (Support_Request__c sr : srList) {
                    SupportRequestInfo supportInfo = new SupportRequestInfo();
                    supportInfo.supportId = sr.Name;
                    supportInfo.status = sr.Status__c;
                    supportInfo.priority = sr.Priority_List__c;
                    supportInfo.natureOfConcern = sr.ConcernList__c;
                    supportInfo.concernSubType = sr.Concern_Sub_Type__c;
                    supportInfo.description = sr.Description__c;
                    supportInfo.feedback = sr.Feedback__c;
                    
                    // Handle ticket images
                    List<String> ticketImages = new List<String>();
                    
                    for (ContentDocumentLink link : docLinks) {
                        if (link.LinkedEntityId == sr.Id && docToDistUrl.containsKey(link.ContentDocumentId)) {
                            ticketImages.addAll(docToDistUrl.get(link.ContentDocumentId));
                        }
                    }
                    supportInfo.ticketImage = ticketImages;
                    
                    response.data.supportRequestList.add(supportInfo);
                }
                
                response.data.totalCount = [SELECT COUNT() FROM Support_Request__c WHERE Customer_Master__c = :cmList[0].Id];
                
                // Sending the response
                sendResponse(response);
                
                
                
            }
            else{
                
                log.response__c = 'User not found';
                log.Status__c = 'Success';
                insert log;
                sendErrorResponse('User not found ');
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
    public class SupportlistWrapper {
        public String userId;
        public Integer pageSize;
        
    }
    public class SupportListResponse {
        public Boolean success;
        public String message;
        public SupportListData data;
    }
    public class SupportListData {
        public List<SupportRequestInfo> supportRequestList;
        public Integer totalCount;
    }
    
    public class SupportRequestInfo {
        public String supportId;
        public String status;
        public String priority;
        public String natureOfConcern;
        public String concernSubType;
        public String description;
        public String feedback;
        public List<String> ticketImage;
    }
    private static void sendResponse(SupportListResponse response) {
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
    private static void sendErrorResponse(String message) {
        SupportListResponse response = new SupportListResponse();
        response.success = false;
        response.message = message;
        
        RestResponse res = RestContext.response;
        res.statusCode = 400;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
    
}