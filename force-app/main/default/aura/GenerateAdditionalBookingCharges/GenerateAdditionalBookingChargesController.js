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
                var stampDuty =  booking.Stamp_duty__c ? booking.Stamp_duty__c : 0;
                var registrationFee =  booking.Registration_Fee__c ? booking.Registration_Fee__c : 0;
                var associationFee =  booking.Association_Deposit__c ? booking.Association_Deposit__c : 0;
                var totalAmount = stampDuty+ registrationFee;
                
                var defaultEmailContent = "<div style='color: black;'><strong>Dear " + customerName + ",</strong><br/><br/>" +
                    "Please find below the details regarding your balance payment. You are requested to kindly transfer the funds as per the instructions mentioned against each payment.<br/><br/>" +
                    
                    "<strong>1. Stamp Duty & Registration Charges - " +
                    "Rs."+totalAmount+"/- </strong> You may transfer the particular amount to the <strong>below mentioned SBI account</strong>.<br/> <br/>" +
                    "<table border='1'>" +
                    "<tr><th colspan='2' >Bank Account Details - SBI</th></tr>" +
                    "<tr><th colspan='2' style='border:none;'></th></tr>" +
                    "<tr><th>BANK NAME</th><td>STATE BANK OF INDIA</td></tr>" +
                    "<tr><th>BRANCH</th><td>COMMERCIAL BRANCH</td></tr>" +
                    "<tr><th>ACCOUNT NAME</th><td>VEEGALAND DEVELOPERS PRIVATE LIMITED</td></tr>" +
                    "<tr><th>ACCOUNT NO.</th><td>30242595690</td></tr>" +
                    "<tr><th>ACCOUNT TYPE</th><td>CURRENT ACCOUNT</td></tr>" +
                    "<tr><th>IFSC CODE</th><td>SBIN0004062</td></tr>" +
                    "</table><br/>" +
                    "<strong>2. Document Writing Fees, Valuation Certificate Cost, Clerical Expenses for Registration, Ownership Change Fees at Corporation, Payment of Building Tax in Owner’s Name - Rs. 41,000/-  (Mode of payment - Direct) As we are handing over the fund to different authorities cheque , DD or Fund transfer is not accepted</strong><br/><br/>" +
                    "<strong>Association Deposit - Rs. "+associationFee+"/- (Cheque in favour of \"Veegaland Thejus Apartment Owners Association\") </strong><br/>" +
                                     
                    "<strong>Kindly issue 2 Passport size photos at the time of registration.</strong><br/><br/>" +
                    "Please feel free to contact in case of further assistance.<br/><br/>" +
                    
                    "Thanks & Regards,<br/><br/>"+
                    
                    "<strong>Midhu Siju | Officer - Customer relations | 9207054444</strong><br/>"+
                    "<strong>Alitta Lijoy | Customer relation Executive | 90482 37066</strong><br/><br/>"+
                    
                    "<strong>Veegaland Developers Limited</strong><br/>"+
                    "Regd.Office: XXXV/564, 4TH FLOOR, <br/>"+
                    "K C F TOWER, BHARAT MATHA COLLEGE ROAD, KAKKANADU,<br/>"+
                    "Thrikkakara,Ernakulam- 682021, Kerala<br/>"+
                    "Tel: +91 484 2584000/2973944, +916235051144<br/>"+
                    
                    "<a href='http://www.veegaland.com/'>www.veegaland.com</a><br/>"+
                    
                    "follow us on: Facebook | Instagram | LinkedIn | Youtube<br/>";
                
                
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
        console.log('Here in the sendEmail 1');
        var action = component.get("c.sendExtraCostDemandMail");
        
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