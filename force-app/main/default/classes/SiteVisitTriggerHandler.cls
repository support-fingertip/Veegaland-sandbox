public class SiteVisitTriggerHandler {
    
    public static void handleAfter(List<Site_Visit__c> newSiteVisits, List<Site_Visit__c> oldSiteVisits) {
        Set<Id> leadIds = new Set<Id>();
        
        if (newSiteVisits != null) {
            for (Site_Visit__c sv : newSiteVisits) {
                if (sv.Lead__c != null) {
                    leadIds.add(sv.Lead__c);
                }
            }
        }

        if (oldSiteVisits != null) {
            for (Site_Visit__c sv : oldSiteVisits) {
                if (sv.Lead__c != null) {
                    leadIds.add(sv.Lead__c);
                }
            }
        }

        if (!leadIds.isEmpty()) {
            updateLeadVisitCounts(leadIds);
        }
    }
    
    private static void updateLeadVisitCounts(Set<Id> leadIds) {
    
        List<Lead> leadsToUpdate = new List<Lead>([
            SELECT Id, Completed_Visits__c, Cancelled_Visits__c 
            FROM Lead 
            WHERE Id IN :leadIds
        ]);

        
        Map<Id, Integer> completedVisitCounts = new Map<Id, Integer>();
        Map<Id, Integer> cancelledVisitCounts = new Map<Id, Integer>();

        
        for (AggregateResult ar : [
            SELECT Lead__c, COUNT(Id) completedVisits
            FROM Site_Visit__c
            WHERE Lead__c IN :leadIds AND Status__c = 'Completed'
            GROUP BY Lead__c
        ]) {
            completedVisitCounts.put((Id)ar.get('Lead__c'), (Integer)ar.get('completedVisits'));
        }

        for (AggregateResult ar : [
            SELECT Lead__c, COUNT(Id) cancelledVisits
            FROM Site_Visit__c
            WHERE Lead__c IN :leadIds AND Status__c = 'Cancelled'
            GROUP BY Lead__c
        ]) {
            cancelledVisitCounts.put((Id)ar.get('Lead__c'), (Integer)ar.get('cancelledVisits'));
        }

     
        for (Lead lead : leadsToUpdate) {
            lead.Completed_Visits__c = completedVisitCounts.containsKey(lead.Id) ? completedVisitCounts.get(lead.Id) : 0;
            lead.Cancelled_Visits__c = cancelledVisitCounts.containsKey(lead.Id) ? cancelledVisitCounts.get(lead.Id) : 0;
        }

      
        if (!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
        }
    }
}