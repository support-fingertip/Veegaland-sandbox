public class UpdateFollowUpController {
//update Follow-Up Date aura name - updateFollowUpDate
    @AuraEnabled
    public static string createALog(string recId, string ButtonValue,string UpdateLeadStatus){
        system.debug('recId'+recId+' ButtonValue'+ButtonValue);
        if(recId != null || recId != ''){
            try{
                Lead l = [SELECT Id, Name, Follow_up_Description__c, Follow_up_scheduled_date__c, Follow_up_Status__c, Follow_up_Subject__c,Mark_the_follow_up_as_completed__c, OwnerId,Follow_up_completed_Description__c,Lead_Stage__c FROM Lead WHERE Id = :recId LIMIT 1];
                List<Follow_up__c> f = [SELECT Id,Status__c,Name,CreatedDate FROM Follow_up__c WHERE Status__c = 'Scheduled' AND Leads__c=:recId LIMIT 1];
                Follow_up__c tsk = new Follow_up__c();
                tsk.Leads__c = l.Id;
                tsk.Scheduled_Date__c = l.Follow_up_scheduled_date__c;
                tsk.Status__c = 'Scheduled';
                tsk.Subject__c = l.Follow_up_Subject__c;
                tsk.Description__c = l.Follow_up_Description__c;
                tsk.OwnerId = l.OwnerId;
                if(f.size()>0){
                    for(Follow_up__c followup:f){
                        if(l.Mark_the_follow_up_as_completed__c == true){
                            followup.Status__c = 'Completed';  
                       } 
                    }
                   update f;
                }
                if(l.Lead_Stage__c != 'SV Schedule' && l.Lead_Stage__c != 'Closed Lost'){
                    insert tsk;  
                }
                  
                
                /*if(f.size()>0) {
tsk.Id = f[0].Id; // Assign the existing Follow-up record's Id if found
update tsk;
} else if(ButtonValue == 'New Follow Up'){
insert tsk;
}*/
                  // Attempt to insert the task record
                /*else if(f.size()==0 && ButtonValue == 'Update Follow Up'){
return 'No pending tasks. Sorry! Can not update.';  
}*/
            }
            catch (Exception e) {
                System.debug('An error occurred: ' + e.getMessage());
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    // Get the error message for the current error
                    String errorMessage = e.getDmlMessage(i);
                    // You can log or handle the error message as needed
                    System.debug('An error occurred: ' + errorMessage);
                    return errorMessage;
                }
            }
        }
        return null;
    }
}