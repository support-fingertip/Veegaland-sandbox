@RestResource(urlMapping='/WorkProgressDetailAPI/*')
global without sharing class WorkProgress_MobileAPI {
    
    @HttpPost
    global static void getMyPropertiesDetail() {
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the JSON body
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='MyPropertyDetails_MobileAPI';
        log.Request__c = requestBody;
        
        try{
            WorkProgressScreenWrapper proj = (WorkProgressScreenWrapper) JSON.deserialize(requestBody, WorkProgressScreenWrapper.class);
            String userId = proj.userId;
            String projectId = proj.projectId;
            String workProgressId = proj.workProgressId;
            if (String.isBlank(userId) || String.isBlank(projectId) || String.isBlank(workProgressId)) {
                log.response__c = 'UserId, projectId or workProgressId Should not be blank.';
                log.Status__c ='SUCCESS';
                insert log;
                
            //sendErrorResponse('');
                return;
            }
            List<Customer_Master__c> cmList = [ SELECT Id, Email__c, Password__c, First_Name__c, Last_Name__c, Phone__c,Name  FROM Customer_Master__c  WHERE Name = :userId AND isActive__c = TRUE LIMIT 1 ];
            
            if (cmList.isEmpty()) {
                log.response__c = 'Customer Not Found';
                log.Status__c ='SUCCESS';
                insert log;
                
            sendErrorResponse('Customer Not Found');
                return;
            }
            Project__c project = [ SELECT Id, Name, Project__c, Display_in_Home__c  FROM Project__c WHERE Project_Id__c = :projectId LIMIT 1  ];
            
            
            if (project == null) {
                log.response__c = 'Project Not Found';
                log.Status__c = 'SUCCESS';
                insert log;
                sendErrorResponse('Project Not Found');
                return;
            }
            Work_Progress__c workplist = [Select id,Name,Work_Progress_till_Now__c,List_of_Image__c from Work_Progress__c where Name =: workProgressId limit 1];
            if(workplist==null){
                log.response__c = 'Work Progress Not Found';
                log.Status__c = 'SUCCESS';
                insert log;
                sendErrorResponse('Work Progress Not Not Found');
                return;
            }
            
              List<ContentDocumentLink> docLinks = [ SELECT ContentDocumentId  FROM ContentDocumentLink  WHERE LinkedEntityId = :workplist.Id   ];
                
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
              
            WorkProgressResponse response = new WorkProgressResponse();
            response.status = true;
            response.message = '';
            response.result = new WorkProgressResult();
            response.result.workProgressList = new List<String>();
                    List<String> imagelist = new List<String>();
                    for (ContentDistribution cd : cdlsy) {
                        
                         String picUrl = '';
                    picUrl =  cd.ContentDownloadUrl.replace('download/?' , 'renditionDownload?rendition=ORIGINAL_Jpg&');
                    picUrl = picUrl.replace('&ids' , '&versionId');
                   
                        
                        imagelist.add(picUrl);
                    }
            response.result.workProgressList =imagelist;
            
            sendResponse(response);
                }
            else{
                        log.response__c = 'No Document Found';
                        log.Status__c ='SUCCESS';
                        insert log;
                        
                        sendErrorResponse('No Document Found');
                        return;
                        
                    }
            
        }
        Catch (Exception e){
            log.response__c = e.getStackTraceString();
            log.Status__c ='FAIL';
            log.Error_Message__c = e.getMessage();
            insert log;
            
            sendErrorResponse('Error '+e.getMessage());
        }
        
    }
    public class WorkProgressScreenWrapper {
        public String userId;
        public String projectId;
        public String workProgressId;
        
    }
    public class WorkProgressResponse {
        public Boolean status;
        public String message;
        public WorkProgressResult result;
    }
    public class WorkProgressResult {
        public List<String> workProgressList;  // List of image URLs
    }
    
    // Helper method to send the response
    private static void sendResponse(WorkProgressResponse response) {
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
    @testVisible
    private static void sendErrorResponse(String message) {
        RestContext.response.statusCode = 400;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'status' => false,
                'message' => message
                }));
    }
}