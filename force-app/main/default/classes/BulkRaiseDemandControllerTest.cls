@IsTest
public class BulkRaiseDemandControllerTest {

    @TestSetup
    static void setup() {
        // Setup the test data
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

        // Create Project
        Project__c project = new Project__c();
        project.Name = 'Veegaland Green Heights';
        project.Project_Type__c = 'Apartments';
        project.Finance_User__c = owner.Id;
        project.CRM_Manager__c = owner.Id;
        project.Legal_User__c = owner.Id;
        project.Legal_User2__c = owner.Id;
        insert project;

        // Create Leads
        Lead ld = new Lead(LastName = 'test', Company = 'testCompany', phone = '9876543459', LeadSource = '99 acres', Project_City__c = 'Ernakulam', Email = 'test@gmail.com', Secondary_Email__c = 'test2@gmail.com', OwnerId = owner.Id);
        insert ld;

        Lead ld1 = new Lead(LastName = 'test', Company = 'testCompanyxx', phone = '9876543457', LeadSource = '99 acres', Project_City__c = 'Ernakulam', Email = 'test1234@gmail.com', Secondary_Email__c = 'test2343@gmail.com', OwnerId = owner.Id);
        insert ld1;

        // Create Payment Plan
        Payment_Plan__c payplan = new Payment_Plan__c();
        payplan.Active__c = true;
        payplan.Project__c = project.Id;
        insert payplan;

        // Create Master Payment Schedules
        Master_payment_schedule__c mpy = new Master_payment_schedule__c(S_No__c = 1, Status__c = 'Completed', Project__c = project.Id, Payment_Plan__c = payplan.Id, Payment_Percent__c = 50);
        insert mpy;

        Master_payment_schedule__c mpy1 = new Master_payment_schedule__c(S_No__c = 2, Status__c = 'Completed', Project__c = project.Id, Payment_Plan__c = payplan.Id, Payment_Percent__c = 50);
        insert mpy1;

        // Create Block and Plot
        Block__c block = new Block__c(Name = 'A', Project__c = project.Id);
        insert block;

        Plot__c unit1 = new Plot__c(Name = '105', Status__c = 'Available', Project__c = project.Id, Block__c = 'A4', Plot_Type__c = 'Residential', Block1__c = block.Id, Carpet_Area__c = 850, Premium_Status__c = 'Premium', Floor__c = '1');
        insert unit1;

        // Create Quote
        Quote__c Qt1 = new Quote__c(Discount_In_Rupees__c = 100, Leads__c = ld.Id, Project__c = 'Veegaland Green Heights', Unit__c = unit1.Id, Car_Parking_Charge__c = 70, Extra_car_parking_charges__c = 10, Floor_Rise_Charges__c = 10, Built_up_area__c = 2000);
        insert Qt1;

        // Create Booking
        Booking__c book1 = new Booking__c(
            SLead__c = ld1.Id,
            Payment_Plan__c = payplan.Id,
            Followup_Date__c = System.today(),
            Followup_Subject__c = 'test22',
            Last_Comment__c = 'test22',
            Project__c = 'Veegaland Green Heights',
            Payment_Type__c = 'Custom',
            Sale_Agreement_Completed__c = false,
            Agreement_Amount_Cleared__c = 'Received Partial Amount',
            Stage__c = 'Welcome Email',
            Demand_Number__c = '12345',
            Date_of_Booking__c = System.today(),
            Mode_Of_Payment__c = 'Credit Card',
            Funding_Type__c = 'Own Funds',
            Plot__c = unit1.Id,
            Loan_Sanction_Confirmed__c = true,
            Loan_Sanctioned_Amount__c = 10000,
            Finance_User__c = owner.Id,
            Sales_Manager1__c = owner.Id,
            Sales_Executive__c = owner.Id,
            Legal_Team__c = owner.Id,
            CRM_Manager__c = owner.Id,
            First_Applicant_Name__c = 'Akhil',
            Legal_Advocate_Assigned__c = owner.Id,
            Email1__c = 'Test@gamil.com',
            Project1__c=project.Id,
            GST__c = 5
        );
        insert book1;
        
        Payment_schedule__c pay = new Payment_schedule__c();
        pay.Booking__c = book1.id;
        pay.Payment_percent__c = 20;
        pay.Master_Payment_Schedule__c = mpy.Id;
        pay.Amount__c = 10000;
        pay.S_No__c = 1;
        pay.name = 'Test';
        insert pay;
        
        Payment_schedule__c pay1 = new Payment_schedule__c();
        pay1.Booking__c = book1.id;
        pay1.Payment_percent__c = 20;
        pay1.Master_Payment_Schedule__c = mpy1.Id;
        pay1.Amount__c = 10000;
        pay1.S_No__c = 2;
        pay1.name = 'Test';
        insert pay1;
    }

