@isTest
public class InterestRateTriggerTest {
    @isTest
    static void testInterestRateTrigger() {
        // Step 1: Insert test Project records
        Project__c proj1 = new Project__c(Name = 'Project 1', Interest_Percentage__c = 5);
        Project__c proj2 = new Project__c(Name = 'Project 2', Interest_Percentage__c = 7);
        insert new List<Project__c>{proj1, proj2};

        // Step 2: Insert Interest_Rate__c record with current month and initial rate
        Interest_Rate__c ir = new Interest_Rate__c(
            Interest_Rate__c = 10,
            Month__c = DateTime.now().format('MMMM') // current month name
        );
        insert ir;

        // Step 3: Update Interest_Rate__c to new value to fire trigger
        ir.Interest_Rate__c = 12;
        update ir;

        // Step 4: Query Projects and assert they were updated by trigger
        List<Project__c> updatedProjects = [SELECT Interest_Percentage__c FROM Project__c WHERE Id IN :new List<Id>{proj1.Id, proj2.Id}];
        for (Project__c p : updatedProjects) {
            System.assertEquals(12, p.Interest_Percentage__c, 'Project Interest Percentage should be updated to new Interest Rate');
        }
    }
}