@isTest
private class CustomPicklistGlobalControllerTest {

    @isTest
    static void testFindPicklistOptions() {
        // Use a standard object and picklist field to ensure test consistency
        String objectApiName = 'Account';
        String fieldApiName = 'Industry';

        Test.startTest();
        List<CustomPicklistGlobalController.picklistWrapper> picklistOptions =
            CustomPicklistGlobalController.findPicklistOptions(objectApiName, fieldApiName);
        Test.stopTest();

        // Assert the result is not null
        System.assertNotEquals(null, picklistOptions, 'Picklist options should not be null');

        // Assert there's at least one picklist value (Industry field always has some values)
        System.assert(picklistOptions.size() > 0, 'Expected some picklist values for Industry');

        // Optional: Log first value
        System.debug('First Picklist Value: ' + picklistOptions[0].pickListValue);
    }
}