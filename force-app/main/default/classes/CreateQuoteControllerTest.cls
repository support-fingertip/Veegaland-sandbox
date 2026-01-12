@isTest
public class CreateQuoteControllerTest {
    
    public static testmethod void quoteControllerTest(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales executive'];
        
        // Create a User object that uses that Profile
        User owner = new User();
        owner.LastName = 'test';
        owner.ProfileId = p.Id;
        owner.Alias = 'standt';
        owner.Email = 'user@org.com';
        owner.Username='us3333er@org.com';
        owner.EmailEncodingKey = 'UTF-8';
        owner.LanguageLocaleKey = 'en_US';
        owner.LocaleSidKey = 'en_US';
        owner.TimeZoneSidKey = 'America/Los_Angeles';
        insert owner;
        
        Project__c project = new  Project__c();
        project.Name = 'Veegaland Green Heights';
        project.Project_Type__c='Apartments';
        project.Finance_User__c = owner.Id;
        project.CRM_Manager__c =  owner.Id;
        project.Legal_User__c = owner.Id;
        project.Legal_User2__c = owner.Id;
        insert project;
        
        Block__c block = new Block__c();
        block.Name='A';
        block.Project__c=project.id;
        insert block;
        
        Plot__c unit = new Plot__c();
        unit.Name = '101';
        unit.Status__c = 'Available';
        unit.Project__c = project.Id;
        unit.Block__c = 'A4';
        unit.Plot_Type__c = 'Residential';
        unit.Block1__c = block.Id;
        unit.Carpet_Area__c = 850;
        unit.Balcony_Sq_mts__c = 20;
        unit.Balcony_Area__c = 100;
        unit.BHK_Type__c = '3 BHK';
        unit.Premium_Status__c = 'Premium';
        unit.Floor__c = '1';
        unit.Share__c = 'MHPL';
        unit.Facing__c = 'EAST';
        unit.Carpet_Sq_mts__c = 80;
        unit.CA__c = 75;
        unit.Built_up_area__c = 1200;
        unit.UDS__c = 300;
        unit.UDS_Sq_mts__c = 50;
        unit.Super_built_up_area__c = 1500;
        unit.Price_Per_Sq_Ft__c = 5000;
        unit.Floor_Rise__c = 200;
        unit.Premium_Charge__c = 100000;
        unit.Covered_Park_Parking__c = 50000;
        unit.Other_Charges__c = 20000;
        unit.Solar_Charges__c = 15000;
        unit.GST1__c = 18;
        unit.Floor__c = '30';
        insert unit;
        
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
        unit1.BHK_Type__c = '3 BHK';
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
        unit.Premium_Charge__c = 100000;
        unit1.Covered_Park_Parking__c = 50000;
        unit1.Other_Charges__c = 20000;
        unit1.Solar_Charges__c = 15000;
        unit1.GST1__c = 18;
        unit1.Floor__c = '3';
        insert unit1;
        
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
        
        Master_payment_schedule__c mpy = new Master_payment_schedule__c (
            S_No__c = 1,
            Name='Booking Avance Amount',
            Status__c = 'Completed',
            Project__c = project.id,
            Payment_Plan__c = payplan.Id,
            Payment_Percent__c = 25
        );
        insert mpy;
        
        Master_payment_schedule__c mpy1 = new Master_payment_schedule__c (
            S_No__c = 2,
            Name='First payment schedule',
            Status__c = 'Completed',
            Project__c = project.id,
            Payment_Plan__c = payplan.Id,
            Payment_Percent__c = 25
        );
        insert mpy1;
        
        Master_payment_schedule__c mpy2 = new Master_payment_schedule__c (
            S_No__c = 2,
            Name='Second payment schedule',
            Status__c = 'Completed',
            Project__c = project.id,
            Payment_Plan__c = payplan.Id,
            Payment_Percent__c = 25
        );
        insert mpy2;
        
        Master_payment_schedule__c mpy3 = new Master_payment_schedule__c (
            S_No__c = 2,
            Name='third payment schedule',
            Status__c = 'Completed',
            Project__c = project.id,
            Payment_Plan__c = payplan.Id,
            Payment_Percent__c = 25
        );
        insert mpy3;
        
        Quote__c Qt = new Quote__c();
        Qt.Approval_status__c = 'Approved';
        Qt.Leads__c = ld.Id;
        Qt.Discount_In_Rupees__c = 100;
        Qt.Quote_status__c = 'Available';
        Qt.Project__c = project.id;
        Qt.Payment_Plan__c = payplan.Id;
        Qt.Unit__c = unit.id;
        qt.Payment_Type__c='Standard';
        Qt.Project__c = 'Veegaland Green Heights';
        QT.Extra_car_parking_charges__c=9798789;
        QT.Car_Parking_Charge__c=9798789;
        QT.Floor_Rise_Charges__c=8789;
        QT.Built_up_area__c=8789;
        
        insert Qt;
        
        Quote__c Qt1 = new Quote__c();
        Qt1.Approval_status__c = 'Approved';
        Qt1.Leads__c = ld1.Id;
        Qt1.Discount_In_Rupees__c = 100;
        Qt1.Quote_status__c = 'Available';
        Qt1.Payment_Plan__c = project.id;
        Qt1.Unit__c = unit1.id;
        Qt1.Payment_Type__c='Standard';
        Qt1.Project__c = 'Veegaland Green Heights';
        QT1.Extra_car_parking_charges__c=9798789;
        QT1.Car_Parking_Charge__c=9798789;
        QT.Floor_Rise_Charges__c=8789;
        QT1.Built_up_area__c=8789;
        
        
        test.startTest();
        CreateQuoteController.getPlots('Veegaland Green Heights');
        CreateQuoteController.getPicklistValues('Quote__c', 'Quote_status__c');
        CreateQuoteController.getPaymentTypePicklistValues();
        CreateQuoteController.saveOppPlot(QT1);
        CreateQuoteController.getPaymentSchedules(payplan.Id, 'Veegaland Green Heights');
        
        
        
        test.stoptest();
    }
}