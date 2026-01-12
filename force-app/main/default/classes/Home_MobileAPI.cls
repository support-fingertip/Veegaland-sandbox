/****************************************************************
* Class Name   : Home_MobileAPI
* Company      : Fingertipplus
* Created Date : 27-05-2025
* @description : 
* This class exposes a RESTful API endpoint `/HomeAPI/*` for mobile applications to retrieve dynamic home screen content. It accepts a userId as input, validates the user, and returns data for:
*  - Awards,Cities covered, Completed projects, Happy customers, Project images marked for homepage, Banner images for display
* 
* Functional Flow:
*  - Validates the userId parameter (must not be blank).
*  - Verifies the user exists and is active in the Customer_Master__c object.
*  - Retrieves a single Home__c record and all Project__c records.
*  - Filters project and banner images based on `Display_in_Home__c` and 
*    `Display_in_Banner__c` flags.
*  - Returns a structured JSON response containing numeric metrics and 
*    lists of image URLs.
*  - Logs both request and response to Apex_Log__c for traceability.
* 
* Author       : Praveen Kumar
* 
* Change Log:
* -----------------------------------------------------------------------------
* Ver | Author         | Date       | Description
* -----------------------------------------------------------------------------
* 1.0 | Praveen Kumar  | 27-05-2025 | Initial version
* -----------------------------------------------------------------------------
**************************************************************/

