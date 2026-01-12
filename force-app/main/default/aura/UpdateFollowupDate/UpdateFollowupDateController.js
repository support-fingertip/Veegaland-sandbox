({
    doInit : function(component, event, helper) {
        component.set('v.spinner',true);
        //alert(component.get("v.Status"));
    },
    
    handleError: function (cmp, event, helper) {
        
    },
    handleLoad: function(component, event, helper) {
        component.set('v.spinner',false);
    },
    handleOnSubmit : function(component, event, helper) {
        component.set('v.spinner',true);
        var status = component.get("v.Status");
        event.preventDefault();   
        var eventFields = event.getParam("fields");
        if(status != null)
        {
            eventFields["Follow_up_Status__c"] = status;
        }
        component.find('myform').submit(eventFields); 
        //component.set('v.spinner',false);
    },
    handleSuccess : function(component,event,helper) { 
        //alert(component.get("v.ButtonValue"));
        var recId = component.get("v.recordId");
        var ButtonValue = component.get("v.ButtonValue");
        var action = component.get("c.createALog");
        action.setParams({
            recId : recId,
            ButtonValue: ButtonValue
        }); 
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                var responseMessage = response.getReturnValue();
                //alert(responseMessage);
                if(responseMessage == null){
                    helper.toastMsg('SUCCESS','Success','Record Updated'); 
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                }
                else{
                    if(responseMessage == 'Choose Future Date and Time'){
                        helper.toastMsg('Error','Error',responseMessage); 
                    }
                    else{
                        helper.toastMsg('Error','Error',responseMessage);
                        $A.get("e.force:closeQuickAction").fire(); 
                    } 
                } 
            }
            else{
                helper.toastMsg('ERROR','Error','Something went wrong');
                $A.get("e.force:closeQuickAction").fire(); 
            }
        });
        $A.enqueueAction(action);
        /*$A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();*/
        component.set('v.spinner',false);
    },
    doCancel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    },
    NewhandleClick: function(component,event,helper){
        //alert('new');
        component.set("v.ActiveDiv",false);
        component.set("v.Status",'Scheduled');
        component.set('v.VarientValue',"brand");
        component.set('v.VarientValues',"neutral");
        component.set('v.ButtonValue',"New Follow Up");
        //alert(component.get("v.Status"));
    },
    UpdatehandleClick: function(component,event,helper){
        //alert('Update');
        component.set("v.ActiveDiv",true);
        component.set("v.Status",'Completed'); 
        component.set('v.VarientValue',"neutral");
        component.set('v.VarientValues',"brand");
        component.set('v.ButtonValue',"Update Follow Up");
        //alert(component.get("v.Status"));
    },
    
})