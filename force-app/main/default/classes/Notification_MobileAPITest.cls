@isTest
private class Notification_MobileAPITest {
    @testSetup
    static void setup() {
        Customer_Master__c cust = new Customer_Master__c(  Email__c='notif@a.com', Password__c='pw', First_Name__c='N', Last_Name__c='U', Phone__c='1000000001', isActive__c=true);
        insert cust;
        
        
        Notification__c notif = new Notification__c(  IsActive__c=true, Notification_Category__c='Offers', Notification_Time__c=System.now(), IsNotificationSent__c =true);
        insert notif;
        
         //  ContentVersion
        ContentVersion cv1 = new ContentVersion(
            Title = '[ Notification Image ]',
            PathOnClient = 'Notification.pdf',
            VersionData = Blob.valueOf('Test content')
        );
        insert cv1;

        
        ContentVersion insertedCV1 = [
            SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv1.Id
        ];

        // Link ContentDocument to Project
        ContentDocumentLink cdl1 = new ContentDocumentLink(
            ContentDocumentId = insertedCV1.ContentDocumentId,
            LinkedEntityId = notif.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl1;

      
        List<ContentDistribution> existingDists1 = [
            SELECT Id FROM ContentDistribution WHERE ContentVersionId = :insertedCV1.Id
        ];

        if (existingDists1.isEmpty()) {
            
            ContentDistribution dist1 = new ContentDistribution(
                Name = 'Test Dist',
                ContentVersionId = insertedCV1.Id
            );
        
            insert dist1;
            }
        
        Notification_Subscriber__c ntr = new Notification_Subscriber__c(Customer_Master__c =cust.id,Notification__c = notif.id);
        insert ntr;
    }
    @isTest
    static void testSuccessOffers() {
        Customer_Master__c cust = [SELECT Name FROM Customer_Master__c LIMIT 1];
        String body = JSON.serialize(new Map<String,Object>{'userId'=>cust.Name, 'isNotification'=>'False', 'pageSize'=>0});
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/NotificationAPI/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(body);
        RestContext.response = new RestResponse();
        Test.startTest();
        Notification_MobileAPI.getOfferDetail();
        Test.stopTest();
        
        System.assertEquals(200, RestContext.response.statusCode);
    }
    @isTest
    static void testBlankUserId() {
        String body = JSON.serialize(new Map<String,Object>{'userId'=>'', 'isNotification'=>'False', 'pageSize'=>0});
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/NotificationAPI/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(body);
        RestContext.response = new RestResponse();
        Test.startTest();
        Notification_MobileAPI.getOfferDetail();
        Test.stopTest();
        
    }
    
    @isTest
    static void testSuccessOffers1() {
        Customer_Master__c cust = [SELECT Name FROM Customer_Master__c LIMIT 1];
        String body = JSON.serialize(new Map<String,Object>{'userId'=>cust.Name, 'isNotification'=>'True', 'pageSize'=>0});
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/NotificationAPI/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(body);
        RestContext.response = new RestResponse();
        Test.startTest();
        Notification_MobileAPI.getOfferDetail();
        Test.stopTest();
        
        System.assertEquals(200, RestContext.response.statusCode);
    }
}