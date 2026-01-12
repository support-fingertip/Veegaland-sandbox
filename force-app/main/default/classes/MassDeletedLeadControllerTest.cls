@isTest
private class MassDeletedLeadControllerTest {
    
    @isTest
    static void testMassDeleted() {
        // Test setup
        Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Sales executive' LIMIT 1];
        User testUser = new User(
            ProfileId = testProfile.Id,
            FirstName = 'Test345',
            LastName = 'User543',
            Email = 'chethanamma5@gmail.com',
            Username = 'testuser34567866@example.com',
            Alias = 'TUser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert testUser;
        
         Project__c pjt = new Project__c();
        pjt.Name = 'Veegaland Elanza';
        pjt.Active__c = true;
        insert pjt;
        
        Round_Robin__c rr = new Round_Robin__c();
        rr.Type__c = 'Sales';
        rr.Project__c = pjt.id;
        rr.Project_Assigned__c='Veegaland Elanza';
        rr.Active__c=true;
        insert rr;
        
        Round_Robin_Member__c rb1=new Round_Robin_Member__c();
        //rb1.Name='18';
        rb1.User__c=testUser.id;
        rb1.User_Type__c='Sales';
        rb1.Round_Robin__c=rr.id;
        rb1.Active__c=true;
        insert rb1;
        
        Lead ld = new Lead();
        ld.LastName = 'Test';
        ld.Company = 'test';
        ld.Phone = '9123456788';
        ld.Allocated_Project__c='Veegaland Elanza';
        ld.Lead_Assigned__c = false;
        ld.Delete_Lead__c = false;
        ld.Projects__c = pjt.id;
        ld.OwnerId=testUser.id;
        insert ld;
        
        List<Lead> testLeads = new List<Lead>();
        testLeads.add(ld);
        
        Test.startTest();
        
        // Run the controller logic
        MassDeletedLeadController controller = new MassDeletedLeadController(new ApexPages.StandardSetController(testLeads));
        controller.getIDs = testLeads;
        
        // Assign the required profile to the test user
        System.runAs(testUser) {
            PageReference resultPage = controller.massdeleted();
            
            // Add assertions based on your specific requirements
           // System.assert(resultPage != null, 'Result page should not be null');
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testNoDeletePermission() {
        // Test setup
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        User u = new User(Alias = 'standt', Email='standarduserHouzbay@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserHouzbay@testorg.com',Availability__c =TRUE,Working__c=TRUE,IsActive=true);
        insert u;
        
        Project__c pjt = new Project__c();
        pjt.Name = 'Veegaland Elanza';
        pjt.Active__c = true;
        insert pjt;
        
        Round_Robin__c rr = new Round_Robin__c();
        rr.Type__c = 'Sales';
        rr.Project__c = pjt.id;
        rr.Project_Assigned__c='Veegaland Elanza';
        rr.Active__c=true;
        insert rr;
        
        Round_Robin_Member__c rb1=new Round_Robin_Member__c();
        //rb1.Name='18';
        rb1.User__c=u.id;
        rb1.User_Type__c='Sales';
        rb1.Round_Robin__c=rr.id;
        rb1.Active__c=true;
        insert rb1;
        
        Lead ld = new Lead();
        ld.LastName = 'Test';
        ld.Company = 'test';
        ld.Phone = '9123456788';
        ld.Allocated_Project__c='Veegaland Elanza';
        ld.Lead_Assigned__c = false;
        ld.Delete_Lead__c = false;
        ld.Projects__c = pjt.id;
        ld.OwnerId=u.id;
        insert ld;
        
        List<Lead> testLeads = new List<Lead>();
        testLeads.add(ld);
       
        
        Test.startTest();
        
        // Run the controller logic
        MassDeletedLeadController controller = new MassDeletedLeadController(new ApexPages.StandardSetController(testLeads));
        controller.getIDs = testLeads;
        
        // Assign the restricted profile to the test user
        System.runAs(u) {
            PageReference resultPage = controller.massdeleted();
            
            // Add assertions based on your specific requirements
            // System.assert(resultPage == null, 'Result page should be null due to lack of delete permission');
            //System.assertEquals(1, ApexPages.getMessages().size(), 'Error message should be added to the page');
        }
        
        Test.stopTest();
    }
    
    // Add more test methods to cover additional scenarios
}