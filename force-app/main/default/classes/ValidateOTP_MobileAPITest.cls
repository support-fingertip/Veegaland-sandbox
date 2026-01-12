@isTest
private class ValidateOTP_MobileAPITest {

    @testSetup
    static void setupData() {
        // Create test Customer_Master__c record
        Customer_Master__c customer = new Customer_Master__c(
           
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Phone__c = '9876543210',
            Email__c = 'test@example.com',
            Password__c = 'pass123',
            OTP_Number__c = 1234,
            isActive__c = true
        );
        insert customer;
    }

    @isTest
    static void testValidOTP() {
        Customer_Master__c cm = [SELECT Id, Name FROM Customer_Master__c LIMIT 1];

        String jsonInput = JSON.serialize(new Map<String, Object>{
            'userId' => cm.Name,
            'otp' => '1234',
            'deviceId' => 'device001'
        });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonInput);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/OTPVerificationAPI/';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ValidateOTP_MobileAPI.getMyPropertiesDetail();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
      
    }

    @isTest
    static void testInvalidOTP() {
        Customer_Master__c cm = [SELECT Name FROM Customer_Master__c LIMIT 1];

        String jsonInput = JSON.serialize(new Map<String, Object>{
            'userId' => cm.Name,
            'otp' => '0000',
            'deviceId' => 'device001'
        });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonInput);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/OTPVerificationAPI/';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ValidateOTP_MobileAPI.getMyPropertiesDetail();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
       // System.assert(RestContext.response.responseBody.toString().contains('OTP not matched'));
    }

    @isTest
    static void testBlankFields() {
        String jsonInput = JSON.serialize(new Map<String, Object>{
            'userId' => '',
            'otp' => '',
            'deviceId' => 'device001'
        });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonInput);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/OTPVerificationAPI/';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ValidateOTP_MobileAPI.getMyPropertiesDetail();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
       
    }

    @isTest
    static void testUserNotFound() {
        String jsonInput = JSON.serialize(new Map<String, Object>{
            'userId' => 'FakeUserId',
            'otp' => '1234',
            'deviceId' => 'device001'
        });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonInput);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/OTPVerificationAPI/';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ValidateOTP_MobileAPI.getMyPropertiesDetail();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
       
    }

    @isTest
    static void testExceptionHandling_InvalidJson() {
        // Deliberately malformed JSON
        String invalidJson = '{ "userId": "abc", "otp": "1234" '; // missing closing }

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(invalidJson);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/OTPVerificationAPI/';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ValidateOTP_MobileAPI.getMyPropertiesDetail();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
       
    }
}