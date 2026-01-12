trigger DemandRaisedTrigger on Demand_Raised__c (after insert) {
    Set<String> recipientIds = new Set<String>();
    List<Id> demandIdsSet = new List<Id>();
    
    for (Demand_Raised__c demand : Trigger.new) {
        // Add the record creator to the recipient list
        recipientIds.add(demand.CreatedById);
        demandIdsSet.add(demand.Id);
        
        // Build notification message
        String title = 'New Demand Raised';
        String body = 'This is to notify that Booking (' + demand.Booking_Name__c + '), has a new demand raise. ' +
                      'The demand raise ' + demand.Name + ' has been created.';
        String notificationName = 'Demand_Raise_Creation_Notification';

        // Send the notification
        ReceiptController.sendCustomNotification(
            recipientIds,
            title,
            body, 
            demand.Id,
            notificationName
        );
    }
        // Call bulkified email method
    if (!demandIdsSet.isEmpty() && label.DisabledDemandRaise !='TRUE') {
        DemandRaisedHelper.sendDemandEmailToCustomer(demandIdsSet);
    }
    if (!demandIdsSet.isEmpty()) {
        DemandRaisedHelper.updatePaymentScheduleFields(demandIdsSet);
    }
}