public without sharing class FileUploadControlller {


    // Fetch files attached to a record
    @AuraEnabled
    public static List<ContentDocument> getFiles(Id recordId) {
        List<ContentDocument> files = new List<ContentDocument>();
        List<ContentDocumentLink> links = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
        
        if (!links.isEmpty()) {
            Set<Id> fileIds = new Set<Id>();
            for (ContentDocumentLink link : links) {
                fileIds.add(link.ContentDocumentId);
            }

            files = [SELECT Id, Title,FileExtension FROM ContentDocument WHERE Id IN :fileIds];
        }
        
        return files;
    }

    // Rename files
    @AuraEnabled
    public static void renameFileApex(List<Id> fileIds) {
        List<ContentDocument> files = [SELECT Id, Title FROM ContentDocument WHERE Id IN :fileIds];
        for (ContentDocument file : files) {
            file.Title = 'Sale Agreement';
        }
        update files;
    }

    // Delete file by ID
    @AuraEnabled
     public static void deleteFileApex(Id fileId) {
    try {
        // First delete the ContentDocument
        List<ContentDocument> files = [SELECT Id FROM ContentDocument WHERE Id = :fileId ];
        if (!files.isEmpty()) {
            delete files; // This will delete the file and its links automatically
        }
    } catch (Exception e) {
        throw new AuraHandledException('Error deleting file: ' + e.getMessage());
    }
}
 }