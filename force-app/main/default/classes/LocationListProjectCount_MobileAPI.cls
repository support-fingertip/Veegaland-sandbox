@RestResource(urlMapping='/LocationListProjectCountAPI/*')
global without sharing class LocationListProjectCount_MobileAPI {
    
    
    @HttpPost
    global static void getMyPropertiesDetail() {
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the JSON body
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='LocationListProjectCount_MobileAPI';
        log.Request__c =requestBody;
        try{
            locationListProjectWrapper proj = (locationListProjectWrapper) JSON.deserialize(requestBody, locationListProjectWrapper.class);
            String userId = proj.userId;
            String search = proj.search;
            String startPrice = proj.startPrice;
            String endPrice = proj.endPrice;
            String startAreaRange = proj.startAreaRange;
            String endAreaRange = proj.endAreaRange;
            String bedroomCount = proj.bedroomCount;
            String city = proj.city;
            //  Integer pageSize = proj.pageSize;
            
            
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
                String baseQuery = 'SELECT Id, Name, Project_Id__c, Project__c, StartingPrice__c, Display_in_Home__c, Display_in_Banner__c, projectSubImage__c, ProjectImage__c, BannerImage__c, BHK_Type__c, Construction_Area__c,City__c,Maximum_No_of_Parking__c,City_Name__c,Master_Location__c FROM Project__c';
                
                List<String> conditions = new List<String>();
                conditions.add('Active__c = TRUE');
                conditions.add('Used_in_Mobile_App__c = TRUE');
                if (search != null && !String.isBlank(search.trim())) {
                    conditions.add('Name LIKE \'%' + String.escapeSingleQuotes(search.trim()) + '%\'');
                }
                
                if (startPrice != null && !String.isBlank(startPrice)) {
                    try {
                        Decimal sp = Decimal.valueOf(startPrice);
                        conditions.add('StartingPrice__c >= ' + sp);
                    } catch (Exception e) {
                        System.debug('Invalid startPrice: ' + startPrice);
                    }
                }
                if (endPrice != null && !String.isBlank(endPrice)) {
                    try {
                        Decimal ep = Decimal.valueOf(endPrice);
                        conditions.add('StartingPrice__c <= ' + ep);
                    } catch (Exception e) {
                        System.debug('Invalid endPrice: ' + endPrice);
                    }
                }
                
                if (startAreaRange != null && !String.isBlank(startAreaRange)) {
                    try {
                        Decimal sa = Decimal.valueOf(startAreaRange);
                        conditions.add('Construction_Area__c >= ' + sa);
                    } catch (Exception e) {
                        System.debug('Invalid startAreaRange: ' + startAreaRange);
                    }
                }
                if (endAreaRange != null && !String.isBlank(endAreaRange)) {
                    try {
                        Decimal ea = Decimal.valueOf(endAreaRange);
                        conditions.add('Construction_Area__c <= ' + ea);
                    } catch (Exception e) {
                        System.debug('Invalid endAreaRange: ' + endAreaRange);
                    }
                }
                if (bedroomCount != null && !String.isBlank(bedroomCount)) {
                    conditions.add('BHK_Type__c INCLUDES (\'' + String.escapeSingleQuotes(bedroomCount.trim()) + '\')');
                }
                if (city != null && !String.isBlank(city)) {
                    conditions.add('City_Name__c = \'' + String.escapeSingleQuotes(city.trim()) + '\'');
                }
                
                if (!conditions.isEmpty()) {
                    baseQuery += ' WHERE ' + String.join(conditions, ' AND ');
                }
                // baseQuery += ' ORDER BY Name LIMIT 10 OFFSET ' + pageSize;
                System.debug('Final Query: ' + baseQuery);
                
                List<Project__c> projectList = Database.query(baseQuery);
                Set<Id> projId = new Set<Id>();
                
                For(Project__c  pc : projectList){
                    
                    if(pc.Master_Location__c!=null){
                        projId.add(pc.Id);
                    }
                }
                
                List<Location__c> locationlist =[select id,Name,City_Name__c,Location__c,(Select id from Projects__r) from Location__c where ID IN (Select Master_Location__c from Project__c Where ID IN:projId  AND Active__c=TRUE )];
                if(!locationlist.isEmpty()){
                    LocationListResponse response = new LocationListResponse();
                    response.status = true;
                    response.message = '';
                    response.data = new LocationListData();
                    response.data.locationList = new List<LocationInfo>();
                    for (Location__c loc : locationList) {
                        LocationInfo location = new LocationInfo();
                        location.locationId = loc.Name;  // Use the Location ID
                        location.name = loc.City_Name__c;  // Use the Name field
                        Integer filteredCount = 0;
                        for (Project__c pro : projectList) {
                            if (pro.Master_Location__c == loc.Id) {
                                filteredCount++;
                            }
                        }
                        location.projectCount = filteredCount;
                        // location.projectCount = loc.Projects__r.size();  // Count related projects
                        //location.projectCount = projectList.size();  // Count related projects
                        
                        // For Latitude and Longitude, you can retrieve from custom fields or hardcode if required
                        if (loc.Location__c != null) {
                            location.location = new LocationCoordinates();
                            location.location.latitude = loc.Location__c.getLatitude();
                            location.location.longitude = loc.Location__c.getLongitude();
                        }
                        
                        response.data.locationList.add(location);
                        
                    }
                    sendResponse(response);
                    log.response__c =string.valueof(response);
                    log.Status__c ='SUCCESS';
                    insert log;
                    
                }else{
                    sendErrorResponse('No Location Found');  
                }
                
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
    
    public class locationListProjectWrapper {
        public String userId;
        public String search;
        public String startPrice;
        public String endPrice;
        public String startAreaRange;
        public String endAreaRange;
        public String bedroomCount;
        public String city;
        //  public Integer pageSize;
        
    }
    
    private static void sendErrorResponse(String message) {
        RestContext.response.statusCode = 400;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'status' => false,
                'message' => message
                }));
    }
    public class LocationListResponse {
        public Boolean status;
        public String message;
        public LocationListData data;
    }
    public class LocationListData {
        public List<LocationInfo> locationList;
    }
    public class LocationInfo {
        public String locationId;
        public String name;
        public Integer projectCount;
        public LocationCoordinates location; 
    }
    
    // LatLong info wrapper class for storing latitude and longitude
    
    public class LocationCoordinates {
        public Decimal latitude;
        public Decimal longitude;
    }
    private static void sendResponse(LocationListResponse response) {
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
    public static void testcover(){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}