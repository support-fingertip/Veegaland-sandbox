({
    doInit: function(component, event, helper) {
        // Get the list of selected records
        var selectedRecords = component.get("v.selectedRecords");
        console.log('selectedRecords '+ JSON.stringify(selectedRecords));
        // Initialize selectedBookingIds with all booking IDs
        var bookingIds = [];
        selectedRecords.forEach(function(record) {
            bookingIds.push(record.booking.Id);
        });
        
        // Set the selectedBookingIds attribute with all the IDs
        component.set("v.selectedBookingIds", bookingIds);
        
    },
    submit: function(component, event, helper) {
        var contentDocumentIds = component.get("v.selectedFileIds");
        var selectedBookingIds = [];
        var emailContentMap = component.get("v.emailContentMap") || {};
        var contentDocumentIdsMap = component.get("v.contentDocumentIdsMap") || {};
        var invoiceNumberMap = component.get("v.invoiceNumberMap")|| {};
        var notvalid = false;
        invoiceNumberMap = {};
        
        var checkboxes = component.find("bookingCheckbox");
        checkboxes = Array.isArray(checkboxes) ? checkboxes : [checkboxes];
        var invoiceIds = component.find('invoiceId');
        invoiceIds = Array.isArray(invoiceIds) ? invoiceIds : [invoiceIds];
        invoiceIds.forEach(function(invId) {
            invId.showHelpMessageIfInvalid();
            var isValid = invId.checkValidity();
            if(isValid == false){
                notvalid = true;
                console.log('Invioice number cannot be empty');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": 'error',
                    "title": 'Error',
                    "message": 'Invioice number cannot be empty',
                    "duration": 10000
                });
                toastEvent.fire();
                return;
            }
            var bookingId = invId.get("v.name") || '';
            var invValue = invId.get("v.value") || '';
            invoiceNumberMap[bookingId] = invValue;
        });
        if(notvalid != true){
            checkboxes.forEach(function(checkbox) {
                if (checkbox.get("v.checked")) { 
                    
                    var bookingRecord = checkbox.get("v.value");
                    selectedBookingIds.push(bookingRecord.Id);
                    //emailContentMap[bookingRecord.Id] = defaultEmailContent;
                    contentDocumentIdsMap[bookingRecord.Id] = contentDocumentIds;                
                }
            });
            
            component.set("v.emailContentMap", '');
            component.set("v.contentDocumentIdsMap", contentDocumentIdsMap);
            component.set("v.selectedBookingIds", selectedBookingIds);
            var action = component.get("c.RaiseDemand");
            action.setParams({
                "bookingIds": selectedBookingIds,
                "emailContents": emailContentMap,
                "contentIds": contentDocumentIdsMap,
                "invoiceNumbers":invoiceNumberMap
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState(); // Get the response state
                
                if (state === 'SUCCESS') {
                    var res_string = response.getReturnValue();
                    var type = res_string === 'Demand Raise records created and submitted for approval.' ? 'success' : 'error';
                    component.set("v.showPopup",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": type,
                        "title": type.charAt(0).toUpperCase() + type.slice(1), // Capitalize title
                        "message": res_string,
                        "duration": 10000
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                    
                } else if (state === 'ERROR') {
                    console.log('here Error');
                    // Handle error case
                    var errors = response.getError();
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        console.log('Error message: ' + errors[0].message);
                    } else {
                        console.log('Unknown error');
                    }
                }
            });
            
            $A.enqueueAction(action);
        }
    },
    Close: function(component, event, helper) {
        component.set("v.showPopup",false);
    }
})