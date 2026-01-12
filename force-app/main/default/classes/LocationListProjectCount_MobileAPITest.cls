@isTest
private class LocationListProjectCount_MobileAPITest {
     
    @testSetup
    static void setup() {
        Customer_Master__c cm = new Customer_Master__c( isActive__c=true);
        insert cm;
        
           // Step 2: Insert Location
    Location__c loc = new Location__c();
    insert loc;
 
    // Step 3: Insert Project with Master_Location__c and Location__c
    Project__c proj = new Project__c(
        Name = 'Veegaland Casabella',
        Master_Location__c = loc.Id,
        Active__c = true,
        Project__c = 'Veegaland Casabella'
       
    );
     proj.put('Location__Latitude__s', 10.0);
        proj.put('Location__Longitude__s', 76.0);

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
        LocationListProjectCount_MobileAPI.getMyPropertiesDetail();
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
         LocationListProjectCount_MobileAPI.getMyPropertiesDetail();
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
        LocationListProjectCount_MobileAPI.getMyPropertiesDetail();
         LocationListProjectCount_MobileAPI.testcover();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
       
    }
}