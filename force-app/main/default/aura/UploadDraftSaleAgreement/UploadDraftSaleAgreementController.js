({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        helper.loadAgreementData(component);
    },
    handleRefresh : function(component, event, helper) {
        // Simply call doInit again
        component.set('v.isLoading', true);
        helper.loadAgreementData(component);
        //$A.get('e.force:refreshView').fire();
        //component.set('v.isLoading', false);
	    },

     handleDraftUploaded: function(component, event, helper) {
       
        var eventuploaded = event.getParam('uploaded');
        var eventdocumentname = event.getParam('documentname');
        var eventdocumentid = event.getParam('documentid');

        component.set("v.fileName", eventdocumentname);
        component.set("v.draftdocumentId", eventdocumentid);
        component.set("v.draftuploaded", eventuploaded);

         var action = component.get("c.updateBookingURL");

         action.setParams({
            "bookingId": component.get("v.recordId"),
            "documentId": eventdocumentid
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if (state === 'SUCCESS') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": 'Success',
                    "message": 'Draft Agreement Uploaded Successfully',
                    "duration": 10000
                });
                toastEvent.fire();
            } else if (state === 'ERROR') {
                console.log('Here in the sendEmail 5');
                 var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": 'Error',
                    "message": 'Failed to send email',
                    "duration": 10000
                });
                console.log('Failed to send email: ', response.getError());
            }
        });
    },

    handleFinalFileChange: function(component, event, helper) {
       
        var eventuploaded = event.getParam('uploaded');
        var eventdocumentname = event.getParam('documentname');
        var eventdocumentid = event.getParam('documentid');

        component.set("v.finalFileName", eventdocumentname);
        component.set("v.finaldocumentId", eventdocumentid);
        component.set("v.finaluploaded", eventuploaded);

        var action = component.get("c.updatefinalSaleAgreementUpload");

         action.setParams({
            "bookingId": component.get("v.recordId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if (state === 'SUCCESS') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": 'Success',
                    "message": 'Draft Agreement Uploaded Successfully',
                    "duration": 10000
                });
                toastEvent.fire();
            } else if (state === 'ERROR') {
                console.log('Here in the sendEmail 5');
                 var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": 'Error',
                    "message": 'Failed to send email',
                    "duration": 10000
                });
                console.log('Failed to send email: ', response.getError());
            }
        });
    },

   
    // Handle Send Button click
    handleSendClick: function(component, event, helper) {
        component.get('v.isLoading',true);
        // Call Apex to save the file in Salesforce and send email
        helper.sendFileAndEmail(component);
        component.set("v.disableDraftMail",false);
        helper.loadAgreementData(component);
    },
    
    handleFinalSendClick: function(component, event, helper) {
        component.get('v.isLoading',true);
        let fileContent = component.get("v.finalFileContent");
        let fileName = component.get("v.finalFileName");
        component.set("v.disableFinalDraftMail",true);
        
        if (!fileContent) {
            alert("Please upload a file first.");
            return;
        }
        
        // Call Apex to save the file in Salesforce and send email
        helper.sendFinalFileAndEmail(component, fileName, fileContent);
        component.set("v.disableFinalDraftMail",false);
        helper.loadAgreementData(component);
    },
    
    sendAgreementDetail: function(component, event, helper) {

        component.set('v.disableAgreementRequest',true);
        var recordId = component.get("v.recordId");
        var applicants = component.get('v.applicantDetails');
        var customerName = '';
        // Extract and set Primary Applicant Name
        if (applicants.length > 0) {
            customerName = applicants[0].applicantName;
        }
        var defaultEmailContent = "<div style='color: black;'>Dear <strong>" + customerName+"</strong>,";
        defaultEmailContent += "<br/><br/><strong>Greetings From Veegaland Developers.</strong><br/><br/>"+
            "<table border='1' style='border-collapse:collapse;width:100%;'>"+
            "<tr><th colspan='2'>Details</th></tr>";
        for (var i = 0; i < applicants.length; i++) {
            var app = applicants[i];
            
            defaultEmailContent += "<tr><th colspan='2' style='background-color:#f2f2f2;'>Applicant " + (i+1) + "</th></tr>";
            defaultEmailContent += "<tr><th>Name</th><td>" + (app.applicantName || "--") + "</td></tr>";
            defaultEmailContent += "<tr><th>Email</th><td>" + (app.applicantEmail || "--") + "</td></tr>";
            defaultEmailContent += "<tr><th>Occupation</th><td>" + (app.profession || "--") + "</td></tr>";
            defaultEmailContent += "<tr><th>District</th><td> -- </td></tr>";
            defaultEmailContent += "<tr><th>Village office / Panchayath</th><td> -- </td></tr>";
            defaultEmailContent += "<tr><th>Taluk</th><td> -- </td></tr>";
            defaultEmailContent += "<tr><th>Desom / Kara</th><td> -- </td></tr>";
            defaultEmailContent += "<tr><th>Post office</th><td> -- </td></tr>";
        }

        defaultEmailContent += "</table><br/><br/>" +
            "Click the secure link to provide the required information and fill in the necessary details for agreement preparation.<br/>" +
            "Link:<a href='https://site-speed-6226--postsbox1.sandbox.my.salesforce-sites.com/AgreementDetails?id="+recordId+"'>Agreement Details Link</a><br/><br/>"+
            "Your prompt response will help us proceed with agreement execution smoothly.<br/>" +
            "If you have any questions or need assistance, feel free to reach out to our team.<br/>" +
            "Please ensure all required details are provided to avoid any delays.<br/>";
        "Thanks & Regards,<br/><br/>"+
            "<strong>Midhu Siju | Officer - Customer relations | 9207054444</strong><br/>"+
            "<strong>Alitta Lijoy | Customer relation Executive | 90482 37066</strong><br/><br/>"+
            "<strong>Veegaland Developers Pvt.Ltd.</strong><br/>"+
            "Regd.Office:XIII/300 E-26, 4th Floor,<br/>"+
            "K  Chittilappilly  Tower,  BMC Road,<br/>"+
            "Thrikkakara P.O, Ernakulam-682021<br/>"+
            "Tel: +91 484 2584000/2973944, +916235051144<br/>"+
            "<a href='http://www.veegaland.com/'>www.veegaland.com</a><br/>"+
            "follow us on: Facebook | Instagram | LinkedIn | Youtube<br/>";
        const modifiedEmailContent =  defaultEmailContent;
        var action = component.get("c.sendAgreementdetailsrequest");
        // Set the parameter for the Apex method - receiptId is passed from the component
        action.setParams({
            "recId": component.get("v.recordId"),
            "emailContent": modifiedEmailContent
        });
        // Set the callback function to handle the response from Apex
        action.setCallback(this, function(response) {
            var state = response.getState(); // Get the response state
            if (state === 'SUCCESS') {
                // Retrieve the return value from the Apex method
                var res_string = response.getReturnValue();
                component.set('v.disableAgreementRequest',false);
                // Stop the event propagation
                event.stopPropagation();
                
                // Close the quick action panel
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                
                // Determine the toast type based on the response
                var type = res_string === 'Email sent successfully.' ? 'success' : 'error';
                
                // Show toast notification
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": type,
                    "title": type,
                    "message": res_string,
                    "duration": 10000
                });
                toastEvent.fire();
                
                // Refresh the view to reflect changes
                $A.get('e.force:refreshView').fire();
                helper.loadAgreementData();
            } else if (state === 'ERROR') {
                console.log('Here in the sendEmail 5');
                component.set('v.disableAgreementRequest',false);
                // Handle error case
                console.log('Failed to send email: ', response.getError());
            }
        });
        
        // Enqueue the action to call the Apex method
        $A.enqueueAction(action);
    },
    // Handle Verified button click
    handleVerified: function(component, event, helper) {
        // Implement the logic for marking as verified if needed
        helper.updateBookingStatus(component, 'Verified');
        helper.loadAgreementData(component);
    },
    
    // Handle Reject button click
    handleReject: function(component, event, helper) {
        component.set("v.isRejectPopupVisible", true); // Show rejection popup
    },
    
    // Close the rejection popup
    closeRejectPopup: function(component, event, helper) {
        component.set("v.isRejectPopupVisible", false); // Hide rejection popup
        helper.loadAgreementData(component);
    },
    
    // Handle the rejection submission
    handleSubmitRejection: function(component, event, helper) {
        var rejectionComment = component.get("v.rejectionComment");
        if (rejectionComment) {
            helper.updateBookingStatus(component, 'Rejected', rejectionComment); // Update booking and send email
            helper.loadAgreementData(component);
        } else {
            // Handle case when no rejection comment is provided
            alert("Please provide a rejection comment.");
        }
    },
    handleSubmitApproval : function(component, event, helper) {
        var action = component.get("c.submitForApproval");
        action.setParams({ bookingId : component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                $A.get("e.force:showToast").setParams({
                    title: "Success",
                    message: result,
                    type: "success"
                }).fire();
                $A.get("e.force:refreshView").fire();
            } else {
                var errors = response.getError();
                $A.get("e.force:showToast").setParams({
                    title: "Error",
                    message: errors && errors[0] ? errors[0].message : "Unknown error",
                    type: "error"
                }).fire();
            }
        });
        $A.enqueueAction(action);
    }
})