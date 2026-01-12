({
    doInit: function (component, event, helper) {
        const quoteId = component.get("v.recordId");
        if (!quoteId) {
            alert("Quote ID is missing!");
            return;
        }

        // Redirect to the Visualforce page with the Quote ID as a parameter
        const vfUrl = '/apex/VeegalandQuoteExcel?Id=' + quoteId;
        window.open(vfUrl, '_blank');
         var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                   
    }
})