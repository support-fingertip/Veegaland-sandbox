({
    doInit : function(component, event, helper) {
        helper.getBookingPicklists(component,event,helper);
        var action = component.get("c.fetchQuoteAndCoApplicants");
        action.setParams({ quoteId: component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var quoteData = result.quote;
                if(quoteData.Leads__r)
                component.set("v.leadName", quoteData.Leads__r.Name);
                   if( quoteData.Unit__r)
                component.set("v.unitName", quoteData.Unit__r.Name);
                 if(quoteData.Payment_Plan__r)
                component.set("v.paymentPlanName", quoteData.Payment_Plan__r.Name);
                var mappedData = helper.mapQuoteToBooking(component,quoteData);
                component.set("v.plot", mappedData);
                console.error('plot'+JSON.stringify(component.get("v.plot")));
                component.set("v.coApplicants", result.coApplicants);
            } else {
                console.error("Error fetching data: " + response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    closeModel: function(component, event, helper) {
        
        $A.get('e.force:closeQuickAction').fire();
        $A.get('e.force:refreshView').fire();
        
        
    },
    saveBooking : function(component, event, helper) {
         console.log('here saveBooking');
       
        let isAllValid = true;
        component.set("v.btnDisable",false);
        let plot = component.get("v.plot");
        if (plot &&!plot.Funding_Type__c) {
            var cmpA = component.find("pickVal");
            if(cmpA) {
                cmpA.handleCheckRequired();
            }
        }
         console.log('here saveBooking1');
        isAllValid = component.find('field').reduce(function(isValidSoFar, inputCmp){
            inputCmp.showHelpMessageIfInvalid();
            return isValidSoFar && inputCmp.checkValidity();
        }, true);
        
        if(isAllValid) {
             component.set('v.isSubmit',true);
            var book = component.get("v.plot");
            var action = component.get("c.createBook");
            action.setParams({
                'bk': book,
                'recId': component.get('v.recordId'),
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('state '+state);
                if(state === 'SUCCESS') {
                    component.set('v.isSubmit',false);
                    console.log('Test4');
                    var db = response.getReturnValue();
                    component.set('v.recordId', db);
                    
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": db,
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                    
                    component.set('v.showNext', true);
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": 'Success',
                        "title": 'Success!',
                        "message": 'Booking and Co-Applicants processed successfully.',
                        "duration": 5000
                    });
                    toastEvent.fire();
                }else if (state === 'ERROR') {
                    component.set('v.isSubmit',false);
                    const errors = response.getError();
                    console.log('Full error object: ' + JSON.stringify(errors));
                    
                    let errorMessage = "An unexpected error occurred.";
                    
                    if (errors && errors.length > 0) {
                        const err = errors[0];
                        
                        if (err.message) {
                            errorMessage = err.message;
                        } else if (err.pageErrors && err.pageErrors.length > 0) {
                            errorMessage = err.pageErrors[0].message;
                        } else if (err.fieldErrors) {
                            const fieldKeys = Object.keys(err.fieldErrors);
                            if (fieldKeys.length > 0 && err.fieldErrors[fieldKeys[0]].length > 0) {
                                errorMessage = err.fieldErrors[fieldKeys[0]][0].message;
                            }
                        }
                    }
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": 'Error',
                        "title": 'Error!',
                        "message": errorMessage,
                        "duration": 5000
                    });
                    toastEvent.fire();
                    
                    console.error('Error: ' + errorMessage);
                }
            });
            
            $A.enqueueAction(action);
        }
    },
    
    /* gotoReceipt : function (component, event, helper) {
         var action=component.get("c.getPhotosNumber");
          action.setParams({
                'storeId' :component.get('v.bookingRecordId')
            });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                var acc = response.getReturnValue();
                if(acc >= 2){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type":'Success',
                        "title": 'Success!',
                        "message":'Booking Files Submitted Successfully',
                        "duration":5000
                    });
                    toastEvent.fire();
                    //var navEvt = $A.get("e.force:navigateToSObject");
                    //navEvt.setParams({
                       // "recordId": component.get('v.bookingRecordId'),
                        //"slideDevName": "detail"
                    //});
                    //navEvt.fire(); 
                    component.set('v.showNext',false);
                    component.set('v.goToreceipt',true);
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type":'Error',
                        "title": 'Error!',
                        "message":'Please Upload Booking Form and Scanned Quotation',
                        "duration":5000
                    });
                    toastEvent.fire();
                }
               
            }
        });
        $A.enqueueAction(action);		
    }*/
    addRow: function(component, event, helper) { 
        helper.addAppliacantRecord(component, event, helper);
    },
    removeRow : function(component, event, helper) {
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        var aitems= component.get('v.applicantList');
        aitems.splice(index, 3);
        component.set("v.applicantList", aitems);
        
    },
    handleSelectedProjectIdChange: function(component, event, helper){
        var newSelectedId = event.getParam("value");
        console.log('Value changed to: ' + newSelectedId);
        var plot = component.get('v.plot');
        plot.Associated_Project__c = newSelectedId;
        component.set('v.plot',plot);
    },
    handleSelectedUnitIdChange: function(component, event, helper){
        var newSelectedId = event.getParam("value");
        console.log('unit Value changed to: ' + newSelectedId);
        var plot = component.get('v.plot');
        plot.Associated_Unit__c = newSelectedId;
        component.set('v.plot',plot);
    },
    handleSelectExisting: function(component, event, helper) {
        var selectedValue = component.get("v.plot.Existing_customer__c");
        var plot = component.get("v.plot");
        if (selectedValue !== "Yes") {
            plot.Associated_Unit__c = null;
            plot.Associated_Project__c = null;
            component.set("v.plot", plot);
        }
    }
})