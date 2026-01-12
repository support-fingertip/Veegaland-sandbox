@isTest
private class AllProject_MobileAPITest {
    
    @testSetup
    static void setupData() {
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
            Used_in_Mobile_App__c=true,
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
        
    }
    
    static testMethod void testValidRequest_AllFields() {
        Customer_Master__c customer = [SELECT Name FROM Customer_Master__c LIMIT 1];
        
        Map<String, Object> requestBody = new Map<String, Object>{
            'userId' => customer.Name,
                'search' => 'Test',
                'startPrice' => '400000',
                'endPrice' => '600000',
                'startAreaRange' => '1000',
                'endAreaRange' => '1300',
                'bedroomCount' => '1 BHK',
                'parkingCount' => '2',
                'pageSize' => 0,
                'city' => 'Pune'
                };
                    
                    RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/AllProjectAPI/';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        AllProject_MobileAPI.getAllprojectDetail();
        Test.stopTest();
        
        String body = RestContext.response.responseBody.toString();
    }
    
    static testMethod void testBlankUserId() {
        Map<String, Object> requestBody = new Map<String, Object>{
            'userId' => ''
                };
                    
                    RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/AllProjectAPI/';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        AllProject_MobileAPI.getAllprojectDetail();
        Test.stopTest();
        
        System.assertEquals(400, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('correct userId'));
    }
    
    static testMethod void testInvalidUserId() {
        Map<String, Object> requestBody = new Map<String, Object>{
            'userId' => 'invalidUserXYZ'
                };
                    
                    RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/AllProjectAPI/';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        AllProject_MobileAPI.getAllprojectDetail();
        Test.stopTest();
        
        System.assertEquals(400, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('User Not Found'));
    }
    
    static testMethod void testInvalidJson() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{ badJson::: }');
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/AllProjectAPI/';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        AllProject_MobileAPI.getAllprojectDetail();
        Test.stopTest();
        
        System.assertEquals(400, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('Error'));
    }
    
    static testMethod void testNoFilters() {
        Customer_Master__c customer = [SELECT Name FROM Customer_Master__c LIMIT 1];
        
        Map<String, Object> requestBody = new Map<String, Object>{
            'userId' => customer.Name,
                'pageSize' => 0
                };
                    
                    RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/AllProjectAPI/';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        AllProject_MobileAPI.getAllprojectDetail();
        Test.stopTest();
        
    }
}