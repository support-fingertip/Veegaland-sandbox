@isTest
public class WelcomeMailControllerTest {
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    public static testmethod void WelcomeMailtest(){    
// Create a User for Lead owner
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; // Change the profile name as needed
        User u = new User(
            ProfileId = p.Id,
            LastName='TestOwner',
            Email='owner@tests.com',
            Username='owner@tests.com',
            Alias='ownrs',
            CommunityNickname='ownr',
            EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            Phone='7890776600',
            TimeZoneSidKey='America/Los_Angeles'
        );
        insert u;
        Lead ld = new Lead();
        ld.LastName='Test';
        ld.Company='TestCompany';
        ld.Phone='5465474763';
        ld.ownerId = u.Id;
        insert ld;
        ld.Email='test@gmail.com';
        ld.Secondary_Email__c='test1@gmail.com';
        update ld;
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.startTest();
        WelcomeMailController.sendWelcomeEmailtoCustomer(new List<String>{ld.Id});
        WelcomeMailController.SendAssignedLeadEmailtoEexcutive(new List<String>{ld.Id});
        test.stoptest();
    }
}