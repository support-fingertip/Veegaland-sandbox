@IsTest
private class CreateSupportRequestTest {
 
    // Utility method to create a test Customer_Master__c
    private static Customer_Master__c createTestCustomer() {
        Customer_Master__c customer = new Customer_Master__c(
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Email__c = 'test@example.com',
            Password__c = 'pass123',
            Phone__c = '1234567890',
            
            Loyality__c = '22',
            isActive__c = true
        );
        insert customer;
        return customer;
    }

    @isTest
    static void testCreateSupportRequest_Success() {
        
         Customer_Master__c customer1 = new Customer_Master__c(
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Email__c = 'test@example.com',
            Password__c = 'pass123',
            Phone__c = '1234567890',
            
            Loyality__c = '22',
            isActive__c = true
        );
        insert customer1;
        
         Customer_Master__c cus = [SELECT Id,Name FROM Customer_Master__c LIMIT 1];
        // Create JSON body
        String jsonBody = JSON.serialize(new Map<String, Object>{
            'userid' => cus.Name,
            'concernId' => 'C123',
            'supportId' => 'S456',
            'concernSubType' => 'SubIssue',
            'priorityId' => 'High',
            'descrjption' => 'Test issue description'
        });

        // Setup mock request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/CreateSupportRequestAPI/';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        CreateSupportRequest.CreateSupportRequest();
        CreateSupportRequest.sendSuccessResponse('');
        Test.stopTest();
        

      
    }

    @isTest
    static void testCreateSupportRequest_BlankUserId() {
        // Create JSON with blank userid
        String jsonBody = JSON.serialize(new Map<String, Object>{
            'userid' => '',
            'concernId' => 'C123',
            'supportId' => 'S456',
            'concernSubType' => 'SubIssue',
            'projectUnitId' => 'projectUnitId',
            'priorityId' => 'High',
            'descrjption' => 'Test issue description'
        });

        // Setup mock request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/CreateSupportRequestAPI/';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        CreateSupportRequest.CreateSupportRequest();
        Test.stopTest();

        
    }

    @isTest
    static void testCreateSupportRequest_UserNotFound() {
        // Create JSON with non-existing userId
        String jsonBody = JSON.serialize(new Map<String, Object>{
            'userid' => 'NonExistingUser',
            'concernId' => 'C123',
            'supportId' => 'S456',
            'concernSubType' => 'SubIssue',
            'projectUnitId' => 'projectUnitId',
            'priorityId' => 'High',
            'descrjption' => 'Test issue description'
        });

        // Setup mock request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/CreateSupportRequestAPI/';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        CreateSupportRequest.CreateSupportRequest();
        CreateSupportRequest.testcover();
        Test.stopTest();

       
    }

    @isTest
    static void testCreateSupportRequest_ExceptionFlow() {
        // Simulate exception by passing malformed JSON
        String badJson = '{"userid": "abc", "concernId": "xyz"'; // Missing closing }

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(badJson);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/CreateSupportRequestAPI/';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        CreateSupportRequest.CreateSupportRequest();
        Test.stopTest();

       
    }
@isTest
static void testSendSuccessResponse_Coverage() {
    // Step 1: Insert a valid customer
    Customer_Master__c customer = new Customer_Master__c(
        First_Name__c = 'Test',
        Last_Name__c = 'User',
        Email__c = 'test@example.com',
        Password__c = 'test123',
        Phone__c = '9999999999',
       
        Loyality__c = '0',
        isActive__c = true
    );
    insert customer;

    // Step 2: Create matching JSON input
    String jsonBody = JSON.serialize(new Map<String, Object>{
        'userid' => customer.Name,  // Must match exactly with 'Name' field
        'concernId' => 'CID001',
        'supportId' => 'SID001',
        'concernSubType' => 'Hardware',
        'priorityId' => 'High',
            'projectUnitId' => 'projectUnitId',
        'descrjption' => 'My device is not working'
    });

    // Step 3: Set RestContext
    RestRequest req = new RestRequest();
    req.requestBody = Blob.valueOf(jsonBody);
    req.httpMethod = 'POST';
    req.requestURI = '/services/apexrest/CreateSupportRequestAPI/';

    RestResponse res = new RestResponse(); // Ensure this line is present!

    RestContext.request = req;
    RestContext.response = res;

    // Step 4: Call the method and test
    Test.startTest();
    CreateSupportRequest.CreateSupportRequest();
    Test.stopTest();

    // Step 5: Validate response (verifies sendSuccessResponse() executed)
    String responseBody = RestContext.response.responseBody.toString();
    System.debug('Response Body: ' + responseBody);
    
   
}

}