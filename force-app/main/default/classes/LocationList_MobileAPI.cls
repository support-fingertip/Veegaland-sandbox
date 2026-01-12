@RestResource(urlMapping='/LocationListAPI/*')
global without sharing class LocationList_MobileAPI {
    
    @HttpPost
    global static void getMyPropertiesDetail() {
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the JSON body
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='LocationList_MobileAPI';
        log.Request__c =requestBody;
        
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
            List<Customer_Master__c> cmList = [ SELECT Id, Email__c, Password__c, First_Name__c, Last_Name__c, Phone__c,Name  FROM Customer_Master__c  WHERE Name = :userId AND isActive__c = TRUE LIMIT 1 ];
            
            if (cmList.isEmpty() && userId!= '0') {
                log.response__c = 'Customer Not Found';
                log.Status__c ='SUCCESS';
                insert log;
                
                sendErrorResponse('User Not Found in System');
                return;
            }
            if(!cmList.isEmpty() || userId=='0'){
                
                List<Project__c> prolist = [select id,Location__c,City__c,Project_Id__c,City_Name__c from Project__c Where Active__c=TRUE AND Used_in_Mobile_App__c = TRUE];
                  List<Location__c> locationlist =[select id,Name,City_Name__c,Location__c,(Select id from Projects__r) from Location__c where ID IN (Select Master_Location__c from Project__c Where Active__c=TRUE)];
              
                // Prepare response data
                MyPropertiesResponse response = new MyPropertiesResponse();
                response.status = true;
                response.message = '';
                response.result = new MyPropertiesResult();
                response.result.locationList = new List<LocationInfo>();
                for (Project__c projRecord : prolist) {
                    LocationInfo location = new LocationInfo();
                    location.id = projRecord.Project_Id__c;
                    location.name = projRecord.City_Name__c ; // Combine City and Location for the name
                    
                    // Add location (latitude and longitude)
                    if (projRecord.Location__c != null) {
                        location.location = new LocationCoordinates();
                        location.location.latitude = projRecord.Location__c.getLatitude();
                        location.location.longitude = projRecord.Location__c.getLongitude();
                    }
                    
                    response.result.locationList.add(location);
                }
                sendResponse(response);
                
            }
            
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
        public List<LocationInfo> locationList;
    }
    public class LocationInfo {
        public String id;
        public String name;
        public LocationCoordinates location;  // Geolocation data (Latitude, Longitude)
    }
    public class LocationCoordinates {
        public Decimal latitude;
        public Decimal longitude;
    }
    private static void sendResponse(MyPropertiesResponse response) {
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
    
}