    @IsTest
    static void testGetBookingRecords() {
        // Set up mock data
        Master_payment_schedule__c masterPaymentSchedule = [SELECT Id FROM Master_payment_schedule__c LIMIT 1];

        // Test the getBookingRecords method
        Test.startTest();
        List<BulkRaiseDemandController.BookingWrapper> bookingWrappers = BulkRaiseDemandController.getBookingRecords(masterPaymentSchedule.Id);
        Test.stopTest();

        // Assert that results are returned
        System.assertNotEquals(0, bookingWrappers.size(), 'No booking records found');
    }

    @IsTest
    static void testGetBookingRecordsWithProject() {
        // Set up mock data
        Master_payment_schedule__c masterPaymentSchedule = [SELECT Id FROM Master_payment_schedule__c LIMIT 1];

        // Test the getBookingRecordsWithProject method
        Test.startTest();
        List<BulkRaiseDemandController.BookingWrapper> bookingWrappersWithProject = BulkRaiseDemandController.getBookingRecordsWithProject(masterPaymentSchedule.Id);
        Test.stopTest();

        // Assert that results are returned
        System.assertNotEquals(0, bookingWrappersWithProject.size(), 'No booking records with project found');
    }

    @IsTest
    static void testGetBlocks() {
        // Create and insert Master_Payment_Schedule record for block retrieval
        Project__c project = [select id from Project__c where name ='Veegaland Green Heights'];
        Master_payment_schedule__c masterPaymentSchedule = new Master_payment_schedule__c(
            Name = 'Test Master Payment Schedule for Blocks',
            Project__c = project.Id,
            S_No__c = 1
        );
        insert masterPaymentSchedule;

        // Test the getBlocks method
        Test.startTest();
        List<Block__c> blocks = BulkRaiseDemandController.getBlocks(masterPaymentSchedule.Id);
        Test.stopTest();

    }

    @IsTest
    static void testUpdatePaymentSchedules() {
        List<Payment_Plan__c> payplan = [SELECT Id FROM Payment_Plan__c LIMIT 1];
        List<Booking__c> bookings = [SELECT Id,Debit_Amount__c,Project1__c,Total_Interest_Waive_Off__c,GST__c,Plot__c,Plot__r.Name,Plot__r.Block__c,Plot__r.Block1__r.Name,Project1__r.Name,Lead__c FROM Booking__c LIMIT 1];
        Project__c project = [select id from Project__c where name ='Veegaland Green Heights'];
        // Set up test data
        Master_payment_schedule__c masterPaymentSchedule = new Master_payment_schedule__c(
            Payment_Plan__c = payplan[0].Id,
            Name = 'Test Master Payment Schedule for Calculation',
            Project__c = project.Id,
            S_No__c = 1
        );
        insert masterPaymentSchedule;
        // Create and insert a payment schedule record
        payment_schedule__c paySchedule = new payment_schedule__c(
            Name = 'Test Payment Schedule',
            Amount__c = 10000,
            Is_Demanded__c = false,
            Master_Payment_Schedule__c = masterPaymentSchedule.Id, // Replace with actual Id
            Booking__c = bookings[0].Id, // Replace with actual Booking Id
            Status__c = 'Scheduled'
        );
        insert paySchedule;

        // Test the updatePaymentSchedules method
        Test.startTest();
        BulkRaiseDemandController.updatePaymentSchedules(paySchedule.Id);
        Test.stopTest();

    }

