@isTest
public class SaleAgreementControllerTest {
    
    public static testmethod void raisedemand(){
        Project__c project = new  Project__c();
        project.Name = 'Veegaland Green Heights';
        project.Project_Type__c='Apartments';
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
        
        Booking__c book = new Booking__c();
        book.Followup_Date__c = system.today();
        book.Followup_Subject__c = 'test22';
        book.Last_Comment__c = 'test22';
        book.Project1__c = project.Id;
        book.Project__c = 'Veegaland Green Heights';
        book.Payment_Type__c = 'Custom';
        book.Sale_Agreement_Completed__c = false;
        book.Agreement_Amount_Cleared__c ='Received Partial Amount';
        book.Stage__c ='Token Amount Collection';
        book.Demand_Number__c = '12345'; 
        book.Project1__c = project.Id; 
        book.Date_of_Booking__c = System.today(); 
        book.Mode_Of_Payment__c = 'Credit Card';
        book.Funding_Type__c = 'Own Funds';
        book.Plot__c = unit.Id;
        book.Loan_Sanction_Confirmed__c = true;
        book.Loan_Sanctioned_Amount__c = 10000;
        book.Sale_Agreement_Date__c = system.today();
        book.Built_up_area__c = 2080;
        book.Premium_Charge__c = 50000;
        book.Other_Charges__c = 30000;
        book.Covered_Park_Parking__c = 300000;
        book.GST__c = 10;
        insert book;
        
        Master_payment_schedule__c mpy = new Master_payment_schedule__c ();
        mpy.Status__c = 'Completed';
        mpy.Project__c = project.id;
        insert mpy;
        
        Payment_schedule__c pay = new Payment_schedule__c();
        pay.Booking__c = book.id;
        pay.Payment_percent__c = 20;
        pay.Master_Payment_Schedule__c = mpy.Id;
        //pay.Amount__c = 10000;
        pay.S_No__c = 2;
        pay.name = 'Test';
        insert pay;
        
        test.starttest();
        PageReference testPage = Page.SALE_AGREEMENT_AARYA; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(book.Id));
        ApexPages.StandardController sc = new  ApexPages.StandardController(book);     
        SaleAgreementController controller = new SaleAgreementController(sc);
        
        unit.Floor__c = '2';
        update unit ;
        ApexPages.StandardController sc1 = new  ApexPages.StandardController(book);     
        SaleAgreementController controller2 = new SaleAgreementController(sc1);
        unit.Floor__c = '12';
        update unit ;
        ApexPages.StandardController sc3 = new  ApexPages.StandardController(book);     
        SaleAgreementController controller3 = new SaleAgreementController(sc3);
        test.stoptest();
        
    }
    
}