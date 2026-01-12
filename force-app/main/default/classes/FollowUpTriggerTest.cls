@isTest
public class FollowUpTriggerTest {
    
    public static testmethod void testfollowup(){
         Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales executive'];
        
        // Create a User object that uses that Profile
        User u = new User();
        u.LastName = 'test';
        u.ProfileId = p.Id;
        u.Alias = 'standt';
        u.Email = 'user@org.com';
        u.Username='use7788888r@org.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        insert u;
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Company = 'testCompany';
        ld.phone ='9876543459';
        ld.LeadSource = 'Website';
        ld.Email ='test@gmail.com';
        ld.Secondary_Email__c ='test2@gmail.com';
        ld.OwnerId=u.Id;
        
        insert ld;
        
        Follow_up__c fl = new Follow_up__c();
        fl.Leads__c= ld.id;
        fl.Scheduled_Date__c=DateTime.newInstance(2025, 10, 28, 23, 59, 59);
        fl.Status__c='Scheduled';
        insert fl;
        
        delete fl;
       
    }

}