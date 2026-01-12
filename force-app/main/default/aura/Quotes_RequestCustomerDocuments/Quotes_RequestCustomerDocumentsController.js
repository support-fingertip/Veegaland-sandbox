({
    doInit: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getQuoteData");
        action.setParams({
            "recordId": recordId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result '+JSON.stringify(result));
                var customerName = result.Lead_Name__c;
                var salesExecutiveName = result.Owner.Name;
                var salesExecutiveEmail = result.Owner.Email || '';
                var salesExecutivePhone = result.Owner.Phone || '';
                var encryptedId = result.Encrypted_Key__c;
                var customerEmail = result.Lead_Email__c;
                component.set("v.ownerEmail",salesExecutiveEmail);
                component.set("v.ownerPhone",salesExecutivePhone);
                component.set("v.ownerName",salesExecutiveName);
                component.set("v.customerEmail",customerEmail);
                //console.log('Encription'+result.Encrypted_Key__c);
                var defaultEmailContent = "<div style='color: black;'><strong>Dear " + customerName +",</strong></div>" ;
                
                defaultEmailContent += "<div style='color: black;'><br/>Thank you for choosing Veegaland Homes. To proceed with your booking, we kindly request you to upload the following documents of yourself and co-applicants if applicable:"+
                    "<br/> <br/><strong>Required Documents:</strong>"+
                    " <br/> <br/>Aadhaar Card</br>Passport (if applicable)<br/>PAN Card"+
                    "<br/><br/><strong>Instructions:</strong><br/><br/>"+
                    "Formats Accepted: PDF, JPG, PNG<br/>Maximum File Size: 10 MB per document<br/>Deadline: Please upload your documents by [Deadline Date].<br/>Upload Link: <a href='https://site-speed-6226--postsbox1.sandbox.my.salesforce-sites.com/BookingForm?Id="+recordId+"' >Update Booking Details</a> <br/><br/>"+
                    "If you have any questions or require assistance, feel free to contact your sales executive at "+salesExecutiveEmail+"(Email) or "+salesExecutivePhone+"(Phone).<br/><br/>"+
                    "Thank you for your prompt attention."
                /*"<br/><br/>Best regards,"+
                    "<br/><strong>Veegaland Developers Pvt Ltd.</strong>"+
                    "<br/><br/>Sales Executive: <br/><strong>"+salesExecutiveName+"</strong><br/>"+salesExecutiveEmail+"<br/>"+salesExecutivePhone*/;
                
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
    },
    sendEmail: function(component, event, helper) {
        var allFiles = component.get('v.files');
        var contentDocumentIds = component.get('v.filesIDS');
        var modifiedEmailContent = component.get("v.emailContent");
        var ownerName = component.get("v.ownerName");
        var ownerPhone = component.get("v.ownerPhone");
        var ownerEmail = component.get("v.ownerEmail");
        var customerEmail = component.get("v.customerEmail");
        var toAddresses = [];
        modifiedEmailContent += "<br/><div style='color: black;'>Regards,<br/><strong>" + ownerName + "</strong><br/>";
        
        // Conditionally add the phone number if it exists, else add the email
        if(ownerPhone) {
            modifiedEmailContent += 'Phone: ' + ownerPhone;
        }
        if(ownerEmail){
            modifiedEmailContent += 'Email: ' + ownerEmail;
        }
        
        modifiedEmailContent += '</div>';
        
        if (customerEmail) {
            toAddresses.push(customerEmail);
        }
         console.log('here3');
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
         console.log('here4');
        var action = component.get("c.sendRequestDocumentMail");
        action.setParams({
            "recordId": component.get("v.recordId"),
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