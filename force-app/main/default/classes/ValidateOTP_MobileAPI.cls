@RestResource(urlMapping='/ValidateOTPAPI/*')
global without sharing class ValidateOTP_MobileAPI {
    
    
    @HttpPost
    global static void getMyPropertiesDetail() {
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the JSON body
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='ValidateOTP_MobileAPI';
        
        try{
            WorkProgressScreenWrapper proj = (WorkProgressScreenWrapper) JSON.deserialize(requestBody, WorkProgressScreenWrapper.class);
            String userId = proj.userId;
            String otp = proj.otp;
            
            if (String.isBlank(userId) || String.isBlank(otp)) {
                log.response__c = 'User Id or OTP Should not be blank.';
                log.Status__c ='SUCCESS';
                insert log;
                
                sendErrorResponse('Please Send correct userId and OTP ');
                return;
            }
            List<Customer_Master__c> cmList = [ SELECT Id,OTP_Number__c  FROM Customer_Master__c  WHERE Name = :userId AND isActive__c = TRUE LIMIT 1 ];
            if (cmList.isEmpty()) {
                log.response__c = 'Customer Not Found';
                log.Status__c ='SUCCESS';
                insert log;
                
                sendErrorResponse('User Not Found in System');
                return;
            }
            
            if(cmList[0].OTP_Number__c == Integer.ValueOf(otp)){
                ResponseWrapper response = new ResponseWrapper();
                response.success = true;
                response.message = 'OTP Varified Successfully';
                
                RestResponse res = RestContext.response;
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(response));
            }
            else{
                 log.response__c = 'OTP not matched';
                log.Status__c ='SUCCESS';
                insert log;
               
                sendErrorResponse('OTP not matched' );
            }
        }
        Catch (Exception e){
            log.response__c = e.getStackTraceString();
            log.Status__c ='FAIL';
            log.Error_Message__c = e.getMessage();
            insert log;
            
            sendErrorResponse('Error '+ e.getMessage());
            
        }
        
    }
    
    public class WorkProgressScreenWrapper {
        public String userId;
        public String otp;
        
    }
    
    public class ResponseWrapper {
        public Boolean success;
        public String message;
    }
    
    private static void sendErrorResponse(String message) {
        RestContext.response.statusCode = 400;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'status' => false,
                'message' => message
                }));
    } 
    
}