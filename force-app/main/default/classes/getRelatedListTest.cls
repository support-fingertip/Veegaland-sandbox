@isTest
public class getRelatedListTest 
{
@isTest
    public static void method1(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales executive'];
        
        // Create a User object that uses that Profile
        User u = new User();
        u.LastName = 'test';
        u.ProfileId = p.Id;
        u.Alias = 'standt';
        u.Email = 'user@org.com';
        u.Username='us88900er@org.com';
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
        CreateALogAfterLeasdUpdate.fromUpdateLeadStatus=false;
        site_visit__c sv = new site_visit__c();
        sv.Lead__c = ld.Id;
        sv.Status__c ='Scheduled';
        sv.Date__c = DateTime.newInstance(2025, 10, 28, 23, 59, 59);
        
        insert sv;
        Related_Source__c rs= new Related_Source__c();
       // rs.Name='test';
        rs.Source__c='Magic Bricks';
        rs.Sub_Source__c='Website';
        rs.Phone__c='9988775544';
        rs.Email__c='test@mail.com';
        insert rs;
       
        
        Follow_up__c fu = new Follow_up__c();
      //  u.Name='test';
        fu.Scheduled_Date__c=DateTime.newInstance(2025, 10, 28, 23, 59, 59);
        //fu.Subject__c='subject';
        fu.Status__c='Scheduled';
        fu.Description__c='description testing ';
        insert fu;
        
        getRelatedList.getRelatedList('rs');
        getRelatedList.getSiteVisit('sv');
        getRelatedList.getFollowUp('fu');
        getRelatedList.FollowUpdetails(ld.id);
       
        
        
    }
}