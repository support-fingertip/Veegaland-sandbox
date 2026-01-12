({
    doInit : function(component, event, helper) {
        let baseUrl = window.location.origin;
        var action = component.get("c.getSaleAgreement");
        action.setParams({recordId :component.get("v.recordId") });     
        action.setCallback(this,function(response){   
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                var booking = result.booking;
                
                if (!booking) {
                    console.error("Booking data is missing!");
                    return;
                }
                
                // Check if booking fields exist, else assign default values
                var salutation = booking.salutation_Applicant1__c ? booking.salutation_Applicant1__c : "";
                var firstApplicant = booking.First_Applicant_Name__c ? booking.First_Applicant_Name__c : "Customer";
                var project = booking.Project__c ? booking.Project__c : "N/A";
                
                // Construct customer name safely
                var customerName = salutation + " " + firstApplicant;
                var secureLink = 'https://site-speed-6226--postsbox1.sandbox.my.salesforce-sites.com/AgreementApproval?id='+booking.Id;
                // Set Booking Record
                component.set("v.bookingRecord", result.booking);
                
                // Construct email content with safe values
                var defaultEmailContent = "<div style='color: black;'><strong>Dear " + customerName + ",</strong><br/><br/>" +
                    "We hope this message finds you well.<br/>" +
                    "Please find below a secure link to review the draft version of your agreement:<br/>" +
                    "Secure Link: <a href='" + secureLink + "' style='color: blue; text-decoration: underline;' target='_blank'>Click here to review the agreement</a><br/>" +
                    "You can add your comments or suggestions directly through the review page. This link has also been sent to your WhatsApp for your convenience.<br/>" +
                    "If you have any questions or need assistance, feel free to reach out to us.<br/>"
                + "<p>Thanks & Regards,</p><br/>"
                + "<p><strong>Midhu Siju | Officer - Customer Relations | 9207054444</strong></p>"
                + "<p><strong>Alitta Lijoy | Customer Relation Executive | 90482 37066</strong></p>"
                + "<br/>"
                + "<p><strong>Veegaland Developers Pvt. Ltd.</strong></p>"
                + "<p>Regd. Office: XIII/300 E-26, 4th Floor, K Chittilappilly Tower, BMC Road,</p>"
                + "<p>Thrikkakara P.O, Ernakulam-682021</p>"
                + "<p>Tel: +91 484 2584000 / 2973944, +91 6235051144</p>"
                + "<p><a href='https://www.veegaland.com' target='_blank'>www.veegaland.com</a></p>"
                + "<br/>"
                + "<p>Follow us on: "
                + "<a href='https://www.facebook.com' target='_blank'>Facebook</a> | "
                + "<a href='https://www.instagram.com' target='_blank'>Instagram</a> | "
                + "<a href='https://www.linkedin.com' target='_blank'>LinkedIn</a> | "
                + "<a href='https://www.youtube.com' target='_blank'>YouTube</a>"
                + "</p>"
                + "</div>";
                
                component.set("v.emailContent", defaultEmailContent);
                
                // Validate agreement type and recordId
                if (!result.agreementType) {
                    console.error("Agreement type is missing!");
                    return;
                }
                if (!component.get("v.recordId")) {
                    console.error("Record ID is missing!");
                    return;
                }
                
                // Construct VF Page URL safely
                let url = baseUrl + '/apex/' + result.agreementType + '?Id=' + component.get("v.recordId");
                component.set("v.vfPageUrl", url);
                
            }
        });
        $A.enqueueAction(action);
    },
    sendEmail: function(component, event, helper) {
        console.log('Sending email...');
        
        // Prepare action to call Apex method
        var action = component.get("c.sendEmailGenerateSA");
        var emailContent = component.get("v.emailContent");
        
        action.setParams({
            recId: component.get("v.recordId"),
            emailContent: emailContent
        });
        
        // Handle callback from server
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('Apex response state:', state);
            
            if (state === "SUCCESS") {
                var resultMessage = response.getReturnValue();
                console.log('Apex response message:', resultMessage);
                
                // Close the quick action panel if it exists
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                if (dismissActionPanel) {
                    dismissActionPanel.fire();
                }
                
                // Determine toast type
                var toastType = resultMessage === 'Email sent successfully' ? 'success' : 'error';
                
                // Show toast notification
                var toastEvent = $A.get("e.force:showToast");
                if (toastEvent) {
                    toastEvent.setParams({
                        type: toastType,
                        title: toastType === 'success' ? 'Success' : 'Error',
                        message: resultMessage,
                        duration: 10000
                    });
                    toastEvent.fire();
                }
                
                // Refresh view
                $A.get('e.force:refreshView').fire();
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error('Apex error:', errors);
                
                var toastEvent = $A.get("e.force:showToast");
                if (toastEvent) {
                    toastEvent.setParams({
                        type: 'error',
                        title: 'Error',
                        message: errors && errors[0] && errors[0].message ? errors[0].message : 'Unknown error',
                        duration: 10000
                    });
                    toastEvent.fire();
                }
            }
        });
        
        // Enqueue action to run
        $A.enqueueAction(action);
    },
    
    close : function(component, event, helper) {
        event.stopPropagation();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
})