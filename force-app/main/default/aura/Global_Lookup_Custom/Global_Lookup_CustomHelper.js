({
    searchRecordsHelper : function(component, event, helper, value) {
        var searchString = component.get('v.searchString') || ''; 
        var query = component.get('v.query');
        var action = component.get('c.fetchRecordsGB');

        console.log('searchString: ', searchString);
        console.log('value param: ', value);

        action.setParams({
            objectName: component.get('v.objectName'),
            filterField: component.get('v.fieldName'),
            query: query,
            additionalFields: component.get('v.additionalFields'),
            value: '',
            searchString: searchString
        });

        action.setCallback(this, function(response) {
            $A.util.addClass(component.find("Spinner"), "slds-hide");
            if (response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('Result:', result);
                if (result.length > 0) {
                    component.set('v.recordsList', result);
                    component.set('v.message', '');
                    if (!$A.util.isEmpty(value)) {
                        component.set('v.selectedRecord', result[0]);
                    }
                } else {
                    component.set('v.recordsList', []);
                    component.set('v.message', "No Records Found for '" + searchString + "'");
                }
                if ($A.util.isEmpty(component.get('v.value'))) {
                    $A.util.addClass(component.find('resultsDiv'), 'slds-is-open');
                }
            } else {
                var errors = response.getError();
                var errorMsg = errors && errors[0] && errors[0].message ? errors[0].message : "Unknown error";
                component.set('v.recordsList', []);
                component.set('v.message', errorMsg);
                console.error("Error fetching records:", errorMsg);
            }
        });

        $A.enqueueAction(action);
    }
})