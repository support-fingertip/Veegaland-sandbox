@isTest
public class TaskTrigger_Test {
    
    @isTest static void testTask() {
        
        User person = new User(
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
        insert person;
        
        Project__c project = new  Project__c();
        project.Name = 'Veegaland Green Heights';
        project.Project_Type__c='Apartments';
        project.Finance_User__c = person.Id;
        project.CRM_Manager__c =  person.Id;
        project.Legal_User__c = person.Id;
        project.Legal_User2__c = person.Id;
        insert project;
        
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Company = 'testCompany';
        ld.phone ='9876543459';
        ld.LeadSource = '99 acres';
        ld.Project_City__c = 'Ernakulam';
        ld.Email ='test@gmail.com';
        ld.Secondary_Email__c ='test2@gmail.com';
        ld.OwnerId=person.Id;
        
        insert ld; 
        
        Lead ld1 = new Lead();
        ld1.LastName = 'test';
        ld1.Company = 'testCompanyxx';
        ld1.phone ='9876543457';
        ld1.LeadSource = '99 acres';
        ld1.Project_City__c = 'Ernakulam';
        ld1.Email ='test1234@gmail.com';
        ld1.Secondary_Email__c ='test2343@gmail.com';
        ld1.OwnerId=person.Id;
        
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
        book1.Funding_Type__c = 'Loan';
        book1.Plot__c = unit1.Id;
        book1.Loan_Sanction_Confirmed__c = true;
        book1.Loan_Sanctioned_Amount__c = 10000;
        book1.Finance_User__c = person.Id;
        book1.Sales_Manager1__c = person.Id;
        book1.Sales_Executive__c =person.Id;
        book1.Legal_Team__c = person.Id;
        book1.CRM_Manager__c=person.Id;
        book1.First_Applicant_Name__c = 'Akhil';
        book1.Legal_Advocate_Assigned__c = person.Id;
        book1.Email1__c = 'Test@gamil.com';
        book1.Project1__c = project.Id;
        insert book1;
        
        Payment_schedule__c pay = new Payment_schedule__c();
        pay.Booking__c = book1.id;
        pay.Payment_percent__c = 0;
        pay.Master_Payment_Schedule__c = mpy.Id;
        pay.S_No__c = 1;
        pay.name = 'On Regestration';
        pay.status__c = 'Completed';
        insert pay;
        
        Receipt__c receipt = new Receipt__c(Booking__c = book1.Id,	Finance_User__c=person.Id);
        insert receipt;
        
        Receipt_Line_Item__c receiptLineItem = new Receipt_Line_Item__c(
            Name = 'Receipt Line Item 1',
            Receipt__c = receipt.Id,
            Booking__c = book1.Id,
            Amount__c = 1000000,
            Payment_schedule__c = pay.Id
        );
        
        insert receiptLineItem;
        
        receipt.Approval_status__c = 'Approved by Finance Team';
        update receipt;
            
        // Create test Task for "Token Advance Payment Follow-up"
        Task task1 = new Task(
            Subject = 'Token Advance Payment Follow-up',
            Status = 'Not Started',
            WhatId = book1.Id  // The WhatId will be the Booking__c Id
        );
        insert task1;
        
        // Create test Task for "Welcome Call Follow-up"
        Task task2 = new Task(
            Subject = 'Welcome Call Follow-up',
            Status = 'Not Started',
            WhatId = book1.Id  // The WhatId will be the Booking__c Id
        );
        insert task2;
        
        Task task3 = new Task(
            Subject = 'Car Parking Follow-up',
            Status = 'Not Started',
            WhatId = book1.Id  // The WhatId will be the Booking__c Id
        );
        insert task3;
        
        // Create test Task for "Advance Payment Follow-up"
        Task task4 = new Task(
            Subject = 'Advance Payment Follow-up',
            Status = 'Not Started',
            WhatId = book1.Id  // The WhatId will be the Booking__c Id

        );
        
        Task task5 = new Task(
            Subject = 'Sale Agreement Registration Completion',
            Status = 'Not Started',
            WhatId = book1.Id  // The WhatId will be the Booking__c Id
        );
        insert task5;
        // Create test Task for "Welcome Call Follow-up"
        Task task6 = new Task(
            Subject = 'Please verify the agreement details of primary applicant',
            Status = 'Not Started',
            WhatId = book1.Id  // The WhatId will be the Booking__c Id
        );
        insert task6;
        
        // Update tasks to trigger the "before update" logic in the trigger
        task1.Status = 'Completed';
        task2.Status = 'Completed';
        task3.Status = 'Completed';
        task4.Status = 'Completed';
        task5.Status = 'Completed';
        task6.Status = 'Completed';
        
        update new List<Task>{task1, task2};
            
            }
}