({
    handleSendNotification: function(component, event, helper) {
        const message = component.get("v.notificationMessage");
        const action = component.get("c.sendNotification");
        action.setParams({ targetid: 'a005h000012x6yfAAA' });

        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                alert("Notification sent successfully!");
            } else {
                alert("Failed to send notification: " + response.getError());
            }
        });

        $A.enqueueAction(action);
    },
	 handleSendtaskNotification: function(component, event, helper) {
        const message = component.get("v.notificationMessage");
        const action = component.get("c.sendtaskNotification");
        action.setParams({ targetid: 'a005h000012x6yfAAA' });

        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                alert("Notification sent successfully!");
            } else {
                alert("Failed to send notification: " + response.getError());
            }
        });

        $A.enqueueAction(action);
    },

    handleSendEmail: function(component, event, helper) {
        const subject = 'Booking Form';
        const action = component.get("c.sendEmail");
        action.setParams({ subject: subject });

        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                alert("Email sent successfully!");
            } else {
                alert("Failed to send email: " + response.getError());
            }
        });

        $A.enqueueAction(action);
    },
    
    handleKYCSendEmail: function(component, event, helper) {
        const subject = 'KYC Documents Upload';
        const action = component.get("c.sendKYCEmail");
        action.setParams({ subject: subject });

        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                alert("Email sent successfully!");
            } else {
                alert("Failed to send email: " + response.getError());
            }
        });

        $A.enqueueAction(action);
    },
    handleRecpSendEmail: function(component, event, helper) {
        
        const subject = 'Payment Recived';
        const action = component.get("c.sendReciEmail");
        action.setParams({ subject: subject });

        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                alert("Email sent successfully!");
            } else {
                alert("Failed to send email: " + response.getError());
            }
        });

        $A.enqueueAction(action);
    },
    handleRecsafSendEmail: function(component, event, helper) {
        const subject = 'Payment Recived';
        const action = component.get("c.sendReciafterEmail");
        action.setParams({ subject: subject });

        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                alert("Email sent successfully!");
            } else {
                alert("Failed to send email: " + response.getError());
            }
        });

        $A.enqueueAction(action);
    },
    handleWelcomSendEmail: function(component, event, helper) {
        const subject = 'Welcome to Veegaland world';
        const action = component.get("c.sendWelcomEmail");
        action.setParams({ subject: subject });

        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                alert("Email sent successfully!");
            } else {
                alert("Failed to send email: " + response.getError());
            }
        });

        $A.enqueueAction(action);
    },
    handleParkinglayoutSendEmail: function(component, event, helper) {
        const subject = 'Parking layout selection';
        const action = component.get("c.sendParklyouEmail");
        action.setParams({ subject: subject });

        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                alert("Email sent successfully!");
            } else {
                alert("Failed to send email: " + response.getError());
            }
        });

        $A.enqueueAction(action);
    },
    handleCoapplicantSendEmail: function(component, event, helper) {
        const subject = 'Co Applicant details';
        const action = component.get("c.sendCoapplicantEmail");
        action.setParams({ subject: subject });

        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                alert("Email sent successfully!");
            } else {
                alert("Failed to send email: " + response.getError());
            }
        });

        $A.enqueueAction(action);
    },
    handleDraftAggteementSendEmail: function(component, event, helper) {
        const subject = 'Draft Agreement';
        const action = component.get("c.sendDraftAgreenEmail");
        action.setParams({ subject: subject });

        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                alert("Email sent successfully!");
            } else {
                alert("Failed to send email: " + response.getError());
            }
        });

        $A.enqueueAction(action);
    },
    handleBalanceAmountSendEmail: function(component, event, helper) {
        const subject = 'Requisition for release of instalment.';
        const action = component.get("c.sendBalanceAmountEmail");
        action.setParams({ subject: subject });

        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                alert("Email sent successfully!");
            } else {
                alert("Failed to send email: " + response.getError());
            }
        });

        $A.enqueueAction(action);
    },
});