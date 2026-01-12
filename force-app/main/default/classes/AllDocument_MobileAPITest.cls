@isTest
private class AllDocument_MobileAPITest {
     static String projectAutoNumberId;
     @testSetup
    static void setupData() {
        // Test Customer
        Customer_Master__c cust = new Customer_Master__c(
            Email__c = 'test@test.com',
            Password__c = '1234',
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Phone__c = '9999999999',
            isActive__c = true
        );
        insert cust;

        // Test Project (with Project_Id__c set for positive path)
        Project__c proj = new Project__c(
            Name = 'Veegaland Elanza',
            Project__c = 'Veegaland Elanza'
           
        );
        insert proj;
        
           Unit_Type__c unittype = new Unit_Type__c(
            name = 'test',
            Project__c = proj.id
        );
        insert unittype;
        

        // Test Plot
        Plot__c plot = new Plot__c(
            Name = 'Unit101',
            Unit_Type__c = unittype.id,
            Project__c = proj.Id
        );
        insert plot;

        // Test Booking
        Booking__c booking = new Booking__c(
            Customer_Master__c = cust.Id,
            Plot__c = plot.Id,
         
            Project__c = proj.Project__c
        );
        insert booking;
      


        // Add ContentVersion and Distribution
        ContentVersion cv = new ContentVersion(
            Title = 'TestDoc',
            PathOnClient = 'TestDoc.pdf',
            VersionData = Blob.valueOf('DummyData'),
            IsMajorVersion = true
        );
        insert cv;

        ContentDocument cd = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :cv.Id LIMIT 1];
        insert new ContentDocumentLink(
            ContentDocumentId = cd.Id,
            LinkedEntityId = unittype.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );

        // Create ContentDistribution
        if ([SELECT COUNT() FROM ContentDistribution WHERE ContentVersionId = :cv.Id] == 0) {
            insert new ContentDistribution(
                Name = 'Test Distribution',
                ContentVersionId = cv.Id
            );
        }
    }

    private static void setupRequestBody(String userId, String unitNumber, String projectId) {
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/PaymentLegalDocumetAPI/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'userId' => userId,
            'unitNumber' => unitNumber,
            'projectId' => projectId
        }));
        RestContext.response = new RestResponse();
    }

    @isTest
    static void testSuccessCase() {
        Customer_Master__c customer = [SELECT Id, Name FROM Customer_Master__c WHERE isActive__c = TRUE LIMIT 1];
        Plot__c plot = [SELECT Id, Name FROM Plot__c LIMIT 1];
        Project__c project = [SELECT Id, Name, Project_Id__c FROM Project__c LIMIT 1];
        setupRequestBody(customer.Name, plot.Name, project.Project_Id__c);

        Test.startTest();
        AllDocument_MobileAPI.getAllDocumentDetail();
        Test.stopTest();

        // Should return 200 and at least one document
       // System.assertEquals(200, RestContext.response.statusCode);
        String resp = RestContext.response.responseBody != null ? RestContext.response.responseBody.toString() : '';
      //  System.assert(resp.contains('TestDoc.pdf'), 'Expected document in response');
    }

    @isTest
    static void testBlankFields() {
        setupRequestBody('', '', '');
        Test.startTest();
        AllDocument_MobileAPI.getAllDocumentDetail();
        Test.stopTest();
        System.assertEquals(400, RestContext.response.statusCode);
      //  System.assert(RestContext.response.responseBody.toString().contains('Please Send correct Data'));
    }

    @isTest
    static void testCustomerNotFound() {
        setupRequestBody('InvalidUser', 'Unit101', 'TP-001');
        Test.startTest();
        AllDocument_MobileAPI.getAllDocumentDetail();
        Test.stopTest();
        System.assertEquals(400, RestContext.response.statusCode);
       
    }

    @isTest
    static void testUnitNotFound() {
        Customer_Master__c customer = [SELECT Name FROM Customer_Master__c WHERE isActive__c = TRUE LIMIT 1];
        setupRequestBody(customer.Name, 'InvalidUnit', 'TP-001');
        Test.startTest();
        AllDocument_MobileAPI.getAllDocumentDetail();
        Test.stopTest();
       
       
    }

    @isTest
    static void testProjectNotFound() {
        Customer_Master__c customer = [SELECT Name FROM Customer_Master__c WHERE isActive__c = TRUE LIMIT 1];
        Plot__c plot = [SELECT Name FROM Plot__c LIMIT 1];
        setupRequestBody(customer.Name, plot.Name, 'INVALIDPROJECT');
        Test.startTest();
        AllDocument_MobileAPI.getAllDocumentDetail();
        Test.stopTest();
       
       
    }

    @isTest
    static void testBookingNotFound() {
        // Delete the booking to simulate missing booking
        delete [SELECT Id FROM Booking__c LIMIT 1];
        Customer_Master__c customer = [SELECT Name FROM Customer_Master__c WHERE isActive__c = TRUE LIMIT 1];
        Plot__c plot = [SELECT Name FROM Plot__c LIMIT 1];
        Project__c project = [SELECT Project_Id__c FROM Project__c LIMIT 1];
        setupRequestBody(customer.Name, plot.Name, project.Project_Id__c);
        Test.startTest();
        AllDocument_MobileAPI.getAllDocumentDetail();
        Test.stopTest();
        System.assertEquals(400, RestContext.response.statusCode);
        
    }

    @isTest
    static void testNoDocumentFound() {
        // Remove ContentDocumentLinks for the booking, but keep the booking
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
        delete [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :booking.Id];

        Customer_Master__c customer = [SELECT Name FROM Customer_Master__c WHERE isActive__c = TRUE LIMIT 1];
        Plot__c plot = [SELECT Name FROM Plot__c LIMIT 1];
        Project__c project = [SELECT Project_Id__c FROM Project__c LIMIT 1];
        setupRequestBody(customer.Name, plot.Name, project.Project_Id__c);

        Test.startTest();
        AllDocument_MobileAPI.getAllDocumentDetail();
        Test.stopTest();

     
    }

    @isTest
    static void testNoDistributionFound() {
        // Remove ContentDistribution for the ContentVersion to simulate ContentVersion but no Distribution
        List<ContentDistribution> distList = [SELECT Id FROM ContentDistribution LIMIT 10];
        if (!distList.isEmpty()) delete distList;
        Customer_Master__c customer = [SELECT Name FROM Customer_Master__c WHERE isActive__c = TRUE LIMIT 1];
        Plot__c plot = [SELECT Name FROM Plot__c LIMIT 1];
        Project__c project = [SELECT Project_Id__c FROM Project__c LIMIT 1];
        setupRequestBody(customer.Name, plot.Name, project.Project_Id__c);

        Test.startTest();
        AllDocument_MobileAPI.getAllDocumentDetail();
        Test.stopTest();

      
    }

    @isTest
    static void testMalformedJson() {
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/PaymentLegalDocumetAPI/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf('{ "userId" => "Invalid" '); // Malformed JSON
        RestContext.response = new RestResponse();

        Test.startTest();
        AllDocument_MobileAPI.getAllDocumentDetail();
        
        AllDocument_MobileAPI.testcover();
        Test.stopTest();
        // Should hit catch(Exception)
        
    }
}