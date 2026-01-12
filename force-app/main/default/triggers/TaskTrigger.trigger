trigger TaskTrigger on Task (before update,after update) {
    
    Set<Id> bookingIds = new Set<Id>();
    List<Id> welcomeCallDoneList = new List<Id>();
    List<Id> carParkingDoneList = new List<Id>();
    
    Set<Id> totalReviewTaskList = new Set<Id>();
    Set<Id> saDetailverifiedist = new Set<Id>();
    Set<Id> bookingIdsToADReview = new Set<Id>();
    Set<Id> allReviewedList = new Set<Id>();
    Set<Id> agreementCostFollowup = new Set<Id>();
    Set<Id> completedSADetailsSendList = new Set<Id>();
    Set<Id> agreementCostReceivedList = new Set<Id>();
    Set<Id> agreementCompletedList = new Set<Id>();
    Set<Id> advanceBookingIds = new Set<Id>();
    
    
    if(trigger.isBefore){
    for (Task t : Trigger.new) {
        Task oldTask = Trigger.oldMap.get(t.Id);
        
        
        if (t.WhatId != null && 
            t.Subject == 'Welcome Call Follow-up' &&
            t.Status == 'Completed' && oldTask.Status != t.Status) {
                
                welcomeCallDoneList.add(t.WhatId);
            }
       /* if (t.WhatId != null && 
            t.Subject == 'Car Parking Follow-up' &&
            t.Status == 'Completed' && oldTask.Status != t.Status) {
                
                carParkingDoneList.add(t.WhatId);
            }*/
        if (t.WhatId != null && 
            t.Subject == 'Advance Payment Follow-up' &&
            t.Status == 'Completed' && oldTask.Status != t.Status) {
                
                advanceBookingIds.add(t.WhatId);
            }
        
        if (t.WhatId != null && 
            t.Subject == 'Overall Booking Details Review' &&
            t.Status == 'Completed' && oldTask.Status != t.Status) {
                
                allReviewedList.add(t.WhatId);
            }


        if (t.WhatId != null && 
            t.Subject == 'Sale Agreement Registration Completion' &&
            t.Status == 'Completed' && oldTask.Status != t.Status) {
                
                agreementCompletedList.add(t.WhatId);
            }
        if (t.WhatId != null &&
            t.Subject != null &&
            t.Subject.contains('Please verify the agreement details of primary applicant') &&
            t.Status == 'Completed' &&
            oldTask.Status != 'Completed') {
                
                saDetailverifiedist.add(t.WhatId);
            }
    }
    }
    if(trigger.isAfter){
        for (Task t : Trigger.new) {
            Task oldTask = Trigger.oldMap.get(t.Id);
            if (t.WhatId != null && 
                t.Subject == 'Token Advance Payment Follow-up' &&
                t.Status == 'Completed' && oldTask.Status != t.Status) {
                    
                    bookingIds.add(t.WhatId);
                }     
        }
    }    
    
    if (!bookingIds.isEmpty()) {
        BookingController.completeOrCreateTokenAdvanceFollowUps(bookingIds);
    }
    
    if (!welcomeCallDoneList.isEmpty()) {
        TaskController.updateBookingAACStage(welcomeCallDoneList);
    }
    
   /* if (!carParkingDoneList.isEmpty()) {
        TaskController.updateBookingAACStage(carParkingDoneList);
    }*/
    
    if (!advanceBookingIds.isEmpty()) {
        BookingController.completeOrCreateAdvanceFollowUps(advanceBookingIds);
    }

    if (!allReviewedList.isEmpty()) {
        TaskController.updateBookingAllReviewed(allReviewedList);
    }
    
    if (!agreementCompletedList.isEmpty()) {
        TaskController.updateBookingtoAgreementCompleted(agreementCompletedList);
    }
    
    if (!saDetailverifiedist.isEmpty()) {
        TaskController.updateBookingSADetails(saDetailverifiedist);
    }
}