/****************************************************************
* Class Name   : LoginAPI_MobileAPI
* Company      : Fingertipplus
* Created Date : 27-05-2025
* @description : 
* This class exposes a RESTful POST web service endpoint for login functionality, primarily used in a mobile application. It accepts JSON input containing the user's email and password, verifies the 
* credentials against active records in the Customer_Master__c object, and returns a structured JSON response including user information  on successful login or appropriate error messages on failure.
* 
* The flow includes:
*  - JSON request body parsing
*  - Null/blank validation of credentials
*  - Authentication against active Customer_Master__c records
*  - Structured success or failure response generation
*  - Logging of all activity via the Apex_Log__c custom object
* 
* 
* Author       : Praveen Kumar
* 
* Change Log:
* ----------------------------------------------------------------------------- 
* Ver | Author           | Date       | Description
* ----------------------------------------------------------------------------- 
* 1.0 | Praveen Kumar    | 27-05-2025 | Initial version
* ----------------------------------------------------------------------------- 
**************************************************************/

@RestResource(urlMapping='/LoginAPI/*')
global without sharing class LoginAPI_MobileAPI{
    @HttpPost
    global static void CheckLogin() {
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the JSON body
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='LoginAPI_MobileAPI';
        log.Request__c =requestBody;
        
        try{
            
            // Deserialize the JSON body into the callWrapper class
            loginWrapper logindata = (loginWrapper) JSON.deserialize(requestBody, loginWrapper.class);
            String cemail = logindata.email;
            String cpass = logindata.password;
            String deviceId = logindata.deviceId;
            
            system.debug(cemail +'===='+ cpass);
            // Null check
            if (String.isBlank(cemail) || String.isBlank(cpass)  ) {
                log.response__c = 'Email or Password is not Vailid.';
                log.Status__c ='SUCCESS';
                insert log;
                
                sendErrorResponse('Please enter correct email and password');
                return;
            }
            
           
                List<Customer_Master__c> cmList = [ SELECT Id,AssociationUser__c, Email__c, Password__c, First_Name__c, Last_Name__c, Phone__c,Name  FROM Customer_Master__c  WHERE Email__c = :cemail AND Password__c = :cpass AND isActive__c=True  LIMIT 1 ];
            
            
            if (cmList.isEmpty()) {
                log.response__c = 'Customer Not Found';
                log.Status__c ='SUCCESS';
                insert log;
                
                sendErrorResponse('Customer Not Found');
                return;
            } 
            
           
            Customer_Master__c cm = cmList[0];
            List<Logged_in_Device__c> dvlst = [select id,Status__c,Last_Logged_Out__c from Logged_in_Device__c where Device_Id__c =: deviceId AND Customer_Master__c =:cmList[0].Id limit 1]; 
            if(dvlst.Size()==0){
                
                Logged_in_Device__c lgd = new Logged_in_Device__c();
                lgd.Customer_Master__c =cmList[0].Id;
                lgd.Last_Logged_In__c = System.Now();
                lgd.Status__c ='Active';
                lgd.Device_Id__c =deviceId;
                insert lgd;
            }
            else if(dvlst.Size()==1){
                dvlst[0].Status__c = 'Active';
                dvlst[0].Last_Logged_In__c = System.Now();
                update dvlst[0];
                
            } 
            
            Map<String, Object> responseData = new Map<String, Object>();
            responseData.put('status', true);
            responseData.put('message', 'Login successfully');
            
            Map<String, Object> data = new Map<String, Object>{
                'firstName' => cm.First_Name__c,
                    'lastName' => cm.Last_Name__c,
                    'email' => cm.Email__c,
                    'phoneNumber' => cm.Phone__c,
                    'isAssociationLogin' => cm.AssociationUser__c,
                    'userId' => cm.Name
                    };
                        responseData.put('data', data);
            
            RestContext.response.statusCode = 200;
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(responseData));
            log.response__c = string.valueof(cm);
            log.Status__c ='SUCCESS';
            insert log;
            
            
           // Boolean assosiationlogin = Boolean.valueOf(isAssociationLogin);
            
            
        }catch (Exception e){
            log.response__c = e.getStackTraceString();
            log.Status__c ='FAIL';
            log.Error_Message__c = e.getMessage();
            insert log;
            
            /*
System.debug('Error creating task: ' + e.getMessage());
RestContext.response.statusCode = 400;
RestContext.response.responseBody = Blob.valueOf('Error: ' + e.getMessage());
*/
            sendErrorResponse('Login failed: ' + e.getMessage());
            
        }
        
        
    }
    
    // Wrapper class for deserialization
    public class loginWrapper {
        public String email;
        public String password;
        public String deviceId;
    }
    private static void sendErrorResponse(String message) {
        RestContext.response.statusCode = 400;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'status' => false,
                'message' => message
                }));
    }
    
}