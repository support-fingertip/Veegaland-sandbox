public class CustomNotificationServiceClass {
    public static void sendCustomNotification(map<Id,Set<String>> leadIdToOwnerIdsMap, String Title, String Body, String notificationName) {
        if (leadIdToOwnerIdsMap.isEmpty()) {
            return;
        }
        
        try {
            // Fetch Notification Type
            CustomNotificationType notificationType;
            try {
                notificationType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName =: notificationName LIMIT 1];
            } catch (Exception e) {
                System.debug('Error: Custom Notification Type not found for ' + notificationName);
                return; // Exit if notification type is missing
            }
            
            // Create and Send Notification
            for (Id recordId : leadIdToOwnerIdsMap.keySet()) {
                
                Set<String> ownerIds = leadIdToOwnerIdsMap.get(recordId);
                
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setNotificationTypeId(notificationType.Id);
                notification.setSenderId(UserInfo.getUserId());
                notification.setBody(Body);
                notification.setTitle(Title);
                notification.setTargetId(recordId);
                
                // Sending the notification
                notification.send(ownerIds);
            }
            System.debug('Custom Notification Sent Successfully!');
        } catch (Exception e) {
            System.debug('Error sending custom notification: ' + e.getMessage());
        }
    }
    
}