({
    init: function (cmp, event, helper) {
        helper.doInit(cmp, event, helper);
    },
    handleProjectChange: function (cmp, event, helper) {
        var selectedProjectId = cmp.get("v.selectedProject");
        var projectData = cmp.get("v.projectData");
        const selectedProject = projectData.find(prj => prj.projectValue === selectedProjectId);
        var selected = selectedProject ? selectedProject.paymentPlans : [];
        cmp.set("v.planOptions",selected);
    },
    handleGetMPSRecords: function (cmp, event, helper) {
        try {
            
            var paymentPlanId = cmp.get("v.selectedPlan");
            if(!paymentPlanId){
                $A.get("e.force:showToast").setParams({
                    "title": "Error",
                    "message": "Select a payment plan",
                    "type": "error"
                }).fire();
                return;
            }
            
            var action = cmp.get("c.getMPSRecords");
            action.setParams({
                "paymentPlan": paymentPlanId
            });
            
            action.setCallback(this, function (response) {
                var state = response.getState();
                
                if (state === "SUCCESS") {
                    var result = response.getReturnValue() || [];
                    
                    // Defensive check: ensure result is an array
                    if (Array.isArray(result)) {
                        var projectOptions = result.map(function (prj) {
                            return {
                                label: prj.projectLabel || "Unnamed Project",
                                value: prj.projectValue || ""
                            };
                        });
                        
                        cmp.set("v.projectData", result);
                        cmp.set("v.projectOptions", projectOptions);
                        console.log('projectOptions '+ JSON.stringify(projectOptions));
                    } else {
                        console.error("Unexpected response format:", result);
                        helper.showToast("Error", "Invalid data format received.", "error");
                    }
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.error("Error message: " + errors[0].message);
                        helper.showToast("Error", errors[0].message, "error");
                    } else {
                        console.error("Unknown error");
                        helper.showToast("Error", "An unknown error occurred.", "error");
                    }
                } else {
                    console.warn("Response state: " + state);
                    helper.showToast("Warning", "Unexpected response state: " + state, "warning");
                }
            });
            
            $A.enqueueAction(action);
        } catch (e) {
            console.error("Exception in getRelatedValues:", e);
            helper.showToast("Error", "Unexpected exception occurred.", "error");
        }
    }
    
})