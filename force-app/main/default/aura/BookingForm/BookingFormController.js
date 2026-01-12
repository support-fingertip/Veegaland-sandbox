({
    close : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    send: function(component,event,helper){
        var action = component.get("c.SendManagementEmail");
        action.setParams({"recordId":component.get("v.recordId")});
        action.setCallback(this,function(response){
            if(response.getState() == 'SUCCESS' ) {
                //alert(response.getState());
                var res_string= response.getReturnValue();
                event.stopPropagation();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                var type;
                if(res_string == 'Email sent successfully'){
                    type = 'success';
                }else{
                    type = 'error';
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":type,
                    "title": type,
                    "message":res_string,
                    "duration":10000
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
            else
            {
                (state === 'ERROR')
                {
                    console.log('failed');
                }
            }
        });
        $A.enqueueAction(action);
    },
})