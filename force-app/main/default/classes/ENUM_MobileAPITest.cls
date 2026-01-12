@isTest
private class ENUM_MobileAPITest {
    @isTest static void testGetPicklistValues() {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ENUMAPI/';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        Test.startTest();
        ENUM_MobileAPI.getPicklistValues();
        Test.stopTest();
    }
}