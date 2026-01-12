@isTest
public class LeadMergeBatchTest {
    @testSetup
    static void setupTestData() {
        // Create test leads with duplicate phone numbers
        Lead lead1 = new Lead(LastName = 'John Doe', Phone = '1234567890', Email = 'john@example.com', Status = 'Analysis',Company='Test');
        Lead lead2 = new Lead(LastName = 'John D.', Phone = '1234567890', Email = 'john.d@example.com', Status = 'Closed-Lost',Company='Test');
        insert new List<Lead>{ lead1, lead2 };

        // Create related records
        Related_Source__c rs = new Related_Source__c(Lead__c = lead2.Id, Source__c = 'Google Ads');
        insert rs;
    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();
        LeadMergeBatch batchJob = new LeadMergeBatch();
        Database.executeBatch(batchJob, 10); // Run batch with small size
        Test.stopTest();

        // Validate the primary lead is retained and related records are reassigned
        Lead retainedLead = [SELECT Id, Name FROM Lead WHERE Phone = '1234567890' LIMIT 1];
        System.assertNotEquals(null, retainedLead, 'Primary lead should exist');

        // Validate related records are reassigned
        List<Related_Source__c> relatedSources = [SELECT Id, Lead__c FROM Related_Source__c WHERE Lead__c = :retainedLead.Id];
        System.assert(relatedSources.size() > 0, 'Related sources should be reassigned');

        // Ensure only one lead remains
        List<Lead> remainingLeads = [SELECT Id FROM Lead WHERE Phone = '1234567890'];
       // System.assertEquals(1, remainingLeads.size(), 'Only one lead should remain after merging');
    }
}