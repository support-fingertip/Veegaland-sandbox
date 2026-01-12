@isTest
private class BirthdayBatchTestClass {
    private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    @isTest
    static void testAssignTask() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales executive'];
        
        // Create a User object that uses that Profile
        User u = new User();
        u.LastName = 'test';
        u.ProfileId = p.Id;
        u.Alias = 'standt';
        u.Email = 'user@org.com';
        u.Phone = '7997807788';
        u.username='usettttttr@org.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.Working__c=false;
        u.Availability__c=false;
        u.TimeZoneSidKey = 'America/Los_Angeles';
        insert u;
        // Test data setup
        List<Lead> testLeads = new List<Lead>();
        Lead ld2 = new Lead();
        ld2.LastName = 'test';
        ld2.Company = 'testCompany';
        ld2.DOB__c = Date.today();
        ld2.Phone = '9876543457';    
        ld2.LeadSource = 'Website';
        ld2.Lead_status__c ='Working';
        ld2.OwnerId = u.Id;
        testLeads.add(ld2);
        insert ld2;
        ld2.Re_assigned_date__c = DateTime.newInstance(2023, 11, 28, 23, 59, 59);
        ld2.Lead_status__c = 'New';
        ld2.Lead_Assigned__c = false;
        ld2.Lead_Transfered__c = false;
        update ld2;   
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Company = 'testCompany';
        ld.DOB__c = Date.today();
        ld.phone ='9876543459';
        ld.LeadSource = 'Website';
        ld.Email ='test@gmail.com';
        ld.Secondary_Email__c ='test2@gmail.com';
        ld.OwnerId = u.Id;
        insert ld;
        testLeads.add(ld);
         Test.startTest();
		Test.setMock(HttpCalloutMock.class, new RestMock());
       
        BirthdayBatchClass.AssignTask();
        BirthdayBatchClass.TestIncrease();
        
        Test.stopTest();
    }
}