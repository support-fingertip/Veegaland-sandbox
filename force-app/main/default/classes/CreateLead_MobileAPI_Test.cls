@isTest
private class CreateLead_MobileAPI_Test {
    @testSetup
    static void setup() {
        Customer_Master__c cm = new Customer_Master__c(
             Email__c='lead@example.com',
            Password__c='pass',
            First_Name__c='Lead',
            Last_Name__c='User',
            Phone__c='1112223333',
            isActive__c=true
        );
        insert cm;
        Project__c proj = new Project__c(Name='ProjTest',   Project__c='Veegaland Thejus');
        insert proj;
    }
    
    @isTest
    static void testSuccess() {
        Project__c proj = [SELECT Project_Id__c FROM Project__c LIMIT 1];
        Customer_Master__c cm = [SELECT Name FROM Customer_Master__c LIMIT 1];
        String body = JSON.serialize(new Map<String, Object>{
            'userid' => cm.Name,
            'projectId' => proj.Project_Id__c,
            'name' => 'Sample Lead',
            'email' => 'lead@x.com',
            'phoneNumber' => '1234567890',
            'configuration' => '3BHK'
        });
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/LeadCreationAPI/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(body);
        RestContext.response = new RestResponse();
        Test.startTest();
        CreateLead_MobileAPI.CreateLead();
        Test.stopTest();
       
    }
    
    @isTest
    static void testBlankFields() {
        String body = JSON.serialize(new Map<String, Object>{
            'userid' => '',
            'projectId' => '',
            'name' => '',
            'phoneNumber' => ''
        });
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/LeadCreationAPI/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(body);
        RestContext.response = new RestResponse();
        Test.startTest();
        CreateLead_MobileAPI.CreateLead();
        Test.stopTest();
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    @isTest
    static void testCustomerNotFound() {
        Project__c proj = [SELECT Project_Id__c FROM Project__c LIMIT 1];
        String body = JSON.serialize(new Map<String, Object>{
            'userid' => 'NonExist',
            'projectId' => proj.Project_Id__c,
            'name' => 'Test',
            'phoneNumber' => '123'
        });
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/LeadCreationAPI/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(body);
        RestContext.response = new RestResponse();
        Test.startTest();
        CreateLead_MobileAPI.CreateLead();
        Test.stopTest();
        System.assertEquals(400, RestContext.response.statusCode);
    }
}