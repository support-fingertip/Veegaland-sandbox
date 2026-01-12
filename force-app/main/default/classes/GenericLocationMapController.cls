public class GenericLocationMapController {
   
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getLocationDetails(String objectName, String recordId, String locationNameField,String locationField, String cityField) {
        Map<String, Object> result = new Map<String, Object>();

        // Dynamically build the SOQL query
        String soqlQuery = 'SELECT ' + locationNameField + ', ' + cityField +', ' + locationField + ' FROM ' + objectName + ' WHERE Id = :recordId LIMIT 1';

        // Execute the dynamic SOQL query
        SObject record = Database.query(soqlQuery);

        // Check if the record is found
        if (record != null) {
            // Get the location name (for example, LocationName__c)
            String locationName = (String) record.get(locationNameField);
            String cityName = (String) record.get(cityField);
            
            // Get the location field (assuming it's a geolocation field, like Location__Latitude__s and Location__Longitude__s)
            Object locationData = record.get(locationField);
            
            if (locationData != null && cityName != null && locationData instanceof Location) {
                Location loc = (Location) locationData;
                Double latitude = loc.getLatitude();
                Double longitude = loc.getLongitude();

                result.put('locationName', locationName);
                result.put('latitude', latitude);
                result.put('longitude', longitude);
                result.put('city', cityName);
            } else {
                result.put('error', 'Location field data is invalid or missing.');
            }
        } else {
            result.put('error', 'Record not found.');
        }
        system.debug('result '+result);
        return result;
    }
}