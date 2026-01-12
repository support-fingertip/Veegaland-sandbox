({
    doInit: function(component, event, helper) {
        var objectName = component.get("v.objectName");
        var recordId = component.get("v.recordId");
        var locationNameField = component.get("v.locationNameField"); // e.g., "LocationName__c"
        var locationField = component.get("v.locationField");
        var cityField = component.get("v.cityField");
        
        // Call Apex method to get the location details
        var action = component.get("c.getLocationDetails");
        action.setParams({
            objectName: objectName,
            recordId: recordId,
            locationNameField: locationNameField,
            locationField: locationField,
            cityField:cityField
        });
        
        // Set up the callback function to handle the response
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result.error) {
                    component.set("v.errorMessage", result.error);
                } else {
                    component.set("v.locationName", result.locationName);
                    component.set("v.latitude", result.latitude);
                    component.set("v.longitude", result.longitude);
                    component.set("v.cityName", result.city);
                    var link = 'https://www.google.com/maps?q='+ result.latitude + ',' +  result.longitude;
                    component.set('v.mapMarkers', [
                        {
                            location: {
                                Street:result.locationName,
                                City: result.city,
                                State: 'Kerala'
                            },
                            
                            title: result.locationName,
                            description: link
                        }
                    ]);
                    component.set('v.zoomLevel', 16);
                }
            } else {
                component.set("v.errorMessage", "Failed to retrieve data");
            }
        });
        
        $A.enqueueAction(action);
    },
    showInGoogleMaps: function(component, event, helper) {
        var latitude = component.get("v.latitude");
        var longitude = component.get("v.longitude");
        
        // Open Google Maps with current latitude and longitude
        var url = "https://www.google.com/maps?q=" + latitude + "," + longitude;
        window.open(url, "_blank");
    }
})