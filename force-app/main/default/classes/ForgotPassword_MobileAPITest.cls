@isTest
private class ForgotPassword_MobileAPITest {
    @isTest static void testForgotPassword_Success() {
        Customer_Master__c cm = new Customer_Master__c(Email__c='t@t.com', Phone__c='12345', isActive__c=true);
        insert cm;
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ForgotPasswordAPI/';
        req.httpMethod = 'POST';
        ForgotPassword_MobileAPI.changedPassowrdWrapper w = new ForgotPassword_MobileAPI.changedPassowrdWrapper();
        w.email = cm.Email__c;
        w.phoneNumber = cm.Phone__c;
        req.requestBody = Blob.valueOf(JSON.serialize(w));
        RestContext.request = req;
        RestContext.response = new RestResponse();
        Test.startTest();
        ForgotPassword_MobileAPI.changePasswordMethod();
        Test.stopTest();
    }
    @isTest static void testForgotPassword_MissingFields() {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ForgotPasswordAPI/';
        req.httpMethod = 'POST';
        ForgotPassword_MobileAPI.changedPassowrdWrapper w = new ForgotPassword_MobileAPI.changedPassowrdWrapper();
        w.email = '';
        w.phoneNumber = '';
        req.requestBody = Blob.valueOf(JSON.serialize(w));
        RestContext.request = req;
        RestContext.response = new RestResponse();
        ForgotPassword_MobileAPI.changePasswordMethod();
    }
}