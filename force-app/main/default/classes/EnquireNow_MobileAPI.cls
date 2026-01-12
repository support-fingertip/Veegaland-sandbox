@RestResource(urlMapping='/EnquireNowAPI/*')
global without sharing  class EnquireNow_MobileAPI {
    
    
    @HttpPost
    global static void CreateLead() {
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the JSON body
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='EnquireNow_MobileAPI';
        log.Request__c = requestBody;
        
        try{
            
            // Deserialize the JSON body into the callWrapper class
            LeadWrapper newleaddata = (LeadWrapper) JSON.deserialize(requestBody, LeadWrapper.class);
            String projectId = newleaddata.projectId;
            String userid = newleaddata.userid;
            String lastName = newleaddata.lastName;
            String firstName = newleaddata.firstName;
            String email = newleaddata.email;
            String phoneNumber = newleaddata.phoneNumber;
            
            
            if (String.isBlank(userId) ||String.isBlank(projectId) || String.isBlank(lastName)|| String.isBlank(phoneNumber) ) {
                log.response__c = 'Lead Data should not be blank';
                log.Status__c ='SUCCESS';
                insert log;
                sendErrorResponse('Lead Data should not be blank');
                return;
            }
             List<Customer_Master__c> cmList = [ SELECT Id, Email__c, Password__c, First_Name__c, Last_Name__c, Phone__c,Name  FROM Customer_Master__c  WHERE Name = :userId AND isActive__c = TRUE LIMIT 1 ];
            Project__c project = [ SELECT Id, Name, Project__c, Display_in_Home__c,Display_in_Banner__c,projectSubImage__c,ProjectImage__c,BannerImage__c,BHK_Type__c FROM Project__c WHERE Project_Id__c = :projectId LIMIT 1  ];
            
            
            Lead ld = new Lead();
            ld.LastName = lastName;
            ld.FirstName = firstName;
            ld.Allocated_Project__c = project.Project__c;
            ld.Phone= phoneNumber;
            ld.Email =email;
            ld.Company = 'Veegaland';
            ld.Leadsource__c='Mobile App';
            ld.Sub_Source__c = 'Created By '+ cmList[0].Name;
            
            insert ld;
            
            
            
            
            log.response__c = 'Data Submitted Successfully ' + userId+'=='+ ld.Id;
            log.Status__c = 'SUCCESS';
            insert log;
            
            sendSuccessResponse();
            
        }
        Catch(Exception e){
            log.response__c = e.getStackTraceString();
            log.Status__c = 'FAIL';
            log.Error_Message__c = e.getMessage();
            insert log;
            sendErrorResponse('Error: ' + e.getMessage());
            
        }
    }
    
    
    // Wrapper class for deserialization
    public class LeadWrapper {
        public string userid;
        public string projectId;
        public string lastName;
         public string firstName;
        public String email;
        public String phoneNumber;
    }
    public class ResponseWrapper {
        public Boolean success;
        public String message;
    }
    private static void sendSuccessResponse() {
        ResponseWrapper response = new ResponseWrapper();
        response.success = true;
        response.message = 'Enquiry submitted successfully';
        
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