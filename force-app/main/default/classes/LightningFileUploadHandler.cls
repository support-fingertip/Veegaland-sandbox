public class LightningFileUploadHandler {
    
    // Method to get files associated with a record and separate them by document type
    @AuraEnabled  
    public static Map<String, List<ContentDocument>> getFiles(String recordId) { 
        System.debug('Fetching files for record: ' + recordId);
        
        // Query ContentDocumentLink to get the linked ContentDocumentId for the given recordId
        List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId 
                                             FROM ContentDocumentLink 
                                             WHERE LinkedEntityId = :recordId]; 
        
        // Create a set to store ContentDocumentIds
        Set<Id> documentIds = new Set<Id>(); 
        for(ContentDocumentLink cdl : cdlList){  
            documentIds.add(cdl.ContentDocumentId);  
        } 
        
        // Initialize map to store categorized documents
        Map<String, List<ContentDocument>> categorizedFiles = new Map<String, List<ContentDocument>>{
            'Aadhar' => new List<ContentDocument>(),
            'PAN' => new List<ContentDocument>(),
            'Passport' => new List<ContentDocument>(),
            'Photo' => new List<ContentDocument>()
        };

        // If there are document IDs, fetch the corresponding ContentDocuments
        if(!documentIds.isEmpty()) {
            List<ContentDocument> documents = [SELECT Id, Title, FileType FROM ContentDocument WHERE Id IN :documentIds];
            
            // Categorize documents based on title
            for (ContentDocument doc : documents) {
                if (doc.Title.contains('Aadhar')) {
                    categorizedFiles.get('Aadhar').add(doc);
                } else if (doc.Title.contains('PAN')) {
                    categorizedFiles.get('PAN').add(doc);
                } else if (doc.Title.contains('Passport')) {
                    categorizedFiles.get('Passport').add(doc);
                } else if (doc.Title.contains('Photo')) {
                    categorizedFiles.get('Photo').add(doc);
                }
            }
        }
        
        // Return the map of categorized files
        return categorizedFiles;
    }
    
    // Method to delete a file from ContentDocument
    @AuraEnabled  
    public static void deleteFile(String contentDocumentId) { 
        try {
            // Delete the ContentDocument record
            delete [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId]; 
        } catch (Exception e) {
            System.debug('Error while deleting file: ' + e.getMessage());
            throw new AuraHandledException('Error deleting the file: ' + e.getMessage());
        }
    }  
}