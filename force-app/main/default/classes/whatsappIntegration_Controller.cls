public class whatsappIntegration_Controller {
    @Future(callout=true)
    Public static void WhatsappTextMessage(string types,string executiveName,string executivePhone,string CustomerNumber, string ScheduledDate, string ScheduledTime){
        Whats_app__mdt  info=[select Access_Token__c,type__c,language__c,templateName__c,EndPoint__c,API_Key__c from Whats_app__mdt 
                                where IsActive__c=true and type__c=:types];
        system.debug('API_Key '+info.API_Key__c);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(info.EndPoint__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Api-Key', info.API_Key__c);
        //request.setHeader('Authorization','Api-Key a98c3afc-2c95-4395-ad24-e4d564e4807c');
        data d = new data();
        d.to = CustomerNumber;
        d.templateName = info.templateName__c;
        d.language = info.language__c;
        d.callbackData = 'test data';
        body b = new body(); 
        List<parameters> pList = new List<parameters>();
        if(types=='Site visit confirmation'){
            parameters p2 = new parameters();
            p2.type = 'text';
            p2.text = ScheduledDate;
            pList.add(p2);
            parameters p3 = new parameters();
            p3.type = 'text';
            p3.text = ScheduledTime;
            pList.add(p3);
            parameters p = new parameters();
            p.type = 'text';
            p.text = executiveName;
            pList.add(p);
            parameters p1 = new parameters();
            p1.type = 'text';
            p1.text = executivePhone;
            pList.add(p1); 
        }
        else if(types=='Welcome message For Lead Creation' || types=='Site visit thank you message'){
            parameters p = new parameters();
            p.type = 'text';
            p.text = executiveName;
            pList.add(p);
            parameters p1 = new parameters();
            p1.type = 'text';
            p1.text = executivePhone;
            pList.add(p1);  
        }
        b.parameters = pList;
        d.body = b;
        string requestBody = JSON.serialize(d); 
        request.setBody(requestBody);
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='Whatsapp '+types;
        log.Request__c =requestBody;
        try{
            HttpResponse response = http.send(request);
            string cc=response.getBody() ;
            log.response__c = cc;
            log.Mobile_Number__c = CustomerNumber;
            system.debug(cc);
            if (response.getStatusCode() == 201 || response.getStatusCode()== 200) 
            {
                System.debug('The status code returned was not expected: ' +  response.getStatusCode() + ' ' + response.getStatus());
            } 
            else 
            {
                system.debug( response.getBody());
            }
            insert log;
            
        }
        catch(DmlException e) {
            system.debug('system error message'+e.getMessage());  
        }   
    }
    // singel message with template
    public class data{
        public string to{get;set;}  
        public string templateName{get;set;} 
        public string language{get;set;}
        public string callbackData{get;set;}
        public string header{get;set;}
        public body body{get;set;}
        public string button{get;set;} 
    }
    public class body {
        public list<parameters> parameters{get;set;} 
    }
    public class parameters {
        public string type{get;set;} 
        public string text{get;set;} 
    }
}