/*
*********************************************************
Apex Class Name    : LeadMergeBatch
Created Date       : Mar 03, 2025
@description       : This class is used to merge all the duplicate leads in the system and delete the duplicates
@author            : Mayuri Patel
Modification Log:
Ver   Date         Author                  Modification
1.0   03-03-2025   Mayuri Patel            Initial Version
*********************************************************
*/
public class LeadMergeBatch implements Database.Batchable<SObject>, Database.Stateful {
    Map<String, Lead> primaryLeadMap = new Map<String, Lead>(); // Store primary leads
    
    
    // Child objects and their respective Lead Lookup Fields
    Map<String, String> childObjectMap = new Map<String, String>{
        'Related_Source__c' => 'Lead__c', // Example: Change according to your org
            'Site_Visit__c' => 'Lead__c',
            'Follow_Up__c' => 'Leads__c',
            'Quote__c' => 'Leads__c',
            'Booking__c' => 'SLead__c'
            };
                
                // Fetch Leads (Retrieve all leads and process duplicates in Apex)
                public Database.QueryLocator start(Database.BatchableContext BC) {
                    return Database.getQueryLocator([
                        SELECT Id, Name, Phone, Secondary_Phone__c, CreatedDate 
                        FROM Lead
                        WHERE Phone != NULL OR Secondary_Phone__c != NULL
                        ORDER BY CreatedDate DESC
                    ]);
                }
    
    public void execute(Database.BatchableContext BC, List<Lead> leadList) {
        Map<String, List<Lead>> duplicateLeadsMap = new Map<String, List<Lead>>();
        
        // Group leads by Phone and Secondary Mobile
        for (Lead lead : leadList) {
            String key = (lead.Phone != null) ? lead.Phone : lead.Secondary_Phone__c;
            if (key != null) {
                if (!duplicateLeadsMap.containsKey(key)) {
                    duplicateLeadsMap.put(key, new List<Lead>());
                }
                duplicateLeadsMap.get(key).add(lead);
            }
        }
        
        for (String phoneKey : duplicateLeadsMap.keySet()) {
            List<Lead> duplicates = duplicateLeadsMap.get(phoneKey);
            
            if (duplicates.size() > 1) {
                // Select Primary Lead (earliest created lead)
                Lead primaryLead = duplicates[0];
                System.debug('Primary Lead Selected: ' + primaryLead.Id + ' - ' + primaryLead.Name);
                
                for (Integer i = 1; i < duplicates.size(); i++) {
                    Lead duplicate = duplicates[i];
                    System.debug('Duplicate Lead Found: ' + duplicate.Id + ' - ' + duplicate.Name);
                    
                    // Log related records without updating
                    List<SObject> childRecords = fetchChildRecords(duplicate.Id);
                    for (SObject record : childRecords) {
                        System.debug('Child Record: ' + record);
                    }
                }
            }
        }
    }
    
    // Helper method to fetch related records without updating them
    public List<SObject> fetchChildRecords(Id oldLeadId) {
        List<SObject> records = new List<SObject>();
        
        for (String objectName : childObjectMap.keySet()) {
            String lookupField = childObjectMap.get(objectName);
            String query = 'SELECT Id, ' + lookupField + ' FROM ' + objectName + ' WHERE ' + lookupField + ' = :oldLeadId';
            
            List<SObject> childRecords = Database.query(query);
            records.addAll(childRecords);
        }
        return records;
    }

    
    public void finish(Database.BatchableContext BC) {
        System.debug('Batch Completed - Merged Duplicate Leads');
    }
}