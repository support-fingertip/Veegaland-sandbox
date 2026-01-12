@RestResource(urlMapping='/ProjectNameListAPI/*')
global without sharing class ProjectNameList_MobileAPI {
    
    
    @HttpPost
    global static void getProjectNameList() {
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the JSON body
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='ProjectNameList_MobileAPI';
        log.Request__c =requestBody;
        try{
            ProjectNameListWrapper proj = (ProjectNameListWrapper) JSON.deserialize(requestBody, ProjectNameListWrapper.class);
            
            String userId = proj.userId;
            
            if (String.isBlank(userId)  ) {
                log.response__c = 'UserId Should not be blank.';
                log.Status__c ='SUCCESS';
                insert log;
                
                sendErrorResponse('Please Send correct Data');
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
            List<Project__c> projlst = [select id, Name,Project__c, Project_Id__c from Project__c];
            
            ProjectResponse response = new ProjectResponse();
            response.success = true;
            response.message = '';
            response.data = new DataWrapper();
            
            List<ProjectInfo> projectList = new List<ProjectInfo>();
            
            for (Project__c pro : projlst) {
                projectList.add(new ProjectInfo(pro.Project_Id__c, pro.Name));
            }
            response.data.projectList = projectList;
            
            // Sending response with the project data
            sendResponse(response);
            
            
        }
        
        Catch (Exception e){
            log.response__c = e.getStackTraceString();
            log.Status__c ='FAIL';
            log.Error_Message__c = e.getMessage();
            insert log;
            sendErrorResponse('Error: ' + e.getMessage());
            
        }
    }
    
    public class ProjectNameListWrapper {
        public String userId;
        
    }
    public class ProjectResponse {
        public Boolean success;
        public String message;
        public DataWrapper data;
    }
    
    public class DataWrapper {
        public List<ProjectInfo> projectList;
    }
    public class ProjectInfo {
        public String projectId;
        public String projectName;
        
        public ProjectInfo(String projectId, String projectName) {
            this.projectId = projectId;
            this.projectName = projectName;
        }
    }
    private static void sendResponse(ProjectResponse response) {
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