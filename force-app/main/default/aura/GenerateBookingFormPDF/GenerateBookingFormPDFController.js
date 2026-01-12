({
    doInit : function(component, event, helper) {
        var action=component.get("c.getQuoteData");
        var recordId = component.get('v.recordId');
        console.log('recordId '+recordId);
        action.setParams({'recordId':  recordId })
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS" ){
                var result = response.getReturnValue();
                console.log('result '+JSON.stringify(result));
                var customerName = result.Primary_Applicant_Name__c;
                var salesExecutiveName = result.Owner.Name;
                var salesExecutiveEmail = result.Owner.Email || '';
                var salesExecutivePhone = result.Owner.Phone || '';
                var encryptedId = result.Encrypted_Key__c;
                var customerEmail = result.Primary_Applicant_Email__c;
                var project = result.Project__c;
                //var location = result.Project__r.Locality_Name__c+' ,'+result.Project__r.City__c;
                var unitName = result.Unit__r.Name;
                component.set("v.ownerEmail",salesExecutiveEmail);
                component.set("v.ownerPhone",salesExecutivePhone);
                component.set("v.ownerName",salesExecutiveName);
                component.set("v.customerEmail",customerEmail);
                //console.log('Encription'+result.Encrypted_Key__c);
                var defaultEmailContent = "<div style='color: black;'><strong>Dear " + customerName +",</strong></div><br/>" ;
                
                defaultEmailContent += "<div style='color: black;'>Thank you for providing the required documents for your booking. Please find your Booking Form attached in the below link to view and download it."+
                    "<br/><br/>Kindly review the details in the form and let us know your decision."+
                    "<br/><br/>If you have any questions or require assistance, feel free to contact us at "+salesExecutiveEmail+"(Email) or "+salesExecutivePhone+"(Phone)."+
                    "<br/><br/>Thank you for your prompt attention.";
                /*"<br/><br/>Best regards,"+
                    "<br/><strong>Veegaland Developers Pvt Ltd.</strong>"+
                    "<br/><br/>Sales Executive: <br/><strong>"+salesExecutiveName+"</strong><br/>"+salesExecutiveEmail+"<br/>"+salesExecutivePhone*/;
                
                component.set("v.emailContent", defaultEmailContent);
                var vfpage = '/apex/FinalBookingForm'+'?Id='+recordId;
                component.set('v.vfPage',vfpage);
                component.set('v.showPdf',true);               
                /*var db = response.getReturnValue();
                if(db =='select payment type'){
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type":'Error',
                        "title": 'Error!',
                        "message":'Please select payment type',
                        "duration":10000
                    });
                    toastEvent.fire();
                }else{
                    component.set('v.showPdf',true);
                    var vfpage = '/apex/'+db+'?Id='+recordId;
                    console.log('vfpage '+vfpage);
                    component.set('v.vfPage',vfpage);
                    
                }*/
            }
        });
        $A.enqueueAction(action); 
    },
    sendEmail: function(component, event, helper) {
        console.log('start');
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
            modifiedEmailContent += '<br/>Phone: ' + ownerPhone;
        }
        if(ownerEmail){
            modifiedEmailContent += '<br/>Email: ' + ownerEmail;
        }
        modifiedEmailContent += '<br/><strong>VEEGALAND DEVELOPERS LIMITED</strong>';
        modifiedEmailContent += '</div>';
        
        if (customerEmail) {
            toAddresses.push(customerEmail);
        }
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
        var action = component.get("c.sendBookingFormtoCustomer");
        action.setParams({
            "recordId": component.get("v.recordId"),
            "emailContent": modifiedEmailContent,
            "contentIds": contentDocumentIds
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('finish');
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
                console.log('finish');
                console.error("Error sending email");
            }
        });
        
        $A.enqueueAction(action);
    },
    close : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})