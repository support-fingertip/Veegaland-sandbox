@istest
public class Demand_Note_SendControllerTest {
    @isTest
    static void testRaiseDemandController() {
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
        book1.Last_Comment__c = 'test22';
        book1.Project__c = 'Veegaland Green Heights';
        book1.Payment_Type__c = 'Custom';
        book1.Sale_Agreement_Completed__c = false;
        book1.Agreement_Amount_Cleared__c ='Received Partial Amount';
        book1.Stage__c ='Welcome Email';
        book1.Demand_Number__c = '12345'; 
        book1.Date_of_Booking__c = System.today(); 
        book1.Mode_Of_Payment__c = 'Credit Card';
        book1.Funding_Type__c = 'Own Funds';
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
        
        list<Payment_schedule__c> pylist = new list<Payment_schedule__c>();
        
        Payment_schedule__c pay = new Payment_schedule__c();
        pay.Booking__c = book1.id;
        pay.Payment_percent__c = 0;
        pay.Master_Payment_Schedule__c = mpy.Id;
        pay.S_No__c = 1;
        pay.name = 'On Regestration';
        pay.status__c = 'Completed';
        pylist.add(pay);
        
        Payment_schedule__c pay1 = new Payment_schedule__c();
        pay1.Booking__c = book1.id;
        pay1.Payment_percent__c = 10;
        pay1.Master_Payment_Schedule__c = mpy.Id;
        pay1.S_No__c = 2;
        pay1.name = 'On Agreement';
        pylist.add(pay1);
        
        Payment_schedule__c pay3 = new Payment_schedule__c();
        pay3.Booking__c = book1.id;
        pay3.Payment_percent__c = 10;
        pay3.Master_Payment_Schedule__c = mpy.Id;
        pay3.S_No__c = 3;
        pay3.name = 'On Completion of basement';
        pylist.add(pay3);
        
        insert pylist;
        
        Demand_Raised__c re = new Demand_Raised__c();
        
        re.Total_Amount_till_Current_Milestone__c = 50000;
        re.Total_Paid_Till__c = 20000;
        re.Previous_pendings__c = 15000;
        re.Interest_Delay_Till_Previous_Milestone__c = 0;
        re.Total_Interest_Paid__c = 1000;
        re.Current_Demand_amount__c = 100000;
        re.Intrest_Amount__c = 500;
        re.Grand_Total__c = 60000;
        re.Grand_Total_In_Words__c = 'Sixty Thousand';
        re.Current_Milestone__c = 'On Regestration';
        re.Milestone_Completed_Date__c = Date.newInstance(2022, 12, 31);
        re.Milestone_Number__c = '2';
        re.Due_Date__c = System.now().addDays(7);
        re.Current_Milestone_Percentage__c = 50;
        re.Total_Percentage_till_Current_Milestone__c = 60;
        re.TDS_Amount__c = 500;
        re.Booking__c = book1.id;
        re.Total_Flat_Cost__c = 55000;
        re.Finance_User__c = Owner.Id;
        re.Demand_Email_Content__c = 'This is a static email content for the demand.';
        re.Demand_Content_Ids__c = '';
        re.Demanded_Date__c = System.now();
        re.Payment_schedule__c = pay.Id;
        
        insert re;
        
        
        Receipt__c receipt = new Receipt__c(Booking__c = book1.Id,	Finance_User__c=owner.Id);
        insert receipt;
        
        Receipt_Line_Item__c receiptLineItem = new Receipt_Line_Item__c(
            Name = 'Receipt Line Item 1',
            Receipt__c = receipt.Id,
            Booking__c = book1.Id,
            Amount__c = 10000,
            Payment_schedule__c = pay.Id
        );
        
        insert receiptLineItem;
        
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(re);
        Test.setCurrentPageReference(new PageReference('/apex/Demand_Note_Send?id=' + re.Id ));
        Demand_Note_SendController controller = new  Demand_Note_SendController(sc);
        test.stopTest();
    }
}