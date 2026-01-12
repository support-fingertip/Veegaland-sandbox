@isTest
public class UpdateFollowUpControllerTest {
    @isTest
    static void testCreateALog_NewFollowUp() {
        // Test data setup
        // Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales executive'];
        
        // Create a User object that uses that Profile
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales executive'];
        User u = new User();
        u.LastName = 'test';
        u.ProfileId = p.Id;
        u.Alias = 'standt';
        u.Email = 'user@org.com';
        u.Username='user@org.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        insert u;
        Lead ld2 = new Lead();
        ld2.LastName = 'test';
        ld2.Company = 'testCompany';
        ld2.Phone = '9876543457';    
        ld2.LeadSource = 'Website';
        ld2.OwnerId = u.Id;
        ld2.Lead_status__c ='Working';
        ld2.Project_City__c = 'Thrissur';
        ld2.Allocated_Project__c = 'Veegaland Elanza';
        ld2.OwnerId=u.Id;
        ld2.Follow_up_scheduled_date__c = system.now()+2;
       // ld2.Follow_up_Subject__c = 'test';
        ld2.Follow_up_Status__c = 'Scheduled';
        insert ld2;
        Lead ld3 = new Lead();
        ld3.LastName = 'test';
        ld3.Company = 'testCompany';
        ld3.Phone = '9876543457';    
        ld3.LeadSource = 'Website';
        ld3.OwnerId = u.Id;
        ld3.Lead_status__c ='Working';
        ld3.Project_City__c = 'Thrissur';
        ld3.Allocated_Project__c = 'Veegaland Elanza';
        ld3.OwnerId=u.Id;
        ld3.Follow_up_scheduled_date__c = system.now()+2;
     //   ld3.Follow_up_Subject__c = 'test';
        ld3.Follow_up_Status__c = 'Completed';
        insert ld3;
        Follow_up__c tsk = new Follow_up__c();
        tsk.Leads__c = ld2.Id;
        tsk.Scheduled_Date__c = system.now()+2;
        tsk.Status__c = 'Scheduled';
        //tsk.Subject__c = 'test';
        tsk.Description__c = 'test';
        tsk.OwnerId = u.id;
		insert tsk;
        
        String result = UpdateFollowUpController.createALog(ld2.Id, 'New Follow Up','true');
        String result1 = UpdateFollowUpController.createALog(ld3.Id, 'New Follow Up','true');
        
        // Assert that no error message is returned
        System.assertEquals(null, result);

        // Add additional assertions as needed
    }

    @isTest
    static void testCreateALog_UpdateFollowUp_NoPendingTasks() {
        // Test data setup
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales executive'];
        User u = new User();
        u.LastName = 'test';
        u.ProfileId = p.Id;
        u.Alias = 'standt';
        u.Email = 'user@org.com';
        u.Username='user@org.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        insert u;
        Lead ld2 = new Lead();
        ld2.LastName = 'test';
        ld2.Company = 'testCompany';
        ld2.Phone = '9876543457';    
        ld2.LeadSource = 'Website';
        ld2.OwnerId = u.Id;
        ld2.Lead_status__c ='Working';
        ld2.Project_City__c = 'Thrissur';
        ld2.Allocated_Project__c = 'Veegaland Elanza';
        ld2.OwnerId=u.Id;
        ld2.Follow_up_Status__c = 'Scheduled';
        ld2.Follow_up_scheduled_date__c = system.now()+2;
       // ld2.Follow_up_Subject__c = 'test';
        insert ld2;

        // Test method invocation
        Test.startTest();
        String result = UpdateFollowUpController.createALog(ld2.Id, 'Update Follow Up','ture');
        Test.stopTest();

        // Assert that the expected error message is returned
        //System.assertEquals('No pending tasks. Sorry! Can not update.', result);

        // Add additional assertions as needed
    }
}