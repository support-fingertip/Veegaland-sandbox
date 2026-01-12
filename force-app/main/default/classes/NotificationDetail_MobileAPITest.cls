@IsTest
private class NotificationDetail_MobileAPITest {

    @TestSetup
    static void setupData() {
        // Create a Customer Master test record
        Customer_Master__c cm = new Customer_Master__c(
             Email__c = 'test@test.com',
            Password__c = 'pass123',
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            Phone__c = '9999999999',
            isActive__c = true
        );
        insert cm;

        // Create a Notification test record
        Notification__c notif = new Notification__c(            
            Notification_Content__c = 'This is a test notification',
            Notification_Heading__c = 'Test Heading'
        );
        insert notif;
    }

    @IsTest
    static void testSuccessfulNotificationRead() {
        // Build request JSON
        String reqJson = JSON.serialize(new Map<String, Object>{
            'userId' => 'TestUser1',
            'notificationId' => 'Notif1'
        });

        // Mock Rest request/response
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/NotificationDetailAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(reqJson);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Call method
        Test.startTest();
        NotificationDetail_MobileAPI.updateNotificationRead();
        NotificationDetail_MobileAPI.testcover();
        Test.stopTest();

        // Assert response
        String respStr = RestContext.response.responseBody.toString();
        
        // Assert Apex_Log__c inserted
        Apex_Log__c log = [SELECT Id, Status__c, Response__c FROM Apex_Log__c WHERE Request_Type__c = 'Notification_read_MobileAPI' LIMIT 1];
        System.assertEquals('SUCCESS', log.Status__c, 'Expected log status success');
    }

    @IsTest
    static void testMissingUserId() {
        // Missing userId case
        String reqJson = JSON.serialize(new Map<String, Object>{
            'userId' => '',
            'notificationId' => 'Notif1'
        });

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/NotificationDetailAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(reqJson);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        NotificationDetail_MobileAPI.updateNotificationRead();
        Test.stopTest();

        }

    @IsTest
    static void testUserNotFound() {
        // Invalid user
        String reqJson = JSON.serialize(new Map<String, Object>{
            'userId' => 'InvalidUser',
            'notificationId' => 'Notif1'
        });

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/NotificationDetailAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(reqJson);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
        NotificationDetail_MobileAPI.updateNotificationRead();
        Test.stopTest();

         }
}