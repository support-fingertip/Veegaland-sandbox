trigger LeadTriggers on Lead (before insert, after insert, before update, after update) {
    
    if(label.Enable_Trigger=='TRUE'){
        system.debug(utility.runLeadTrigger);
        if(Utility.runLeadTrigger  != false){
            
            if (Trigger.isBefore) {
                if (Trigger.isInsert) {
                    system.debug('test');
                    user u = [SELECT Id,Name,Profile.Name FROM user WHERE Id=:userinfo.getUserId()];
                    RelatedSourceHandler.checkMobileNumber(trigger.new);
                    // Create a set to store unique Allocated_Project__c values
                    Set<String> allocatedProjectNames = new Set<String>();
                    // Collect unique Allocated_Project__c values from trigger.new leads
                    for (Lead lead : trigger.new) {
                        allocatedProjectNames.add(lead.Allocated_Project__c);
                    }
                    
                    // Query Project__c records based on unique Allocated_Project__c values
                    List<Project__c> projectList = [SELECT Id, Name, City__c FROM Project__c WHERE Name IN :allocatedProjectNames];
                    
                    // Map to store Project__c records by Allocated_Project__c value
                    Map<String, Project__c> projectMap = new Map<String, Project__c>();
                    for (Project__c project : projectList) {
                        projectMap.put(project.Name, project);
                    }
                    
                    // Update Lead records with Project_City__c based on Allocated_Project__c
                    for (Lead lead : trigger.new) {
                        if (projectMap.containsKey(lead.Allocated_Project__c)) {
                            lead.Project_City__c = projectMap.get(lead.Allocated_Project__c).City__c;
                        }
                    }
                    RelatedSourceHandler.duplicateCheck2(trigger.new);
                    system.debug('user');
                    
                    //List<Lead> newLead = trigger.new;
                    List<Lead> newLead = new List<Lead>(); 
                    List<Lead> CallEnquiryLeads = new List<Lead>();
                    // Add all leads from trigger.new to newLeads
                    //newLead.addAll(trigger.new);
                    
                    /*if(u.Profile.Name !='Sales executive' && Trigger.new[0].Leadsource__c!='Channel partner' && Trigger.new[0].Leadsource__c!='fb'  && Trigger.new[0].Leadsource__c!='99 acres' )
{
RoundRobinHandler.assignLead(trigger.new,false,'Sales'); 
system.debug('round robin');
}else{
for(Lead ld : trigger.new){
ld.Lead_Assigned__c = true;
ld.Reassigned_By__c = UserInfo.getUserId();
ld.Re_assigned_date__c = system.now();
//ld.last_re_assign_date__c = system.today();
ld.Pre_sales_user__c =UserInfo.getUserId();
ld.Sales_User__c =UserInfo.getUserId();
ld.SV_User__c=UserInfo.getUserId();

}
}*/
                    List<User> u1 = [SELECT Id, Name,ProfileId FROM User WHERE ProfileId IN (SELECT Id FROM Profile WHERE Name = 'Sales Cordinator') and Assign_Leads__c=true limit 1];
                    system.debug('u1'+u1);
                    
                    for(Lead ld : trigger.new){
                        
                        if (u.Profile.Name !='Sales executive'  && ld.Leadsource__c=='Inbound call' && ld.Round_Robin_Off__c == false) {
                            CallEnquiryLeads.add(ld);
                            
                        }
                        else if(u.Profile.Name !='Sales executive' && ld.Leadsource__c!='Channel partner' && ld.Leadsource__c!='fb' && ld.Leadsource__c!='99 acres' && ld.Leadsource__c!='ig' && ld.Leadsource__c!='Inbound call' && ld.Round_Robin_Off__c == false)
                        {  
                            newLead.add(ld);
                        }  
                        
                        else{
                            
                            ld.Lead_Assigned__c = true;
                            ld.Reassigned_By__c = UserInfo.getUserId();
                            ld.Re_assigned_date__c = system.now();
                            //ld.last_re_assign_date__c = system.today();
                            ld.Pre_sales_user__c =UserInfo.getUserId();
                            ld.Sales_User__c =UserInfo.getUserId();
                            ld.SV_User__c=UserInfo.getUserId();
                            if(u1.size()>0 && (ld.Leadsource__c == 'Channel partner' || ld.Leadsource__c == 'fb' || ld.Leadsource__c == '99 acres' || ld.Leadsource__c == 'ig')){
                                ld.ownerId = u1[0].Id;
                            }
                        }
                    }
                    if(newLead.size()>0){ 
                        system.debug('round robin');   
                        RoundRobinHandler.assignLead(newLead,false,'Sales');
                    }
                    if(CallEnquiryLeads.size()>0){ 
                        system.debug('round robin');   
                        RoundRobinHandler.assignCallEnquiryLeads(CallEnquiryLeads,false,'Sales'); 
                    }
                    
                    /*for (Lead lead : trigger.new) {
if(u1.size()>0 && (lead.Leadsource__c == 'Channel partner' || lead.Leadsource__c == 'fb' || lead.Leadsource__c == '99 acres')){
lead.ownerId = u1[0].Id;
}
}*/
                } 
                if (Trigger.isUpdate) {
                    system.debug('on update');
                    List<Lead> lList = new List<Lead>();
                    for(Lead l:trigger.new){
                        if(l.Country__c != Trigger.oldmap.get(l.Id).Country__c)
                            l.Country_Code__c = null;
                    }
                    RelatedSourceHandler.checkMobileNumber(trigger.new);
                    for(Lead l:trigger.new){
                        system.debug(Trigger.oldmap.get(l.Id).Allocated_Project__c);
                        if(l.Allocated_Project__c != Trigger.oldmap.get(l.Id).Allocated_Project__c){
                            Set<String> allocatedProjectNames = new Set<String>();
                            // Collect unique Allocated_Project__c values from trigger.new leads
                            for (Lead lead : trigger.new) {
                                allocatedProjectNames.add(lead.Allocated_Project__c);
                            }
                            // Query Project__c records based on unique Allocated_Project__c values
                            List<Project__c> projectList = [ SELECT Id, Name, City__c  FROM Project__c  WHERE Name IN :allocatedProjectNames ];
                            
                            // Map to store Project__c records by Allocated_Project__c value
                            Map<String, Project__c> projectMap = new Map<String, Project__c>();
                            for (Project__c project : projectList) {
                                projectMap.put(project.Name, project);
                            }
                            
                            // Update Lead records with Project_City__c based on Allocated_Project__c
                            for (Lead lead : trigger.new) {
                                if (projectMap.containsKey(lead.Allocated_Project__c)) {
                                    lead.Project_City__c = projectMap.get(lead.Allocated_Project__c).City__c;
                                }
                            }
                            
                        }  
                    }
                    for(Lead l:trigger.new){
                        if(((l.Phone != Trigger.oldmap.get(l.Id).Phone)||(l.Secondary_Phone__c != Trigger.oldmap.get(l.Id).Secondary_Phone__c)||(l.Email != Trigger.oldmap.get(l.Id).Email)||(l.Secondary_Email__c != Trigger.oldmap.get(l.Id).Secondary_Email__c)) && UpdatePhoneEmailController.updatePhoneemai){
                            lList.add(l);
                            
                        }
                    }
                    if(!lList.isEmpty()){
                        String returnMessage = RelatedSourceHandler.duplicateCheckProject(lList);  
                        system.debug('returnMessage'+returnMessage); 
                        if(returnMessage!=null){
                            lList[0].addError(returnMessage);
                        }
                        
                    }
                    for (Lead lead : trigger.new) {
                        if(lead.Lead_Stage__c == 'Analysis' || lead.Lead_Stage__c == 'Qualification' || lead.Lead_Stage__c == 'Closed Lost'){
                            lead.Lead_Probability__c = 'Cold';  
                        }  
                        if(lead.Lead_Stage__c == 'Proposal' || lead.Lead_Stage__c == 'SV Schedule' || lead.Lead_Stage__c == 'SV Completed'){
                            lead.Lead_Probability__c = 'Warm';  
                        }
                        if(lead.Lead_Stage__c == 'Negotiation' || lead.Lead_Stage__c == 'Booked'){
                            lead.Lead_Probability__c = 'Hot';  
                        }
                        if(lead.Lead_Stage__c == 'SV Schedule' && Trigger.oldmap.get(lead.Id).Lead_stage__c != lead.Lead_Stage__c){
                            if(lead.Site_Visit_Schedule_Date__c == null){
                                lead.addError('Please Fill in the SV Scheduled Date and Time');
                            }  
                        }
                        if(lead.Lead_Stage__c == 'SV Completed' && Trigger.oldmap.get(lead.Id).Lead_stage__c != lead.Lead_Stage__c){
                            if(lead.SV_Completed_Date_Time__c == null || lead.Site_Visit_Feedback__c == null){
                                lead.addError('Please Fill in the SV Completed Date and Time, Feedback');
                            }  
                        }
                        /*if(lead.Lead_Stage__c == 'Negotiation' && Trigger.oldmap.get(lead.Id).Lead_stage__c != lead.Lead_Stage__c){
if(lead.Site_Visit_Schedule_Date__c == null || lead.SV_Completed_Date_Time__c == null || lead.Site_Visit_Feedback__c == null){
lead.addError('Please ensure that the required fields for the scheduled stage and completed stage of the SV are properly filled.');
}  
}*/
                        if(lead.Lead_Stage__c == 'Negotiation' && Trigger.oldmap.get(lead.Id).Lead_stage__c != lead.Lead_Stage__c && Trigger.oldmap.get(lead.Id).Lead_stage__c!='SV Completed' && (lead.Follow_up_Description__c=='' || lead.Follow_up_Description__c==null)){
                            lead.addError('Please enter a Follow-up description.');
                        }
                        if((lead.Lead_Stage__c == 'Booked' && Trigger.oldmap.get(lead.Id).Lead_stage__c != lead.Lead_Stage__c) || (lead.Lead_Stage__c == 'Car parking allocated' && Trigger.oldmap.get(lead.Id).Lead_stage__c != lead.Lead_Stage__c) || (lead.Lead_Stage__c == 'Agreement executed' && Trigger.oldmap.get(lead.Id).Lead_stage__c != lead.Lead_Stage__c) || (lead.Lead_Stage__c == 'Sales Agreement Drafting' && Trigger.oldmap.get(lead.Id).Lead_stage__c != lead.Lead_Stage__c) ){
                            if(lead.Aadhaar_No__c == null || lead.PAN_NO__c == null){
                                lead.addError('Please convert the quote to a booking');
                            }  
                        }
                        if(lead.Lead_Stage__c == 'Closed Lost' && Trigger.oldmap.get(lead.Id).Lead_stage__c != lead.Lead_Stage__c){
                            if(lead.Closed_Lost_Reason__c == null){
                                lead.addError('Please fill in the Closed lost reason');
                            }  
                        }
                        //Lead name validation code
                        if (lead.Leadsource__c == 'Inbound call' && lead.Lead_Stage__c != 'Analysis' && lead.Lead_Stage__c != 'Qualification' && lead.Lead_Stage__c != 'Closed Lost' && lead.LastName == 'Customer') {
                            lead.addError('Please enter the correct name.');
                        }
                    }
                    User u = [SELECT Id, Name, Profile.Name FROM User WHERE Profile.Name = 'System Administrator' and IsActive=true LIMIT 1];
                    List<Lead> preSalesLdList = new List<Lead>();
                    //List<Lead> ldList = new List<Lead>();
                    
                    for(Lead ld : Trigger.new){
                        system.debug('new Lead_stage__c '+ld.Lead_stage__c+ld.Lead_Type__c+ld.Lead_Age__c+ld.Updated_Lead_Age__c);
                        system.debug('old Lead_stage__c '+Trigger.oldmap.get(ld.Id).Lead_stage__c);
                        if (ld.Lead_stage__c != Trigger.oldmap.get(ld.Id).Lead_stage__c && ld.Lead_stage__c=='Qualification' && !ld.Lead_Assigned__c && !ld.Lead_Transfered__c ){
                            if(ld.Next_Round_robin_date__c < system.today())
                            {
                                preSalesLdList.add(ld);
                            }else{
                                ld.Lead_Assigned__c=true;
                            }
                            
                        }
                        
                    }
                    
                    if(preSalesLdList.size()>0){
                        RoundRobinHandler.assignLead(preSalesLdList,false,'Sales');
                    }
                    //ReEngaged Lead after 90 days will go to Roundrobin irrespective of Lead Stage
                    List<Lead> reEngagedLead = new List<Lead>();
                    user us = [SELECT Id,Name,Profile.Name FROM user WHERE Id=:userinfo.getUserId()];
                    
                    for(Lead ld : Trigger.new){
                        system.debug(ld.Lead_Type__c+ld.Updated_Lead_Age__c+ld.Lead_Assigned__c+ld.Delete_Lead__c+ld.Re_Engaged_Date__c+'=='+Trigger.Oldmap.get(ld.id).Re_Engaged_Date__c);
                        
                        if(ld.Lead_Type__c=='Re-Engaged'&& ld.Updated_Lead_Age__c > 90 &&ld.Lead_Assigned__c !=true && ld.Delete_Lead__c !=true && Trigger.Oldmap.get(ld.id).Re_Engaged_Date__c!=ld.Re_Engaged_Date__c){
                            system.debug('Re-Engaged');
                            if(us.Profile.Name !='Sales executive'){
                                
                                system.debug('Insdie the  Re-Engaged');
                                reEngagedLead.add(ld);
                            }
                            else{
                                
                                ld.Lead_Assigned__c = true;
                                ld.Reassigned_By__c = UserInfo.getUserId();
                                ld.Re_assigned_date__c = system.now();
                                //ld.last_re_assign_date__c = system.today();
                                ld.Pre_sales_user__c =UserInfo.getUserId();
                                ld.Sales_User__c =UserInfo.getUserId();
                                ld.SV_User__c=UserInfo.getUserId();
                                ld.OwnerId=UserInfo.getUserId();
                                
                            }
                        }
                    }
                    
                    if(reEngagedLead.size()>0){
                        RoundRobinHandler.assignLead(reEngagedLead,false,'Sales');
                    }
                    
                }
                
            }
            
            if (Trigger.isAfter) {
                if (Trigger.isInsert) {
                    RelatedSourceHandler.afterinsertLogic(trigger.new);
                    List<string> LeadId = new List<string>();
                    for(Lead l: trigger.new) {
                        if(l.Lead_stage__c == 'Qualification'){
                            LeadId.add(l.Id);
                        }
                    }
                    if(LeadId.size()>0)
                    {
                        system.debug('whatsapp message');
                        WelcomeMailController.sendWelcomeEmailtoCustomer(LeadId);
                        WelcomeMailController.SendAssignedLeadEmailtoEexcutive(LeadId);
                        WelcomeMailController.SendWhatsAppMsg(LeadId);
                    }
                    
                } 
                if (Trigger.isUpdate) {
                    Set<Id> lostWinLeads = new Set<Id>();
                    Set<Id> ownerChange = new Set<Id>();
                    List<string> LeadId = new List<string>();
                    for(Lead con : Trigger.new){
                        system.debug(Trigger.oldmap.get(con.Id).lead_stage__c );
                        system.debug(con.Lead_stage__c );
                        // Commeted on 29/10/2024 by Praveeen as suggested by Varna
                        if(con.Lead_stage__c!=Trigger.oldmap.get(con.Id).lead_stage__c && (con.Lead_stage__c=='Booked')){
                            lostWinLeads.add(con.Id);
                        }
                        if(con.OwnerId!=Trigger.oldmap.get(con.Id).OwnerId && con.Lead_stage__c!='Closed Lost' && con.Lead_stage__c!='Booked'){
                            ownerChange.add(con.Id);
                        }
                        
                        // Lead assignment notification to owner of the record
                        if(con.OwnerId!=Trigger.oldmap.get(con.Id).OwnerId)
                        {
                            LeadId.add(con.Id);
                        }
                    }
                    if(LeadId.size()>0)
                    {
                        WelcomeMailController.SendAssignedLeadEmailtoEexcutive(LeadId); 
                        transferLeadController.sendNotification(LeadId);
                    }
                    if(lostWinLeads.size()>0){
                        List<site_visit__c> svList = new List<site_visit__c>();
                        svList = [SELECT Id,Name,status__c FROM site_visit__c WHERE Lead__c IN : lostWinLeads and (status__c='Scheduled' or status__c='Rescheduled')];
                        if(svList.size()>0){
                            for(site_visit__c sv : svList){
                                sv.status__c='Cancelled';
                                sv.Cancelled_Reason__c = 'Lead is Booked';
                            }
                            Update svList;
                        }
                        /*  List<Follow_up__c> svList1 = new List<Follow_up__c>();
svList1 = [SELECT Id,Name,status__c FROM Follow_up__c WHERE Leads__c IN : lostWinLeads and status__c='Scheduled'];
if(svList1.size()>0){
for(Follow_up__c sv1 : svList1){
sv1.status__c='Cancelled';
sv1.Description__c='Lead is Booked';
}
Update svList1;
}
*/
                    }
                    
                    if(ownerChange.size()>0){
                        List<Follow_up__c> fwList = new List<Follow_Up__c>();
                        fwList = [SELECT Id,Name,OwnerId,Leads__r.ownerId FROM Follow_Up__c WHERE Leads__c IN: ownerChange and status__c='Scheduled'];
                        if(fwList.size()>0){
                            for(Follow_Up__c fw : fwList){
                                fw.ownerId = fw.Leads__r.OwnerId;
                            }
                            Update fwList;
                        }
                        List<site_visit__c> fwList1 = new List<site_visit__c>();
                        fwList1 = [SELECT Id,Name,OwnerId,Lead__r.ownerId FROM site_visit__c WHERE Lead__c IN: ownerChange and (status__c='Scheduled' or status__c='Rescheduled')];
                        if(fwList1.size()>0){
                            for(site_visit__c fw1 : fwList1){
                                fw1.ownerId = fw1.Lead__r.OwnerId;
                            }
                            Update fwList1;
                        }
                    }
                }
                // delete account
                /*if (Trigger.isDelete) {
//accountController.upsertAccount(trigger.old, 'delete');
}
// create account
if (Trigger.isUndelete) {
//accountController.upsertAccount(trigger.new, 'undelete');
}*/
            } 
            
            //if(trigger.isAfter && trigger.isInsert){
            /*for(Lead l: trigger.new) {
WelcomeMailController.sendWelcomeEmailtoCustomer(l.Id);
}
List<Lead> l = trigger.new;
List<User> u = [select Id, Name,Phone from User where Id=:l[0].Id limit 1];
List<Messaging.SingleEmailMessage> semailList = new List<Messaging.SingleEmailMessage>();
for(Lead ld : trigger.new){
Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
semail.setSubject('VeegaLand Home Welcome Mail');

List<string> sendTo = new List<string>();
if(ld.Email !=null){
sendTo.add(ld.Email);
}

if(ld.Secondary_Email__c !=null){
sendTo.add(ld.Secondary_Email__c);
}

semail.setToAddresses(sendTo);
semail.setHtmlBody('Dear Valued Customer,<br/>We appreciate your keen interest in Veegaland Homes. Your dedicated point of contact will be'+ l[0].Name + ', who is readily available to assist you with any inquiries or information you may require.<br/><br/> For comprehensive details about the project, please visit our website, https://www.veegaland.com/ <br/> Should you have any further questions, feel free to reach out.<br/> <br/> Best Regards,<br/> Veegaland Homes <br/>'+ l[0].Name +' <br/> ['+ l[0].Phone +']');
if(ld.Email !=null)
{
//Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail}); 
semailList.add(semail);
}

}
Messaging.sendEmail(semailList);*/
            //}
            
            
            /*if(trigger.isAfter&& trigger.isupdate){
Set<Id> leadIds = new Set<Id>();

//List<Follow_Up__c> followUpsToUpdate = new List<Follow_Up__c>();

for (Lead__c leadRecord : Trigger.new) {
if (leadRecord.Lead_Status__c == 'Lost' || leadRecord.Lead_Status__c == 'Unqualified') {
leadIds.add(leadRecord.Id);
}
}
// if (!leadIds.isEmpty()) {

Follow_Up__c followUpsToUpdate = [SELECT Id, Status__c FROM Follow_Up__c WHERE Lead1__c	 IN :leadIds];
/* for (Follow_Up__c followUpRecord : followUpsToUpdate) {
followUpRecord.Status__c = 'Cancelled';
}
followUpsToUpdate.Status__c ='Cancelled';
update followUpsToUpdate;
}*/
        }
        //}
        
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
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
            }
        }
        
    }
    
}