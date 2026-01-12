@isTest
private class NotificationRead_MobileAPITest {

    @testSetup
    static void setupTestData() {
        User u = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];

        // Create CRM Executive
        User crmExec = new User(
            Username = 'crmuser' + System.currentTimeMillis() + '@test.com',
            Alias = 'crmusr',
            Email = 'crm@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Exec',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
          ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/New_York'
        );
        insert crmExec;

        // Create Customer
        Customer_Master__c customer = new Customer_Master__c(
          
            Email__c = 'test@test.com',
            Phone__c = '9999999999',
            First_Name__c = 'Test',
            Last_Name__c = 'User',
            isActive__c = true
           
        );
        insert customer;

        // Create Notification
        Notification__c noti = new Notification__c(
           
            IsActive__c = true
           
        );
        insert noti;

        // Link Notification to Customer
        Notification_Subscriber__c nrc = new Notification_Subscriber__c(
            Customer_Master__c = customer.Id,
            Notification__c = noti.Id,
            isRead__c = false
        );
        insert nrc;
    }

    @isTest
    static void testNotificationUpdateSuccess() {
        Customer_Master__c cm = [SELECT Name FROM Customer_Master__c LIMIT 1];
        Notification__c noti = [SELECT Name FROM Notification__c LIMIT 1];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestUri = '/services/apexrest/NotificationReadAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(
            '{"userId": "' + cm.Name + '", "notificationId": ["' + noti.Name + '"]}'
        );

        RestContext.request = req;
        RestContext.response = res;

        NotificationRead_MobileAPI.updateNotificationRead();

        Notification_Subscriber__c updatedNrc = [SELECT isRead__c FROM Notification_Subscriber__c LIMIT 1];
        System.assertEquals(true, updatedNrc.isRead__c);
    }

    @isTest
    static void testMissingUserId() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestUri = '/services/apexrest/NotificationReadAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(
            '{"userId": "", "notificationId": ["TEST_NOTIF_1"]}'
        );

        RestContext.request = req;
        RestContext.response = res;

        NotificationRead_MobileAPI.updateNotificationRead();

        System.assertEquals(400, RestContext.response.statusCode);
    }

    @isTest
    static void testInvalidCustomer() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestUri = '/services/apexrest/NotificationReadAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(
            '{"userId": "INVALID_USER", "notificationId": ["TEST_NOTIF_1"]}'
        );

        RestContext.request = req;
        RestContext.response = res;

        NotificationRead_MobileAPI.updateNotificationRead();

        System.assertEquals(400, RestContext.response.statusCode);
    }

    @isTest
    static void testEmptyNotificationList() {
        Customer_Master__c cm = [SELECT Name FROM Customer_Master__c LIMIT 1];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestUri = '/services/apexrest/NotificationReadAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(
            '{"userId": "' + cm.Name + '", "notificationId": []}'
        );

        RestContext.request = req;
        RestContext.response = res;

        NotificationRead_MobileAPI.updateNotificationRead();

        System.assertEquals(200, RestContext.response.statusCode); // still a success
    }
}