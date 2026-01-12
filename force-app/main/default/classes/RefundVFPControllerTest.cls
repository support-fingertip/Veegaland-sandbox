@isTest
private class RefundVFPControllerTest {

    @isTest
    static void testRefundVFPController_Coverage() {
        
        User owner = new User(
            Email = 'owner112@example.com',
            Alias = 'owner',
            LastName='andy',
            ProfileId = UserInfo.getProfileId(),
            Username = 'owner43221163@example.com',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Working__c = true,
            isActive = true,
            Availability__c=true
        );
        insert owner;
        
        Project__c project = new  Project__c();
        project.Name = 'Veegaland Green Heights';
        project.Project_Type__c='Apartments';
        project.Finance_User__c = owner.Id;
        project.CRM_Manager__c =  owner.Id;
        project.Legal_User__c = owner.Id;
        project.Legal_User2__c = owner.Id;
        insert project;
        
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Company = 'testCompany';
        ld.phone ='9876543459';
        ld.LeadSource = '99 acres';
        ld.Project_City__c = 'Ernakulam';
        ld.Email ='test@gmail.com';
        ld.Secondary_Email__c ='test2@gmail.com';
        ld.OwnerId=owner.Id;
        
        insert ld; 
        
        Lead ld1 = new Lead();
        ld1.LastName = 'test';
        ld1.Company = 'testCompanyxx';
        ld1.phone ='9876543457';
        ld1.LeadSource = '99 acres';
        ld1.Project_City__c = 'Ernakulam';
        ld1.Email ='test1234@gmail.com';
        ld1.Secondary_Email__c ='test2343@gmail.com';
        ld1.OwnerId=owner.Id;
        
        insert ld1; 
        
        Payment_Plan__c payplan = new Payment_Plan__c();
        payplan.Active__c = true;
        payplan.Project__c = project.id;
        insert payplan;
        
        Master_payment_schedule__c mpy = new Master_payment_schedule__c ();
        mpy.S_No__c = 1;
        mpy.Status__c = 'Completed';
        mpy.Project__c = project.id;
        mpy.Payment_Plan__c = payplan.Id;
        mpy.Payment_Percent__c = 50;
        insert mpy;
        
        Master_payment_schedule__c mpy1 = new Master_payment_schedule__c ();
        mpy1.S_No__c = 2;
        mpy1.Payment_Percent__c = 50;
        mpy1.Status__c = 'Completed';
        mpy1.Project__c = project.id;
        mpy1.Payment_Plan__c = payplan.Id;
        insert mpy1;
        
        Block__c block = new Block__c();
        block.Name='A';
        block.Project__c=project.id;
        insert block;
        
        
        Plot__c unit1 = new Plot__c();
        unit1.Name = '105';
        unit1.Status__c = 'Available';
        unit1.Project__c = project.Id;
        unit1.Block__c = 'A4';
        unit1.Plot_Type__c = 'Residential';
        unit1.Block1__c = block.Id;
        unit1.Carpet_Area__c = 850;
        unit1.Balcony_Sq_mts__c = 20;
        unit1.Balcony_Area__c = 100;
        unit1.BHK_Type__c = '2.5 BHK';
        unit1.Premium_Status__c = 'Premium';
        unit1.Floor__c = '1';
        unit1.Share__c = 'MHPL';
        unit1.Facing__c = 'EAST';
        unit1.Carpet_Sq_mts__c = 80;
        unit1.CA__c = 75;
        unit1.Built_up_area__c = 1200;
        unit1.UDS__c = 300;
        unit1.UDS_Sq_mts__c = 50;
        unit1.Super_built_up_area__c = 1500;
        unit1.Price_Per_Sq_Ft__c = 5000;
        unit1.Floor_Rise__c = 200;
        unit1.Covered_Park_Parking__c = 50000;
        unit1.Other_Charges__c = 20000;
        unit1.Solar_Charges__c = 15000;
        unit1.GST1__c = 18;
        unit1.Floor__c = '3';
        insert unit1;

        // Create Booking
        Booking__c booking = new Booking__c(
            First_Applicant_Name__c = 'John Doe',
            PAN_Number1__c = 'ABCDE1234F',
            salutation_Applicant1__c = 'Mr',
            Plot__c = unit1.Id,
            Project__c = 'Veegaland Green Heights',
            GSTIN__c = '29ABCDE1234F2Z5',
            Permanent_Street_Location__c = 'MG Road',
            Permanent_Post_Office__c = 'PO Test',
            Permanent_City__c = 'Bangalore',
            Permanent_State__c = 'Karnataka',
            Permanent_House_No_Name__c = '123',
            Permanent_Postal_Code__c = 560001
        );
        insert booking;

        // Create Refund
        Refund__c refund = new Refund__c(
            Booking__c = booking.Id,
            Bank_Name__c = 'HDFC',
            Receipt_Number__c = 'RCPT-001',
           Total_GST_Amount__c = 500,
            Total_Base_Value__c  = 700,
            Transaction_Number__c = 'TXN12345',
            Name = 'Refund Test',
            Refund_Date__c = Date.today(),
            Voucher_No__c = 'VCH-001'
        );
        insert refund;

        // Create Co-Applicant
        Co_Applicant__c coApp = new Co_Applicant__c(
            Booking__c = booking.Id,
            Name = 'Jane Doe',
            PAN_Number__c = 'ABCDE5678F'
        );
        insert coApp;

        // Instantiate controller
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(refund);
        RefundVFPController controller = new RefundVFPController(stdCtrl);

    }
    
