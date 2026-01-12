({
    doInit : function(component, event, helper) {
        let baseUrl = window.location.origin;
        var action = component.get("c.getDemandRaised");
        action.setParams({recordId :component.get("v.recordId") }); 
        action.setCallback(this,function(a){ 
            var state = a.getState();
            if (state === 'SUCCESS') {
                var url = '';
                component.set("v.demandRaisedRecord",a.getReturnValue());
                var demandRaisedValue = a.getReturnValue();
                var ocCompletion = demandRaisedValue.Payment_schedule__r.Post_OC_Completion__c;
                component.set("v.postOC",ocCompletion);
                if(ocCompletion){
                    url = baseUrl+'/apex/BillofSupplySendVFP?Id='+component.get("v.recordId");
                }else{
                    url = baseUrl+'/apex/Demand_Note_Send?Id='+component.get("v.recordId");
                }
                
                if(demandRaisedValue.Demand_Email_Content__c && demandRaisedValue.Demand_Email_Content__c != ''){
                    component.set("v.emailContent", demandRaisedValue.Demand_Email_Content__c);
                }
                if(demandRaisedValue.Demand_Content_Ids__c != '' && demandRaisedValue.Demand_Content_Ids__c){
                    var listRaised = demandRaisedValue.Demand_Content_Ids__c.split(",").map(item => item.trim());
                    component.set("v.filesIDS", listRaised);
                }
                console.log('url'+ url);
                component.set("v.vfPageUrl", url);
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
        $A.enqueueAction(action);
    },
    send: function(component, event, helper) {
        console.log('here 1');
        var action = component.get("c.ResendRaiseDemand");
        console.log('here 2');
        var recId = component.get("v.recordId");
        console.log('here 3');
        var recordIdsList = component.get("v.recordIdsList") || [];
        console.log('here 4');
        recordIdsList.push(recId);
        console.log('here 5');
        component.set("v.recordIdsList", recordIdsList);
        console.log('here 6');
        // Set the parameter for the Apex method - receiptId is passed from the component
        action.setParams({
            "recordIds": recordIdsList,
        });
        
        // Set the callback function to handle the response from Apex
        action.setCallback(this, function(response) {
            console.log('here 7');
            var state = response.getState(); // Get the response state
            
            if (state === 'SUCCESS') {
                console.log('here sucess');
                // Retrieve the return value from the Apex method
                var res_string = response.getReturnValue();
                
                // Close the quick action panel
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                
                var type = 'success';
                // Show toast notification
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": 'success',
                    "title": type.charAt(0).toUpperCase() + type.slice(1), // Capitalize title
                    "message": 'Demand Raise mail successfully resend.',
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