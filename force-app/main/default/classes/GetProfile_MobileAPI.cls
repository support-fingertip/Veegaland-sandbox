@RestResource(urlMapping='/GetProfileAPI/*')
global without sharing class GetProfile_MobileAPI {
    
    
    @HttpPost
    global static void getProfileMethod() {
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the JSON body
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='GetProfile_MobileAPI';
        log.Request__c = requestBody;
        
        try{
            
            // Deserialize the JSON body into the callWrapper class
            getProfileWrapper newleaddata = (getProfileWrapper) JSON.deserialize(requestBody, getProfileWrapper.class);
            String userid = newleaddata.userId;
            system.debug(userid);
            if (String.isBlank(userId)  ) {
                log.response__c = 'UserId should not be blank';
                log.Status__c ='SUCCESS';
                insert log;
                sendErrorResponse('UserId should not be blank');
                return;
            }
            List<Customer_Master__c> cmList = [ SELECT Id, Email__c, Password__c, First_Name__c, Last_Name__c, Phone__c,Name ,AssociationUser__c FROM Customer_Master__c  WHERE Name = :userId AND isActive__c = TRUE LIMIT 1 ];
            if (!cmList.isEmpty()) {
                Customer_Master__c customer = cmList[0];
                
                // Prepare the response object
                ResponseWrapper response = new ResponseWrapper();
                response.success = true;
                response.message = 'User profile update successfully';
                // Create the data response object
                DataWrapper data = new DataWrapper();
                data.firstName = cmList[0].First_Name__c;
                data.lastName = cmList[0].Last_Name__c;
                data.email = cmList[0].Email__c;
                data.phoneNumber = cmList[0].Phone__c;
                data.userid = cmList[0].Name;
                data.isAssociationLogin = cmList[0].AssociationUser__c;
                // data.profileImage = customer.Profile_Image__c;
                // Set the response data
                response.data = data;
                log.response__c = 'User profile update successfully ' + userId;
                log.Status__c = 'SUCCESS';
                insert log;
                
                // Send the response
                sendResponse(response);
                
            }
            else {
                // If no customer is found
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
    public class getProfileWrapper {
        public string userId;
    }
    
    public class ResponseWrapper {
        public Boolean success;
        public String message;
        public DataWrapper data;
    }
    public class DataWrapper {
        public String firstName;
        public String lastName;
        public String email;
        public String phoneNumber;
        public String userid;
        public String profileImage;
        public Boolean isAssociationLogin ;
    }
    private static void sendResponse(ResponseWrapper response) {
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
    private static void sendErrorResponse(String message) {
        ResponseWrapper response = new ResponseWrapper();
        response.success = false;
        response.message = message;
        
        RestResponse res = RestContext.response;
        res.statusCode = 400;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
    
}