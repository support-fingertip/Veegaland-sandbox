({
    showToast: function(message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: type,
            message: message,
            type: type.toLowerCase(),
            mode: 'dismissible'
        });
        toastEvent.fire();
    }
    
})