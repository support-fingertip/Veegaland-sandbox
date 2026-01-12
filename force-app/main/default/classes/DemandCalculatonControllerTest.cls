@isTest
public class DemandCalculatonControllerTest {
    @isTest
    public static void demandCalculation(){
        
        //create booking
         Booking__c book = new Booking__c();
        insert book;
        
        //creating masterpayment schedule
        Master_payment_schedule__c mpy = new Master_payment_schedule__c ();
        mpy.S_No__c = 1;
        mpy.Status__c = 'Completed';
       // mpy.Project__c = project.id;
       // mpy.Payment_Plan__c = payplan.Id;
        mpy.Payment_Percent__c = 25;
        insert mpy;
        
        //creating payment schedule
        Payment_schedule__c pys = new Payment_schedule__c();
        pys.Payment_Percent__c=10;
        pys.Payment_Due_Date__c = system.today()+3;
        pys.Booking__c = book.id;
        pys.Master_Payment_Schedule__c = mpy .Id;
        pys.name ='on booking';
        pys.Interest_Percent__c=25;
        insert pys;
        
        DemandCalculatonController.getRaiseDemandWithBooking(book.Id);
        
        
    }

}