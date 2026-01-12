@isTest
public class CustomerFileUploadControllerTest {

    @isTest
    static void testUploadFile_NewFile() {
        
        
        
        
        // Creatin booking record
        Booking__c book = new Booking__c();
        insert book;
        
        // Set the URL parameters (simulate ?id=xxx&filename=abc)
    ApexPages.currentPage().getParameters().put('id', 'book.Id');
    ApexPages.currentPage().getParameters().put('filename', 'TestDocumentName');

    // Now call the constructor
    CustomerFileUploadController controller = new CustomerFileUploadController();

        // Simulate file data (base64 string)
        String fileData = EncodingUtil.base64Encode(Blob.valueOf('Dummy file content'));
        String fileName = 'AadharCard.pdf';
        String fileNaming = 'Aadhar Card - John';

        Test.startTest();
        String result = CustomerFileUploadController.uploadFile(fileNaming, fileName, fileData, book.Id);
        String result1 = CustomerFileUploadController.uploadFile(fileNaming, '', fileData, '');
        Test.stopTest();

       
        // Verify file linked
        List<ContentDocumentLink> links = [
            SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :book.Id
        ];
        
    }

    @isTest
    static void testUploadFile_ExistingFile() {
        // Step 1: Create a record
        Contact testContact = new Contact(LastName = 'File Holder');
        insert testContact;

        // Step 2: Upload an initial version
        ContentVersion version = new ContentVersion(
            Title = 'Passport Size Photo - John',
            PathOnClient = 'passport.jpg',
            VersionData = Blob.valueOf('Initial content'),
            IsMajorVersion = true
        );
        insert version;

        // Step 3: Get associated ContentDocumentId
        ContentVersion insertedVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :version.Id];
        String docId = insertedVersion.ContentDocumentId;

        // Step 4: Link to record
        insert new ContentDocumentLink(
            LinkedEntityId = testContact.Id,
            ContentDocumentId = docId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );

        // Step 5: Now call uploadFile() with same title
        String fileData = EncodingUtil.base64Encode(Blob.valueOf('New version content'));
        String fileNaming = 'Passport Size Photo - John';

        Test.startTest();
        String result = CustomerFileUploadController.uploadFile(fileNaming, 'passport_v2.jpg', fileData, testContact.Id);
        Test.stopTest();

        System.assert(result.contains('File Uploaded Successfully'), 'Expected success on update');
    }

    @isTest
    static void testUploadFile_NoRecordId() {
        String fileData = EncodingUtil.base64Encode(Blob.valueOf('test'));
        Test.startTest();
        String result = CustomerFileUploadController.uploadFile('TestTitle', 'Test.pdf', fileData, null);
        Test.stopTest();
        System.assert(result.contains('Error: No Record ID Provided!'), 'Should return error for null recordId');
    }
}