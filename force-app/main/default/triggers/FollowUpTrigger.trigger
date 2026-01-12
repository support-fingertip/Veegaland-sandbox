trigger FollowUpTrigger on Follow_up__c (before insert,before update,after insert,after update, after delete, after undelete) 
{
    Set<Id> parentIds = new Set<Id>();
    list<Lead> lstld = new list<Lead>();
    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete){
        for (Follow_up__c sv : Trigger.new) 
        {
            if (sv.Leads__c != null) 
            {
                parentIds.add(sv.Leads__c);
            }
        }
    }
    else if (Trigger.isDelete) {
        for (Follow_up__c sv : Trigger.old) {
            if (sv.Leads__c != null) {
                parentIds.add(sv.Leads__c);
            }
        }
    }
    List<Lead> ldlst = [SELECT Id, (SELECT Id FROM Follow_ups__r) FROM Lead WHERE Id IN :parentIds];
    for (Lead ld : ldlst) 
    {
        ld.No_of_Follow_Up__c = ld.Follow_ups__r.size();
    }
    update ldlst;
    if(trigger.isBefore && trigger.isInsert)
    {
        RoundRobinHandler.assignToFollowup(trigger.new);
        
    }
    if(trigger.isBefore && trigger.isUpdate) {
        for (Follow_up__c sv : Trigger.new) {
            if (sv.Status__c == 'Completed' && Trigger.oldMap.get(sv.Id).Status__c != 'Completed') {
              sv.Completed_Date__c = system.today();  
            }
            if ((sv.Status__c == 'Missed' || sv.Status__c == 'Scheduled' || sv.Status__c == 'Cancelled' )&& Trigger.oldMap.get(sv.Id).Status__c == 'Completed') {
              sv.addError('We cannot change a completed stage to another stage.');  
            }
        } 
    }  
}