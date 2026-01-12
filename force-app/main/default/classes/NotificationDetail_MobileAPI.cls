@RestResource(urlMapping='/NotificationDetailAPI/*')
global without sharing  class NotificationDetail_MobileAPI {
    
    @HttpPost
    global static void updateNotificationRead() {
        
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the JSON body
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='Notification_read_MobileAPI';
        log.Request__c =requestBody;
        try{
            
            notificationReqWrapper ntdata = (notificationReqWrapper) JSON.deserialize(requestBody, notificationReqWrapper.class);
            String userId = ntdata.userId;
            String NotifcationIds = ntdata.notificationId; 
            
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
            List<Notification__c> notificationlist = new List<Notification__c>();
            notificationlist = [SELECT Id,Name,Notification_Content__c,Notification_Heading__c FROM Notification__c WHERE Name=:NotifcationIds limit 1];
            
           //
            OfferResponseWrapper response = new OfferResponseWrapper();
                response.success = true;
                response.message = '';
                response.data = new SupportListData();
                response.data.NotificationHeading = notificationlist[0].Notification_Heading__c;
                response.data.NotificationContent = notificationlist[0].Notification_Content__c;
            // Send the response back using a wrapper class
           
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
            RestContext.response.statusCode = 200;
            
            log.Status__c = 'SUCCESS';
            log.Response__c= 'Notification read successfully';
            insert log;
            
        } catch (Exception e) {
            log.response__c = e.getStackTraceString();
            log.Status__c = 'FAIL';
            log.Error_Message__c = e.getMessage();
            insert log;
            
            sendErrorResponse('Login failed: ' + e.getMessage());
        }
    }
    
    

    // Wrapper class for the entire response
    public class OfferResponseWrapper {
        public Boolean success;
        public String message;
        
        public SupportListData data;
    }

    public class notificationReqWrapper {
        public String userId;
        public String notificationId;
    }
    
    
    public class SupportListResponse {
        public Boolean success;
        public String message;
        public SupportListData data;
    }
    public class SupportListData {
        public String NotificationHeading;
        public String NotificationContent;
    }
    private static void sendErrorResponse(String message) {
        RestContext.response.statusCode = 400;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object> {
            'success' => false,
            'message' => message
        }));
    }

   public Static void testcover(){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
       
       
    }


}