    @IsTest
    static void testBookingScheduleCalculations() {
        List<Payment_Plan__c> payplan = [SELECT Id FROM Payment_Plan__c LIMIT 1];
        Project__c project = [select id from Project__c where name ='Veegaland Green Heights'];
        // Set up test data
        Master_payment_schedule__c masterPaymentSchedule = new Master_payment_schedule__c(
            Payment_Plan__c = payplan[0].Id,
            Name = 'Test Master Payment Schedule for Calculation',
            Project__c = project.Id,
            S_No__c = 1
        );
        insert masterPaymentSchedule;

        List<Booking__c> bookings = [SELECT Id,Debit_Amount__c,Tower__c,Project1__c,Total_Interest_Waive_Off__c,GST__c,Plot__c,Plot__r.Name,Plot__r.Block__c,Plot__r.Block1__r.Name,Project1__r.Name,Lead__c FROM Booking__c LIMIT 1];
        map<Id, payment_schedule__c> bookingPaymentMap = new Map<Id, payment_schedule__c>();

        // Add a sample payment schedule record to the map
        payment_schedule__c paySchedule = new payment_schedule__c(
            Master_Payment_Schedule__c = masterPaymentSchedule.Id,
            Amount__c = 10000,
            Booking__c = bookings[0].Id,
            Status__c = 'Completed',
            Payment_percent__c = 50
        );
        insert paySchedule;
        bookingPaymentMap.put(bookings[0].Id, paySchedule);

        // Test the bookingScheduleCalculations method
        Test.startTest();
        List<BulkRaiseDemandController.BookingWrapper> result = BulkRaiseDemandController.bookingScheduleCalculations(bookings, bookingPaymentMap, masterPaymentSchedule);
        Test.stopTest();

    }

    @IsTest
    static void testBookingScheduleProjectCalculations() {
        // Set up test data
        List<Payment_Plan__c> payplan = [SELECT Id FROM Payment_Plan__c LIMIT 1];
        Project__c project = [select id from Project__c where name ='Veegaland Green Heights'];
        Master_payment_schedule__c masterPaymentSchedule = new Master_payment_schedule__c(
            Payment_Plan__c = payplan[0].Id,
            Name = 'Test Master Payment Schedule for Project Calculations',
            Project__c = project.Id,
            S_No__c = 1
        );
        insert masterPaymentSchedule;

        List<Booking__c> bookings = [SELECT Id,Debit_Amount__c,Project1__c,Total_Interest_Waive_Off__c,GST__c,Plot__c,Plot__r.Name,Plot__r.Block__c,Plot__r.Block1__r.Name,Project1__r.Name,Lead__c FROM Booking__c LIMIT 1];
        map<Id, payment_schedule__c> bookingPaymentMap = new Map<Id, payment_schedule__c>();

        // Add a sample payment schedule record to the map
        payment_schedule__c paySchedule = new payment_schedule__c(
            Master_Payment_Schedule__c = masterPaymentSchedule.Id,
            Amount__c = 10000,
            Booking__c = bookings[0].Id,
            Status__c = 'Completed',
            Payment_percent__c = 50
        );
        insert paySchedule;
        bookingPaymentMap.put(bookings[0].Id, paySchedule);

        // Test the bookingScheduleProjectCalculations method
        Test.startTest();
        List<BulkRaiseDemandController.BookingWrapper> result = BulkRaiseDemandController.bookingScheduleProjectCalculations(bookings, bookingPaymentMap, masterPaymentSchedule);
        Test.stopTest();
    }
}