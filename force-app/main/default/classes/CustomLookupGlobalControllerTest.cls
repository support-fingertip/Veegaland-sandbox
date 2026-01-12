@isTest
public class CustomLookupGlobalControllerTest {

    @testSetup
    static void setupTestData() {
        // Create test records for the Project__c object
        List<Project__c> projects = new List<Project__c>();
        for (Integer i = 0; i < 5; i++) {
            Project__c pr = new Project__c(
                Name = 'Project ' + i,
                Project_Type__c = 'Apartments'
            );
            projects.add(pr);
        }
        insert projects;
    }
/*
    @isTest
    static void testFetchRecords_WithSearchString() {
        // Test fetching records using search string
        Test.startTest();
        List<CustomLookupGlobalController.RecordsData> result = CustomLookupGlobalController.fetchRecords(
            'Project__c', 
            'Name', 
            'Project_Type__c', 
            'Pro%', 
            null, 
            null, 
            null, 
            null, 
            null
        );
        Test.stopTest();

        System.assert(result.size() > 0, 'Records should be returned');
        System.assert(result[0].label.startsWith('Project'), 'First record should start with "Project"');
    }

   

    @isTest
    static void testFetchRecords_WithInvalidSearch() {
        // Test with an invalid search, expecting no records
        Test.startTest();
        List<CustomLookupGlobalController.RecordsData> result = CustomLookupGlobalController.fetchRecords(
            'Project__c', 
            'Name', 
            null, 
            'Non', 
            null, 
            'Project_Type__c', 
            'Apartments', 
            null, 
            null
        );
        List<CustomLookupGlobalController.RecordsData> result1 = CustomLookupGlobalController.fetchRecordsGB('Project__c', 'Name', 'Project_Type__c', 'Project_Type__c=\'Apartments\'', '','');
        Test.stopTest();

        System.assert(result.size() == 0, 'No records should be returned for non-matching search string');
    }

    @isTest
    static void testFetchRecords_WithQueryField1AndValue() {
        // Test fetching records with specific queryField1 and queryValue1
        Project__c pr = [SELECT Id, Name FROM Project__c LIMIT 1];
        
        Test.startTest();
        List<CustomLookupGlobalController.RecordsData> result = CustomLookupGlobalController.fetchRecords(
            'Project__c', 
            'Name', 
            null, 
            null, 
            null, 
            null, 
            pr.Id, 
            'Project_Type__c', 
            'Apartments'
        );
        Test.stopTest();

        System.assert(result.size() > 0, 'Records should be returned');
        System.assert(result[0].label.startsWith('Project'), 'First record should start with "Project"');
    }*/
}