({
    doInit: function(component, event, helper) {
        
        //helper.getlead(component);
        component.set('v.mycolumns3', [
            {label: 'Lead Id', fieldName: 'Lead_ID__c', type: 'text'},
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Mobile Number', fieldName: 'Phone', type: 'text'},
            {label: 'Email', fieldName: 'Email', type: 'text'},
            
            
        ]);
            
            
            },
            searchLead: function(component, event) {
            var searchKey = component.find("searchKeyLead").get("v.value");
            //  alert(searchKey)
            if (searchKey.length < 5) {
           component.set("v.LeadCollection",[]);
            return;
            }
            var selectedList=component.get("v.selectedIdList");
            component.set("v.isSelectAll",false);
            console.log('searchKey:::::'+searchKey);
            var action = component.get("c.findLead");
            action.setParams({
            "searchKey": searchKey,
            });
            action.setCallback(this, function(a) {
            component.set("v.LeadCollection", a.getReturnValue());
            //  alert(JSON.stringify(component.get("v.LeadCollection")))
            });
            $A.enqueueAction(action);
            },
            updateSelectedText4: function (component, event) {
            var selectedRows = event.getParam('selectedRows');
            component.set('v.selectedRowsCount4', selectedRows.length);
            component.set('v.selectedLead', selectedRows);
            
            },
            docancel: function (component, event, helper) {
            //component.set("v.showLeads", false);
            $A.get("e.force:closeQuickAction").fire(); 
            //history.back();
                component.set("v.showLeads", false);
            },
            MergeLead: function (component, event, helper) {
            var action = component.get("c.mergeLead");
            // alert(JSON.stringify(component.get("v.selectedLead")))
            // alert(JSON.stringify(component.get("v.recordId")))
            action.setParams({'leads': component.get('v.selectedLead'),
            'recId':  component.get('v.recordId')
            })
            action.setCallback(this, function(response) {
            component.set('v.selectedRows', []);
        var state = response.getState();
        if (state === "SUCCESS") {
            var res_string= response.getReturnValue();
            var type;
            if(res_string == 'Lead Merged Successfully'){
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
        var navService = component.find("navService");
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                "recordId": component.get('v.recordId'),
                "objectApiName": "Lead",
                "actionName": "view"
            }
        }
        event.preventDefault();
        navService.navigate(pageReference);
    });
    $A.enqueueAction(action);
    
},
 })