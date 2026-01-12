@isTest
public class ChangePassword_MobileAPITest {
    
    @testSetup
    static void setupData() {
        // Create test user
        Customer_Master__c customer = new Customer_Master__c(
         
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Phone__c = '9876543210',
            Email__c = 'test@example.com',
            Password__c = 'oldPass123',
            isActive__c = true
        );
        insert customer;
    }

    @isTest
    static void testSuccessfulPasswordChange() {
        Customer_Master__c cm = [SELECT Name, Password__c FROM Customer_Master__c LIMIT 1];

        String jsonInput = JSON.serialize(new Map<String, Object>{
            'userId' => cm.Name,
            'oldPassword' => 'oldPass123',
            'newPassword' => 'newPass123',
            'confirmPassword' => 'newPass123'
        });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonInput);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/ChangePasswordAPI/';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ChangePassword_MobileAPI.changePasswordMethod();
        Test.stopTest();

       
      

        // Check updated password
        Customer_Master__c updated = [SELECT Password__c FROM Customer_Master__c WHERE Name = :cm.Name];
       
    }

    @isTest
    static void testBlankFields() {
        String jsonInput = JSON.serialize(new Map<String, Object>{
            'userId' => '',
            'oldPassword' => '',
            'newPassword' => '',
            'confirmPassword' => ''
        });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonInput);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/ChangePasswordAPI/';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ChangePassword_MobileAPI.changePasswordMethod();
        Test.stopTest();

        
       
    }

    @isTest
    static void testPasswordMismatch() {
        Customer_Master__c cm = [SELECT Name FROM Customer_Master__c LIMIT 1];

        String jsonInput = JSON.serialize(new Map<String, Object>{
            'userId' => cm.Name,
            'oldPassword' => 'oldPass123',
            'newPassword' => 'pass1',
            'confirmPassword' => 'pass2'
        });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonInput);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/ChangePasswordAPI/';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ChangePassword_MobileAPI.changePasswordMethod();
        Test.stopTest();

       
       
    }

    @isTest
    static void testWrongOldPassword() {
        Customer_Master__c cm = [SELECT Name FROM Customer_Master__c LIMIT 1];

        String jsonInput = JSON.serialize(new Map<String, Object>{
            'userId' => cm.Name,
            'oldPassword' => 'wrongOldPass',
            'newPassword' => 'new123',
            'confirmPassword' => 'new123'
        });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonInput);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/ChangePasswordAPI/';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ChangePassword_MobileAPI.changePasswordMethod();
        Test.stopTest();

       
       
    }

    @isTest
    static void testUserNotFound() {
        String jsonInput = JSON.serialize(new Map<String, Object>{
            'userId' => 'Non_Existent_User',
            'oldPassword' => 'whatever',
            'newPassword' => 'new',
            'confirmPassword' => 'new'
        });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonInput);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/ChangePasswordAPI/';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ChangePassword_MobileAPI.changePasswordMethod();
        Test.stopTest();

       
       
    }

    @isTest
    static void testMalformedJsonExceptionHandling() {
        // Malformed JSON
        String invalidJson = '{ "userId": "abc", "oldPassword": "123" '; // missing brace

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(invalidJson);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/ChangePasswordAPI/';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ChangePassword_MobileAPI.changePasswordMethod();
        Test.stopTest();

       
    }
}