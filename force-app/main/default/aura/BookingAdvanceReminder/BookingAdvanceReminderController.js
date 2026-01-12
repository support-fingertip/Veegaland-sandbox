({
    doInit : function(component, event, helper) {
        var action = component.get("c.getBookingRecord");
        action.setParams({ "recordId": component.get("v.recordId") });
        console.log('Here doInit');
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                let result = response.getReturnValue();
                var b = result.booking;
                component.set("v.bookingRecord", b);
                console.log('Here response.getState');
                let emails = [];
                // Convert amount to words (you can fetch from Apex if needed)
                let amountInWords = 'Rupees ' + result.balanceAmountWords; 
                var customerNames = result.customerNames;
                console.log('Here response.getState1');
                let emailBody =
                    'Dear Sir/Madam, <br/><br/>' +
                   '<b>Greetings from Veegaland Developers !!</b> <br/>' +
                    'Hope this mail finds you in good health and spirit. <br/><br/>' +
                    'Sub: Requisition for release of instalment.<br/>' +
                    'Ref: <b>' + (b.Project1__r ? b.Project1__r.Name : '') +
                     '</b>, <b>Unit Number - </b>' + (b.Plot__r ? b.Plot__r.Name : '') + ' - '+ customerNames+'. <br/><br/>' +
                        'This is to remind you that an amount of <b> INR ' + b.Balance_Advance_Amount__c +
                        '/- (' + amountInWords + ')</b>' +
                        ' will be due against apartment No. <b>' + (b.Plot__r ? b.Plot__r.Name : '') +
                        'NOTE: Collection of advance above 10% from the customer which is in contravention of section 13(1) of Real Estate (Regulation & Development).<br/><br/>' +
                        'Request you to kindly pay separately in the below mentioned bank account:<br/><br/>' +
                        
                        'Bank: '+b.Project1__r.Bank_Name__c+'<br/>' +
                        'Account No: '+b.Project1__r.Beneficiary_Account_No__c+'<br/>' +
                        'IFSC: '+b.Project1__r.IFSC_CODE__c+'<br/>' +
                        'SWIFT: '+b.Project1__r.SWIFT_CODE__c+'<br/>' +
                        'Branch: '+b.Project1__r.Branch_Name__c+'<br/><br/>' +
                        '</b> at <b>' + (b.Project1__r ? b.Project1__r.Name : '') + '</b><br/><br/>' +
                        '<p>Please ensure to clear the pending amount at your earliest convenience.</p>' +
                        '<p>Thank you for your attention to this matter.</p>' +
                        "Thanks & Regards,<br/><br/>"+
                        "<strong>Midhu Siju | Officer - Customer relations | 9207054444</strong><br/>"+
                        "<strong>Alitta Lijoy | Customer relation Executive | 90482 37066</strong><br/><br/>"+
                        "<strong>Veegaland Developers Limited</strong><br/>"+
                        "Regd.Office:XXXV/564, 4TH FLOOR, <br/>"+
                        "K C F TOWER, BHARAT MATHA COLLEGE ROAD, KAKKANADU, <br/>"+
                        "Thrikkakara,Ernakulam- 682021, Kerala<br/>"+
                        "Tel: +91 484 2584000/2973944, +916235051144<br/>"+
                        "<a href='http://www.veegaland.com/'>www.veegaland.com</a><br/>"+
                        "follow us on: Facebook | Instagram | LinkedIn | Youtube<br/>";
                console.log('Here response.getState2');
                component.set("v.emailContent", emailBody);
                console.log('Here response.getState3');
            } else {
                console.error('Error:', response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    sendEmail: function(component, event, helper) {
        console.log('Here in the sendEmail');
        const modifiedEmailContent =  component.get("v.emailContent");
        var action = component.get("c.sendAdvanceReminderEmail");
        // Set the parameter for the Apex method - receiptId is passed from the component
        action.setParams({
            "bookingId": component.get("v.recordId"),
            "emailContent": modifiedEmailContent
        });
        console.log('Here in the sendEmail 3');
        // Set the callback function to handle the response from Apex
        action.setCallback(this, function(response) {
            var state = response.getState(); // Get the response state
            if (state === 'SUCCESS') {
                console.log('Here in the sendEmail 4');
                // Retrieve the return value from the Apex method
                //var res_string = response.getReturnValue();
                
                // Stop the event propagation
                event.stopPropagation();
                
                // Close the quick action panel
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                
                // Determine the toast type based on the response
                //var type = res_string === 'Email sent successfully' ? 'success' : 'error';
                
                // Show toast notification
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": 'success',
                    "title": 'Success',
                    "message": 'Email sent successfully',
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