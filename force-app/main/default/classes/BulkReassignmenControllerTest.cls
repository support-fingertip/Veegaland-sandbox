@isTest
public class BulkReassignmenControllerTest {
  public static testMethod void ProjectBoardtest(){
      Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales executive'];
        
        // Create a User object that uses that Profile
        User u = new User();
        u.LastName = 'test';
        u.ProfileId = p.Id;
        u.Alias = 'standt';
        u.Email = 'user@org.com';
        u.Username='us555er@org.com';
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
        test.startTest();
      BulkReassignmenController.getuserdetails();
      BulkReassignmenController.getcon(userinfo.getUserId(),'Veegaland Elanza','New','Common Floor','',system.today(),system.today(),'');
      BulkReassignmenController.getprojectFieldValue();
      BulkReassignmenController.getleadstatusFieldValue();
      BulkReassignmenController.getLeadSource();
      BulkReassignmenController.getLeadStageFieldValue();
      
     list<Lead>ledlist = [select id, LastName, Company, OwnerId from Lead];
        
      BulkReassignmenController.updateOwner(ledlist,userinfo.getUserId(),userinfo.getUserId());
      test.stoptest();
  }
}