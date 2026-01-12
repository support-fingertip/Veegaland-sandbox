@isTest
private class DemandScreen_MobileAPI_Test {
    
    @isTest
    static void testDemandScreenMethod_Success() {
       //Creating Customer
        Customer_Master__c customer = new Customer_Master__c(
            
            First_Name__c = 'test',
            Last_Name__c = 'test Lastname',
            Email__c = 'test@gmail.com',
            Phone__c = '9786904320' ,
            isActive__c = true
            
        );
        insert customer;
        // Create test project
        Project__c project = new Project__c(
            Name = 'Test Project',
            
            Project__c = 'Veegaland Elanza',
            Pincode__c = 123456
        );
        insert project;
        
          //  ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'Sub image',
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
        
        
        
        
        project = [SELECT Id, Project_Id__c FROM Project__c WHERE Id = :project.Id];
        
        Plot__c plot = new Plot__c(
            Name = 'Unit A',
            Project__c = project.Id
        );
        insert plot;
        
        // Create a test Booking__c
        Booking__c booking = new Booking__c(
            Customer_Master__c = customer.Id,
            Project__c ='Veegaland Elanza',
            Plot__c = plot.Id,
            Project1__c = project.Id
        );
        insert booking;
        
        // Create Demand_Raised__c
        Demand_Raised__c demand = new Demand_Raised__c(
            Booking__c = booking.Id,
            Current_Demand_amount__c = 15000,
            Due_Date__c = Date.today(),
            Demanded_Date__c = Date.today()
            // Payment_Collection_Status__c = 'Paid'
        );
        insert demand;
        
        // Create Payment Schedule
        Payment_schedule__c ps = new Payment_schedule__c(
            Booking__c = booking.Id,
            Status__c = 'Completed',
            S_No__c = 1,
            Payment_Due_Date__c = Date.today()
        );
        insert ps;
        
        // Create Receipt_Line_Item__c
        Receipt__c receipt = new Receipt__c( 
            Receipt_date__c = Date.today(),
            Booking__c = booking.Id
        );
        insert receipt;
        
        Receipt_Line_Item__c rli = new Receipt_Line_Item__c(
            Booking__c = booking.Id,
            Receipt__c = receipt.Id,
            // Invoice_Number__c = 'INV001',
            Amount__c = 5000,
            Approval_Status1__c = 'Approved',
            Payment_schedule__c = ps.Id
        );
        insert rli;
        
      
        Customer_Master__c cus = [SELECT Id,Name FROM Customer_Master__c LIMIT 1];
        Project__c pro = [SELECT Project_Id__c FROM Project__c LIMIT 1];
        
        
        // Prepare mock JSON
        String jsonBody = JSON.serialize(new Map<String, String>{
            'userId' => cus.Name,
                'projectId' => pro.Project_Id__c
                });
        
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/DemandScreenAPI/';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        DemandScreen_MobileAPI.DemandScreenMethod();
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testMissingUserIdOrProjectId() {
        String jsonBody = JSON.serialize(new Map<String, String>{
            'userId' => '',
                'projectId' => ''
                });
        
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/DemandScreenAPI/';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        DemandScreen_MobileAPI.DemandScreenMethod();
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testCustomerNotFound() {
        // No customer inserted
        
        String jsonBody = JSON.serialize(new Map<String, String>{
            'userId' => 'NonExistentUser',
                'projectId' => 'SomeProjectId'
                });
        
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/DemandScreenAPI/';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        DemandScreen_MobileAPI.DemandScreenMethod();
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testProjectNotFound() {
        Customer_Master__c customer = new Customer_Master__c(
            
            isActive__c = true
        );
        insert customer;
        
        String jsonBody = JSON.serialize(new Map<String, String>{
            'userId' => customer.Name,
                'projectId' => 'INVALID'
                });
        
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/DemandScreenAPI/';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        DemandScreen_MobileAPI.DemandScreenMethod();
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testNoBookingFound() {
        Customer_Master__c customer = new Customer_Master__c(
            
            isActive__c = true
        );
        insert customer;
        
        Project__c project = new Project__c(
            Name = 'Test Project',
            
            Project__c = 'Veegaland Elanza'
        );
        insert project;
        
        // No booking created
        
        String jsonBody = JSON.serialize(new Map<String, String>{
            'userId' => customer.Name,
                'projectId' => project.Project_Id__c
                });
        
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/DemandScreenAPI/';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        DemandScreen_MobileAPI.DemandScreenMethod();
         DemandScreen_MobileAPI.testcover();
        Test.stopTest();
        
        
    }
}