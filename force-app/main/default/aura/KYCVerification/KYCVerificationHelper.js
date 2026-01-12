({
    fetchKYCData: function(component) {
        let action = component.get("c.getKYCData");
        action.setParams({ recordId: component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.kycData",result );
                console.log("KYC data: " + JSON.stringify(result));
            } else {
                console.error("Error fetching KYC data: " + response.getError());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    updateKYCData: function(component) {
        
        let isAllValid = component.find('field').reduce(function(isValidSoFar, inputCmp){
            inputCmp.showHelpMessageIfInvalid();
            return isValidSoFar && inputCmp.checkValidity();
        },true);
        
        if(isAllValid == true){
            let action = component.get("c.updateKYCData");
            action.setParams({
                recordId: component.get("v.recordId"),
                kycData: component.get("v.kycData")
            });
            
            action.setCallback(this, function(response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "KYC Verification updated successfully!.",
                        "type": "success"
                    });
                    toastEvent.fire();
                } else {
                    console.error("Error updating KYC data: " + response.getError());
                }
                $A.get('e.force:closeQuickAction').fire();
                $A.get('e.force:refreshView').fire();
            });
            
            $A.enqueueAction(action);
        }
    }
});