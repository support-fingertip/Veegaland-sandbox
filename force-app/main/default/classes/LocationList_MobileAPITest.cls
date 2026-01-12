@isTest
private class LocationList_MobileAPITest {
    
    @testSetup
    static void setup() {
        Customer_Master__c cust = new Customer_Master__c(
            Email__c = 'loc@ex.com',
            Password__c = 'p',
            First_Name__c = 'AA',
            Last_Name__c = 'BB',
            Phone__c = '1234567891',
            isActive__c = true
        );
        insert cust;

        // Create Project with GeoLocation set
        Project__c proj = new Project__c(
            Name = 'Proj1',
            Project__c = 'Veegaland Elanza',
           Used_in_Mobile_App__c = TRUE,
            
            Location__latitude__s = 12.9716,
            Location__longitude__s = 77.5946
        );
        insert proj;
    }

    @isTest
    static void testSuccess() {
        Customer_Master__c cust = [SELECT Name FROM Customer_Master__c LIMIT 1];
        String jsonInput = JSON.serialize(new Map<String,Object>{ 'userId' => cust.Name });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonInput);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/LocationListAPI/';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        LocationList_MobileAPI.getMyPropertiesDetail();
        Test.stopTest();

       
    }

    @isTest
    static void testBlankUser() {
        String jsonInput = JSON.serialize(new Map<String,Object>{ 'userId' => '' });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonInput);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/LocationListAPI/';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        LocationList_MobileAPI.getMyPropertiesDetail();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assert(RestContext.response.responseBody.toString().contains('Please Send correct userId'));
    }

    @isTest
    static void testCustomerNotFound() {
        String jsonInput = JSON.serialize(new Map<String,Object>{ 'userId' => 'InvalidUserName' });

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonInput);
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/LocationListAPI/';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        LocationList_MobileAPI.getMyPropertiesDetail();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
       
    }
}