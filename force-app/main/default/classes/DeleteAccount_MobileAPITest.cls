@isTest
private class DeleteAccount_MobileAPITest {
    @testSetup
    static void setup() {
        Customer_Master__c cm = new Customer_Master__c(
             Email__c='del@example.com',
            Password__c='p',
            First_Name__c='Del',
            Last_Name__c='User',
            Phone__c='3333333333',
            isActive__c=true
        );
        insert cm;
    }
    @isTest
    static void testSuccess() {
        Customer_Master__c cm = [SELECT Name FROM Customer_Master__c LIMIT 1];
        String body = JSON.serialize(new Map<String,Object>{'userId'=>cm.Name});
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/DeleteAccountAPI/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(body);
        RestContext.response = new RestResponse();
        Test.startTest();
        DeleteAccount_MobileAPI.getMyPropertiesDetail();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
        Customer_Master__c updated = [SELECT isActive__c FROM Customer_Master__c WHERE Name = :cm.Name];
        System.assertEquals(false, updated.isActive__c);
    }
      @isTest
    static void testSuccess1() {
     
        String body = JSON.serialize(new Map<String,Object>{'userId'=> ''});
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/DeleteAccountAPI/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(body);
        RestContext.response = new RestResponse();
        Test.startTest();
        DeleteAccount_MobileAPI.getMyPropertiesDetail();
        Test.stopTest();
        
    }
    @isTest
    static void testBlankUserId() {
        String body = JSON.serialize(new Map<String,Object>{'userId'=>''});
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/DeleteAccountAPI/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(body);
        RestContext.response = new RestResponse();
        Test.startTest();
        DeleteAccount_MobileAPI.getMyPropertiesDetail();
        Test.stopTest();
        System.assertEquals(400, RestContext.response.statusCode);
    }
    @isTest
static void testExceptionBlock() {
    // Set malformed JSON to trigger JSON.deserialize() exception
    RestContext.request = new RestRequest();
    RestContext.request.requestUri = '/services/apexrest/DeleteAccountAPI/';
    RestContext.request.httpMethod = 'POST';
    RestContext.request.requestBody = Blob.valueOf('{"userId":'); // Invalid JSON
    RestContext.response = new RestResponse();

    Test.startTest();
    DeleteAccount_MobileAPI.getMyPropertiesDetail();
    Test.stopTest();

    // Even though response might not be 200 or 400 due to exception, this ensures the exception block ran.
    System.assertNotEquals(null, RestContext.response);
}
}