trigger InterestRateTrigger on Interest_Rate__c (after update) {
    
    
    String currentMonth =  DateTime.now().format('MMMM');
    
    for (Interest_Rate__c ir : Trigger.new) {
        if (
            ir.Interest_Rate__c != Trigger.oldMap.get(ir.Id).Interest_Rate__c
            && ir.Month__c == currentMonth 
        ) {  
            
            List<Project__c> projectsToUpdate = [ 
                SELECT Id, Interest_Percentage__c 
                FROM Project__c 
            ];
            
            for (Project__c project : projectsToUpdate) {
                project.Interest_Percentage__c = ir.Interest_Rate__c;
            }
            
            if (!projectsToUpdate.isEmpty()) {
                update projectsToUpdate;
            }
        }
    }
}