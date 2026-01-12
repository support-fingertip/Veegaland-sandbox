@isTest
public class PaymentScheduleTabControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create a User (Owner)
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
            isActive = true
        );
        insert owner;
        
        // Create a Project
        Project__c project = new Project__c(
            Name = 'Veegaland Green Heights',
            Project_Type__c = 'Villas',
            Company__c = 'Veegaland Homes',
            Finance_User__c = owner.Id
        );
        insert project;
        
        // Create a Lead
        Lead ld1 = new Lead(
            LastName = 'test',
            Company = 'testCompanyxx',
            Phone = '9876543457',
            LeadSource = '99 acres',
            Project_City__c = 'Ernakulam',
            Email = 'test1234@gmail.com',
            Secondary_Email__c = 'test2343@gmail.com',
            OwnerId = owner.Id
        );
        insert ld1; 
        
        // Create a Payment Plan
        Payment_Plan__c payplan = new Payment_Plan__c(Active__c = true, Project__c = project.id);
        insert payplan;
        
        // Create a Block
        Block__c block = new Block__c(Name='Tower A', Project__c=project.id);
        insert block;
        
        // Create a Plot
        Plot__c unit = new Plot__c(
            Name = '101',
            Status__c = 'Available',
            Project__c = project.Id,
            Block__c = 'A4',
            Plot_Type__c = 'Residential',
            Block1__c = block.Id,
            Carpet_Area__c = 850,
            Balcony_Sq_mts__c = 20,
            Balcony_Area__c = 100,
            BHK_Type__c = '3 BHK',
            Premium_Status__c = 'Premium',
           // Floor__c = '1',
            Share__c = 'MHPL',
            Facing__c = 'EAST',
            Carpet_Sq_mts__c = 80,
            CA__c = 75,
            Built_up_area__c = 1200,
            UDS__c = 300,
            UDS_Sq_mts__c = 50,
            Super_built_up_area__c = 1500,
            Price_Per_Sq_Ft__c = 5000,
            Floor_Rise__c = 200,
            Premium_Charge__c = 100000,
            Covered_Park_Parking__c = 50000,
            Other_Charges__c = 20000,
            Solar_Charges__c = 15000,
            GST1__c = 18,
            Floor__c = '30'
        );
        insert unit;
        
        // Create a Booking
        Booking__c book = new Booking__c(
            SLead__c = ld1.Id,
            Payment_Plan__c = payplan.Id,
            Followup_Date__c = system.today(),
            Project1__c = project.id,
            Followup_Subject__c = 'test22',
            Last_Comment__c = 'test22',
            Project__c = 'Veegaland Green Heights',
            Payment_Type__c = 'Custom',
            Sale_Agreement_Completed__c = false,
            Agreement_Amount_Cleared__c ='Received Partial Amount',
            Stage__c ='Welcome Email',
            Demand_Number__c = '12345', 
            Date_of_Booking__c = System.today(), 
            Mode_Of_Payment__c = 'Credit Card',
            Funding_Type__c = 'Own Funds',
            Plot__c = unit.Id,
            Loan_Sanction_Confirmed__c = true,
            Loan_Sanctioned_Amount__c = 10000,
            Finance_User__c = owner.Id,
            Sales_Manager1__c = owner.Id,
            Sales_Executive__c = owner.Id,
            Legal_Team__c = owner.Id,
            CRM_Manager__c = owner.Id,
            First_Applicant_Name__c = 'Akhil',
            Legal_Advocate_Assigned__c = owner.Id,
            Email1__c = 'Test@gamil.com'
        );
        insert book;

        // Create Payment Schedules
        List<Payment_schedule__c> pylist = new list<Payment_schedule__c>();
        
        Payment_schedule__c pay1 = new Payment_schedule__c(
            Booking__c = book.id,
            Payment_percent__c = 0,
            S_No__c = 1,
            Name = 'On Registration',
            status__c = 'Completed'
        );
        pylist.add(pay1);
        
        Payment_schedule__c pay2 = new Payment_schedule__c(
            Booking__c = book.id,
            Payment_percent__c = 10,
            S_No__c = 2,
            Name = 'On Agreement',
            status__c = 'Completed'
        );
        pylist.add(pay2);
        
        insert pylist;

        // Create Receipt and Receipt Line Item
        Receipt__c receipt = new Receipt__c(Booking__c = book.Id, Finance_User__c = owner.Id);
        insert receipt;
        
        Receipt_Line_Item__c receiptLineItem = new Receipt_Line_Item__c(
            Name = 'Receipt Line Item 1',
            Receipt__c = receipt.Id,
            Booking__c = book.Id,
            Amount__c = 10000,
            Payment_schedule__c = pay1.Id
        );
        insert receiptLineItem;
    }

    @isTest
    static void testGetPaymentScheduleList() {
        Booking__c book = [SELECT Id FROM Booking__c LIMIT 1];
        List<Payment_schedule__c> result = PaymentScheduleTabController.getPaymentScheduleList(book.Id);
    }
    
    @isTest
    static void testFindPaymentSchedules() {
        Booking__c book = [SELECT Id FROM Booking__c LIMIT 1];
        List<Payment_schedule__c> result = PaymentScheduleTabController.findPaymentSchedules('On Agreement', book.Id);        System.assert(result.size() > 0, 'There should be payment schedules matching search criteria');
    }
    
    @isTest
    static void testGetPaymentSchedule() {
        Payment_schedule__c result = PaymentScheduleTabController.getPaymentSchedule();
    }
    
    @isTest
    static void testUpdatePaymentSchedules() {
        Payment_schedule__c ps = [SELECT Id, Name FROM Payment_schedule__c LIMIT 1];
        ps.Name = 'Updated Payment Schedule';
        List<Payment_schedule__c> toUpdate = new List<Payment_schedule__c>{ ps };
        Test.startTest();
        PaymentScheduleTabController.updatepaymentSchedules(toUpdate);
        Test.stopTest();
        ps = [SELECT Name FROM Payment_schedule__c WHERE Id = :ps.Id];
    }
    
    @isTest
    static void testMergeSchedules() {
        List<Payment_schedule__c> schedules = [SELECT Id FROM Payment_schedule__c LIMIT 2];
        List<Id> scheduleIds = new List<Id>();
        for (Payment_schedule__c ps : schedules) {
            scheduleIds.add(ps.Id);
        }
        Test.startTest();
        List<Payment_Schedule__c> result = PaymentScheduleTabController.mergeSchedules(scheduleIds);
        Test.stopTest();
    }
}