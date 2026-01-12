public class ActivateCustomerMasterContr {
    @AuraEnabled
    public static void activateCustomerMaster(String recordId) {
        if(recordId!=null){
              List<Customer_Master__c> cmList = [ SELECT Id, Email__c, Password__c,First_Name__c, Last_Name__c, Phone__c,Name,Loyality__c,isActive__c  FROM Customer_Master__c  where Id=: recordId limit 1];
            cmList[0].isActive__c=true;
            update cmList[0];
            
            
        }
    }

}