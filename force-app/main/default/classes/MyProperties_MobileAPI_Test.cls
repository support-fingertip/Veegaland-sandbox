@isTest
private class MyProperties_MobileAPI_Test {

    @isTest
    static void testGetMyPropertiesDetail() {

        // Create a test Customer_Master__c
        Customer_Master__c customer = new Customer_Master__c(
          
            Email__c = 'test@example.com',
            Password__c = 'test123',
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Phone__c = '9999999999',
            isActive__c = true
        );
        insert customer;

        // Create test project
        Project__c project = new Project__c(
            Name = 'Test Project',
   
    StartingPrice__c = 5000,
    Saleable_Area__c = '43545',
    BHK_Type__c = '3',
    Maximum_No_of_Parking__c  = 5,
    Pincode__c = 123456
        );
        insert project;
        
         
         //  ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'Project list view',
            PathOnClient = 'ProjectDetailPageImage.pdf',
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
        

        // Create a test Plot__c
        Plot__c plot = new Plot__c(
            Name = 'Unit 101',
            BHK_Type__c = '2 BHK',
            No_of_Indivisual_Car_Parking__c = 1,
            Built_up_area__c = 1000,
            Project__c = project.Id
        );
        insert plot;

        // Create a test Booking__c
        Booking__c booking = new Booking__c(
            Customer_Master__c = customer.Id,
            Project__c ='Veegaland Elanza',
            Plot__c = plot.Id
        );
        insert booking;
        
         Customer_Master__c cus = [SELECT Id,Name FROM Customer_Master__c LIMIT 1];
        Project__c pro = [SELECT Project_Id__c FROM Project__c LIMIT 1];

        // Create mock REST request body
        MyProperties_MobileAPI.MyPropertiesWrapper reqBody = new MyProperties_MobileAPI.MyPropertiesWrapper();
        reqBody.userId = cus.Name;
        reqBody.pageSize = 0;
        reqBody.search = 'Test Project';
        reqBody.startPrice = '5000';
        reqBody.endPrice = '7000';
        reqBody.startAreaRange = '1232';
        reqBody.endAreaRange = '43545';
        reqBody.bedroomCount = '3';
        reqBody.parkingCount = '5';
        
        String jsonInput = JSON.serialize(reqBody);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/MyPropertiesAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonInput);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        MyProperties_MobileAPI.getMyPropertiesDetail();
        Test.stopTest();

       
    }

    @isTest
    static void testGetMyPropertiesDetailInvalidUser() {
        MyProperties_MobileAPI.MyPropertiesWrapper reqBody = new MyProperties_MobileAPI.MyPropertiesWrapper();
        reqBody.userId = 'NonExistingUser';
        reqBody.pageSize = 0;

        String jsonInput = JSON.serialize(reqBody);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/MyPropertiesAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonInput);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        MyProperties_MobileAPI.getMyPropertiesDetail();
        Test.stopTest();

      
    }

    @isTest
    static void testGetMyPropertiesDetailBlankUser() {
        MyProperties_MobileAPI.MyPropertiesWrapper reqBody = new MyProperties_MobileAPI.MyPropertiesWrapper();
        reqBody.userId = null;
        reqBody.pageSize = 10;

        String jsonInput = JSON.serialize(reqBody);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/MyPropertiesAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonInput);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        MyProperties_MobileAPI.getMyPropertiesDetail();
        Test.stopTest();

      
    }
    
}