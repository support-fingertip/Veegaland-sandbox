@isTest
private class AdvanceReceiptTriggerTest {

    @testSetup
    static void setupTestData() {
        Project__c project = new Project__c(
            Name = 'Test Project',
            Project__c = 'Veegaland Green Heights'
        );
        insert project;

        Booking__c booking = new Booking__c(
            Permanent_State__c = 'Kerala',
            Permanent_City__c = 'Cochin',
            Permanent_Post_Office__c = 'Edapally',
            Permanent_Street_Location__c = 'Main Road',
            Permanent_House_No_Name__c = '12A',
            First_Applicant_Name__c = 'John Doe',
            PAN_Number1__c = 'ABCDE1234F',
            GSTIN__c = '32ABCDE1234F1Z5',
            Permanent_Postal_Code__c = 682024
        );
        insert booking;

        Plot__c plot = new Plot__c(
            Name = 'Plot 101',
            Apartment_area__c = 1200,
            Floor__c = '1',
            Carpet_Area__c = 950,
            Project__c = project.Id,
            Unit_Common_Type__c = 'Type A'
        );
        insert plot;

        booking.Plot__c = plot.Id;
        booking.Project__c = 'Veegaland Green Heights';
        update booking;

        Co_Applicant__c coApp = new Co_Applicant__c(
            Name = 'Jane Doe',
            PAN_Number__c = 'WXYZ1234P',
            Booking__c = booking.Id
        );
        insert coApp;

        Advance_Receipt__c receipt = new Advance_Receipt__c(
            Advance_Amount__c = 105000,
            Advance_Receipt_Date__c = Date.today(),
            Bank_Name__c = 'ICICI Bank',
            Branch__c = 'MG Road',
            Cheque_Transaction_Number__c = 'TXN123456',
            Mode_of_Payment__c = 'Cheque',
            Payment_From__c = 'Customer',
            Finance_User__c = UserInfo.getUserId(),
            Remarks__c = 'Initial Payment',
            Invoice_Id__c = 'VD/AR/24-25/01',
            Booking__c = booking.Id
        );
        insert receipt;
    }

    @isTest
    static void testInvoiceIdWhenPreviousExists() {
        // Get the booking with existing receipt
        Booking__c existingBooking = [SELECT Id FROM Booking__c LIMIT 1];

        Advance_Receipt__c newReceipt = new Advance_Receipt__c(
            Booking__c = existingBooking.Id,
            Advance_Amount__c = 50000,
            Advance_Receipt_Date__c = Date.today()
        );

        Test.startTest();
        insert newReceipt;
        Test.stopTest();

        newReceipt = [SELECT Invoice_Id__c FROM Advance_Receipt__c WHERE Id = :newReceipt.Id];
        System.debug('New Invoice ID: ' + newReceipt.Invoice_Id__c);
        System.assert(newReceipt.Invoice_Id__c.contains('/02'), 'Expected invoice to end with /02');
    }

    @isTest
    static void testInvoiceIdWhenNoPreviousExists() {
        // Create a fresh booking with no prior receipts
        Booking__c newBooking = new Booking__c(
            Permanent_State__c = 'Tamil Nadu',
            Permanent_City__c = 'Chennai',
            Permanent_Post_Office__c = 'T Nagar',
            Permanent_Street_Location__c = 'Park Road',
            Permanent_House_No_Name__c = '88C',
            First_Applicant_Name__c = 'New Customer',
            PAN_Number1__c = 'XYZAB1234X',
            GSTIN__c = '33XYZAB1234X1Z6',
            Permanent_Postal_Code__c = 600017
        );
        insert newBooking;

        Advance_Receipt__c firstReceipt = new Advance_Receipt__c(
            Booking__c = newBooking.Id,
            Advance_Amount__c = 75000,
            Advance_Receipt_Date__c = Date.today()
        );

        Test.startTest();
        insert firstReceipt;
        firstReceipt.Approval_Status__c = 'Approved by Finance Team';
        update firstReceipt;
        Test.stopTest();

        firstReceipt = [SELECT Invoice_Id__c FROM Advance_Receipt__c WHERE Id = :firstReceipt.Id];
        System.debug('First Invoice ID: ' + firstReceipt.Invoice_Id__c);
        System.assert(firstReceipt.Invoice_Id__c.endsWith('/01'), 'Expected invoice to end with /01 for new booking');
    }
}