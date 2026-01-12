@isTest
public class AdvanceReceiptControllerTest {
    @isTest
    public static void advance(){
        // creating test data for booking
        Booking__c booking = new Booking__c(
          //salutation_Applicant1__c = 'Mr.',
            First_Applicant_Name__c = 'Test'
        );
        insert booking;
        
        Payment_schedule__c p =  new Payment_schedule__c(
        Booking__c = booking.Id
        );
        insert p;
        
        //create Receipt__c record
       Receipt__c rcp = new Receipt__c(
       Approval_status__c = 'Approved by Finance Team',
           Booking__c = booking.Id

       );
        insert rcp;
        
        //creating Receipt_Line_Item__c record
        Receipt_Line_Item__c rc= new Receipt_Line_Item__c(
        Booking__c = booking.Id,
            Payment_schedule__c = p.Id,
             Receipt__c = rcp.Id  
      //  S_No__c = '1'
            
        
        );
        insert rc;
        
        
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(booking);
        AdvanceReceiptController adv = new  AdvanceReceiptController(stdcontroller);
        
        
        
        
    }
    
    
    
}