({
    validate: function(component, event) {
        var isValid = true;
        var oppPlot = component.get('v.oppPlot');
        
        if (oppPlot.Unit__c == null) {
            isValid = false;
        }
        
        if (oppPlot.Payment_Plan__c == null) {
            isValid = false;
        }
        
        // Always set the checkbox values explicitly (true or false)
        var checkboxValue = component.find("checkbox").get("v.checked");
        oppPlot.Additional_Car_Parking_Required__c = checkboxValue;
        
        var speciallaunch = component.find("checkbox1").get("v.checked");
        oppPlot.Special_Launch__c = speciallaunch;
        
        component.set("v.oppPlot", oppPlot);
        
        return isValid;
    },
    save: function(component, event, helper) {
        component.set('v.spinner', true);
        var oppPlot = component.get("v.oppPlot");
        
        if (!oppPlot.Payment_Plan__c) {
            component.set('v.spinner', false);
            helper.showToast("Please select payment plan", "error");
            return;
        }
        
        var action = component.get("c.saveOppPlot");
        action.setParams({
            oppPlot: oppPlot
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log("Returned: " + returnValue);
                
                if (returnValue && returnValue.startsWith('ERROR:')) {
                    component.set('v.spinner', false);
                    helper.showToast(returnValue.replace('ERROR: ', ''), "error");
                } else {
                    component.set("v.quoteId", returnValue);
                    
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get('v.quoteId'),
                        "slideDevName": "detail"
                    });
                    debugger;
                    navEvt.fire();
                    
                    helper.showToast("Quote Created successfully","success");
                    component.set('v.quoteId','');
                }
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    helper.showToast(errors[0].message, "error");
                } else {
                    helper.showToast("Unknown error occurred", "error");
                }
                component.set('v.spinner', false);
            } else if (state === "INCOMPLETE") {
                helper.showToast("Server response incomplete", "error");
                component.set('v.spinner', false);
            }
        });
        
        $A.enqueueAction(action);
    }
    
    ,
    /*
    approvalSubmit: function(component,event,helper) {
                    var action=component.get("c.submitapproval");
                    action.setParams({
                        'quoteId' :component.get('v.quoteId')
                    });
                    action.setCallback(this,function(response){
                        if(response.getState() == "SUCCESS"){
                            
                            helper.showToast("Quote Created Successfully and Submited for Approval","Success");
                            
                            
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": component.get('v.quoteId'),
                                "slideDevName": "detail"
                            });
                            navEvt.fire();
                        }
                    });
                    $A.enqueueAction(action);		
                },
                */
    getFilteredLead: function(component, event,helper) {
        // alert('hh')
        var oppPlot = component.get('v.oppPlot');
        var pymplan = oppPlot.Payment_Plan__c;
        var project = oppPlot.Projects__c;
        
        // alert(pymplan+'--'+project)
        var action = component.get("c.getPaymentSchedules");
        
        action.setParams({'Pay':  pymplan,
                          'Project': project
                         })
        action.setCallback(this,function(response){
            var state = response.getState();
            
            if(state == "SUCCESS" ){ 
                //  alert(1);
                var db = response.getReturnValue();
                
                //console.log(db.payList.length());
                if(db.payList !=null){
                    console.log('if');
                    
                    component.set('v.paymentSchedules', db.payList );
                    
                    //alert(JSON.stringify(component.get('v.paymentSchedules')))
                }
                else{
                    
                    //  helper.addProductRecord(component,event,helper);
                    console.log('else');
                    
                }
                
            }
        });
        $A.enqueueAction(action); 
        
    },
    saveSchedules : function(component,event,helper) {  
        var action=component.get("c.insertSchedules");
        action.setParams({'payList':component.get('v.paymentSchedules'),
                          'quoteid':component.get('v.quoteId')});
        
        action.setCallback(this,function(response){ 
            //  alert('the response state'+response.getState())
            if(response.getState() == "SUCCESS"){ 
                component.set("v.paymentSchedules", []);
                component.set('v.spinner',false);
                component.set('v.showqute',false);
                component.set("v.showNextCmp", false);
                
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get('v.quoteId'),
                    "slideDevName": "detail"
                });
                debugger;
                navEvt.fire();
                
                helper.showToast("Quote Created successfully","success");
                component.set('v.quoteId','');
            }
            else if (response.getState() === "ERROR") {
                var errors = response.getError();
                alert(errors);
                alert(errors[0].message);
                if (errors) {
                    alert(errors[0].message);
                    
                }
                
            }
            debugger;
        });
        $A.enqueueAction(action); 
        
    }, 
    
    showToast : function(message,type) {
        console.log(message)
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":type,
            "message":  message
        });
        toastEvent.fire();
    },
    
})