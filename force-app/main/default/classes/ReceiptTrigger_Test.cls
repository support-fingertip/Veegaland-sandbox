@isTest
public class ReceiptTrigger_Test {
    @isTest
    public static void testReceiptTrigger(){
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

           
        Project__c project = new  Project__c();
        project.Name = 'Veegaland Green Heights';
        project.Project_Type__c ='Villas';
        project.Company__c='Veegaland Homes';
        project.Finance_User__c = owner.Id;
        insert project;
        
        Payment_Plan__c payplan = new Payment_Plan__c();
        payplan.Active__c = true;
        payplan.Project__c = project.Id;
        payplan.Disable_Merge__c = true;
        insert payplan;
        
        Master_payment_schedule__c mpys = new Master_payment_schedule__c ();
        mpys.Payment_Plan__c = payplan.Id;
        mpys.Name = 'Booking Advance Amount';
        mpys.Status__c = 'Not Started';
        // mpys.Project__c = project.id;
        mpys.S_No__c = 3;
        mpys.Payment_Percent__c = 25;
        insert mpys;
        
        
        Booking__c book1 = new Booking__c();
        // book.SLead__c = ld.Id;
        // book.Quote__c = Qt1.Id;
        //  book.Project1__c = project.Id;
        // book1.Payment_Plan__c = payplan.Id;
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
        // book1.Plot__c = unit1.Id;
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
        
         Booking__c book = new Booking__c();
        // book.SLead__c = ld.Id;
        // book.Quote__c = Qt1.Id;
        //  book.Project1__c = project.Id;
        // book1.Payment_Plan__c = payplan.Id;
        book.Followup_Date__c = system.today();
        book.Followup_Subject__c = 'test22';
        book.Last_Comment__c = 'test22';
        book.Project__c = 'Veegaland Green Heights';
        book.Payment_Type__c = 'Custom';
        book.Sale_Agreement_Completed__c = false;
        book.Agreement_Amount_Cleared__c ='Received Partial Amount';
        book.Stage__c ='Token Amount Collection';
        book.Demand_Number__c = '12345'; 
        book.Date_of_Booking__c = System.today(); 
        book.Mode_Of_Payment__c = 'Credit Card';
        book.Funding_Type__c = 'Loan';
        // book1.Plot__c = unit1.Id;
        book.Loan_Sanction_Confirmed__c = true;
        book.Loan_Sanctioned_Amount__c = 10000;
        book.Finance_User__c = owner.Id;
        book.Sales_Manager1__c = owner.Id;
        book.Sales_Executive__c =owner.Id;
        book.Legal_Team__c = owner.Id;
        book.CRM_Manager__c=owner.Id;
        book.First_Applicant_Name__c = 'Akhil';
        book.Legal_Advocate_Assigned__c = owner.Id;
        book.Email1__c = 'Test@gamil.com';
        insert book;
        
        Payment_schedule__c pys = new Payment_schedule__c(
        Payment_Percent__c=10,
        Payment_Due_Date__c = system.today()+3,
        Booking__c = book.id,
        Master_Payment_Schedule__c = mpys.Id,
        name ='on First Schedule',
        Interest_Percent__c=50,
        Demand_Date__c = Date.Today()
        );
        insert pys;
        
        Payment_schedule__c pys1 = new Payment_schedule__c(
            Payment_Percent__c=10,
            Payment_Due_Date__c = system.today()+3,
            Booking__c = book.id,
            Master_Payment_Schedule__c = mpys.Id,
            name ='on Second Schedule',
            Interest_Percent__c=50,
            Demand_Date__c = Date.Today()
        );
        insert pys1;
        
        Payment_schedule__c pys11 = new Payment_schedule__c(
        Payment_Percent__c=10,
        Payment_Due_Date__c = system.today()+3,
        Booking__c = book1.id,
        Master_Payment_Schedule__c = mpys.Id,
        name ='on First Schedule',
        Interest_Percent__c=50,
        Demand_Date__c = Date.Today()
        );
        insert pys11;
        
        Payment_schedule__c pys12 = new Payment_schedule__c(
            Payment_Percent__c=10,
            Payment_Due_Date__c = system.today()+3,
            Booking__c = book1.id,
            Master_Payment_Schedule__c = mpys.Id,
            name ='on Second Schedule',
            Interest_Percent__c=50,
            Demand_Date__c = Date.Today()
        );
        insert pys12;
        
        List<Receipt__c> rclist = new List<Receipt__c>();
        //Receipt
        Receipt__c rc = new Receipt__c(
            
            Receipt_date__c = Date.Today(),
            Instrument_N__c = 'sdfsdfsd',
            Booking__c = book1.Id,
            Finance_User__c = owner.Id,
            
            Payment_From__c = 'Advance Receipt'
            
        );
        insert rc;
        rclist.add(rc);
        Receipt__c rc1 = new Receipt__c(
            
            Receipt_date__c = Date.Today(),
            Instrument_N__c = 'sdfsdfsd',
            Booking__c = book.Id,
            Finance_User__c = owner.Id,
            
            Payment_From__c = 'Bank'
            
        );
        insert rc1;
        rclist.add(rc1);
        rclist.sort(new ReceiptDateComparator());
        
        rc1.Approval_status__c = 'Approved by Finance Team';
        update rc1;
        
        rc1.Approval_status__c = 'Rejected by Finance Team';
        update rc1;
        
        
    }
    
    
    
    
}