@RestResource(urlMapping='/HomeAPI/*')
global without sharing class Home_MobileAPI {
    
    @HttpPost
    global static void getHomeDetail() {
        
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the JSON body
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='Home_MobileAPI';
        log.Request__c =requestBody;
        try{
            
            HomeWrapper homedata = (HomeWrapper) JSON.deserialize(requestBody, HomeWrapper.class);
            String userId = homedata.userId;
            
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
            if((!cmList.isEmpty() ) || userId=='0'){
                Home__c home = [SELECT HappyCustomers__c,Awards__c,Cities__c,Complete_Projects__c FROM Home__c LIMIT 1];
                List<Project__c> projects = [SELECT Id, Display_in_Home__c,Display_in_Banner__c,projectSubImage__c,ProjectImage__c,BannerImage__c FROM Project__c Where Active__c=TRUE];
                
                // Banner Image for Display_in_Banner__c
                // Home Image for ProjectImage Display_in_Home__c
                Set<Id> ProjectId = new Set<Id>();
                Set<Id> bannerImageId = new Set<Id>();
                
                
                
                
                for(Project__c proj : projects){
                    if(proj.Display_in_Home__c){
                        ProjectId.add(proj.ID);
                    }
                    if(proj.Display_in_Banner__c){
                        bannerImageId.add(proj.ID);
                    }
                }
                List<ContentDocumentLink> docLinks = [ SELECT ContentDocumentId  FROM ContentDocumentLink  WHERE LinkedEntityId IN: ProjectId  ];
                List<ContentDocumentLink> bandocLinks = [ SELECT ContentDocumentId  FROM ContentDocumentLink  WHERE LinkedEntityId IN: bannerImageId  ];
                
                List<Id> docIds = new List<Id>();
                for (ContentDocumentLink link : docLinks) {
                    docIds.add(link.ContentDocumentId);
                }
                
                
                List<Id> bandocIds = new List<Id>();
                for (ContentDocumentLink link : bandocLinks) {
                    bandocIds.add(link.ContentDocumentId);
                }
                
                List<String> bannerImageList = new List<String>();
                List<String> projectImageList = new List<String>();
                
                if (!bandocIds.isEmpty()) {
                    List<ContentVersion> versions = [ SELECT Id, Title, FileExtension, ContentDocumentId  FROM ContentVersion  WHERE IsLatest = true AND ContentDocumentId IN :bandocIds];
                    Set<id> cdid = new Set<id>();
                    
                    for (ContentVersion cv : versions) {
                        if(cv.Title.Contains('Promotional Images') ){
                            cdid.add(cv.id);  
                        }
                        
                    }
                    
                    List<ContentDistribution> cdlsy =[select id,DistributionPublicUrl,ContentDownloadUrl,ContentVersion.Title,ContentVersion.FileExtension,createdDate from ContentDistribution where ContentVersionId IN :cdid ORDER BY CREATEDDATE DESC];
                    
                    
                    for(ContentDistribution cd : cdlsy){
                        
                        if(cd.ContentVersion.Title.Contains('Promotional Images')){
                            String picUrl = '';
                            picUrl =  cd.ContentDownloadUrl.replace('download/?' , 'renditionDownload?rendition=ORIGINAL_Jpg&');
                            picUrl = picUrl.replace('&ids' , '&versionId');
                            // docToDistUrl.get(dist.ContentDocumentId).add(picUrl);
                            // bannerImageList.add(cd.DistributionPublicUrl);
                            bannerImageList.add(picUrl);
                            
                        }
                    }
                    
                }
                
                
                if (!docIds.isEmpty()) {
                    List<ContentVersion> versions = [ SELECT Id, Title, FileExtension, ContentDocumentId  FROM ContentVersion  WHERE IsLatest = true AND ContentDocumentId IN :docIds];
                    Set<id> cdid = new Set<id>();
                    
                    for (ContentVersion cv : versions) {
                        if( cv.Title.Contains('Schedule Images')){
                            cdid.add(cv.id);  
                        }
                        
                    }
                    
                    List<ContentDistribution> cdlsy =[select id,DistributionPublicUrl,ContentDownloadUrl,ContentVersion.Title,ContentVersion.FileExtension,createdDate from ContentDistribution where ContentVersionId IN :cdid ORDER BY CREATEDDATE DESC ];
                    
                    
                    for(ContentDistribution cd : cdlsy){
                        
                        if(cd.ContentVersion.Title.Contains('Schedule Images')){
                            String picUrl = '';
                            picUrl =  cd.ContentDownloadUrl.replace('download/?' , 'renditionDownload?rendition=ORIGINAL_Jpg&');
                            picUrl = picUrl.replace('&ids' , '&versionId');
                            
                            // projectImageList.add(cd.DistributionPublicUrl);
                            
                            projectImageList.add(picUrl);
                            
                        }
                    }
                    
                }
                
                
                
                /*
for (Project__c proj : projects) {
if (proj.Display_in_Home__c ==true) {
projectImageList.add(proj.ProjectImage__c);
}
if (proj.Display_in_Banner__c == true) {
bannerImageList.add(proj.BannerImage__c);
}
}*/
                
                HomeResponse response = new HomeResponse();
                response.success = true;
                response.message = '';
                response.data = new HomeData();
                
                // response.data.awards = (home.Awards__c != null) ? Integer.valueOf(home.Awards__c) : 0;
                response.data.awards =Integer.ValueOf(label.awards);
                // response.data.cities = (home.Cities__c != null) ? Integer.valueOf(home.Cities__c) : 0;
                response.data.cities =Integer.ValueOf(label.city);
                //response.data.completeProjects = (home.Complete_Projects__c != null) ? Integer.valueOf(home.Complete_Projects__c) : 0;
                // response.data.happyCustomer = (home.HappyCustomers__c != null) ? Integer.valueOf(home.HappyCustomers__c) : 0;
                response.data.completeProjects =Integer.ValueOf(label.CompletedProject);
                response.data.happyCustomer =Integer.ValueOf(label.happyCustomer);                
                response.data.bannerImageList = bannerImageList;
                response.data.projectImageList = projectImageList;
                
                sendResponse(response);
                log.response__c =string.valueof(response) + projects.Size();
                log.Status__c ='SUCCESS';
                insert log;
                
            }
            
            
        }
        Catch (Exception e){
            log.response__c = e.getStackTraceString();
            log.Status__c ='FAIL';
            log.Error_Message__c = e.getMessage();
            insert log;
            
            sendErrorResponse('Login failed: ' + e.getMessage());
            
        }
        
    }
    
    
    public class HomeWrapper {
        public String userId;
    }
    public class HomeResponse {
        public Boolean success;
        public String message;
        public HomeData data;
    }
    public class HomeData {
        public List<String> bannerImageList;
        public Integer completeProjects;
        public Integer cities;
        public Integer awards;
        public Integer happyCustomer;
        public List<String> projectImageList;
    }
    private static void sendResponse(HomeResponse responseWrapper) {
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
    }
    private static void sendErrorResponse(String message) {
        RestContext.response.statusCode = 400;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'status' => false,
                'message' => message
                }));
    }
    
    
}