@isTest
public class getQuoteDataTest {
    
    @isTest
    public static void getQuote(){
        
        //Creating booking
          Project__c project = new  Project__c();
        project.Name = 'Veegaland Green Heights';
        project.Project_Type__c='Apartments';
        //project.Finance_User__c = owner.Id;
        //project.CRM_Manager__c =  owner.Id;
        //project.Legal_User__c = owner.Id;
        //project.Legal_User2__c = owner.Id;
        insert project;
        
         Booking__c book = new Booking__c();
        //book.SLead__c = ld.Id;
       // book.Quote__c = Qt.Id;
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
        
        //Creating Quote
          Quote__c Qt = new Quote__c(
            Discount_In_Rupees__c = 100,
            //Leads__c = ld1.id,
            Project__c = 'Veegaland Green Heights',
           // Unit__c =unit1.Id,
            Car_Parking_Charge__c = 70,
            Extra_car_parking_charges__c = 10,
            Floor_Rise_Charges__c = 10,
            Built_up_area__c = 2000
        );
        
        insert Qt;
        
         Master_payment_schedule__c mpy = new Master_payment_schedule__c ();
        mpy.S_No__c = 1;
        mpy.Status__c = 'Completed';
        mpy.Project__c = project.id;
      //  mpy.Payment_Plan__c = payplan.Id;
        mpy.Payment_Percent__c = 25;
        insert mpy;
        
         Payment_schedule__c pys = new Payment_schedule__c();
        pys.Payment_Percent__c=10;
        pys.Payment_Due_Date__c = system.today()+3;
        pys.Booking__c = book.id;
        pys.Master_Payment_Schedule__c = mpy .Id;
        pys.name ='on booking';
        pys.Interest_Percent__c=25;
        insert pys;
       // ApexPages.currentPage().getParameters().put('id', qt.Id);
        //ApexPages.StandardController controller = new ApexPages.StandardController(Qt);
        //getQuoteData qQ = getQuoteData(controller);
        ApexPages.currentPage().getParameters().put('id', qt.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(qt);
        getQuoteData q = new getQuoteData(sc);
        
        
    }

}