@isTest
private class Home_MobileAPITest {
 
    @testSetup
    static void setupData() {
        // 1) Create Customer
        Customer_Master__c customer = new Customer_Master__c(
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Email__c = 'test@example.com',
            Password__c = 'password',
            Phone__c = '1234567890',
            isActive__c = true
        );
        insert customer;
        
        // 2) Create Home record
        Home__c home = new Home__c(
            Awards__c = 5,
            Cities__c = 3,
            Complete_Projects__c = 10,
            HappyCustomers__c = 100
        );
        insert home;
        
        // 3) Create Project
        Project__c project = new Project__c(
            Active__c = true,
            Display_in_Home__c = true,
            Display_in_Banner__c = true
        );
        insert project;

        // 4) Create Amenity to link later
        Amenity__c withImg = new Amenity__c(
            Name = 'Sample Amenity',
            Project__c = project.Id
        );
        insert withImg;

        // 5) Create two ContentVersions (project-detail and sub-image)
        ContentVersion cv1 = new ContentVersion(
            Title         = 'Project detail page image',
            PathOnClient  = 'proj1.jpg',
            VersionData   = Blob.valueOf('x'),
            IsMajorVersion= true
        );
        ContentVersion cv2 = new ContentVersion(
            Title         = 'Sub image',
            PathOnClient  = 'sub1.jpg',
            VersionData   = Blob.valueOf('x'),
            IsMajorVersion= true
        );
        insert new List<ContentVersion>{ cv1, cv2 };

        // 6) Get ContentDocumentId from inserted versions
        List<ContentVersion> cvs = [
            SELECT Id, ContentDocumentId FROM ContentVersion
            WHERE Id IN :new List<Id>{cv1.Id, cv2.Id}
        ];

        // 7) Link both documents to the project
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        for (ContentVersion cv : cvs) {
            links.add(new ContentDocumentLink(
                LinkedEntityId    = project.Id,
                ContentDocumentId = cv.ContentDocumentId,
                ShareType         = 'V',
                Visibility        = 'AllUsers'
            ));
        }

        // 8) Link the first document to the amenity record
        links.add(new ContentDocumentLink(
            LinkedEntityId    = withImg.Id,
            ContentDocumentId = cvs[0].ContentDocumentId,
            ShareType         = 'V',
            Visibility        = 'AllUsers'
        ));
        insert links;
    }

    static testMethod void testValidRequest() {
        Customer_Master__c customer = [SELECT Name FROM Customer_Master__c LIMIT 1];

        String jsonBody = JSON.serialize(new Map<String, String>{
            'userId' => customer.Name
        });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/HomeAPI/';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Home_MobileAPI.getHomeDetail();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        String resp = RestContext.response.responseBody.toString();
        System.assert(resp.contains('success'));
    }

    static testMethod void testBlankUserId() {
        String jsonBody = JSON.serialize(new Map<String, String>{
            'userId' => ''
        });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/HomeAPI/';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Home_MobileAPI.getHomeDetail();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('Please Send correct userId'));
    }

    static testMethod void testInvalidUserId() {
        String jsonBody = JSON.serialize(new Map<String, String>{
            'userId' => 'NonExistentUser123'
        });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/HomeAPI/';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Home_MobileAPI.getHomeDetail();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('User Not Found in System'));
    }

    static testMethod void testInvalidJsonRequest() {
        String jsonBody = '{badJson:::}'; // malformed JSON

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/HomeAPI/';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Home_MobileAPI.getHomeDetail();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('Login failed'));
    }
}