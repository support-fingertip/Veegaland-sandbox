@isTest
public class LeadOwnerPerformanceReportApexTestClass {
    @isTest
    public static void TestClassMethod(){
        Profile userProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Executive' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',  // Ensures unique username
            Alias = 'tuser',
            ProfileId = userProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        
        insert testUser;
        Lead ld = new Lead();
        ld.LastName = 'Varna';
        ld.Phone = '7845963211';
        ld.Lead_source__c = 'Website';
        ld.Company = 'abc';
        ld.OwnerId = testUser.Id;
        insert ld;
        Follow_up__c f = new Follow_up__c();
        f.Scheduled_Date__c = system.now()+1;
        f.Subject__c = 'Not Answering/Not Responding';
        f.Description__c = 'test';
        f.OwnerId = testUser.Id;
        insert f;
        f.Completed_Date__c = system.today();
        update f;
        date FromCreatedDateFilter = Date.newInstance(2024,01,01);
        date ToCreatedDateFilter = Date.newInstance(2024,12,31);
        LeadOwnerPerformanceReportApex.getRecords(FromCreatedDateFilter, ToCreatedDateFilter,'TODAY');
        LeadOwnerPerformanceReportApex.getRecords(FromCreatedDateFilter, ToCreatedDateFilter,'Date_Range');
        LeadOwnerPerformanceReportApex.getAllStageRecords(FromCreatedDateFilter, ToCreatedDateFilter,'TODAY');
        LeadOwnerPerformanceReportApex.getAllStageRecords(FromCreatedDateFilter, ToCreatedDateFilter,'Date_Range');
        LeadOwnerPerformanceReportApex.getLeadRecords(FromCreatedDateFilter, ToCreatedDateFilter,'TODAY');
        LeadOwnerPerformanceReportApex.getLeadRecords(FromCreatedDateFilter, ToCreatedDateFilter,'Date_Range');
        
    }
}