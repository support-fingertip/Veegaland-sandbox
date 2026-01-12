@isTest
public class SupportRequestHelperTest {

    @isTest
    static void testGetSupportRequestDependentMap() {
        Test.startTest();
        // Call the main dependency map method
        Map<String, List<String>> depMap = SupportRequestHelper.getSupportRequestDependentMap();
        Test.stopTest();

    }

    @isTest
    static void testGetProjectConcerns() {
        Test.startTest();
        List<String> projects = SupportRequestHelper.getProjectConcerns();
        Test.stopTest();

    }

    @isTest
    static void testGetSalesConcerns() {
        Test.startTest();
        List<String> sales = SupportRequestHelper.getSalesConcerns();
        Test.stopTest();

    }

    @isTest
    static void testFetchSupportRequestPicklistMapAuraEnabled() {
        Test.startTest();
        Map<String, List<String>> depMap = SupportRequestHelper.fetchSupportRequestPicklistMap();
        Test.stopTest();

    }
}