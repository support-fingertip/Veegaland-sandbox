@RestResource(urlMapping='/LocationFilterAPI/*')
global without sharing class LocationFilter_MobileAPI {
      @HttpPost
    global static void getAllprojectDetail() {
        
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the JSON body
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='AllProject_MobileAPI';
        log.Request__c =requestBody;
        
        try{
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
            
            if (String.isBlank(userId) ) {
                log.response__c = 'User Id Should not be blank.';
                log.Status__c ='SUCCESS';
                insert log;
                
                sendErrorResponse('Please Send correct userId');
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
            if(!cmList.isEmpty()){
                // List<Project__c> projectList = [SELECT Id, Name,Project_Id__c, Project__c, Display_in_Home__c,Display_in_Banner__c,projectSubImage__c,ProjectImage__c,BannerImage__c,BHK_Type__c FROM Project__c ];
                String baseQuery = 'SELECT Id, Name, Project_Id__c, Project__c, StartingPrice__c, Display_in_Home__c, Display_in_Banner__c, projectSubImage__c, ProjectImage__c, BannerImage__c, BHK_Type__c, Construction_Area__c,City__c,Maximum_No_of_Parking__c FROM Project__c';
                List<String> conditions = new List<String>();
               conditions.add('Active__c = TRUE');
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
                if (city != null && !String.isBlank(city)) {
                    conditions.add('City__c = \'' + String.escapeSingleQuotes(city.trim()) + '\'');
                }
                if (bedroomCount != null && !String.isBlank(bedroomCount)) {
                    conditions.add('BHK_Type__c INCLUDES (\'' + String.escapeSingleQuotes(bedroomCount.trim()) + '\')');
                }
                if (parkingCount != null && !String.isBlank(parkingCount)) {
                    try {
                        Integer parking = Integer.valueOf(parkingCount);
                        conditions.add('Maximum_No_of_Parking__c = ' + parking);
                    } catch (Exception e) {
                        System.debug('Invalid noOfParking: ' + parkingCount);
                    }
                }
                
                
                //baseQuery += ' ORDER BY Name LIMIT 10 OFFSET ' + pageSize;
               
                    if (!conditions.isEmpty()) {
                        baseQuery += ' WHERE ' + String.join(conditions, ' AND ');
                    }
                baseQuery += ' ORDER BY Name LIMIT 10 OFFSET ' + pageSize;
                System.debug('Final Query: ' + baseQuery);
                
                List<Project__c> projectList = Database.query(baseQuery);
                
                Map<Id, String> projectImageMap = new Map<Id, String>();              
                
                Set<Id> ProjectId = new Set<Id>();
                for (Project__c pr : projectList) {
                    ProjectId.add(pr.Id);
                }
                Map<Id, Id> projectToDocMap = new Map<Id, Id>();
                Map<Id, String> docToDistUrl = new Map<Id, String>();
                
                if(!ProjectId.isEmpty()){
                    
                    List<ContentDocumentLink> docLinks = [ SELECT ContentDocumentId, LinkedEntityId   FROM ContentDocumentLink WHERE LinkedEntityId IN :ProjectId];
                    Set<Id> contentDocIds = new Set<Id>();
                    for (ContentDocumentLink link : docLinks) {
                        contentDocIds.add(link.ContentDocumentId);
                    }
                    Map<Id, String> docIdToTitle = new Map<Id, String>();
                    for (ContentVersion cv : [SELECT ContentDocumentId, Title FROM ContentVersion    WHERE ContentDocumentId IN :contentDocIds AND Title LIKE '%Project list view%' ]) {
                        docIdToTitle.put(cv.ContentDocumentId, cv.Title);
                    }
                    
                    for (ContentDistribution dist : [ SELECT ContentDocumentId, DistributionPublicUrl,ContentDownloadUrl FROM ContentDistribution WHERE ContentDocumentId IN :docIdToTitle.keySet() ]) {
                        
                        String picUrl = '';
                        picUrl =  dist.ContentDownloadUrl.replace('download/?' , 'renditionDownload?rendition=ORIGINAL_Jpg&');
                        picUrl = picUrl.replace('&ids' , '&versionId');
                        
                        docToDistUrl.put(dist.ContentDocumentId, picUrl);
                    }
                    for (ContentDocumentLink link : docLinks) {
                        Id docId = link.ContentDocumentId;
                        Id projId = link.LinkedEntityId;
                        if (docToDistUrl.containsKey(docId)) {
                            projectToDocMap.put(projId, docId);
                        }
                    }
                    
                    
                    
                }
                
                List<ProjectResponse> allProjectList = new List<ProjectResponse>();
                
                for (Project__c p : projectList) {
                    ProjectResponse pr = new ProjectResponse();
                    pr.projectId = p.Project_Id__c;
                    pr.projSalesforceId = p.ID;
                    pr.projectName = p.Project__c;
                    pr.bhkCount = parseBhkCount(p.BHK_Type__c);
                    
                    if (projectToDocMap.containsKey(p.Id)) {
                        Id docId = projectToDocMap.get(p.Id);
                        pr.projectImage = docToDistUrl.get(docId);
                    } else {
                        pr.projectImage = '';
                    }
                    
                    allProjectList.add(pr);
                }
                
                
                
                ResponseWrapper response = new ResponseWrapper();
                response.success = true;
                response.message = '';
                response.data = new DataWrapper();
                response.data.allProjectList = allProjectList;
                response.data.totalCount = allProjectList.size();
                
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
            sendErrorResponse('Error: ' + e.getMessage());
            
        }
        
    }
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
        public String projectImage;
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
    private static void sendResponse(ResponseWrapper responseWrapper) {
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
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