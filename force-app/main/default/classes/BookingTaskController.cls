public class BookingTaskController {

    
    public static void createFollowUpTask(Id bookingId) {
        Follow_up__c followUpTask = new Follow_up__c(
            Subject__c = 'Please Do Follow-up with customer for balance payment',
            Booking__c = bookingId
        );
        insert followUpTask;
    }

    public static void createLogInteractionTask(Id bookingId) {
        Task logTask = new Task(
            Subject = 'Log interaction and key notes',
            WhatId = bookingId,
            Status = 'Not Started',
            Priority = 'Normal'
        );
        insert logTask;
    }

    public static void createCarParkingEmailTask(Id bookingId) {
        Task parkingTask = new Task(
            Subject = 'Send car parking selection email',
            WhatId = bookingId,
            Status = 'Not Started',
            Priority = 'Normal'
        );
        insert parkingTask;
    }

    public static void createFollowUpForIncompleteResponse(Id bookingId) {
        Task incompleteResponseTask = new Task(
            Subject = 'Follow up on incomplete responses',
            WhatId = bookingId,
            Status = 'Not Started',
            Priority = 'High'
        );
        insert incompleteResponseTask;
    }

    public static void createPaymentFollowUpTask(Id bookingId) {
        Follow_up__c paymentFollowUpTask = new Follow_up__c(
            Subject__c = 'Do Follow-up on unpaid payment',
            Booking__c = bookingId
        );
        insert paymentFollowUpTask;
    }
}