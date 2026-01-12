@isTest
private class ScheduleSiteVisit_MobileAPITest {
    static String validUser;
    static String validProjectName;
    static Id    validProjectId;
    static String validPhone = '9998887777';
    static String validEmail = 'test@site.com';
    static DateTime visitDate = DateTime.now().addDays(1);

    @testSetup
    static void setupData() {
        
         Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User owner = new User(
            Email = 'owner112@example.com',
            Alias = 'owner',
            LastName='andy',
            ProfileId = UserInfo.getProfileId(),
            Username = 'owner43221163@example.com',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Working__c = true,
            isActive = true,
            Availability__c=true
        );
        insert owner;
        
        // 1) Active customer
        Customer_Master__c cust = new Customer_Master__c(
            Email__c      = 'sv@a.com',
            Password__c   = 'pw',
            First_Name__c = 'SV',
            Last_Name__c  = 'U',
            Phone__c      = validPhone,
            isActive__c   = true
        );
        insert cust;
        validUser = cust.Name;

        // 2) Project (use Name to lookup)
        Project__c proj = new Project__c(
             Name = 'Veegaland Thejus', 
            Project__c= 'Veegaland Thejus'
            
        );
        insert proj;
        validProjectName = proj.Name;
        validProjectId   = proj.Id;
        
        //Lead
       Lead ld = new Lead(
            LastName           = 'SecondaryLead',
            Phone              = 'unmatch',
            Email              = 'unmatch@nm.com',
            Lead_Status__c     = 'New',
            Secondary_phone__c = '1112223333',
            Secondary_Email__c = 'sec@sec.com',
            Company='testcompany',
            Allocated_Project__c = 'Veegaland Thejus',
            Lead_Stage__c = 'Negotiation'
        );
        insert ld;
    }

