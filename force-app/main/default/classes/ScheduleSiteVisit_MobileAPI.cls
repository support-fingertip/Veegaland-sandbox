@RestResource(urlMapping='/ScheduleSiteVisitAPI/*')
global without sharing class ScheduleSiteVisit_MobileAPI {
    
    
    @HttpPost
    global static void createSiteVisit() {
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the JSON body
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='ScheduleSiteVisit_MobileAPI';
        log.Request__c = requestBody;
        try{
            SiteVisitDataWrapper proj = (SiteVisitDataWrapper) JSON.deserialize(requestBody, SiteVisitDataWrapper.class);
            String userId = proj.userId;
            String projectId = proj.projectId;
            String firstName = proj.firstName;
            String lastName = proj.lastName;
            String email = proj.email;
            String phoneNumber = proj.phoneNumber;
            DateTime svdate = proj.svdate;
            
             System.debug('emailfinal '+ email);
             System.debug('phoneNumberfinal '+ phoneNumber);
             
            
            System.debug('svdate '+ svdate);
            
            
            if (String.isBlank(userId) ||String.isBlank(projectId) || String.isBlank(lastName)|| String.isBlank(phoneNumber) ) {
                log.response__c = 'Lead Data should not be blank';
                log.Status__c ='SUCCESS';
                insert log;
                sendErrorResponse('Lead Data should not be blank');
                return;
            }
            List<Customer_Master__c> cmList = [ SELECT Id, Email__c, Password__c, First_Name__c, Last_Name__c, Phone__c,Name  FROM Customer_Master__c  WHERE Name = :userId AND isActive__c = TRUE LIMIT 1 ];
            
            if (cmList.isEmpty()) {
                log.response__c = 'Customer Not Found';
                log.Status__c ='SUCCESS';
                insert log;
                sendErrorResponse('User Not Found in System');
                return;
            }
            Set <String> PhoneSet = new Set<String>();
            Set <String> mailSet = new Set<String>();
            
            Project__c project = [ SELECT Id, Name, Project__c, Display_in_Home__c,Display_in_Banner__c,projectSubImage__c,ProjectImage__c,BannerImage__c,BHK_Type__c FROM Project__c WHERE Project_Id__c = :projectId LIMIT 1  ];
            
            List<Lead> oldLeadList = [SELECT Id,Email,Phone,PhoneProject__c,Secondary_Phone_Project__c,SecondaryEmailProject__c,EmailProject__c,Secondary_phone__c,Secondary_Email__c,OwnerId, Allocated_Project__c FROM Lead WHERE (Phone =: phoneNumber OR Email =:  email OR Secondary_phone__c =:phoneNumber OR Secondary_Email__c =: email) AND Lead_Stage__c!='Closed Lost' AND Lead_Stage__c!='Booked' ORDER BY CreatedDate ASC limit 1];        
           system.debug('oldLeadList'+oldLeadList);
            if(oldLeadList.size()>0){
                CreateALogAfterLeasdUpdate.fromUpdateLeadStatus=true;
                Site_Visit__c sv = new Site_Visit__c();
                sv.Lead__c = oldLeadList[0].id;
                sv.Date__c =svdate;
               
                insert sv;
                
                log.response__c = 'Site Visit Created Successfully by ' + userId;
                log.Status__c = 'SUCCESS';
                insert log;
                
                sendSuccessResponse();
                
            }
            else{
                Lead ld = new Lead();
                ld.LastName = lastName;
                ld.Allocated_Project__c = project.Project__c;
                ld.Phone= phoneNumber;
                ld.Email =email;
                ld.Company = 'Veegaland';
                ld.Leadsource__c ='Mobile App';
                ld.Sub_Source__c = 'Created By '+ cmList[0].Name;
                
                insert ld;
                Site_Visit__c sv = new Site_Visit__c();
                sv.Lead__c = ld.id;
                sv.Date__c =svdate;
                insert sv;
                log.response__c = 'Lead and Site Visit Created Successfully by ' + userId;
                log.Status__c = 'SUCCESS';
                insert log;
                
                sendSuccessResponse();
                
                
            }
            
        }
        Catch (Exception e){
            log.response__c = e.getStackTraceString();
            log.Status__c ='FAIL';
            log.Error_Message__c = e.getMessage();
            insert log;
            sendErrorResponse('Error: ' + e.getMessage());
            
        }
    }
    
    public class SiteVisitDataWrapper {
        public String userId;
        public String projectId;
        public String firstName;
        public String lastName;
        public String email;
        public String phoneNumber;
        public DateTime svdate;
        
    }
    
    private static void sendErrorResponse(String message) {
        RestContext.response.statusCode = 400;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'status' => false,
                'message' => message
                }));
    }
    public class ResponseWrapper {
        public Boolean success;
        public String message;
    }
    @TestVisible
    private static void sendSuccessResponse() {
        ResponseWrapper response = new ResponseWrapper();
        response.success = true;
        response.message = 'site book successfully';
        
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
    
}