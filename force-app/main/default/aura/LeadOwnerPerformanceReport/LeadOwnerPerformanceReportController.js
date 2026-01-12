({
    doInit : function(component, event, helper) {
         var today = new Date();
        var todayFormatted = today.toISOString().slice(0, 10); // Formats to "YYYY-MM-DD"

        // Set the default values for 'FromCreatedDateFilter' and 'ToCreatedDateFilter'
        component.set("v.FromCreatedDateFilter", todayFormatted);
        component.set("v.ToCreatedDateFilter", todayFormatted);
        helper.getRecords(component, event);
    },
     handleOnChange: function(component, event, helper) {
        helper.getRecords(component, event); 
    },
    handleChange: function(component, event, helper) {
        //alert('hi');
        let selectedValue = event.target.value;
        component.set("v.selectedDateValue",selectedValue);
        //alert(selectedValue);
        helper.getRecords(component, event);
    }
})