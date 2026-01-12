@isTest
public class CreateALogAfterLeasdUpdateTest {
    public static testmethod void LeasdUpdatetest(){
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
        
        Project__c pjt = new Project__c();
        pjt.Name = 'Veegaland Elanza';
        pjt.Active__c = true;
        insert pjt;
        Project__c pjt1 = new Project__c();
        pjt1.Name = 'test project';
        pjt1.Active__c = true;
        insert pjt1;
        
        Lead ld1 = new Lead();
        ld1.LastName = 'Test';
        ld1.Company = 'test';
        ld1.Phone = '9123456788';
        ld1.LeadSource = 'Common Floor';
        ld1.Allocated_Project__c ='Veegaland Elanza';   
        ld1.OwnerId=u.Id;
        insert ld1;
        
        Related_Source__c rs = new Related_Source__c();
        rs.Phone__c = '+9123456788';
        rs.Allocated_Project__c ='Veegaland Elanza';
        rs.Secondary_Email__c='test1@gmail.com';
        rs.Email__c = 'test@gmail.com';
        rs.Secondary_Phone__c ='+9123456788';
        rs.Lead__c = ld1.id;
        insert rs;
        
        Lead led = new Lead();
        led.LastName = 'Test';
        led.Company = 'test';
        led.Phone = '9123456788';
        led.LeadSource = 'Common Floor';
        led.Lead_status__c = 'Closed lost';
        led.Lead_stage__c = 'Closed lost';
        led.Allocated_Project__c = 'Veegaland Elanza';
        led.OwnerId=u.Id;
        insert led;
        
        
        Lead ld = new Lead();
        ld.LastName = 'Test';
        ld.Company = 'test';
        ld.Phone = '+9123456788';
        ld.Secondary_Phone__c ='+9123456788';
        ld.Country_Code__c = '91';
        ld.Email = 'test@gmail.com';
        ld.Secondary_Email__c='test1@gmail.com';
        ld.Allocated_Project__c='Veegaland Elanza';
        ld.Channel_partner_Name__c='test';
        ld.Main_Lead__c = led.id;
        ld.Delete_Lead__c = true;
        ld.Sub_Source__c = 'test';
        ld.Last_Comment__c = 'testesttest';
        ld.Secondary_Country_Code__c = '91';
        ld.LeadSource = 'Common Floor';
        ld.Campaign__c = 'test';
        ld.Type_of_lead__c = 'Direct Lead';
        ld.CallUUID__c = 'test';
        ld.Channel_partner_Email__c = 'test1@gmail.com';
        ld.Channel_partner_Phone__c = '9988776655';
        ld.Re_engaged_Count__c = 3;
        ld.Lead_status__c='New';
        ld.Lead_stage__c='Qualification';
        //ld.Country__c='India';
      //  ld.State__c='Kerala';
        ld.OwnerId=u.Id;
        //SV Schedule
        insert ld;
        /*Follow_up__c f = new Follow_up__c();
        f.Scheduled_Date__c = system.now()+1;
        f.Subject__c = 'Not Answering/Not Responding';
        f.Description__c = 'test';
        insert f;*/

        CreateALogAfterLeasdUpdate.fromUpdateLeadStatus=true;
        
        site_visit__c sv = new site_visit__c();
        sv.Lead__c = ld.Id;
        sv.Status__c ='Scheduled';
        sv.Projects__c = pjt.Id;
        sv.Date__c = DateTime.newInstance(2025, 10, 28, 23, 59, 59);
        sv.Feedback__c='hgvjhgj';
        
        
        insert sv;
        
        site_visit__c sv1 = new site_visit__c();
        sv1.Lead__c = ld.Id;
        sv1.Status__c ='Completed';
        sv1.Projects__c = pjt.Id;
        sv1.Date__c = DateTime.newInstance(2025, 10, 28, 23, 59, 59);
        sv1.SV_Completed_Date_Time__c = DateTime.newInstance(2025, 10, 28, 23, 59, 59);
        sv1.Feedback__c='hgvjhgj';
        
        
        insert sv1;
        /*ld.Lead_status__c='SV Schedule';
        ld.Lead_stage__c='SV Schedule';
        ld.Phone='4654758090';
        ld.Secondary_Phone__c='24354657';
        ld.Site_Visit_Feedback__c='tfgvjk';
        ld.Site_Visit_Schedule_Date__c = DateTime.newInstance(2025, 10, 28, 23, 59, 59);
        update ld;*/
        test.startTest();
        CreateALogAfterLeasdUpdate.createALog(ld.Id, 'Veegaland Elanza', 'SV Schedule');
        CreateALogAfterLeasdUpdate.createALog(ld.id,'test project','SV Schedule');
        CreateALogAfterLeasdUpdate.createALog(ld.id,'test project','SV Completed');
        /*ld.Lead_status__c='SV Completed';
        ld.Lead_stage__c='SV Completed';
        ld.SV_Completed_Date_Time__c = system.now();
        ld.Phone='4654758';
        ld.Secondary_Phone__c='24354657';
        update ld;  */    
        CreateALogAfterLeasdUpdate.createALog(ld.id,pjt.Id,'SV Completed');
        CreateALogAfterLeasdUpdate.getAllocatedProject(ld.id);
        CreateALogAfterLeasdUpdate.getProject(ld.id);
        CreateALogAfterLeasdUpdate.getProject(ld.id);
        CreateALogAfterLeasdUpdate.checkfollowUp(ld.id);
        CreateALogAfterLeasdUpdate.UpdateFollowUps(ld.id,'New Follow Up','true');
        CreateALogAfterLeasdUpdate.testcover();
        CreateALogAfterLeasdUpdate.getFollowUps(ld.id);
        test.stoptest();
    }
}