({
    doInit: function(component, event, helper) {
        helper.fetchKYCData(component);
    },

    handleCheckboxChange: function(component, event) {
        let fieldName = event.getSource().get("v.name");
        let kycData = component.get("v.kycData");
        kycData[fieldName] = event.getSource().get("v.checked");
        component.set("v.kycData", kycData);
    },

    handleFieldChange: function(component, event) {
        let fieldName = event.getSource().get("v.name");
        let kycData = component.get("v.kycData");
        kycData[fieldName] = event.getSource().get("v.value");
        component.set("v.kycData", kycData);
    },

    saveKYCData: function(component, event, helper) {
        helper.updateKYCData(component);
    },
    closeModel: function(component, event, helper) {
        
        $A.get('e.force:closeQuickAction').fire();
        $A.get('e.force:refreshView').fire();
    },
});