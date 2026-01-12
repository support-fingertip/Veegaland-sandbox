public class InterestRateScheduler implements Schedulable {
    
    // Execute method for the scheduled job
    public void execute(SchedulableContext context) {
        try {
            // Get the current month
            DateTime currentDateTime = DateTime.now();
            String currentMonth = currentDateTime.format('MMMM');
            
            // Fetch the Interest_Rate__c record for the current month
            Interest_Rate__c currentRate = [SELECT Id, Interest_Rate__c, Month__c 
                                            FROM Interest_Rate__c 
                                            WHERE Month__c = :currentMonth 
                                            LIMIT 1];
            
            if (currentRate != null) {
                // Fetch all the Project__c records that need to be updated
                List<Project__c> projectsToUpdate = [SELECT Id, Interest_Percentage__c 
                                                     FROM Project__c 
                                                     WHERE Interest_Percentage__c != :currentRate.Interest_Rate__c];
                
                // Update the Interest_Percentage__c field with the new rate
                for (Project__c project : projectsToUpdate) {
                    project.Interest_Percentage__c = currentRate.Interest_Rate__c;
                }
                
                // Update the records in Salesforce
                if (!projectsToUpdate.isEmpty()) {
                    update projectsToUpdate;
                }
            } else {
                System.debug('No Interest Rate found for the current month: ' + currentMonth);
            }
        } catch (Exception e) {
            System.debug('Error occurred: ' + e.getMessage());
        }
    }
}