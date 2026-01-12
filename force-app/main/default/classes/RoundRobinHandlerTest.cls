@isTest
public class RoundRobinHandlerTest {
    
    @isTest
    public static void testAssignLead() {
        
        // Create test User (owner)
        User owner = new User(
            Email = 'owner112@example.com',
            Alias = 'owner',
            LastName = 'andy',
            ProfileId = UserInfo.getProfileId(),
            Username = 'owner43221163@example.com',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Working__c = true,
            isActive = true,
            Availability__c = true
        );
        insert owner;
        
        User owner1 = new User(
            Email = 'owner1@example.com',
            Alias = 'owner',
            LastName = 'andy',
            ProfileId = UserInfo.getProfileId(),
            Username = 'owner43221@example.com',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Working__c = true,
            isActive = true,
            Availability__c = true
        );
        insert owner1;
        
           Project__c project = new  Project__c();
        project.Name = 'Veegaland Casabella';
        project.Project_Type__c='Apartments';
        project.Finance_User__c = owner.Id;
        project.CRM_Manager__c =  owner.Id;
        project.Legal_User__c = owner.Id;
        project.Legal_User2__c = owner.Id;
        project.City__c = 'Ernakulam';
        insert project;
        
        // Create test Round Robin Members
        Round_Robin__c rr = new Round_Robin__c(
            Active__c = true,
            Project__c = project.Id,
            Project_Assigned_City__c = 'Ernakulam'
        );
        insert rr;
        
        Round_Robin_Member__c rrMember1 = new Round_Robin_Member__c(
            User__c = owner.Id,
            Round_Robin__c = rr.Id,
            User_Type__c = 'Sales',
            Active__c = true,
            Last_Assignment_Date_Time__c = null
        );
        insert rrMember1;
        
        Round_Robin_Member__c rrMember2 = new Round_Robin_Member__c(
            User__c = owner1.Id,
            Round_Robin__c = rr.Id,
            User_Type__c = 'Sales',
            Active__c = true,
            Last_Assignment_Date_Time__c = 2022
        );
        insert rrMember2;
        
     
        // Create test Lead
        Lead lead1 = new Lead(
            LastName = 'TestLead1',
            Company = 'TestCompany',
            Phone = '9876543210',
            project__c = 'Veegaland Casabella',
            Projects__c = project.Id,
            Leadsource__c = 'Inbound call',
            Project_City__c = 'Ernakulam',
            Lead_Assigned__c = false,
           Secondary_Email__c = 'test2@gmail.com',
            Email = 'test4@gmail.com'
        );
        insert lead1;
             // Create test Lead
        Lead lead3 = new Lead(
            LastName = 'TestLead1',
            Company = 'TestCompany',
            Phone = '9876543210',
            project__c = 'Veegaland Casabella',
            Projects__c = project.Id,
            Leadsource__c = 'Common Floor',
            Project_City__c = 'Ernakulam',
            Lead_Assigned__c = false,
           Secondary_Email__c = 'test2@gmail.com',
            Email = 'test4@gmail.com'
        );
        insert lead3;
        owner.Availability__c=false;
        update owner;
        owner1.Availability__c=false;
        update owner1;
        Lead lead2 = new Lead(
            LastName = 'TestLead2',
            Company = 'TestCompany',
            Phone = '9876543211',
            Leadsource__c = 'Inbound call',
            Project_City__c = 'Ernakulam',
            Lead_Assigned__c = false
          //  Email__c = 'test4@gmail.com'
        );
        insert lead2;
            
        
        
        // Prepare the list of Leads to assign
        List<Lead> leadsToAssign = new List<Lead>{ lead1, lead2 };
            CreateALogAfterLeasdUpdate.fromUpdateLeadStatus = false;
            
            Test.startTest();
        
        List<Site_visit__c> siteList = new List<Site_visit__c>();
        //creating sitevisit records
        Site_visit__c  site = new Site_visit__c();
        site.Lead__c =lead1.Id;
        site.Status__c = 'Scheduled';
        site.Date__c = Date.today();
        site.OwnerId = owner1.Id;
        insert site;
        siteList.add(site);
        
        List<Follow_up__c> flist = new List<Follow_up__c>();
        Follow_up__c  follow = new Follow_up__c(
        Leads__c = lead1.Id
        
        );
        insert follow;
        flist.add(follow);
        
      
            Lead lead4 = new Lead(
            LastName = 'TestLead1',
            Company = 'TestCompany',
            Phone = '9876543210',
            project__c = 'Veegaland Casabella',
            Projects__c = project.Id,
            Leadsource__c = 'Common Floor',
            Project_City__c = 'Ernakulam',
            Lead_Assigned__c = false,
           Secondary_Email__c = 'test2@gmail.com',
            Email = 'test4@gmail.com'
        );
        insert lead4;
         RoundRobinHandler.assignLead(leadsToAssign, true, 'Sales');
               owner.Availability__c=true;
        update owner;
        owner1.Availability__c=true;
        update owner1;
         RoundRobinHandler.assignLead(leadsToAssign, true, 'Sales');
        //RoundRobinHandler.assignCallEnquiryLeads(leadsToAssign, true, 'Sales');
        RoundRobinHandler.assignToSiteVisit(siteList);
        RoundRobinHandler.assignToFollowup(flist);
        Test.stopTest();
        
    
}
}