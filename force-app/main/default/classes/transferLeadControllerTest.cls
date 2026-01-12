@isTest
public class transferLeadControllerTest {
    public static testmethod void WelcomeMailtest(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales executive'];
        
        
        
        // Create a User object that uses that Profile
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
        List<string> l = new List<string>();
        
         Project__c project = new  Project__c();
        project.Name = 'Veegaland Green Heights';
        project.Project_Type__c='Apartments';
        project.Finance_User__c = u.Id;
        project.CRM_Manager__c =  u.Id;
        project.Legal_User__c = u.Id;
        project.Legal_User2__c = u.Id;
        insert project;

        
        Lead ld = new Lead();
        ld.LastName='Test';
        ld.Company = 'testCompany';
        ld.Email = 'test@gmail.com';
        ld.Projects__c = project.Id;
        ld.Secondary_Email__c = 'test1@gmail.com';
        ld.Lead_source__c = 'Common Floor';
        ld.Phone='5465474763';
        ld.OwnerId = u.Id;
        insert ld;
        l.add(ld.Id);
        
                
        
        test.startTest();
            //   transferLeadController.getRecordAccess(ld.id);
        transferLeadController.getPickListValues();
       // transferLeadController.getAllUsers(ld.id);
       // transferLeadController.LeadAssigned_Emailto_PreSalesUser(ld.id);
       // transferLeadController.LeadAssigned_Emailto_Customer(ld.id);
                transferLeadController.sendNotification(l);
        transferLeadController.getExisitingLead(ld);
      //  transferLeadController.moveToSales(ld.id,'Veegaland Elanza','tReason', true, UserInfo.getUserId());

         test.stoptest();
    }
}