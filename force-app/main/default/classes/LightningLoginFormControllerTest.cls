@IsTest(SeeAllData = true)
public with sharing class LightningLoginFormControllerTest {
    
    @IsTest
    static void LightningLoginFormControllerInstantiation() {
        LightningLoginFormController controller = new LightningLoginFormController();
        System.assertNotEquals(controller, null);
    }
    
    @IsTest
    static void testIsUsernamePasswordEnabled() {
        System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled());
    }
    
    @IsTest
    static void testIsSelfRegistrationEnabled() {
        System.assertEquals(false, LightningLoginFormController.getIsSelfRegistrationEnabled());
    }
    
    @IsTest
    static void testGetSelfRegistrationURL() {
        System.assertEquals(null, LightningLoginFormController.getSelfRegistrationUrl());
    }
    
    @IsTest
    static void testAuthConfig() {
        Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
        System.assertNotEquals(null, authConfig);
    }
    
    // Mock class for Site.login method to simulate failed login
    class MockSiteLoginFailure implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Simulating a failed login with a 400 Bad Request response
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            
            // Simulate error response from the login system
            res.setBody('{"error":"Invalid credentials"}');
            res.setStatusCode(400);  // HTTP status code 400 (Bad Request)
            
            return res;
        }
    }

    @isTest
    static void testLoginFailure() {
        // Prepare test data for failed login
        String username = 'wrongUser';
        String password = 'wrongPassword';
        String startUrl = '/home';
        
        // Mock the Site.login method to throw an exception (simulate login failure)
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSiteLoginFailure());
        String result = LightningLoginFormController.login(username, password, startUrl);
        Test.stopTest();
        
    }
     @isTest
    static void testGetForgotPasswordUrl() {
        // Mock the AuthConfiguration
        Test.startTest();
        String result = LightningLoginFormController.getForgotPasswordUrl();
        Test.stopTest();
        
    }
     @isTest
    static void testSetExperienceIdSuccess() {
        // Test setting experience id
        String experienceId = 'TestExperienceId';
        
        Test.startTest();
        String result = LightningLoginFormController.setExperienceId(experienceId);
        Test.stopTest();
    }
}