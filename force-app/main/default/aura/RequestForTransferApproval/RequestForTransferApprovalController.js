({
    doInit: function(component, event, helper) {
        var action = component.get("c.getBookingDetails");
        var bookingId = component.get("v.recordId");
        
        action.setParams({ bookingId: bookingId });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var booking = response.getReturnValue();
                console.log('Project1__c: ' + booking.Project1__c);
                component.set("v.projectId", booking.Project1__c);
                var query = "Project__c = '" + booking.Project1__c + "' AND Status__c = 'Available'";
                component.set("v.query", query);
            } else {
                var errors = response.getError();
                console.error("Error fetching booking details:", errors);
                helper.showToast("Error", "Failed to fetch booking details", "error");
            }
        });
        
        $A.enqueueAction(action);
    },
    
    sendRequest : function(component, event, helper) {
        var action = component.get("c.requestTransferApproval");  
        action.setParams({
            recId: component.get('v.recordId'),
            selectedPlotId: component.get('v.selectedPlot.Id')
        });
        
        action.setCallback(this, function(response){
            var res = response.getReturnValue();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": res.success ? "Success!" : "Error!",
                "message": res.message,
                "type": res.success ? "success" : "error"
            });
            toastEvent.fire();
            
            if (res.success) {
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        
        $A.enqueueAction(action);
    },
    
    closeModel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:closeQuickAction').fire();
        $A.get('e.force:refreshView').fire();
    },
})