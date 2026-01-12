@isTest
private class MobileIntegrationServiceTest {

    @isTest
    static void testPreviousPending() {
        // Step 1: Create Booking__c record
        Booking__c booking = new Booking__c(
           
            Permanent_Postal_Code__c = 123456
           
          
        );
        insert booking;

        // Step 2: Create Master_Payment_Schedule__c records
        Master_Payment_Schedule__c completedMilestone1 = new Master_Payment_Schedule__c(
            Name = 'Milestone 1',
            S_No__c = 1,
            Completed_Date__c = Date.today().addDays(-30),
            Payment_percent__c = 20,
            Status__c = 'Completed'
        );
        insert completedMilestone1;

        Master_Payment_Schedule__c completedMilestone2 = new Master_Payment_Schedule__c(
            Name = 'Milestone 2',
            S_No__c = 2,
            Completed_Date__c = Date.today().addDays(-10),
            Payment_percent__c = 30,
            Status__c = 'Completed'
        );
        insert completedMilestone2;

        // Step 3: Create Payment_Schedule__c records
        Payment_Schedule__c ps1 = new Payment_Schedule__c(
            Booking__c = booking.Id,
            Master_Payment_Schedule__c = completedMilestone1.Id,
           
            Payment_percent__c = 20
        );

        Payment_Schedule__c ps2 = new Payment_Schedule__c(
            Booking__c = booking.Id,
            Master_Payment_Schedule__c = completedMilestone2.Id,
          
            Payment_percent__c = 30
        );
        insert new List<Payment_Schedule__c>{ ps1, ps2 };

        // Step 4: Call the method and assert
        Test.startTest();
        String result = MobileIntegrationService.previousPending(booking.Id);
        Test.stopTest();

        System.debug('Result: ' + result);
        System.assertNotEquals('0', result, 'Expected some calculated balance due');
    }
}