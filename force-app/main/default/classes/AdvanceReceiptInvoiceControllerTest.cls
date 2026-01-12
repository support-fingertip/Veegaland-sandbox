@isTest
private class AdvanceReceiptInvoiceControllerTest {

    @testSetup
    static void setupTestData() {
        
          Project__c project = new Project__c(
            Name = 'Test Project',
              Project__c = 'Veegaland Green Heights'
            
        );
        insert project;
        // Create test Booking
        Booking__c booking = new Booking__c(
            
            Permanent_State__c = 'Kerala',
            Permanent_City__c = 'Cochin',
            Permanent_Post_Office__c = 'Edapally',
            Permanent_Street_Location__c = 'Main Road',
            Permanent_House_No_Name__c = '12A',
            First_Applicant_Name__c = 'John Doe',
            PAN_Number1__c = 'ABCDE1234F',
            salutation_Applicant1__c = 'Mr',
            GSTIN__c = '32ABCDE1234F1Z5',
            Permanent_Postal_Code__c = 682024
        );
        insert booking;

        // Create test Plot
        Plot__c plot = new Plot__c(
            Name = 'Plot 101',
           Apartment_area__c = 1200,
            Floor__c = '1',
            Carpet_Area__c = 950,
            Project__c = project.id,
            Unit_Common_Type__c = 'Type A'
        );
        insert plot;

        // Update Booking with Plot and Project reference
        booking.Plot__c = plot.Id;
        booking.Project__c = 'Veegaland Green Heights'; // Dummy Project ID or use a real one if available
        update booking;

        // Create Co-Applicant
        Co_Applicant__c coApp = new Co_Applicant__c(
            Name = 'Jane Doe',
            PAN_Number__c = 'WXYZ1234P',
            Booking__c = booking.Id
        );
        insert coApp;

        // Create Advance Receipt
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
          Invoice_Id__c = 'INV001',
            Booking__c = booking.Id
        );
        insert receipt;
    }

    @isTest
    static void testAdvanceReceiptInvoiceController() {
        Advance_Receipt__c testReceipt = [SELECT Id FROM Advance_Receipt__c LIMIT 1];
        ApexPages.StandardController stdController = new ApexPages.StandardController(testReceipt);
        Test.startTest();
        AdvanceReceiptInvoiceController controller = new AdvanceReceiptInvoiceController(stdController);
        Test.stopTest();

      
    }

    @isTest
    static void testConvertNumberToWordsZeroAndNull() {
        // Null test
        String result1 = AdvanceReceiptInvoiceController.convertNumberToWords(null);
       

        // Zero test
        String result2 = AdvanceReceiptInvoiceController.convertNumberToWords(0);
      

        // Random number
        String result3 = AdvanceReceiptInvoiceController.convertNumberToWords(155000);
       
    }
}