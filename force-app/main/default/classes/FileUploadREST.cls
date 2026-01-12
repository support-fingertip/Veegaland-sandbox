public with sharing class FileUploadREST {
    public String bookingId { get; set; }
    //public String FileName { get; set; }
    
	public FileUploadREST() {
        bookingId = ApexPages.currentPage().getParameters().get('Id');
        //FileName = 'Allotment';
    }
    /*@RemoteAction
    public static String uploadFile(String bookingId, String fileName, String base64Data) {
        //try {
            system.debug('bookingId '+bookingId);
            
             //bookingId = ApexPages.currentPage().getParameters().get('id');
            //system.debug('Apex Page bookingId '+bookingId);
            // Decode the base64 content
            Blob fileBody = EncodingUtil.base64Decode(base64Data);

            // Create ContentVersion (represents the actual file)
            ContentVersion cv = new ContentVersion();
            cv.Title = fileName;
            cv.PathOnClient = fileName;
            cv.VersionData = fileBody;
            insert cv;
			
        	system.debug('cv '+cv.Id);
            // Fetch the ContentDocumentId
            ContentVersion insertedCV = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
			system.debug('bookingId '+bookingId);
            // Link file to Booking__c
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = insertedCV.ContentDocumentId;
            cdl.LinkedEntityId = bookingId;
            cdl.ShareType = 'V'; // Viewer access
            cdl.Visibility = 'AllUsers';
            insert cdl;

            return 'Success';*/
        /*} catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }*/
    //}
    @RemoteAction
    public static String uploadFile(String fileNaming,String fileName, String fileData, String recordId) {
        try {
            if (String.isEmpty(recordId)) {
                return 'Error: No Record ID Provided!';
            }
            system.debug('fileNaming '+fileNaming+'fileName '+fileName+'fileData '+fileData+'recordId '+recordId);
            // Get all linked ContentDocumentIds for the record
            List<Id> contentDocIds = new List<Id>();
            List<ContentDocumentLink> existingLinks = [
                SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId
            ];
            
            system.debug('existingLinks '+existingLinks);
            for (ContentDocumentLink link : existingLinks) {
                contentDocIds.add(link.ContentDocumentId);
            }
            
            ContentDocument existingDoc = null;
            if (!contentDocIds.isEmpty()) {
                // Query all ContentDocuments at once
                List<ContentDocument> contentDocs = [
                    SELECT Id, Title FROM ContentDocument WHERE Id IN :contentDocIds
                ];
                system.debug('contentDocs '+contentDocs);
                
                for (ContentDocument doc : contentDocs) {
                    if (doc.Title == fileNaming) {
                        existingDoc = doc;
                        break;
                    }
                }
            }
            
            ContentVersion fileVersion = new ContentVersion();
            fileVersion.Title = fileNaming;
            fileVersion.PathOnClient = fileName;
            fileVersion.Origin='C';
            fileVersion.VersionData = EncodingUtil.base64Decode(fileData);
            
            if (existingDoc != null) {
                // Create a new version of the existing document
                fileVersion.ContentDocumentId = existingDoc.Id;
            } else {
                // First-time upload, create a new document
                fileVersion.FirstPublishLocationId = recordId;
            }
            
            insert fileVersion;
            
            system.debug('fileVersion '+fileVersion);
            
            if (existingDoc == null) {
                // If it's a new document, link it to the record
                ContentDocument contentDoc = [
                    SELECT Id FROM ContentDocument 
                    WHERE LatestPublishedVersionId = :fileVersion.Id 
                    LIMIT 1
                ];
                
                system.debug('contentDoc '+contentDoc);
                ContentDocumentLink docLink = new ContentDocumentLink();
                docLink.LinkedEntityId = recordId;
                docLink.ContentDocumentId = contentDoc.Id;
                docLink.Visibility = 'AllUsers';
                docLink.ShareType = 'V'; // Viewer access
                
                insert docLink;
                system.debug('docLink '+docLink);
            }
            
            return 'File Uploaded Successfully: ' + (existingDoc != null ? existingDoc.Id : fileVersion.Id);
            
        } catch (Exception e) {
            system.debug('Error'+ e.getMessage());
            return 'Error: ' + e.getMessage();
        }
    }

}