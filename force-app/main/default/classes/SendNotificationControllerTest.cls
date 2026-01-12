@isTest
public class SendNotificationControllerTest {

    // Mock callout for OneSignal
    class MockOneSignalResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"id":"dummy-id","external_id":"external123"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testSendNotification_UserSpecific() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockOneSignalResponse());

        // Create a customer
        Customer_Master__c customer = new Customer_Master__c(
           // Name = 'Test Customer',
            Email__c = 'test@example.com',
            isActive__c = true
        );
        insert customer;

        // Create notification with 'User Specific'
        Notification__c notif = new Notification__c(
           // Name = 'Test Notification',
            Notification_Content__c = 'This is a test notification.',
            //Notification_Category__c = 'User Specific',
            //Notification_Date__c = Date.today(),
            Notification_Time__c = System.now(),
            Customer_Master__c = customer.Id,
            IsActive__c = true,
            IsNotificationSent__c = false
        );
        insert notif;

        // Add a device for the customer
        Logged_in_Device__c device = new Logged_in_Device__c(
            Customer_Master__c = customer.Id,
            Device_Id__c = 'device123',
            Status__c = 'Active'
        );
        insert device;

        Test.startTest();
        SendNotificationController.sendNotification(notif.Id);
        Test.stopTest();

        // Verify Notification_Subscriber__c was inserted
        List<Notification_Subscriber__c> subscribers = [
            SELECT Id, Customer_Master__c, Notification__c FROM Notification_Subscriber__c
            WHERE Notification__c = :notif.Id
        ];
        
    }

    @isTest
    static void testSendNotification_NotUserSpecific() {
        Test.setMock(HttpCalloutMock.class, new MockOneSignalResponse());

        Customer_Master__c customer1 = new Customer_Master__c(
           // Name = 'Customer A',
            Email__c = 'a@test.com',
            isActive__c = true
        );
        insert customer1;

        Customer_Master__c customer2 = new Customer_Master__c(
            //Name = 'Customer B',
            Email__c = 'b@test.com',
            isActive__c = true
        );
        insert customer2;

        Notification__c notif = new Notification__c(
           // Name = 'General Notification',
            Notification_Content__c = 'For all users',
           // Notification_Category__c = 'General',
            //Notification_Date__c = Date.today(),
            Notification_Time__c = System.now(),
            IsActive__c = true,
            IsNotificationSent__c = false
        );
        insert notif;
        Notification_Subscriber__c ns = new Notification_Subscriber__c ();
       
         ns.Customer_master__c=customer2.Id;
         ns.Notification__c=notif.Id;
         insert ns;

        Test.startTest();
        SendNotificationController.sendNotification(notif.Id);
        Test.stopTest();

        List<Notification_Subscriber__c> subs = [
            SELECT Id FROM Notification_Subscriber__c WHERE Notification__c = :notif.Id
        ];
       
    }

    @isTest
    static void testPushOneSignalNotification() {
        Test.setMock(HttpCalloutMock.class, new MockOneSignalResponse());

        Notification__c notif = new Notification__c(
            //Name = 'Push Test',
            Notification_Content__c = 'Test push content',
            Notification_Heading__c = 'Test Heading',
            Notification_Category__c = 'User Specific',
            //Notification_Date__c = Date.today(),
            Notification_Time__c = System.now(),
            IsActive__c = true,
            IsNotificationSent__c = false
        );
        insert notif;

        Set<String> dummyPlayers = new Set<String>{'device123', 'device456'};

        Test.startTest();
        SendNotificationController.pushOneSignalNotification(notif.Id, dummyPlayers);
        Test.stopTest();

     
       
    }
}