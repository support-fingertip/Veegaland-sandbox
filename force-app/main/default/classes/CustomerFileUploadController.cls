public without sharing class CustomerFileUploadController {
    
    public String bookingId { get; set; }
    public String fileNaming { get; set; }
    
    public CustomerFileUploadController() {
        bookingId = ApexPages.currentPage().getParameters().get('id');
        fileNaming = ApexPages.currentPage().getParameters().get('filename');
    }
    
    @RemoteAction
    public static String uploadFile(String fileNaming, String fileName, String fileData, String recordId) {
        try {
            if (String.isEmpty(recordId)) {
                return 'Error: No Record ID Provided!';
            }
            
            // Get all existing ContentDocumentIds linked to the record
            List<Id> contentDocIds = new List<Id>();
            for (ContentDocumentLink link : [
                SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId
            ]) {
                contentDocIds.add(link.ContentDocumentId);
            }
            
            // Check if a document with the same title already exists
            ContentDocument existingDoc = null;
            if (!contentDocIds.isEmpty()) {
                for (ContentDocument doc : [
                    SELECT Id, Title FROM ContentDocument WHERE Id IN :contentDocIds
                ]) {
                    if (doc.Title == fileNaming) {
                        existingDoc = doc;
                        break;
                    }
                }
            }
            
            // Create new ContentVersion
            ContentVersion fileVersion = new ContentVersion();
            fileVersion.Title = fileNaming;
            fileVersion.PathOnClient = fileName;
            fileVersion.Origin = 'C';
            fileVersion.VersionData = EncodingUtil.base64Decode(fileData);
            
            if (existingDoc != null) {
                // Add a new version to the existing document
                fileVersion.ContentDocumentId = existingDoc.Id;
            } else {
                // New file entirely
                fileVersion.FirstPublishLocationId = recordId;
            }
            
            insert fileVersion;
            
            // Only create a ContentDocumentLink if this is a new document
            if (existingDoc == null) {
                List<ContentDocument> docs = [
                    SELECT Id FROM ContentDocument 
                    WHERE LatestPublishedVersionId = :fileVersion.Id 
                    LIMIT 1
                ];
                
                if (!docs.isEmpty()) {
                    ContentDocument newDoc = docs[0];
                    
                    Boolean isAlreadyLinked = ![
                        SELECT Id FROM ContentDocumentLink 
                        WHERE ContentDocumentId = :newDoc.Id AND LinkedEntityId = :recordId 
                        LIMIT 1
                    ].isEmpty();
                    
                    if (!isAlreadyLinked) {
                        ContentDocumentLink docLink = new ContentDocumentLink();
                        docLink.LinkedEntityId = recordId;
                        docLink.ContentDocumentId = newDoc.Id;
                        docLink.Visibility = 'AllUsers';
                        docLink.ShareType = 'V';
                        insert docLink;
                    }
                } else {
                    return 'File Uploaded Successfully.';
                }
            }
            
            return 'File Uploaded Successfully.';
            
        } catch (Exception e) {
              ExceptionHandler.addLog(e,fileName,'customerfileupload',recordId);  /*Add Exception to error log*/
            System.debug('Error: ' + e.getMessage());
            return 'Error: ' + e.getMessage();
        }
    }
    
}