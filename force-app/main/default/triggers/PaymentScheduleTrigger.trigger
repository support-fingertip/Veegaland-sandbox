trigger PaymentScheduleTrigger on Payment_schedule__c (before insert,before update,after insert, after update, after delete, after undelete) {
    
    Set<Id> quoteIds = new Set<Id>();
    if (Trigger.isUpdate) {
        if(Trigger.isBefore){
            List<Payment_schedule__c> payList = new List<Payment_schedule__c>();
            for (Payment_schedule__c payment : Trigger.new) {
                Payment_schedule__c oldSchedule = Trigger.oldMap.get(payment.id);
                if((payment.Include_Interest__c != oldSchedule.Include_Interest__c) && payment.Include_Interest__c == false){
                    payment.Balance_Amount__c = payment.AmountB__c;
                }
                if(payment.Demand_Date__c != null){
                    date newDuwDate = payment.Demand_Date__c.addDays(15);
                    if((newDuwDate != Trigger.oldMap.get(payment.id).Payment_Due_Date__c)){
                        payment.Payment_Due_Date__c = newDuwDate;
                    }
                }
                
            }
        }
        if(Trigger.isAfter){
            Set<Id> relevantRecords = new Set<Id>();
            Set<Id> payChangeList = new Set<Id>();
            Set<Id> updateRcptLines = new Set<Id>();
            
            for (Payment_Schedule__c newPs : Trigger.new) {
                Payment_Schedule__c oldPs = Trigger.oldMap.get(newPs.Id);
                
                // Check if Received_Amount1__c has changed and now equals Amount1__c
                if (newPs.Received_Amount1__c != oldPs.Received_Amount1__c && 
                    newPs.Received_Amount1__c == newPs.Amount1__c && 
                    newPs.Booking__c != null && newPs.S_No__c == 1) {
                        relevantRecords.add(newPs.Id);
                    }
                if(newPs.Payment_percent__c != null && newPs.Payment_percent__c != oldPs.Payment_percent__c ){
                    payChangeList.add(newPs.Booking__c);
                }
                
                if(newPs.Is_Demanded__c != oldPs.Is_Demanded__c && newPs.Is_Demanded__c == true ){
                    updateRcptLines.add(newPs.Id);
                }
            }
            if(!payChangeList.isEmpty()){
                PaymentScheduleService.updatePaymentSchedules(payChangeList);
            }
            // If there are relevant records, proceed with further processing
            if (!relevantRecords.isEmpty()) {
                PaymentScheduleService.sendPaymentNotification(relevantRecords);
            }
            if(!updateRcptLines.isEmpty()){
                ReceiptController.updateReceiptLineItems(updateRcptLines);
            }
        }
    }
}