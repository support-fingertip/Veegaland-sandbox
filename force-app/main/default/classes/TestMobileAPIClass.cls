@RestResource(urlMapping='/getProjectAttachmentLinks/*')
global without sharing  class TestMobileAPIClass {
    
     global class FileRequest {
        public String userId;
        public String isProjectDocument;
    }
       global class FileResponse {
        public String fileName;
        public String fileUrl;
    }
    
     @HttpPost
    global static List<FileResponse> doPost() {
        RestRequest req = RestContext.request;
        FileRequest input = (FileRequest) JSON.deserialize(req.requestBody.toString(), FileRequest.class);
        
        if (String.isBlank(input.userId) || String.isBlank(input.isProjectDocument)) {
            throw new AuraHandledException('Missing userId or isProjectDocument');
        }

        // Get Project
        Project__c project = [SELECT Id FROM Project__c WHERE Name = :input.isProjectDocument LIMIT 1 ];

        // Get linked ContentDocument IDs
        List<ContentDocumentLink> docLinks = [ SELECT ContentDocumentId  FROM ContentDocumentLink  WHERE LinkedEntityId = :project.Id   ];

        List<Id> docIds = new List<Id>();
        for (ContentDocumentLink link : docLinks) {
            docIds.add(link.ContentDocumentId);
        }

        List<FileResponse> responses = new List<FileResponse>();

        if (!docIds.isEmpty()) {
            // Get latest ContentVersion for each document
            List<ContentVersion> versions = [ SELECT Id, Title, FileExtension, ContentDocumentId  FROM ContentVersion  WHERE IsLatest = true AND ContentDocumentId IN :docIds];
            Set<id> cdid = new Set<id>();

            for (ContentVersion cv : versions) {
                cdid.add(cv.id);
                
            }
            
            List<ContentDistribution> cdlsy =[select id,DistributionPublicUrl,ContentDownloadUrl,ContentVersion.Title,ContentVersion.FileExtension,createdDate from ContentDistribution where ContentVersionId IN :cdid];
            for(ContentDistribution cd : cdlsy){
                FileResponse fr = new FileResponse();
                fr.fileName = cd.ContentVersion.Title + '.' + cd.ContentVersion.FileExtension;
                fr.fileUrl = cd.ContentDownloadUrl;
                responses.add(fr); 
            }
          
        }
        
        return responses;
    }
}