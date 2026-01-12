@RestResource(urlMapping='/NotificationAPI/*')
global without sharing  class Notification_MobileAPI {
    
    @HttpPost
    global static void getOfferDetail() {
        
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the JSON body
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='Notification_MobileAPI';
        log.Request__c =requestBody;
        try{
            
            notificationReqWrapper ntdata = (notificationReqWrapper) JSON.deserialize(requestBody, notificationReqWrapper.class);
            String userId = ntdata.userId;
            String isNotification = ntdata.isNotification; // if they want offers they will pass "false" in this parameter. if they want other notifications they will pass "true"
            Integer pageSize = ntdata.pageSize;
            
            if (String.isBlank(userId)) {
                log.response__c = 'User Id Should not be blank.';
                log.Status__c ='SUCCESS';
                insert log;
                
                sendErrorResponse('User Id Should not be blank.');
                return;
            }
            List<Customer_Master__c> cmList = [ SELECT Id, Email__c, Password__c, First_Name__c, Last_Name__c, Phone__c, Name, Loyality__c/*, CRM_Executive__c, CRM_Executive__r.LastName, CRM_Executive__r.Phone, CRM_Executive__r.Email */ FROM Customer_Master__c WHERE Name = :userId AND isActive__c = TRUE LIMIT 1 ];
            
            if (cmList.isEmpty()) {
                log.response__c = 'Customer Not Found';
                log.Status__c ='SUCCESS';
                insert log;
                
                sendErrorResponse('User Not Found in System');
                return;
            }
            set<Id> notiIds = new  set<Id>();
            
            List<Notification__c> notificationlist = new List<Notification__c>();
            Map<Id, Boolean> readMap = new Map<Id, Boolean>();
            for(Notification_Subscriber__c  ncr : [SELECT Id, isRead__c, Customer_Master__c, Notification__c FROM Notification_Subscriber__c WHERE Notification__r.isActive__c=true AND customer_master__c=:cmList[0].Id]){
                notiIds.add(ncr.Notification__c);
                readMap.put(ncr.Notification__c, ncr.isRead__c);
            }
            System.debug(notiIds);
            System.debug(readMap);
            
              notificationlist = [SELECT Id, Customer_Master__c, IsActive__c, IsNotificationSent__c, Notification_Category__c, Notification_Date__c, Notification_Content__c, Notification_Time__c, Name
                                    FROM Notification__c WHERE isActive__c = True AND IsNotificationSent__c = True  AND Id IN : notiIds ORDER BY Notification_Time__c DESC limit 10 OFFSET : pageSize];
           system.debug(notificationlist.size());
     /*       if (isNotification=='True') {
                notificationlist = [SELECT Id, Customer_Master__c, IsActive__c, IsNotificationSent__c, Notification_Category__c, Notification_Date__c, Notification_Content__c, Notification_Time__c, Name
                                    FROM Notification__c WHERE isActive__c = True AND IsNotificationSent__c = True AND Notification_Category__c != 'Offers' AND Id IN : notiIds ORDER BY Notification_Time__c DESC limit 10 OFFSET: pageSize];
            } else {
                notificationlist = [SELECT Id, Customer_Master__c, IsActive__c, IsNotificationSent__c, Notification_Category__c, Notification_Date__c, Notification_Content__c, Notification_Time__c, Name
                                    FROM Notification__c WHERE isActive__c = True AND IsNotificationSent__c = True AND Notification_Category__c = 'Offers' AND Id IN : notiIds ORDER BY Notification_Time__c DESC limit 10 OFFSET : pageSize];
            }*/
            //system.debug(notificationlist.size());
            
            Map<Date, List<Notification__c>> NotiDateMap = new Map<Date, List<Notification__c>>();
            Set<Id> NotificationIds = new Set<Id>();
            for (Notification__c nt : notificationlist) {
                NotificationIds.add(nt.Id);
            }
            //List<Notification_Read_Customer__c> lstnotfreadc = new List<Notification_Read_Customer__c>();
            //lstnotfreadc = [SELECT Id, isRead__c, Customer_Master__c, Notification__c FROM Notification_Read_Customer__c WHERE Notification__c IN :NotificationIds AND customer_master__c=:cmList[0].Id];
            
            
            //For Notification Image
            Map<Id, Id> projectToDocMap = new Map<Id, Id>();
            Map<Id, String> docToDistUrl = new Map<Id, String>();
            
            
            List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>();
            
            // ✅ Only run the query if NotificationIds is NOT empty!
            if (!NotificationIds.isEmpty()) {
                docLinks = [SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink WHERE LinkedEntityId IN :NotificationIds];
            }
            
            Set<Id> contentDocIds = new Set<Id>();
            for (ContentDocumentLink link : docLinks) {
                contentDocIds.add(link.ContentDocumentId);
            }
            Map<Id, String> docIdToTitle = new Map<Id, String>();
            for (ContentVersion cv : [SELECT ContentDocumentId, Title FROM ContentVersion WHERE ContentDocumentId IN: contentDocIds AND Title LIKE '%[ Notification Image ]%' ]) {
                docIdToTitle.put(cv.ContentDocumentId, cv.Title);
            }
            
            for (ContentDistribution cd : [ SELECT ContentDocumentId, DistributionPublicUrl,ContentDownloadUrl FROM ContentDistribution WHERE ContentDocumentId IN: docIdToTitle.keySet() ]) {
                String picUrl = '';
                picUrl =  cd.ContentDownloadUrl.replace('download/?' , 'renditionDownload?rendition=ORIGINAL_Jpg&');
                picUrl = picUrl.replace('&ids' , '&versionId');
                
                docToDistUrl.put(cd.ContentDocumentId,picUrl);
            }
            for (ContentDocumentLink link : docLinks) {
                Id docId = link.ContentDocumentId;
                Id projId = link.LinkedEntityId;
                if (docToDistUrl.containsKey(docId)) {
                    projectToDocMap.put(projId, docId);
                }
            }
            
            
            
            // Prepare the response object
            List<AnnouncementWrapper> announcementList = new List<AnnouncementWrapper>();
            for (Notification__c notification : notificationlist) {
                Date notificationDate = notification.Notification_Date__c;
                if (!NotiDateMap.containsKey(notificationDate)) {
                    NotiDateMap.put(notificationDate, new List<Notification__c>());
                }
                NotiDateMap.get(notificationDate).add(notification);
            }
            System.debug(NotiDateMap);
            for (Date dt : NotiDateMap.keySet()) {
                AnnouncementWrapper announcement = new AnnouncementWrapper();
                announcement.ntdate = dt.format();
                List<NotificationWrapper> notifications = new List<NotificationWrapper>();
                
                for (Notification__c notification : NotiDateMap.get(dt)) {
                    NotificationWrapper notificationData = new NotificationWrapper();
                    notificationData.notificationsId = notification.Name;
                   // notificationData.imageUrl = notification.ImageUrl__c;
                    notificationData.description = notification.Notification_Content__c;
                    notificationData.notificationTime = notification.Notification_Time__c.format();
                    notificationData.isRead = readMap.get(notification.Id);
                    if (projectToDocMap.containsKey(notification.Id)) {
                        Id docId = projectToDocMap.get(notification.Id);
                        system.debug(docId + '==='+ docToDistUrl.get(docId));
                        notificationData.imageUrl = docToDistUrl.get(docId);
                    } else {
                        notificationData.imageUrl = '';
                    }
                    
                    
                    notifications.add(notificationData);
                }
                
                announcement.notifications = notifications;
                announcementList.add(announcement);
            }
            
            // Send the response back using a wrapper class
            OfferResponseWrapper response = new OfferResponseWrapper();
            response.success = true;
            response.message = '';
            response.data = new DataWrapper();
            response.data.announcementList = announcementList;
            response.data.totalCount = notificationlist.size();
            
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
            RestContext.response.statusCode = 200;
            
            log.Status__c = 'SUCCESS';
            insert log;
            
        } catch (Exception e) {
            log.response__c = e.getStackTraceString();
            log.Status__c = 'FAIL';
            log.Error_Message__c = e.getMessage();
            insert log;
            
            sendErrorResponse('Login failed: ' + e.getMessage());
        }
    }
    
    // Wrapper class for notifications
    public class NotificationWrapper {
        public String notificationsId;
        public String imageUrl;
        public String description;
        public String notificationTime;
        public Boolean isRead;
    }
    
    // Wrapper class for announcements
    public class AnnouncementWrapper {
        public String ntdate;
        public List<NotificationWrapper> notifications;
    }
    
    // Wrapper class for the data response
    public class DataWrapper {
        public List<AnnouncementWrapper> announcementList;
        public Integer totalCount;
    }
    
    // Wrapper class for the entire response
    public class OfferResponseWrapper {
        public Boolean success;
        public String message;
        public DataWrapper data;
    }
    
    public class notificationReqWrapper {
        public String userId;
        public String isNotification;
        public Integer pageSize;
    }
    
    private static void sendErrorResponse(String message) {
        RestContext.response.statusCode = 400;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object> {
            'success' => false,
                'message' => message
                }));
    }
    
    
    
}