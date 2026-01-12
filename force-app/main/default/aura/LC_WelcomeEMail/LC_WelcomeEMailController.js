({
    doInit: function(component, event, helper) {
        let baseUrl = window.location.origin;
        var url='';
        var recordId = component.get("v.recordId");
        console.log(recordId);
        var action = component.get("c.getRecordData");
        action.setParams({
            "recordId": recordId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var record = result.booking;
                console.log(JSON.stringify(record));
                console.log('Project__c'+record.Project__c);
                component.set("v.record", record);
                
                var customerName = record.salutation_Applicant1__c+' '+record.First_Applicant_Name__c;
                var allotmentSecureLink = 'https://site-speed-6226.my.salesforce-sites.com/DocumentUploader?Id=' + record.Id + '&filename=SignedAllotmentLetter ';
                var carparkingSecureLink = 'https://site-speed-6226.my.salesforce-sites.com/slotSelection?id='+record.Id;
                var signature = component.get("v.signUrl");
                var defaultEmailContent = 
                    "<div style='color: black;'>" +
                    "<p>Dear "+customerName+",</p>" +
                    
                    "<p>Warm greetings from Veegaland Developers!</P>"+
                    
                    "<p>We sincerely thank you for choosing Veegaland Developers as your trusted partner in fulfilling your dream home. We are truly honored by your decision and committed to making your journey with us smooth, transparent, and memorable.</p>" +
                    "<p style='color:#1b7868;font-weight:400'><b>Allotment Documents</b></p>" +
                    
                    "<p>Enclosed with this email:<ul> <li>Allotment Letter</li><li>Policy Sheet(FAQ)</li><li>Floor Plans</li><li>Car Parking Plan</li><li>Electrical Plan</li><li>Plumbing Plan</li><li>Sample Sale Agreement</li><li>Alteration Policy</li><li>List of Approved Banks for Home Loans</li></ul></p>" +
                    
                    "<p>Upload your signed allotment letter here: <a href='"+allotmentSecureLink+"' target='_blank' rel='noopener noreferrer' style='color: blue; text-decoration: underline;'>Upload Allotment Letter Signed Copy</a></p>" +
                    
                    "<p><span style='color:#1b7868;font-weight:400'><b>Parking Selection</b></span></p>" +
                    
                    "<p>As a valued customer, you have the privilege to select your preferred parking slot for your apartment in [Project Name].</p>" +
                    
                    "<p>Select Parking Slot: <a href='"+carparkingSecureLink+"' target='_blank' rel='noopener noreferrer' style='color: blue; text-decoration: underline;'>Car parking slot selection</a></p>" +
                    
                    "<p>Note: "+
                    "<ul> <li>Back-to-Back &amp; Individual Parking will be charged at an additional cost.</li>"+
                    "<li>Parking layout attached is for reference only.</li>"+
                    "<li>Kindly finalize your parking within 24 hours.</li></ul></p>" +

                    "<p style='color:#1b7868;font-weight:400'><b>Support &amp; Assistance</b></p>" +
                    
                    "<p>For further assistance, contact our customer care:"+
                    "<ul> <li>Midhu Siju | Officer, Customer Relations | midhu@veegaland.in | 9207054444</li>"+
                    "<li>Alita Lijoy | Customer Relations Executive | alita@veegaland.in | 9048237066</li>"+
                    "<li>Smitha | Customer Care Executive | smitha@veegaland.in | </li></ul></p>" +
                    
                    "<p style='color:#1b7868;font-weight:400'><b>Bank Loans Queries:</b></p>"+
                    "<ul> <li>We kindly request you to inform us if you are planning to apply for a home loan, and from which bank. Please share the bank details along with the contact person’s phone number.</li>"+
                    "<li>If you have not yet decided on the bank, please inform us at the time of signing the Sale Agreement so that we can arrange the loan documents accordingly. This will help ensure a smooth fund flow without any delays. Please contact Alita Lijoy | Customer Relations Executive | customercare@veegaland.in | 9048237066</li></ul>"+

                    
                    "<p>Warm regards, <br/><b>Giri S. Nair</b><br/>General Manager – CRM <br/>Veegaland Developers <br/></p>" +
                    "</div>";
                
                
                component.set("v.emailContent", defaultEmailContent);
                url = baseUrl+'/apex/AllotmentLetter?Id='+component.get("v.recordId");
                component.set("v.vfPageUrl", url);
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
        console.log('aftercommit:'+afercomit);
    },
    sendEmail: function(component, event, helper) {
        var recList = component.get('v.recepients');
        var allFiles = component.get('v.files');
        var contentDocumentIds = component.get('v.filesIDS');
        var modifiedEmailContent = component.get("v.emailContent");
        var loggedInUserName = component.get("v.loggedInUserName");
        var loggedInUserPhone = component.get("v.loggedInUserPhone");
        var loggedInUserEmail = component.get("v.loggedInUserEmail");
        
        var record = component.get("v.record");
        
        var toAddresses = [];
        if(recList) {
            var recList = recList.split(',');
            recList.forEach(function(email) {
                toAddresses.push(email.trim());
            });
        }
        if (record.Email1__c) {
            toAddresses.push(record.Email1__c);
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
        
        var action = component.get("c.welcomeMailAuraCmp");
        action.setParams({
            "recId": component.get("v.recordId"),
            // "toAddresses": toAddresses,
            "emailContent": modifiedEmailContent
            //"contentIds": contentDocumentIds
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