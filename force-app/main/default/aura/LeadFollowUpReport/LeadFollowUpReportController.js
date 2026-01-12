({
    doInit : function(component, event, helper) {
        var today = new Date();
        var todayFormatted = today.toISOString().slice(0, 10); // Formats to "YYYY-MM-DD"

        // Set the default values for 'FromCreatedDateFilter' and 'ToCreatedDateFilter'
        component.set("v.FromCreatedDateFilter", todayFormatted);
        component.set("v.ToCreatedDateFilter", todayFormatted);
        helper.getLeadRecords(component, event);
    },
    handleOnChange: function(component, event, helper) {
        helper.getLeadRecords(component, event); 
    },
     navigateToRecord : function(component, event, helper) {
         var recordId = event.currentTarget.getAttribute('data-id'); // Get the record Id from the clicked link
         var recordUrl = "/" + recordId;
         // Open the record detail page in a new tab using window.open
         window.open(recordUrl, '_blank'); 
    },
    /*exportToExcel: function(component, event, helper) {
        var records = component.get("v.records");
        
        if (!records || records.length === 0) {
            alert('No data to export');
            return;
        }
        
        // Prepare CSV data
        var csv = "Sl No.,Lead Name,Lead Stage,No. of follow-up,Descriptions\n";
        
        records.forEach(function(record, index) {
            // Add serial number, lead name, lead stage, and number of follow-ups (handling undefined values)
            csv += (index + 1) + ',' + (record.leadName || '') + ',' + (record.leadStage || '') + ',' + (record.NoofFollowup || ''); 
            
            // Adding descriptions (filter out empty descriptions and strip HTML tags)
            if (record.descriptions && record.descriptions.length > 0) {
                var descriptionStr = record.descriptions.filter(Boolean).join(' '); // Filter out empty descriptions
                descriptionStr = descriptionStr.replace(/<\/?[^>]+(>|$)/g, " "); // Strip HTML tags
                
                // Replace all types of dashes (hyphen, en dash, em dash) with spaces
                descriptionStr = descriptionStr.replace(/[-–—]/g, ' '); 
                
                // Remove any line breaks and clean the description
                csv += ',' + descriptionStr.replace(/[\n\r]/g, ' '); 
            } else {
                csv += ','; // Leave blank if no descriptions
            }
            
            // End of the current record row
            csv += '\n';
        });
        
        // Create a hidden element to trigger download
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv); // Create data URI
        hiddenElement.target = '_blank';
        hiddenElement.download = 'Lead with Follow-up Report.csv'; // Filename for the exported CSV
        hiddenElement.click(); // Trigger the download
    }*/
    exportToExcel: function(component, event, helper) {
        var records = component.get("v.records");
        
        if (!records || records.length === 0) {
            alert('No data to export');
            return;
        }
        
        var csv = "Sl No.,Lead Name,Lead Stage,No. of follow-up";
        
        // Dynamically add description headers
        var maxDescriptions = records[0].descriptions.length; // Assuming each record has the same number of descriptions
        for (var i = 0; i < maxDescriptions; i++) {
            csv += ",Description " + (i + 1);
        }
        csv += '\n';
        
        records.forEach(function(record, index) {
            // Add serial number, lead name, lead stage, and number of follow-ups (handling undefined values)
            csv += (index + 1) + ',' + (record.leadName || '') + ',' + (record.leadStage || '') + ',' + (record.NoofFollowup || ''); 
            
            // Adding descriptions (filter out empty descriptions and strip HTML tags)
            if (record.descriptions && record.descriptions.length > 0) {
                record.descriptions.forEach(function(rec) {
                    // Check if rec is valid (not null or undefined)
                    if (rec) {
                        // Strip HTML tags and replace dashes with spaces
                        var descriptionStr = rec.replace(/<\/?[^>]+(>|$)/g, " ") // Strip HTML tags
                        .replace(/[-–—]/g, ' ') // Replace all types of dashes with spaces
                        .replace(/[\n\r]/g, ' '); // Remove any line breaks
                        
                        // Append the cleaned description to the CSV
                        csv += ',' + descriptionStr; 
                    } else {
                        // If no description, add a blank field
                        csv += ',';
                    }
                });

            } else {
                csv += ','; // Leave blank if no descriptions
            }
            
            // End of the current record row
            csv += '\n';
        
        });
        
        // Create a hidden element to trigger download
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv); // Create data URI
        hiddenElement.target = '_blank';
        hiddenElement.download = 'Lead with Follow-up Report.csv'; // Filename for the exported CSV
        hiddenElement.click(); // Trigger the download
    },
    handleChange: function(component, event, helper) {
        //alert('hi');
        let selectedValue = event.target.value;
        component.set("v.selectedDateValue",selectedValue);
        //alert(selectedValue);
        helper.getLeadRecords(component, event);
    }


})