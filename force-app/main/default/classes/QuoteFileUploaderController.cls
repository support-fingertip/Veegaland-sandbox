public with sharing class QuoteFileUploaderController {

    @AuraEnabled
    public static Map<String, List<ContentDocument>> getUploadedFiles(Id recordId) {
        Map<String, List<ContentDocument>> filesMap = new Map<String, List<ContentDocument>>();
        filesMap.put('Aadhar', new List<ContentDocument>());
        filesMap.put('PAN', new List<ContentDocument>());
        filesMap.put('Passport', new List<ContentDocument>());
        filesMap.put('Photo', new List<ContentDocument>());

        // Step 1: Query ContentDocumentLink where LinkedEntityId is the given recordId
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :recordId
        ];

        // Step 2: Create a Set to store the ContentDocumentIds from the ContentDocumentLink results
        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink link : links) {
            contentDocumentIds.add(link.ContentDocumentId);
        }

        // If we have content document ids, fetch the corresponding ContentDocument records
        if (!contentDocumentIds.isEmpty()) {
            List<ContentDocument> documents = [
                SELECT Id, Title 
                FROM ContentDocument 
                WHERE Id IN :contentDocumentIds
            ];

            // Step 3: Categorize documents based on title
            for (ContentDocument doc : documents) {
                if (doc.Title.contains('Aadhar')) {
                    filesMap.get('Aadhar').add(doc);
                } else if (doc.Title.contains('PAN')) {
                    filesMap.get('PAN').add(doc);
                } else if (doc.Title.contains('Passport')) {
                    filesMap.get('Passport').add(doc);
                } else if (doc.Title.contains('Photo')) {
                    filesMap.get('Photo').add(doc);
                }
            }
        }

        // Return the map of files categorized by type
        return filesMap;
    }

    @AuraEnabled
    public static String uploadFile(String recordId, String base64Data, String fileName) {
        try {
            // Step 1: Rename the file based on its type
            String newFileName = fileName;
            if (fileName.contains('Aadhar')) {
                newFileName = 'Primary Applicant Aadhar';
            } else if (fileName.contains('PAN')) {
                newFileName = 'Primary Applicant PAN';
            } else if (fileName.contains('Passport')) {
                newFileName = 'Primary Applicant Passport';
            } else if (fileName.contains('Photo')) {
                newFileName = 'Primary Applicant Passport Size Photo';
            }

            // Step 2: Create and insert a new ContentVersion record
            ContentVersion cv = new ContentVersion();
            cv.VersionData = EncodingUtil.base64Decode(base64Data);
            cv.Title = newFileName;
            cv.PathOnClient = '/' + newFileName;
            cv.FirstPublishLocationId = recordId;
            insert cv;

            return 'Success';
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
}