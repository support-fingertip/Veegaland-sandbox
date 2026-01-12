({
    
    closeModel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:closeQuickAction').fire();
        $A.get('e.force:refreshView').fire();
    },
    sendRequest : function(component, event, helper) {
        var action = component.get("c.bypassStagetoDraftAgreement");
        action.setParams({
            recId: component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var errorMessage = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                if (!errorMessage || errorMessage.trim() === '') {
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Booking stage is successfully moved to Draft Agreement Preperation.",
                        "type": "success"
                    });
                    // Optionally refresh view and close modal on success
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                } else {
                    // If errorMessage is returned, show it as an error toast
                    toastEvent.setParams({
                        "title": "Error",
                        "message": errorMessage,
                        "type": "error"
                    });
                }
                toastEvent.fire();
            } else if (state === "ERROR") {
                var errors = response.getError();
                var message = "An unknown error occurred while sending the request.";
                if (errors && errors[0] && errors[0].message) {
                    message = errors[0].message;
                }
                var errorToastEvent = $A.get("e.force:showToast");
                errorToastEvent.setParams({
                    "title": "Error",
                    "message": message,
                    "type": "error"
                });
                errorToastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
    
})