public without sharing class transferLeadController {
    public static Boolean pushToSales = true;
    public static Boolean transferLead = false;
    /*@auraEnabled
public static Boolean getRecordAccess(String recId){
UserRecordAccess ura = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :recId];
return ura.HasEditAccess;
}*/
    /*@auraEnabled
public static List<String> getProjectNames(string recId){
system.debug(recId);
Lead con = [SELECT Id,Allocated_project__c FROM Lead WHERE Id=:recId];
Schema.DescribeFieldResult fieldResult = contact.Allocated_Project__c.getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
List<String> selectOpt = new List<String>();

for( Schema.PicklistEntry f : ple)
{
if(con.Allocated_Project__c !=f.getValue()){
selectOpt.add(f.getValue());
}

}     
return selectOpt;
}*/
    @auraEnabled
    public static List<String> getPickListValues(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Lead.Allocated_Project__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }
        return pickListValuesList;
    }
    /*@AuraEnabled
public static List<User> getAllUsers(string leadId){
Lead ld = [SELECT Id,ownerId FROM Lead WHERE Id=:leadId ];
string str= [select id,name from profile where id=:userinfo.getProfileId()].Name;

return [SELECT Id,Name FROM user where isActive=TRUE AND Id!=:ld.OwnerId ];


}
@auraEnabled
public static string moveToSales(string LeadId, string allocatedProject, string tReason, Boolean checkbox, string owner){
transferLead = true;
Lead c = [SELECT LastName,Phone,Email,Country__c,Leadsource__c,sub_source__c,Country_code__c,Secondary_phone__c,Secondary_email__c,Secondary_country__c,Secondary_Country_code__c,Company FROM Lead WHERE Id=:LeadId];
Lead con = new Lead();
con.Main_Lead__c = LeadId;
con.Allocated_Project__c = allocatedProject;
//con.FirstName = c.Name;
con.LastName = c.LastName;
con.Phone = c.Phone;
con.Email = c.Email;
con.Country__c = c.Country__c;
con.Country_Code__c = c.Country_Code__c;
con.Secondary_Email__c = c.Secondary_Email__c;
con.Secondary_Phone__c = c.Secondary_Phone__c;
con.Secondary_Country_Code__c = c.Secondary_Country_Code__c;
con.Secondary_Country__c = c.Secondary_Country__c;
con.Leadsource__c = 'Transferred lead';
con.Sub_Source__c = userinfo.getUserName();
con.Description__c = tReason;
con.Type_of_lead__c ='Transfer Lead';
con.Company = c.Company;
if(checkbox){
con.Lead_Assigned__c = true;
con.OwnerId = owner;
}
insert con;
Lead cn = new Lead();
cn.Id = LeadId;
cn.Lead_status__c = 'Closed Lost';
cn.Drop_Off_Reason__c = tReason;
cn.Lost_Reason__c='Project Unfit';
cn.Lead_Transfered__c = true;
update cn;

ListView lw= [SELECT Id, Name, DeveloperName, SobjectType FROM ListView WHERE SobjectType='Lead' AND DeveloperName='TodaysLeads'];
return lw.Id;
}
@auraEnabled
public static void LeadAssigned_Emailto_PreSalesUser(string recId){
Lead ld = [SELECT Id,Name, Pre_sales_user__r.name,Sales_User__r.name,Pre_sales_user__r.Email, Sales_User__r.Email, Assign_To__c, Allocated_Project__c, Allocated_Unit__r.name, Secondary_Email__c, Reassigned_Hr__c, Email  FROM Lead WHERE Id=:recId];

Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();

semail.setSubject('Lead has been Assigned');

List<string> sendTo = new List<string>();

if(ld.Pre_sales_user__r.Email !=null){
sendTo.add(ld.Pre_sales_user__r.Email);
}
System.debug('===='+sendTo);
semail.setToAddresses(sendTo);

semail.setHtmlBody('Hello '+ld.Pre_sales_user__r.name+',<br/> <br/> A Lead named '+ld.name+' has been assigned to You, Who is very much interest in buying a Unit in '+ld.Allocated_Project__c +' Project.<br/> Note: This is a sample Email, sent to PreSales User upon Creating a Lead.<br/>Please feel free to talk With us for clarification if any.,<br/>');

if(sendTo.size()>0){
Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
system.debug(semail);
}

}
@auraEnabled
public static string LeadAssigned_Emailto_Customer(string recId){
Lead ld = [SELECT Id,Name, Pre_sales_user__r.name,Sales_User__r.name,Pre_sales_user__r.Email, Sales_User__r.Email, Assign_To__c, Allocated_Project__c, Allocated_Unit__r.name, Secondary_Email__c, Reassigned_Hr__c, Email  FROM Lead WHERE Id=:recId];

Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();

semail.setSubject('Customer Id Created');

List<string> sendTo = new List<string>();

if(ld.Email !=null){
sendTo.add(ld.Email);
}
if(ld.Secondary_Email__c !=null){
sendTo.add(ld.Secondary_Email__c);
}

System.debug('===='+sendTo);
semail.setToAddresses(sendTo);

semail.setHtmlBody('Congratulations '+ld.name+',<br/> <br/> Your Details has been Registered With Us for the Enquiry of '+ld.Allocated_Project__c+' project.<br/> Thank you very much for Choosing Us.<br/> Note: This is a sample Email, sent to Customer upon Creating a Lead.<br/>Please feel free to talk With us for clarification if any.,<br/>');

if(sendTo.size()>0){
Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
system.debug(semail);
return 'Mail sent to customer';
}
else{
return 'Mail not sent to customer';
}

}*/
    @auraEnabled
    public static void sendNotification(List<string> recId ){
        if(recId.size()>0){
            List<Lead> ld = [SELECT Id,Name, OwnerId,Pre_sales_user__r.name,Sales_User__r.name, Assign_To__c, Allocated_Project__c, Allocated_Unit__r.name, Secondary_Email__c, Reassigned_Hr__c, Email  FROM Lead WHERE Id IN :recId];
            CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName ='Lead_Assignment_Notify'];
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            for(Lead l: ld){
                notification.setBody(l.Name);
                notification.setTitle('Lead Assigned');
                //notification.setSenderId(senderId);
                notification.setNotificationTypeId(type.id);
                notification.setTargetId(l.Id); // target object id
                notification.send(new Set<String> {l.OwnerId}); 
        }
        } 
    }
    @auraEnabled
    public static string getExisitingLead(Lead lead){
        list<string> mobList =new list<string>();
        list<string> emailList = new list<string>();
        if(lead != null){
            if((lead.Email !=null && lead.Email !='' ) || ((lead.Phone !=null && lead.Phone !='' ) || (lead.Secondary_Phone__c !=null && lead.Secondary_Phone__c !='' ) || (lead.Secondary_Email__c !=null && lead.Secondary_Email__c !='' ) || (lead.Allocated_Project__c !=null && lead.Allocated_Project__c !='' ))){
                
                if(lead.Phone !=null && lead.Phone !='' ){
                    string con = String.valueOf(lead.Phone);
                    con =con.replaceAll('[^\\+|\\d]','');
                    string phn ='%'+con.right(10);
                    mobList.add(phn);
                }
                if(lead.Secondary_Phone__c !=null && lead.Secondary_Phone__c !='' ){
                    string con = String.valueOf(lead.Secondary_Phone__c);
                    con =con.replaceAll('[^\\+|\\d]','');
                    string phn ='%'+con.right(10);
                    mobList.add(phn);
                }
                if(lead.Email != null && lead.Email != ''){
                    emailList.add(lead.Email);
                }
                if(lead.Secondary_Email__c != null && lead.Secondary_Email__c != ''){
                    emailList.add(lead.Secondary_Email__c);
                }
                string city;
                List<Project__c> p = [select Id,name,City__c from Project__c where Name=:lead.Allocated_Project__c];
                if(p.size()>0){
                    city = p[0].City__c; 
                }
                string leadvalue = 'Closed Lost';
               // string  query = 'select Id,Name,OwnerId,Owner.Name,Lead_Stage__c,Updated_Lead_Age__c,Lead_Type__c from Lead where Lead_Stage__c != :leadvalue and Project_City__c =:lead.city and(Phone like :mobList OR Secondary_Phone__c like :mobList or Email like :emailList or Secondary_Email__c like :emailList )  limit 1';
                string  query = 'select Id,Name,OwnerId,Owner.Name,Lead_Stage__c,Updated_Lead_Age__c,Lead_Type__c from Lead where Lead_Stage__c != :leadvalue  and(Phone like :mobList OR Secondary_Phone__c like :mobList or Email like :emailList or Secondary_Email__c like :emailList )  limit 1';
                /*if(emailList.size()>0){
                    query += ' or Email like :emailList or Secondary_Email__c like :emailList';
                }
                if(lead.city !=null && lead.city !='' ){
                    string citys = lead.city ;
                    query += 'or Project_City__c =:citys';
                }
                
                query += ' limit 1';*/
                system.debug(query);
                Lead l=Database.query(query);
                string msg = l.Id+':'+l.Name+':'+l.Owner.Name+':'+l.OwnerId;
                system.debug('message'+msg+' Lead stage'+l.Lead_Stage__c);
                if(l.Lead_Stage__c != 'Closed Lost' ){
                    return msg;
                }
                else{
                    return ':::';
                }
            }else{
                return ':::';  
            }  
        }else{
            return ':::';  
        } 
        
    }
}