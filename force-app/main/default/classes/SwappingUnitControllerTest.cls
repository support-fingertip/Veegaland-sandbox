@IsTest
public class SwappingUnitControllerTest {
    
    @TestSetup
    static void setup() {
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
        payplan.Disable_Merge__c = true;
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
        unit1.BHK_Type__c = '2 BHK';
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
        
        Quote__c Qt1 = new Quote__c(
            Discount_In_Rupees__c = 100,
            Leads__c = ld.id,
            Project__c = 'Veegaland Green Heights',
            Unit__c =unit1.Id,
            Car_Parking_Charge__c = 70,
            Extra_car_parking_charges__c = 10,
            Floor_Rise_Charges__c = 10,
            Built_up_area__c = 2000
        );
        
        insert Qt1;
        
        
        Booking__c book1 = new Booking__c();
        book1.SLead__c = ld1.Id;
        book1.Payment_Plan__c = payplan.Id;
        book1.Followup_Date__c = system.today();
        book1.Followup_Subject__c = 'test22';
        book1.Project1__c = project.Id;
        book1.Last_Comment__c = 'test22';
        book1.Project__c = 'Veegaland Green Heights';
        book1.Payment_Type__c = 'Custom';
        book1.Sale_Agreement_Completed__c = false;
        book1.Agreement_Amount_Cleared__c ='Received Partial Amount';
        book1.Stage__c ='Welcome Email';
        book1.Demand_Number__c = '12345'; 
        book1.Date_of_Booking__c = System.today(); 
        book1.Mode_Of_Payment__c = 'Credit Card';
        book1.Funding_Type__c = 'Loan';
        book1.Plot__c = unit1.Id;
        book1.Loan_Sanction_Confirmed__c = true;
        book1.Loan_Sanctioned_Amount__c = 10000;
        book1.Finance_User__c = owner.Id;
        book1.Sales_Manager1__c = owner.Id;
        book1.Sales_Executive__c =owner.Id;
        book1.Legal_Team__c = owner.Id;
        book1.CRM_Manager__c=owner.Id;
        book1.First_Applicant_Name__c = 'Akhil';
        book1.Legal_Advocate_Assigned__c = owner.Id;
        book1.Email1__c = 'Test@gamil.com';
        book1.Project1__c = project.Id;
        book1.Payment_Type__c = 'Standard';
        book1.GST__c =5;
        insert book1;
       
        Plot__c pl = new Plot__c();
        pl.Name = '101';
        pl.Status__c = 'Available';
        pl.Project__c = project.Id;
        pl.Block__c = 'A4';
        pl.Plot_Type__c = 'Residential';
        pl.Block1__c = block.Id;
        pl.Carpet_Area__c = 850;
        pl.Balcony_Sq_mts__c = 20;
        pl.Balcony_Area__c = 100;
        pl.BHK_Type__c = '2 BHK';
        pl.Premium_Status__c = 'Premium';
        pl.Floor__c = '1';
        pl.Share__c = 'MHPL';
        pl.Facing__c = 'EAST';
        pl.Carpet_Sq_mts__c = 80;
        pl.CA__c = 75;
        pl.Built_up_area__c = 1200;
        pl.UDS__c = 300;
        pl.UDS_Sq_mts__c = 50;
        pl.Super_built_up_area__c = 1500;
        pl.Price_Per_Sq_Ft__c = 5000;
        pl.Floor_Rise__c = 200;
        pl.Premium_Charge__c = 100000;
        pl.Covered_Park_Parking__c = 50000;
        pl.Other_Charges__c = 20000;
        pl.Solar_Charges__c = 15000;
        pl.GST1__c = 18;
        
        insert pl;
        
        Plot__c pl2 = new Plot__c();
        pl2.Name = '202';
        pl2.Status__c = 'Booked';
        pl2.Project__c = project.Id;
        pl2.Block__c = 'B7';
        pl2.Plot_Type__c = 'Commercial';
        pl2.Block1__c = block.Id;
        pl2.Carpet_Area__c = 900;
        pl2.Balcony_Sq_mts__c = 25;
        pl2.Balcony_Area__c = 120;
        pl2.BHK_Type__c = '2 BHK';
        pl2.Premium_Status__c = 'Super Premium';
        pl2.Floor__c = '2';
        pl2.Share__c = 'LAND OWNER';
        pl2.Facing__c = 'NORTH';
        pl2.Carpet_Sq_mts__c = 85;
        pl2.CA__c = 70;
        pl2.Built_up_area__c = 1300;
        pl2.UDS__c = 350;
        pl2.UDS_Sq_mts__c = 55;
        pl2.Super_built_up_area__c = 1600;
        pl2.Price_Per_Sq_Ft__c = 5500;
        pl2.Floor_Rise__c = 250;
        pl2.Premium_Charge__c = 120000;
        pl2.Covered_Park_Parking__c = 60000;
        pl2.Other_Charges__c = 25000;
        pl2.Solar_Charges__c = 18000;
        pl2.GST1__c = 18;
        
        insert pl2;

        
        
        Master_payment_schedule__c mpy2 = new Master_payment_schedule__c ();
        mpy.Status__c = 'Completed';
        mpy.Project__c = project.Id;
        mpy.S_No__c = 2;
        mpy.Payment_Percent__c = 50;
        insert mpy2;
        
        Master_payment_schedule__c mpy3 = new Master_payment_schedule__c ();
        mpy1.Status__c = 'Progress';
        mpy1.Project__c = project.Id;
        mpy.S_No__c = 3;
        mpy.Payment_Percent__c = 10;
        insert mpy3;
        
        list<Payment_schedule__c> pysch = new  list<Payment_schedule__c>();
        Payment_schedule__c pys = new Payment_schedule__c();
        pys.Payment_Percent__c=10;
        pys.Payment_Due_Date__c = system.today()+3;
        pys.Booking__c = book1.id;
        pys.Master_Payment_Schedule__c = mpy .Id;
        pys.name ='on booking';
        insert pys;
        pysch.add(pys);
    }
    
