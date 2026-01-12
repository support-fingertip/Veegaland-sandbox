@isTest
private class ProjectDetail_MobileAPITest {
@testSetup
static void setup() {
    // 1) Create Customer
    Customer_Master__c customer = new Customer_Master__c(
        First_Name__c = 'Test',
        Last_Name__c = 'User',
        Email__c = 'test@example.com',
        Password__c = 'password',
        Phone__c = '9999999999',
        isActive__c = true
    );
    insert customer;

    // 2) Create Amenity
    Amenity__c amenity = new Amenity__c(Name = 'Gym');
    insert amenity;

    // 3) Create Project
    Project__c project = new Project__c(
        Name = 'Test Project',
        Active__c = true,
        Display_in_Home__c = true,
        Display_in_Banner__c = true,
        BHK_Type__c = '2;3;5',
        Area_Name__c = 'Area 51',
       // StartingPrice__c = '500000',
        Locality_Name__c = 'Sector 9',
        WorkProgress__c = 'Completed',
        Project_Description__c = 'Luxury apartments'
    );
    insert project;

    // Link Amenity to Project
    amenity.Project__c = project.Id;
    update amenity;

    // 4) Create two ContentVersions (project-detail and sub-image)
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

    // 5) Link both to the project
    List<ContentVersion> cvs = [
        SELECT Id, ContentDocumentId FROM ContentVersion
        WHERE Id IN :new List<Id>{cv1.Id, cv2.Id}
    ];
    for (ContentVersion cv : cvs) {
        insert new ContentDocumentLink(
            LinkedEntityId    = project.Id,
            ContentDocumentId = cv.ContentDocumentId,
            ShareType         = 'V',
            Visibility        = 'AllUsers'
        );
    }

    // 6) Link only the first amenity to the first doc
    insert new ContentDocumentLink(
        LinkedEntityId    = amenity.Id,
        ContentDocumentId = cvs[0].ContentDocumentId,
        ShareType         = 'V',
        Visibility        = 'AllUsers'
    );

    // Distribution logic intentionally skipped (assumed handled in main class logic)
}

    @isTest
    static void testValidRequest() {
        Customer_Master__c customer = [SELECT Name FROM Customer_Master__c LIMIT 1];
        Project__c project = [SELECT Project_Id__c FROM Project__c LIMIT 1];

        Map<String, String> reqMap = new Map<String, String>{
            'userId' => customer.Name,
            'projectId' => project.Project_Id__c
        };
        String jsonInput = JSON.serialize(reqMap);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonInput);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/ProjectDetailAPI/';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ProjectDetail_MobileAPI.getProjectDetail();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        String body = RestContext.response.responseBody.toString();
        System.assert(body.contains('"success":true'));
        System.assert(body.contains('amenities'));
    }

    @isTest
    static void testBlankUserIdOrProjectId() {
        Map<String, String> reqMap = new Map<String, String>{
            'userId' => '',
            'projectId' => ''
        };
        String jsonInput = JSON.serialize(reqMap);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonInput);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/ProjectDetailAPI/';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ProjectDetail_MobileAPI.getProjectDetail();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('UserId or ProjectId Should not be Null.'));
    }

    @isTest
    static void testInvalidUser() {
        Project__c project = [SELECT Project_Id__c FROM Project__c LIMIT 1];

        Map<String, String> reqMap = new Map<String, String>{
            'userId' => 'INVALID_USER',
            'projectId' => project.Project_Id__c
        };
        String jsonInput = JSON.serialize(reqMap);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonInput);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/ProjectDetailAPI/';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ProjectDetail_MobileAPI.getProjectDetail();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('Customer Not Found'));
    }

    @isTest
    static void testInvalidJson() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{badJson:::}');
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/ProjectDetailAPI/';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ProjectDetail_MobileAPI.getProjectDetail();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('Error:'));
    }
}