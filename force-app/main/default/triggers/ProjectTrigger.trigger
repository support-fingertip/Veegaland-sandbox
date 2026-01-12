trigger ProjectTrigger on Project__c (before insert, before update, after insert, after update, after delete, after undelete) {
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        Set<Id> newset = new Set<Id>();
        List<Payment_schedule__c> updatelist = new List<Payment_schedule__c>();
        
        for (Project__c pro : Trigger.new) {
            if (pro.Interest_Percentage__c != null && pro.Interest_Percentage__c != Trigger.oldMap.get(pro.Id).Interest_Percentage__c && label.DisableInterest != 'TRUE') {
                newset.add(pro.Id);
            }
        }
        
        if (!newset.isEmpty()) {
            PaymentScheduleBatch scheduleBatch = new PaymentScheduleBatch(newset);
            Database.executeBatch(scheduleBatch);
        }
    }
}