  /*  @IsTest
    static void testGetPlots() {
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
        
        List<Plot__c> plots = SwappingUnitController.getPlots(booking.Id);
        
    }*/
    
    @IsTest
    static void testGetBooking() {
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
        
        Booking__c result = SwappingUnitController.getBooking(booking.Id);
        
        System.assertNotEquals(null, result, 'Booking should not be null');
        System.assertEquals(booking.Id, result.Id, 'Booking ID should match');
    }
    
    @IsTest
    static void testGetUnit() {
        Plot__c plot = [SELECT Id FROM Plot__c LIMIT 1];
        
        Plot__c result = SwappingUnitController.getUnit(plot.Id);
        
        System.assertNotEquals(null, result, 'Plot should not be null');
        System.assertEquals(plot.Id, result.Id, 'Plot ID should match');
    }
    
    @IsTest
    static void testSaveOppPlot() {
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
        
        Booking__c updatedBooking = new Booking__c(Id = booking.Id);
        
        String result = SwappingUnitController.saveOppPlot(updatedBooking, booking.Id);
        
        //System.assertEquals(booking.Id, result, 'Updated Booking ID should match');
        
        Booking__c updated = [SELECT Name FROM Booking__c WHERE Id = :booking.Id];
    }
    
    @IsTest
    static void testGetPaymentTypePicklistValues() {
        List<String> paymentTypes = SwappingUnitController.getPaymentTypePicklistValues();
        
        System.assertNotEquals(0, paymentTypes.size(), 'Payment type picklist should not be empty');
    }
    
    @IsTest
    static void testGetPaymentSchedules() {
        String projectName = [SELECT Name FROM Project__c LIMIT 1].Name;
        
        List<Master_payment_schedule__c> paymentSchedules = SwappingUnitController.getPaymentSchedules('Standard', projectName);
        
    }
    
    @IsTest
    static void testInsertSchedules() {
        Booking__c booking1 = [SELECT Id FROM Booking__c where Payment_Type__c = 'Standard' LIMIT 1];
        
        List<Payment_schedule__c> paymentSchedules = new List<Payment_schedule__c>();
        List<Payment_schedule__c> paymentSchedules1 = new List<Payment_schedule__c>();
        Payment_schedule__c ps = new Payment_schedule__c(Name = 'Test Schedule', Payment_Percent__c = 10,Booking__c=booking1.Id);
        paymentSchedules.add(ps);
        
        Test.startTest();
        SwappingUnitController.insertSchedules(paymentSchedules, booking1.Id);
        Test.stopTest();
    
    }
}