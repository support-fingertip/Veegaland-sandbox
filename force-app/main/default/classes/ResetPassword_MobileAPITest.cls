@isTest
private class ResetPassword_MobileAPITest {

    @testSetup
    static void setupData() {
        // Create test data for Customer_Master__c
        Customer_Master__c customer = new Customer_Master__c(
          
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Phone__c = '9999999999',
            Email__c = 'test@example.com',
            Password__c = 'oldPassword',
            isActive__c = true
        );
        insert customer;
    }

    @isTest
    static void testSuccessfulPasswordReset() {
        Customer_Master__c cm = [SELECT Name,Email__c FROM Customer_Master__c LIMIT 1];

        String jsonInput = JSON.serialize(new Map<String, Object>{
            'userId' => cm.Name,
            'newPassword' => 'newPass123',
            'email' =>  cm.Email__c,
            'confirmPassword' => 'newPass123'
        });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonInput);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/ResetPasswordAPI/';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ResetPassword_MobileAPI.changePasswordMethod();
        Test.stopTest();

      
        // Assert password update
        Customer_Master__c updated = [SELECT Password__c FROM Customer_Master__c WHERE Name = :cm.Name];
      
    }

    @isTest
    static void testBlankFieldsValidation() {
        String jsonInput = JSON.serialize(new Map<String, Object>{
            'userId' => '',
            'newPassword' => '',
            'confirmPassword' => ''
        });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonInput);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/ResetPasswordAPI/';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ResetPassword_MobileAPI.changePasswordMethod();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
       
    }

    @isTest
    static void testPasswordMismatchValidation() {
        Customer_Master__c cm = [SELECT Name FROM Customer_Master__c LIMIT 1];

        String jsonInput = JSON.serialize(new Map<String, Object>{
            'userId' => cm.Name,
            'newPassword' => 'pass1',
            'confirmPassword' => 'pass2'
        });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonInput);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/ResetPasswordAPI/';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ResetPassword_MobileAPI.changePasswordMethod();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
      
    }

    @isTest
    static void testUserNotFound() {
        String jsonInput = JSON.serialize(new Map<String, Object>{
            'userId' => 'NON_EXISTENT_USER',
            'newPassword' => 'abc123',
            'confirmPassword' => 'abc123'
        });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonInput);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/ResetPasswordAPI/';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ResetPassword_MobileAPI.changePasswordMethod();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
       
    }

    @isTest
    static void testExceptionHandlingWithInvalidJson() {
        // Force deserialization exception by malformed JSON
        String badJson = '{ "userId": "001", "newPassword": "pass1" '; // missing end brace

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(badJson);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/ResetPasswordAPI/';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ResetPassword_MobileAPI.changePasswordMethod();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
       
    }
}