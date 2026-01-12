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
                var customerName = result.Lead_Name__c;
                var salesExecutiveName = result.Owner.Name;
                var salesExecutiveEmail = result.Owner.Email || '';
                var salesExecutivePhone = result.Owner.Phone || '';
                var encryptedId = result.Encrypted_Key__c;
                var customerEmail = result.Lead_Email__c;
                var project = result.Project__c;
                var unitName = result.Unit__r.Name;
                
                component.set("v.ownerEmail", salesExecutiveEmail);
                component.set("v.ownerPhone", salesExecutivePhone);
                component.set("v.ownerName", salesExecutiveName);
                component.set("v.customerEmail", customerEmail);
                
                var defaultEmailContent = "<div style='color: black;'>Dear " + customerName + ",</div><br/>";
                defaultEmailContent += "<div style='color: black;'>Thank you for choosing Veegaland Homes</div><br/>";
                defaultEmailContent += "<div style='color: black;'>We are pleased to share the cost sheet for Unit: <strong>" + project + " " + unitName + "</strong> for your review. Please find the details attached for your reference.</div><br/>";
                defaultEmailContent += "<div style='color: black;'>If you have any questions or need further assistance, feel free to get in touch with your sales executive. We're here to help you every step of the way.</div><br/>";
                defaultEmailContent += "<div style='color: black;'>Warm regards,</div>";
                defaultEmailContent += "<div style='color: black;'><strong>" + salesExecutiveName + "</strong></div>";
                defaultEmailContent += "<div style='color: black;'>" + salesExecutiveEmail + "</div>";
                if (salesExecutivePhone) {
                    defaultEmailContent += "<div style='color: black;'>" + salesExecutivePhone + "</div>";
                }
                defaultEmailContent += "<div style='color: black;'>Veegaland Developers Limited</div>";
                
                component.set("v.emailContent", defaultEmailContent);
                var vfpage;
                /*if(project == 'Veegaland Serene')
                {
                   vfpage = '/apex/VeegalandSerenelatestQuotePdf'+'?Id='+recordId;
                }
                else{*/
                   vfpage = '/apex/VeegalandQuotePdf'+'?Id='+recordId; 
                //}
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
        var action = component.get("c.sendCostSheettoCustomer");
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