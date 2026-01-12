@isTest
public class RelatedSourceHandlerTest {
     public static testmethod void RelatedSourcetest() 
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
          
         Lead ld1 = new Lead();
         ld1.LastName = 'Test';
         ld1.Company = 'test';
         ld1.Phone = '9123456788';
         ld1.LeadSource = 'Common Floor';
         ld1.Allocated_Project__c ='Veegaland Elanza';   
         ld1.OwnerId = u.Id;
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
         led.Allocated_Project__c = 'Veegaland Elanza';
         led.OwnerId = u.Id;
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
         ld.Lead_status__c = 'New';
         ld.OwnerId = u.Id;
       //  ld.Country__c='India';
       // ld.State__c='Andaman';
         insert ld;
         
         
         Lead ld2 = new Lead();
         
         ld2.LastName = 'Test';
         ld2.Company = 'test';
         ld2.Phone = '913223456988';
         ld2.Secondary_Phone__c ='+9323456888';
         ld2.Country_Code__c = '91';
         ld2.Email = 'test32332@gmail.com';
         ld2.Secondary_Email__c='test867861@gmail.com';
         ld2.Allocated_Project__c='Veegaland Elanza';
         ld2.Project_City__c = 'Thrissur';
         ld2.Channel_partner_Name__c='test';
         ld2.Main_Lead__c = led.id;
         ld2.Delete_Lead__c = true;
         ld2.Sub_Source__c = 'test';
         ld2.Last_Comment__c = 'testesttest';
         ld2.Secondary_Country_Code__c = '91';
         ld2.LeadSource = 'Common Floor';
         ld2.Campaign__c = 'test';
         ld2.Type_of_lead__c = 'Direct Lead';
         ld2.CallUUID__c = 'test';
         ld2.Channel_partner_Email__c = 'tes756t1@gmail.com';
         ld2.Channel_partner_Phone__c = '9988776655';
         ld2.Re_engaged_Count__c = 3;
         ld2.Lead_status__c = 'New';
         ld2.Lead_stage__c = 'Qualification';
         ld2.Country__c='India';
       
         ld2.OwnerId = u.Id;
         insert ld2;
         List<Lead>ledlists = new List<Lead>();
         ledlists.add(ld2);
         
         
     list<Lead>ledlist = [select id,Main_Lead_Age__c, LastName,Leadsource__c,Main_lead_status__c,Lead.Project_City__c,Lead_status__c,Re_engaged_Count__c,Channel_partner_Phone__c,Channel_partner_Email__c,Channel_Partner_Firm__c,Secondary_Country_Code__c,CallUUID__c,Type_of_lead__c,Campaign__c, Company,Email,Sub_Source__c,Secondary_Email__c,Main_Lead__c, Channel_partner_Name__c,Delete_Lead__c, Phone, Allocated_project__c, Country__c,Country_Code__c,Last_Comment__c,Secondary_Country__c, Secondary_Phone__c, OwnerId from Lead];
        
         
         test.startTest();
         RelatedSourceHandler.checkMobileNumber(ledlist);
         RelatedSourceHandler.checkMobileNumber(ledlists);
        // RelatedSourceHandler.duplicateCheck(ledlist);
         RelatedSourceHandler.afterinsertLogic(ledlist);
         RelatedSourceHandler.addRelatedSource2(led,ld);
         RelatedSourceHandler.duplicateCheckProject(ledlist);
         RelatedSourceHandler.testcover();
        // RelatedSourceHandler.createLog(ledlist);
         test.stoptest();
     }
}