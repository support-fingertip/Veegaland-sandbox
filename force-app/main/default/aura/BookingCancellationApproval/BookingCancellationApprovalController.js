({
   doInit: function(component) {
        var action = component.get("c.getCancellationStatus");
        action.setParams({ bookingId: component.get("v.recordId") });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var isRequested = response.getReturnValue();
                if (isRequested) {
                    $A.get('e.force:closeQuickAction').fire();
                    $A.get('e.force:refreshView').fire();
                    
                    // Show toast
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Info",
                        message: "Cancellation process is already ongoing.",
                        type: "info",
                        mode: "dismissible"
                    });
                    toastEvent.fire();
                }
            } else {
                console.error('Failed to check cancellation status');
            }
        });

        $A.enqueueAction(action);
    },
    
    handleCheckboxChange : function(component, event, helper) {
        var isChecked = event.getSource().get("v.checked");
        component.set("v.postAgreementCancellation", isChecked);
    },
    
    closeModel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:closeQuickAction').fire();
        $A.get('e.force:refreshView').fire();
    },
  sendRequest : function(component, event, helper) {
    var action = component.get("c.bookingCancellationApproval");
    action.setParams({
        recId: component.get('v.recordId'),
        cancellationCharges: component.get("v.cancellationCharges"),
        postAgreement: component.get("v.postAgreementCancellation"),
        originalAgreement: component.get("v.originalAgreementCollected")
    });
    action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            var errorMessage = response.getReturnValue();
            var toastEvent = $A.get("e.force:showToast");
            if (!errorMessage || errorMessage.trim() === '') {
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The Request submitted for booking Cancellation.",
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