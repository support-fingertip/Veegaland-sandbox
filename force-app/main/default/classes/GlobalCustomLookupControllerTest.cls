@isTest
public class GlobalCustomLookupControllerTest {
    
    @testSetup
    static void setupData() {
        // Create a role hierarchy
        UserRole parentRole = new UserRole(Name = 'Parent Role');
        insert parentRole;

        UserRole childRole = new UserRole(Name = 'Child Role', ParentRoleId = parentRole.Id);
        insert childRole;

        // Create current user
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id,
            UserRoleId = childRole.Id
        );
        insert u;

        System.runAs(u) {
            // Create dummy object with fields for dynamic SOQL test (using Account)
            Account acc1 = new Account(Name = 'Test Account A', AccountNumber = '001');
            Account acc2 = new Account(Name = 'Test Account B', AccountNumber = '002');
            insert new List<Account>{acc1, acc2};
        }
    }

    @isTest
    static void testFetchRecords_UsingValue() {
        Account a = [SELECT Id, Name FROM Account LIMIT 1];
        Test.startTest();
        List<GlobalCustomLookupController.RecordsData> results = GlobalCustomLookupController.fetchRecords(
            'Account',
            'Name',
            'AccountNumber',
            '',
            a.Id,
            '',
            '',
            '',
            ''
        );
        Test.stopTest();
      
    }

    @isTest
    static void testFetchRecords_UsingQueryFieldAndSearchString() {
        Test.startTest();
        List<GlobalCustomLookupController.RecordsData> results = GlobalCustomLookupController.fetchRecords(
            'Account',
            'Name',
             'Industry',
           	'Test',
            '',
            'AccountNumber',
            '0121123212441',
            '',
            ''
        );
        Test.stopTest();
      
    }

    @isTest
    static void testFetchRecords_SearchOnly() {
        Test.startTest();
        List<GlobalCustomLookupController.RecordsData> results = GlobalCustomLookupController.fetchRecords(
            'Account',
            'Name',
            'AccountNumber',
            'Test',
            '',
            '',
            '',
            '',
            ''
        );
        Test.stopTest();
       
    }

    @isTest
    static void testFetchRecordsGB_WithValueOnly() {
        Account a = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        List<GlobalCustomLookupController.RecordsData> results = GlobalCustomLookupController.fetchRecordsGB(
            'Account',
            'Name',
            'AccountNumber',
            '',
            a.Id,
            ''
        );
        Test.stopTest();
        System.assertEquals(1, results.size());
    }

    @isTest
    static void testFetchRecordsGB_WithQueryAndSearch() {
        Test.startTest();
        List<GlobalCustomLookupController.RecordsData> results = GlobalCustomLookupController.fetchRecordsGB(
            'Account',
            'Name',
            'AccountNumber',
            'AccountNumber=\'001\'',
            '',
            'Test'
        );
        Test.stopTest();
       
    }

    @isTest
    static void testFetchRecordsGB_UserCase() {
        Test.startTest();
        List<GlobalCustomLookupController.RecordsData> results = GlobalCustomLookupController.fetchRecordsGB(
            'User',
            'Name',
            'Email',
            '',
            '',
            'Test'
        );
        Test.stopTest();
       
    }

    @isTest
    static void testFetchUsers() {
        Test.startTest();
        List<GlobalCustomLookupController.RecordsData> results = GlobalCustomLookupController.fetchUsers(
            'Name',
            'Email',
            'Test'
        );
        Test.stopTest();
       
    }
}