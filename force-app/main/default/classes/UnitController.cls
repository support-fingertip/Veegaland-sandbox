public class UnitController {
    
    public static void copyProjectDocumentsToUnits(List<Plot__c> newUnits) {
        if (newUnits.isEmpty()) {
            return; // No new units, exit early
        }
        system.debug('here');
        Map<Id, String> unitProjectMap = new Map<Id, String>(); // UnitId -> ProjectId
        Map<Id, String> unitTypeMap = new Map<Id, String>();    // UnitId -> Unit_Common_Type__c

        // Step 1: Collect Unit_Project__c IDs and their Unit_Common_Type__c
        for (Plot__c unit : newUnits) {
            if (unit.Project__c != null && unit.Unit_Common_Type__c != null) {
                unitProjectMap.put(unit.Id, unit.Project__c);
                unitTypeMap.put(unit.Id, unit.Unit_Common_Type__c);
            }
        }

        // Step 2: Fetch all documents linked to Project__c objects
        Map<Id, List<ContentDocumentLink>> projectDocumentsMap = new Map<Id, List<ContentDocumentLink>>();
        Set<Id> contentDocumentIds = new Set<Id>(); // Store ContentDocument IDs to fetch Titles in one query

        for (ContentDocumentLink docLink : [
            SELECT ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :unitProjectMap.values()
        ]) {
            if (!projectDocumentsMap.containsKey(docLink.LinkedEntityId)) {
                projectDocumentsMap.put(docLink.LinkedEntityId, new List<ContentDocumentLink>());
            }
            projectDocumentsMap.get(docLink.LinkedEntityId).add(docLink);
            contentDocumentIds.add(docLink.ContentDocumentId);
        }
        system.debug('projectDocumentsMap '+projectDocumentsMap);
        // Step 3: Fetch Titles of all ContentDocuments in one query
        Map<Id, String> contentDocumentTitleMap = new Map<Id, String>();
        for (ContentDocument doc : [
            SELECT Id, Title FROM ContentDocument 
            WHERE Id IN :contentDocumentIds
        ]) {
            contentDocumentTitleMap.put(doc.Id, doc.Title);
        }

        List<ContentDocumentLink> newDocumentLinks = new List<ContentDocumentLink>();
        // Step 4: Process units and copy documents
        for (Id unitId : unitProjectMap.keySet()) {
            Id projectId = unitProjectMap.get(unitId);
            String unitType = unitTypeMap.get(unitId);

            if (projectDocumentsMap.containsKey(projectId)) {
                for (ContentDocumentLink docLink : projectDocumentsMap.get(projectId)) {
                    String documentTitle = contentDocumentTitleMap.get(docLink.ContentDocumentId);

                    // Determine which documents should be copied based on Unit_Common_Type__c
                    if ((unitType == 'Type A' && (documentTitle.contains('Parking Plan A') || documentTitle.contains('Electrical Plan A') || documentTitle.contains('Plumbing Plan A') || documentTitle.contains('Floor Plan A'))) ||
                        (unitType == 'Type B' && (documentTitle.contains('Parking Plan B') || documentTitle.contains('Electrical Plan B') || documentTitle.contains('Plumbing Plan B') || documentTitle.contains('Floor Plan B'))) ||
                        (unitType == 'Type C' && (documentTitle.contains('Parking Plan C') || documentTitle.contains('Electrical Plan C') || documentTitle.contains('Plumbing Plan C') || documentTitle.contains('Floor Plan C')))) {
                        
                        // Rename document to a standard format without Type A/B/C
                        String renamedTitle = documentTitle.replace(' A', '').replace(' B', '').replace(' C', '');
                        // Create a new document link for the unit
                        ContentDocumentLink newDocLink = new ContentDocumentLink(
                            ContentDocumentId = docLink.ContentDocumentId,
                            LinkedEntityId = unitId,
                            ShareType = 'I' // 'I' means inferred permission
                        );
                        newDocumentLinks.add(newDocLink);
                    }
                }
            }
        }

        // Step 5: Insert new document links to attach documents to Unit__c
         system.debug('newDocumentLinks '+newDocumentLinks);
        if (!newDocumentLinks.isEmpty()) {
            insert newDocumentLinks;
        }
    }
}