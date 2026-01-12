@isTest
private class EnquireNow_MobileAPITest {
@isTest
static void testCreateLead_Success() {
     Customer_Master__c cm = new Customer_Master__c( isActive__c=true);
        insert cm;
          cm = [SELECT Name FROM Customer_Master__c WHERE Id = :cm.Id];
           // Step 2: Insert Location
    Location__c loc = new Location__c();
    insert loc;
 loc = [SELECT Name FROM Location__c WHERE Id = :loc.Id];
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
proj = [SELECT Name,Project_Id__c FROM Project__c WHERE Id = :proj.Id];
 RestRequest req = new RestRequest();
req.requestURI = '/services/apexrest/EnquireNowAPI/';
req.httpMethod = 'POST';

EnquireNow_MobileAPI.LeadWrapper wrapper = new EnquireNow_MobileAPI.LeadWrapper();
wrapper.userid = cm.Name;
wrapper.projectId = proj.Project_Id__c;
wrapper.lastName = 'Smith';
wrapper.firstName = 'Test';
wrapper.email = 'smith@example.com';
wrapper.phoneNumber = '9876543210';

req.requestBody = Blob.valueOf(JSON.serialize(wrapper));
    RestContext.request = req;

    // Set up RestContext.response to avoid null pointer
    RestContext.response = new RestResponse();

    // Call the API
    Test.startTest();
    EnquireNow_MobileAPI.CreateLead();
    Test.stopTest();

    // Optional: Assert Lead was created
    List<Lead> leads = [SELECT Id FROM Lead WHERE LastName = 'Smith'];
   
}


    static testMethod void testCreateLead_MissingFields() {
        Test.startTest();

        EnquireNow_MobileAPI.LeadWrapper leadWrapper = new EnquireNow_MobileAPI.LeadWrapper();
        leadWrapper.userid = 'USER123';
        leadWrapper.projectId = 'PROJ123';
        leadWrapper.lastName = 'Smith';
        leadWrapper.firstName = 'Test';
        leadWrapper.email = 'smith@example.com';
        leadWrapper.phoneNumber = '9876543210';
        
        String body = JSON.serialize(leadWrapper);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/EnquireNowAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);
        RestContext.request = req;
        RestContext.response = res;

        EnquireNow_MobileAPI.CreateLead();

        Test.stopTest();

        List<Apex_Log__c> logs = [SELECT Id, Status__c, response__c FROM Apex_Log__c ORDER BY CreatedDate DESC LIMIT 1];
       
    }

    static testMethod void testCreateLead_InvalidUserOrProject_Exception() {
        Test.startTest();

        EnquireNow_MobileAPI.LeadWrapper leadWrapper = new EnquireNow_MobileAPI.LeadWrapper();
        leadWrapper.userid = 'USER123';
        leadWrapper.projectId = 'PROJ123';
        leadWrapper.lastName = 'Smith';
        leadWrapper.firstName = 'Test';
        leadWrapper.email = 'smith@example.com';
        leadWrapper.phoneNumber = '9876543210';
        
        String body = JSON.serialize(leadWrapper);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/EnquireNowAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);
        RestContext.request = req;
        RestContext.response = res;

        EnquireNow_MobileAPI.CreateLead();

        Test.stopTest();

        List<Apex_Log__c> logs = [SELECT Id, Status__c, Error_Message__c FROM Apex_Log__c ORDER BY CreatedDate DESC LIMIT 1];
        System.assertEquals('FAIL', logs[0].Status__c);
        System.assert(logs[0].Error_Message__c.contains('List has no rows'), 'Expected query exception');
    }
@isTest
static void testExistingLead_SecondaryMatch() {
    // Insert test Customer
    Customer_Master__c customer = new Customer_Master__c(
        First_Name__c = 'Jane',
        Last_Name__c = 'Doe',
        Phone__c = '7778889999',
        Email__c = 'secondary@example.com',
        isActive__c = true
    );
    insert customer;

    // Insert test Project
    Project__c proj = new Project__c(
        Name = 'Test Project',
        Project__c = 'Veegaland Thejus',
        Display_in_Home__c = true,
        Display_in_Banner__c = false
    );
    insert proj;

    // Create lead with secondary phone/email
    Lead lead = new Lead(
        LastName = 'SecondaryMatch',
        Secondary_phone__c = '7778889999',
        Secondary_Email__c = 'secondary@example.com',
        Company = 'Test Co',
        Lead_Status__c = 'New',
        Allocated_Project__c = proj.Project__c
    );
    insert lead;

    RestRequest req = new RestRequest();
    req.httpMethod  = 'POST';
    req.requestUri  = '/services/apexrest/ScheduleSiteVisitAPI/';
    req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
        'userId'      => customer.Name,
        'projectId'   => proj.Project__c,
        'lastName'    => 'SecondaryMatch',
        'phoneNumber' => '7778889999',
        'email'       => 'secondary@example.com'
    }));
    RestContext.request  = req;
    RestContext.response = new RestResponse();

    Test.startTest();
    EnquireNow_MobileAPI.CreateLead();
    Test.stopTest();

  
}


}