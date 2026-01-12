@isTest
public class followUpControllerTest {
    public static testmethod void Bookingtest(){
         Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales executive'];
        User u = new User();
        u.LastName = 'test';
        u.ProfileId = p.Id;
        u.Alias = 'standt';
        u.Email = 'user@org.com';
        u.Username='us88888er@org.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        insert u;
        u.Availability__c=true;
        u.Working__c=true;
        update u;
        u.Availability__c=false;
        update u;
        
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
        
        CreateALogAfterLeasdUpdate.fromUpdateLeadStatus=false;
        site_visit__c sv = new site_visit__c();
        sv.Lead__c = ld.Id;
        sv.Status__c ='Scheduled';
        sv.Project__c = 'Veegaland Maybell';
        sv.Date__c = DateTime.newInstance(2025, 10, 28, 23, 59, 59);
        insert sv;
        string d ='29/01/2025, 5:08 pm';
        followUpController.getFollowUpDetails(ld.Id);
        followUpController.dateFormat(d);
    }

}