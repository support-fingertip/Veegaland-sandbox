@isTest
public class ActivateCustomerMasterContrTest {
    
    @isTest
    static void testActivateCustomerMaster() {
        // Create a test Customer_Master__c record
        Customer_Master__c cm = new Customer_Master__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@example.com',
            Password__c = 'password123',
            Phone__c = '1234567890',
          
            Loyality__c = '100',
            isActive__c = false
        );
        insert cm;

        // Call the method with the test record ID
        Test.startTest();
        ActivateCustomerMasterContr.activateCustomerMaster(cm.Id);
        Test.stopTest();

        // Retrieve the updated record to verify the change
        cm = [SELECT isActive__c FROM Customer_Master__c WHERE Id = :cm.Id];
        System.assertEquals(true, cm.isActive__c, 'Customer should be activated');
    }

    @isTest
    static void testActivateCustomerMaster_NullId() {
        // This should do nothing and not throw any exception
        Test.startTest();
        ActivateCustomerMasterContr.activateCustomerMaster(null);
        Test.stopTest();
    }
}