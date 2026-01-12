@isTest
private class TestMobileAPIClassTest {

    @isTest
    static void testDoPostWithValidData() {
        
        Project__c project = new Project__c(Name = 'Test Project');
        insert project;

        //  ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'TestFile',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Test content')
        );
        insert cv;

        
        ContentVersion insertedCV = [
            SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id
        ];

        // Link ContentDocument to Project
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = insertedCV.ContentDocumentId,
            LinkedEntityId = project.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;

      
        List<ContentDistribution> existingDists = [
            SELECT Id FROM ContentDistribution WHERE ContentVersionId = :insertedCV.Id
        ];

        if (existingDists.isEmpty()) {
            
            ContentDistribution dist = new ContentDistribution(
                Name = 'Test Dist',
                ContentVersionId = insertedCV.Id
            );
            insert dist;
        }

       
        TestMobileAPIClass.FileRequest reqBody = new TestMobileAPIClass.FileRequest();
        reqBody.userId = UserInfo.getUserId();
        reqBody.isProjectDocument = project.Name;

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/getProjectAttachmentLinks/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(reqBody));
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        List<TestMobileAPIClass.FileResponse> result = TestMobileAPIClass.doPost();
        Test.stopTest();

    }
}