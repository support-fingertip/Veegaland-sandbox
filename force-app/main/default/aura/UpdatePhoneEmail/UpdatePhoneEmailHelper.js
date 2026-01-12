({
	getcontactdata : function(component, event, helper) {
		 var action = component.get("c.getcontactdetails");
        action.setParams({ 
            recId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state=response.getState();
            console.log('Response : '+JSON.stringify(response.getReturnValue()));            
            if(state==='SUCCESS'){
                var lead = response.getReturnValue();
                if(lead !=null && lead !='' && lead !=undefined){
                    component.set('v.leaddata',lead);
                   
                    if(lead.Phone !=null && lead.Phone !='' && lead.Phone != undefined){
                        
                        component.set('v.phone',lead.Phone.toString());
                    }
                    if(lead.Secondary_Phone__c !=null && lead.Secondary_Phone__c !=''){
                         component.set('v.secondaryPhone',lead.Secondary_Phone__c);
                    }
                    if(lead.Email !=null && lead.Email !='' && lead.Email!=undefined){
                         component.set('v.email',lead.Email);
                    }
                    if(lead.Secondary_Email__c !=null && lead.Secondary_Email__c !='' && lead.Secondary_Email__c!=undefined){
                        component.set('v.secondaryEmail',lead.Secondary_Email__c);
                    }
                     //alert(JSON.stringify(component.get("v.leaddata")));
                }
                component.set("v.isModalOpen", true);
                 component.set('v.Spinner', false);
            }else{
                console.log('else block');
                component.set('v.Spinner', false);
                helper.toastMsg(component, event, helper, "error", "Error!", "Something went Wrong! Please contact System Admin");
            }
        });
        $A.enqueueAction(action);
	},
     toastMsg : function (component, event, helper, type, title, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": msg
        });
        toastEvent.fire();
    },
    saveContactData: function(component,event,helper){
       
        //alert(JSON.stringify(component.get("v.leaddata")));
         var action = component.get("c.savecontactdetails");
        action.setParams({ 
            recId: component.get("v.recordId"),
            phone : component.get("v.phone"),
            email : component.get("v.email"),
            secondaryPhone : component.get("v.secondaryPhone"),
            secondaryEmail : component.get("v.secondaryEmail")
        });
        action.setCallback(this, function(response) {
            var state=response.getState();
            console.log('Response : '+response.getReturnValue()); 
            //alert(state);
            if(state==='SUCCESS'){
                if( response.getReturnValue()=='Success'){
                    helper.toastMsg(component, event, helper, "success", "Success", "Contact details updated");
                component.set("v.isModalOpen", true);
                 component.set('v.Spinner', false);
                 $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                }else{
                    //alert(response.getReturnValue());
                    helper.toastMsg(component, event, helper, "error", "Error!", response.getReturnValue());
               component.set("v.isModalOpen", true);
                 component.set('v.Spinner', false);
                }
                 
            }else if(state==='ERROR'){ 
                component.set('v.Spinner', false);
                var errors = response.getError();
                //alert(JSON.stringify(errors));
                //alert(errors[0].message);
                if (errors && errors[0] && errors[0].fieldErrors && errors[0].fieldErrors.Phone) {
                    var phoneErrors = errors[0].fieldErrors.Phone;
                    for (var i = 0; i < phoneErrors.length; i++) {
                        var errorMessage = phoneErrors[i].message;
                        if (errorMessage.includes('Max length 12')) {
                            helper.toastMsg(component, event, helper, "error", "Error!", "Phone Field is a numeric field and Max length 12");
                            break; // Stop looping if the error condition is met for one of the errors
                        }
                    }
                }else {
                   helper.toastMsg(component, event, helper, "error", "Error!", "Something went wrong. please contact admin");
                }
                
            }
        });
        $A.enqueueAction(action);
    }
})