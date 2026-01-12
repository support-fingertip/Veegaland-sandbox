@isTest
public class DemandRaisedTrigger_Test {
    
    @isTest
    public static void demandRaised(){
      //create booking
        List<Booking__c> bookList = new List<Booking__c>();
        Booking__c book = new Booking__c();
       // book.SLead__c = ld.Id;
       // book.Quote__c = Qt1.Id;
       // book.Project1__c = project.Id;
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
        book.Funding_Type__c = 'Own Funds';
       // book1.Plot__c = unit1.Id;
        //book1.Loan_Sanction_Confirmed__c = true;
       // book1.Loan_Sanctioned_Amount__c = 10000;
       // book1.Finance_User__c = owner.Id;
       // book1.Sales_Manager1__c = owner.Id;
       // book1.Sales_Executive__c =owner.Id;
       // book1.Legal_Team__c = owner.Id;
       // book1.CRM_Manager__c=owner.Id;
       // book1.First_Applicant_Name__c = 'Akhil';
       // book1.Legal_Advocate_Assigned__c = owner.Id;
        book.Email1__c = 'Test@gamil.com';
        insert book;
    
     //creating master payment schedule
        Master_payment_schedule__c mpy = new Master_payment_schedule__c ();
        mpy.S_No__c = 1;
        mpy.Status__c = 'Completed';
        //mpy.Project__c = project.id;
        //mpy.Payment_Plan__c = payplan.Id;
        mpy.Payment_Percent__c = 25;
        insert mpy;
        
        
        // creating payment schedule
        Payment_schedule__c pys = new Payment_schedule__c();
        pys.Payment_Percent__c=10;
        pys.Payment_Due_Date__c = system.today()+3;
        pys.Booking__c = book.id;
        pys.Master_Payment_Schedule__c = mpy .Id;
        pys.name ='on booking';
        pys.Interest_Percent__c=25;
        insert pys;
        
        List<Id> idList = new List<Id>();
        // create demand raise
        Demand_Raised__c demand = new Demand_Raised__c(
            Booking__c = book.Id,
            //Demand_Content_Ids__c = cvId,
            Payment_Schedule__c = pys.Id,
            Demanded_Date__c = Date.Today(),
            Demand_Email_Content__c = 'Test'
            
        );
        insert demand;
        }

}