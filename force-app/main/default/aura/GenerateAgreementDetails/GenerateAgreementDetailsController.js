({
    doInit : function(component, event, helper) {
        
        var recordId = component.get("v.recordId");
        var action = component.get("c.getBookingAndApplicantDetails");
        action.setParams({
            "recId": recordId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var applicants = response.getReturnValue();
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
                console.log('emailContent'+defaultEmailContent);
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
        var action = component.get("c.sendEmailGenerateAgreementdetailsrequest");
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