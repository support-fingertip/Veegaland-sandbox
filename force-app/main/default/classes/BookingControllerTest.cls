@isTest
public class BookingControllerTest {
    @testSetup
    static void setup() {
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
        book.Booking_Amount1__c = 30000;
        book.GST__c = 5;
        insert book;
        
         Co_Applicant__c co = new Co_Applicant__c(
            Name = 'Test CoApp',
            Booking__c = book.Id,
            Correspondence_Country__c = 'India',
             Quote__c = Qt.Id
        );
        insert co;
        
        
        Booking__c book1 = new Booking__c();
        book1.SLead__c = ld1.Id;
        book1.Payment_Plan__c = payplan.Id;
        book1.Followup_Date__c = system.today();
        book1.Followup_Subject__c = 'test22';
        book1.Last_Comment__c = 'test22';
        book1.Project__c = 'Veegaland Green Heights';
        book1.Payment_Type__c = 'Custom';
        book1.Sale_Agreement_Completed__c = false;
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
        book1.Project1__c = project.id;
        book1.TPA_Agreement_Date__c = Date.newInstance(2023, 7, 1);
        book1.Mobile_Primary__c = '7867564534';
        book1.GST__c = 5;
        insert book1;
        
        // Co_Applicant__c co1 = new Co_Applicant__c(
         //   Name = 'Test CoApp',
//            Booking__c = book1.Id,
         //   Correspondence_Country__c = 'India'
      //  );
      //  insert co1;
        
        
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
    
    public static testmethod void bookingController(){
        
       
        // Fetch the inserted bookings
        List<Booking__c> newBookings = [SELECT Id, Project1__c, Email1__c,SLead__c, Sales_Executive__c,Booking_Amount1__c, CRM_Manager__c, Finance_User__c, Mode_Of_Payment__c, Advance_Transaction_Date__c,
                                        Cheque_DD_NEFT_RTGS_No__c,Advance_Payment_From__c, Advance_Payment_Bank__c, Advance_Branch__c
                                        FROM Booking__c 
                                        WHERE Sales_Executive__r.isActive = true];
       
        Quote__c Qt =[Select Id,  Project__c , Unit__c From Quote__c Limit 1];
            Set<id> bookingIds = new Set<id>();
        list<id> bookingListIds = new list<id>();
        for (Booking__c booking : newBookings) {
            bookingIds.add(booking.Id);
            bookingListIds.add(booking.Id);
        }
        newBookings[0].Stage__c = 'Token Amount Collection';
        update newBookings[0];
        BookingController.completeOrCreateTokenAdvanceFollowUps(bookingIds);
        
        // Call the method to test
        Test.startTest();
        BookingController.bookingAmountReceipt(newBookings);
        BookingController.assignUsersByRoundRobin(newBookings);
        BookingController.getBookingPicklists();
        BookingController.updatePlotStatusToSold(bookingIds);
        BookingController.welcomeTaskCompletion(bookingIds);
        BookingController.createWelcomeTask(bookingIds);
        //BookingController.testcover();
       //BookingController.custmerMasterallocation(newBookings);
        
        BookingController.bookingRecordShare(bookingListIds);
        
        BookingController.UpdateBookingUsers(newBookings, 'Finance');
        BookingController.UpdateBookingUsers(newBookings, 'Legal');
        BookingController.UpdateBookingUsers(newBookings, 'CRM');
        BookingController.welcomeMailAuraCmp(newBookings[0].Id,'');
        BookingController.fetchQuoteAndCoApplicants(Qt.Id);
       
        Test.stopTest();
        
    }
    public static testmethod void bookingController2(){
        List<Project__c> project = [SELECT Id FROM Project__c Limit 1];
        List<Quote__c> Quote = [SELECT Id FROM Quote__c Limit 1];
        List<Lead> lead = [SELECT Id FROM Lead Limit 1];
        List<Payment_Plan__c> payplan = [SELECT Id FROM Payment_Plan__c Limit 1];
        List<Block__c> block = [SELECT Id FROM Block__c Limit 1];
        List<user> owner = [SELECT Id FROM user WHERE isActive=true Limit 1];
        List<String> emptyList = new List<String>();
        List<String> emptyList1 = new List<String>();
        
        Plot__c unit1 = new Plot__c();
        unit1.Name = '109';
        unit1.Status__c = 'Available';
        unit1.Project__c = project[0].Id;
        unit1.Block__c = 'A4';
        unit1.Plot_Type__c = 'Residential';
        unit1.Block1__c = block[0].Id;
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
        unit1.Covered_Park_Parking__c = 50000;
        unit1.Other_Charges__c = 20000;
        unit1.Solar_Charges__c = 15000;
        unit1.GST1__c = 18;
        unit1.Floor__c = '3';
        insert unit1;
        
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
        book1.Project1__c = project[0].Id;
        book1.GST__c = 5;
        insert book1;
        Test.startTest();
        BookingController.cloneBookingWithUnitChangeDetails(book1, '', 'Token Amount Collection');
        BookingController.getCancellationStatus(book1.Id);
        BookingController.bookingCancellationApproval(book1.Id, 25000, true, true);
        BookingController.getRecordData(book1.Id);
         BookingController.generatePdfAndAttachBooking('FinalBookingForm',Quote[0].Id,book1.Id );
        BookingController.generatePdfAndAttachQuote('FinalBookingForm',Quote[0].Id);
        Test.stopTest();
    }
    
    public static testmethod void bookingController5(){
        List<Project__c> project = [SELECT Id FROM Project__c Limit 1];
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
        unit.Covered_Park_Parking__c = 50000;
        unit.Other_Charges__c = 20000;
        unit.Solar_Charges__c = 15000;
        unit.GST1__c = 18;
        unit.Floor__c = '3';
        insert unit;
        
        Quote__c Qt1 = new Quote__c(     
            Discount_In_Rupees__c = 100,
            Leads__c = lead[0].id,
            Project__c = 'Veegaland Green Heights',
            Unit__c =unit.Id,
            Car_Parking_Charge__c = 70,
            Extra_car_parking_charges__c = 10,
            Floor_Rise_Charges__c = 10,
            Built_up_area__c = 2000
        );
        
        insert Qt1;
        
        Booking__c book1 = new Booking__c();
        book1.SLead__c = lead[0].Id;
        book1.Quote__c = Qt1.Id;
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
        book1.GST__c = 5;
        
        Co_Applicant__c co = new Co_Applicant__c(
            Name = 'Test CoApp',
            Booking__c = book1.Id,
            Correspondence_Country__c = 'India',
             Quote__c = Qt1.Id
        );
        insert co;
        
        Test.startTest();
        BookingController.createBook(book1, Qt1.Id);
        Test.stopTest();
    }
    
    public static testmethod void testSendCustomNotification() {
        // Fetch a recipient user
        User recipientUser = [SELECT Id FROM user WHERE isActive=true Limit 1];
        List<Booking__c> newBookings = [SELECT Id, Project1__c, Email1__c,SLead__c,Unit_NumberFor__c,Project__c,Owner.Name, Sales_Executive__c, CRM_Manager__c FROM Booking__c WHERE CRM_Manager__r.isActive = true];
        Set<id> bookingIds = new Set<id>();
        List<id> bookings = new List<id>();
        List<ContentVersion> cvs = new List<ContentVersion>();
        List<String> contentIds = new List<String>();
        
        for (Booking__c booking : newBookings) {
            bookingIds.add(booking.Id);
            bookings.add(booking.Id);
            
            // Floor Plan
            ContentVersion floorPlanCV = new ContentVersion(
                Title = 'Floor Plan',
                PathOnClient = 'FloorPlan.pdf',
                VersionData = Blob.valueOf('This is a test Floor Plan PDF'), 
                FirstPublishLocationId = booking.Id
            );
            cvs.add(floorPlanCV);
            
            // Plumbing Plan
            ContentVersion plumbingPlanCV = new ContentVersion(
                Title = 'Plumbing Plan',
                PathOnClient = 'PlumbingPlan.pdf',
                VersionData = Blob.valueOf('This is a test Plumbing Plan PDF'), 
                FirstPublishLocationId = booking.Id
            );
            cvs.add(plumbingPlanCV);
            
            // Parking Plan
            ContentVersion parkingPlanCV = new ContentVersion(
                Title = 'Parking Plan',
                PathOnClient = 'ParkingPlan.pdf',
                VersionData = Blob.valueOf('This is a test Parking Plan PDF'),
                FirstPublishLocationId = booking.Id
            );
            cvs.add(parkingPlanCV);
            
            // Electrical Plan
            ContentVersion electricalPlanCV = new ContentVersion(
                Title = 'Electrical Plan',
                PathOnClient = 'ElectricalPlan.pdf',
                VersionData = Blob.valueOf('This is a test Electrical Plan PDF'), 
                FirstPublishLocationId = booking.Id
            );
            cvs.add(electricalPlanCV);
            
            // Sample Sale Agreement
            ContentVersion saleAgreementCV = new ContentVersion(
                Title = 'Sample Sale Agreement',
                PathOnClient = 'SampleSaleAgreement.pdf',
                VersionData = Blob.valueOf('This is a test Sale Agreement PDF'), 
                FirstPublishLocationId = booking.Id
            );
            cvs.add(saleAgreementCV);
            
        }
        insert cvs;
        Set<String> recipientIds = new Set<String>{recipientUser.Id};
            String title = 'Test Notification Title';
        String body = 'Test Notification Body';
        String recId = recipientUser.Id;
        String notificationName = 'Custom_Notification';
        
        Test.startTest();
        BookingController.sendCustomNotification(recipientIds, title, body, recId, notificationName);
        BookingController.sendCarParkingNotification(bookingIds);
        BookingController.agreementDraftStage(bookings);
        BookingController.createTaskForAgreementCost(bookingIds);
        BookingController.createTaskForAppointment(bookingIds);
        BookingController.createTaskForAgreementCompletion(bookingIds);
        BookingController.createTaskForPostAgreement(bookings);
        BookingController.sendNameBoardMail(newBookings[0].Id, 'Hello', contentIds);
        BookingController.getSecondaryApplicantDetails(newBookings[0].Id);
        BookingController.handleTokenAdvanceFollowupTasks(bookings);
        BookingController.completeOrCreateTokenAdvanceFollowUps(bookingIds);
        BookingController.advanceBalanceAmoutFollowup(bookings);
        BookingController.getBookingAndApplicantDetails(newBookings[0].Id);
        BookingController.sendEmailGenerateAgreementdetailsrequest(newBookings[0].Id, 'Hello sendEmailGenerateAgreementdetailsrequest');
        BookingController.agreementDetailsReceivedFlow(bookingIds);
        BookingController.createTaskForTheOverallCheck(bookingIds);
        BookingController.createTaskDraftAgreementSend(bookingIds);
        BookingController.instalmentMail(newBookings);
        BookingController.handleAgreementStatusUpdate(bookingIds);
        BookingController.createFinanceTasksForFullyPaidBookings(bookingIds);
        BookingController.createSaleDeedTasks(bookingIds);
        BookingController.updateBookingDocumentsBulk(new list<id> {newBookings[0].Id});
        BookingController.welcomeMail(bookingIds);
        BookingController.getBookingDetails(newBookings[0].Id);
        BookingController.updateBookingDocuments(newBookings[0].Id);
          BookingController.bypassStagetoDraftAgreement(newBookings[0].Id);
        BookingController.completeOrCreateAdvanceFollowUps(bookingIds);
        BookingController.completeOrCreateTokenAdvanceFollowUps(bookingIds);
        Test.stopTest();
        
    }
    public static testmethod void  testHelperAndFormatWithHyphens() {
        Integer num = 1234556;
        
        Test.startTest();
        
        BookingController.convertToWords(num);
        BookingController.testCover();
        
        Test.stopTest();
        
    }
}