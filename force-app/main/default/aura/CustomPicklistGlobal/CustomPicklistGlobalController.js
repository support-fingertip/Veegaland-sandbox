({
    doInit : function(component, event, helper) {
       
        var action = component.get('c.findPicklistOptions');
        action.setParams({
            'objAPIName':component.get('v.objAPIName'),
            'fieldAPIname':component.get('v.fieldAPIname')
        });
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS') {
                var options = response.getReturnValue();
                component.set("v.options",options);
            }else {
                // If server throws any error
                var errors = response.getError();
                console.log('options'+JSON.stringify(errors));
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.message', errors[0].message);
                    console.log(errors[0].message);
                }
            }
        });
        $A.enqueueAction(action);
    },
    handleCheckRequired : function(component, event, helper) {
        console.log('here inside');
        var inputFields = component.find('fieldR');
        var isAllValid = true;
        
        if (Array.isArray(inputFields)) {
            // multiple fields
            isAllValid = inputFields.reduce(function(isValidSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return isValidSoFar && inputCmp.checkValidity();
            }, true);
        } else if (inputFields) {
            // single field
            inputFields.showHelpMessageIfInvalid();
            isAllValid = inputFields.checkValidity();
        } else {
            // no fields found - decide what to do
            isAllValid = true;
        }
        return isAllValid;
    }
    
})