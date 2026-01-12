@isTest
private class WorkProgressscreen_MobileAPITest {
   // Helper method to set up RestContext
    private static RestRequest setupRestRequest(String requestBody) {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/WorkProgressScreenAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();
        return req;
    }    
    // Test successful retrieval of work progress details
    @isTest static void testGetMyPropertiesDetail_Success() {
        // Setup test data
        Customer_Master__c cm = new Customer_Master__c( isActive__c=true);
        insert cm;
          cm = [SELECT Name FROM Customer_Master__c WHERE Id = :cm.Id];
           // Step 2: Insert Location
    Location__c loc = new Location__c();
    insert loc;
 loc = [SELECT Name FROM Location__c WHERE Id = :loc.Id];
    // Step 3: Insert Project with Master_Location__c and Location__c
    Project__c proj = new Project__c(
        Name = 'Veegaland Casabella',
        Master_Location__c = loc.Id,
        Active__c = true,
        Project__c = 'Veegaland Casabella'
       
    );
     proj.put('Location__Latitude__s', 10.0);
        proj.put('Location__Longitude__s', 76.0);

        insert proj;
         proj = [SELECT Name,Project_Id__c FROM Project__c WHERE Id = :proj.Id];
        Work_Progress__c wp = new Work_Progress__c(
            Project__c = proj.Id,
           
            Work_Progress_till_Now__c = Date.today()
          
        );
        insert wp;
        
        WorkProgressscreen_MobileAPI.WorkProgressScreenWrapper wrapper = new WorkProgressscreen_MobileAPI.WorkProgressScreenWrapper();
        wrapper.userId = cm.Name;
        
        // Assume Project_Id__c is set automatically; query to get it
      
        wrapper.projectId = proj.Project_Id__c ;
        
        setupRestRequest(JSON.serialize(wrapper));
        
        Test.startTest();
        WorkProgressscreen_MobileAPI.getMyPropertiesDetail();
        Test.stopTest();
        
        
    }
    
    // Test when userId or projectId is blank
    @isTest static void testGetMyPropertiesDetail_MissingFields() {
        WorkProgressscreen_MobileAPI.WorkProgressScreenWrapper wrapper = new WorkProgressscreen_MobileAPI.WorkProgressScreenWrapper();
        wrapper.userId = '';
        wrapper.projectId = '';
        
        setupRestRequest(JSON.serialize(wrapper));
        
        Test.startTest();
        WorkProgressscreen_MobileAPI.getMyPropertiesDetail();
        Test.stopTest();
        
        // Verify log entry
        Apex_Log__c log = [SELECT Response__c, Status__c FROM Apex_Log__c WHERE Request_Type__c = 'MyPropertyDetails_MobileAPI' LIMIT 1];
    }
    
    // Test when customer is not found
    @isTest static void testGetMyPropertiesDetail_CustomerNotFound() {
        WorkProgressscreen_MobileAPI.WorkProgressScreenWrapper wrapper = new WorkProgressscreen_MobileAPI.WorkProgressScreenWrapper();
        wrapper.userId = 'NonExistentUser';
        wrapper.projectId = 'PROJ001';
        
        setupRestRequest(JSON.serialize(wrapper));
        
        Test.startTest();
        WorkProgressscreen_MobileAPI.getMyPropertiesDetail();
        Test.stopTest();
        
        // Verify log entry
        Apex_Log__c log = [SELECT Response__c, Status__c FROM Apex_Log__c WHERE Request_Type__c = 'MyPropertyDetails_MobileAPI' LIMIT 1];
    }
    
    // Test when project is not found
    @isTest static void testGetMyPropertiesDetail_ProjectNotFound() {
        Customer_Master__c cm = new Customer_Master__c(
           
            isActive__c = true
        );
        insert cm;
        
        WorkProgressscreen_MobileAPI.WorkProgressScreenWrapper wrapper = new WorkProgressscreen_MobileAPI.WorkProgressScreenWrapper();
        wrapper.userId = cm.Name;
        wrapper.projectId = 'NonExistentProject';
        
        setupRestRequest(JSON.serialize(wrapper));
        
        Test.startTest();
        WorkProgressscreen_MobileAPI.getMyPropertiesDetail();
        Test.stopTest();
        
        // Verify log entry
        Apex_Log__c log = [SELECT Response__c, Status__c FROM Apex_Log__c WHERE Request_Type__c = 'MyPropertyDetails_MobileAPI' LIMIT 1];
    }
    
    // Test exception handling
    @isTest static void testGetMyPropertiesDetail_Exception() {
        // Invalid JSON to trigger an exception
        String invalidJson = '{ "userId": "TestUser", "projectId": "PROJ001"'; // Malformed JSON (missing closing brace)
        
        setupRestRequest(invalidJson);
        
        Test.startTest();
        WorkProgressscreen_MobileAPI.getMyPropertiesDetail();
        Test.stopTest();
        
        // Verify log entry
        Apex_Log__c log = [SELECT Response__c, Status__c, Error_Message__c FROM Apex_Log__c WHERE Request_Type__c = 'MyPropertyDetails_MobileAPI' LIMIT 1];
    }
}