trigger NotificationSubscriberTrigger on Notification_Subscriber__c (before insert) {
    
     Set<Id> notificationIds = new Set<Id>();
    Set<Id> customerIds = new Set<Id>();

    for (Notification_Subscriber__c nr : Trigger.new) {
        if (nr.Notification__c != null) {
            notificationIds.add(nr.Notification__c);
        }
        if (nr.Customer_Master__c != null) {
            customerIds.add(nr.Customer_Master__c);
        }
    }

    Map<String, Notification_Subscriber__c> existingMap = new Map<String, Notification_Subscriber__c>();

    for (Notification_Subscriber__c nr : [SELECT Id, Notification__c, Customer_Master__c
       										 FROM Notification_Subscriber__c WHERE Notification__c IN :notificationIds AND Customer_Master__c IN :customerIds ]) {
        String key = nr.Notification__c + '-' + nr.Customer_Master__c;
        existingMap.put(key, nr);
    }

    for (Notification_Subscriber__c nr : Trigger.new) {
        String key = nr.Notification__c + '-' + nr.Customer_Master__c;
        if (existingMap.containsKey(key)) {
            nr.addError('A Notification Subscriber record for this Notification and Customer already exists.');
        }
    }

}