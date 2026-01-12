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
                //var agreementCost = booking.Agreement_Cost__c ? booking.Agreement_Cost__c : "Not Provided";
                var customerName = salutation + " " + firstApplicant;
                //var stampDuty =  booking.Stamp_duty__c ? booking.Stamp_duty__c : 0;
                // var registrationFee =  booking.Registration_Fee__c ? booking.Registration_Fee__c : 0;
                //var associationFee =  booking.Association_Deposit__c ? booking.Association_Deposit__c : 0;
                // var totalAmount = stampDuty+ registrationFee;
                var saleExecutive = booking.Sales_Executive__c ? booking.Sales_Executive__r.Name : null;
                if (!saleExecutive) {
                    helper.showToast("error", "Missing Sales Executive", "Sales Executive is not assigned. Email cannot be sent.");
                    return;
                }
                var unitNumber = booking.Plot__r.Name;
                  var salesMangerName = booking.Sales_Manager1__c ? booking.Sales_Manager1__r.Name : null;
                
                const bookingLink = 'https://'+window.location.hostname+'/' + recordId;
                
                var defaultEmailContent = "<div style='color: black;'><strong>Dear Sir,</strong><br/><br/>" +
                    "It has been observed that in the booking for <b>" + customerName+'/'+ unitNumber+"</b>, the customer details entered/attachments uploaded by <b>" +saleExecutive+ "</b> are incorrect/incomplete. Entering accurate information at the time of booking is essential for proper documentation, communication, and compliance.<br/><br/>" +
                    
                    "Requesting correction of this record and reiteration to the sales team that customer data must be verified and correctly updated for each booking in the CRM to avoid such issues in the future.</br></br> " +
                    "You can <a href='" + bookingLink + "' target='_blank'>click here</a> to view the Booking record in Salesforce.<br/><br/>" +
                    
                    "Thanks & Regards,<br/>"+salesMangerName+"<br/>Veegaland Developers Limited"
                
                
                
                component.set("v.emailContent", defaultEmailContent);
            } else {
                console.error("Error retrieving record data");
            }
        });
        
        // Enqueue the action to call the Apex method
        $A.enqueueAction(action);
        
        
    },
    sendEmail: function(component, event, helper) {
        console.log('Inside sendEmail');
      var defaultEmails = "Kurian@veegaland.in, giri@veegaland.in";

        var additionalEmails = component.get("v.toAddresses");
        var emailContent = component.get("v.emailContent");
        
        // Validate additional emails if provided
        if (additionalEmails && additionalEmails.trim() !== "") {
            if (!helper.validateEmails(additionalEmails)) {
                helper.showToast("error", "Invalid Email Format", "One or more additional email addresses are invalid.");
                return;
            }
        }
        
        // Combine both default and additional email addresses
        var finalToAddress = defaultEmails;
        if (additionalEmails && additionalEmails.trim() !== "") {
            finalToAddress += "," + additionalEmails;
        }
        
        // Proceed to send the email
        var action = component.get("c.sendDeviationEmail");
        action.setParams({
            recId: component.get("v.recordId"),
            toAddresses: finalToAddress,
            emailContent: emailContent
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var res_string = response.getReturnValue();
                
                event.stopPropagation();
                $A.get("e.force:closeQuickAction").fire();
                
                var type = res_string === 'Email sent successfully' ? 'success' : 'error';
                helper.showToast(type, type, res_string);
                $A.get('e.force:refreshView').fire();
            } else if (state === 'ERROR') {
                console.error('Failed to send email:', response.getError());
            }
        });
        
        $A.enqueueAction(action);
    }
    ,
    close : function(component, event, helper) {
        event.stopPropagation();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
})