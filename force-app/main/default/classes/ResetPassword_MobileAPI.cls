@RestResource(urlMapping='/ResetPasswordAPI/*')
global without sharing class ResetPassword_MobileAPI {
	
     @HttpPost
    global static void changePasswordMethod() {
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the JSON body
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='ResetPassword_MobileAPI';
        log.Request__c = requestBody;
        
        try{
            changedPassowrdWrapper newleaddata = (changedPassowrdWrapper) JSON.deserialize(requestBody, changedPassowrdWrapper.class);
            String newPassword = newleaddata.newPassword;
            String confirmPassword = newleaddata.confirmPassword;
            String cemail = newleaddata.email;
            String userId = newleaddata.userId;
            
            if (String.isBlank(userId) ||  String.isBlank(newPassword)  || String.isBlank(confirmPassword)  ) {
                log.response__c = 'Reset Passowrd data is blank';
                log.Status__c ='SUCCESS';
                insert log;
                sendErrorResponse('Reset Passowrd data should not be blank');
                return;
            }
            if(newPassword != confirmPassword){
                log.response__c = 'Password not matched';
                log.Status__c ='SUCCESS';
                insert log;
                sendErrorResponse('Password not matched');
                return;
            }
             List<Customer_Master__c> cmList = [ SELECT Id, Email__c, Password__c, First_Name__c, Last_Name__c, Phone__c,Name  FROM Customer_Master__c  WHERE Name = :userId AND isActive__c = TRUE AND Email__c=:cemail LIMIT 1 ];
            if (!cmList.isEmpty()) {
                cmList[0].Password__c=newPassword;
                update cmList;
                log.response__c = 'Reset password update successfully by ' + userId;
                log.Status__c = 'SUCCESS';
                insert log;
                
                sendSuccessResponse();
                
            }else{
                sendErrorResponse('User Not Found');
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
    
    public class changedPassowrdWrapper {
        public string email;
        public string newPassword;
        public string confirmPassword;
        public string userId;
    }
    
    public class ResponseWrapper {
        public Boolean success;
        public String message;
    }
    private static void sendErrorResponse(String message) {
        ResponseWrapper response = new ResponseWrapper();
        response.success = false;
        response.message = message;
        
        RestResponse res = RestContext.response;
        res.statusCode = 400;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
    private static void sendSuccessResponse() {
        ResponseWrapper response = new ResponseWrapper();
        response.success = true;
        response.message = 'Reset password updated successfully';
        
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
}