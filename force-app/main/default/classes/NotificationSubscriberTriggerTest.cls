@isTest
private class NotificationSubscriberTriggerTest {

    @isTest
    static void testNotificationSubscriberTrigger() {
        // Create test Customer
        Customer_Master__c customer = new Customer_Master__c();
        insert customer;

        // Create test Notification
        Notification__c notification = new Notification__c();
        insert notification;

        // Insert first Notification Subscriber (should succeed)
        Notification_Subscriber__c sub1 = new Notification_Subscriber__c(
            Notification__c = notification.Id,
            Customer_Master__c = customer.Id
        );
        insert sub1;

        // Attempt to insert duplicate Notification Subscriber (should fail)
        Notification_Subscriber__c sub2 = new Notification_Subscriber__c(
            Notification__c = notification.Id,
            Customer_Master__c = customer.Id
        );

        Test.startTest();
        try {
            insert sub2;
            System.assert(false, 'Expected DUPLICATE error but insert succeeded');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('already exists'), 'Expected duplicate error');
        }
        Test.stopTest();
    }

    @isTest
    static void testNotificationSubscriberTriggerWithDifferentCombinations() {
        // Create two customers and two notifications
        Customer_Master__c cust1 = new Customer_Master__c();
        Customer_Master__c cust2 = new Customer_Master__c();
        insert new List<Customer_Master__c>{ cust1, cust2 };

        Notification__c notif1 = new Notification__c();
        Notification__c notif2 = new Notification__c();
        insert new List<Notification__c>{ notif1, notif2 };

        // Insert distinct combinations – should pass
        Notification_Subscriber__c s1 = new Notification_Subscriber__c(Notification__c = notif1.Id, Customer_Master__c = cust1.Id);
        Notification_Subscriber__c s2 = new Notification_Subscriber__c(Notification__c = notif1.Id, Customer_Master__c = cust2.Id);
        Notification_Subscriber__c s3 = new Notification_Subscriber__c(Notification__c = notif2.Id, Customer_Master__c = cust1.Id);
        insert new List<Notification_Subscriber__c>{ s1, s2, s3 };
    }
}