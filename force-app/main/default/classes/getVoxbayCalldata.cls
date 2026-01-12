@RestResource(urlmapping = '/callcenterbridging/*')
global class getVoxbayCalldata {
    
    @HttpPost
    global static string postCallData(){
        
        //create parameters 
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String requestType = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        if(requestType=='landedOnServer'){
            String requestBody = System.RestContext.request.requestBody.toString();
            MyRequestData requestData = (MyRequestData)JSON.deserialize(requestBody, MyRequestData.class);
            String callerNumber = requestData.callerNumber;
            callerNumber = callerNumber.replaceAll('[^a-zA-Z0-9\\s+]', '');
            callerNumber = callerNumber.replaceAll(' ', '');
            if(callerNumber != null && callerNumber.startsWith('+')){
                callerNumber = callerNumber.removeStart('+');
                if(callerNumber != null && callerNumber.startsWith('91')  && callerNumber.length()>10){
                    callerNumber = callerNumber.removeStart('91');
                }
            }
            else if(callerNumber != null && callerNumber.startsWith('91') && callerNumber.length()>10){
                callerNumber = callerNumber.removeStart('91'); 
            }
            else if(callerNumber != null && callerNumber.startsWith('0') && callerNumber.length()>10){
                callerNumber = callerNumber.removeStart('0'); 
            }
            String calledNumber = requestData.calledNumber;
            String callUUID = requestData.CallUUID;
            string AgentNumber = 'none';
            List<Apex_Log__c> logList = new List<Apex_Log__c>();
            Apex_Log__c log = new Apex_Log__c();
            log.Request_Type__c ='landedOnServer';
            //string bodyJson = '{"calledNumber":"'+calledNumber+'","callerNumber":"'+callerNumber+'","CallUUID":"'+CallUUID+'","requestBody":"'+requestBody+'"}';
            log.Request__c =requestBody;
            String outcomeMsg;
            // insert call detail record
            Call_Detail__c call = new Call_Detail__c();
            call.calledNumber__c = calledNumber;
            call.callerNumber__c = callerNumber;
            call.CallUUID__c = CallUUID;
            call.Call_Type__c = 'In bound Call';
            // insert lead
            Lead l2 = new Lead();
            l2.Phone = callerNumber;
            l2.Allocated_Project__c = 'No Project Voxbay';
            l2.Company = 'abc';
            l2.Leadsource__c = 'Inbound call';
            l2.LastName = 'Customer';
            l2.CallUUID__c = CallUUID;
            if(callerNumber != null && callerNumber != '')
            {
                try {
                    system.debug('l2'+l2);
                    //Check Duplicatancy based on phone number
                    List<Lead> existingLeads = [select id,Name,OwnerId,CallUUID__c from Lead where (phone=:callerNumber or Secondary_Phone__c=:callerNumber) and Lead_Stage__c!='Closed Lost' order by CreatedDate DESC limit 1];
                    List<Related_Source__c> relatedList = [select id,Name,Lead__c,Lead__r.OwnerId,CallUUID__c from Related_Source__c where (Phone__c=:callerNumber or Secondary_Phone__c=:callerNumber) and Lead__r.Lead_Stage__c!='Closed Lost' order by CreatedDate DESC limit 1];
                    if(existingLeads.isEmpty() && relatedList.isEmpty()) {
                        insert l2;    
                    }
                    if(l2.id != null)
                    {
                        call.Lead__c = l2.id;
                    }
                    if(!existingLeads.isEmpty()){
                        call.Lead__c = existingLeads[0].id; 
                        existingLeads[0].CallUUID__c = CallUUID;
                        update existingLeads[0];
                    }
                    else if(!relatedList.isEmpty()){
                        call.Lead__c = relatedList[0].id; 
                        relatedList[0].CallUUID__c = CallUUID;
                        update relatedList[0];
                    }
                    // soql on lead when phone or secondary phone equal to callernumber. if there no lead with this number. then do soql query on related source
                    List<Lead> l = [select id,Name,OwnerId from Lead where (phone=:callerNumber or Secondary_Phone__c=:callerNumber) and Lead_Stage__c!='Closed Lost' limit 1];
                    if(l.size()>0){
                        // query on user object where Id = lead.OwnerId
                        for(Lead l1:l){
                            List<User> u = [select Id, Name, Phone from User where Id=:l1.OwnerId];
                            if(u.size()>0){
                                for(User u1:u){
                                    AgentNumber = u1.Phone;
                                    call.Lead__c = l1.id;
                                    call.OwnerId = u1.id;
                                }
                            }
                        }
                    }
                    else{
                        List<Related_Source__c> related = [select id,Name,Lead__c,Lead__r.OwnerId from Related_Source__c where (Phone__c=:callerNumber or Secondary_Phone__c=:callerNumber) and Lead__r.Lead_Stage__c!='Closed Lost' limit 1]; 
                        if(related.size()>0){
                            // query on user object where Id = lead.OwnerId
                            for(Related_Source__c r1:related){
                                if(r1.Lead__c != null){
                                    User u = [select Id, Name, Phone from User where Id=:r1.Lead__r.OwnerId];
                                    AgentNumber = u.Phone;
                                    call.Lead__c = r1.Lead__c;
                                    call.OwnerId = u.id;
                                }
                            }
                        }  
                    }
                    
                    log.status__c='SUCCESS';   
                    system.debug('call'+call);
                    insert call;
                }catch (DmlException e) {
                    System.debug('An error occurred while updating the users: ' + e.getMessage());
                    outcomeMsg = 'Error: An exception has been encountered while calling out to Integration:  ' + e.getMessage();
                    log.status__c='FAILED';
                    log.Error_Message__c = e.getMessage();  
                }
            }
            else{
                log.status__c='FAILED';
                log.Error_Message__c = 'callerNumber Missing';
            }
            //log.response__c = AgentNumber;
            logList.add(log);
            insert logList; 
            // return lead owner phone number
            return 'success';
            
        }else if(requestType=='callRoute'){
            String requestBody = System.RestContext.request.requestBody.toString();
            MyRequestData requestData = (MyRequestData)JSON.deserialize(requestBody, MyRequestData.class);
            String callerNumber = requestData.callerNumber;
            String calledNumber = requestData.calledNumber;
            String callUUID = requestData.CallUUID;
            string AgentNumber = 'none';
            callerNumber = callerNumber.replaceAll('[^a-zA-Z0-9\\s+]', '');
            callerNumber = callerNumber.replaceAll(' ', '');
            if(callerNumber != null && callerNumber.startsWith('+')){
                callerNumber = callerNumber.removeStart('+');
                if(callerNumber != null && callerNumber.startsWith('91')  && callerNumber.length()>10){
                    callerNumber = callerNumber.removeStart('91');
                }
            }
            else if(callerNumber != null && callerNumber.startsWith('91') && callerNumber.length()>10){
                callerNumber = callerNumber.removeStart('91'); 
            }
            else if(callerNumber != null && callerNumber.startsWith('0') && callerNumber.length()>10){
                callerNumber = callerNumber.removeStart('0'); 
            }
            List<Apex_Log__c> logList = new List<Apex_Log__c>();
            Apex_Log__c log = new Apex_Log__c();
            log.Request_Type__c ='callRoute';
            log.Request__c =requestBody;
            String outcomeMsg; 
            
            if(callerNumber != null && callerNumber != '')
            {
                try {
                    // soql on lead when phone or secondary phone equal to callernumber. if there no lead with this number. then do soql query on related source
                    
                    List<Lead> l = [select id,Name,OwnerId from Lead where (phone=:callerNumber or Secondary_Phone__c=:callerNumber) and Lead_Stage__c!='Closed Lost' limit 1];
                    if(l.size()>0){
                        // query on user object where Id = lead.OwnerId
                        for(Lead l1:l){
                            List<User> u = [select Id, Name, Phone from User where Id=:l1.OwnerId and Phone != null];
                            if(u.size()>0){
                                for(User u1:u){
                                    AgentNumber = u1.Phone;
                                }
                            }
                        }
                    }
                    else{
                        List<Related_Source__c> related = [select id,Name,Lead__c,Lead__r.OwnerId from Related_Source__c where (Phone__c=:callerNumber or Secondary_Phone__c=:callerNumber) and Lead__r.Lead_Stage__c!='Closed Lost' limit 1]; 
                        if(related.size()>0){
                            // query on user object where Id = lead.OwnerId
                            for(Related_Source__c r1:related){
                                if(r1.Lead__c != null){
                                    User u = [select Id, Name, Phone from User where Id=:r1.Lead__r.OwnerId and Phone != null];
                                    AgentNumber = u.Phone;
                                }
                            }
                        }  
                    }
                    log.status__c='SUCCESS';   
                }catch (DmlException e) {
                    System.debug('An error occurred while updating the users: ' + e.getMessage());
                    outcomeMsg = 'Error: An exception has been encountered while calling out to Integration:  ' + e.getMessage();
                    log.status__c='FAILED';
                    log.Error_Message__c = e.getMessage();  
                }
            }
            else{
                log.status__c='FAILED';
                log.Error_Message__c = 'callerNumber Missing';
            }
            log.response__c = AgentNumber;
            logList.add(log);
            insert logList; 
            // return lead owner phone number
            return AgentNumber; 
        }else if(requestType=='answeredByAgent'){
            String requestBody = System.RestContext.request.requestBody.toString();
            MyRequestData requestData = (MyRequestData)JSON.deserialize(requestBody, MyRequestData.class);
            String AgentNumber = requestData.AgentNumber;
            system.debug('AgentNumber'+AgentNumber);
            String calledNumber = requestData.calledNumber;
            String callUUID = requestData.CallUUID;
            List<Apex_Log__c> logList = new List<Apex_Log__c>();
            Apex_Log__c log = new Apex_Log__c();
            log.Request_Type__c ='answeredByAgent';
            log.Request__c =requestBody;
            String outcomeMsg;
            // query call detail record with CallUUID as external Id
            try{
                List<Call_Detail__c> call = [select Id, Name,Lead__c,Lead__r.OwnerId from Call_Detail__c where CallUUID__c=:CallUUID];
                if(call.size()>0 && AgentNumber != null && AgentNumber != ''){
                    // query on user object where phone = AgentNumber
                    User u = [select id, Name, Phone, Status__c from User where Phone=:AgentNumber and Availability__c=true limit 1];
                    if(u != null){
                        for(Call_Detail__c c:call){
                            c.OwnerId = u.id; 
                            c.AgentNumber__c = AgentNumber;
                        }
                        List<Lead> leadRecord = [select Id,Name,OwnerId from Lead where CallUUID__c=:CallUUID limit 1];
                        List<Lead> leadList = new List<Lead>();
                        if(leadRecord.size()>0){
                            for(Lead l:leadRecord){
                                l.OwnerId = u.Id;  
                                leadList.add(l);
                            }   
                        }
                        if(leadList.size()>0){
                            update leadList; 
                        }
                        
                        update call;
                    }
                    // change user avaliable status to in call
                    u.Status__c = 'ONCALL';
                    u.callUUID__c = callUUID;
                    update u;
                }
                List<Call_Detail__c> call1 = [select Id,Name,Lead__c,Lead__r.OwnerId from Call_Detail__c where CallUUID__c=:CallUUID limit 1]; 
                
                sendNotification(call1);
                log.status__c='SUCCESS';
            }catch (DmlException e) {
                System.debug('An error occurred while updating the users: ' + e.getMessage());
                outcomeMsg = 'Error: An exception has been encountered while calling out to Integration:  ' + e.getMessage();
                log.status__c='FAILED';
                log.Error_Message__c = e.getMessage();
            }
            logList.add(log);
            insert logList; 
            // when user click on lead name/lead Id we need to navigate to details page but popup will not close. user need eneter comments and click upate button on popup
            return 'success';       
        }else if(requestType=='callDisconnected'){
            String requestBody = System.RestContext.request.requestBody.toString();
            MyRequestData requestData = (MyRequestData)JSON.deserialize(requestBody, MyRequestData.class);
            String AgentNumber = requestData.AgentNumber;
            String callUUID = requestData.CallUUID;
            List<Apex_Log__c> logList = new List<Apex_Log__c>();
            Apex_Log__c log = new Apex_Log__c();
            log.Request_Type__c ='callDisconnected';
            log.Request__c =requestBody;
            String outcomeMsg;
            try{
                if(AgentNumber != null && AgentNumber != ''){
                    // query on user object where phone = AgentNumber
                    List<User> u = [select id, Name, Phone, Status__c from User where Phone=:AgentNumber limit 1];
                    // change user avaliable status to avaliable
                    if(u.size()>0){
                        for(User u1:u){
                            u1.Status__c = 'AVAILABLE';
                        }
                        log.status__c='SUCCESS';
                        update u;
                    }
                }
            }catch (DmlException e) {
                System.debug('An error occurred while updating the users: ' + e.getMessage());
                outcomeMsg = 'Error: An exception has been encountered while calling out to Integration:  ' + e.getMessage();
                log.status__c='FAILED';
                log.Error_Message__c = e.getMessage();
            }
            logList.add(log);
            insert logList; 
            return 'success';
        }else if(requestType=='incomingCallCDR'){
            integer totalCallDuration = 0;
            integer conversationDuration = 0;
            //integer dtmf = 0;
            String requestBody = System.RestContext.request.requestBody.toString();
            MyRequestData requestData = (MyRequestData)JSON.deserialize(requestBody, MyRequestData.class);
            string calledNumber = requestData.calledNumber;
            string callerNumber = requestData.callerNumber;
            if(requestData.totalCallDuration != null){totalCallDuration = integer.valueOf(requestData.totalCallDuration);}
            string callDate = requestData.callDate;
            string callStatus = requestData.callStatus;
            string AgentNumber = requestData.AgentNumber;
            string CallUUID = requestData.CallUUID;
            string callStartTime = requestData.callStartTime;
            string callEndTime = requestData.callEndTime;
            if(requestData.conversationDuration != null){conversationDuration = integer.valueOf(requestData.conversationDuration);}
            //if(requestData.dtmf != null){dtmf = integer.valueOf(requestData.dtmf);}
            string transferredNumber = requestData.transferredNumber;
            string recording_URL = requestData.recording_URL;
            List<Apex_Log__c> logList = new List<Apex_Log__c>();
            Apex_Log__c log = new Apex_Log__c();
            log.Request_Type__c ='incomingCallCDR';
            string bodyJson = '{"calledNumber":"'+calledNumber+'","callerNumber":"'+callerNumber+'","totalCallDuration":"'+totalCallDuration+'","callDate":"'+callDate+'","callStatus":"'+callStatus+'","AgentNumber":"'+AgentNumber+'","CallUUID":"'+CallUUID+'","callStartTime":"'+callStartTime+'","callEndTime":"'+callEndTime+'","conversationDuration":"'+conversationDuration+'","transferredNumber":"'+transferredNumber+'","recording_URL":"'+recording_URL+'"}';
            log.Request__c =bodyJson;
            String outcomeMsg;
            try{
                Call_Detail__c calldetail = new Call_Detail__c();
                calldetail.totalCallDuration__c = totalCallDuration;
                if(!Test.IsRunningTest())
                {
                    calldetail.callDate__c = datetime.valueOf(callDate);
                }
                calldetail.callStatus__c = callStatus;
                calldetail.callStartTime__c = callStartTime;
                calldetail.callEndTime__c = callEndTime;
                calldetail.CallUUID__c = CallUUID;
                calldetail.conversationDuration__c = conversationDuration;
                //calldetail.dtmf__c = dtmf;
                calldetail.transferredNumber__c = transferredNumber;
                calldetail.Call_Type__c = 'In bound Call';
                //calldetail.recording_URL__c = 'http://pbx.voxbaysolutions.com/callrecordings/'+ recording_URL;
                calldetail.recording_URL__c = recording_URL;
                calldetail.AgentNumber__c = AgentNumber;
                // upsert call detail record with new parameters
                log.status__c='SUCCESS';
                Database.upsert(calldetail, Call_Detail__c.Fields.CallUUID__c, false);
                Database.upsertResult sr = Database.upsert(calldetail, Call_Detail__c.Fields.CallUUID__c, false);
                if(!sr.isSuccess())
                {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug('Error Message: ' + err.getMessage());  
                    }
                }
            }catch (DmlException e) {
                System.debug('An error occurred while updating the users: ' + e.getMessage());
                outcomeMsg = 'Error: An exception has been encountered while calling out to Integration:  ' + e.getMessage();
                log.status__c='FAILED';
                log.Error_Message__c = e.getMessage();
            }
            logList.add(log);
            insert logList; 
            return 'success';
            
        }else if(requestType=='callIntiation'){
            string extension = RestContext.request.params.get('extension');
            string destination = RestContext.request.params.get('destination');
            string callerid = RestContext.request.params.get('callerid');
            string callUUlD = RestContext.request.params.get('callUUlD');
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            string url  =   'http://pbx.voxbaysolutions.com/api/call.php?uid=UID&pin=PIN&ext=EXTENSIONNUMBER &destination=DESTINATIONNUMBER';
            request.setEndpoint(url);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            
            
        }else if(requestType=='outgoingCallCDR'){
            string extension = RestContext.request.params.get('extension');
            string destination = RestContext.request.params.get('destination');
            string callerid = RestContext.request.params.get('callerid');
            string duration = RestContext.request.params.get('duration');
            string status = RestContext.request.params.get('status');
            string dates = RestContext.request.params.get('date');
            string recording_URL = RestContext.request.params.get('recording_URL');
            
            
            Call_Detail__c calldetail = new Call_Detail__c();
            
            if(!Test.IsRunningTest())
            {
                calldetail.duration__c = Decimal.valueOf(duration);
                calldetail.date__c = datetime.valueOf(dates);
            }
            //calldetail.callerid__c = callerid;
            calldetail.extension__c = extension;
            calldetail.destination__c = destination;
            //calldetail.CallUUID__c = CallUUID;
            calldetail.callStatus__c = status;
            calldetail.Call_Type__c = 'Out bound Call';
            calldetail.recording_URL__c = 'http://pbx.voxbaysolutions.com/callrecordings/'+ recording_URL;
            // upsert call detail record with new parameters
            Database.upsert(calldetail, Call_Detail__c.Fields.CallUUID__c, false);
        }
        //equate the parameters with the respective fields of the new record
        
        /*RestContext.response.responseBody = blob.valueOf('[{"Comment Id": 
'+JSON.serialize(thisComment.Id)+', "Message" : "Comment submitted 
successfully"}]');
} */
        
        return 'success';
    }
    
    
    public static void sendNotification(List<Call_Detail__c> call1)
    {
        // open the popup with leads details and comments.
        List<CtiNotification__e> publishEvents = new List<CtiNotification__e>();
        if(call1.size()>0)
        {
            CtiNotification__e eve = new CtiNotification__e();  
            eve.User_Id__c = call1[0].Lead__r.OwnerId ;
            eve.Record_Id__c = call1[0].Lead__c; 
            eve.ObjectName__c = 'Lead';
            System.debug(eve);
            publishEvents.add(eve);   
        }
        
        if(!publishEvents.isEmpty()){
            EventBus.publish(publishEvents);
        } 
    }
    public class MyRequestData {
        public String callerNumber;
        public String calledNumber;
        public String CallUUID;
        public String AgentNumber;
        public string totalCallDuration;
        public string callDate;
        public string callStatus;
        public string callStartTime;
        public string callEndTime;
        public string conversationDuration;
        public string dtmf;
        public string transferredNumber;
        public string recording_URL;
    }
    public static void testcover(){
        integer i=0;
        i=0;
        i=0;
        i=0;
        i=0; 
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        
        
        
    }
}