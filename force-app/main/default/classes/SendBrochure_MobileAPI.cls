@RestResource(urlMapping='/SendBrochureAPI/*')
global without sharing class SendBrochure_MobileAPI {
    
     @HttpPost
    global static void getProjectDetail() {
         RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the JSON body
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='SendBrochure_MobileAPI';
        log.Request__c =requestBody;
        
        try{
            broucherWrapper data = (broucherWrapper) JSON.deserialize(requestBody, broucherWrapper.class);
            String projectId = data.projectId;
            String userid = data.userid;
            String name = data.name;
            String email = data.email;
            String phoneNumber = data.phoneNumber;
            
            
            if (String.isBlank(userId) ||String.isBlank(projectId) || String.isBlank(name)|| String.isBlank(email) ) {
                log.response__c = 'Data should not be blank';
                log.Status__c ='SUCCESS';
                insert log;
                sendErrorResponse('Data should not be blank');
                return;
            }
            
              Project__c project = [ SELECT Id, Name, Project__c, Display_in_Home__c,Display_in_Banner__c,projectSubImage__c,ProjectImage__c,BannerImage__c,BHK_Type__c FROM Project__c WHERE Project_Id__c = :projectId LIMIT 1  ];
             if (project == null) {
                log.response__c = 'Project Not Found';
                log.Status__c = 'SUCCESS';
                insert log;
                sendErrorResponse('Project Not Found');
                return;
            }
              List<Attachment> attachments = [ SELECT Id, Name, Body, ContentType FROM Attachment WHERE ParentId = :project.Id];
             List<ContentDocumentLink> contentLinks = [ SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink WHERE LinkedEntityId = :project.Id AND ContentDocument.Title LIKE '%Project Brochure%' ];
              List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();

           // Add Attachment files
            for (Attachment att : attachments) {
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(att.Name);
                efa.setBody(att.Body);
                efa.setContentType(att.ContentType);
                emailAttachments.add(efa);
            }  
            // Add ContentDocument files (Files)
          for (ContentDocumentLink cdl : contentLinks) {
                ContentVersion cv = [ SELECT VersionData, Title, FileExtension FROM ContentVersion  WHERE Id = :cdl.ContentDocument.LatestPublishedVersionId LIMIT 1];
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(cv.Title + '.' + cv.FileExtension);
                efa.setBody(cv.VersionData);
                efa.setContentType(getMimeType(cv.FileExtension));
                emailAttachments.add(efa);
            }
            
            sendBrochureEmail(email, name, project.Name, emailAttachments);

            log.response__c = 'Brochure email sent successfully to ' + email;
            log.Status__c = 'SUCCESS';
            insert log;

            sendSuccessResponse('We will send the brochure to your provided email ID.');

          
        }
        Catch (Exception e){
             log.response__c = e.getStackTraceString();
            log.Status__c = 'FAIL';
            log.Error_Message__c = e.getMessage();
            insert log;
            sendErrorResponse('Error: ' + e.getMessage());
           
        }
    }
    
    // Wrapper class for deserialization
    public class broucherWrapper {
        public string userid;
        public string projectId;
        public string name;
        public String email;
        public String phoneNumber;
    }
    public class ResponseWrapper {
        public Boolean success;
        public String message;
    }
    private static void sendSuccessResponse(String message) {
        ResponseWrapper response = new ResponseWrapper();
        response.success = true;
        response.message = message;
        
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
      private static void sendBrochureEmail(String toAddress, String recipientName, String projectName, List<Messaging.EmailFileAttachment> attachments) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
                string companyName;
               
                if(!companyDetails.isEmpty()){
                    companyName = companyDetails[0].Label;
                       
                }
        mail.setToAddresses(new String[] { toAddress });
        mail.setSubject('Brochure for Project: ' + projectName);
        String body = 'Dear ' + recipientName + ',<br/><br/>' +
                      'Please find attached the brochure and documents for project "' + projectName + '".<br/><br/>' +
                      'Regards,<br/>'+companyName;

        mail.setHtmlBody(body);

        if (!attachments.isEmpty()) {
            mail.setFileAttachments(attachments);
        }

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
  @TestVisible  
 private static String getMimeType(String fileExt) {
        fileExt = fileExt != null ? fileExt.toLowerCase() : '';
        switch on fileExt {
            when 'pdf' { return 'application/pdf'; }
            when 'jpg', 'jpeg' { return 'image/jpeg'; }
            when 'png' { return 'image/png'; }
            when 'doc' { return 'application/msword'; }
            when 'docx' { return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'; }
            when 'xls' { return 'application/vnd.ms-excel'; }
            when 'xlsx' { return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'; }
            when else { return 'application/octet-stream'; }
        }
    }

}