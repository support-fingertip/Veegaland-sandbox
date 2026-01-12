@isTest
private class LoginAPI_MobileAPITest {
    
    static testMethod void testValidLogin_NewDevice() {
        // Setup Customer
        Customer_Master__c customer = new Customer_Master__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@example.com',
            Password__c = 'pass123',
            Phone__c = '9999999999',
            isActive__c = true
        );
        insert customer;

        String deviceId = 'device123';

        // Prepare JSON request
        String jsonBody = JSON.serialize(new Map<String, String>{
            'email' => customer.Email__c,
            'password' => customer.Password__c,
            'deviceId' => deviceId
        });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/LoginAPI/';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        LoginAPI_MobileAPI.CheckLogin();
        Test.stopTest();

        // Assert success
        System.assertEquals(200, RestContext.response.statusCode);
        String responseStr = RestContext.response.responseBody.toString();
        System.assert(responseStr.contains('Login successfully'));
    }

    static testMethod void testValidLogin_ExistingDevice() {
        // Setup Customer
        Customer_Master__c customer = new Customer_Master__c(
            First_Name__c = 'Jane',
            Last_Name__c = 'Smith',
            Email__c = 'jane@example.com',
            Password__c = 'mypassword',
            Phone__c = '8888888888',
            isActive__c = true
        );
        insert customer;

        String deviceId = 'device999';

        // Insert device already logged in before
        Logged_in_Device__c device = new Logged_in_Device__c(
            Customer_Master__c = customer.Id,
            Device_Id__c = deviceId,
            Status__c = 'Active',
            Last_Logged_Out__c = System.now()
        );
        insert device;

        String jsonBody = JSON.serialize(new Map<String, String>{
            'email' => customer.Email__c,
            'password' => customer.Password__c,
            'deviceId' => deviceId
        });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/LoginAPI/';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        LoginAPI_MobileAPI.CheckLogin();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        String responseStr = RestContext.response.responseBody.toString();
        System.assert(responseStr.contains('Login successfully'));
    }

    static testMethod void testInvalidLogin_WrongPassword() {
        Customer_Master__c customer = new Customer_Master__c(
            First_Name__c = 'Error',
            Last_Name__c = 'Case',
            Email__c = 'wrongpass@example.com',
            Password__c = 'correctpass',
            isActive__c = true
        );
        insert customer;

        String jsonBody = JSON.serialize(new Map<String, String>{
            'email' => customer.Email__c,
            'password' => 'wrongpass',
            'deviceId' => 'deviceX'
        });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/LoginAPI/';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        LoginAPI_MobileAPI.CheckLogin();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('Customer Not Found'));
    }

    static testMethod void testBlankEmailPassword() {
        String jsonBody = JSON.serialize(new Map<String, String>{
            'email' => '',
            'password' => '',
            'deviceId' => 'deviceZ'
        });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonBody);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/LoginAPI/';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        LoginAPI_MobileAPI.CheckLogin();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('Please enter correct email and password'));
    }

    static testMethod void testInvalidJSONThrowsException() {
        // Force an exception by passing invalid JSON
        String invalidJson = '{badJson}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(invalidJson);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/LoginAPI/';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        LoginAPI_MobileAPI.CheckLogin();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('Login failed'));
    }
}