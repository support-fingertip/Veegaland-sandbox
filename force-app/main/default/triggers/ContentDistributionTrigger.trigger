trigger ContentDistributionTrigger on ContentDistribution (After insert) {
    if (!Trigger.new.isEmpty()) {
        // Extract ContentDistribution IDs from Trigger.new
        List<Id> contentDistributionIds = new List<Id>();
        
        // Loop through Trigger.new to get the IDs
        for (ContentDistribution dist : Trigger.new) {
            contentDistributionIds.add(dist.Id);
        }
        
        // Debugging: Log the IDs to check
        System.debug('ContentDistribution IDs: ' + contentDistributionIds);
        
        // Call the service method to handle the update logic
        system.debug('inside ContentDistributionTrigger');
        ContentServiceController.updateParkingFloorWithDownloadUrl(contentDistributionIds);
    }
}