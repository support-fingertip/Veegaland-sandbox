@isTest
public class InterestRateSchedulerTest {
    
    // Test method to verify the functionality of InterestRateScheduler
    @isTest
    static void testInterestRateScheduler() {
        // Create a test Interest_Rate__c record for the current month
        DateTime currentDateTime = DateTime.now();
        String currentMonth = currentDateTime.format('MMMM');
        
        Interest_Rate__c testRate = new Interest_Rate__c(
            Interest_Rate__c = 5.5,
            Month__c = currentMonth
        );
        insert testRate;
        
        // Create a few Project__c records to be updated
        Project__c project1 = new Project__c(Interest_Percentage__c = 4.0);
        Project__c project2 = new Project__c(Interest_Percentage__c = 6.0);
        Project__c project3 = new Project__c(Interest_Percentage__c = 5.5); // Should not be updated
        insert new List<Project__c>{project1, project2, project3};
        
        // Start the test
        Test.startTest();
        
        // Schedule the job using System.schedule
        String cronExpression = '0 0 0 1 1 ?'; // Runs once at midnight
        String jobName = 'InterestRateScheduler Test';
        InterestRateScheduler scheduler = new InterestRateScheduler();
        System.schedule(jobName, cronExpression, scheduler);
        
        // End the test to allow the job to execute
        Test.stopTest();
        
        // Verify that the Interest_Percentage__c fields were updated
        Project__c updatedProject1 = [SELECT Interest_Percentage__c FROM Project__c WHERE Id = :project1.Id];
        Project__c updatedProject2 = [SELECT Interest_Percentage__c FROM Project__c WHERE Id = :project2.Id];
        Project__c updatedProject3 = [SELECT Interest_Percentage__c FROM Project__c WHERE Id = :project3.Id];
        
        // Assert that project1 and project2 were updated, but project3 was not
        System.assertEquals(5.5, updatedProject1.Interest_Percentage__c);
        System.assertEquals(5.5, updatedProject2.Interest_Percentage__c);
        System.assertEquals(5.5, updatedProject3.Interest_Percentage__c); // project3 should stay the same
    }
}