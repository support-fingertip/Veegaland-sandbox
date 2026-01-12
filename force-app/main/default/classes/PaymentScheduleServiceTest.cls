@isTest
    public class PaymentScheduleServiceTest {
        
        @isTest  
        public static void PaymentScheduleTest(){
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
            payplan.Disable_Merge__c = false;
            insert payplan;
            
            List<Master_payment_schedule__c> newMPSchedule = new List<Master_payment_schedule__c>();
            Master_payment_schedule__c mpy1 = new Master_payment_schedule__c (
                S_No__c = 1,
                Payment_Percent__c = 20,
                Project__c = project.id,
                Payment_Plan__c = payplan.Id
            );
            newMPSchedule.add(mpy1);
            
            Master_payment_schedule__c mpy2 = new Master_payment_schedule__c (
                S_No__c = 2,
                Payment_Percent__c = 20,
                Project__c = project.id,
                Payment_Plan__c = payplan.Id,
                Completed_Date__c = Date.newInstance(2025, 7, 22)
            );
            newMPSchedule.add(mpy2);
            
            Master_payment_schedule__c mpy3 = new Master_payment_schedule__c (
                S_No__c = 3,
                Payment_Percent__c = 20,
                Project__c = project.id,
                Payment_Plan__c = payplan.Id,
                Completed_Date__c = Date.newInstance(2025, 8, 22)
            );
            newMPSchedule.add(mpy3);
            
            Master_payment_schedule__c mpy4 = new Master_payment_schedule__c (
                S_No__c = 4,
                Payment_Percent__c = 20,
                Project__c = project.id,
                Payment_Plan__c = payplan.Id,
                Completed_Date__c = Date.newInstance(2025, 9, 22)
            );
            newMPSchedule.add(mpy4);
            
            Master_payment_schedule__c mpy5 = new Master_payment_schedule__c (
                S_No__c = 5,
                Payment_Percent__c = 20,
                Project__c = project.id,
                Payment_Plan__c = payplan.Id,
                Last_Schedule__c = true,
                Completed_Date__c = Date.newInstance(2026, 10, 22)
            );
            newMPSchedule.add(mpy5);
            
            
            Payment_Plan__c payplan1 = new Payment_Plan__c(
                Active__c = true,
                Project__c = project.id,
                Disable_Merge__c = true
            );
            insert payplan1;
            
            Master_payment_schedule__c mpyn1 = new Master_payment_schedule__c (
                S_No__c = 1,
                Payment_Percent__c = 20,
                Project__c = project.id,
                Payment_Plan__c = payplan1.Id
            );
            newMPSchedule.add(mpyn1);
            
            Master_payment_schedule__c mpyn2 = new Master_payment_schedule__c (
                S_No__c = 2,
                Payment_Percent__c = 20,
                Project__c = project.id,
                Payment_Plan__c = payplan1.Id
            );
            newMPSchedule.add(mpyn2);
            
            Master_payment_schedule__c mpyn3 = new Master_payment_schedule__c (
                S_No__c = 3,
                Payment_Percent__c = 20,
                Project__c = project.id,
                Payment_Plan__c = payplan1.Id
            );
            newMPSchedule.add(mpyn3);
            
            Master_payment_schedule__c mpyn5 = new Master_payment_schedule__c (
                S_No__c = 4,
                Payment_Percent__c = 40,
                Project__c = project.id,
                Payment_Plan__c = payplan1.Id,
                Last_Schedule__c = true
            );
            newMPSchedule.add(mpyn5);
            
            insert newMPSchedule;
            
            Block__c block = new Block__c();
            block.Name='A';
            block.Project__c=project.id;
            insert block;
            
            Plot__c unit = new Plot__c();
            unit.Name = '105';
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
            
            Plot__c unit1 = new Plot__c(
                Name = '101',
                Status__c = 'Available',
                Project__c = project.Id,
                Block__c = 'A4',
                Plot_Type__c = 'Residential',
                Block1__c = block.Id,
                Carpet_Area__c = 850,
                Balcony_Sq_mts__c = 20,
                Balcony_Area__c = 100,
                BHK_Type__c = '1 BHK',
                Premium_Status__c = 'Premium',
                Floor__c = '1',
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
                GST1__c = 18
            );
            insert unit1;
            
            
            Quote__c Qt1 = new Quote__c(
                Discount_In_Rupees__c = 100,
                Leads__c = ld1.id,
                Project__c = 'Veegaland Green Heights',
                Unit__c =unit1.Id,
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
                Unit__c =unit.Id,
                Car_Parking_Charge__c = 70,
                Extra_car_parking_charges__c = 10,
                Floor_Rise_Charges__c = 10,
                Built_up_area__c = 2000
            );
            
            insert Qt;
            
            Booking__c book = new Booking__c(
                SLead__c = ld.Id,
                Quote__c = Qt.Id,
                Payment_Plan__c = payplan.Id,
                Followup_Date__c = system.today(),
                Followup_Subject__c = 'test22',
                Last_Comment__c = 'test22',
                Project__c = 'Veegaland Green Heights',
                Payment_Type__c = 'Custom',
                Sale_Agreement_Completed__c = false,
                Agreement_Amount_Cleared__c ='Received Partial Amount',
                Stage__c ='Welcome Email',
                Demand_Number__c = '12345',
                Project1__c = project.Id,
                Date_of_Booking__c = System.today(),
                Mode_Of_Payment__c = 'Credit Card',
                Funding_Type__c = 'Loan',
                Plot__c = unit.Id,
                Loan_Sanction_Confirmed__c = true,
                Loan_Sanctioned_Amount__c = 10000,
                Sales_Manager1__c = owner.Id,
                Sales_Executive__c = owner.Id,
                Finance_User__c = owner.Id,
                First_Applicant_Name__c = 'Akhil',
                CRM_Manager__c=owner.Id,
                Legal_Team__c = owner.Id,
                Legal_Advocate_Assigned__c = owner.Id,
                Email1__c = 'Test@gamil.com',
                Booking_Amount1__c = 30000,
                GST__c = 5
            );
            insert book;
            
            Booking__c book1 = new Booking__c(
                SLead__c = ld.Id,
                Quote__c = Qt1.Id,
                Payment_Plan__c = payplan1.Id,
                Followup_Date__c = system.today(),
                Followup_Subject__c = 'test22',
                Last_Comment__c = 'test22',
                Project__c = 'Veegaland Green Heights',
                Payment_Type__c = 'Custom',
                Sale_Agreement_Completed__c = false,
                Agreement_Amount_Cleared__c ='Received Partial Amount',
                Stage__c ='Welcome Email',
                Demand_Number__c = '12345',
                Project1__c = project.Id,
                Date_of_Booking__c = System.today(),
                Mode_Of_Payment__c = 'Credit Card',
                Funding_Type__c = 'Loan',
                Plot__c = unit1.Id,
                Loan_Sanction_Confirmed__c = true,
                Loan_Sanctioned_Amount__c = 10000,
                Sales_Manager1__c = owner.Id,
                Sales_Executive__c = owner.Id,
                Finance_User__c = owner.Id,
                First_Applicant_Name__c = 'Akhil',
                CRM_Manager__c=owner.Id,
                Legal_Team__c = owner.Id,
                Legal_Advocate_Assigned__c = owner.Id,
                Email1__c = 'Test@gamil.com',
                Booking_Amount1__c = 30000,
                GST__c = 5,
                Merge_Schedules_by_Booking_Date__c = true
            );
            insert book1;
            
            book.GST__c = 4;
            update book;
            
            book.Payment_Plan__c = payplan1.id;
            update book;
            
            PaymentScheduleService.testCover();
            
        }
    }