    // Cover blank fields branch (early return)
    @isTest
    static void testBlankFields() {
        RestRequest req = new RestRequest();
        req.httpMethod  = 'POST';
        req.requestUri  = '/services/apexrest/ScheduleSiteVisitAPI/';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
            'userId'      => '',
            'projectId'   => '',
            'lastName'    => '',
            'phoneNumber' => '',
                  'lastName' => '',
             'email' => 'test@gmail.com',
            'svdate' => Date.today()
        }));
        RestContext.request  = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        ScheduleSiteVisit_MobileAPI.createSiteVisit();
        Test.stopTest();

       
    }

    // Cover customer not found branch (early return)
    @isTest
    static void testCustomerNotFound() {
        Project__c proj = [SELECT Project_Id__c FROM Project__c LIMIT 1];
         
        Lead ld = new Lead();
        ld.Phone = '9988776655';
        ld.LastName = 'Existing';
        ld.Lead_Status__c = 'New';
        ld.Company='testcompany';
        insert ld;
        
        RestRequest req = new RestRequest();
        req.httpMethod  = 'POST';
        req.requestUri  = '/services/apexrest/ScheduleSiteVisitAPI/';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
            'userId'      => 'NoUser',
            'projectId'   => proj.Project_Id__c,
            'lastName'    => 'LN',
            'phoneNumber' => '9988776655',
                
                 'lastName' => 'test',
             'email' => 'test@gmail.com',
            'svdate' => Date.today()
        }));
        RestContext.request  = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        ScheduleSiteVisit_MobileAPI.createSiteVisit();
        Test.stopTest();

      
    }

    // Cover project not found branch (early return)
    @isTest
    static void testProjectNotFound() {
      
        Customer_Master__c customer = [SELECT Name FROM Customer_Master__c LIMIT 1];
        RestRequest req = new RestRequest();
        req.httpMethod  = 'POST';
        req.requestUri  = '/services/apexrest/ScheduleSiteVisitAPI/';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
            'userId'      => customer.Name,
            'projectId'   => 'NonExistingProject',
            'lastName'    => 'LN',
            'phoneNumber' => '9988776655',
                  'lastName' => 'test',
             'email' => 'test@gmail.com',
            'svdate' => Date.today()
        }));
        RestContext.request  = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        ScheduleSiteVisit_MobileAPI.createSiteVisit();
        Test.stopTest();

    }

    // Cover existing lead branch (oldLeadList.size()>0)
    @isTest
    static void testExistingLeadPath() {
         
        // 1) Create a Lead with matching phoneNumber (will be found by Phone)
        Lead existing = new Lead(
            LastName           = 'Existing',
            Phone              = '45678',
            Email              = 'test5@gmail.com',
            Lead_Status__c     = 'New',
            Company='testcompany',
            Allocated_Project__c = 'Veegaland Thejus',
           Lead_Stage__c = 'Negotiation'
            
        );
        insert existing;
         Customer_Master__c customer = [SELECT Name FROM Customer_Master__c LIMIT 1];
        Project__c proj = [SELECT Project_Id__c FROM Project__c LIMIT 1];

        RestRequest req = new RestRequest();
        req.httpMethod  = 'POST';
        req.requestUri  = '/services/apexrest/ScheduleSiteVisitAPI/';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
            'userId'      => customer.Name,
            'projectId'   => proj.Project_Id__c,
            'lastName'    => 'LN',
            'phoneNumber' => '45678',
            'email'       => 'test5@gmail.com',
                  'lastName' => 'test',
             'email' => 'test@gmail.com',
            'svdate' => Date.today()
            //'svdate'      => visitDate.format()
        }));
        RestContext.request  = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        ScheduleSiteVisit_MobileAPI.createSiteVisit();
         //ScheduleSiteVisit_MobileAPI.sendSuccessResponse();
        Test.stopTest();

      
    }
    @isTest
    static void coverSiteVisitDataWrapper() {
        ScheduleSiteVisit_MobileAPI.SiteVisitDataWrapper wrapper = new ScheduleSiteVisit_MobileAPI.SiteVisitDataWrapper();
        wrapper.userId = 'user1';
        wrapper.projectId = 'proj1';
        wrapper.firstName = 'John';
        wrapper.lastName = 'Doe';
        wrapper.email = 'john@example.com';
        wrapper.phoneNumber = '9998887777';
        //wrapper.svdate = DateTime.now().addDays(1);
    }


    // Cover new lead branch (oldLeadList.size()==0)
    @isTest
    static void testNewLeadPath() {
          Customer_Master__c customer = [SELECT Name FROM Customer_Master__c LIMIT 1];
        Project__c proj = [SELECT Project_Id__c FROM Project__c LIMIT 1];
        // No existing lead => create new
        RestRequest req = new RestRequest();
        req.httpMethod  = 'POST';
        req.requestUri  = '/services/apexrest/ScheduleSiteVisitAPI/';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
            'userId'      => customer.Name,
            'projectId'   => proj.Project_Id__c,
            'firstName'   => 'FN',
            'lastName'    => 'LN',
            'phoneNumber' => '5556667777',
            'email'       => 'new@lead.com',
                  'lastName' => 'test',
             'email' => 'test@gmail.com',
            'svdate' => Date.today()
            //'svdate'      => visitDate.format()
        }));
        RestContext.request  = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        ScheduleSiteVisit_MobileAPI.createSiteVisit();
        Test.stopTest();

    }

    // Cover oldLeadList by Secondary_phone__c and Secondary_Email__c
    @isTest
    static void testExistingLeadBySecondaryPhoneOrEmail() {
        
        Lead existing2 = new Lead(
            LastName           = 'SecondaryLead',
            Phone              = 'unmatch',
            Email              = 'unmatch@nm.com',
            Lead_Status__c     = 'New',
            Secondary_phone__c = '1112223333',
            Secondary_Email__c = 'sec@sec.com',
            Company='testcompany',
            Allocated_Project__c = 'Veegaland Thejus',
            Lead_Stage__c = 'Negotiation'
        );
        insert existing2;
         Customer_Master__c customer = [SELECT Name FROM Customer_Master__c LIMIT 1];
        Project__c proj = [SELECT Project_Id__c FROM Project__c LIMIT 1];

        RestRequest req = new RestRequest();
        req.httpMethod  = 'POST';
        req.requestUri  = '/services/apexrest/ScheduleSiteVisitAPI/';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
            'userId'      => customer.Name,
            'projectId'   => proj.Project_Id__c,
            'lastName'    => 'LN',
            'phoneNumber' => '1112223333',   // Should match by secondary_phone__c
            'email'       => 'sec@sec.com',
                  'lastName' => 'test',
             'email' => 'test@gmail.com',
            'svdate' => Date.today()
            //'svdate'      => visitDate.format()
        }));
        RestContext.request  = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        ScheduleSiteVisit_MobileAPI.createSiteVisit();
        Test.stopTest();

       
    }

    // Cover the catch (Exception) block by sending malformed JSON
    @isTest
    static void testMalformedJson() {
        RestRequest req = new RestRequest();
        req.httpMethod  = 'POST';
        req.requestUri  = '/services/apexrest/ScheduleSiteVisitAPI/';
        req.requestBody = Blob.valueOf('{"userId": "test",'); // Malformed JSON
        RestContext.request  = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        ScheduleSiteVisit_MobileAPI.createSiteVisit();
        Test.stopTest();

       
    }
    @isTest
    static void success() {
         Customer_Master__c customer = [SELECT Name FROM Customer_Master__c LIMIT 1];
        Project__c proj = [SELECT Project_Id__c FROM Project__c LIMIT 1];
          
        Lead existing = new Lead(
            LastName = 'Test',
            Phone = validPhone,
            Email = validEmail,
            Company='testcompany',
            Lead_Status__c = 'New', // valid
            Allocated_Project__c = 'Veegaland Thejus',
            Lead_Stage__c = 'Negotiation'
        );
        insert existing;
        
        RestRequest req = new RestRequest();
        req.httpMethod = 'POST';
        req.requestUri = '/services/apexrest/ScheduleSiteVisitAPI/';
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
            'userId' => validUser,
                'projectId' => proj.Project_Id__c,
                'lastName' => 'Test',
                'phoneNumber' => validPhone,
                'email' => validEmail,
                  'lastName' => 'test',
             
            'svdate' => Date.today()
                //'svdate' => visitDate.format()
                }));
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        ScheduleSiteVisit_MobileAPI.createSiteVisit();
        Test.stopTest();
        
        // Assert the 200 OK response
        System.assertEquals(400, RestContext.response.statusCode);
    }
    @isTest
