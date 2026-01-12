@RestResource(urlMapping='/MyPropertiesAPI/*')
global without sharing class MyProperties_MobileAPI {
    
    
    @HttpPost
    global static void getMyPropertiesDetail() {
        
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the JSON body
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='MyProperties_MobileAPI';
        log.Request__c =requestBody;
        
        try{
            MyPropertiesWrapper proj = (MyPropertiesWrapper) JSON.deserialize(requestBody, MyPropertiesWrapper.class);
            String userId = proj.userId;
            String search = proj.search;
            String startPrice = proj.startPrice;
            String endPrice = proj.endPrice;
            String startAreaRange = proj.startAreaRange;
            String endAreaRange = proj.endAreaRange;
            String bedroomCount = proj.bedroomCount;
            String parkingCount = proj.parkingCount;
            Integer pageSize = proj.pageSize;
            
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
                system.debug(cmList[0].id);
                List<Booking__c> booklist = [select id,Project__c,Plot__c from Booking__c where Customer_Master__c =: cmList[0].id  AND Stage__c NOT IN ('Cancellation', 'Unit Swap')];
                Set<Id> unitId = new Set<Id>();
                
                for(Booking__c bk : booklist){
                    if(bk.Plot__c!=null){
                        unitId.add(bk.Plot__c);
                    }
                }
                System.debug(unitId);
                // Fetch Projects related to Plots in the bookings
                List<Project__c> projectList = new List<Project__c>();
                List<Plot__c> unitlist = new List<Plot__c>();
                if (!unitId.isEmpty()) {
                    unitlist = [select id,Name,BHK_Type__c,No_of_Indivisual_Car_Parking__c,Built_up_area__c,Project__c,Project__r.Project_Id__c,Project__r.Name,Project__r.ProjectImage__c from Plot__c where Id IN : unitId Order By Name DESC limit 10 OFFSET : pageSize];
                    System.debug(unitlist);
                    //   projectList = [SELECT Id, Name, Project__c, Display_in_Home__c, Display_in_Banner__c,Project_Id__c,projectSubImage__c, ProjectImage__c, BannerImage__c, BHK_Type__c
                    //               FROM Project__c  WHERE Id IN (SELECT Project__c FROM Plot__c WHERE Id IN :unitId) ORDER BY Name  limit 10 OFFSET: pageSize];
                    
                    //  String baseQuery = 'SELECT Id, Name, Project_Id__c, Project__c, StartingPrice__c, Display_in_Home__c, Display_in_Banner__c, projectSubImage__c, ProjectImage__c, BannerImage__c, BHK_Type__c, Construction_Area__c,City__c,Maximum_No_of_Parking__c FROM Project__c';
                    String baseQuery = 'SELECT Id, Name, Project__c, Display_in_Home__c, Display_in_Banner__c, Project_Id__c, projectSubImage__c, ProjectImage__c, BannerImage__c, BHK_Type__c FROM Project__c WHERE Id IN (SELECT Project__c FROM Plot__c WHERE Id IN :unitId)';
                    
                    List<String> conditions = new List<String>();
                    
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
                    if (parkingCount != null && !String.isBlank(parkingCount)) {
                        try {
                            Integer parking = Integer.valueOf(parkingCount);
                            conditions.add('Maximum_No_of_Parking__c = ' + parking);
                        } catch (Exception e) {
                            System.debug('Invalid noOfParking: ' + parkingCount);
                        }
                    }
                    
                    if (!conditions.isEmpty()) {
                        baseQuery += ' AND ' + String.join(conditions, ' AND ');
                    }
                    
                    baseQuery += ' ORDER BY Name LIMIT 10 OFFSET ' + pageSize;
                    
                    System.debug('Final Query: ' + baseQuery);
                    
                   // projectList = Database.query(baseQuery);
                    System.debug(projectList);
                    
                     projectList= [SELECT Id, Name, Project__c, Display_in_Home__c, Display_in_Banner__c, Project_Id__c, projectSubImage__c, ProjectImage__c, BannerImage__c, BHK_Type__c FROM Project__c WHERE Id IN (SELECT Project__c FROM Plot__c WHERE Id IN :unitId)];
                }
                Map<Id, String> projectImageMap = new Map<Id, String>();              
                
                
                Set<Id> ProjectId = new Set<Id>();
                for (Project__c pr : projectList) {
                    ProjectId.add(pr.Id);
                }
                System.debug(ProjectId);
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
                
                
                
                ResponseWrapper response = new ResponseWrapper();
                response.success = true;
                response.message = '';
                response.data = new DataWrapper();
                
                List<ProjectResponse> allProjectList = new List<ProjectResponse>();
                /*  for (Project__c p : projectList) {
ProjectResponse pr = new ProjectResponse();
pr.projectId = p.Project_Id__c;
pr.projectName = p.Name;
pr.projectImage = p.ProjectImage__c != null ? p.ProjectImage__c : '';
//pr.area = p.Area__c != null ? String.valueOf(p.Area__c) : '';
//pr.beds = p.Beds__c != null ? String.valueOf(p.Beds__c) : '';
// pr.parking = p.Parking__c != null ? String.valueOf(p.Parking__c) : '';
allProjectList.add(pr);
}
*/
                for (Plot__c p : unitlist) {
                    system.debug('p '+ p);
                    ProjectResponse pr = new ProjectResponse();
                    pr.unitNumber = p.Name;
                    pr.projectId = p.Project__r.Project_Id__c;
                    pr.projectName = p.Project__r.Name;
                    //  pr.projectImage = p.Project__r.ProjectImage__c != null ? p.Project__r.ProjectImage__c : '';
                    pr.area = p.Built_up_area__c != null ? String.valueOf(p.Built_up_area__c) : '';
                    pr.beds = p.BHK_Type__c != null ? String.valueOf(p.BHK_Type__c) : '';
                    pr.parking = p.No_of_Indivisual_Car_Parking__c != null ? String.valueOf(p.No_of_Indivisual_Car_Parking__c) : '';
                    
                    if (projectToDocMap.containsKey(p.Project__c)) {
                        Id docId = projectToDocMap.get(p.Project__c);
                        system.debug(docId + '==='+ docToDistUrl.get(docId));
                        pr.projectImage = docToDistUrl.get(docId);
                    } else {
                        pr.projectImage = '';
                    }
                    
                    allProjectList.add(pr);
                    
                    
                }
                
                response.data.allProjectList = allProjectList;
                response.data.totalCount = allProjectList.size();
                log.response__c =string.valueof(response)+ '=='+ projectToDocMap+ '=='+docToDistUrl;
                log.Status__c ='SUCCESS';
                insert log;
                
                sendResponse(response);
                
                
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
    public class MyPropertiesWrapper {
        public String userId;
        public String search;
        public String startPrice;
        public String endPrice;
        public String startAreaRange;
        public String endAreaRange;
        public String bedroomCount;
        public String parkingCount;
        public Integer pageSize;
        
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
        public DataWrapper data;
    }
    public class DataWrapper {
        public List<ProjectResponse> allProjectList;
        public Integer totalCount;
    }
    public class ProjectResponse {
        public String projectId;
        public String projectImage;
        public String projectName;
        public String area;
        public String beds;
        public String parking;
        public String unitNumber;
    }
    private static void sendResponse(ResponseWrapper response) {
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
    
    
    
}