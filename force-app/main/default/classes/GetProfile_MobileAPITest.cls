@isTest
private class GetProfile_MobileAPITest {
    @isTest static void testGetProfileMethod_Success() {
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
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/GetProfileAPI/';
        req.httpMethod = 'POST';
        GetProfile_MobileAPI.getProfileWrapper w = new GetProfile_MobileAPI.getProfileWrapper();
        w.userId = cm.Name;
        req.requestBody = Blob.valueOf(JSON.serialize(w));
        RestContext.request = req;
        RestContext.response = new RestResponse();
        Test.startTest();
        GetProfile_MobileAPI.getProfileMethod();
        Test.stopTest();
    }
    @isTest static void testGetProfileMethod_MissingUserId() {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/GetProfileAPI/';
        req.httpMethod = 'POST';
        GetProfile_MobileAPI.getProfileWrapper w = new GetProfile_MobileAPI.getProfileWrapper();
        w.userId = '';
        req.requestBody = Blob.valueOf(JSON.serialize(w));
        RestContext.request = req;
        RestContext.response = new RestResponse();
        GetProfile_MobileAPI.getProfileMethod();
    }
}