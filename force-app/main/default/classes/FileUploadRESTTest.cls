@isTest
private class FileUploadRESTTest {
    
    @isTest
    static void testUploadFile_NewDocument() {
        // Step 1: Create a dummy record to associate file with
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Step 2: Prepare dummy base64 data
        String sampleData = 'Test content for the file';
        Blob fileBlob = Blob.valueOf(sampleData);
        String base64Data = EncodingUtil.base64Encode(fileBlob);

        // Step 3: Call the method
        Test.startTest();
        String response = FileUploadREST.uploadFile(
            'TestFileTitle',
            'testFile.txt',
            base64Data,
            acc.Id
        );
        Test.stopTest();

        // Step 4: Verify
    
        
        List<ContentVersion> uploadedVersions = [
            SELECT Id, Title, PathOnClient 
            FROM ContentVersion 
            WHERE Title = 'TestFileTitle'
        ];
        
    }
    
   @isTest
static void testUploadFile_ExistingDocument() {
    // Setup record
    Account acc = new Account(Name = 'Existing Account');
    insert acc;

    // Create initial file and auto-link to Account
    Blob initialBlob = Blob.valueOf('Original file content');
    ContentVersion initialVersion = new ContentVersion(
        Title = 'DuplicateFile',
        PathOnClient = 'file1.txt',
        VersionData = initialBlob,
        FirstPublishLocationId = acc.Id, // Automatically creates the link
        Origin = 'C'
    );
    insert initialVersion;

    ContentDocument existingDoc = [
        SELECT Id FROM ContentDocument 
        WHERE LatestPublishedVersionId = :initialVersion.Id
    ];

  
    String newData = 'Updated content';
    String base64New = EncodingUtil.base64Encode(Blob.valueOf(newData));

    Test.startTest();
    String response = FileUploadREST.uploadFile(
        'DuplicateFile',
        'file1.txt',
        base64New,
        acc.Id
    );
    Test.stopTest();

}

    @isTest
    static void testUploadFile_NoRecordId() {
        String dummyData = EncodingUtil.base64Encode(Blob.valueOf('test'));
        Test.startTest();
        String response = FileUploadREST.uploadFile('NoID', 'test.txt', dummyData, null);
        Test.stopTest();
       
    }
}