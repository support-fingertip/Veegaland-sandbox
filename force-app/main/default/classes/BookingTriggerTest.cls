@isTest
private class BookingTriggerTest {

   @testSetup
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
        insert payplan;
        
        Master_payment_schedule__c mpy = new Master_payment_schedule__c ();
        mpy.S_No__c = 1;
        mpy.Status__c = 'Completed';
        mpy.Project__c = project.id;
        mpy.Payment_Plan__c = payplan.Id;
        mpy.Payment_Percent__c = 25;
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
        
        Master_payment_schedule__c mpys = new Master_payment_schedule__c ();
        mpys.Payment_Plan__c = payplan.Id;
        mpys.Name = 'Booking Advance Amount';
        mpys.Status__c = 'Not Started';
        mpys.Project__c = project.id;
        mpys.S_No__c = 3;
        mpys.Payment_Percent__c = 25;
        insert mpys;
        
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
        book1.SLead__c = ld.Id;
        book1.Quote__c = Qt1.Id;
        book1.Project1__c = project.Id;
        book1.Payment_Plan__c = payplan.Id;
        book1.Followup_Date__c = system.today();
        book1.Followup_Subject__c = 'test22';
        book1.Last_Comment__c = 'test22';
        book1.Project__c = 'Veegaland Green Heights';
        book1.Payment_Type__c = 'Custom';
        book1.Sale_Agreement_Completed__c = false;
        book1.Agreement_Amount_Cleared__c ='Received Partial Amount';
        book1.Stage__c ='Token Amount Collection';
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
        insert book1;
        

        
        Payment_schedule__c pys = new Payment_schedule__c();
        pys.Payment_Percent__c=10;
        pys.Payment_Due_Date__c = system.today()+3;
        pys.Booking__c = book1.id;
        pys.Master_Payment_Schedule__c = mpy.Id;
        pys.name ='on booking';
        pys.Interest_Percent__c=25;
        insert pys;
        
        Co_Applicant__c coApplicant = new Co_Applicant__c(Name = 'Co-Applicant 1', Booking__c = book1.Id,Email__c='Testeemail@gmai.com');
        insert coApplicant;
        
        // Create Receipt
        Receipt__c receipt = new Receipt__c(Booking__c = book1.Id,Finance_User__c= owner.Id, Approval_status__c = 'Approved by Finance Team');
        insert receipt;
        Receipt_Line_Item__c receiptLineItem = new Receipt_Line_Item__c(
            Name = 'Receipt Line Item 1',
            Receipt__c = receipt.Id,
            Booking__c = book1.Id,
            Amount__c = 1600000,
            Payment_schedule__c = pys.Id,
            Cheque_no_Transaction_Number__c = '11223555555'
        );
        
        insert receiptLineItem;
        
        Round_Robin__c rrobin = new Round_Robin__c();
        rrobin.Active__c = true;
        rrobin.User__c = owner.Id;
        rrobin.Project__c = project.Id;
        rrobin.Project_Assigned__c = 'Veegaland Green Heights';
        rrobin.Project_Assigned_City__c='Ernakulam';
        insert rrobin;
        
        // Create Round Robin Members
        Round_Robin_Member__c rrMember1 = new Round_Robin_Member__c(
            User__c = owner.Id,
            User_Type__c = 'Sales Executive',
            Round_Robin__c = rrobin.Id,
            Active__c =true
        );
        insert rrMember1;
        
        Round_Robin_Member__c rrMember2 = new Round_Robin_Member__c(
            User__c = owner.Id,
            User_Type__c = 'CRM',
            Round_Robin__c = rrobin.Id,
            Active__c =true
        );
        insert rrMember2;
        
        Round_Robin_Member__c rrMember3 = new Round_Robin_Member__c(
            User__c = owner.Id,
            User_Type__c = 'Finance',
            Round_Robin__c = rrobin.Id,
            Active__c =true
        );
        insert rrMember3;
        
