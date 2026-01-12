@isTest
public class UnitPriceChangeTest 
{
    public static testMethod void ProjectBoardtest()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales executive'];
       User u = new User();
            u.LastName = 'test';
            u.ProfileId = p.Id;
            u.Alias = 'standt';
            u.Email = 'user@org.com';
            u.Username='user553555432@org.com';
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
        ut1.BHK_Type__c='2.5 BHK';
        insert ut1;
        Plot__c ut = new Plot__c();
        ut.Name='New';
        ut.Project__c=pjt.id;
        ut.Status__c='Available';
        ut.BHK_Type__c='2.5 BHK';
        insert ut;
        test.startTest();
      UnitPriceChange.getuserdetails();
      UnitPriceChange.getcon('',pjt.id,'2BHK','Available',system.today(),system.today(),'');
      UnitPriceChange.getprojectFieldValue();
      UnitPriceChange.getleadstatusFieldValue();
      UnitPriceChange.getLeadSource();
    
     list<Plot__c>ledlist = [select id, Name from Plot__c];
        
      UnitPriceChange.updateOwner(ledlist,userinfo.getUserId(),100);
      test.stoptest();
    }
    

}