public with sharing class PaymentScheduleTabController {
    @AuraEnabled(cacheable = true)
    public static List < Payment_schedule__c > getPaymentScheduleList(Id bookingId) {
        return [
            SELECT
            Id,
            AmountB__c, Name, Round_Off_Amount__c, S_No__c, SGST_Amount__c, CGST_Amount__c, Is_Demanded__c, Booking__c, Amount__c, Payment_percent__c, Custom_Value__c
            FROM Payment_schedule__c
            WHERE Booking__c =: bookingId
            WITH USER_MODE ORDER BY S_No__c ASC
        ];
    }
    
    @AuraEnabled(cacheable = true)
    public static List < Payment_schedule__c > findPaymentSchedules(String searchKey, Id bookingId) {
        String key = '%' + searchKey + '%';
        return [
            SELECT Id, AmountB__c, Name,  Round_Off_Amount__c, S_No__c, SGST_Amount__c, CGST_Amount__c, Is_Demanded__c, Amount__c, Payment_percent__c, Custom_Value__c
            FROM Payment_schedule__c
            WHERE Name LIKE: key AND Booking__c =: bookingId 
            WITH USER_MODE ORDER BY S_No__c ASC
            LIMIT 10
        ];
    }
    
    @AuraEnabled(cacheable = true)
    public static Payment_schedule__c getPaymentSchedule() {
        return [
            SELECT Id, AmountB__c, Name, Round_Off_Amount__c, S_No__c, SGST_Amount__c, CGST_Amount__c, Is_Demanded__c, Amount__c, Payment_percent__c, Custom_Value__c
            FROM Payment_schedule__c
            WITH USER_MODE
            LIMIT 1
        ];
    }
    
    @AuraEnabled
    public static void updatepaymentSchedules(List < Payment_schedule__c > paymentScheduleForUpdate) {
        // Make sure we can update the database before trying to update
        if (!Schema.sObjectType.Payment_schedule__c.isUpdateable()) {
            throw new SecurityException(
                'Insufficient permissions to update contacts'
            );
        }
        update paymentScheduleForUpdate;
    }
    
    @AuraEnabled
    public static void updatePaymentSchedule(
        Id recordId,
        Decimal roundOffAmount,
        String name
    ) {
        Payment_schedule__c paymentSchedule = new Payment_schedule__c(
            Id = recordId,
            Round_Off_Amount__c = roundOffAmount,
            Name = Name
        );
        update paymentSchedule;
    }
    
    @AuraEnabled
    public static List < Payment_Schedule__c > mergeSchedules(List < Id > scheduleIds) {
        if (scheduleIds == null || scheduleIds.isEmpty()) {
            return new List < Payment_Schedule__c > ();
        }
        
        // Query all schedules ordered by S_No__c
        List < Payment_Schedule__c > schedules = [
            SELECT Id, Name, S_No__c, Payment_Percent__c, Amount__c, Completed_Date__c,
            Booking__c, Booking__r.Project1__c, Booking__r.Payment_Plan__c, AmountB__c,
            Booking__r.Payment_Plan__r.Name, Booking__r.Name, Custom_Value__c
            FROM Payment_Schedule__c
            WHERE Id IN: scheduleIds
            ORDER BY S_No__c ASC
        ];
        
        if (schedules.isEmpty()) {
            return new List < Payment_Schedule__c > ();
        }
        
        Payment_Schedule__c firstSchedule = schedules[0];
        Payment_Schedule__c lastSchedule = schedules[schedules.size() - 1];
        
        // Calculate totals
        Decimal totalPercent = 0;
        Decimal totalAmount = 0;
        Decimal totalAmountWithGst  = 0;
        Decimal gstCutoff = 0;
        
        for (Payment_Schedule__c s: schedules) {
            totalPercent += (s.Payment_Percent__c != null ? s.Payment_Percent__c : 0);
            totalAmount += (s.Amount__c != null ? s.Amount__c : 0);
            //gstCutoff need to get the amount
            System.debug('Amount '+s.AmountB__c);
            totalAmountWithGst += (s.AmountB__c != null ? s.AmountB__c : 0);
        }
        
        Date lastCompletedDate = lastSchedule.Completed_Date__c;
        String lastCompletedMilestone = lastSchedule.Name;
        Id bookingId = lastSchedule.Booking__c;
        String externalId = lastSchedule.Booking__r.Payment_Plan__r.Name + lastSchedule.Booking__r.Name;
        Master_Payment_Schedule__c mps;
        
        // Check if Master Payment Schedule already exists
        try {
            
            mps = [
                SELECT Id, ExternalId__c, Name, Payment_Percent__c, S_No__c
                FROM Master_Payment_Schedule__c
                WHERE Name =: ('On ' + lastCompletedMilestone)
                AND Payment_Percent__c =: totalPercent
                AND Payment_Plan__c =: lastSchedule.Booking__r.Payment_Plan__c
                LIMIT 1
            ];
        }catch (QueryException qe) {
            
            mps = new Master_Payment_Schedule__c(
                Name = 'On ' + lastCompletedMilestone,
                Project__c = lastSchedule.Booking__r.Project1__c,
                Payment_Percent__c = totalPercent,
                Amount__c = totalAmount,
                Completed_Date__c = lastCompletedDate,
                Completed__c = true,
                Combined_Schedule__c = true,
                Status__c = 'Completed',
                Include_Interest__c = true,
                Payment_Plan__c = lastSchedule.Booking__r.Payment_Plan__c,
                ExternalId__c = externalId,
                S_No__c = firstSchedule.S_No__c
            );
            insert mps;
        }
        
        // Create new Payment Schedule linked to Master
        Payment_Schedule__c psNew = new Payment_Schedule__c(
            Name = mps.Name,
            Payment_percent__c = mps.Payment_Percent__c,
            Booking__c = bookingId,
            Status__c = 'Completed',
            S_No__c = mps.S_No__c,
            Completed__c = true,
            Master_Payment_Schedule__c = mps.Id,
            Amount__c = totalAmount,
            Scheduled_Amount__c = totalAmountWithGst
        );
        insert psNew;
        
        // Update related Receipt Line Items to point to new Payment Schedule
        List < Receipt_Line_Item__c > receiptItems = [
            SELECT Id, Payment_Schedule__c
            FROM Receipt_Line_Item__c
            WHERE Payment_Schedule__c IN: scheduleIds
        ];
        for (Receipt_Line_Item__c rli: receiptItems) {
            rli.Payment_Schedule__c = psNew.Id;
        }
        if (!receiptItems.isEmpty()) {
            update receiptItems;
        }
        
        // Delete old schedules
        delete schedules;
        
        // Return all remaining Payment Schedules for the booking
        return [
            SELECT
            Id,
            AmountB__c, Name, Round_Off_Amount__c, S_No__c, SGST_Amount__c, CGST_Amount__c, Is_Demanded__c, Booking__c, Amount__c, Payment_percent__c, Custom_Value__c
            FROM Payment_Schedule__c
            WHERE Booking__c =: bookingId AND Id NOT IN : scheduleIds
            ORDER BY S_No__c ASC
        ];
    }
     
}