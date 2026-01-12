@isTest
public class HomeNotificationControllerTest {
    public static testmethod void Bookingtest(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales executive'];
        User u = new User();
        u.LastName = 'test';
        u.ProfileId = p.Id;
        u.Alias = 'standt';
        u.Email = 'user22@org.com';
        u.Username='ustest00777er@org.com';
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
        ld.Email ='testabc@gmail.com';
        ld.Secondary_Email__c ='test2@gmail.com';
        ld.OwnerId=u.Id;
        insert ld;
        
        Follow_up__c fl = new Follow_up__c();
        fl.Leads__c= ld.id;
        fl.Scheduled_Date__c=DateTime.newInstance(2025, 10, 28, 23, 59, 59);
        fl.Status__c='Scheduled';
        insert fl;
        
        CreateALogAfterLeasdUpdate.fromUpdateLeadStatus=true;
        
        Site_Visit__c sv = new Site_Visit__c();
        sv.Lead__c = ld.Id;
        sv.Date__c = Datetime.now().addDays(1);
        sv.Project__c='Veegaland Maybell';
        sv.Date__c=System.today()+1;
        sv.Status__c='Scheduled';
        insert sv;
        Site_Visit__c sv1 = new Site_Visit__c();
        sv1.Lead__c = ld.Id;
        sv1.Date__c = Datetime.now().addDays(1);
        sv1.Project__c='Veegaland Elanza';
        sv1.Date__c=System.today()+1;
        sv1.Status__c='Scheduled';
        insert sv1;
        /*site_visit__c sv2 = new site_visit__c();
        sv2.Lead__c = ld.Id;
        sv2.Status__c ='Scheduled';
        sv2.Date__c = DateTime.newInstance(2025, 10, 28, 23, 59, 59);
        sv2.Project__c = 'Veegaland Green Capital';
        insert sv2;*/
        string d = '16/09/2023, 18:00:00';
        string d1 = '16/09/2023, 18:00:00';
        HomeNotificationController.getFollowUpInformation();
        HomeNotificationController.getSiteVistInformation();
        HomeNotificationController.getPendingFollowUpInformation();
        HomeNotificationController.getPendingSiteVistInformation();
        HomeNotificationController.getMissedCallTask();
        HomeNotificationController.updateSvDetils(sv.id,'Cancelled' , 'Cancelled Commenrts',null);
        HomeNotificationController.updateSvDetils(sv1.id,'Completed' , 'Conducted comments','16/09/2025, 19:00:00');
        
       
    }
}