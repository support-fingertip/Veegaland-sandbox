@isTest
private class ReferFriend_MobileAPITest {

    @testSetup
    static void setupData() {
        // Create Customer
        Customer_Master__c customer = new Customer_Master__c(
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Email__c = 'testuser@example.com',
            Phone__c = '9999999999',
            isActive__c = true
        );
        insert customer;

        // Create Project
        Project__c project = new Project__c(
            Name = 'Veegaland Elanza',
           Project__c = 'Veegaland Elanza'
        );
        insert project;
    }

    @isTest
    static void testCreateLead_Success() {
        Customer_Master__c customer = [SELECT Name FROM Customer_Master__c LIMIT 1];
        Project__c project = [SELECT Project_Id__c FROM Project__c LIMIT 1];

        String jsonBody = JSON.serialize(new Map<String, Object>{
            'userid' => customer.Name,
            'interested_project' => project.Project_Id__c,
            'name' => 'Friend Name',
            'email' => 'friend@example.com',
            'phoneNumber' => '8888888888'
        });

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestUri = '/services/apexrest/ReferFriendAPI/';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        ReferFriend_MobileAPI.CreateLead();
        Test.stopTest();
    }

    @isTest
    static void testCreateLead_MissingFields() {
        String jsonBody = JSON.serialize(new Map<String, Object>{
            'userid' => '',
            'interested_project' => '',
            'name' => '',
            'email' => 'abc@example.com',
            'phoneNumber' => ''
        });

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestUri = '/services/apexrest/ReferFriendAPI/';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;

        RestContext.response = new RestResponse();

        Test.startTest();
        ReferFriend_MobileAPI.CreateLead();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        
    }

    @isTest
    static void testCreateLead_CustomerNotFound() {
        Project__c project = [SELECT Project_Id__c FROM Project__c LIMIT 1];

        String jsonBody = JSON.serialize(new Map<String, Object>{
            'userid' => 'InvalidUser',
            'interested_project' => project.Project_Id__c,
            'name' => 'Friend',
            'email' => 'friend@example.com',
            'phoneNumber' => '7777777777'
        });

        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestUri = '/services/apexrest/ReferFriendAPI/';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;

        RestContext.response = new RestResponse();

        Test.startTest();
        ReferFriend_MobileAPI.CreateLead();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
      
    }

    @isTest
    static void testCreateLead_ExceptionScenario() {
        // Simulate by passing a malformed JSON
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestUri = '/services/apexrest/ReferFriendAPI/';
        req.requestBody = Blob.valueOf('{"userid": "TestUser", bad_json}');
        RestContext.request = req;

        RestContext.response = new RestResponse();

        Test.startTest();
        ReferFriend_MobileAPI.CreateLead();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
      
    }
}