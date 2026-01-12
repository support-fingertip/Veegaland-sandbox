({
   
    openCallPopup: function(component, event, helper)
    {
        var action = component.get('c.LeadRecordDetails');
        action.setCallback(this,function(response){
            var state=response.getState();            
            if(state==='SUCCESS'){
                var leadId = response.getReturnValue();
                if(leadId != null){
                var navigateEvent = $A.get("e.force:navigateToSObject");
                navigateEvent.setParams({
                    "recordId": leadId,
                    "slideDevName": "detail"
                });
                navigateEvent.fire(); 
                }
            }else if(state==='ERROR'){
                var toastsuccessEvent = $A.get("e.force:showToast");
                toastsuccessEvent.setParams({
                    "title": "Something went wrong.",
                    "message": "Please contact System Administrator.",
                    "type" : "error"
                });
                toastsuccessEvent.fire(); 
            }
        });
        $A.enqueueAction(action);  
    },
})