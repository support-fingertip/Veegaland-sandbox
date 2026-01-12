({
	getRecords: function(component, event) {
        component.set("v.spinner",true);
        // Call Apex to get records
        var action = component.get("c.getAllStageRecords");
        action.setParams({
            'FromCreatedDateFilter': component.get("v.FromCreatedDateFilter"), 
            'ToCreatedDateFilter': component.get("v.ToCreatedDateFilter"),
            'CreatedDate': component.get("v.selectedDateValue")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.records", response.getReturnValue());
            }
			component.set("v.spinner",false);
        });
        $A.enqueueAction(action); 
    }
})