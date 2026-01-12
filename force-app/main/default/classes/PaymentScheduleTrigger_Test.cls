@isTest
public class PaymentScheduleTrigger_Test {
    @isTest
    
    public static void payment(){
        
        User owner = new User(
            Email = 'owner112@example.com',
            Alias = 'owner',
            LastName='andy',
            ProfileId = UserInfo.getProfileId(),
            Username = 'owner43221163@example.com',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert owner;
        
        
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
        
        Booking__c book = new Booking__c();
        //  book.SLead__c = ld.Id;
        //  book.Quote__c = Qt.Id;
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
        // book.Project1__c = project.Id; 
        book.Date_of_Booking__c = System.today(); 
        book.Mode_Of_Payment__c = 'Credit Card';
        book.Funding_Type__c = 'Own Funds';
        // book.Plot__c = unit.Id;
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
        book.Project1__c = project.Id;
        book.GST__c = 5;
        insert book;

        Payment_schedule__c pys = new Payment_schedule__c();
        pys.Payment_Percent__c=10;
        pys.Payment_Due_Date__c = system.today()+3;
        pys.Booking__c = book.id;
        pys.Master_Payment_Schedule__c = mpys.Id;
        // pys.name ='on booking';
        pys.Interest_Percent__c=25;
        pys.Demand_Date__c = Date.Today();
        
        insert pys;
        
        pys.name ='on booking';
        pys.Include_Interest__c = true;
        pys.Is_Demanded__c= true;
            update pys;
    }
    
}