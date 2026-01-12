({
    doInit : function(component, event, helper) {
        
        var recordId = component.get("v.recordId");
        var action = component.get("c.getBookingRecord");
        action.setParams({
            "recordId": recordId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var booking = result.booking;
                component.set('v.record',booking);
                if (!booking) {
                    console.error("Booking data is missing!");
                    return;
                }
                
                // Check if booking fields exist, else assign default values
                var salutation = booking.salutation_Applicant1__c ? booking.salutation_Applicant1__c : "";
                var firstApplicant = booking.First_Applicant_Name__c ? booking.First_Applicant_Name__c : "Customer";
                var project = booking.Project__c ? booking.Project__c : "N/A";
                var agreementCost = booking.Agreement_Cost__c ? booking.Agreement_Cost__c : "Not Provided";
                var customerName = salutation + " " + firstApplicant;
                
                var defaultEmailContent = 
                "<div style='color:black;'>" +
                "<p><strong>Dear " + customerName + ",</strong></p>" +
            
                "<p>We hope this message finds you well. We are pleased to inform you that the registered sale agreement for unit <strong>" 
                + (booking.Plot__r.Name || "Unit") + "</strong> at <strong>" 
                + (booking.Project__c || "your project") + "</strong> has been received from the authorities. (Attached documents for your reference)</p>" +
            
                "<p>In order to proceed with the necessary formalities, we kindly request your assistance in confirming whether you have availed a home loan for the purchase. So kindly share the bank name and contact person’s details.</p>" +
            
                "<p>If you have not availed a home loan, we kindly ask that you provide us with your courier address. We will arrange for the original documents to be sent to you promptly. Alternatively, you may collect the documents directly from our corporate office.</p>" +
            
                "<br/>" +
                "<p><strong>Thanks & Regards,</strong></p>" +
                "<p>Midhu Siju | Officer - Customer Relations | 9207054444</p>" +
                "<p>Alitta Lijoy | Customer Relations Executive | 90482 37066</p>" +
            
                "<br/>" +
                
                "<p>Follow us on: " +
                    "<a href='https://www.facebook.com' target='_blank'>Facebook</a> | " +
                    "<a href='https://www.instagram.com' target='_blank'>Instagram</a> | " +
                    "<a href='https://www.linkedin.com' target='_blank'>LinkedIn</a> | " +
                    "<a href='https://www.youtube.com' target='_blank'>YouTube</a>" +
                "</p>" +
            
                "</div>";

                
                component.set("v.emailContent", defaultEmailContent);
            } else {
                console.error("Error retrieving record data");
            }
        });
        
        $A.enqueueAction(action);
    },
    handleFileUpload: function(component, event, helper) {
        var files = event.getParam("files");
        var getFiles = component.get("v.filesIDS");
        getFiles.push(...files);
        component.set('v.filesIDS',getFiles);
        
        var afercomit = component.get('v.filesIDS');
        console.log('aftercommit:'+afercomit);
    },
    sendEmail: function(component, event, helper) {
        console.log('sendEmail(1)');
        var recList = component.get('v.recepients');
        var allFiles = component.get('v.files');
        var contentDocumentIds = component.get('v.filesIDS');
        var modifiedEmailContent = component.get("v.emailContent");
        var loggedInUserName = component.get("v.loggedInUserName");
        var loggedInUserPhone = component.get("v.loggedInUserPhone");
        var loggedInUserEmail = component.get("v.loggedInUserEmail");
        var record = component.get("v.record");
         console.log('sendEmail(2)');
        var toAddresses = [];
        if(recList) {
            var recList = recList.split(',');
            recList.forEach(function(email) {
                toAddresses.push(email.trim());
            });
        }
         console.log('sendEmail(3)');
        if (record.Email1__c) {
            toAddresses.push(record.Email1__c);
        }
         console.log('sendEmail(4)');
        if (toAddresses.length === 0) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "No email address available to send the email.",
                "type": "error"
            });
            toastEvent.fire();
            return;
        }
         console.log('sendEmail(5)');
        var action = component.get("c.sendRegisterdAgreement");
        action.setParams({
            "recId": component.get("v.recordId"),
            // "toAddresses": toAddresses,
            "emailContent": modifiedEmailContent,
            "contentIds": contentDocumentIds
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Email Sent Successfully.",
                    "type": "success"
                });
                toastEvent.fire();
                
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            } else {
                console.error("Error sending email");
            }
        });
        
        $A.enqueueAction(action);
    },
    Cancel: function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})