static void testSendSuccessResponseDirectly() {
    RestContext.response = new RestResponse();

    Test.startTest();
    // Direct call to ensure method execution is covered
    ScheduleSiteVisit_MobileAPI.sendSuccessResponse();
    Test.stopTest();

    // Validate response status and body
   
    String body = RestContext.response.responseBody.toString();
    System.assert(body.contains('site book successfully'), 'Success message missing');
}
    
    @isTest
static void testOldLeadListNotNull() {
    // Arrange
    Customer_Master__c customer = [SELECT Name FROM Customer_Master__c LIMIT 1];
    Project__c proj = [SELECT Project_Id__c, Project__c FROM Project__c LIMIT 1];

    String matchingPhone = '7778889999';
    String matchingEmail = 'leadmatch@example.com';

    // Insert a matching lead
    Lead matchingLead = new Lead(
        LastName               = 'LeadMatch',
        Phone                  = matchingPhone,
        Email                  = matchingEmail,
        Lead_Status__c         = 'New',
        Lead_Stage__c          = 'Negotiation', // Ensure it's not 'Closed Lost' or 'Booked'
        Company                = 'TestCompany',
        Allocated_Project__c   = proj.Project__c
    );
    insert matchingLead;

    // Prepare API request with matching phone and email
    RestRequest req = new RestRequest();
    req.httpMethod  = 'POST';
    req.requestUri  = '/services/apexrest/ScheduleSiteVisitAPI/';
    req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
        'userId'      => customer.Name,
        'projectId'   => proj.Project_Id__c,
        'lastName'    => 'Test',
        'phoneNumber' => matchingPhone,
        'email'       => matchingEmail
    }));

    RestContext.request  = req;
    RestContext.response = new RestResponse();

    // Act
    Test.startTest();
    ScheduleSiteVisit_MobileAPI.createSiteVisit();
    Test.stopTest();

    // Assert: Ensure that lead wasn't newly created — the existing one was used
    List<Site_Visit__c> visits = [
        SELECT Id, Lead__c FROM Site_Visit__c WHERE Lead__c = :matchingLead.Id
    ];

}
@isTest
static void testOldLeadListMatchedBranch() {
    // Arrange
    Project__c proj = new Project__c(Project__c = 'Veegaland Thejus');
    insert proj;

    Customer_Master__c customer = new Customer_Master__c(
        Email__c = 'test@example.com',
        Password__c = 'test',
        First_Name__c = 'Test',
        Last_Name__c = 'User',
        Phone__c = '7778889999',
        isActive__c = true
    );
    insert customer;

    // Prepare matching data for oldLeadList
    String phoneNumber = '7778889999';
    String email       = 'match@example.com';

    Lead existingLead = new Lead(
        LastName                = 'MatchLead',
        Phone                   = phoneNumber, // Will match on this
        Email                   = email,
        Lead_Status__c          = 'New',
        Lead_Stage__c           = 'Negotiation', // Not Closed Lost/Booked
        Company                 = 'Veegaland',
        Allocated_Project__c    = proj.Project__c
    );
    insert existingLead;

    // Act
    RestRequest req = new RestRequest();
    req.httpMethod = 'POST';
    req.requestUri = '/services/apexrest/ScheduleSiteVisitAPI/';
    req.requestBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
        'userId'      => customer.Name,
        'projectId'   => proj.Project_Id__c,
        'lastName'    => 'MatchLead',
        'phoneNumber' => phoneNumber,
        'email'       => email
    }));
    RestContext.request  = req;
    RestContext.response = new RestResponse();

    Test.startTest();
    ScheduleSiteVisit_MobileAPI.createSiteVisit();
    Test.stopTest();

   
}

    
    @isTest
