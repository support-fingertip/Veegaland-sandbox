({
    doInit: function(component, event, helper) {
        let baseUrl = window.location.origin;
        component.set("v.baseUrl",baseUrl);
        let booking = component.get("v.booking");
        if (booking) {
            let action = component.get("c.getPaymentSchedules");
            action.setParams({ bookingId: booking.Id });
            
            action.setCallback(this, function(response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.data", response.getReturnValue());
                } else {
                    console.error("Error fetching data: ", response.getError());
                }
            });
            
            $A.enqueueAction(action);
        }
    },
    handleClosePopup : function(component, event, helper) {
        component.set("v.visible",false);
    },
    handleRadioSelection: function(component, event, helper) {
        const selectedIndex = parseInt(event.currentTarget.getAttribute('data-index'), 10);
        const selectedIndexId = event.currentTarget.getAttribute('value');
        const selectedMilestone = event.currentTarget.getAttribute('data-value');
        const ocCompleted = event.currentTarget.getAttribute('data-oc');
        
        component.set("v.selectedIndexId", selectedIndexId);
        component.set("v.selectedMilestone", selectedMilestone);
        component.set("v.selectedIndex", selectedIndex);
        component.set("v.isCompletedOC", ocCompleted);
    },
    handleGenerate: function(component, event, helper) {
        
        var baseUrl = component.get('v.baseUrl');
        var bookingval =  component.get('v.booking');
        var currentMilestone =  component.get('v.currentMilestone');
        var selectedIndexId =  component.get('v.selectedIndexId');
        var selectedMilestone = component.get('v.selectedMilestone');
        var selectedIndex =  component.get('v.selectedIndex');
        var isCompletedOC =  component.get('v.isCompletedOC');
        component.set("v.milestoneId",selectedIndexId);
        
        if(selectedIndexId){
            let url;
            var applicantNames = '';
            if (bookingval.salutation_Applicant1__c && bookingval.First_Applicant_Name__c) {
                applicantNames = bookingval.salutation_Applicant1__c + ' ' + bookingval.First_Applicant_Name__c;
            }
            var secondApplicantName = '';
            if (bookingval.Second_Applicant_Name__c && bookingval.Second_Applicant_Name__c.trim() !== '') {
                secondApplicantName = bookingval.salutation_Applicant2__c + ' ' + bookingval.Second_Applicant_Name__c;
            }
            if (secondApplicantName != '') {
                applicantNames += ' and ' + secondApplicantName;
            }
            let milestoneName = '';
            if(currentMilestone.Name){
                milestoneName = currentMilestone.Name;
            }
            let ProjectName='';
            if(bookingval.Project1__r.Name){
                ProjectName = bookingval.Project1__r.Name;
            }
            var defaultEmailContent ='';
           /* if(selectedIndex != 1){
                defaultEmailContent += 
                    '<div style="color: black;">' +
                    'Dear <strong>' + bookingval.First_Applicant_Name__c + '</strong>,' +
                    '</div><br/>' +
                    '<div>' +
                    '<strong>Greetings from Veegaland Developers !!</strong><br/><br/>' +
                    'Hope this mail finds you in good health and spirit.<br/><br/>' +
                    '<strong>Sub: Requisition for release of instalment.</strong><br/>' +
                    '<strong>Ref: ' + bookingval.Project1__r.Name + ', Apartment No. ' + bookingval.Plot__r.Name + ' - ' + bookingval.First_Applicant_Name__c + '</strong><br/><br/>' +
                    'This is to remind you that an amount of <strong>INR 000/-</strong> (ooo) will be due against apartment No. ' + 
                    bookingval.Plot__r.Name + ' at <strong>' + bookingval.Project1__r.Name + '</strong>.<br/><br/>' +
                    'Request you to kindly release the amount to our below mentioned bank account:<br/><br/>' +
                    
                    '<table style="border-collapse: collapse; width: 100%; font-size: 14px;" border="1">' +
                    '<tr><th style="padding: 8px; text-align: left;">Account No.</th><td style="padding: 8px;">0587073000000353</td></tr>' +
                    '<tr><th style="padding: 8px; text-align: left;">Bank Name</th><td style="padding: 8px;">THE SOUTH INDIAN BANK LTD</td></tr>' +
                    '<tr><th style="padding: 8px; text-align: left;">Branch Name</th><td style="padding: 8px;">KAKKANAD</td></tr>' +
                    '<tr><th style="padding: 8px; text-align: left;">IFSC Code</th><td style="padding: 8px;">SIBL0000587</td></tr>' +
                    '</table>' +
                    
                    '<br/><br/>Thank you for choosing <strong>Veegaland Developers Pvt Ltd.</strong>.<br/><br/>' +
                    'Best regards,<br/><br/>' +
                    
                    '<strong>Midhu Siju | Officer - Customer Relations | 9207054444 </strong><br/> ' +
                    '<strong>Alitta Lijoy | Customer Relation Executive | 90482 37066 </strong><br/><br/>' +
                    
                    'Veegaland Developers Pvt.Ltd.<br/>' +
                    'Regd. Office: XIII/300 E-26, 4th Floor,<br/>' +
                    'K Chittilappilly Tower, BMC Road,<br/>' +
                    'Thrikkakara P.O, Ernakulam-682021<br/>' +
                    'Tel: +91 484 2584000 / 2973944, +916235051144<br/>' +
                    '<a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a><br/><br/>' +
                    
                    'Follow us on: ' +
                    '<a href="https://www.facebook.com/veegalanddevelopers" target="_blank">Facebook</a> | ' +
                    '<a href="https://www.instagram.com/veegalanddevelopers" target="_blank">Instagram</a> | ' +
                    '<a href="https://www.linkedin.com/company/veegalanddevelopers" target="_blank">LinkedIn</a> | ' +
                    '<a href="https://www.youtube.com/channel/veegalanddevelopers" target="_blank">YouTube</a>' +
                    '</div>';
            }else{
                
                defaultEmailContent += 
                    '<div style="color: black;">' +
                    'Dear <strong>' + bookingval.First_Applicant_Name__c + '</strong>,' +
                    '</div><br/><br/>' +
                    '<strong>Greetings from Veegaland Developers !!</strong><br/><br/>' +
                    'This is just to share the invoice related to the advance amount already received for Apartment No. 16A at Veegaland Green Heights.<br/>' +
                    + tdsMessage + 
                    '<br/> Please find the invoice attached for your reference.'+
                    'Thank you for choosing <strong>Veegaland Developers Pvt Ltd.</strong>.<br/><br/>' +
                    'Best regards,<br/><br/>' +
                    
                    '<br/><strong>Midhu Siju | Officer - Customer Relations | 9207054444 </strong><br/> ' +
                    '<strong>Alitta Lijoy | Customer Relation Executive | 90482 37066 </strong><br/><br/>' +
                    
                    'Veegaland Developers Pvt.Ltd.<br/>' +
                    'Regd. Office: XIII/300 E-26, 4th Floor,<br/>' +
                    'K Chittilappilly Tower, BMC Road,<br/>' +
                    'Thrikkakara P.O, Ernakulam-682021<br/>' +
                    'Tel: +91 484 2584000 / 2973944, +916235051144<br/>' +
                    '<a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a><br/><br/>' +
                    'Follow us on: ' +
                    '<a href="https://www.facebook.com/veegalanddevelopers" target="_blank">Facebook</a> | ' +
                    '<a href="https://www.instagram.com/veegalanddevelopers" target="_blank">Instagram</a> | ' +
                    '<a href="https://www.linkedin.com/company/veegalanddevelopers" target="_blank">LinkedIn</a> | ' +
                    '<a href="https://www.youtube.com/channel/veegalanddevelopers" target="_blank">YouTube</a>' +
                    '</div>';
            }*/
            console.log('Here');
            if(isCompletedOC == true){
                url = baseUrl+'/apex/BillofSupplyCustomVFP?Id='+ bookingval.Id+'&PId=' + selectedIndexId;
            }else{
                url = baseUrl+'/apex/Demand_Note_Custom?Id='+ bookingval.Id+'&PId=' + selectedIndexId;
            }
            component.set("v.emailContent", defaultEmailContent);
            console.log('Here1');
            component.set("v.vfPageUrl", url);
            console.log('Here2');
        }else{
            var toastEvent = $A.get("e.force:showToast");
            var type = 'error';
            toastEvent.setParams({
                "type": type,
                "title": type.charAt(0).toUpperCase() + type.slice(1), // Capitalize title
                "message": 'Please select a milestone',
                "duration": 10000
            });
            toastEvent.fire();
        }
        
    },
    handleCreateDemand: function(component, event, helper) {
        
        var selectedIndexId =  component.get('v.milestoneId');
        var emailContent = component.get("v.emailContent");
        var contentDocumentIds = component.get("v.filesIDS");
        var invoiceNumber = component.get("v.invoiceNumber");
        
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
        
        if(selectedIndexId){
            
            let action = component.get("c.raiseDemand");
            action.setParams({
                "milestoneId": selectedIndexId,
                "documentIds": contentDocumentIds,
                "invoiceNo":invoiceNumber
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
                    var type = res_string === 'Demand raised successfully.' ? 'success' : 'error';
                    
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
                component.set("v.visible",false);
            });
            
            // Enqueue the action to call the Apex method
            $A.enqueueAction(action);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            var type = 'error';
            toastEvent.setParams({
                "type": type,
                "title": type.charAt(0).toUpperCase() + type.slice(1), // Capitalize title
                "message": 'Please select a milestone',
                "duration": 10000
            });
            toastEvent.fire();
        }
    },
    handleFileUpload: function(component, event, helper) {
        var files = event.getParam("files");
        var getFiles = component.get("v.filesIDS");
        getFiles.push(...files);
        component.set('v.filesIDS',getFiles);
        
        var afercomit = component.get('v.filesIDS');
    },
    
})