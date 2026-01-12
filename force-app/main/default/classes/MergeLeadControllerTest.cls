@isTest
public class MergeLeadControllerTest {
    public static testmethod void MergeLeadtest(){
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
        List<string> stringlist = new List<string>();
        stringlist.add('Manoj'); 
        stringlist.add('Raj'); 
        stringlist.add('Mohan');
        Lead ld = new Lead();
        ld.LastName = 'Test';
        ld.Company = 'test';
        ld.Phone = '11111111';
        ld.OwnerId=u.Id;
        insert ld;
        list<Lead>ledlist = [select id, LastName, Company, OwnerId from Lead];
        test.startTest();
        MergeLeadController.getLeads();
        MergeLeadController.findLead('t',stringlist);
        MergeLeadController.mergeLead(ledlist,ld.id);
        test.stoptest();
    }
}