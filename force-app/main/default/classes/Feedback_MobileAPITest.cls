@isTest
private class Feedback_MobileAPITest {
    @isTest static void testCreateFeedback_Success() {
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
        req.requestURI = '/services/apexrest/FeedbackAPI/';
        req.httpMethod = 'POST';
        Feedback_MobileAPI.LeadWrapper w = new Feedback_MobileAPI.LeadWrapper();
        w.userid = cm.Name;
        w.token = 'tok123';
        w.fullName = 'Tester';
        w.subject = 'Test';
        w.email = 't@t.com';
        w.phoneNumber = '12345';
        w.message = 'Feedback!';
        req.requestBody = Blob.valueOf(JSON.serialize(w));
        RestContext.request = req;
        RestContext.response = new RestResponse();
        Test.startTest();
        Feedback_MobileAPI.CreateFeedback();
        Test.stopTest();
    }
    @isTest static void testCreateFeedback_MissingFields() {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/FeedbackAPI/';
        req.httpMethod = 'POST';
        Feedback_MobileAPI.LeadWrapper w = new Feedback_MobileAPI.LeadWrapper();
        w.userid = '';
        req.requestBody = Blob.valueOf(JSON.serialize(w));
        RestContext.request = req;
        RestContext.response = new RestResponse();
        Feedback_MobileAPI.CreateFeedback();
    }
}