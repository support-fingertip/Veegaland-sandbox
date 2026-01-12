@isTest
private class Demand_Note_AdditionalchargesTest {

    @isTest
    static void testControllerWithValidData() {
        // Step 1: Create Booking__c record (assuming necessary fields)
        Booking__c booking = new Booking__c(
            
            Permanent_Postal_Code__c = 560001
        );
        insert booking;

        // Step 2: Create Additional_Charges__c record
        Additional_Charges__c additionalCharge = new Additional_Charges__c(
            Booking__c = booking.Id,
           
            GST__c = 0.0,
            Amount__c = 100000.0
        );
        insert additionalCharge;

        // Step 3: Set the page parameters
        Test.setCurrentPage(Page.Demand_Note_Additionalcharges); // Replace with actual VF page name
        ApexPages.currentPage().getParameters().put('Id', additionalCharge.Id);

        // Step 4: Initialize the controller
        ApexPages.StandardController sc = new ApexPages.StandardController(additionalCharge);
        Demand_Note_Additionalcharges controller = new Demand_Note_Additionalcharges(sc);

        // Step 5: Assert computed values
        System.assertNotEquals(null, controller.formattedCurrentDate, 'Date should be formatted');
        System.assertNotEquals(null, controller.formattedPin, 'PIN should be formatted');
        System.assert(controller.valueOfSupply > 0, 'Value of supply should be computed');
        System.assert(controller.taxableValue > 0, 'Taxable value should be computed');
        System.assert(controller.cgst > 0, 'CGST should be computed');
        System.assert(controller.sgst > 0, 'SGST should be computed');
        System.assertNotEquals(null, controller.Current_Demand_Amount_In_Words, 'Amount in words should be set');
    }

    @isTest
    static void testControllerWithNullPin() {
        // Step 1: Create Booking__c without postal code
        Booking__c booking = new Booking__c();
        insert booking;

        // Step 2: Create Additional_Charges__c record
        Additional_Charges__c additionalCharge = new Additional_Charges__c(
            Booking__c = booking.Id,
          
            GST__c = 0.0,
            Amount__c = 100000.0
        );
        insert additionalCharge;

        // Step 3: Set the page parameters
        Test.setCurrentPage(Page.Demand_Note_Additionalcharges); // Replace with actual VF page name
        ApexPages.currentPage().getParameters().put('Id', additionalCharge.Id);

        // Step 4: Initialize the controller
        ApexPages.StandardController sc = new ApexPages.StandardController(additionalCharge);
        Demand_Note_Additionalcharges controller = new Demand_Note_Additionalcharges(sc);

        // Step 5: Validate formattedPin should remain null
        System.assertEquals(null, controller.formattedPin, 'formattedPin should be null when postal code is missing');
    }
}