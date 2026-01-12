@RestResource(urlMapping='/AllProject/*')
global without sharing class AllProject_MobileAPI_Copy {
    
    @HttpPost
    global static void getAllprojectDetail() {
        
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString();
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c = 'AllProject_MobileAPI';
        log.Request__c = requestBody;
        
        try {
            AllProjectWrapper proj = (AllProjectWrapper) JSON.deserialize(requestBody, AllProjectWrapper.class);
            String userId = proj.userId;
            String search = proj.search;
            String startPrice = proj.startPrice;
            String endPrice = proj.endPrice;
            String startAreaRange = proj.startAreaRange;
            String endAreaRange = proj.endAreaRange;
            String bedroomCount = proj.bedroomCount;
            String parkingCount = proj.parkingCount;
            Integer pageSize = proj.pageSize;
            String city = proj.city;
            
            if (String.isBlank(userId)) {
                log.response__c = 'User Id Should not be blank.';
                log.Status__c = 'SUCCESS';
                insert log;
                sendErrorResponse('Please Send correct userId');
                return;
            }
            
            List<Customer_Master__c> cmList = [ SELECT Id, Email__c, Password__c, First_Name__c, Last_Name__c, Phone__c, Name  
                                               FROM Customer_Master__c  WHERE Name = :userId AND isActive__c = TRUE LIMIT 1 ];
            
            if (cmList.isEmpty() && userId != '0') {
                log.response__c = 'Customer Not Found';
                log.Status__c = 'SUCCESS';
                insert log;
                sendErrorResponse('User Not Found in System');
                return;
            }
            
            if (!cmList.isEmpty() || userId == '0') {
                String baseQuery = 
                    'SELECT Id, Name, Project_Id__c, Project__c, StartingPrice__c, Display_in_Home__c, Display_in_Banner__c, ' +
                    'projectSubImage__c, ProjectImage__c, BannerImage__c, BHK_Type__c, Construction_Area__c, City__c, Maximum_No_of_Parking__c ' +
                    'FROM Project__c';
                
                List<String> conditions = new List<String>();
                conditions.add('Active__c = TRUE');
                conditions.add('Used_in_Mobile_App__c = TRUE');
                
                if (!String.isBlank(search)) {
                    conditions.add('Name LIKE \'%' + String.escapeSingleQuotes(search.trim()) + '%\'');
                }
                if (!String.isBlank(startPrice)) {
                    try {
                        Decimal sp = Decimal.valueOf(startPrice);
                        conditions.add('StartingPrice__c >= ' + sp);
                    } catch (Exception e) {}
                }
                if (!String.isBlank(endPrice)) {
                    try {
                        Decimal ep = Decimal.valueOf(endPrice);
                        conditions.add('StartingPrice__c <= ' + ep);
                    } catch (Exception e) {}
                }
                if (!String.isBlank(startAreaRange)) {
                    try {
                        Decimal sa = Decimal.valueOf(startAreaRange);
                        conditions.add('Construction_Area__c >= ' + sa);
                    } catch (Exception e) {}
                }
                if (!String.isBlank(endAreaRange)) {
                    try {
                        Decimal ea = Decimal.valueOf(endAreaRange);
                        conditions.add('Construction_Area__c <= ' + ea);
                    } catch (Exception e) {}
                }
                if (!String.isBlank(city)) {
                    conditions.add('City__c = \'' + String.escapeSingleQuotes(city.trim()) + '\'');
                }
                if (!String.isBlank(bedroomCount)) {
                    conditions.add('BHK_Type__c INCLUDES (\'' + String.escapeSingleQuotes(bedroomCount.trim()) + '\')');
                }
                if (!String.isBlank(parkingCount)) {
                    try {
                        Integer parking = Integer.valueOf(parkingCount);
                        conditions.add('Maximum_No_of_Parking__c = ' + parking);
                    } catch (Exception e) {}
                }
                
                if (!conditions.isEmpty()) {
                    baseQuery += ' WHERE ' + String.join(conditions, ' AND ');
                }
                baseQuery += ' ORDER BY Name LIMIT 10 OFFSET ' + pageSize;
                
                List<Project__c> projectList = Database.query(baseQuery);
                Set<Id> projectIds = new Set<Id>();
                
                for (Project__c pr : projectList) {
                    projectIds.add(pr.Id);
                }
                
                Map<Id, List<String>> projectToImageUrls = new Map<Id, List<String>>();
                
                if (!projectIds.isEmpty()) {
                    List<ContentDocumentLink> docLinks = [ SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :projectIds];
                    Set<Id> contentDocIds = new Set<Id>();
                    for (ContentDocumentLink link : docLinks) {
                        contentDocIds.add(link.ContentDocumentId);
                    }
                    
                    // Get ContentVersions related to our documents
                    List<ContentVersion> images = [ SELECT ContentDocumentId, Title    FROM ContentVersion   WHERE ContentDocumentId IN :contentDocIds   AND Title LIKE '%Project list view%' ];
                    
                    Map<Id, String> docIdToTitle = new Map<Id, String>();
                    for (ContentVersion cv : images) {
                        docIdToTitle.put(cv.ContentDocumentId, cv.Title);
                    }
                    
                    // Get public URLs
                    Map<Id, String> docToDistUrl = new Map<Id, String>();
                    for (ContentDistribution dist : [ SELECT ContentDocumentId, ContentDownloadUrl FROM ContentDistribution WHERE ContentDocumentId IN :docIdToTitle.keySet()  ]) {
                        String picUrl = dist.ContentDownloadUrl
                            .replace('download/?', 'renditionDownload?rendition=ORIGINAL_Jpg&')
                            .replace('&ids', '&versionId');
                        docToDistUrl.put(dist.ContentDocumentId, picUrl);
                    }
                    
                    // Build map: Project → List<Image URLs] (Elevation first)
                    for (ContentDocumentLink link : docLinks) {
                        Id projId = link.LinkedEntityId;
                        Id docId = link.ContentDocumentId;
                        
                        if (docToDistUrl.containsKey(docId)) {
                            // Ensure project entry exists
                            if (!projectToImageUrls.containsKey(projId)) {
                                projectToImageUrls.put(projId, new List<String>());
                            }
                            
                            List<String> imageList = projectToImageUrls.get(projId);
                            String title = docIdToTitle.get(docId);
                            String imageUrl = docToDistUrl.get(docId);
                            
                            // Safe "Elevation-first" insert logic
                            if (title != null && title.toLowerCase().contains('elevation')) {
                                if (imageList.isEmpty()) {
                                    imageList.add(imageUrl); // just add if list is empty
                                } else {
                                    imageList.add(0, imageUrl); // insert at front if list exists
                                }
                            } else {
                                imageList.add(imageUrl);
                            }
                            
                            // Put back the updated list
                            projectToImageUrls.put(projId, imageList);
                        }
                    }
                }
                
                // Build response
                List<ProjectResponse> allProjectList = new List<ProjectResponse>();
                for (Project__c p : projectList) {
                    ProjectResponse pr = new ProjectResponse();
                    pr.projectId = p.Project_Id__c;
                    pr.projSalesforceId = p.Id;
                    pr.projectName = p.Project__c;
                    pr.bhkCount = parseBhkCount(p.BHK_Type__c);
                    pr.projectImage = projectToImageUrls.containsKey(p.Id)
                        ? projectToImageUrls.get(p.Id)
                        : new List<String>();
                    allProjectList.add(pr);
                }
                
                ResponseWrapper response = new ResponseWrapper();
                response.success = true;
                response.message = '';
                response.data = new DataWrapper();
                response.data.allProjectList = allProjectList;
                response.data.totalCount = allProjectList.size();
                
                sendResponse(response);
                log.response__c = JSON.serialize(response);
                log.Status__c = 'SUCCESS';
                insert log;
            }
        } catch (Exception e) {
            log.response__c = e.getStackTraceString();
            log.Status__c = 'FAIL';
            log.Error_Message__c = e.getMessage();
            insert log;
            sendErrorResponse('Error: ' + e.getMessage());
        }
    }
    
    // --- Wrapper Classes ---
    public class AllProjectWrapper {
        public String userId;
        public String search;
        public String startPrice;
        public String endPrice;
        public String startAreaRange;
        public String endAreaRange;
        public String bedroomCount;
        public String parkingCount;
        public Integer pageSize;
        public String city;
    }
    
    public class ProjectResponse {
        public String projectId;
        public List<String> projectImage;
        public String projectName;
        public String projSalesforceId;
        public List<String> bhkCount;
    }
    
    public class DataWrapper {
        public List<ProjectResponse> allProjectList;
        public Integer totalCount;
    }
    
    public class ResponseWrapper {
        public Boolean success;
        public String message;
        public DataWrapper data;
    }
    
    // --- Utility Methods ---
    private static void sendResponse(ResponseWrapper responseWrapper) {
        RestContext.response.statusCode = 200;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
    }
    
    private static void sendErrorResponse(String message) {
        RestContext.response.statusCode = 400;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'success' => false,
                'message' => message
                }));
    }
    
    private static List<String> parseBhkCount(String bhkCountStr) {
        List<String> bhkList = new List<String>();
        if (String.isNotBlank(bhkCountStr)) {
            bhkList = bhkCountStr.split(';');
            for (Integer i = 0; i < bhkList.size(); i++) {
                bhkList[i] = bhkList[i].trim();
            }
        }
        return bhkList;
    }
    
}