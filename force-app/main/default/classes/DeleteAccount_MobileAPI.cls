@RestResource(urlMapping='/DeleteAccountAPI/*')
global without sharing class DeleteAccount_MobileAPI {
    
    
    @HttpPost
    global static void getMyPropertiesDetail() {
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the JSON body
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='DeleteAccount_MobileAPI';
        log.Request__c =requestBody;
        
        try{
            WorkProgressScreenWrapper proj = (WorkProgressScreenWrapper) JSON.deserialize(requestBody, WorkProgressScreenWrapper.class);
            String userId = proj.userId;
            
            if (String.isBlank(userId) ) {
                log.response__c = 'User Id Should not be blank.';
                log.Status__c ='SUCCESS';
                insert log;
                
                sendErrorResponse('Please Send correct userId');
                return;
            }
            List<Customer_Master__c> cmList = [ SELECT Id, Email__c, Password__c, First_Name__c, Last_Name__c, Phone__c,Name,isActive__c  FROM Customer_Master__c  WHERE Name = :userId AND isActive__c = TRUE LIMIT 1 ];
            
            if (cmList.isEmpty()) {
                log.response__c = 'Customer Not Found';
                log.Status__c ='SUCCESS';
                insert log;
                
                sendErrorResponse('User Not Found in System');
                return;
            }
            cmList[0].isActive__c= false;
            update cmList;
            DeleteAccountResponse response = new DeleteAccountResponse();
            response.status = true;
            response.message = 'Account deleted successfully';
            
            // Sending the response
            sendResponse(response);
            
            
        }
        Catch (Exception e){
            log.response__c = e.getStackTraceString();
            log.Status__c ='FAIL';
            log.Error_Message__c = e.getMessage();
            insert log;
            
        }
        
    }
    
    public class WorkProgressScreenWrapper {
        public String userId;
        
    }
    
    private static void sendErrorResponse(String message) {
        RestContext.response.statusCode = 400;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'status' => false,
                'message' => message
                }));
    }
    public class DeleteAccountResponse {
        public Boolean status;
        public String message;
    }
    private static void sendResponse(DeleteAccountResponse response) {
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
}