        Round_Robin_Member__c rrMember4 = new Round_Robin_Member__c(
            User__c = owner.Id,
            User_Type__c = 'Legal',
            Round_Robin__c = rrobin.Id,
            Active__c =true
        );
        insert rrMember4;
    }



    @isTest
    static void testBookingTriggerBeforeUpdate() {
        // Fetch a booking record
        Booking__c booking = [SELECT Id, Stage__c, Token_Advance_Amount_Status__c FROM Booking__c LIMIT 1];

        // Change some field values to trigger the update
        booking.Stage__c = 'Sale Deed Registration';

        Test.startTest();
        update booking;
        Test.stopTest();

    }

    @isTest
    static void testBookingTriggerAfterInsert() {
        // Create a new booking record
        List<Project__c> project = [SELECT Id FROM Project__c WHERE Name = 'Veegaland Green Heights' Limit 1];
        List<Quote__c> Quote = [SELECT Id FROM Quote__c Limit 1];
        List<Lead> lead = [SELECT Id FROM Lead Limit 1];
        List<Payment_Plan__c> payplan = [SELECT Id FROM Payment_Plan__c Limit 1];
        List<Block__c> block = [SELECT Id FROM Block__c Limit 1];
        List<user> owner = [SELECT Id FROM user WHERE isActive=true Limit 1];
        List<String> emptyList = new List<String>();
        List<String> emptyList1 = new List<String>();
      
        
        Plot__c unit = new Plot__c();
        unit.Name = '119';
        unit.Status__c = 'Available';
        unit.Project__c = project[0].Id;
        unit.Block__c = 'A4';
        unit.Plot_Type__c = 'Residential';
        unit.Block1__c = block[0].Id;
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
        unit.Covered_Park_Parking__c = 50000;
        unit.Other_Charges__c = 20000;
        unit.Solar_Charges__c = 15000;
        unit.GST1__c = 18;
        unit.Floor__c = '3';
        insert unit;
        
        Booking__c book1 = new Booking__c();
        book1.SLead__c = lead[0].Id;
        book1.Quote__c = Quote[0].Id;
        book1.Payment_Plan__c = payplan[0].Id;
        book1.Followup_Date__c = system.today();
        book1.Followup_Subject__c = 'test22';
        book1.Last_Comment__c = 'test22';
        book1.Project__c = 'Veegaland Green Heights';
        book1.Project1__c = project[0].Id;
        book1.Payment_Type__c = 'Custom';
        book1.Sale_Agreement_Completed__c = false;
        book1.Agreement_Amount_Cleared__c ='Received Partial Amount';
        book1.Stage__c ='Welcome Email';
        book1.Demand_Number__c = '12345'; 
        book1.Date_of_Booking__c = System.today(); 
        book1.Mode_Of_Payment__c = 'Credit Card';
        book1.Funding_Type__c = 'Loan';
        book1.Plot__c = unit.Id;
        book1.Loan_Sanction_Confirmed__c = true;
        book1.Loan_Sanctioned_Amount__c = 10000;
        book1.Finance_User__c = owner[0].Id;
        book1.First_Applicant_Name__c = 'Akhil';
        book1.OwnerId = owner[0].Id;
        book1.Email1__c = 'Test@gamil.com';
        book1.Booking_Amount1__c = 120000;
        book1.Advance_Branch__c = 'PPNS';
        book1.Advance_Payment_Bank__c = 'HDFC Bank';
        book1.Advance_Payment_From__c = 'Bank';
        book1.Cheque_DD_NEFT_RTGS_No__c = 'DCF26977389';
        book1.Advance_Transaction_Date__c = system.Today();


        Test.startTest();
        insert book1;
        Test.stopTest();

    }

    @isTest
    static void testBookingTriggerAfterUpdate() {
        // Fetch a booking record
        Booking__c booking = [SELECT Id, Stage__c, Finance_User__c, Token_Advance_Amount_Status__c FROM Booking__c  LIMIT 1];
        Id bookingId = booking.Id;

        // Modify the booking stage
        booking.Stage__c = 'Token Amount Collection';
        booking.Sale_Agreement_Uploaded__c = true;
        booking.Agreement_Uploads_Successful__c = true;
        Payment_schedule__c Payment = [SELECT Id FROM Payment_schedule__c WHERE Booking__c =:booking.Id AND S_No__c = 1  LIMIT 1];
        
        Receipt__c receipt = new Receipt__c(Booking__c = booking.Id,Finance_User__c= booking.Finance_User__c, Approval_status__c = 'Approved by Finance Team');
        insert receipt;
        Receipt_Line_Item__c receiptLineItem = new Receipt_Line_Item__c(
            Name = 'Advance booking amount',
            Receipt__c = receipt.Id,
            Booking__c = booking.Id,
            Amount__c = 1600000,
            Payment_schedule__c = Payment.Id,
            Cheque_no_Transaction_Number__c = '11223555555'
        );
        
        insert receiptLineItem;
        
        Test.startTest();
        update booking;
        booking.Stage__c = 'Welcome Email';
        update booking;
        
        booking.Stage__c = 'Advance Amount Collection';
        update booking;
        
        booking.Stage__c = 'Draft Agreement Preparation';
        booking.Agreement_Approval_Status__c = 'Approved';
        
        
        booking.Final_Draft_Agreement_Mail_Send__c = true;
        update booking;
        
       
        booking.Stage__c = 'Demands & Collection';
        booking.Registration_Statutory_Charges_cleared__c = true;
        booking.All_Payment_Cleared__c = true;
        update booking;
        
        booking.Stage__c = 'Sale Deed Registration';
        booking.Registration_Done__c = true;
        booking.Sale_Deed_Registration_Status__c = 'Completed' ;
        update booking;
        
        booking.Name_Board_Selected__c = true;
        update booking;
        
        booking.Cancellation_Status__c = 'Rejected';
        update booking;
        
        booking.Stage__c = 'Handover';
        booking.Unit_Swap_Requested__c = true;
        update booking;
        
        booking.Swap_Unit_Status__c = 'Approved';
        update booking;
        
        booking.Stage__c ='Cancellation';
        booking.Swap_Unit_Status__c = '';
        update booking;
        
        Test.stopTest();
         list<Id> bookingIds = new list<Id> ();
        bookingIds.add(booking.Id);
       BookingController.bookingRecordShare(bookingIds);
    }

    @isTest
    static void testCustomNotificationAfterBookingUpdate() {
        // Fetch a booking record
        Booking__c booking = [SELECT Id, Stage__c, Cancellation_Status__c FROM Booking__c LIMIT 1];
        Id bookingId = booking.Id;

        // Change Cancellation_Status to trigger the custom notification
        booking.Cancellation_Status__c = 'Approved';

        Test.startTest();
        update booking;
        Test.stopTest();

    }
     @isTest
    static void testBookingTriggerAfterUpdate1() {
        // Fetch a booking record
        Booking__c booking = [SELECT Id, Stage__c, Finance_User__c, Token_Advance_Amount_Status__c FROM Booking__c  LIMIT 1];
        Id bookingId = booking.Id;

        // Modify the booking stage
        booking.Stage__c = 'Token Amount Collection';
        booking.Sale_Agreement_Uploaded__c = true;
        booking.Agreement_Uploads_Successful__c = true;
        Payment_schedule__c Payment = [SELECT Id FROM Payment_schedule__c WHERE Booking__c =:booking.Id AND S_No__c = 1  LIMIT 1];
        
        Receipt__c receipt = new Receipt__c(Booking__c = booking.Id,Finance_User__c= booking.Finance_User__c, Approval_status__c = 'Approved by Finance Team');
        insert receipt;
        Receipt_Line_Item__c receiptLineItem = new Receipt_Line_Item__c(
            Name = 'Advance booking amount',
            Receipt__c = receipt.Id,
            Booking__c = booking.Id,
            Amount__c = 1600000,
            Payment_schedule__c = Payment.Id,
            Cheque_no_Transaction_Number__c = '11223555555'
        );
        
        insert receiptLineItem;
         booking.Stage__c = 'Draft Agreement Preparation';
        booking.Agreement_Appointment_Date__c = system.today().addDays(10);
        update booking;
        
         booking.Stage__c = 'Draft Agreement Preparation';
        booking.Final_Sale_Deed_Send_to_Customer__c = true;
        booking.Draft_Agreement_Uploaded__c = true;
        update booking;
        
        booking.Sale_deed_Approval_Status__c = 'Rejected';
        update booking;
        
        booking.Agreement_Appointment_Date__c = system.today();
        update booking;
        
        booking.Stage__c = 'Sale Agreement Registration';
        booking.Registration_Status__c = 'Executed';
        update booking;
        
        booking.Stage__c = 'Sale Agreement Registration';
        booking.Registration_Status__c = 'Scheduled';
        booking.Agreement_Status__c = 'Shared with Customer';
        update booking;
        
        booking.Stage__c = 'Sale Agreement Registration';
        booking.Registration_Status__c = 'Cancelled';
        booking.Agreement_Status__c = 'Shared with Customer';
        update booking;
        
         booking.Stage__c = 'Sale Agreement Registration';
        booking.Registration_Status__c = 'Executed';
        booking.Agreement_Status__c = 'Shared with Customer';
        update booking;
        
        booking.Agreement_Approval_Status__c = 'Rejected';
        booking.Stage__c = 'Demands & Collection';
        update booking;

    }
    
}