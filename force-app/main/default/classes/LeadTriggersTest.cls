@isTest
public class LeadTriggersTest {
    
    public static testmethod void testLead()
    {
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
        User u1 = new User();
        u1.LastName = 'test1';
        u1.ProfileId = p.Id;
        u1.Alias = 'standt';
        u1.Email = 'user@org1.com';
        u1.Username='user@org1.com';
        u1.EmailEncodingKey = 'UTF-8';
        u1.LanguageLocaleKey = 'en_US';
        u1.LocaleSidKey = 'en_US';
        u1.TimeZoneSidKey = 'America/Los_Angeles';
        
        insert u1;
        system.runas(u){
        Lead ld2 = new Lead();
        ld2.LastName = 'test';
        ld2.Company = 'testCompany';
        ld2.Phone = '9876543457';    
        ld2.LeadSource = '99 acres';
        ld2.OwnerId = u.Id;
        //ld2.Lead_status__c ='Working';
        ld2.Project_City__c = 'Thrissur';
        ld2.Allocated_Project__c = 'Veegaland Elanza';
        ld2.OwnerId=u.Id;
        insert ld2;
        ld2.Re_assigned_date__c = DateTime.newInstance(2023, 11, 28, 23, 59, 59);
        ld2.Lead_Stage__c = 'Qualification';
        ld2.Lead_Assigned__c = false;
        ld2.Lead_Transfered__c = false;
        ld2.OwnerId=u1.Id;
        //update ld2;   
       
        }
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Company = 'testCompany';
        ld.phone ='9876543459';
        ld.LeadSource = '99 acres';
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
        
        Follow_up__c fw = new Follow_up__c();
        fw.Leads__c = ld.Id;
        fw.Status__c ='Scheduled';
        fw.Scheduled_Date__c =DateTime.newInstance(2025, 10, 28, 23, 59, 59);
        insert fw;
        ld.OwnerId = u.Id;  
        Update ld;
        ld.Lead_status__c = 'closed lost';
        update ld;
        ld.Re_assigned_date__c = DateTime.newInstance(2022, 10, 28, 23, 59, 59);
        ld.Lead_status__c = 'New';
        ld.Lead_Assigned__c = false;
        ld.Lead_Transfered__c = false;
        update ld;
       
        
    }
}