public class ContentServiceController {

    public static void updateParkingFloorWithDownloadUrl(List<Id> contentDistributions) {
        
        // Debugging: log the input ContentDistribution IDs
        System.debug('ContentDistribution IDs: ' + contentDistributions);

        // Query ContentDistributions to get their ContentVersionId and ContentDownloadUrl
        List<ContentDistribution> contentDistributionList = [
            SELECT Id, ContentVersionId, ContentDownloadUrl 
            FROM ContentDistribution 
            WHERE Id IN :contentDistributions
        ];
        
        // Debugging: log the queried ContentDistribution records
        System.debug('ContentDistribution List: ' + contentDistributionList);

        // Set to hold the ContentVersionIds for querying ContentDocuments
        Set<Id> contentVersionIds = new Set<Id>();
        
        // Populate the set with ContentVersionIds
        for (ContentDistribution dist : contentDistributionList) {
            contentVersionIds.add(dist.ContentVersionId);
        }
        
        // Query for all ContentVersions related to the inserted ContentDistributions
        Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>(
            [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersionIds]
        );
        
        // Debugging: log the contentVersionMap
        System.debug('ContentVersion Map: ' + contentVersionMap);

        // Set to hold the ContentDocumentIds for querying ContentDocumentLink
        Set<Id> contentDocumentIds = new Set<Id>();
        
        // Populate the set with ContentDocumentIds from the ContentVersions
        for (ContentVersion cv : contentVersionMap.values()) {
            contentDocumentIds.add(cv.ContentDocumentId);
        }
        
        // Query ContentDocumentLink to get the related records (LinkedEntityId)
        List<ContentDocumentLink> contentDocLinks = [
            SELECT ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE ContentDocumentId IN :contentDocumentIds
        ];
        
        // Map to store the LinkedEntityId (which is the parent record ID) for each ContentDocumentId
        Map<Id, Id> contentDocumentLinkMap = new Map<Id, Id>();
        
        // Populate the map with ContentDocumentId -> LinkedEntityId (which is the Parking_Floor__c Id)
        for (ContentDocumentLink link : contentDocLinks) {
            contentDocumentLinkMap.put(link.ContentDocumentId, link.LinkedEntityId);
        }
        
        // Debugging: log the contentDocumentLinkMap
        System.debug('ContentDocumentLink Map: ' + contentDocumentLinkMap);

        // List to store Parking_Floor__c records that need to be updated
        List<Parking_Floor__c> parkingFloorsToUpdate = new List<Parking_Floor__c>();

        // Process each ContentDistribution
        for (ContentDistribution dist : contentDistributionList) {
            // Get the ContentVersion from the map using ContentVersionId
            ContentVersion cv = contentVersionMap.get(dist.ContentVersionId);
            
            if (cv != null) {
                // Get the LinkedEntityId (parent record ID) from the map using ContentDocumentId
                Id linkedEntityId = contentDocumentLinkMap.get(cv.ContentDocumentId);
                
                // Check if the LinkedEntityId corresponds to Parking_Floor__c
                if (linkedEntityId != null && linkedEntityId.getSObjectType() == Parking_Floor__c.SObjectType) {
                    // Create or update the Parking_Floor__c record
                    Parking_Floor__c parkingFloor = new Parking_Floor__c(
                        Id = linkedEntityId,
                        Layout_Public_url__c = dist.ContentDownloadUrl // Use ContentDownloadUrl from ContentDistribution
                    );
                    parkingFloorsToUpdate.add(parkingFloor);
                } else {
                    // Debugging: log when LinkedEntityId is not a Parking_Floor__c
                    System.debug('LinkedEntityId is not a Parking_Floor__c: ' + linkedEntityId);
                }
            } else {
                // Debugging: log when ContentVersion is not found
                System.debug('ContentVersion not found for ContentVersionId: ' + dist.ContentVersionId);
            }
        }
        
        // Check if there are any Parking_Floor__c records to update
        if (!parkingFloorsToUpdate.isEmpty()) {
            try {
                // Perform the update DML operation
                update parkingFloorsToUpdate;
                System.debug('Successfully updated Parking_Floor__c records.');
            } catch (DmlException e) {
                // Log any DML exceptions
                System.debug('Error updating Parking_Floor__c records: ' + e.getMessage());
            }
        } else {
            // Debugging: log if no records need updating
            System.debug('No Parking_Floor__c records to update.');
        }
    }
}