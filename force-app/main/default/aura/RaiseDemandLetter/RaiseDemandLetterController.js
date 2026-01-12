({
    doInit : function(component, event, helper) {
        let baseUrl = window.location.origin;
        var action = component.get("c.getRaiseDemandWithBooking");
        action.setParams({bookingId :component.get("v.recordId") });     
        action.setCallback(this,function(a){    
            let state = a.getState();
            if (state === "SUCCESS") {
                
                let results = a.getReturnValue();
                let bookingval = results.booking;
                let postOCplan = results.PostOC;
                let milestone = results.raiseDemandDetails;
                let milestoneNumber = milestone.currentMilestoneNumber;
                let url;
                
                console.log('milestoneNumber '+milestoneNumber);
                component.set("v.isDemanded",milestone.isDemanded);
                component.set("v.isPostOC",postOCplan);
                
                var applicantNames = '';
                if (bookingval.salutation_Applicant1__c && bookingval.First_Applicant_Name__c) {
                    applicantNames = bookingval.salutation_Applicant1__c + ' ' + bookingval.First_Applicant_Name__c;
                }
                let tdsMessage = '';
                
                if (milestone.TDSonePercentage > 0) {
                    tdsMessage += '<br/> Please pay and upload the receipt of 1% TDS amount of current milestone base amount = ' 
                    + milestone.TDSonePercentage 
                    + '%. Receipt upload link: '
                    + '<a href="https://site-speed-6226--postsbox1.sandbox.my.salesforce-sites.com/DocumentUploader?Id=' 
                    + bookingval.Id 
                    + '&filename=TDS ' 
                    + milestone.currentCompletedStage 
                    + ' Challan_Receipt" target="_blank">Upload TDS Challan Receipt</a> <br/>';
                }
                if(milestoneNumber != '1st'){
                    var defaultEmailContent = 
                        '<div style="color: black;">' +
                        'Dear <strong>' + bookingval.First_Applicant_Name__c + '</strong>,' +
                        '</div><br/>' +
                        '<div>' +
                        '<strong>Greetings from Veegaland Developers !!</strong><br/><br/>' +
                        'Hope this mail finds you in good health and spirit.<br/><br/>' +
                        '<strong>Sub: Requisition for release of instalment.</strong><br/>' +
                        '<strong>Ref: ' + bookingval.Project1__r.Name + ', Apartment No. ' + bookingval.Plot__r.Name + ' - ' + bookingval.First_Applicant_Name__c + '</strong><br/><br/>' +
                        'This is to remind you that an amount of <strong>INR '+milestone.presentDue+'/-</strong> ('+milestone.milestoneAmountInWords+') will be due against apartment No. ' + 
                        bookingval.Plot__r.Name + ' at <strong>' + bookingval.Project1__r.Name + '</strong>.<br/><br/>' +
                        'Request you to kindly release the amount to our below mentioned bank account:<br/><br/>' +
                        
                        '<table style="border-collapse: collapse; width: 100%; font-size: 14px;" border="1">' +
                        '<tr><th style="padding: 8px; text-align: left;">Account No.</th><td style="padding: 8px;"> '+results.projectBeneficiaryAccountNo+' </td></tr>' +
                        '<tr><th style="padding: 8px; text-align: left;">Bank Name</th><td style="padding: 8px;"> '+results.projectBankName+' </td></tr>' +
                        '<tr><th style="padding: 8px; text-align: left;">Branch Name</th><td style="padding: 8px;"> '+results.projectBranchName+' </td></tr>' +
                        '<tr><th style="padding: 8px; text-align: left;">IFSC Code</th><td style="padding: 8px;"> '+results.projectIfscCode+' </td></tr>' +
                        '</table> <br/>'+ 
                        tdsMessage + 
                        'Thank you for choosing <strong>Veegaland Homes</strong>.<br/><br/>' +
                        'Best regards,<br/><br/>' +
                        
                        '<strong>Midhu Siju | Officer - Customer Relations | 9207054444 </strong><br/> ' +
                        '<strong>Alitta Lijoy | Customer Relation Executive | 90482 37066 </strong><br/><br/>' +
                        
                        'Veegaland Developers Limited<br/>' +
                        'Regd. Office: XXXV/564, 4TH FLOOR,<br/>' +
                        'K C F TOWER, BHARAT MATHA COLLEGE ROAD, KAKKANADU,<br/>' +
                        'Thrikkakara,Ernakulam- 682021, Kerala<br/>' +
                        'Tel: +91 484 2584000 / 2973944, +916235051144<br/>' +
                        '<a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a><br/><br/>' +
                        
                        'Follow us on: ' +
                        '<a href="https://www.facebook.com/veegalanddevelopers" target="_blank">Facebook</a> | ' +
                        '<a href="https://www.instagram.com/veegalanddevelopers" target="_blank">Instagram</a> | ' +
                        '<a href="https://www.linkedin.com/company/veegalanddevelopers" target="_blank">LinkedIn</a> | ' +
                        '<a href="https://www.youtube.com/channel/veegalanddevelopers" target="_blank">YouTube</a>' +
                        '</div>';
                }else{
                    var defaultEmailContent = 
                        '<div style="color: black;">' + 
                        'Dear <strong>' + bookingval.First_Applicant_Name__c + '</strong>,' +
                        '</div><br/><br/>' +
                        '<strong>Greetings from Veegaland Developers !!</strong><br/><br/>' +
                        'This is just to share the invoice related to the advance amount already received for Apartment No. 16A at Veegaland Green Heights.<br/>' +
                        tdsMessage + 
                        '<br/> Please find the invoice attached for your reference.'+
                        'Thank you for choosing <strong>Veegaland Homes</strong>.<br/><br/>' +
                        'Best regards,<br/><br/>' +
                        
                        '<br/><strong>Midhu Siju | Officer - Customer Relations | 9207054444 </strong><br/> ' +
                        '<strong>Alitta Lijoy | Customer Relation Executive | 90482 37066 </strong><br/><br/>' +
                        
                        'Veegaland Developers Limited<br/>' +
                        'Regd. Office: XXXV/564, 4TH FLOOR,<br/>' +
                        'K C F TOWER, BHARAT MATHA COLLEGE ROAD, KAKKANADU,<br/>' +
                        'Thrikkakara,Ernakulam- 682021, Kerala<br/>' +
                        'Tel: +91 484 2584000 / 2973944, +916235051144<br/>' +
                        '<a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a><br/><br/>' +
                        'Follow us on: ' +
                        '<a href="https://www.facebook.com/veegalanddevelopers" target="_blank">Facebook</a> | ' +
                        '<a href="https://www.instagram.com/veegalanddevelopers" target="_blank">Instagram</a> | ' +
                        '<a href="https://www.linkedin.com/company/veegalanddevelopers" target="_blank">LinkedIn</a> | ' +
                        '<a href="https://www.youtube.com/channel/veegalanddevelopers" target="_blank">YouTube</a>' +
                        '</div>';
                }
                console.log('>>>>>>>>>>>>>>>>>>url>>>>>>>>>>>>>>');
                if(postOCplan == true){
                    url = baseUrl+'/apex/BillofSupplyVFP?Id='+component.get("v.recordId");
                }else{
                    url = baseUrl+'/apex/Demand_Note?Id='+component.get("v.recordId");
                }
                
                
                component.set("v.emailContent", defaultEmailContent);
                component.set("v.vfPageUrl", url);
            } else {
                console.error("Error fetching data: ", a.getError());
            }
        });
        $A.enqueueAction(action);
    },
    send: function(component, event, helper) {
        var action = component.get("c.RaiseDemand");
        var recId = component.get("v.recordId");
        var contentDocumentIds = component.get('v.filesIDS'); // This is the list of file IDs
        var contentHTML = component.get('v.emailContent'); // This is the email content
        var recordIdsList = component.get("v.recordIdsList") || [];
        var emailContentMap = component.get("v.emailContentMap") || {};
        var contentDocumentIdsMap = component.get("v.contentDocumentIdsMap") || {};
        var invoiceNumber = component.get("v.invoiceNumber");
        var invoiceNumberMap = component.get("v.invoiceNumberMap")|| {};
        
        let fields = component.find('invNum');
        fields = Array.isArray(fields) ? fields : [fields];
        
        var isAllValid = fields.reduce(function(isValidSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return isValidSoFar && inputCmp.checkValidity();
        }, true);
        
        if(isAllValid == false){
            console.log('Invioice number cannot be empty');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": 'error',
                "title": 'Error',
                "message": 'Invioice number cannot be empty',
                "duration": 10000
            });
            toastEvent.fire();
            return;
        }
        
        recordIdsList.push(recId);
        
        invoiceNumberMap[recId] = invoiceNumber;
        emailContentMap[recId] = contentHTML;
        
        contentDocumentIdsMap[recId] = contentDocumentIds;
        console.log('here 4'+JSON.stringify(contentDocumentIds));
        component.set("v.recordIdsList", recordIdsList);
        component.set("v.emailContentMap", emailContentMap);
        component.set("v.invoiceNumberMap", invoiceNumberMap);
        component.set("v.contentDocumentIdsMap", contentDocumentIdsMap);

        // Set the parameter for the Apex method - receiptId is passed from the component
        action.setParams({
            "bookingIds": recordIdsList,
            "emailContents": emailContentMap,
            "contentIds": contentDocumentIdsMap,
            "invoiceNumbers": invoiceNumberMap
        });
        // Set the callback function to handle the response from Apex
        action.setCallback(this, function(response) {
            var state = response.getState(); // Get the response state
            
            if (state === 'SUCCESS') {
                console.log('here sucess');
                // Retrieve the return value from the Apex method
                var res_string = response.getReturnValue();
                
                // Close the quick action panel
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                
                // Determine the toast type based on the response
                var type = res_string === 'Demand Raise records created' ? 'success' : 'error';
                
                // Show toast notification
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": type,
                    "title": type.charAt(0).toUpperCase() + type.slice(1), // Capitalize title
                    "message": res_string,
                    "duration": 10000
                });
                toastEvent.fire();
                
                // Refresh the view to reflect changes
                $A.get('e.force:refreshView').fire();
            } else if (state === 'ERROR') {
                console.log('here Error');
                // Handle error case
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    console.log('Error message: ' + errors[0].message);
                } else {
                    console.log('Unknown error');
                }
            }
        });
        
        // Enqueue the action to call the Apex method
        $A.enqueueAction(action);
    },
    handleFileUpload: function(component, event, helper) {
        var files = event.getParam("files");
        var getFiles = component.get("v.filesIDS");
        getFiles.push(...files);
        component.set('v.filesIDS',getFiles);
        
        var afercomit = component.get('v.filesIDS');
    },
    close : function(component, event, helper) {
        event.stopPropagation();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        component.set('v.visible',false);
    },
})