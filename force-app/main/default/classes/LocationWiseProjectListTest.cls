@isTest
private class LocationWiseProjectListTest {
    @isTest static void testGetMyPropertiesDetail_Success() {
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
        Project__c = 'Veegaland Casabella',
        Used_in_Mobile_App__c = true
       
    );
     proj.put('Location__Latitude__s', 10.0);
        proj.put('Location__Longitude__s', 76.0);

        insert proj;

        LocationWiseProjectList.locationListProjectWrapper w = new LocationWiseProjectList.locationListProjectWrapper();
        w.userId = cm.Name;
        w.locationId = loc.Name;
         w.search = 'Test';
       w.startPrice = '400000';
       w.endPrice = '600000';
       w.startAreaRange = '1000';
       w.endAreaRange = '2000';
       w.bedroomCount = '2 BHK';
     
       w.city = 'TestCity';

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/LocationWiseProjectListAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(w));
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        // Step 1: Insert ContentVersion
ContentVersion cv = new ContentVersion();
cv.Title = 'Test Project Logo';
cv.PathOnClient = 'TestProjectLogo.jpg';
cv.VersionData = Blob.valueOf('test'); // dummy blob content
insert cv;

// Step 2: Query ContentDocumentId from the inserted ContentVersion
cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];

// Step 3: Link ContentDocument to Project via ContentDocumentLink
ContentDocumentLink cdl = new ContentDocumentLink();
cdl.ContentDocumentId = cv.ContentDocumentId;
cdl.LinkedEntityId = proj.Id;
cdl.ShareType = 'V';
cdl.Visibility = 'AllUsers';
insert cdl;




        Test.startTest();
        LocationWiseProjectList.getMyPropertiesDetail();
        Test.stopTest();
    }

    @isTest static void testGetMyPropertiesDetail_MissingFields() {
        LocationWiseProjectList.locationListProjectWrapper w = new LocationWiseProjectList.locationListProjectWrapper();
        w.userId = 'test';
        w.locationId = '';

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/LocationWiseProjectListAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(w));
        RestContext.request = req;
        RestContext.response = new RestResponse();

        LocationWiseProjectList.getMyPropertiesDetail();
        
    }
        @isTest static void testGetMyPropertiesDetail_MissingblankFields() {
        LocationWiseProjectList.locationListProjectWrapper w = new LocationWiseProjectList.locationListProjectWrapper();
        w.userId = '';
        w.locationId = '';

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/LocationWiseProjectListAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(w));
        RestContext.request = req;
        RestContext.response = new RestResponse();

        LocationWiseProjectList.getMyPropertiesDetail();
        
    }
}