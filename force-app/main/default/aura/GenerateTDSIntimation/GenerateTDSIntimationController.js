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
                var totalPaid = booking.Received_Amount_TAX_exclude__c ? booking.Received_Amount_TAX_exclude__c : "Not Provided";
                var customerName = salutation + " " + firstApplicant;
                var tdsAmount = Math.round(totalPaid *0.01);
                var today = new Date();
                var dueDate = new Date();
                dueDate.setDate(today.getDate() + 7); // Add 7 days
                
                // Format as YYYY-MM-DD (if needed)
                var formattedDueDate = dueDate.getFullYear() + '-' + 
                    ('0' + (dueDate.getMonth() + 1)).slice(-2) + '-' + 
                    ('0' + dueDate.getDate()).slice(-2);
                
                var defaultEmailContent = "<div style='color: black;'>"
                + "<p><strong>Dear " + customerName + ",</strong></p><br/>"
                + "<p>We hope this email finds you well.</p><br/>"
                + "<p>As per the provisions of the Income Tax Act, your transactions have exceeded ₹50,00,000 during the financial year. Consequently, Tax Deducted at Source (TDS) is applicable on further payments made to you under Section 194Q.</p><br/>"
                + "<p><strong>Details of Transactions:</strong></p>"
                + "<ul>"
                + "<li>Total Amount Crossed: <strong>Rs."+totalPaid+"/-</strong></li>"
                + "<li>TDS Rate Percentage: <strong>1%</strong></li>"
                + "<li>TDS Rate Applicable: <strong>Rs."+tdsAmount+"/-</strong></li>"
                + "<li>Due Date for Payment: <strong>"+formattedDueDate+"</strong></li>"
                + "</ul><br/>"
                + "<p>To ensure compliance, we kindly request you to pay the applicable TDS amount and submit the challan copy for verification.</p><br/>"
                + "<p><strong>Steps for Payment & Submission:</strong></p>"
                + "<ol>"
                + "<li>Make the TDS payment using the appropriate tax portal.</li>"
                + "<li>Upload the challan copy using the following link: <a href='https://site-speed-6226--postsbox1.sandbox.my.salesforce-sites.com/TDSChallanCopy?Id="+recordId+"'>Upload Challan</a></li>"
                + "</ol><br/>"
                + "<p>Your prompt action on this matter will be highly appreciated. Should you require any assistance, please feel free to reach out.</p><br/>"
                + "<p>Looking forward to your acknowledgment of this intimation.</p><br/>"
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