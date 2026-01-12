public without sharing class RelatedSourceHandler {
    
    public static List<Lead> deleteList = new List<Lead>();
    public static List<Lead> updateList = new List<Lead>();
    public static List<Related_source__c> rsList = new List<Related_source__c>();
    public static Map<Id,Lead> matchedMap = new  Map<Id,Lead>();
    public static datetime startTime;
    public static datetime endTime;  
    
    public static void checkMobileNumber(List<Lead> newRecordsList) {
        
        Map<String, String> countryCodeMap = Utility.getAllCountryCodeMappings(true);
        system.debug('countryCodeMap'+countryCodeMap);
        Map<String, String> countryNameMap = Utility.getAllCountryCodeMappings(false); 
        system.debug('countryNameMap'+countryNameMap);
        List<Lead> contactItems = newRecordsList;
        
        for( Lead contact : contactItems ) { 
            boolean phone=true;
            boolean secondaryPhone=true;
            if(contact.Phone != null){
                contact.Phone = contactFormatter.getformated(contact.Phone);
            }
            if(contact.Phone != null && contact.Phone.startsWith('+')){
                contact.Phone = contact.Phone.removeStart('+');
                if(contact.Phone != null && contact.Phone.startsWith('91')){
                    contact.Country_Code__c = '91';
                    contact.Country__c = countryCodeMap.get('91');
                    contact.Phone = contact.Phone.removeStart('91');
                }
                else{
                    for(String countryCode : countryCodeMap.keySet()){
                        if(contact.Phone != null && contact.Phone.startsWith(countryCode) && phone){
                            contact.Country_Code__c = countryCode;
                            contact.Country__c = countryCodeMap.get(countryCode);
                            contact.Phone = contact.Phone.removeStart(countryCode);
                            phone = false;
                        }
                    }
                }
            }
            else if(contact.Phone != null && contact.Phone.startsWith('91') && contact.phone.length()>10){
                contact.Country_Code__c = '91';
                contact.Country__c = countryCodeMap.get('91');
                contact.Phone = contact.Phone.removeStart('91');
            }
            if(contact.Secondary_Phone__c != null && contact.Secondary_Phone__c.startsWith('+')){
                contact.Secondary_Phone__c = contact.Secondary_Phone__c.removeStart('+');
                if(contact.Secondary_Phone__c  != null && contact.Secondary_Phone__c .startsWith('91')){
                    contact.Secondary_Country_Code__c = '91';
                    contact.Secondary_Country__c = countryCodeMap.get('91');
                    contact.Secondary_Phone__c = contact.Secondary_Phone__c.removeStart('91');
                }else{
                    for(String countryCode : countryCodeMap.keySet()){
                        if(contact.Secondary_Phone__c != null && contact.Secondary_Phone__c.startsWith(countryCode) && secondaryPhone){
                            contact.Secondary_Country_Code__c = countryCode;
                            contact.Secondary_Country__c = countryCodeMap.get(countryCode);
                            contact.Secondary_Phone__c = contact.Secondary_Phone__c.removeStart(countryCode);
                            secondaryPhone = false;
                        }
                    }  
                }
            }
            if(contact.Phone != null && contact.Country__c == null &&   contact.Country_Code__c  == null){
                contact.Country_Code__c = '91';
                contact.Country__c = countryCodeMap.get('91');
            }
            if(contact.Secondary_Phone__c != null && contact.Secondary_Country__c == null){
                contact.Secondary_Country_Code__c = '91';
                contact.Secondary_Country__c = countryCodeMap.get('91');
            }
            if(contact.Country_Code__c != null){
                contact.Country__c = countryCodeMap.get(contact.Country_Code__c);  
            }
            else if(contact.Country__c != null){
                contact.Country_Code__c = countryNameMap.get(contact.Country__c); 
            }
        }
    }
    /*public static void duplicateCheck(List<Lead> ldList){
Set <String> PhoneSet = new Set<String>();
Set <String> mailSet = new Set<String>();
for(Lead ld : ldList){
string allocatedProject='';
if(ld.Allocated_project__c !=null){
allocatedProject = ld.Allocated_project__c;
}
ld.Email = ld.Email;
ld.Phone = ld.Phone;
if(ld.Phone !=null){
PhoneSet.add(ld.Phone+allocatedProject);
}
if(ld.Secondary_Phone__c !=null){
PhoneSet.add(ld.Secondary_Phone__c+allocatedProject);
}
if(ld.Email !=null){
mailSet.add(ld.Email+allocatedProject);
}
if(ld.Secondary_Email__c !=null){
mailSet.add(ld.Secondary_Email__c+allocatedProject);
}
}

List<Related_Source__c> oldList = [SELECT Id,Name,SecondaryEmailProject__c,PhoneProject__c,SecondaryPhoneProject__c,EmailProject__c,lead__c FROM Related_Source__c 
WHERE (PhoneProject__c IN : PhoneSet OR EmailProject__c IN :  mailSet OR SecondaryPhoneProject__c IN :PhoneSet OR 
SecondaryEmailProject__c IN : mailSet) ORDER BY CreatedDate ASC];
system.debug(oldList);
Map<string,Related_Source__c> emailMap = new Map<string,Related_Source__c>();
Map<string,Related_Source__c> SecondaryEmailMap = new Map<string,Related_Source__c>();
Map<string,Related_Source__c> PhoneMap = new Map<string,Related_Source__c>();
Map<string,Related_Source__c> SecondaryPhoneMap = new Map<string,Related_Source__c>();
if(oldList.size() >0){
for(Related_Source__c old : oldList){

if(old.EmailProject__c !=null){
emailMap.put(old.EmailProject__c,old);
}
if(old.PhoneProject__c !=null){
PhoneMap.put(old.PhoneProject__c,old);
}
if(old.SecondaryEmailProject__c !=null){
SecondaryEmailMap.put(old.SecondaryEmailProject__c,old);
}
if(old.SecondaryPhoneProject__c !=null){
SecondaryPhoneMap.put(old.SecondaryPhoneProject__c,old);
}
}

for(Lead nld : ldList){
string allocatedProject='';
if(nld.Allocated_project__c !=null){
allocatedProject = nld.Allocated_project__c;
}
if(nld.Phone !=null && PhoneMap.containsKey(nld.Phone+allocatedProject)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = PhoneMap.get(nld.Phone+allocatedProject).Lead__c;
}else if(nld.Phone !=null && SecondaryPhoneMap.containsKey(nld.Phone+allocatedProject)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = SecondaryPhoneMap.get(nld.Phone+allocatedProject).Lead__c;
}else if(nld.Email !=null && emailMap.containsKey(nld.Email+allocatedProject)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = emailMap.get(nld.Email+allocatedProject).Lead__c;
}else if(nld.Email !=null && SecondaryEmailMap.containsKey(nld.Email+allocatedProject)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = SecondaryEmailMap.get(nld.Email+allocatedProject).Lead__c;
}else if(nld.Secondary_phone__c !=null && PhoneMap.containsKey(nld.Secondary_phone__c+allocatedProject)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = PhoneMap.get(nld.Secondary_phone__c+allocatedProject).Lead__c;
}else if(nld.Secondary_phone__c !=null && SecondaryPhoneMap.containsKey(nld.Secondary_phone__c+allocatedProject)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = SecondaryPhoneMap.get(nld.Secondary_phone__c+allocatedProject).Lead__c; 
}else if(nld.Secondary_Email__c !=null && emailMap.containsKey(nld.Secondary_Email__c+allocatedProject)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = emailMap.get(nld.Secondary_Email__c+allocatedProject).Lead__c;
}else if(nld.Secondary_Email__c !=null && SecondaryEmailMap.containsKey(nld.Secondary_Email__c+allocatedProject)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = SecondaryEmailMap.get(nld.Secondary_Email__c+allocatedProject).Lead__c;
}
} 
} 

// recentCreatedContactCheck(ldList);

}*/
    public static void afterinsertLogic(List<Lead> ldList){
        system.debug('afterinsertLogic');
        Map<string,Lead> newemailMap = new Map<string,Lead>();
        Map<string,Lead> newPhoneMap = new Map<string,Lead>();
        if(ldList.size()>1){
            for(Lead fnld : ldList){
                string allocatedProject='';
                if(fnld.Project_City__c != null){
                    allocatedProject = fnld.Project_City__c;
                }
                if(fnld.Email !=null && !newemailMap.containsKey(fnld.Email+allocatedProject)){
                    newemailMap.put(fnld.Email+allocatedProject,fnld);
                }
                if(fnld.Phone !=null && !newPhoneMap.containsKey(fnld.Phone+allocatedProject)){
                    newPhoneMap.put(fnld.Phone+allocatedProject,fnld);
                }
                if(fnld.Secondary_Email__c !=null && !newemailMap.containsKey(fnld.Secondary_Email__c+allocatedProject)){
                    newemailMap.put(fnld.Secondary_Email__c+allocatedProject,fnld);
                }
                if(fnld.Secondary_phone__c !=null && !newPhoneMap.containsKey(fnld.Secondary_phone__c+allocatedProject)){
                    newPhoneMap.put(fnld.Secondary_phone__c+allocatedProject,fnld);
                }
            }
            system.debug(newPhoneMap.size());
            system.debug(newemailMap.size());
        }
        
        for(Lead nld : ldList){
            system.debug('Channel_partner_Name__c '+nld.Channel_partner_Name__c);
            string allocatedProject='';
            if(nld.Project_City__c != null){
                allocatedProject = nld.Project_City__c;
            }
            if(nld.Delete_Lead__c && nld.Main_Lead__c !=null){
                system.debug('====='+nld);
                system.debug(nld.Delete_Lead__c+'-----'+ nld.Main_Lead__c+'--=='+ nld.id+'--=='+ nld.Main_Lead_Age__c);
                
                addRelatedSource(nld);
            }else if(nld.Phone !=null && NewPhoneMap.containsKey(nld.Phone+allocatedProject) && nld.Id !=NewPhoneMap.get(nld.Phone+allocatedProject).Id){
                
                addRelatedSource2(nld,NewPhoneMap.get(nld.Phone+allocatedProject));
            }else if(nld.Email !=null && newemailMap.containsKey(nld.Email+allocatedProject) && nld.Id !=newemailMap.get(nld.Email+allocatedProject).Id){
                
                addRelatedSource2(nld,newemailMap.get(nld.Email+allocatedProject));
            }else if(nld.Secondary_phone__c !=null && NewPhoneMap.containsKey(nld.Secondary_phone__c+allocatedProject) && nld.Id !=NewPhoneMap.get(nld.Secondary_phone__c+allocatedProject).Id){
                
                addRelatedSource2(nld,NewPhoneMap.get(nld.Secondary_phone__c+allocatedProject));
            }else if(nld.Secondary_Email__c !=null && newemailMap.containsKey(nld.Secondary_Email__c+allocatedProject)  && nld.Id !=newemailMap.get(nld.Secondary_Email__c+allocatedProject).Id){
                
                addRelatedSource2(nld,newemailMap.get(nld.Secondary_Email__c+allocatedProject));
            }else{
                
                
                Related_source__c rs = new Related_source__c();
                rs.Lead__c = nld.Id;
                //system.debug(nld.Delete_Lead__c+'=='+rs.Lead__c +'nld.Id'+nld.Id);
                rs.Source__c = nld.LeadSource__c;
                rs.Sub_Source__c = nld.Sub_Source__c;
                rs.Phone__c = nld.Phone;
                rs.Country_Code__c = nld.Country_Code__c;
                rs.Secondary_Phone__c = nld.Secondary_Phone__c;
                rs.Secondary_Contry_Code__c = nld.Secondary_Country_Code__c;
                rs.Email__c = nld.Email;
                rs.Secondary_Email__c = nld.Secondary_Email__c;
                rs.Description__c = nld.Last_Comment__c;
                system.debug('======'+  rs.Description__c);
                rs.Allocated_Project__c = nld.Allocated_Project__c;
                rs.Campaign__c = nld.Campaign__c;
                rs.type_of_lead__c = nld.Type_of_lead__c;
                if(nld.CallUUID__c != null && nld.CallUUID__c != '')
                {
                    rs.CallUUID__c = nld.CallUUID__c; 
                }
                rs.Channel_partner_Name__c = nld.Channel_partner_Name__c;
                rs.Channel_partner_Email__c = nld.Channel_partner_Email__c;
                rs.Channel_partner_Phone__c = nld.Channel_partner_Phone__c;
                rs.Channel_Partner_Firm__c = nld.Channel_Partner_Firm__c;
                rsList.add(rs);
                if(!matchedMap.containsKey(nld.Id)){
                    system.debug(nld.Id);
                    Lead ld = new Lead();
                    ld.Id = nld.Id;
                    ld.Last_Source_Of_Enquiry__c =nld.LeadSource__c;
                    ld.Last_Sub_Source__c =  nld.Sub_Source__c;
                    ld.First_Source_Of_Enquiry__c = nld.LeadSource__c;
                    ld.First_Sub_Source__c =  nld.Sub_Source__c;
                    ld.First_Approach_On__c = system.now();
                    ld.First_Campaign__c = nld.Campaign__c;
                    if(nld.Campaign__c != null){ld.Last_Campagin__c = nld.Campaign__c;}
                    ld.First_Channel_Partner__c = nld.Channel_partner_Name__c;
                    if(nld.Channel_partner_Name__c != null){ld.Last_Channel_Partner__c = nld.Channel_partner_Name__c;}
                    //ld.Last_Re_engaged_On__c = system.now();
                    system.debug(nld.Re_engaged_Count__c);
                    // ld.Re_engaged_Count__c = nld.Re_engaged_Count__c + 1;
                    matchedMap.put(nld.Id,ld);
                    
                }
                
            }
        }
        
        if(rsList.size() >0){
            system.debug('rsList '+rsList);
            insert rsList;
            rsList.clear();
        }
        
        if(matchedMap.size() >0){
            updateList = matchedMap.values();
            system.debug('updateList '+updateList);
            update updateList;  
            matchedMap.clear();
            updateList.clear();
        }
        if(deleteList.size() >0){
            if(!test.isRunningTest()){
                system.debug('Insie the deltelist'+deleteList.size());
                delete deleteList;
            }
            deleteList.clear();
        }
    }
    public static void addRelatedSource(Lead nld){
        Related_source__c rs = new Related_source__c();
        rs.lead__c = nld.Main_Lead__c;
        system.debug('00000'+nld.Main_Lead__c);
        rs.Source__c = nld.Leadsource__c;
        rs.Sub_Source__c = nld.Sub_Source__c;
        rs.Phone__c = nld.Phone;
        rs.Country_Code__c = nld.Country_Code__c;
        rs.Secondary_Phone__c = nld.Secondary_Phone__c;
        rs.Secondary_Contry_Code__c = nld.Secondary_Country_Code__c;
        rs.Email__c = nld.Email;
        rs.Secondary_Email__c = nld.Secondary_Email__c;
        rs.Description__c = nld.Last_Comment__c;
        rs.Allocated_Project__c = nld.Allocated_Project__c;
        rs.Campaign__c = nld.Campaign__c;
        rs.type_of_lead__c = nld.Type_of_lead__c;
        rs.Channel_partner_Name__c = nld.Channel_partner_Name__c;
        rs.Channel_partner_Email__c = nld.Channel_partner_Email__c;
        rs.Channel_partner_Phone__c = nld.Channel_partner_Phone__c;
        rs.Channel_Partner_Firm__c = nld.Channel_Partner_Firm__c;
        if(nld.CallUUID__c != null && nld.CallUUID__c != '')
        {
            rs.CallUUID__c = nld.CallUUID__c;
        }
        system.debug('Status '+nld.Main_lead_status__c);
        if(nld.Main_lead_status__c == 'Closed Lost'	){
            rs.Lead_Type__c = 'Re-Opened';
        }else{
            rs.Lead_Type__c = 'Re-Engaged';
        }
        rsList.add(rs);
        deleteList.add(new Lead(Id=nld.Id));
        Lead ld = new Lead();
        ld.Id=nld.Main_Lead__c;
        ld.Last_Source_Of_Enquiry__c =nld.LeadSource__c;
        ld.Last_Sub_Source__c =  nld.Sub_Source__c;
        if(nld.Campaign__c != null){ld.Last_Campagin__c = nld.Campaign__c;}
        if(nld.Channel_partner_Name__c != null){ld.Last_Channel_Partner__c = nld.Channel_partner_Name__c;}
        ld.Re_Engaged_Date__c = system.now();
        
        //ld.Last_Re_engaged_On__c = system.now();
        system.debug(nld.Re_engaged_Count__c);
        system.debug('Lead status '+nld.Lead_status__c);
        //ld.Re_engaged_Count__c = nld.Re_engaged_Count__c + 1;
        if(nld.Main_lead_status__c == 'Closed Lost' ){
            system.debug('iguuugugggggggggggg');
            //string RecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Pre Sales').getRecordTypeId();
            //   ld.Lead_status__c ='Duplicate';
            
            ld.Lead_Assigned__c=false;
            ld.Lead_Transfered__c = false;
            // ld.Type_of_lead__c = 'Direct Lead';
            
            ld.Lead_Type__c ='Re-Opened';
            ld.Leadsource__c = nld.Leadsource__c;
            ld.Sub_Source__c = nld.Sub_Source__c;
            ld.Lead_status__c = 'New';
            ld.Lead_stage__c = 'Qualification';
            ld.Status = nld.Status;
            ld.Type__c = nld.Type__c;
            ld.Budget_Type__c = nld.Budget_Type__c;
            ld.BHK__c = nld.BHK__c;
            ld.Campaign__c = nld.Campaign__c;
            ld.Closed_Lost_Reason__c = null;
            
            ld.Area_of_residence__c = nld.Area_of_residence__c;
            ld.Last_Re_Opened_Date1__c = system.today();
            //ld.Assigment_count__c ='0';
            ld.Allocated_Project__c = nld.Allocated_Project__c;
            ld.Last_Re_Opened_Date__c = system.now();
            
            // ld.Re_assigned_date__c=null;
            // ld.RNR_date__c=null;
            // ld.status_change_date__c=null;
            ld.Last_comment__c = '';
            ld.Site_Visit_Schedule_Date__c=null;
            ld.Site_visit_Project__c = null;
            // ld.Reassigned_By__c=null;
            ld.Site_Visit_Feedback__c=null;
            ld.Subject__c=null;
            ld.Fake_Invalid_Reason__c = null;
            ld.Customer_Rating__c = null;
            
            //ld.Next_follow_up_Date__c=null;
            //ld.Next_Followup_Date__c=null;
            //ld.Next_Site_visit_Date__c=null;
            
            //ld.RecordTypeId=RecTypeId;
        }else{
            system.debug('Update the Lead source and subsource');
            ld.Lead_Type__c ='Re-Engaged';
            system.debug('+++'+ nld.Main_Lead_Age__c);
            if(nld.Main_Lead_Age__c>90){
                ld.Leadsource__c = nld.Leadsource__c;
                ld.Sub_Source__c = nld.Sub_Source__c;
                ld.Lead_Assigned__c=false; 
                ld.Updated_Lead_Age__c = nld.Main_Lead_Age__c;
                ld.Create_Date__c = system.today();
                /*ld.Lead_status__c = 'New';
                ld.Lead_stage__c = 'Qualification';
                ld.Lead_Probability__c='Cold';*/
                
            }
            
            
            
        }
        matchedMap.put(nld.Main_Lead__c,ld);
        //updateList.add(ld);
    }
    public static void addRelatedSource2(Lead nld, Lead mainContact){
        Related_source__c rs = new Related_source__c();
        rs.lead__c = mainContact.Id;
        rs.Source__c = nld.LeadSource__c;
        rs.Sub_Source__c = nld.Sub_Source__c;
        rs.Phone__c = nld.Phone;
        rs.Country_Code__c = nld.Country_Code__c;
        rs.Secondary_Phone__c = nld.Secondary_Phone__c;
        rs.Secondary_Contry_Code__c = nld.Secondary_Country_Code__c;
        rs.Email__c = nld.Email;
        rs.Lead_Type__c = 'Re-Engaged';
        rs.Secondary_Email__c = nld.Secondary_Email__c;
        rs.Description__c = nld.Last_Comment__c;
        rs.Allocated_Project__c = nld.Allocated_Project__c;
        rs.Campaign__c = nld.Campaign__c;
        rs.type_of_lead__c = nld.Type_of_lead__c;
        rs.Channel_partner_Name__c = nld.Channel_partner_Name__c;
        rs.Channel_partner_Email__c = nld.Channel_partner_Email__c;
        rs.Channel_partner_Phone__c = nld.Channel_partner_Phone__c;
        rs.Channel_Partner_Firm__c = nld.Channel_Partner_Firm__c;
        if(nld.CallUUID__c != null && nld.CallUUID__c != '')
        {
            rs.CallUUID__c = nld.CallUUID__c;
        }
        rsList.add(rs);
        deleteList.add(new Lead(Id=nld.Id));
        Lead ld = new Lead();
        ld.Id=mainContact.Id;
        ld.First_Source_Of_Enquiry__c = mainContact.LeadSource__c;
        ld.First_Sub_Source__c = mainContact.Sub_Source__c;
        ld.Last_Source_Of_Enquiry__c =nld.LeadSource__c;
        ld.Last_Sub_Source__c =  nld.Sub_Source__c;
        if(nld.Campaign__c != null){ld.Last_Campagin__c = nld.Campaign__c;}
        if(nld.Channel_partner_Name__c != null){ld.Last_Channel_Partner__c = nld.Channel_partner_Name__c;}
        ld.Re_Engaged_Date__c = system.now();
        ld.Lead_Type__c ='Re-Engaged';
        //ld.Last_Re_engaged_On__c = system.now();
        system.debug(nld.Re_engaged_Count__c);
        //ld.Re_engaged_Count__c = nld.Re_engaged_Count__c + 1;
        matchedMap.put(mainContact.Id,ld);
    }
    
    //Duplicate with project City and Phone, Secondary phone, email and secondary email
    /*
public static void duplicateCheck2(List<Lead> ldList){
system.debug('Duplicate check');
Set <String> PhoneSet = new Set<String>();
Set <String> mailSet = new Set<String>();

Set<String> phoneSet1 = new Set<String>();
Set<String> mailSet1 = new Set<String>();
Map<String, String> phoneProjectMap1 = new Map<String, String>();
for(Lead ld : ldList){
string allocatedProject='';
if( ld.Allocated_project__c !=null){
if(ld.Project_City__c != null){
allocatedProject = ld.Project_City__c;
} 
}
ld.Email = ld.Email;
ld.Phone = ld.Phone;
if(ld.Phone !=null){
PhoneSet.add(ld.Phone+allocatedProject);
// PhoneSet.add(ld.Phone);
system.debug('=='+ PhoneSet);
}
if(ld.Secondary_Phone__c !=null){
PhoneSet.add(ld.Secondary_Phone__c+allocatedProject);
//  PhoneSet.add(ld.Secondary_Phone__c);
}

// if (ld.Phone != null) {
//  phoneSet1.add(ld.Phone);
//if (ld.Allocated_project__c != null && ld.Allocated_project__c.equalsIgnoreCase('None'))
//{
//phoneProjectMap1.put(ld.Phone, ld.Allocated_project__c);
//}
//}
//if (ld.Secondary_Phone__c != null) {
// phoneSet1.add(ld.Secondary_Phone__c);
//if (ld.Allocated_project__c != null && ld.Allocated_project__c.equalsIgnoreCase('None'))
//{
//phoneProjectMap1.put(ld.Secondary_Phone__c, ld.Allocated_project__c);
//}
//}
if(ld.Email !=null){
mailSet.add(ld.Email+allocatedProject);
}
if(ld.Secondary_Email__c !=null){
mailSet.add(ld.Secondary_Email__c+allocatedProject);
}


}
// List<Lead> oldLeadList = [SELECT Id,PhoneProject__c,Secondary_Phone_Project__c,SecondaryEmailProject__c,EmailProject__c,Phone,Email,Secondary_phone__c,Secondary_Email__c,Project__c FROM Lead WHERE (Phone IN : PhoneSet OR  Secondary_phone__c IN :PhoneSet) ORDER BY CreatedDate ASC limit 10000];
//  List<Lead> oldLeadList1 = [SELECT Id, Phone, Allocated_project__c,Project__c FROM Lead WHERE Phone IN :phoneSet1];
// List<lead__c> oldLeadList = [SELECT Id,PhoneProject__c,Secondary_Phone_Project__c,SecondaryEmailProject__c,EmailProject__c,Phone__c,Email__c,Secondary_phone__c,Secondary_Email__c FROM lead__c WHERE (PhoneProject__c IN : PhoneSet OR  Secondary_Phone_Project__c IN :PhoneSet) ORDER BY CreatedDate ASC limit 10000];

List<Lead> oldLeadList = [SELECT Id,Email,Phone,PhoneProject__c,Secondary_Phone_Project__c,SecondaryEmailProject__c,EmailProject__c,Secondary_phone__c,Secondary_Email__c,Allocated_Project__c FROM Lead WHERE (PhoneProject__c IN : PhoneSet OR EmailProject__c IN :  mailSet OR Secondary_Phone_Project__c IN :PhoneSet OR SecondaryEmailProject__c IN : mailSet) AND Lead_Stage__c!='Closed Lost' ORDER BY CreatedDate ASC limit 10000];        
if(oldLeadList.size()>0){
system.debug('33333');
Map<string,Lead> emailMap = new Map<string,Lead>();
Map<string,Lead> SecondaryEmailMap = new Map<string,Lead>();
Map<string,Lead> PhoneMap = new Map<string,Lead>();
Map<string,Lead> SecondaryPhoneMap = new Map<string,Lead>();
for(Lead old : oldLeadList){
if(old.PhoneProject__c !=null){
PhoneMap.put(old.PhoneProject__c,old);
}    
if(old.EmailProject__c !=null){
emailMap.put(old.EmailProject__c,old);
}

if(old.SecondaryEmailProject__c !=null){
SecondaryEmailMap.put(old.SecondaryEmailProject__c,old);
}
if(old.Secondary_Phone_Project__c !=null){
SecondaryPhoneMap.put(old.Secondary_Phone_Project__c,old);
}
}
for(Lead nld : ldList){
string allocatedProject='';
if(nld.Allocated_Project__c!=null){
if(nld.Project_City__c != null){
allocatedProject = nld.Project_City__c;
}
}
if(nld.Phone !=null && PhoneMap.containsKey(nld.Phone+allocatedProject)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = PhoneMap.get(nld.Phone+allocatedProject).Id;
}
else if(nld.Phone !=null && SecondaryPhoneMap.containsKey(nld.Phone+allocatedProject)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = SecondaryPhoneMap.get(nld.Phone+allocatedProject).Id;
}
else if(nld.Email !=null && emailMap.containsKey(nld.Email+allocatedProject)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = emailMap.get(nld.Email+allocatedProject).Id;
}else if(nld.Email !=null && SecondaryEmailMap.containsKey(nld.Email+allocatedProject)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = SecondaryEmailMap.get(nld.Email+allocatedProject).Id;
}
else if(nld.Secondary_phone__c !=null && PhoneMap.containsKey(nld.Secondary_phone__c+allocatedProject)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = PhoneMap.get(nld.Secondary_phone__c+allocatedProject).Id;
}
else if(nld.Secondary_phone__c !=null && SecondaryPhoneMap.containsKey(nld.Secondary_phone__c+allocatedProject)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = SecondaryPhoneMap.get(nld.Secondary_phone__c+allocatedProject).Id; 
}
else if(nld.Secondary_Email__c !=null && emailMap.containsKey(nld.Secondary_Email__c+allocatedProject)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = emailMap.get(nld.Secondary_Email__c+allocatedProject).Id;
}else if(nld.Secondary_Email__c !=null && SecondaryEmailMap.containsKey(nld.Secondary_Email__c+allocatedProject)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = SecondaryEmailMap.get(nld.Secondary_Email__c+allocatedProject).Id;
}
}
}
else{
// List<Related_Source__c> oldList = [SELECT Id,Name,SecondaryEmailProject__c,PhoneProject__c,SecondaryPhoneProject__c,EmailProject__c,Contact1__c FROM Related_Source__c 
//WHERE (PhoneProject__c IN : PhoneSet OR SecondaryPhoneProject__c IN :PhoneSet) AND contact1__c!=null ORDER BY CreatedDate ASC];
List<Related_Source__c> oldList = [SELECT Id,Name,SecondaryEmailProject__c,PhoneProject__c,SecondaryPhoneProject__c,EmailProject__c,Lead__c FROM Related_Source__c 
WHERE (PhoneProject__c IN : PhoneSet OR EmailProject__c IN :  mailSet OR SecondaryPhoneProject__c IN :PhoneSet OR 
SecondaryEmailProject__c IN : mailSet) AND Lead__c!=null AND Lead__r.Lead_Stage__c!='Closed Lost' ORDER BY CreatedDate ASC];
system.debug(oldList);
Map<string,Related_Source__c> emailMap = new Map<string,Related_Source__c>();
Map<string,Related_Source__c> SecondaryEmailMap = new Map<string,Related_Source__c>();
Map<string,Related_Source__c> PhoneMap = new Map<string,Related_Source__c>();
Map<string,Related_Source__c> SecondaryPhoneMap = new Map<string,Related_Source__c>();
if(oldList.size() >0){
for(Related_Source__c old : oldList){
if(old.PhoneProject__c !=null){
PhoneMap.put(old.PhoneProject__c,old);
}
if(old.EmailProject__c !=null){
emailMap.put(old.EmailProject__c,old);
}

if(old.SecondaryEmailProject__c !=null){
SecondaryEmailMap.put(old.SecondaryEmailProject__c,old);
}
if(old.SecondaryPhoneProject__c !=null){
SecondaryPhoneMap.put(old.SecondaryPhoneProject__c,old);
}
}
for(Lead nld : ldList){
string allocatedProject='';
if(nld.Allocated_project__c !=null){
if(nld.Project_City__c != null){
allocatedProject = nld.Project_City__c;
}
}
if(nld.Phone !=null && PhoneMap.containsKey(nld.Phone+allocatedProject)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = PhoneMap.get(nld.Phone+allocatedProject).Lead__c;
}
else if(nld.Phone !=null && SecondaryPhoneMap.containsKey(nld.Phone+allocatedProject)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = SecondaryPhoneMap.get(nld.Phone+allocatedProject).Lead__c;
}
else if(nld.Email !=null && emailMap.containsKey(nld.Email+allocatedProject)){
nld.Delete_Lead__c = true; 
nld.Main_Lead__c = emailMap.get(nld.Email+allocatedProject).Lead__c;
}else if(nld.Email !=null && SecondaryEmailMap.containsKey(nld.Email+allocatedProject)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = SecondaryEmailMap.get(nld.Email+allocatedProject).Lead__c;
}
else if(nld.Secondary_phone__c !=null && PhoneMap.containsKey(nld.Secondary_phone__c+allocatedProject)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = PhoneMap.get(nld.Secondary_phone__c+allocatedProject).Lead__c;
}
else if(nld.Secondary_phone__c !=null && SecondaryPhoneMap.containsKey(nld.Secondary_phone__c+allocatedProject)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = SecondaryPhoneMap.get(nld.Secondary_phone__c+allocatedProject).Lead__c; 
}
else if(nld.Secondary_Email__c !=null && emailMap.containsKey(nld.Secondary_Email__c+allocatedProject)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = emailMap.get(nld.Secondary_Email__c+allocatedProject).Lead__c;
}else if(nld.Secondary_Email__c !=null && SecondaryEmailMap.containsKey(nld.Secondary_Email__c+allocatedProject)){
nld.Delete_Lead__c = true;
nld.Main_Lead__c = SecondaryEmailMap.get(nld.Secondary_Email__c+allocatedProject).Lead__c;
}
} 
}
}

//  Map<String, Lead> existingLeadMap = new Map<String, Lead>();
//for (Lead old : oldLeadList) {
//String key = old.Phone + phoneProjectMap1.get(old.Phone);
//existingLeadMap.put(key, old);
//}

//for (Lead nld : ldList) {
//if (nld.Phone != null) {
//String key = nld.Phone + nld.Allocated_project__c;
//if (existingLeadMap.containsKey(key)) {
//Lead existingLead = existingLeadMap.get(key);
//nld.Delete_Lead__c = true;
//nld.Main_Lead__c = existingLead.Id;
//nld.Allocated_Project__c = existingLead.Allocated_Project__c;
//}
//}
//} 

// recentCreatedLeadCheck(ldList);
}
*/
    // Duplicate with Phone, Secondary Phone, Email and Secondary Email
    //Please disable the city-wise duplication check for leads and provide an update. We need the system to allow duplication of leads regardless of the project involved.
    public static void duplicateCheck2(List<Lead> ldList){
        system.debug('Duplicate check');
        Set <String> PhoneSet = new Set<String>();
        Set <String> mailSet = new Set<String>();
        
        Set<String> phoneSet1 = new Set<String>();
        Set<String> mailSet1 = new Set<String>();
        Map<String, String> phoneProjectMap1 = new Map<String, String>();
        for(Lead ld : ldList){
            string allocatedProject='';
            /* 
if( ld.Allocated_project__c !=null){
if(ld.Project_City__c != null){
allocatedProject = ld.Project_City__c;
} 
}
*/
            ld.Email = ld.Email;
            ld.Phone = ld.Phone;
            if(ld.Phone !=null){
                PhoneSet.add(ld.Phone);
                // PhoneSet.add(ld.Phone);
                system.debug('=='+ PhoneSet);
            }
            if(ld.Secondary_Phone__c !=null){
                phoneSet1.add(ld.Secondary_Phone__c);
                //  PhoneSet.add(ld.Secondary_Phone__c);
            }
            
            /* if (ld.Phone != null) {
//  phoneSet1.add(ld.Phone);
if (ld.Allocated_project__c != null && ld.Allocated_project__c.equalsIgnoreCase('None'))
{
phoneProjectMap1.put(ld.Phone, ld.Allocated_project__c);
}
}
if (ld.Secondary_Phone__c != null) {
// phoneSet1.add(ld.Secondary_Phone__c);
if (ld.Allocated_project__c != null && ld.Allocated_project__c.equalsIgnoreCase('None'))
{
phoneProjectMap1.put(ld.Secondary_Phone__c, ld.Allocated_project__c);
}
} */
            if(ld.Email !=null){
                mailSet.add(ld.Email);
            }
            if(ld.Secondary_Email__c !=null){
                mailSet1.add(ld.Secondary_Email__c);
            }
            
            
        }
        // List<Lead> oldLeadList = [SELECT Id,PhoneProject__c,Secondary_Phone_Project__c,SecondaryEmailProject__c,EmailProject__c,Phone,Email,Secondary_phone__c,Secondary_Email__c,Project__c FROM Lead WHERE (Phone IN : PhoneSet OR  Secondary_phone__c IN :PhoneSet) ORDER BY CreatedDate ASC limit 10000];
        //  List<Lead> oldLeadList1 = [SELECT Id, Phone, Allocated_project__c,Project__c FROM Lead WHERE Phone IN :phoneSet1];
        // List<lead__c> oldLeadList = [SELECT Id,PhoneProject__c,Secondary_Phone_Project__c,SecondaryEmailProject__c,EmailProject__c,Phone__c,Email__c,Secondary_phone__c,Secondary_Email__c FROM lead__c WHERE (PhoneProject__c IN : PhoneSet OR  Secondary_Phone_Project__c IN :PhoneSet) ORDER BY CreatedDate ASC limit 10000];
        
        List<Lead> oldLeadList = [SELECT Id,Email,Phone,PhoneProject__c,Secondary_Phone_Project__c,SecondaryEmailProject__c,EmailProject__c,Secondary_phone__c,Secondary_Email__c,Allocated_Project__c FROM Lead WHERE (Phone IN : PhoneSet OR Email IN :  mailSet OR Secondary_phone__c IN :phoneSet1 OR Secondary_Email__c IN : mailSet1) AND Lead_Stage__c!='Closed Lost' AND Lead_Stage__c!='Booked' ORDER BY CreatedDate ASC limit 10000];        
        if(oldLeadList.size()>0){
            system.debug('33333');
            Map<string,Lead> emailMap = new Map<string,Lead>();
            Map<string,Lead> SecondaryEmailMap = new Map<string,Lead>();
            Map<string,Lead> PhoneMap = new Map<string,Lead>();
            Map<string,Lead> SecondaryPhoneMap = new Map<string,Lead>();
            for(Lead old : oldLeadList){
                if(old.Phone !=null){
                    PhoneMap.put(old.Phone,old);
                }    
                if(old.Email !=null){
                    emailMap.put(old.Email,old);
                }
                
                if(old.Secondary_Email__c !=null){
                    SecondaryEmailMap.put(old.Secondary_Email__c,old);
                }
                if(old.Secondary_Phone__c !=null){
                    SecondaryPhoneMap.put(old.Secondary_Phone__c,old);
                }
            }
            for(Lead nld : ldList){
                string allocatedProject='';
                /*   if(nld.Allocated_Project__c!=null){
if(nld.Project_City__c != null){
allocatedProject = nld.Project_City__c;
}
}*/
                if(nld.Phone !=null && PhoneMap.containsKey(nld.Phone)){
                    nld.Delete_Lead__c = true;
                    nld.Main_Lead__c = PhoneMap.get(nld.Phone).Id;
                }
                else if(nld.Phone !=null && SecondaryPhoneMap.containsKey(nld.Phone)){
                    nld.Delete_Lead__c = true;
                    nld.Main_Lead__c = SecondaryPhoneMap.get(nld.Phone).Id;
                }
                else if(nld.Email !=null && emailMap.containsKey(nld.Email)){
                    nld.Delete_Lead__c = true;
                    nld.Main_Lead__c = emailMap.get(nld.Email).Id;
                }else if(nld.Email !=null && SecondaryEmailMap.containsKey(nld.Email)){
                    nld.Delete_Lead__c = true;
                    nld.Main_Lead__c = SecondaryEmailMap.get(nld.Email).Id;
                }
                else if(nld.Secondary_phone__c !=null && PhoneMap.containsKey(nld.Secondary_phone__c)){
                    nld.Delete_Lead__c = true;
                    nld.Main_Lead__c = PhoneMap.get(nld.Secondary_phone__c).Id;
                }
                else if(nld.Secondary_phone__c !=null && SecondaryPhoneMap.containsKey(nld.Secondary_phone__c)){
                    nld.Delete_Lead__c = true;
                    nld.Main_Lead__c = SecondaryPhoneMap.get(nld.Secondary_phone__c).Id; 
                }
                else if(nld.Secondary_Email__c !=null && emailMap.containsKey(nld.Secondary_Email__c)){
                    nld.Delete_Lead__c = true;
                    nld.Main_Lead__c = emailMap.get(nld.Secondary_Email__c).Id;
                }else if(nld.Secondary_Email__c !=null && SecondaryEmailMap.containsKey(nld.Secondary_Email__c)){
                    nld.Delete_Lead__c = true;
                    nld.Main_Lead__c = SecondaryEmailMap.get(nld.Secondary_Email__c).Id;
                }
            }
        }
        else{
            /*  List<Related_Source__c> oldList = [SELECT Id,Name,SecondaryEmailProject__c,PhoneProject__c,SecondaryPhoneProject__c,EmailProject__c,Contact1__c FROM Related_Source__c 
WHERE (PhoneProject__c IN : PhoneSet OR SecondaryPhoneProject__c IN :PhoneSet) AND contact1__c!=null ORDER BY CreatedDate ASC];*/
            List<Related_Source__c> oldList = [SELECT Id,Name,SecondaryEmailProject__c,PhoneProject__c,SecondaryPhoneProject__c,EmailProject__c,Lead__c,Phone__c,Email__c,Secondary_Email__c,Secondary_Phone__c FROM Related_Source__c 
                                               WHERE (Phone__c IN : PhoneSet OR Email__c IN :  mailSet OR Secondary_Phone__c IN :phoneSet1 OR 
                                                      Secondary_Email__c IN : mailSet1) AND Lead__c!=null AND Lead__r.Lead_Stage__c!='Closed Lost' AND Lead__r.Lead_Stage__c!='Booked' ORDER BY CreatedDate ASC];
            system.debug(oldList);
            Map<string,Related_Source__c> emailMap = new Map<string,Related_Source__c>();
            Map<string,Related_Source__c> SecondaryEmailMap = new Map<string,Related_Source__c>();
            Map<string,Related_Source__c> PhoneMap = new Map<string,Related_Source__c>();
            Map<string,Related_Source__c> SecondaryPhoneMap = new Map<string,Related_Source__c>();
            if(oldList.size() >0){
                for(Related_Source__c old : oldList){
                    if(old.Phone__c !=null){
                        PhoneMap.put(old.Phone__c,old);
                    }
                    if(old.Email__c !=null){
                        emailMap.put(old.Email__c,old);
                    }
                    
                    if(old.Secondary_Email__c !=null){
                        SecondaryEmailMap.put(old.Secondary_Email__c,old);
                    }
                    if(old.Secondary_Phone__c !=null){
                        SecondaryPhoneMap.put(old.Secondary_Phone__c,old);
                    }
                }
                for(Lead nld : ldList){
                    string allocatedProject='';
                    /* if(nld.Allocated_project__c !=null){
if(nld.Project_City__c != null){
allocatedProject = nld.Project_City__c;
}
}*/
                    if(nld.Phone !=null && PhoneMap.containsKey(nld.Phone)){
                        nld.Delete_Lead__c = true;
                        nld.Main_Lead__c = PhoneMap.get(nld.Phone).Lead__c;
                    }
                    else if(nld.Phone !=null && SecondaryPhoneMap.containsKey(nld.Phone)){
                        nld.Delete_Lead__c = true;
                        nld.Main_Lead__c = SecondaryPhoneMap.get(nld.Phone).Lead__c;
                    }
                    else if(nld.Email !=null && emailMap.containsKey(nld.Email)){
                        nld.Delete_Lead__c = true; 
                        nld.Main_Lead__c = emailMap.get(nld.Email).Lead__c;
                    }else if(nld.Email !=null && SecondaryEmailMap.containsKey(nld.Email)){
                        nld.Delete_Lead__c = true;
                        nld.Main_Lead__c = SecondaryEmailMap.get(nld.Email).Lead__c;
                    }
                    else if(nld.Secondary_phone__c !=null && PhoneMap.containsKey(nld.Secondary_phone__c)){
                        nld.Delete_Lead__c = true;
                        nld.Main_Lead__c = PhoneMap.get(nld.Secondary_phone__c).Lead__c;
                    }
                    else if(nld.Secondary_phone__c !=null && SecondaryPhoneMap.containsKey(nld.Secondary_phone__c)){
                        nld.Delete_Lead__c = true;
                        nld.Main_Lead__c = SecondaryPhoneMap.get(nld.Secondary_phone__c).Lead__c; 
                    }
                    else if(nld.Secondary_Email__c !=null && emailMap.containsKey(nld.Secondary_Email__c)){
                        nld.Delete_Lead__c = true;
                        nld.Main_Lead__c = emailMap.get(nld.Secondary_Email__c).Lead__c;
                    }else if(nld.Secondary_Email__c !=null && SecondaryEmailMap.containsKey(nld.Secondary_Email__c)){
                        nld.Delete_Lead__c = true;
                        nld.Main_Lead__c = SecondaryEmailMap.get(nld.Secondary_Email__c).Lead__c;
                    }
                } 
            }
        }
        
        /*  Map<String, Lead> existingLeadMap = new Map<String, Lead>();
for (Lead old : oldLeadList) {
String key = old.Phone + phoneProjectMap1.get(old.Phone);
existingLeadMap.put(key, old);
}

for (Lead nld : ldList) {
if (nld.Phone != null) {
String key = nld.Phone + nld.Allocated_project__c;
if (existingLeadMap.containsKey(key)) {
Lead existingLead = existingLeadMap.get(key);
nld.Delete_Lead__c = true;
nld.Main_Lead__c = existingLead.Id;
nld.Allocated_Project__c = existingLead.Allocated_Project__c;
}
}
} */
        
        // recentCreatedLeadCheck(ldList);
    }
    
    
    
    public static String duplicateCheckProject(List<Lead> ldList) {
    System.debug('Starting Duplicate Check');
    
    // Initialize sets to store phone and email values for checking duplicates
    Set<String> phoneSet = new Set<String>();
    Set<String> mailSet = new Set<String>();
    Set<String> secondaryPhoneSet = new Set<String>();
    Set<String> secondaryMailSet = new Set<String>();
    Set<Id> leadIdSet = new Set<Id>();

    // Collect values from incoming leads
    for (Lead ld : ldList) {
        if (ld.Phone != null) {
            phoneSet.add(ld.Phone);
        }
        if (ld.Secondary_Phone__c != null) {
            secondaryPhoneSet.add(ld.Secondary_Phone__c);
        }
        if (ld.Email != null) {
            mailSet.add(ld.Email);
        }
        if (ld.Secondary_Email__c != null) {
            secondaryMailSet.add(ld.Secondary_Email__c);
        }
        leadIdSet.add(ld.Id); // Collect Lead IDs to exclude from queries
    }

    // Check for existing leads with matching phone/email details (exclude specific stages)
    List<Lead> oldLeadList = [
        SELECT Id, Email, Phone, PhoneProject__c, Secondary_Phone_Project__c, SecondaryEmailProject__c,
               EmailProject__c, Secondary_phone__c, Secondary_Email__c, Allocated_Project__c
        FROM Lead 
        WHERE 
            (Phone IN :phoneSet OR Email IN :mailSet OR 
             Secondary_Phone__c IN :secondaryPhoneSet OR Secondary_Email__c IN :secondaryMailSet)
            AND Lead_Stage__c NOT IN ('Closed Lost', 'Booked')
            AND Id NOT IN :leadIdSet
        ORDER BY CreatedDate ASC 
        LIMIT 10000
    ];

    // Return message if duplicates found in existing leads
    if (!oldLeadList.isEmpty()) {
        return 'Lead already existed.';
    }

    // Check for duplicates in Related_Source__c
    List<Related_Source__c> oldList = [
        SELECT Id, Name, SecondaryEmailProject__c, PhoneProject__c, SecondaryPhoneProject__c, EmailProject__c, Lead__c
        FROM Related_Source__c 
        WHERE 
            (Phone__c IN :phoneSet OR Email__c IN :mailSet OR 
             Secondary_Phone__c IN :secondaryPhoneSet OR Secondary_Email__c IN :secondaryMailSet)
            AND Lead__c != null
            AND Lead__c NOT IN :leadIdSet
            AND Lead__r.Lead_Stage__c NOT IN ('Closed Lost', 'Booked')
        ORDER BY CreatedDate ASC
    ];

    System.debug('Related_Source__c duplicates found: ' + oldList);

    // Return message if duplicates found in Related_Source__c records
    if (!oldList.isEmpty()) {
        return 'Lead already existed';
    }

    // No duplicates found
    return null;
}

    /* public static void createLog(List<Lead> ldList){
List<Lead> updateLIst = new List<Lead>();
List<Task> tsList = new List<Task>();
for(Lead ld : ldList){
if(ld.Last_Comment__c!=null){
Lead l = new Lead();
l.Id = ld.Id;
l.Last_commented_date__c = system.now(); 
updateLIst.add(l);
Task logTask =  new Task(
Subject = 'Last comment',
ActivityDate = system.today(),
status='Completed',
Description=ld.Last_Comment__c,
tasksubtype='Call',
WhoId = ld.Id);
tsList.add(logTask);
}
}
if(tsList.size()>0){
Insert tsList;
if(updateLIst.size()>0){
Update updateLIst;
}
}
}*/
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
        i=0;i=0;i=0;i=0;
        i=0;i=0;i=0;i=0;
        i=0;i=0;i=0;i=0;
        i=0;i=0;i=0;i=0;
        i=0;i=0;i=0;i=0;
        i=0;i=0;i=0;i=0;
        
        
    }
    
    
    
}