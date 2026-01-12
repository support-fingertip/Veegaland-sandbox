@RestResource(urlMapping='/WorkProgressScreenAPI/*')
global without sharing class WorkProgressscreen_MobileAPI {
    
    @HttpPost
    global static void getMyPropertiesDetail() {
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the JSON body
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='MyPropertyDetails_MobileAPI';
        
        try{
            WorkProgressScreenWrapper proj = (WorkProgressScreenWrapper) JSON.deserialize(requestBody, WorkProgressScreenWrapper.class);
            String userId = proj.userId;
            String projectId = proj.projectId;
            if (String.isBlank(userId) || String.isBlank(projectId) ) {
                log.response__c = 'UserId or projectId Should not be blank.';
                log.Status__c ='SUCCESS';
                insert log;
                
                sendErrorResponse('UserId or projectId Should not be blank.');
                return;
            }
            List<Customer_Master__c> cmList = [ SELECT Id, Email__c, Password__c, First_Name__c, Last_Name__c, Phone__c,Name  FROM Customer_Master__c  WHERE Name = :userId AND isActive__c = TRUE LIMIT 1 ];
            
            if (cmList.isEmpty()) {
                log.response__c = 'Customer Not Found';
                log.Status__c ='SUCCESS';
                insert log;
                
                sendErrorResponse('User Not Found');
                return;
            }
            Project__c project = [ SELECT Id, Name, Project__c, Display_in_Home__c,Project_Status__c
                                  FROM Project__c WHERE Project_Id__c = :projectId AND Project_Status__c!='Complete' LIMIT 1  ];
            
            
            if (project == null) {
                log.response__c = 'Project Not Found';
                log.Status__c = 'SUCCESS';
                insert log;
                sendErrorResponse('Project Not Found');
                return;
            }
            if(project.Project_Status__c=='Complete'){
                 log.response__c = 'Project is Completed';
                log.Status__c = 'SUCCESS';
                insert log;
                sendErrorResponse('Project is Completed');
                return;
           
            }
            List<Work_Progress__c> workplist = [Select id,Name,Work_Progress_till_Now__c,List_of_Image__c,Work_Progress_Month__c,Work_Progress_Year__c from Work_Progress__c where Project__c =: project.id];
            // Prepare response data
            WorkProgressResponse response = new WorkProgressResponse();
            response.status = 'true';
            response.message = '';
            response.result = new WorkProgressResult();
            response.result.workProgressList = new List<WorkProgressInfo>();
            
            for (Work_Progress__c work : workplist) {
                WorkProgressInfo progressInfo = new WorkProgressInfo();
                progressInfo.id = work.Name;
                progressInfo.wpdate = work.Work_Progress_till_Now__c; // Assuming CreatedDate is the date of work progress
               progressInfo.monthYear = work.Work_Progress_Month__c+' '+work.Work_Progress_Year__c;
                
                response.result.workProgressList.add(progressInfo);
            }
            
            // Sending the response
            sendResponse(response);
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
        
    }
    public class WorkProgressResponse {
        public String status;
        public String message;
        public WorkProgressResult result;
    }
    public class WorkProgressResult {
        public List<WorkProgressInfo> workProgressList;
    }
    public class WorkProgressInfo {
        public String id;
        public Date wpdate;
        public String monthYear;
    }
    private static void sendResponse(WorkProgressResponse response) {
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
    
    private static void sendErrorResponse(String message) {
        RestContext.response.statusCode = 400;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'status' => false,
                'message' => message
                }));
    }
    
}