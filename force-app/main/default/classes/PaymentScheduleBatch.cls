global class PaymentScheduleBatch implements Database.Batchable<SObject> {
    global Set<Id> projectIds;

    global PaymentScheduleBatch(Set<Id> projectIds) {
        this.projectIds = projectIds;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {

        return Database.getQueryLocator([
            SELECT Id, Pending_Amount__c, Name, Payment_Due_Date__c, Booking__c, 
                   Last_Payment_Date__c, Balance_Amount__c, Payment_percent__c, 
                   Booking__r.Project1__r.Interest_Percentage__c, Interest_Up_to_Date__c, 
                   Include_Interest__c, Interest_Amount__c, Interest_Percent__c, Booking__r.Stage__c
            FROM Payment_Schedule__c
            WHERE Include_Interest__c = true AND Booking__r.Project1__c IN :projectIds AND (Booking__r.Stage__c  != 'Cancellation' OR Booking__r.Stage__c  != 'Unit Swap')
        ]);
    }

    global void execute(Database.BatchableContext BC, List<Payment_Schedule__c> scope) {
        List<Payment_schedule__c> updatelist = new List<Payment_schedule__c>();
        List<Interest_Amount_Line_Item__c> intAmtLiIts = new List<Interest_Amount_Line_Item__c>();

        for (Payment_Schedule__c extps : scope) {
            // Update Payment Schedule with new Interest Percentage
            Payment_schedule__c ps = new Payment_schedule__c();
            ps.Id = extps.Id;
            ps.Interest_Percent__c = extps.Booking__r.Project1__r.Interest_Percentage__c;
            ps.Last_Payment_Date__c = System.today();
            ps.Interest_Change_Date__c = System.today();
            updatelist.add(ps);

            // Create Interest Amount Line Items
            Interest_Amount_Line_Item__c interestItems = new Interest_Amount_Line_Item__c();
            interestItems.Interest_Amount__c = extps.Interest_Amount__c;
            interestItems.Interest_Start_Date__c = (extps.Last_Payment_Date__c == null) ? extps.Payment_Due_Date__c.addDays(1) : extps.Last_Payment_Date__c.addDays(1);
            interestItems.Interest_End_Date__c = System.today();
            interestItems.Interest_Percent__c = extps.Interest_Percent__c;
            interestItems.Payment_Schedule__c = extps.Id;
            interestItems.Booking__c = extps.Booking__c;
            interestItems.Principal_Amount__c = extps.Pending_Amount__c;
            intAmtLiIts.add(interestItems);
        }

        if (!updatelist.isEmpty()) {
            update updatelist;
        }
        if (!intAmtLiIts.isEmpty()) {
            insert intAmtLiIts;
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Batch Job Completed');
    }
}