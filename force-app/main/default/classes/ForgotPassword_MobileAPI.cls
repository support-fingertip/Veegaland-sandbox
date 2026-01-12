@RestResource(urlMapping='/ForgotPasswordAPI/*')
global without sharing class ForgotPassword_MobileAPI {
    
    @HttpPost
    global static void changePasswordMethod() {
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the JSON body
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='GetProfile_MobileAPI';
        
        log.Request__c =requestBody;
        
        try{
            changedPassowrdWrapper newleaddata = (changedPassowrdWrapper) JSON.deserialize(requestBody, changedPassowrdWrapper.class);
            String phoneNumber = newleaddata.phoneNumber;
            String cemail = newleaddata.email;
            system.debug(phoneNumber +'=='+cemail);
            if (String.isBlank(phoneNumber) || String.isBlank(cemail)    ) {
                log.response__c = ' Phone Number or Email is blank';
                log.Status__c ='SUCCESS';
                insert log;
                sendErrorResponse('Phone Number or Email should not be blank');
                return;
            }
            List<Customer_Master__c> cmList = [ SELECT Id, Email__c, Password__c, First_Name__c, Last_Name__c, Phone__c,Name,OTP_Number__c  FROM Customer_Master__c  WHERE Email__c = :cemail AND isActive__c = TRUE AND Phone__c=:phoneNumber LIMIT 1 ];
            if (!cmList.isEmpty()) {
                String toEmail= cmList[0].Email__c;
                system.debug(toEmail);
                Integer otp = Math.round(Math.random() * 8999) + 1000;
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                cmList[0].OTP_Number__c=otp;
                update cmList;
                String userId = cmList[0].Name;
                // Set email parameters
                email.setToAddresses(new String[] { toEmail });
                email.setSubject('OTP for Forgot Password');
                
                String body = 'Dear User,\n\n';
                body += 'Your One-Time Password (OTP) for password reset is: ' + otp + '\n\n';
                
                body += 'Regards,\nSupport Team';
                
                email.setPlainTextBody(body);
                List<OrgWideEmailAddress> oweaList = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'systems@veegaland.com' LIMIT 1];
                if (!oweaList.isEmpty()) {
                    email.setOrgWideEmailAddressId(oweaList[0].Id);
                }
                
                // Send the email
               Messaging.SendEmailResult[] results =  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                
           
                
                log.response__c = 'OTP send successfully '+ results;
                log.Status__c = 'SUCCESS';
                insert log;
                
                sendSuccessResponse(userId);
                
            }else{
                log.response__c = 'User Not Found';
                log.Status__c = 'SUCCESS';
                insert log;
                
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
        public string phoneNumber;
    }
    public class ResponseWrapper {
        public Boolean success;
        public String message;
        public String userId;
    }
    private static void sendErrorResponse(String message) {
        ResponseWrapper response = new ResponseWrapper();
        response.success = false;
        response.message = message;
        
        RestResponse res = RestContext.response;
        res.statusCode = 400;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
    private static void sendSuccessResponse(String userId) {
        ResponseWrapper response = new ResponseWrapper();
        response.success = true;
        response.message = 'OTP send successfully';
        response.userId = userId;
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
    
    
}