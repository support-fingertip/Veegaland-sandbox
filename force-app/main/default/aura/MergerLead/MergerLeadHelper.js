({
 getlead: function(component) {
        var action = component.get('c.getLeads');
       // action.setParams({leadId :component.get("v.recordId")});
        action.setCallback(this, function(actionResult) {
            var ldlst = actionResult.getReturnValue();
            component.set('v.LeadList',ldlst);
        });
        $A.enqueueAction(action);
    },
   
})