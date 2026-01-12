@isTest
public class SiteVisitTriggerHandlerTest {
    public static testmethod void testLead()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales executive'];
        
        // Create a User object that uses that Profile
        User u = new User();
        u.LastName = 'test';
        u.ProfileId = p.Id;
        u.Alias = 'standt';
        u.Email = 'user@org.com';
        u.Username='use7778996r@org.com';
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
        List<site_visit__c> svlst= new List<site_visit__c>();
        
        CreateALogAfterLeasdUpdate.fromUpdateLeadStatus=false;
        site_visit__c sv = new site_visit__c();
        sv.Lead__c = ld.Id;
        sv.Status__c ='Scheduled';
        sv.Date__c = DateTime.newInstance(2025, 10, 28, 23, 59, 59);
        
        insert sv;
        svlst.add(sv);
        CreateALogAfterLeasdUpdate.fromUpdateLeadStatus=false;
        sv.Status__c ='Rescheduled';
        sv.Reschedule_Date__c = system.now()+1;
        update sv;
        sv.Status__c ='Completed';
        sv.Feedback__c = 'test';
        sv.SV_Completed_Date_Time__c = DateTime.newInstance(2025, 10, 28, 23, 59, 59);
      ///  update sv;
        sv.Status__c ='Cancelled';
        sv.Cancelled_Reason__c = 'test';
        update sv;
        sv.Date__c = DateTime.newInstance(2024, 10, 28, 23, 59, 59);
        update sv;
        
        Test.startTest();
        SiteVisitTriggerHandler.handleAfter(svlst,svlst);
        Test.stopTest();
    }

}