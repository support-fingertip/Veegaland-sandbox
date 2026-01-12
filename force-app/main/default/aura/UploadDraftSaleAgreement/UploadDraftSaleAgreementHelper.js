({
    sendFileAndEmail: function(component) {
        component.set('v.isLoading', true);
        let action = component.get("c.saveFileAndSendEmail");
        
        // Pass file details and recordId to Apex
        action.setParams({
            recordId: component.get("v.recordId"),
        });
        
        // Handle the response
        action.setCallback(this, function(response) {
             component.get('v.isLoading',false);
            let state = response.getState();
            if (state === "SUCCESS") {
                alert("File uploaded and email sent successfully.");
                helper.loadAgreementData(component);
            } else if (state === "ERROR") {
                alert("There was an error. Please try again.");
            }
        });
        
        // Enqueue the Apex action
        $A.enqueueAction(action);
    },
    sendFinalFileAndEmail: function(component, fileName, fileContent) {
        let action = component.get("c.saveFinalFileAndSendEmail");
        
        // Pass file details and recordId to Apex
        action.setParams({
            recordId: component.get("v.recordId"),
            fileName: fileName,
            fileBody: fileContent
        });
        
        // Handle the response
        action.setCallback(this, function(response) {
            component.get('v.isLoading',false);
            let state = response.getState();
            if (state === "SUCCESS") {
                alert("File uploaded and email sent successfully.");
                helper.loadAgreementData(component);
            } else if (state === "ERROR") {
                alert("There was an error. Please try again.");
            }
        });
        
        // Enqueue the Apex action
        $A.enqueueAction(action);
    },
    loadAgreementData : function(component) {
        // Show spinner
        
        
        var action = component.get("c.getAgreementDetails");
        action.setParams({ bookingId : component.get("v.recordId") });
        
        action.setCallback(this, function(response) {           
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.agreementData", result);
                component.set("v.applicantDetails", result.Email_content);
                component.set('v.disableAgreementRequest',result.Agreement_Details_Request_Send);
                component.set("v.disableDraftMail",result.Draft_Agreement_Uploaded);
                component.set("v.disableFinalDraftMail",result.FInal_Agreement_Upload_and_Email_Send);
                
                /*  var toast = $A.get("e.force:showToast");
            if (toast) {
                toast.setParams({
                    title: "Refreshed",
                    message: "Agreement data has been refreshed successfully.",
                    type: "success"
                });
                toast.fire();
            }*/
            component.set('v.isLoading', false);
        } else if (state === "ERROR") {
            var errors = response.getError();
            var message = "Unknown error"; 
            if (errors && Array.isArray(errors) && errors.length > 0) {
                message = errors[0].message;
            }
            console.error("Error loading agreement data: " + message);
            
            var toast = $A.get("e.force:showToast");
            if (toast) {
                toast.setParams({
                    title: "Error",
                    message: message,
                    type: "error"
                });
                toast.fire();
            }
            component.set('v.isLoading', false);
        }
    });
      
      $A.enqueueAction(action);
  },
    updateBookingStatus: function(component, status, rejectionComment) {
        var action = component.get("c.updateBookingVerificationStatus");
        action.setParams({
            bookingId: component.get("v.recordId"),
            status: status,
            rejectionComment: rejectionComment
        });
                console.log('Here updateBookingStatus');

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (status === 'Rejected') {
                    this.sendRejectionEmail(component, rejectionComment);
                    $A.get("e.force:showToast").setParams({
                        title: "Rejection Success",
                        message: "Rejection submitted Successfully and informed to CRM",
                        type: "success"
                    }).fire();
                }else{
                    $A.get("e.force:showToast").setParams({
                        title: "Approval Success",
                        message: "Agreement details verified sucessfully",
                        type: "success"
                    }).fire();
                }
                // Close the rejection popup if submission is successful
                component.set("v.isRejectPopupVisible", false);
            } else {
                console.error("Error in updating booking: " + response.getError());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    // Send rejection email to CRM Manager
    sendRejectionEmail: function(component, rejectionComment) {
        var action = component.get("c.sendRejectionEmail");
        action.setParams({
            bookingId: component.get("v.recordId"),
            rejectionComment: rejectionComment
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Rejection email sent successfully.");
            } else {
                console.error("Error in sending email: " + response.getError());
            }
        });
        
        $A.enqueueAction(action);
    }
    
})