        @isTest
    static void testConvertNumberToWords() {
        // Test case for Zero
        String result = RefundVFPController.convertNumberToWords(0);
        System.assertEquals('Zero', result, 'Zero should be converted to "Zero"');

        // Test case for Single-digit numbers
        result = RefundVFPController.convertNumberToWords(5);
        System.assertEquals('Five', result, '5 should be converted to "Five"');
        
        // Test case for Teen numbers
        result = RefundVFPController.convertNumberToWords(15);
        System.assertEquals('Fifteen', result, '15 should be converted to "Fifteen"');
        
        // Test case for Tens (20-99)
        result = RefundVFPController.convertNumberToWords(40);
        System.assertEquals('Forty', result, '40 should be converted to "Forty"');
        
        result = RefundVFPController.convertNumberToWords(72);
        System.assertEquals('Seventy Two', result, '72 should be converted to "Seventy Two"');
        
        // Test case for Hundreds (100-999)
        result = RefundVFPController.convertNumberToWords(150);
        System.assertEquals('One Hundred Fifty', result, '150 should be converted to "One Hundred Fifty"');
        
        result = RefundVFPController.convertNumberToWords(850);
        System.assertEquals('Eight Hundred Fifty', result, '850 should be converted to "Eight Hundred Fifty"');
        
        // Test case for Thousands (1000-9999)
        result = RefundVFPController.convertNumberToWords(3000);
        System.assertEquals('Three Thousand', result, '3000 should be converted to "Three Thousand"');
        
        result = RefundVFPController.convertNumberToWords(9999);
        System.assertEquals('Nine Thousand Nine Hundred Ninety Nine', result, '9999 should be converted to "Nine Thousand Nine Hundred Ninety Nine"');
        
        // Test case for Lakhs (10000-999999)
        result = RefundVFPController.convertNumberToWords(250000);
        System.assertEquals('Two Lakh Fifty Thousand', result, '250000 should be converted to "Two Lakh Fifty Thousand"');
        
        result = RefundVFPController.convertNumberToWords(1500000);
        System.assertEquals('Fifteen Lakh', result, '1500000 should be converted to "Fifteen Lakh"');
        
        // Test case for Crores (10000000 and above)
        result = RefundVFPController.convertNumberToWords(10000000);
        System.assertEquals('One Crore', result, '10000000 should be converted to "One Crore"');
        
        result = RefundVFPController.convertNumberToWords(50000000);
        System.assertEquals('Five Crore', result, '50000000 should be converted to "Five Crore"');
    }

    @isTest
    static void testConvertNumberToWords_Null() {
        // Test case for null input
        String result = RefundVFPController.convertNumberToWords(null);
        System.assertEquals('Zero', result, 'Null should be converted to "Zero"');
    }
}