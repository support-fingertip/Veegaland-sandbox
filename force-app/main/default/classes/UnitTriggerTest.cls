@isTest
public class UnitTriggerTest {
    public static testmethod void testUnit()
   {
       Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales executive'];
       User u = new User();
            u.LastName = 'test';
            u.ProfileId = p.Id;
            u.Alias = 'standt';
            u.Email = 'user@org.com';
            u.Username='user34tttttt3r@org.com';
            u.EmailEncodingKey = 'UTF-8';
            u.LanguageLocaleKey = 'en_US';
            u.LocaleSidKey = 'en_US';
            u.TimeZoneSidKey = 'America/Los_Angeles';
        insert u;
       
       Project__c pjt = new Project__c();
       pjt.Name = 'Veegaland Elanza';
       pjt.Active__c = true;
       pjt.CRM_executive__c = u.id;
       insert pjt;
       Plot__c ut1 = new Plot__c();
        ut1.Name='New1';
        ut1.Project__c=pjt.id;
        ut1.Status__c='Available';
        insert ut1;
        Plot__c ut = new Plot__c();
        ut.Name='New';
        ut.Project__c=pjt.id;
        ut.Status__c='Available';
        insert ut;
   }
}