@isTest
private class ProjectNameList_MobileAPITest {
    static String validUser;
    static List<Project__c> insertedProjects;

    @testSetup
    static void setupData() {
        // 1) Create an active customer
        Customer_Master__c cust = new Customer_Master__c(
            Email__c      = 'projname@a.com',
            Password__c   = 'pw',
            First_Name__c = 'PN',
            Last_Name__c  = 'U',
            Phone__c      = '1000000008',
            isActive__c   = true
        );
        insert cust;
        validUser = cust.Name;

        // 2) Insert two projects so the loop runs twice
        insertedProjects = new List<Project__c>{
            new Project__c(Name='P1', Project__c='Veegaland Thejus'),
            new Project__c(Name='P2', Project__c='Veegaland Green Heights')
        };
        insert insertedProjects;
    }

    @isTest
    static void testSuccessProjectsReturned() {
         Customer_Master__c customer = [SELECT Name FROM Customer_Master__c LIMIT 1];
        String customerName = customer.Name;
        // Prepare REST request
        RestRequest req = new RestRequest();
        req.httpMethod  = 'POST';
        req.requestUri  = '/services/apexrest/ProjectNameListAPI/';
        req.requestBody = Blob.valueOf(JSON.serialize(
            new Map<String,Object>{ 'userId' => customerName }
        ));
        RestContext.request  = req;
        RestContext.response = new RestResponse();

        // Invoke
        Test.startTest();
        ProjectNameList_MobileAPI.getProjectNameList();
        Test.stopTest();

        
    }

    @isTest
    static void testBlankUserId() {
        RestRequest req = new RestRequest();
        req.httpMethod  = 'POST';
        req.requestUri  = '/services/apexrest/ProjectNameListAPI/';
        req.requestBody = Blob.valueOf(JSON.serialize(
            new Map<String,Object>{ 'userId' => '' }
        ));
        RestContext.request  = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        ProjectNameList_MobileAPI.getProjectNameList();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        System.assert(
            RestContext.response.responseBody.toString()
            .contains('Please Send correct Data'),
            'Expected blank-user error message'
        );
    }

    @isTest
    static void testCustomerNotFound() {
        RestRequest req = new RestRequest();
        req.httpMethod  = 'POST';
        req.requestUri  = '/services/apexrest/ProjectNameListAPI/';
        req.requestBody = Blob.valueOf(JSON.serialize(
            new Map<String,Object>{ 'userId' => 'NoSuchUser' }
        ));
        RestContext.request  = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        ProjectNameList_MobileAPI.getProjectNameList();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        
    }

    @isTest
    static void testMalformedJsonException() {
        RestRequest req = new RestRequest();
        req.httpMethod  = 'POST';
        req.requestUri  = '/services/apexrest/ProjectNameListAPI/';
        req.requestBody = Blob.valueOf('{invalidJson');
        RestContext.request  = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        ProjectNameList_MobileAPI.getProjectNameList();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
    }
}