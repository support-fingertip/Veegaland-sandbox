public class WelcomeMailController{
   @AuraEnabled 
    public static string sendWelcomeEmailtoCustomer(List<string> recId){
        system.debug('sendWelcomeEmailtoCustomer');
        string response;
        List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
                string companyName;
                
                if(!companyDetails.isEmpty()){
                    companyName = companyDetails[0].Label;
                        
                }
        if(recId.size()>0)
        {
            system.debug('sendWelcomeEmailtoCustomer');
            List<Lead> leadList = [SELECT Id,Name,OwnerId,Owner.Name,Owner.Phone,Email,Secondary_Email__c,Owner.Email,Phone,Country_Code__c FROM Lead WHERE (Email!=null or Secondary_Email__c !=null) and Id In :recId];
            /*List<OrgWideEmailAddress> lstOrgWideEmailId = [Select id from OrgWideEmailAddress];
            string orgWideEmailAddressID;
            if(lstOrgWideEmailId.size() > 0)
            {
                orgWideEmailAddressID = lstOrgWideEmailId[0].id; 
            }*/
            List<Messaging.SingleEmailMessage> semailList = new List<Messaging.SingleEmailMessage>();
            if(leadList.size()==0)
            {
                return 'Please Enter Email Id';
            }
            else{
                for(Lead qt:leadList)
                {
                    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                    //if(orgWideEmailAddressID != null){semail.setOrgWideEmailAddressId(orgWideEmailAddressID);}
                    semail.setSenderDisplayName(qt.Owner.Name);
                    semail.setReplyTo(qt.Owner.Email);
                    semail.setSubject('VeegaLand Home Welcome Message');
                    List<string> sendTo = new List<string>();
                    if(qt.Email !=null){
                        sendTo.add(qt.Email);
                    }
                    else if(qt.Secondary_Email__c !=null){
                        sendTo.add(qt.Secondary_Email__c);
                    }
                    semail.setToAddresses(sendTo);
                    semail.setHtmlBody( 
                        'Dear Valued Customer, <br/><br/>' +
                        'We appreciate your keen interest in Veegaland Homes. Your dedicated point of contact will be '+qt.Owner.Name+ ', who is readily available to assist you with any enquiries or information you may require. <br/><br/>' +
                        'For comprehensive details about the project, please visit our website, https://www.veegaland.com/ <br/><br/>'+
                        'Should you have any further questions, feel free to reach out. <br/><br/>'+
                        'Best regards,<br/><br/>' +
                        companyName+'<br/>'+
                        qt.Owner.Name + '<br/>' +
                        '[' + qt.Owner.Phone + ']'+'<br/>' );
                    
                    //Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
                    //system.debug(semail);
                    semailList.add(semail);
                    //reponse 'Welcome mail sent to customer';
                    
                }
                try{
                    //Messaging.sendEmail(semailList);
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(semailList);  
                    system.debug(results);
                    response = 'Welcome mail sent to customer';
                    
                }catch(dmlException e)
                {
                    system.debug('Error'+e.getMessage());
                    response = 'Something went wrong! please try again';
                }   
            }
            
        }
        return response;
    }
    
    public static void SendAssignedLeadEmailtoEexcutive(List<string> recId){
        List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
                string companyName;
                
                if(!companyDetails.isEmpty()){
                    companyName = companyDetails[0].Label;
                       
                }
        if(recId.size()>0)
        {
            List<Lead> leadList = [SELECT Id,Name,OwnerId,Owner.Name,Owner.Phone,Email,Secondary_Email__c,Owner.Email,CreatedDate FROM Lead WHERE Owner.Email!='' and Id In :recId];
            List<Messaging.SingleEmailMessage> semailList = new List<Messaging.SingleEmailMessage>(); 
            if(leadList.size()>0)
            {
                for(Lead qt:leadList)
                {
                    String LeadDate = qt.CreatedDate.format('dd-MM-YYYY');
                    String LeadTime = qt.CreatedDate.format('HH:mm:ss');
                    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                    semail.setSenderDisplayName(qt.Owner.Name);
                    semail.setReplyTo(qt.Owner.Email);
                    semail.setSubject('Lead Assigned Mail');
                    List<string> sendTo = new List<string>();
                    sendTo.add(qt.Owner.Email);  
                    semail.setToAddresses(sendTo);
                    semail.setHtmlBody( 
                        'Dear '+qt.Owner.Name+', <br/><br/>' +
                        'This is to inform you that a new lead, '+qt.Name+' has been allocated to you on '+LeadDate+' at '+LeadTime+'. Kindly proceed with a prompt follow-up. <br/><br/>'+
                        'Best regards,<br/><br/>' +
                        companyName+' <br/>'
                        );
                    
                    //Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
                    //system.debug(semail);
                    semailList.add(semail);
                    //reponse 'Welcome mail sent to customer';
                    
                }
                try{
                    if(semailList.size()>0){
                        //Messaging.sendEmail(semailList);
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(semailList);  
                        system.debug(results);
                        //response = 'Welcome mail sent to customer';
                    }
                    
                }catch(dmlException e)
                {
                    system.debug('Error'+e.getMessage());
                    //response = 'Something went wrong! please try again';
                }   
            }
        }
        
    }
    public static void SendWhatsAppMsg(List<string> recId){
        if(recId.size()>0){
            //whatsapp message
            if(label.DisableWhatsappaMsg == 'false'){
                system.debug('message');
                List<Lead> leadPhoneList = [SELECT Id,Name,OwnerId,Owner.Name,Owner.Phone,Email,Secondary_Email__c,Owner.Email,Phone,Country_Code__c,Country_Codes__c FROM Lead WHERE Id In :recId];
                if(leadPhoneList.size()>0){
                    for(Lead l:leadPhoneList)
                    {
                        system.debug('Welcome Whatsapp msg'+l);
                        if(l.Phone != null && l.Phone.length()>=10 && l.Owner.Phone != null){
                            string phone;
                            if(l.Country_Code__c != null){
                                phone = l.Country_Code__c+l.Phone;
                            }
                            if(label.DisableWhatsappaMsg == 'false'){
                                whatsappIntegration_Controller.WhatsappTextMessage('Welcome Message For Lead Creation',l.Owner.Name,l.Owner.Phone,phone,'','');
                            }
                        } 
                    }
                }
            } 
        }   
    }
}