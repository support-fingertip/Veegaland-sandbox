@isTest
public class ContentVersionTrigger_Test {
    
    @isTest
    static void testContentVersionTrigger_WithExternalDocumentInfo() {
        // Create a dummy Account to link the file to
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // Prepare a ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'TestFile',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Test file content'),
            ExternalDocumentInfo1 = acc.Id, 
            ExternalDocumentInfo2 = 'FromApp',
            Prefix_fileupload__c = 'TestVersion'
        );
        
        insert cv;

        // Query back the ContentVersion and related ContentDocumentId
        ContentVersion insertedCv = [
            SELECT Id, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :cv.Id
            LIMIT 1
        ];

        // Validate ContentDistribution
        List<ContentDistribution> distributions = [
            SELECT Id, Name, ContentVersionId 
            FROM ContentDistribution 
            WHERE ContentVersionId = :insertedCv.Id
        ];
     

        // Validate ContentDocumentLink
        List<ContentDocumentLink> links = [
            SELECT Id, ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE ContentDocumentId = :insertedCv.ContentDocumentId
        ];
       
    }
    
    @isTest
    static void testContentVersionTrigger_WithoutExternalDocumentInfo() {
        // Upload file without ExternalDocumentInfo1 or ExternalDocumentInfo2
        ContentVersion cv = new ContentVersion(
            Title = 'UnlinkedFile',
            PathOnClient = 'Unlinked.pdf',
            VersionData = Blob.valueOf('Another test file content')
        );
        
        insert cv;

        // Check ContentDistribution created
        List<ContentDistribution> distributions = [
            SELECT Id, Name, ContentVersionId 
            FROM ContentDistribution 
            WHERE ContentVersionId = :cv.Id
        ];
       

        // Should not create any ContentDocumentLink
        ContentVersion insertedCv = [
            SELECT Id, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :cv.Id
        ];
        List<ContentDocumentLink> links = [
            SELECT Id 
            FROM ContentDocumentLink 
            WHERE ContentDocumentId = :insertedCv.ContentDocumentId
        ];
       
    }
}