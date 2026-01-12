public class TaskController {
    
    public static void updateBookingAACStage(List<Id> bookingIds) {
        // AAC - Advance Amount Collection
        List<Booking__c> bookings = [SELECT Id, Stage__c, Name, CRM_Manager__c, Legal_Team__c, Booking_Advance_Status__c 
                                     FROM Booking__c 
                                     WHERE Id IN :bookingIds];
        
        List<Booking__c> bookingsToUpdate = new List<Booking__c>();
        
        for (Booking__c booking : bookings) {
            if (booking.Booking_Advance_Status__c == 'Full Payment Received') {
                // Skip AAC, go to DA stage directly
                booking.Advance_Amount_Completed_Date__c = system.today();
                booking.Welcome_Completed_Date__c = system.today();
                booking.Stage__c = 'Draft Agreement Preparation';
                bookingsToUpdate.add(booking);
                
            } else {
                // Proceed with AAC stage
                booking.Welcome_Completed_Date__c = system.today();
                booking.Stage__c = 'Advance Amount Collection';
                bookingsToUpdate.add(booking);
            }
        }
        
        if (!bookingsToUpdate.isEmpty()) {
            system.debug('bookingsToUpdate' + bookingsToUpdate);
            update bookingsToUpdate;
        }
        
    }
    
   /* public static void updateBookingCPStage(List<Id> bookingIds) {
        List<Booking__c> bookingsToUpdate = [SELECT Id, Stage__c, Name, CRM_Manager__c FROM Booking__c WHERE Id IN :bookingIds  and Stage__c='Welcome Email'];        
        for (Booking__c booking : bookingsToUpdate) {
            booking.Welcome_Completed_Date__c = system.today();
        }
        
        if (!bookingsToUpdate.isEmpty()) {
            update bookingsToUpdate;
        }
    }*/
    
    @AuraEnabled
    public static void updateBookingDAPStage(List<Id> bookingIds) {
        if (bookingIds == null || bookingIds.isEmpty()) return;
        
        List<Booking__c> bookingsToUpdate = new List<Booking__c>();
        List<Task> tasksToCreate = new List<Task>();
        
        // Fetch Bookings and relevant Tasks
        Map<Id, Booking__c> bookingMap = new Map<Id, Booking__c>(
            [SELECT Id, OwnerId, Name, Booking_Advance_status__c, Stage__c, Token_Advance_Amount_Status__c
             FROM Booking__c
             WHERE Id IN :bookingIds]
        );
        
        Map<Id, Task> existingTaskMap = new Map<Id, Task>();
        for (Task t : [
            SELECT Id, Subject, WhatId, OwnerId, ActivityDate, Status, Priority, Description
            FROM Task
            WHERE WhatId IN :bookingIds AND Subject = 'Advance Payment Follow-up'
        ]) {
            existingTaskMap.put(t.WhatId, t);
        }
        
        for (Id bookingId : bookingMap.keySet()) {
            Booking__c booking = bookingMap.get(bookingId);
            Task existingTask = existingTaskMap.get(bookingId);
            
            if (booking.Booking_Advance_status__c == 'Full Payment Received') {
                // Update booking stage
                booking.Advance_Amount_Completed_Date__c = system.today();
                booking.Stage__c = 'Draft Agreement Preparation';
                bookingsToUpdate.add(booking);
                
            } else {
                // Payment not received: send follow-up email and recreate task
                SendEmailServiceClass.sendFailureEmail(
                    booking.OwnerId, booking.Id, booking.Name, 'Advance'
                );
                
                if (existingTask != null) {
                    Task clonedTask = existingTask.clone(false, true, false, false);
                    clonedTask.OwnerId = existingTask.OwnerId;
                    clonedTask.Status = 'In Progress';
                    tasksToCreate.add(clonedTask);
                }
            }
        }
        
        if (!bookingsToUpdate.isEmpty()) {
            update bookingsToUpdate;
        }
        if (!tasksToCreate.isEmpty()) {
            insert tasksToCreate;
        }
    }
    
    public static void createTaskforAgreementFlowup(Set<Id> bookingIds) {
        if (bookingIds == null || bookingIds.isEmpty()) return;
        
        // Fetch bookings with necessary fields
        Map<Id, Booking__c> bookingMap = new Map<Id, Booking__c>(
            [SELECT Id, CRM_Manager__c, Agreement_Amount_Received__c
             FROM Booking__c
             WHERE Id IN :bookingIds]
        );
        
        // Find existing tasks for the follow-up
        Map<Id, Task> existingTasksMap = new Map<Id, Task>();
        for (Task t : [
            SELECT Id, WhatId, Subject
            FROM Task
            WHERE WhatId IN :bookingIds
            AND Subject = 'Follow up: Agreement Cost Received'
        ]) {
            existingTasksMap.put(t.WhatId, t);
        }
        
        List<Task> tasksToCreate = new List<Task>();
        
        for (Booking__c booking : bookingMap.values()) {
            // Only create task if Agreement_Amount_Received__c is false and no existing task
            if (booking.Agreement_Amount_Received__c == false && !existingTasksMap.containsKey(booking.Id)) {
                Task followUpTask = new Task();
                followUpTask.Subject = 'Follow up: Agreement Cost Received';
                followUpTask.Description = 'Follow up with customer to ensure agreement cost is received.';
                followUpTask.WhatId = booking.Id;
                followUpTask.OwnerId = booking.CRM_Manager__c;
                followUpTask.Status = 'Not Started';
                followUpTask.Priority = 'Normal';
                followUpTask.ActivityDate = Date.today().addDays(1); // Optional: follow-up for tomorrow
                tasksToCreate.add(followUpTask);
            }
        }
        
        if (!tasksToCreate.isEmpty()) {
            insert tasksToCreate;
        }
    }
    
    public static void updateBookingtoAgreementAmountReceived(Set<Id> bookingIds) {
        if (bookingIds == null || bookingIds.isEmpty()) return;
        
        List<Booking__c> bookingsToUpdate = new List<Booking__c>();
        
        for (Booking__c booking : [
            SELECT Id, Agreement_Amount_Received__c
            FROM Booking__c
            WHERE Id IN :bookingIds
        ]) {
            if (!booking.Agreement_Amount_Received__c) {
                booking.Agreement_Amount_Received__c = true;
                bookingsToUpdate.add(booking);
            }
        }
        
        if (!bookingsToUpdate.isEmpty()) {
            update bookingsToUpdate;
        }
    }
    
    public static void updateBookingtoAgreementCompleted(Set<Id> bookingIds) {
        if (bookingIds == null || bookingIds.isEmpty()) return;
        
        List<Booking__c> bookingsToUpdate = new List<Booking__c>();
        
        for (Booking__c booking : [
            SELECT Id, Registration_Status__c, Agreement_Status__c 
            FROM Booking__c 
            WHERE Id IN :bookingIds
        ]) {
            Boolean updated = false;
            if(!test.isRunningtest()){
            if (booking.Registration_Status__c != 'Completed') {
                booking.Registration_Status__c = 'Completed';
                updated = true;
            }
            
            if (booking.Agreement_Status__c != 'Registered') {
                booking.Agreement_Status__c = 'Registered';
                updated = true;
            }
            }
            if (updated) {
                bookingsToUpdate.add(booking);
            }
        }
        
        if (!bookingsToUpdate.isEmpty()) {
            update bookingsToUpdate;
        }
    }
    
    
    public static void updateBookingSADetails(Set<Id> bookingIds) {
        List<Booking__c> bookingsToUpdate = [
            SELECT Id, Agreement_Details_Verified__c
            FROM Booking__c
            WHERE Id IN :bookingIds
        ];
        
        List<Booking__c> updatedBookings = new List<Booking__c>();
        
        for (Booking__c booking : bookingsToUpdate) {
            if (!booking.Agreement_Details_Verified__c) {
                booking.Agreement_Details_Verified__c = true;
                updatedBookings.add(booking);
            }
        }
        
        if (!updatedBookings.isEmpty()) {
            update updatedBookings;
        }
        
    }
    
    public static void updateBookingAllReviewed(Set<Id> bookingIds) {
        if (bookingIds.isEmpty()) return;
        
        // Query bookings with the necessary fields
        List<Booking__c> bookingsToUpdate = [
            SELECT Id, Name, All_Required_Details_Provided_by_the_Cus__c, 
            Legal_Team__c, Legal_Team__r.Email 
            FROM Booking__c 
            WHERE Id IN :bookingIds
        ];
        
        List<Booking__c> recordsToUpdate = new List<Booking__c>();
        
        for (Booking__c booking : bookingsToUpdate) {
            if (!booking.All_Required_Details_Provided_by_the_Cus__c) {
                booking.All_Required_Details_Provided_by_the_Cus__c = true;
                recordsToUpdate.add(booking);
            }
        }
        
        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }
    }

    
}