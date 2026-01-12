({
    doInit: function(component, event, helper) {
        // Fetch round-robin members on component initialization
        //helper.getRoundRobinMembers(component,event,helper);
        var action = component.get("c.fetchRoundRobinMembers");
        action.setParams({recId:  component.get('v.recordId') })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //component.set("v.roundRobinMembers", response.getReturnValue());
                //console.log(response.getReturnValue());
                
                
                var SalesUsers=[];
                var PostSalesUsers=[];
                var LegalUsers=[];
                var FinanceUsers=[];
                var result = response.getReturnValue();
                for (var i = 0; i < result.length; i++) {
                    if (result[i].User_Type__c === 'Sales') {
                      	SalesUsers.push(result[i]);
                    }
                    if (result[i].User_Type__c === 'CRM') {
                      	PostSalesUsers.push(result[i]);
                    }
                    if (result[i].User_Type__c === 'Legal') {
                      	LegalUsers.push(result[i]);
                    }
                    if (result[i].User_Type__c === 'Finance') {
                      	FinanceUsers.push(result[i]);
                    }
                }
                
                component.set("v.roundRobinMembersSale", SalesUsers);
                component.set("v.roundRobinMembersPostsale", PostSalesUsers);
                component.set("v.roundRobinMembersLegal", LegalUsers);
                component.set("v.roundRobinMembersFinance", FinanceUsers);
                console.log(response.getReturnValue());
                
            }
        });
        $A.enqueueAction(action);
    },

    toggleActiveStatus: function(component, event, helper) {
        var userId = event.getSource().get("v.value");
        console.log(userId);
        var action = component.get("c.toggleMemberStatus");
        action.setParams({ 'memId': userId,recId:  component.get('v.recordId') });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Refresh the member list after toggling status
                //this.doInit(component,event,helper);
                $A.get('e.force:refreshView').fire();
                component.set("v.roundRobinMembers", response.getReturnValue());
                console.log('yes got it',response.getReturnValue());
                //window.location.reload();
            }
        });
        $A.enqueueAction(action);
    }
})