({
    getLeadRecords: function(component, event) {
        component.set("v.spinner",true);
    // Call Apex to get records
    var action = component.get("c.getLeadRecords");
    action.setParams({
        'FromCreatedDateFilter': component.get("v.FromCreatedDateFilter"), 
        'ToCreatedDateFilter': component.get("v.ToCreatedDateFilter"),
        'CreatedDate': component.get("v.selectedDateValue")
    });
    action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            var records = response.getReturnValue();
            console.log(JSON.stringify(records)); // Log the records
            component.set("v.records", records);
            
            var maxFollowUpCount = 0; // Initialize maxFollowUpCount
            const followUpLabels = [];
            // Iterate over each record to find the maximum followUpDates length
            records.forEach(function(record) {
                if (record.followUpDates && record.followUpDates.length > maxFollowUpCount) {
                    maxFollowUpCount = record.followUpDates.length; // Update maxFollowUpCount
                }
            }); 
            // Closing parenthesis for forEach
            for (let i = 0; i < maxFollowUpCount; i++) {
                followUpLabels.push('Follow Up Date ${i + 1}');
            }

        // Set the labels in the component
        component.set("v.maxFollowUpCount", followUpLabels);
             
        }
        component.set("v.spinner",false);
    });
    $A.enqueueAction(action);
}

    
})