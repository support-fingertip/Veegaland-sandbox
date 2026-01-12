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
                
                var defaultEmailContent = "<div style='color: black;'>"
                + "<p><strong>Dear "+ customerName +"</strong>,</p><br/>"
                + "<p><strong>Greetings From Veegaland Homes!!</strong></p><br/>"
                + "<p>Please find the details of the expenses and payments in regard to the registration of your sale agreement mentioned below. "
                + "You are requested to kindly go through the same and transfer the funds in the manner mentioned against each payment.</p>"
                + "<p><strong>Registration Charges - Rs. "+agreementCost+"/-</strong> You may transfer the particular amount to the below mentioned SBI account.</p>"
                + "<br/>"
                + "<table border='1' cellspacing='0' cellpadding='5' style='border-collapse: collapse; width: 100%; text-align: left;'>"
                + "<tr><th>BANK NAME</th><td>STATE BANK OF INDIA</td></tr>"
                + "<tr><th>BRANCH</th><td>COMMERCIAL BRANCH</td></tr>"
                + "<tr><th>ACCOUNT NAME</th><td>VEEGALAND DEVELOPERS PRIVATE LIMITED.</td></tr>"
                + "<tr><th>ACCOUNT NO.</th><td>30242595690</td></tr>"
                + "<tr><th>ACCOUNT TYPE</th><td>CURRENT ACCOUNT</td></tr>"
                + "<tr><th>IFSC CODE</th><td>SBIN0004062</td></tr>"
                + "</table>"
                + "<br/>"
                + "<p><strong>Passport size photo - 1 nos of each applicant</strong></p>"
                + "<br/>"
                + "<p>Thanks & Regards,</p><br/>"
                + "<p><strong>Midhu Siju | Officer - Customer Relations | 9207054444</strong></p>"
                + "<p><strong>Alitta Lijoy | Customer Relation Executive | 90482 37066</strong></p>"
                + "<br/>"
                + "<p><strong>VEEGALAND DEVELOPERS LIMITED.</strong></p>"
                + "<p>Regd. Office:  XXXV/564, 4TH FLOOR, K C F TOWER, BHARAT MATHA COLLEGE ROAD,</p>"
                + "<p>KAKKANADU, Thrikkakara,Ernakulam- 682021, Kerala</p>"
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
            } else {
                console.error("Error retrieving record data");
            }
        });
        
        $A.enqueueAction(action);
    },
    sendEmail: function(component, event, helper) {
        console.log('Here in the sendEmail');
        const modifiedEmailContent =  component.get("v.emailContent");
        console.log('modifiedEmailContent'+modifiedEmailContent);
        console.log('Here in the sendEmail 1');
        var action = component.get("c.sendAgreementCostMail");
        
        // Set the parameter for the Apex method - receiptId is passed from the component
        action.setParams({
            "recId": component.get("v.recordId"),
            "emailContent": modifiedEmailContent
        });
        console.log('Here in the sendEmail 3');
        // Set the callback function to handle the response from Apex
        action.setCallback(this, function(response) {
            var state = response.getState(); // Get the response state
            if (state === 'SUCCESS') {
                console.log('Here in the sendEmail 4');
                // Retrieve the return value from the Apex method
                var res_string = response.getReturnValue();
                
                // Stop the event propagation
                event.stopPropagation();
                
                // Close the quick action panel
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                
                // Determine the toast type based on the response
                var type = res_string === 'Email sent successfully' ? 'success' : 'error';
                
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
            } else if (state === 'ERROR') {
                console.log('Here in the sendEmail 5');
                // Handle error case
                console.log('Failed to send email: ', response.getError());
            }
        });
        
        // Enqueue the action to call the Apex method
        $A.enqueueAction(action);
    },
    close : function(component, event, helper) {
        event.stopPropagation();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
})