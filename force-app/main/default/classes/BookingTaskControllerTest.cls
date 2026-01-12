@isTest
public class BookingTaskControllerTest {
    @isTest
    
    public static void bookingTask(){
        // creating booking
        Booking__c bk = new Booking__c();
        insert bk;
        
        
        BookingTaskController.createFollowUpTask(bk.Id);
        BookingTaskController.createLogInteractionTask(bk.Id);
        BookingTaskController.createFollowUpForIncompleteResponse(bk.Id);
        BookingTaskController.createPaymentFollowUpTask(bk.Id);
        BookingTaskController.createCarParkingEmailTask(bk.Id);
        
    }
    
}