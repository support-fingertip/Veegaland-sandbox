public class SendNotificationController {
    @AuraEnabled
    public static void sendNotification(String recordId) {
        if(recordId!=null){
            
            Notification__c nc = [SELECT Id,Name,Notification_Content__c,Notification_Date__c,Notification_Time__c,IsNotificationSent__c,IsActive__c,Customer_Master__c,Notification_Category__c,
                                  (SELECT Id,Name,Customer_master__c,Notification__c FROM Notification_Subscribers__r)
                                  FROM Notification__c WHERE Id=:recordId];
            set<Id> customerIds = new set<Id>();
            for(Notification_Subscriber__c nrc : nc.Notification_Subscribers__r){
                customerIds.add(nc.Customer_Master__c);
            }
            List<Customer_Master__c> cmList = new List<Customer_Master__c>();
            if(nc.Notification_Category__c=='User Specific' && !customerIds.contains(nc.Customer_Master__c)){
                cmList = [ SELECT Id, Email__c, Password__c,First_Name__c, Last_Name__c, Phone__c,Name,Loyality__c  FROM Customer_Master__c  where isActive__c = TRUE AND Id=:nc.Customer_Master__c];
            }else{
                cmList = [ SELECT Id, Email__c, Password__c,First_Name__c, Last_Name__c, Phone__c,Name,Loyality__c  FROM Customer_Master__c  where isActive__c = TRUE AND Id NOT IN : customerIds];
            }
            
            List<Notification_Subscriber__c> lstntrc = new List<Notification_Subscriber__c>();
            set<Id> customerId = new  set<Id>();
            For(Customer_Master__c cr : cmList){
                customerId.add(cr.id);
                Notification_Subscriber__c ntrc = new Notification_Subscriber__c();
                ntrc.Customer_Master__c = cr.id;
                ntrc.Notification__c =nc.id;
                ntrc.isRead__c = false;
                lstntrc.add(ntrc);
            }
            set<string> deviceId = new set<string>();
            if(customerId.size()>0){
                List<Logged_in_Device__c> deviceList = new List<Logged_in_Device__c>();
                deviceList = [SELECT Id,Device_Id__c FROM Logged_in_Device__c WHERE Customer_Master__c IN :customerId AND Status__c='Active' AND Device_Id__c!=null];
                for(Logged_in_Device__c div : deviceList){
                    deviceId.add(div.Device_Id__c);
                }
                
            }
            try{
                if(!lstntrc.isEmpty()){
                    pushOneSignalNotification(recordId,deviceId);
                    insert lstntrc;
                    
                } 
            }catch (Exception e){
                
                system.debug('Exception' + e.getMessage());
                
            }
            
            
        }
    }
    
    @future (callout=true)
    public static void pushOneSignalNotification(String recordId, set<string> playerIds){
        Notification__c noti = [SELECT Id,Name,Notification_Content__c,Notification_Date__c,Notification_Heading__c,Notification_Category__c,Notification_Time__c,IsNotificationSent__c,IsActive__c,Customer_Master__c,One_signal_Notifcation_Id__c FROM Notification__c WHERE Id=:recordId];
        string appId = System.Label.app_id;
        string oneSignalAccessToken = System.Label.oneSignalAccessToken;
        // List<string> playerIDs = new List<string>();
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c = 'Mobile App - push OneSignal Notification';
        
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setHeader('Content-Type', 'application/json');
            
            request.setHeader('Authorization', 'Bearer '+oneSignalAccessToken );
            request.setEndpoint('https://onesignal.com/api/v1/notifications');
            //String payload = '{"app_id": "a82ed698-77db-43f2-b4e1-cb12aba8e75d", "contents": {"en": "' + message + '"}, "include_player_ids": ["' + playerIDs + '"]}';
            
            //String payload = '{"app_id": "'+appId+'", "contents": {"en": "' + noti.Notification_Description__c + '"}, "include_player_ids": ' + playerIDs + ',"ios_sound": "your_custom_ios_sound.wav","android_sound": "your_custom_android_sound.mp3"   }  ';
            
            Map<String, Object> payload = new Map<String, Object>();
            payload.put('app_id', appId);
            if(noti.Notification_Category__c !='User Specific'){
                payload.put('included_segments', new List<String>{'All'});
            }else{
                payload.put('include_player_ids', playerIds);
            }
            
            payload.put('headings', new Map<String, String>{'en' => noti.Notification_Heading__c});
            payload.put('contents', new Map<String, String>{'en' => noti.Notification_Content__c});
            //payload.put('large_icon', 'https://cdn-icons-png.flaticon.com/512/733/733585.png');
            //payload.put('big_picture', noti.ImageUrl__c);
            String body = JSON.serialize(payload);
            
            
            request.setBody(body);   
            log.Request__c = body;
            request.setMethod('POST');
            if(!test.isRunningTest()){
                HttpResponse response = http.send(request);
                System.debug('response==>'+response.getBody());
                String var= response.getBody() ;
                log.response__c = var.length()<100000?var:'Long Response';
                
                OneSignalWrapper osWrap = (OneSignalWrapper)JSON.deserialize(var, OneSignalWrapper.class);
                
                
                System.debug('==>'+osWrap);
                if(response.getStatusCode()==200){
                    log.Status__c = 'Success';
                    if(osWrap.id!=null)
                        noti.One_signal_Notifcation_Id__c = osWrap.id;
                    noti.IsNotificationSent__c = true;
                    noti.Notification_Time__c = system.now();
                    
                }else{//Handler the Error
                    log.Status__c = 'One Signal : Error';
                    System.debug('can\'t establish the connection with the API'+osWrap);
                }
            }
        }   catch(Exception e){
            log.Status__c = 'SF : Error';
            log.Error_Message__c =  e.getMessage();
            System.debug('Something went wrong'+e.getMessage());
        } 
        update noti;
        insert log;
    }
    public class OneSignalWrapper {
        public String id;
        public String external_id;
        public Errors errors;
    }
    
    public class Errors {
        public List<String> invalid_player_ids;
    }
}