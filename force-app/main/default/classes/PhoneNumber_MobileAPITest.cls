@isTest
private class PhoneNumber_MobileAPITest {

    @testSetup
    static void setup() {
        Customer_Master__c cust = new Customer_Master__c(
            Email__c = 'phone@a.com',
            Password__c = 'pw',
            First_Name__c = 'P',
            Last_Name__c = 'U',
            Phone__c = '1000000005',
            WhatsApp_Number__c = '9000000000',
            isActive__c = true
        );
        insert cust;
    }

    @isTest
    static void testSuccess() {
        Customer_Master__c cust = [SELECT Name FROM Customer_Master__c LIMIT 1];
        String body = JSON.serialize(new Map<String, Object>{ 'userId' => cust.Name });

        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/PhoneNumberAPI/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(body);
        RestContext.response = new RestResponse();

        Test.startTest();
        PhoneNumber_MobileAPI.getMyPropertiesDetail();
        Test.stopTest();

      
    }

    @isTest
    static void testBlankUserId() {
        String body = JSON.serialize(new Map<String, Object>{ 'userId' => '' });

        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/PhoneNumberAPI/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(body);
        RestContext.response = new RestResponse();

        Test.startTest();
        PhoneNumber_MobileAPI.getMyPropertiesDetail();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode, 'Should return error when userId is blank');
    }

    @isTest
    static void testCustomerNotFound() {
        String body = JSON.serialize(new Map<String, Object>{ 'userId' => 'InvalidUser' });

        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/PhoneNumberAPI/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(body);
        RestContext.response = new RestResponse();

        Test.startTest();
        PhoneNumber_MobileAPI.getMyPropertiesDetail();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode, 'Should return error when customer not found');
    }

    @isTest
    static void testExceptionBlock() {
        // Malformed JSON (missing closing brace)
        String invalidJson = '{"userId": "test"';

        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/PhoneNumberAPI/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(invalidJson);
        RestContext.response = new RestResponse();

        Test.startTest();
        PhoneNumber_MobileAPI.getMyPropertiesDetail();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode, 'Should catch and handle exception');
    }
}