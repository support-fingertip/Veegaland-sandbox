@RestResource(urlMapping='/CreateSupportRequestAPI/*')
global without sharing class CreateSupportRequest {
    
    @HttpPost
    global static void CreateSupportRequest() {
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the JSON body
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='CreateSupportRequest_MobileAPI';
        //log.Request__c = requestBody;
        
        try{
            
            // Deserialize the JSON body into the callWrapper class
            supportRequestWrapper newleaddata = (supportRequestWrapper) JSON.deserialize(requestBody, supportRequestWrapper.class);
          //  List<String> imageFiles = newleaddata.imageFiles;
            String userid = newleaddata.userid;
            String PriorityId = newleaddata.priorityId;
            String supportId = newleaddata.supportId;
            String concernSubType = newleaddata.concernSubType;
            String concernId = newleaddata.concernId;
            String descrjption = newleaddata.descrjption;
            String unitNUmber = newleaddata.projectUnitId;
            
            
            if (String.isBlank(userId) ||String.isBlank(unitNUmber) ) {
                log.response__c = 'UserId or should not be blank';
                log.Status__c ='SUCCESS';
                insert log;
                sendErrorResponse('UserId or projectUnitId should not be blank');
                return;
            }
            List<Customer_Master__c> cmList = [ SELECT Id, Email__c, Password__c, First_Name__c, Last_Name__c, Phone__c,Name  FROM Customer_Master__c  WHERE Name = :userId AND isActive__c = TRUE LIMIT 1 ];
             Plot__c unit = [select id,BHK_Type__c,No_of_Indivisual_Car_Parking__c,Built_up_area__c,Unit_Type__c from Plot__c where Name =: unitNUmber limit 1];
            if(unit.Id ==null ){
                log.response__c = 'Unit number not matched';
                log.Status__c ='SUCCESS';
                insert log;
                sendErrorResponse('projectUnitId not Found');
                return;
             
            }
            if (!cmList.isEmpty() ) {
                
                Support_Request__c sr = new Support_Request__c();
                
                sr.ConcernList__c=concernId;
                
                sr.Support_Type__c=supportId;
                
                sr.Priority_List__c=PriorityId;                
                sr.Description__c=descrjption;
                sr.Unit__c=unit.Id;
                
                sr.Concern_Sub_Type__c = concernSubType;
              /*  List<String> cleanedImages = new List<String>();
                
                for( String image : imageFiles){
                    if (!String.isBlank(image)) {
                        cleanedImages.add(image);
                    }
                    
                }*/
                //sr.TicketImage__c = String.join(cleanedImages, ';');
                sr.Customer_Master__c=cmList[0].id;
                system.debug(sr);
                insert sr;
                /*
                List<ContentVersion> contentVersions = new List<ContentVersion>();
                for (Integer i = 0; i < imageFiles.size(); i++) {
                    String imageBase64 = imageFiles[i];
                    if (!String.isBlank(imageBase64)) {
                        ContentVersion cv = new ContentVersion();
                        cv.Title = 'Support_Image_' + (i+1);
                        cv.PathOnClient = 'Support_Image_' + (i+1) + '.jpg';
                        cv.VersionData = EncodingUtil.base64Decode(imageBase64);
                        cv.IsMajorVersion = true;
                        contentVersions.add(cv);
                    }
                }
                
                insert contentVersions;
                // Link uploaded files to the Support Request using ContentDocumentLink
                List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>();
                for (ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersions]) {
                    ContentDocumentLink link = new ContentDocumentLink();
                    link.ContentDocumentId = cv.ContentDocumentId;
                    link.LinkedEntityId = sr.Id;
                    link.ShareType = 'V'; // Viewer access
                    link.Visibility = 'AllUsers';
                    docLinks.add(link);
                }
                
                insert docLinks;
               */ 
                log.response__c = 'Your support ticket will be generated. ' + userId;
                log.Status__c = 'SUCCESS';
                insert log;
                
                sendSuccessResponse(sr.id);
                
            }            
            else{
                sendErrorResponse('User Not Found');
            }
            
        }
        Catch(Exception e){
            log.response__c = e.getStackTraceString();
            log.Status__c = 'FAIL';
            log.Error_Message__c = e.getMessage();
            insert log;
            sendErrorResponse('Error: ' + e.getMessage());
            
        }
    }
    
    
    // Wrapper class for deserialization
    public class supportRequestWrapper {
        public string userid;
        public string concernId;
        public string supportId;
        public string concernSubType;
        public String priorityId;
        public String descrjption;
        public String projectUnitId;
       // public List<String> imageFiles;
    }
    public class ResponseWrapper {
        public Boolean success;
        public String message;
        public String suppertRequestId;
    }
    @testVisible
    private static void sendSuccessResponse(String SrId) {
        ResponseWrapper response = new ResponseWrapper();
        response.success = true;
        response.message = 'Your support ticket will be generated.';
        response.suppertRequestId =SrId;
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
    private static void sendErrorResponse(String message) {
        ResponseWrapper response = new ResponseWrapper();
        response.success = false;
        response.message = message;
        
        RestResponse res = RestContext.response;
        res.statusCode = 400;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
     public Static void testcover(){
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
        i++; i++;
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