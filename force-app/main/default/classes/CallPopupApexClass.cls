public class CallPopupApexClass {
    @AuraEnabled
    public static string LeadRecordDetails() {
        string userId = UserInfo.getUserId();
        User u = [select Id,Name,callUUID__c from User where Id=:userId limit 1];
        if(u != null){
            List<Call_Detail__c> call = [select Id,Name,Lead__c from Call_Detail__c where callUUID__c=:u.callUUID__c limit 1];
            if(call.size()>0){
                return call[0].Lead__c; 
            }
        }
        return 'null';  
    }
    
}