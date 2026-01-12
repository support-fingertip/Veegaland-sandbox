@IsTest
private class ReceiptCSVUploadController_Tests {

    @TestSetup
    static void setupData() {
        // Use the running user as Finance User to avoid creating Users in test
        Id financeUserId = UserInfo.getUserId();

        // --- Bookings ---
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
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
        unit.BHK_Type__c = '1 BHK';
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
        unit1.BHK_Type__c = '1 BHK';
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
        
        Quote__c Qt1 = new Quote__c(
            Discount_In_Rupees__c = 100,
            Leads__c = ld.id,
            Project__c = 'Veegaland Green Heights',
            Unit__c =unit.Id,
            Car_Parking_Charge__c = 70,
            Extra_car_parking_charges__c = 10,
            Floor_Rise_Charges__c = 10,
            Built_up_area__c = 2000
        );
        
        insert Qt1;
        
        Quote__c Qt = new Quote__c(
            Discount_In_Rupees__c = 100,
            Leads__c = ld1.id,
            Project__c = 'Veegaland Green Heights',
            Unit__c =unit1.Id,
            Car_Parking_Charge__c = 70,
            Extra_car_parking_charges__c = 10,
            Floor_Rise_Charges__c = 10,
            Built_up_area__c = 2000
        );
        
        insert Qt;
        
        Booking__c book = new Booking__c();
        book.SLead__c = ld.Id;
        book.Quote__c = Qt.Id;
        book.Payment_Plan__c = payplan.Id;
        book.Followup_Date__c = system.today();
        book.Followup_Subject__c = 'test22';
        book.Last_Comment__c = 'test22';
        book.Project__c = 'Veegaland Green Heights';
        book.Payment_Type__c = 'Custom';
        book.Sale_Agreement_Completed__c = false;
        book.Agreement_Amount_Cleared__c ='Received Partial Amount';
        book.Stage__c ='Welcome Email';
        book.Demand_Number__c = '12345'; 
        book.Project1__c = project.Id; 
        book.Date_of_Booking__c = System.today(); 
        book.Mode_Of_Payment__c = 'Credit Card';
        book.Funding_Type__c = 'Loan';
        book.Plot__c = unit.Id;
        book.Loan_Sanction_Confirmed__c = true;
        book.Loan_Sanctioned_Amount__c = 10000;
        book.Sales_Manager1__c = owner.Id;
        book.Sales_Executive__c = owner.Id;
        book.Finance_User__c = owner.Id;
        book.First_Applicant_Name__c = 'Akhil';
        book.CRM_Manager__c=owner.Id;
        book.Legal_Team__c = owner.Id;
        book.Legal_Advocate_Assigned__c = owner.Id;
        book.Email1__c = 'Test@gamil.com';
        insert book;
        
        Booking__c book1 = new Booking__c();
        book1.SLead__c = ld1.Id;
        book1.Payment_Plan__c = payplan.Id;
        book1.Followup_Date__c = system.today();
        book1.Followup_Subject__c = 'test22';
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
        book1.First_Applicant_Name__c = 'Akhils';
        book1.Legal_Advocate_Assigned__c = owner.Id;
        book1.Email1__c = 'Test@gamil.com';
        insert book1;

        // --- Payment Schedules (ordered by S_No__c) ---
        // Booking 1 → two schedules: 60, 50
        Payment_Schedule__c b1ps1 = new Payment_Schedule__c(
            Name = 'B1-PS-1', Booking__c = book1.Id, S_No__c = 1
        );
        Payment_Schedule__c b1ps2 = new Payment_Schedule__c(
            Name = 'B1-PS-2', Booking__c = book1.Id, S_No__c = 2
        );

        // Booking 2 → one schedule: 100
        Payment_Schedule__c b2ps1 = new Payment_Schedule__c(
            Name = 'B2-PS-1', Booking__c = book.Id, S_No__c = 1
        );

        insert new List<Payment_Schedule__c>{ b1ps1, b1ps2, b2ps1 };
    }

