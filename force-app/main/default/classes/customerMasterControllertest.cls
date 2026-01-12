@isTest
public class customerMasterControllertest {
    public static testMethod void Customertest(){
         Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales executive'];
        
        // Create a User object that uses that Profile
        User u = new User();
        u.LastName = 'test';
        u.ProfileId = p.Id;
        u.Alias = 'standt';
        u.Email = 'user@org.com';
        u.Username='use5666r@org.com';
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
        ld.OwnerId=u.id;
        
        insert ld;
       
        test.startTest();
          customerMasterController.getLead(10);
       customerMasterController.TotalLead();
        
        customerMasterController.readRecords(ld.id);
        customerMasterController.getProjectPickListValues();
        customerMasterController.getAllUsers();
       customerMasterController.getPickValues('Lead','State__c');
        customerMasterController.searchRecords1('Lead',10,5,'LastName,Company');
        customerMasterController.searchRecords('Lead','LastName,Company','New','test','DESC','Veegaland Elanza','Mycustomer',userinfo.getuserid(),system.today(),system.today(),system.today(),10,5);
          customerMasterController.getCover();

        test.stoptest();
    }
}