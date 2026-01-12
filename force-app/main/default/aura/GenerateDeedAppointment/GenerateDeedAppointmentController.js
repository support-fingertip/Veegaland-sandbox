({
    doInit : function(component, event, helper) {
        let baseUrl = window.location.origin;
        var action = component.get("c.getBookingRecord");
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
                //var regDate = booking.Agreement_Appointment_Date__c ? booking.Agreement_Appointment_Date__c : "Not Provided";
                var regOffice = booking.Project1__r.Register_Office__c ? booking.Project1__r.Register_Office__c : "Not Provided";
                var regOfficeLocation = booking.Project1__r.Register_Office_Location__Latitude__s && booking.Project1__r.Register_Office_Location__Longitude__s ? 'https://www.google.com/maps?q=' + booking.Project1__r.Register_Office_Location__Latitude__s + ',' + booking.Project1__r.Register_Office_Location__Longitude__s : '_blank';
                var legalAdvocate  = (booking.Legal_Advocate_Assigned__r && booking.Legal_Advocate_Assigned__r.Name) ? booking.Legal_Advocate_Assigned__r.Name : "Not Provided";
                
                var registrationDate = booking.Registration_Date__c;
                var deedExpectedDate = booking.Deed_Expected_Date__c;
                
                // Construct customer name safely
                var customerName = salutation + " " + firstApplicant;
                
                // Set Booking Record
                component.set("v.bookingRecord", result.booking);
                
                // if registration date present
                 if (registrationDate) {
                var defaultEmailContent1 = "<div style='color: black;'><strong>Dear " + customerName + ",</strong><br/>" 
                +"Your sale deed appointment has been schedules as follows.<br/>"
                +"<strong>Date & Location for Registration:</strong><br/><br/>"
                +"<table border='0'>"
                +"<tr><th style='text-align:left;'>Date </th><td>: " + registrationDate + "</td></tr>"
              /*  +"<tr><th style='text-align:left;'>Location </th><td>: " + regOffice + "</td></tr>"*/
                + "<tr><th style='text-align:left; padding-right:10px;'>Location</th><td>: <a href='" + regOfficeLocation + "' target='_blank' style='color: #1a73e8; text-decoration: none;'>" + regOffice + "</a></td></tr>"
                +"<tr><th style='text-align:left;'>Advocate Name </th><td>: " + legalAdvocate + "</td></tr></table> <br/><br/>"
                +"Please ensure your presence with all required documents.<br/><br/>"
                + "<p>Thanks & Regards,</p><br/>"
                + "<p><strong>Midhu Siju | Officer - Customer Relations | 9207054444</strong></p>"
                + "<p><strong>Alitta Lijoy | Customer Relation Executive | 90482 37066</strong></p>"
                + "<br/>"
                + "<p><strong>Veegaland Developers Limited</strong></p>"
                + "<p>Regd. Office: XXXV/564, 4TH FLOOR, K C F TOWER, BHARAT MATHA COLLEGE ROAD,KAKKANADU,</p>"
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
                     component.set("v.emailContent", defaultEmailContent1);
                     
                 }
                
                 else if (deedExpectedDate) {
                
                //if deed expected date present
                 var defaultEmailContent2 = "<div style='color: black;'><strong>Dear " + customerName + ",</strong><br/>" 
                +"Your expected sale deed appointment has been schedules as follows.<br/>"
                +"<strong>Date & Location for Registration:</strong><br/><br/>"
                +"<table border='0'>"
                +"<tr><th style='text-align:left;'>Date </th><td>: " + deedExpectedDate + "</td></tr>"
              /*  +"<tr><th style='text-align:left;'>Location </th><td>: " + regOffice + "</td></tr>"*/
                + "<tr><th style='text-align:left; padding-right:10px;'>Location</th><td>: <a href='" + regOfficeLocation + "' target='_blank' style='color: #1a73e8; text-decoration: none;'>" + regOffice + "</a></td></tr>"
                +"<tr><th style='text-align:left;'>Advocate Name </th><td>: " + legalAdvocate + "</td></tr></table> <br/><br/>"
                +"Please confirm whether the expected deed date provided above works for you. If it doesn’t, please let us know a suitable alternative.<br/><br/>"
                + "<p>Thanks & Regards,</p><br/>"
                + "<p><strong>Midhu Siju | Officer - Customer Relations | 9207054444</strong></p>"
                + "<p><strong>Alitta Lijoy | Customer Relation Executive | 90482 37066</strong></p>"
                + "<br/>"
                + "<p><strong>Veegaland Developers Limited</strong></p>"
                + "<p>Regd. Office: XXXV/564, 4TH FLOOR, K C F TOWER, BHARAT MATHA COLLEGE ROAD,</p>"
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
                     component.set("v.emailContent", defaultEmailContent2);
                
                 }
                else {
                    // if both dates are missing
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "warning",
                        "title": "Missing Dates",
                        "message": "Registration Date is Unavailable. Please update before generating the email.",
                        "duration": 8000
                    });
                    toastEvent.fire();

                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();

                    return;
                }
                
                
                
                if (!component.get("v.recordId")) {
                    console.error("Record ID is missing!");
                    return;
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    sendEmail: function(component, event, helper) {
         var emailContent = component.get("v.emailContent");
        // Call the Apex method 'sendEmailGenerateSA'
        var action = component.get("c.sendFInalAppoinmentMail");
        
        // Set the parameter for the Apex method - receiptId is passed from the component
        action.setParams({recId: component.get("v.recordId"),emailContent:emailContent});
        
        // Set the callback function to handle the response from Apex
        action.setCallback(this, function(response) {
            var state = response.getState(); // Get the response state
            
            if (state === 'SUCCESS') {
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
                event.stopPropagation();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
            } else if (state === 'ERROR') {
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