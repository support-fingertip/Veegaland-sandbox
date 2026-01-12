@isTest
private class DownloadAttachmentRESTTest {

    @isTest
    static void testDoGet_success() {
        // Create test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Attachment att = new Attachment(
            ParentId = acc.Id,
            Name = 'testfile.txt',
            Body = Blob.valueOf('Sample file content'),
            ContentType = 'text/plain'
        );
        insert att;

        // Simulate REST request
        String fakeUrl = '/services/apexrest/downloadAttachment/' + att.Id;

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestUri = fakeUrl;
        RestContext.request.httpMethod = 'GET';

        Test.startTest();
        DownloadAttachmentREST.doGet();
        Test.stopTest();

        
    }

    @isTest
    static void testDoGet_invalidId() {
        // Simulate invalid REST request
        String fakeUrl = '/services/apexrest/downloadAttachment/InvalidId';

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestUri = fakeUrl;
        RestContext.request.httpMethod = 'GET';

        Test.startTest();
        DownloadAttachmentREST.doGet();
        Test.stopTest();

       
    }
}