    @IsTest
    static void test_InsertReceiptLineItems_endToEnd() {
        // Fetch setup records
        list<Booking__c> byName = new list<Booking__c>([
            SELECT Id, Name, Finance_User__c
            FROM Booking__c
            WHERE First_Applicant_Name__c IN ('Akhil','Akhils')
        ]);
        Booking__c b1 = byName[0];
        Booking__c b2 = byName[1];

        Date payDate = Date.today();

        // --- Build CSV-like rows (Receipt__c stubs) ---
        // Row 1: Match booking by NAME. Amount = 100 → allocates 60 + 40 across b1 PSes.
        Receipt__c r1 = new Receipt__c();
        r1.BookingName__c              = b1.Name; // Name-based matching
        r1.Receipt_date__c             = payDate;
        r1.Payment_From__c             = 'Customer';
        r1.Check_Transaction_Nmber__c  = 'TXN-001';
        r1.Amount_received__c          = 100;
        r1.Mode_of_payment__c          = 'Cash';
        r1.Payment_Received_Bank__c    = 'ICICI';
        r1.Branch__c                   = 'Main';
        r1.Remarks__c                  = 'Row1';
        r1.Approval_status__c          = 'Approved by Finance Team';
        r1.Skip_Approval__c            = false;

        // Row 2: Match booking by ID string. Amount = 150 → allocates 100 + residual 50 to last PS.
        Receipt__c r2 = new Receipt__c();
        r2.BookingName__c              = String.valueOf(b2.Id); // Id-based matching
        r2.Receipt_date__c             = payDate;
        r2.Payment_From__c             = 'Customer';
        r2.Check_Transaction_Nmber__c  = 'TXN-002';
        r2.Amount_received__c          = 150;
        r2.Mode_of_payment__c          = 'Cheque';
        r2.Payment_Received_Bank__c    = 'HDFC';
        r2.Branch__c                   = 'City';
        r2.Remarks__c                  = 'Row2';
        r2.Approval_status__c          = 'Approved by Finance Team';
        r2.Skip_Approval__c            = true;

        // Row 3: Booking with NO schedules → single RLI, no Payment_Schedule__c reference.
        Receipt__c r3 = new Receipt__c();
        r3.BookingName__c              = b2.Name;
        r3.Receipt_date__c             = payDate;
        r3.Payment_From__c             = 'Customer';
        r3.Check_Transaction_Nmber__c  = 'TXN-003';
        r3.Amount_received__c          = 75;
        r3.Mode_of_payment__c          = 'UPI';
        r3.Payment_Received_Bank__c    = 'SBI';
        r3.Branch__c                   = 'Suburb';
        r3.Remarks__c                  = 'Row3';
        r3.Approval_status__c          = 'Submitted'; // not the special approved value
        r3.Skip_Approval__c            = false;

        Test.startTest();
        List<Id> createdReceiptIds = ReceiptCSVUploadController.insertReceiptLineItems(
            new List<Receipt__c>{ r1, r2, r3 }
        );
        Test.stopTest();

     
    }

    @IsTest
    static void test_BatchEntryPoint_returnsJobId() {
        // Use a minimal row to feed the batch constructor.
        Booking__c b = [SELECT Id, Name FROM Booking__c WHERE First_Applicant_Name__c = 'Akhil' LIMIT 1];
        Receipt__c row = new Receipt__c();
        row.BookingName__c = b.Name;
        row.Amount_received__c = 1;
        row.Check_Transaction_Nmber__c = 'BATCH-001';
        row.Receipt_date__c = Date.today();

        Test.startTest();
        Id jobId = ReceiptCSVUploadController.startBatchInsertReceiptLineItems(new List<Receipt__c>{ row });
        System.assertNotEquals(null, jobId, 'Batch execute should return an AsyncApexJob Id');
        Test.stopTest();
    }
}