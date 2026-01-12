@RestResource(urlMapping='/LocationWiseProjectListAPI/*')
global without sharing class LocationWiseProjectList {
    
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
            String locationId = proj.locationId;
            String search = proj.search;
            String startPrice = proj.startPrice;
            String endPrice = proj.endPrice;
            String startAreaRange = proj.startAreaRange;
            String endAreaRange = proj.endAreaRange;
            String bedroomCount = proj.bedroomCount;
            String city = proj.city;
          //  Integer pageSize = proj.pageSize;
            
            
            
            if (String.isBlank(userId) || String.isBlank(userId) ) {
                log.response__c = 'User Id or Location Id Should not be blank.';
                log.Status__c ='SUCCESS';
                insert log;
                
                sendErrorResponse('Please Send correct userId and Location Id');
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
                List<Location__c> locationlist =[select id,Name,City_Name__c,Location__c from Location__c where Name=: locationId limit 1];
                String baseQuery = 'SELECT Id, Name, Project_Id__c, Location__c,Project__c, StartingPrice__c, Display_in_Home__c, Display_in_Banner__c, projectSubImage__c, ProjectImage__c, BannerImage__c, BHK_Type__c, Construction_Area__c,City__c,Maximum_No_of_Parking__c,City_Name__c,Master_Location__c FROM Project__c';
                
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
               
                // Master Location filter (if available)
                if (!locationlist.isEmpty()) {
                    conditions.add('Master_Location__c = \'' + String.escapeSingleQuotes(locationlist[0].Id) + '\'');
                }
                if (!conditions.isEmpty()) {
                    baseQuery += ' WHERE ' + String.join(conditions, ' AND ');
                }
           //     baseQuery += ' ORDER BY Name LIMIT 10 OFFSET ' + pageSize;
                System.debug('Final Query: ' + baseQuery);
                
                
                
                List<Project__c> Projlist = Database.query(baseQuery);
                
                
                
               // List<Project__c> Projlist =[select id,Location__c,Project_Id__c,Name from Project__c where Master_Location__c =: locationlist[0].id AND Active__c=TRUE] ;
                Set<Id> ProjectId = new Set<Id>();
                Map<Id, String> projectImageMap = new Map<Id, String>();              
                Map<Id, Id> projectToDocMap = new Map<Id, Id>();
                Map<Id, String> docToDistUrl = new Map<Id, String>();
               
                for (Project__c pr : Projlist) {
                    ProjectId.add(pr.Id);
                }
               
                if(!ProjectId.isEmpty()){
                    List<ContentDocumentLink> docLinks = [ SELECT ContentDocumentId, LinkedEntityId   FROM ContentDocumentLink WHERE LinkedEntityId IN :ProjectId];
                    Set<Id> contentDocIds = new Set<Id>();
                    for (ContentDocumentLink link : docLinks) {
                        contentDocIds.add(link.ContentDocumentId);
                    }
                    Map<Id, String> docIdToTitle = new Map<Id, String>();
                    for (ContentVersion cv : [SELECT ContentDocumentId, Title FROM ContentVersion    WHERE ContentDocumentId IN :contentDocIds AND Title LIKE '%Project Logo%' ]) {
                        docIdToTitle.put(cv.ContentDocumentId, cv.Title);
                    }
                    if(docIdToTitle.IsEmpty()){
                        
                    }
                    for (ContentDistribution cd : [ SELECT ContentDocumentId, DistributionPublicUrl,ContentDownloadUrl FROM ContentDistribution WHERE ContentDocumentId IN :docIdToTitle.keySet() ]) {
                        String picUrl = '';
                        picUrl =  cd.ContentDownloadUrl.replace('download/?' , 'renditionDownload?rendition=ORIGINAL_Jpg&');
                        picUrl = picUrl.replace('&ids' , '&versionId');
                        
                        docToDistUrl.put(cd.ContentDocumentId,picUrl);
                    }
                    for (ContentDocumentLink link : docLinks) {
                        Id docId = link.ContentDocumentId;
                        Id projId = link.LinkedEntityId;
                        if (docToDistUrl.containsKey(docId)) {
                            projectToDocMap.put(projId, docId);
                        }
                    }
                    
                }
                
                MyPropertiesResponse response = new MyPropertiesResponse();
                response.status = true;
                response.message = '';
                response.data = new MyPropertiesResult();
                response.data.projectList = new List<ProjectInfo>();
                
                for (Project__c projRecord : Projlist) {
                    ProjectInfo location = new ProjectInfo();
                    location.projectId = projRecord.Project_Id__c;
                    location.name = projRecord.Name;
                    
                    
                    if (projectToDocMap.containsKey(projRecord.Id)) {
                        Id docId = projectToDocMap.get(projRecord.Id);
                        location.projectLogo = docToDistUrl.get(docId);
                    } else {
                        location.projectLogo = '';
                    }
                    
                    // location.name = projRecord.City__c ; // Combine City and Location for the name
                    
                    // Add location (latitude and longitude)
                    if (projRecord.Location__c != null) {
                        location.location = new LocationCoordinates();
                        location.location.latitude = projRecord.Location__c.getLatitude();
                        location.location.longitude = projRecord.Location__c.getLongitude();
                    }
                    
                    response.data.projectList.add(location);
                }
                sendResponse(response);
                 log.response__c =string.valueof(response);
                log.Status__c ='SUCCESS';
                insert log;
               
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
        public String locationId;
        public String search;
        public String startPrice;
        public String endPrice;
        public String startAreaRange;
        public String endAreaRange;
        public String bedroomCount;
        public String city;
      //  public Integer pageSize;
        
        
    }
    public class MyPropertiesResponse {
        public Boolean status;
        public String message;
        public MyPropertiesResult data;
    }
    
    // Result wrapper class containing the project list
    public class MyPropertiesResult {
        public List<ProjectInfo> projectList;
    }
    public class ProjectInfo {
        public String projectId;
        public String name;
        public String projectLogo;
        public LocationCoordinates location;
    }
    
    // LatLong info wrapper class for latitude and longitude
    public class LocationCoordinates {
        public Decimal latitude;
        public Decimal longitude;
    }
    
    
    private static void sendErrorResponse(String message) {
        RestContext.response.statusCode = 400;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'status' => false,
                'message' => message
                }));
    }
    private static void sendResponse(MyPropertiesResponse response) {
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
  
}