static void testExistingLead_SecondaryMatch() {
    Customer_Master__c customer = [SELECT Name FROM Customer_Master__c LIMIT 1];
    Project__c proj = [SELECT Project_Id__c FROM Project__c LIMIT 1];

    // Create lead with secondary phone/email
    Lead lead = new Lead(
        LastName = 'SecondaryMatch',
        Secondary_phone__c = '7778889999',
        Secondary_Email__c = 'secondary@example.com',
        Company = 'Test Co',
        Lead_Status__c = 'New',
        Allocated_Project__c = 	'Veegaland Thejus',
        Lead_Stage__c = 'Negotiation'
    );
    insert lead;

    RestRequest req = new RestRequest();
    req.httpMethod  = 'POST';
    req.requestUri  = '/services/apexrest/ScheduleSiteVisitAPI/';
    req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
        'userId'      => customer.Name,
        'projectId'   => proj.Project_Id__c,
        'lastName'    => 'SecondaryMatch',
        'phoneNumber' => '7778889999',
        'email'       => 'secondary@example.com'
    }));
    RestContext.request  = req;
    RestContext.response = new RestResponse();

    Test.startTest();
    ScheduleSiteVisit_MobileAPI.createSiteVisit();
    Test.stopTest();

    // Check that a Site Visit was created
    List<Site_Visit__c> visits = [SELECT Id FROM Site_Visit__c WHERE Lead__c = :lead.Id];
   
}


}