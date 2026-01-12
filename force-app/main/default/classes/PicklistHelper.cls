@RestResource(urlMapping='/ENUMAP/*')
global without sharing class PicklistHelper {
  @HttpGet
    global static void getPicklistValues() {
        // Create the response object
        EnumAPIResponse response = new EnumAPIResponse();
        response.success = true;
        response.message = 'Fetched Picklist Values Successfully';
        response.data = new EnumData();
        
        // Build supportType with nested concernList (using dependency map)
        response.data.supportType = new List<SupportTypeValue>();
        Map<String, List<String>> dependencyMap = SupportRequestHelper.getSupportRequestDependentMap();
        
        // Get Support Type picklist values
        List<PicklistValue> supportTypes = getPicklistValues('Support_Request__c', 'Support_Type__c');
        for (PicklistValue st : supportTypes) {
            SupportTypeValue stv = new SupportTypeValue();
            stv.id = st.id;
            stv.name = st.name;
            stv.concernList = new List<PicklistValue>();
            
            if (dependencyMap.containsKey(st.id)) {
                for (String dep : dependencyMap.get(st.id)) {
                    PicklistValue pv = new PicklistValue();
                    pv.id = dep;
                    pv.name = dep;
                    stv.concernList.add(pv);
                }
            }
            response.data.supportType.add(stv);
        }
        
        // Fetch Priority picklist values
        response.data.priorityList = getPicklistValues('Support_Request__c', 'Priority_List__c');
        
        // Set links from custom labels
        response.data.privacyPolicyLink = System.Label.PrivacyPolicyLink;
        response.data.aboutUsLink = System.Label.AboutUsLink;
        response.data.termsAndConditionLink = System.Label.TermsAndConditionLink;

        // Send the response
        sendResponse(response);
    }
    
    // Helper: get picklist values
    private static List<PicklistValue> getPicklistValues(String objectName, String fieldName) {
        List<PicklistValue> picklistValues = new List<PicklistValue>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        if (objType == null) return picklistValues;
        
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Schema.DescribeFieldResult fieldDescribe = objDescribe.fields.getMap().get(fieldName).getDescribe();
        
        for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
            PicklistValue picklistValue = new PicklistValue();
            picklistValue.id = entry.getValue();  // API Name
            picklistValue.name = entry.getLabel(); // Label
            picklistValues.add(picklistValue);
        }
        return picklistValues;
    }
    
    // Helper method to send response
    private static void sendResponse(EnumAPIResponse response) {
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }

    // Response wrapper
    public class EnumAPIResponse {
        public Boolean success;
        public String message;
        public EnumData data;
    }

    // Data wrapper
    public class EnumData {
        public List<SupportTypeValue> supportType;
        public List<PicklistValue> priorityList;
        public String privacyPolicyLink;
        public String aboutUsLink;
        public String termsAndConditionLink;
    }

    // Basic picklist wrapper
    public virtual class PicklistValue {
    public String id;
    public String name;
}
    
    // Support Type wrapper (with nested concernList)
    public class SupportTypeValue extends PicklistValue {
        public List<PicklistValue> concernList;
    }
}