@isTest
public class LocationFilter_MobileAPI_Test {
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
      //  StartingPrice__c = '500000',
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
    
    @IsTest
    static void testValidRequestWithAllFilters() {
        Customer_Master__c customer = [SELECT Name FROM Customer_Master__c LIMIT 1];
        Project__c project = [SELECT Project_Id__c FROM Project__c LIMIT 1];
        
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        LocationFilter_MobileAPI.AllProjectWrapper wrap = new LocationFilter_MobileAPI.AllProjectWrapper();
        wrap.userId = customer.Name;
        wrap.search = 'Test';
        wrap.startPrice = '400000';
        wrap.endPrice = '600000';
        wrap.startAreaRange = '1000';
        wrap.endAreaRange = '2000';
        wrap.bedroomCount = '2 BHK';
        wrap.parkingCount = '2';
        wrap.pageSize = 0;
        wrap.city = 'TestCity';
        
        req.requestBody = Blob.valueOf(JSON.serialize(wrap));
        
        LocationFilter_MobileAPI.getAllprojectDetail();
      
        Test.stopTest();
    }
    
    @IsTest
    static void testMissingUserId() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        LocationFilter_MobileAPI.AllProjectWrapper wrap = new LocationFilter_MobileAPI.AllProjectWrapper();
        wrap.userId = null; // blank userId
        
        req.requestBody = Blob.valueOf(JSON.serialize(wrap));
        
        LocationFilter_MobileAPI.getAllprojectDetail();
       
        Test.stopTest();
    }
    
    @IsTest
    static void testUserNotFound() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        LocationFilter_MobileAPI.AllProjectWrapper wrap = new LocationFilter_MobileAPI.AllProjectWrapper();
        wrap.userId = 'NON_EXISTING';
        
        req.requestBody = Blob.valueOf(JSON.serialize(wrap));
        
        LocationFilter_MobileAPI.getAllprojectDetail();
       
        Test.stopTest();
    }
    
    @IsTest
    static void testInvalidFilterValues() {
        Customer_Master__c customer = [SELECT Name FROM Customer_Master__c LIMIT 1];
        Project__c project = [SELECT Project_Id__c FROM Project__c LIMIT 1];
        
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        LocationFilter_MobileAPI.AllProjectWrapper wrap = new LocationFilter_MobileAPI.AllProjectWrapper();
        wrap.userId = customer.Name;
        wrap.startPrice = 'abc'; // invalid decimal
        wrap.endPrice = 'xyz'; // invalid decimal
        wrap.startAreaRange = 'qq'; // invalid decimal
        wrap.endAreaRange = 'ww'; // invalid decimal
        wrap.parkingCount = 'notANumber'; // invalid integer
        wrap.pageSize = 0;
        
        req.requestBody = Blob.valueOf(JSON.serialize(wrap));
        
        LocationFilter_MobileAPI.getAllprojectDetail();
      
        Test.stopTest();
    }
    
    @IsTest
    static void testExceptionScenario() {
        // Force exception by passing invalid JSON
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        req.requestBody = Blob.valueOf('{"invalidJson":');
        
        LocationFilter_MobileAPI.getAllprojectDetail();
       
        Test.stopTest();
    }
    
}