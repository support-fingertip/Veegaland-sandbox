/****************************************************************
* Class Name   : ProjectDetail_MobileAPI
* Company      : Fingertipplus
* Created Date : 27-05-2025
* @description :
* This Apex REST class exposes the `/ProjectDetailAPI/*` endpoint,allowing mobile apps to retrieve detailed information about a specific project. The API requires a valid `userId` and `projectId`,
* validates the customer, fetches associated project and amenity data,and returns a structured JSON response with all relevant details.
*
* Functional Flow:
* - Accepts a JSON request body containing `userId` and `projectId`.
* - Validates that both fields are provided and user is active.
* - Retrieves a single matching `Project__c` record based on `Project_Id__c`.
* - Gathers key project details: images, area, BHK types, pricing, location,
*   progress status, and description.
* - Extracts related `Amenity__c` records and maps them to a custom list.
* - Logs both request and response for monitoring and debugging.
*
* Author       : Praveen Kumar
*
* Change Log:
* --------------------------------------------------------------------------
* Ver | Author         | Date       | Description
* --------------------------------------------------------------------------
* 1.0 | Praveen Kumar  | 27-05-2025 | Initial version
* --------------------------------------------------------------------------
**************************************************************/

@RestResource(urlMapping='/ProjectDetailAPI/*')
global without sharing class ProjectDetail_MobileAPI {
    
    @HttpPost
    global static void getProjectDetail() {
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the JSON body
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='ProjectDetail_MobileAPI';
        log.Request__c =requestBody;
        
        try{
            ProjectWrapper proj = (ProjectWrapper) JSON.deserialize(requestBody, ProjectWrapper.class);
            String userId = proj.userId;
            String prjId = proj.projectId;
            
            if (String.isBlank(userId) || String.isBlank(prjId)) {
                log.response__c = 'UserId or ProjectId Should not be Null.';
                log.Status__c ='SUCCESS';
                insert log;
                sendErrorResponse('UserId or ProjectId Should not be Null.');
                return;
            }
            List<Customer_Master__c> cmList = [ SELECT Id, Email__c, Password__c, First_Name__c, Last_Name__c, Phone__c,Name  FROM Customer_Master__c  WHERE Name = :userId AND isActive__c = TRUE LIMIT 1 ];
            
            if (cmList.isEmpty() && userId!= '0') {
                log.response__c = 'Customer Not Found';
                log.Status__c ='SUCCESS';
                insert log;
                sendErrorResponse('Customer Not Found');
                return;
            }
            
            Project__c project = [ SELECT Id, Project_Status__c,Name,Area_Measure_In__c, Project__c, Display_in_Home__c,Display_in_Banner__c,projectSubImage__c,ProjectImage__c,BannerImage__c,BHK_Type__c,
                                  Area_Name__c,StartingPrice__c,Locality_Name__c ,WorkProgress__c,Project_description__c,Saleable_Area__c,Location__c,
                                  (SELECT Id, Name, AmenityImage__c FROM Amenities__r) FROM Project__c WHERE Project_Id__c = :prjId LIMIT 1  ];
            
            if (project == null) {
                log.response__c = 'Project Not Found';
                log.Status__c = 'SUCCESS';
                insert log;
                sendErrorResponse('Project Not Found');
                return;
            }
            
            
          //  String projectImageUrl = '';
            
                List<String> projectImageUrl = new List<String>();
            String subImageUrl = '';
            List<ContentDocumentLink> projLinks = new List<ContentDocumentLink>();
            if (project != null && project.Id != null) {
                projLinks = [  SELECT ContentDocumentId FROM ContentDocumentLink  WHERE LinkedEntityId = :project.Id ];
            } 
            Set<Id> docIds = new Set<Id>();
            for (ContentDocumentLink link : projLinks) {
                docIds.add(link.ContentDocumentId);
            }
            Map<Id, String> docIdToTitle = new Map<Id, String>();
            /*  for (ContentVersion cv : [  SELECT ContentDocumentId, Title  FROM ContentVersion WHERE ContentDocumentId IN :docIds]) {
docIdToTitle.put(cv.ContentDocumentId, cv.Title);
}*/
            
            List<ContentVersion> versions = [ SELECT Id, Title, FileExtension, ContentDocumentId  FROM ContentVersion  WHERE IsLatest = true AND ContentDocumentId IN :docIds];
            Set<id> cdid = new Set<id>();
            
            for (ContentVersion cv : versions) {
                cdid.add(cv.id);
                docIdToTitle.put(cv.id, cv.Title);
            }
            /*    List<ContentDistribution> cdlsy =[select id,DistributionPublicUrl,ContentDownloadUrl,ContentVersion.Title,ContentVersion.FileExtension,createdDate from ContentDistribution where ContentVersionId IN :cdid];

for (ContentDistribution cd : cdlsy) {
if(cd.ContentVersion.Title.Contains('Project detail page image')){
projectImageUrl = cd.DistributionPublicUrl;  
}
if(cd.ContentVersion.Title.Contains('Sub image')){
subImageUrl = cd.DistributionPublicUrl;  
}

}
*/
            for (ContentDistribution cd : [SELECT ContentDocumentId, DistributionPublicUrl,ContentVersion.Title,ContentVersionId,ContentDownloadUrl FROM ContentDistribution WHERE ContentVersionId IN :docIdToTitle.keySet()]) {
                //  String title = docIdToTitle.get(cd.ContentVersionId).toLowerCase();
                if (cd.ContentVersion.Title.contains('Sub image')) {
                    String picUrl = '';
                    picUrl =  cd.ContentDownloadUrl.replace('download/?' , 'renditionDownload?rendition=ORIGINAL_Jpg&');
                    picUrl = picUrl.replace('&ids' , '&versionId');
                    
                    subImageUrl =picUrl;
                }
            }
             for (ContentDistribution cd : [SELECT ContentDocumentId, DistributionPublicUrl,ContentVersion.Title,ContentVersionId,ContentDownloadUrl FROM ContentDistribution WHERE ContentVersionId IN :docIdToTitle.keySet() ORDER By ContentVersion.Title ASC]) {
             if (cd.ContentVersion.Title.contains('Project detail page image')) {
                    
                    String picUrl = '';
                    picUrl =  cd.ContentDownloadUrl.replace('download/?' , 'renditionDownload?rendition=ORIGINAL_Jpg&');
                    picUrl = picUrl.replace('&ids' , '&versionId');
                    
                    
                    
                    // projectImageUrl = cd.DistributionPublicUrl;
                    projectImageUrl.add(picUrl) ;
                }
             
             }
            
            List<Amenity__c> amenities = [SELECT Id, Name FROM Amenity__c   WHERE Project__c = :project.Id ];
            Map<Id, String> amenityImageMap = new Map<Id, String>();
            Set<Id> amenityIds = new Set<Id>();
            for (Amenity__c a : amenities){
                amenityIds.add(a.Id);
            } 
            
            if (!amenities.isEmpty()) {
                List<ContentDocumentLink> amenityLinks = [ SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :amenityIds  ];
                Set<Id> amenityDocIds = new Set<Id>();
                Map<Id, Id> amenityToDoc = new Map<Id, Id>();
                for (ContentDocumentLink link : amenityLinks) {
                    amenityDocIds.add(link.ContentDocumentId);
                    amenityToDoc.put(link.LinkedEntityId, link.ContentDocumentId);
                }
                
                for (ContentDistribution cd : [ SELECT ContentDocumentId, DistributionPublicUrl, ContentDownloadUrl FROM ContentDistribution WHERE ContentDocumentId IN :amenityDocIds   ]) {
                    for (Id amenityId : amenityToDoc.keySet()) {
                        if (amenityToDoc.get(amenityId) == cd.ContentDocumentId) {
                            
                            String picUrl = '';
                            picUrl =  cd.ContentDownloadUrl.replace('download/?' , 'renditionDownload?rendition=ORIGINAL_Jpg&');
                            picUrl = picUrl.replace('&ids' , '&versionId');
                            amenityImageMap.put(amenityId, picUrl);
                            
                            // amenityImageMap.put(amenityId, cd.DistributionPublicUrl);
                        }
                    }
                }
            }
            
            
            
            ProjectDetailResponse response = new ProjectDetailResponse();
            response.success = true;
            response.message = '';
            response.data = new ProjectData();
            
            // response.data.projectImage = project.ProjectImage__c;
            // response.data.projectSubImage = project.projectSubImage__c;
            
            response.data.projectImage = projectImageUrl;
            response.data.projectSubImage = subImageUrl;
            response.data.area =project.Saleable_Area__c ;
            response.data.apartment = parseMultiPicklist(project.BHK_Type__c);
           response.data.startingPrice =String.Valueof(project.StartingPrice__c );
           response.data.location = project.Area_Name__c +', '+ project.Locality_Name__c ;
            
            
           // response.data.workProgress = project.WorkProgress__c;
            
            
                if(project.Project_Status__c=='Complete'){
                     response.data.workProgress = 'Completed';
               
                }else{
                    
                response.data.workProgress = project.WorkProgress__c;
                }
            response.data.projectDescription = project.Project_Description__c;
            
            response.data.areaUnit = project.Area_Measure_In__c;
            
            if (project.Location__c != null) {
                        response.data.latitude = project.Location__c.getLatitude();
                        response.data.longitude = project.Location__c.getLongitude();
                    }
            
            response.data.amenities = new List<Amenity>();
            for (Amenity__c am : project.Amenities__r) {
                Amenity a = new Amenity();
                //a.image = am.AmenityImage__c;
                a.image = amenityImageMap.containsKey(am.Id) ? amenityImageMap.get(am.Id) : '';
                
                a.amenityName = am.Name;
                response.data.amenities.add(a);
            }
            
            sendResponse(response);
            
            // Log success
            log.response__c = JSON.serialize(response)+'=='+projectImageUrl;
            log.Status__c = 'SUCCESS';
            insert log;
            
        }
        Catch (Exception e){
            log.response__c = e.getStackTraceString();
            log.Status__c ='FAIL';
            log.Error_Message__c = e.getMessage();
            insert log;
            sendErrorResponse('Error: ' + e.getMessage());
            
        }
        
    }
    public class ProjectWrapper {
        public String userId;
        public String projectId;
        
    }
    private static List<String> parseMultiPicklist(String multiPicklistStr) {
        List<String> result = new List<String>();
        if (String.isNotBlank(multiPicklistStr)) {
            result = multiPicklistStr.split(';');
            for (Integer i = 0; i < result.size(); i++) {
                result[i] = result[i].trim();
            }
        }
        return result;
    }
    public class ProjectDetailResponse {
        public Boolean success;
        public String message;
        public ProjectData data;
    }
    public class ProjectData {
        public List<String> projectImage;
        public String projectSubImage;
        public String area;
        public List<String> apartment;
        public String startingPrice;
        public String location;
        public String workProgress;
        public String projectDescription;
        public String areaUnit;
        public List<Amenity> amenities;
        public Decimal latitude;
        public Decimal longitude;
   
    }
    public class Amenity {
        public String image;
        public String amenityName;
    }
    
    private static void sendResponse(ProjectDetailResponse responseWrapper) {
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
    }
    private static void sendErrorResponse(String message) {
        ProjectDetailResponse response = new ProjectDetailResponse();
        response.success = false;
        response.message = message;
        response.data = null;
        
        RestResponse res = RestContext.response;
        res.statusCode = 400;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
    
}