@isTest
public class PaymentScheduleBatchTest {
    @isTest
    public static void paymentScheBatch(){
        
        
        
        Project__c project = new  Project__c();
        project.Name = 'Veegaland Green Heights';
        project.Project_Type__c='Apartments';
        // project.Finance_User__c = owner.Id;
        // project.CRM_Manager__c =  owner.Id;
        // project.Legal_User__c = owner.Id;
        // project.Legal_User2__c = owner.Id;
        insert project;
        
        Booking__c book = new Booking__c();
        // book.SLead__c = ld.Id;
        //        book.Quote__c = Qt.Id;
        // book.Payment_Plan__c = payplan.Id;
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
        // book.Plot__c = unit.Id;
        book.Loan_Sanction_Confirmed__c = true;
        book.Loan_Sanctioned_Amount__c = 10000;
        // book.Sales_Manager1__c = owner.Id;
        // book.Sales_Executive__c = owner.Id;
        // book.Finance_User__c = owner.Id;
        book.First_Applicant_Name__c = 'Akhil';
        // book.CRM_Manager__c=owner.Id;
        // book.Legal_Team__c = owner.Id;
        // book.Legal_Advocate_Assigned__c = owner.Id;
        book.Email1__c = 'Test@gamil.com';
        insert book;
        
        Master_payment_schedule__c mpys = new Master_payment_schedule__c ();
        // mpys.Payment_Plan__c = payplan.Id;
        mpys.Name = 'Booking Advance Amount';
        mpys.Status__c = 'Not Started';
        mpys.Project__c = project.id;
        mpys.S_No__c = 3;
        mpys.Payment_Percent__c = 25;
        insert mpys;
        
        
        
        Payment_schedule__c pys = new Payment_schedule__c();
        pys.Payment_Percent__c=10;
        pys.Payment_Due_Date__c = system.today()+3;
        pys.Booking__c = book.id;
        pys.Master_Payment_Schedule__c = mpys.Id;
        pys.name ='on booking';
        pys.Interest_Percent__c=25;
        pys.Include_Interest__c = true;
        insert pys;
        
        Set<Id> projIds = new Set<Id>{ project.Id };
        
        test.startTest();
        PaymentScheduleBatch batch = new PaymentScheduleBatch(projIds);
        Database.executeBatch(batch);
        test.StopTest();
        
    }
    
}