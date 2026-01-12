@RestResource(urlMapping='/PhoneNumberAPI/*')
global without sharing class PhoneNumber_MobileAPI {
    
    @HttpPost
    global static void getMyPropertiesDetail() {
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the JSON body
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='PhoneNumber_MobileAPI';
        
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
            List<Customer_Master__c> cmList = [ SELECT Id, Email__c, Password__c, First_Name__c, Last_Name__c, Phone__c,Name,WhatsApp_Number__c  FROM Customer_Master__c  WHERE Name = :userId AND isActive__c = TRUE LIMIT 1 ];
            if (cmList.isEmpty() && userId!= '0') {
                log.response__c = 'Customer Not Found';
                log.Status__c ='SUCCESS';
                insert log;
                
                sendErrorResponse('User Not Found in System');
                return;
            }
            MyPropertiesResponse response = new MyPropertiesResponse();
            response.status = true;
            response.message = '';
            response.result = new MyPropertiesResult();
            response.result.phoneNumber = System.Label.Phone_Number;
            response.result.whatsAppNumber = System.Label.WhatsApp_Number;
            
            // Sending the response
            sendResponse(response);
        }
        Catch (Exception e){
            log.response__c = e.getStackTraceString();
            log.Status__c ='FAIL';
            log.Error_Message__c = e.getMessage();
            insert log;
            
                sendErrorResponse('Error'+ e.getMessage());
            
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
    public class MyPropertiesResponse {
        public Boolean status;
        public String message;
        public MyPropertiesResult result;
    }
    public class MyPropertiesResult {
        public String phoneNumber;
        public String whatsAppNumber;
    }
    
    // Helper method to send the response
    private static void sendResponse(MyPropertiesResponse response) {
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
}