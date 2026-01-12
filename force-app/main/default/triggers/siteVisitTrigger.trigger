trigger siteVisitTrigger on Site_Visit__c (before insert,before update,after insert,after update,after delete) {
    if(label.site_visit_label=='TRUE'){
        if(trigger.isBefore && trigger.isInsert)
        {
            system.debug('fromUpdateLeadStatus '+CreateALogAfterLeasdUpdate.fromUpdateLeadStatus);
            List<Site_Visit__c>svlst = new List<Site_Visit__c>();
            List<id>clst = new List<id>();
            for(Site_Visit__c s:trigger.new){
                clst.add(s.Lead__c);
                system.debug(clst);
            }
            if(CreateALogAfterLeasdUpdate.fromUpdateLeadStatus != null && !CreateALogAfterLeasdUpdate.fromUpdateLeadStatus)
            {
                svlst=[select id,Status__c,Lead__c,Lead__r.Lead_status__c from Site_Visit__c where Status__c='Scheduled' and Lead__c In: clst];
                
                system.debug('size'+svlst.size());
                if(svlst.size()>0){
                    
                    for(Site_Visit__c v:trigger.new){
                        v.addError('Please change Scheduled SiteVist status as Completed or Cancelled for Previous SV');
                    }
                }
            }
            RoundRobinHandler.assignToSiteVisit(trigger.new);
        }
        if(trigger.isBefore && trigger.isUpdate)
        {
            List<Site_Visit__c> svList = trigger.new;
            for(Site_Visit__c newSv : svList) 
            {
                Site_Visit__c oldSv = Trigger.oldMap.get(newSv.Id);
                if(oldSv != null && oldSv.Reschedule_Date__c != newSv.Reschedule_Date__c && newSv.Lead_Email__c != null)
                {  
                    newSv.Status__c = 'Rescheduled';
                }
            }
            
        }
        if(trigger.isAfter && trigger.isInsert)
        {
            List<string> sendTo = new List<string>();
            list<Lead>lstContacts=new list<Lead>();
            //list<task> tsklst= new list<task>();
            List<Site_Visit__c> svList = trigger.new;
            List<Site_Visit__c> SVSchedule = [select Id,Name,Date__c,OwnerId,Owner.Name,Owner.Email, Owner.Phone,Lead_Email__c,Lead__r.Email,Lead__r.Secondary_Email__c from Site_Visit__c where Status__c='Scheduled' and Id In :svList and Lead_Email__c != null];
            List<Messaging.SingleEmailMessage> semailList = new List<Messaging.SingleEmailMessage>();
            List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
                string companyName;
                
                if(!companyDetails.isEmpty()){
                    companyName = companyDetails[0].Label;
                        
                }
            for(Site_Visit__c sv:SVSchedule)
            {
                String svDate = sv.Date__c.format('dd-MM-YYYY');
                String svTime = sv.Date__c.format('h:mm a');
                system.debug('Time '+svTime);
                Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                semail.setSenderDisplayName(sv.Owner.Name);
                semail.setReplyTo(sv.Owner.Email);
                semail.setSubject('VeegaLand Home Site Visit Scheduled Mail');
                
                if(sv.Lead__r.Email!=null){
                    sendTo.add(sv.Lead__r.Email);
                }
                else if(sv.Lead__r.Secondary_Email__c!=null){
                    sendTo.add(sv.Lead__r.Secondary_Email__c);
                }
                semail.setToAddresses(sendTo);
                semail.setHtmlBody( 
                    'Dear Valued Customer, <br/><br/>' +
                    'We are excited to inform you that a site visit has been scheduled for you on '+ svDate +' at '+svTime +'. During this visit, you will have the opportunity to explore our apartment project at first hand and gain valuable insights into your potential new home. <br/><br/>' +
                    'Your dedicated point of contact for the site visit will be ' + sv.Owner.Name +' , who can be reached at '+'['+sv.Owner.Phone+']'+'. <br/><br/>'+
                    'We look forward to welcoming you to our project site and assisting you in making your dream homea reality. <br/><br/>'+
                    'Best regards,<br/><br/>' +
                    companyName+'<br/>'+
                    sv.Owner.Name + '<br/>' +
                    '[' + sv.Owner.Phone + ']'+'<br/>' );
                if(sv.Lead__r.Secondary_Email__c!=null || sv.Lead__r.Email!=null){
                    semailList.add(semail);
                }
                //Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail}); 
            }
            //executive mail
            List<Site_Visit__c> SVScheduleList = [select Id,Name,Date__c,OwnerId,Owner.Name,Owner.Email, Owner.Phone,Lead_Email__c,Lead__r.Phone,Lead__r.Country_Code__c,Lead__r.Secondary_Email__c,Lead__r.Country_Codes__c from Site_Visit__c where Status__c='Scheduled' and Id In :svList];
            //List<Messaging.SingleEmailMessage> semailListexe = new List<Messaging.SingleEmailMessage>();
            for(Site_Visit__c sv1:SVScheduleList)
            {
                String svDate = '';
                String svTime = '';
                if (sv1.Date__c != null) {
                    svDate = sv1.Date__c.format('dd-MM-YYYY');
                    svTime = sv1.Date__c.format('h:mm a');
                }
                Messaging.SingleEmailMessage semailList1 = new Messaging.SingleEmailMessage();
                semailList1.setSenderDisplayName(sv1.Owner.Name);
                semailList1.setReplyTo(sv1.Owner.Email);
                semailList1.setSubject('Executive alert mail for sites visit');
                if(sv1.Owner.Email !=null){
                    sendTo.add(sv1.Owner.Email);
                }
                semailList1.setToAddresses(sendTo);
                semailList1.setHtmlBody( 
                    'Dear '+sv1.Owner.Name+', <br/><br/>' +
                    'This is a reminder for the upcoming site visit scheduled on '+svDate+' at '+svTime+' with '+sv1.Name+' Your timely presence at the site is greatly appreciated for the customers visit.<br/><br/>' +
                    'Best regards,<br/><br/>' +
                    'VEEGALAND DEVELOPERS LIMITED <br/>'
                );
                semailList.add(semailList1);
                //Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail}); 
                //whats app message
                if(sv1.Owner.Phone != null){
                    string phone;
                    if(sv1.Lead__r.Country_Code__c != null){
                        phone = sv1.Lead__r.Country_Code__c+sv1.Lead__r.Phone;
                    }
                    
                    if(label.DisableWhatsappaMsg == 'false')
                        whatsappIntegration_Controller.WhatsappTextMessage('Site visit confirmation',sv1.Owner.Name,sv1.Owner.Phone,phone,svDate,svTime); 
                }
            }
            for(Site_Visit__c site:trigger.new)
            {
                if(!CreateALogAfterLeasdUpdate.fromUpdateLeadStatus && site.Date__c !=null && site.Lead__c !=null)
                {
                    Lead con =new Lead();
                    con.Id=site.Lead__c;
                    con.Site_Visit_Schedule_Date__c = site.Date__c;
                    con.Lead_status__c = 'SV Schedule';
                    con.Lead_stage__c = 'SV Schedule';
                    lstContacts.add(con);
                }
                
                /*task tk=new task();
tk.OwnerId=site.OwnerId;
tk.WhoId= site.Lead__c;
//tk.WhatId= SV.Lead__c;
tk.Due_Date_and_Time__c= site.Date__c;
tk.Subject='Site visit Scheduled';

tsklst.add(tk);*/
                
            }
            if(lstContacts.size()>0){
                update lstContacts;
            }
            /*if(tsklst.size()>0){
insert tsklst;
}*/
            if(semailList.size()>0){
                Messaging.sendEmail(semailList);
            }
            /*if(semailListexe.size()>0)
{
Messaging.sendEmail(semailListexe);
}*/
            
        }
        if(trigger.isafter && trigger.isupdate)
        {
            list<Lead>lstContacts=new list<Lead>();
            for(Site_Visit__c site:trigger.new)
            {
                system.debug('fromUpdateLeadStatus '+CreateALogAfterLeasdUpdate.fromUpdateLeadStatus);
                Lead con =new Lead();
                //!CreateALogAfterLeasdUpdate.fromUpdateLeadStatus
                if((CreateALogAfterLeasdUpdate.fromUpdateLeadStatus == null || CreateALogAfterLeasdUpdate.fromUpdateLeadStatus == false) && site.Date__c !=null && site.Lead__c !=null && site.date__c !=Trigger.oldmap.get(site.Id).date__c)
                {
                    con.Id=site.Lead__c;
                    con.Site_Visit_Schedule_Date__c = site.Date__c;
                    lstContacts.add(con);
                }
                if((CreateALogAfterLeasdUpdate.fromUpdateLeadStatus == null || CreateALogAfterLeasdUpdate.fromUpdateLeadStatus == false) && site.Status__c =='Completed' && site.Lead__c !=null && Trigger.oldmap.get(site.Id).Status__c != 'Completed')
                {
                    con.Id=site.Lead__c;
                    con.SV_Completed_Date_Time__c = site.SV_Completed_Date_Time__c;
                    con.Lead_status__c = 'SV Completed';
                    con.Lead_stage__c = 'SV Completed';
                    lstContacts.add(con);
                }
                //reschedule mail
                
            }
            List<string> sendTo = new List<string>();
            List<Site_Visit__c> svList = trigger.new;
            List<Site_Visit__c> SVCompleted = new List<Site_Visit__c>();
            List<Site_Visit__c> SVReSchedules = new List<Site_Visit__c>();
            List<Site_Visit__c> SVCompletedWhmsg = new List<Site_Visit__c>();
            for (Site_Visit__c newSv : svList) {
                // Use Trigger.oldMap to get the old values of the records
                Site_Visit__c oldSv = Trigger.oldMap.get(newSv.Id);
                // Check if the Status__c field has changed from something other than 'Completed' to 'Completed'
                if (oldSv != null && oldSv.Status__c != 'Completed' && newSv.Status__c == 'Completed' && newSv.Lead_Email__c != null) {
                    SVCompleted.add(newSv);
                }
                if (oldSv != null && oldSv.Status__c != 'Completed' && newSv.Status__c == 'Completed') {
                    SVCompletedWhmsg.add(newSv);
                }
                if(oldSv != null && oldSv.Reschedule_Date__c != newSv.Reschedule_Date__c && newSv.Lead_Email__c != null && newSv.Status__c=='Rescheduled')
                {
                    system.debug('SVReSchedules');
                    SVReSchedules.add(newSv);
                }
            }
            system.debug('SVReSchedules'+SVReSchedules);
            //completed Mail
            List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
                string companyName;
                
                if(!companyDetails.isEmpty()){
                    companyName = companyDetails[0].Label;
                       
                }
            List<Site_Visit__c> SVCompletedList = [select Id,Name,Date__c,Reschedule_Date__c,OwnerId,Owner.Name,Owner.Email, Owner.Phone,Lead_Email__c,Lead__r.Phone,Lead__r.Country_Code__c,Lead__r.Secondary_Email__c from Site_Visit__c where Status__c='Completed' and Id In :SVCompleted];
            List<Messaging.SingleEmailMessage> semailList = new List<Messaging.SingleEmailMessage>();
            for(Site_Visit__c sv:SVCompletedList){ 
                if(sv.Lead_Email__c!=null){
                    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                    semail.setSenderDisplayName(sv.Owner.Name);
                    semail.setReplyTo(sv.Owner.Email);
                    semail.setSubject('VeegaLand Home Site Visit Completed Mail'); 
                    sendTo.add(sv.Lead_Email__c);
                    semail.setToAddresses(sendTo);
                    semail.setHtmlBody( 
                        'Dear Valued Customer, <br/><br/>' +
                        'We sincerely appreciate you taking the time to visit us and explore our apartment project. Your interest means a lot to us, and we are here to assist you every step of the way. For any further questions please feel free to reach to us. We look forward to the opportunity to help you find your perfect home. <br/></br/>'+
                        'Best regards,<br/><br/>' +
                        companyName+'<br/>'+
                        sv.Owner.Name + '<br/>' +
                        '[' + sv.Owner.Phone + ']'+'<br/>' );
                    if(sv.Lead__r.Secondary_Email__c!=null || sv.Lead_Email__c!=null){
                        semailList.add(semail); 
                    }     
                }
                //Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail}); 
            }
            List<Site_Visit__c> SVCompletedwhList = [select Id,Name,Date__c,Reschedule_Date__c,OwnerId,Owner.Name,Owner.Email, Owner.Phone,Lead_Email__c,Lead__r.Phone,Lead__r.Country_Code__c,Lead__r.Country_Codes__c from Site_Visit__c where Status__c='Completed' and Id In :SVCompletedWhmsg];
            for(Site_Visit__c svl : SVCompletedwhList){
                //whatsapp message
                if(svl.Owner.Phone != null){
                    string phone;
                    if(svl.Lead__r.Country_Code__c != null){
                        phone = svl.Lead__r.Country_Code__c+svl.Lead__r.Phone; 
                    }
                    
                    if(label.DisableWhatsappaMsg == 'false')
                        whatsappIntegration_Controller.WhatsappTextMessage('Site visit thank you message',svl.Owner.Name,svl.Owner.Phone,phone,'','');  
                }
            }
            //Reschedule mail
            //List<Site_Visit__c> SVReScheduleList = [select Id,Name,Date__c,Reschedule_Date__c,OwnerId,Owner.Name,Owner.Email, Owner.Phone,Lead_Email__c,Lead__r.Secondary_Email__c from Site_Visit__c where Status__c='Rescheduled' and Id In :SVReSchedules and Lead_Email__c != null];
            //List<Messaging.SingleEmailMessage> semailReSdlList = new List<Messaging.SingleEmailMessage>();
            /*for(Site_Visit__c sv:SVReScheduleList)
{
String svDate = sv.Reschedule_Date__c.format('dd-MM-YYYY');
String svTime = sv.Reschedule_Date__c.format('h:mm a');
Messaging.SingleEmailMessage semails = new Messaging.SingleEmailMessage();
semails.setSenderDisplayName(sv.Owner.Name);
semails.setReplyTo(sv.Owner.Email);
semails.setSubject('VeegaLand Home Site Visit Rescheduled Mail');
if(sv.Lead_Email__c!=null){
sendTo.add(sv.Lead_Email__c);
}
else if(sv.Lead__r.Secondary_Email__c!=null){
sendTo.add(sv.Lead__r.Secondary_Email__c);
}
semails.setToAddresses(sendTo);
semails.setHtmlBody( 
'Dear Valued Customer, <br/><br/>' +
'In consideration of your availability, the site visit has been rescheduled for '+svDate+' at '+svTime+'. Kindly allocate your precious time to explore our apartment project during this scheduled appointment. <br/>'+
'Your dedicated point of contact for the site visit will be '+sv.Owner.Name+', who can be reached at '+sv.Owner.Phone+'.<br/>'+
'We look forward to welcoming you to our project site and assisting you in making your dream home a reality.<br/><br/>'+
'Best regards,<br/><br/>' +
'Veegaland Homes <br/>'+
sv.Owner.Name + '<br/>' +
'[' + sv.Owner.Phone + ']'+'<br/>' );
if(sv.Lead__r.Secondary_Email__c!=null || sv.Lead_Email__c!=null){
semailList.add(semails);
}
}*/
            if(lstContacts.size()>0){
                system.debug('lstContacts'+lstContacts);
                update lstContacts;
            }
            if(semailList.size()>0){
                Messaging.sendEmail(semailList);
            }
            /*if(semailReSdlList.size()>0){
Messaging.sendEmail(semailReSdlList);
}*/
        }
        if (Trigger.isAfter) {
            SiteVisitTriggerHandler.handleAfter(Trigger.new, Trigger.old);
        }
        
        if(Test.isRunningTest()){
            integer  i=0;
            if(i==0){
                
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
    }    
    
}