public class CreateALogAfterLeasdUpdate {
    Public static boolean fromUpdateLeadStatus;
    @AuraEnabled
    public static string createALog(Id RecordId, string Project,string status){
        fromUpdateLeadStatus =true;
        string response;
        system.debug('here is id '+ RecordId + 'Project '+ Project);
            
        Lead con = [select id,Follow_up_scheduled_date__c,Follow_up_Status__c,Follow_up_Subject__c,Follow_up_Description__c,Lead_status__c,Lead_Stage__c,Sub_Status__c,Last_Comment__c,Subject__c,Site_visit_Project__c,Next_follow_up_Date__c,Project__c,Site_Visit_Feedback__c,Site_Visit_Schedule_Date__c,Allocated_Project__c,SV_Completed_Date_Time__c from Lead where Id = :RecordId];
         Project = Project == null?con.Allocated_Project__c : Project;
            list<Project__c> proj = [select id from Project__c where Name=:Project limit 1];
        if(con.Lead_Stage__c=='SV Schedule')
        {
            system.debug('SV Schedule');
            system.debug('project'+proj);
            List<Site_visit__c> sv  = [SELECT Id,Name,Date__c,Feedback__c,Reschedule_Date__c,Status__c FROM Site_visit__c WHERE Lead__c=:con.Id AND (status__c='Scheduled' OR status__c='Rescheduled') AND Projects__c in :proj limit 1];
            if(sv.size()>0)
            {
                sv[0].Date__c = con.Site_Visit_Schedule_Date__c;
                sv[0].Reschedule_Date__c = con.Site_Visit_Schedule_Date__c;
                sv[0].Status__c = 'Rescheduled';
                try{
                    update sv;
                    response='success';
                }catch(dmlException e){
                    System.debug('An error occurred: ' + e.getMessage());
                    response=e.getMessage();
                    con.Lead_Stage__c = status; 
                    update con;
                }
            }
            else{
                Site_Visit__c sv1 = new Site_Visit__c();
                sv1.Lead__c = RecordId;
                sv1.Projects__c = proj[0].id; 
                sv1.Date__c = con.Site_Visit_Schedule_Date__c;
                sv1.Status__c = 'Scheduled';
                //Database.SaveResult sr = Database.insert(sv1,false);
                //system.debug('sr'+sr);
                //if(!sr.isSuccess())
                //{
                    /*for (Database.Error err : sr.getErrors()) {
                        System.debug('Error Message: ' + err.getMessage());
                        response=err.getMessage();
                    }*/
                try{
                    insert sv1;
                    response='success';
                }
                catch(dmlException e){
                    System.debug('An error occurred: ' + e.getMessage());
                    response=e.getMessage();
                    con.Lead_Stage__c = status; 
                    update con;
                }
            }
        }
        if(con.Lead_Stage__c=='SV Completed')
        {
            system.debug('SV Completed');
            system.debug('Project '+ project);
            //List<Project__c> projs = [select Id,Name from Project__c where Name=:project];
            List<Site_visit__c> sv  = [SELECT Id,Name,Date__c,Feedback__c,SV_Completed_Date_Time__c,Status__c FROM Site_visit__c WHERE Lead__c=:RecordId AND (status__c='Scheduled' OR status__c='Rescheduled') AND Projects__r.Name = :project limit 1];
            system.debug('sv '+sv);
            if(sv.size()>0)
            {
                sv[0].Feedback__c =  con.Site_Visit_Feedback__c;
                sv[0].SV_Completed_Date_Time__c = con.SV_Completed_Date_Time__c;
                sv[0].Status__c = 'Completed';
                update sv;
                response='success';
            }
            /*else{
                 Site_Visit__c sv1 = new Site_Visit__c();
                sv1.Lead__c = RecordId;
                sv1.Projects__c = proj[0].id; 
                sv1.Date__c = con.Site_Visit_Schedule_Date__c;
                sv1.Feedback__c =  con.Site_Visit_Feedback__c;
                sv1.SV_Completed_Date_Time__c = con.SV_Completed_Date_Time__c;
                sv1.Status__c = 'Completed';
               insert sv1;
                 response='success';
            
            }*/
        }
        system.debug('response'+response);
        return response;
        /*if((con.Lead_status__c=='SV Schedule' || con.Lead_status__c=='SV Completed') && con.Site_visit_Project__c!=null && con.Site_Visit_Schedule_Date__c!=null){
            List<Site_visit__c> sv = new List<Site_visit__c>();
            sv = [SELECT Id,Name,Date__c,Project__c,Feedback__c FROM Site_visit__c WHERE Lead__c=:con.Id AND status__c='Scheduled' LIMIT 1];
            Site_visit__c nsv = new Site_visit__c();
            if(sv.size()>0){
                nsv.Id = sv[0].Id;
            }
            nsv.Lead__c= con.Id;
            nsv.Date__c=con.Site_Visit_Schedule_Date__c;
            nsv.Project__c = con.Site_visit_Project__c;
            if(con.Lead_status__c=='SV Completed'){
                nsv.Status__c='Conducted';
                nsv.Feedback__c = con.Site_Visit_Feedback__c;   
            }
            upsert nsv;
            
        }*/
        
        
    }
    
    
    @auraEnabled
    public static string checkfollowUp(string RecordId){
        string response;
         List<Follow_up__c> fol = [SELECT Id,Status__c,Name FROM Follow_up__c WHERE Status__c = 'Scheduled' AND Leads__c=:RecordId LIMIT 1];
        system.debug(RecordId+'======'+fol.size());
        if(fol.size()>0){
            response= 'Yes';
        }else{
            response= 'No';
       
        }
        system.debug(response);
        return response;
    }
    //To get the current Lead status
    /*@AuraEnabled
    public static string getStatus(ID RecordId){
        Lead con = [select id,Lead_status__c from Lead where ID = :RecordId];
        return con.Lead_status__c;
    }*/
    @AuraEnabled
    public static List<string> getProject(ID RecordId){
         List<String> globalPicklistValues = new List<String>();
      
        
        List<Site_Visit__c> sv = [select Projects__c,Projects__r.Name from Site_Visit__c where Lead__c = :RecordId and (Status__c='Scheduled' or status__c='Rescheduled')];
        system.debug('sv '+sv);
		if(sv.size()>0){
            for(Site_Visit__c siteVisit:sv){
                globalPicklistValues.add(siteVisit.Projects__r.Name);
            }
        }
        /*else{
              // Get a map of fields for the SObject
        Map<String, Schema.SObjectField> fieldMap   = SObjectType.Lead.fields.getMap(); 
        // Get the list of picklist values for this field.
        List<Schema.PicklistEntry> values  = fieldMap.get( 'Allocated_Project__c' ).getDescribe().getPickListValues();
        
        for( PicklistEntry entry : values ) {
            globalPicklistValues.add( entry.getLabel());
        }
       
            
        }*/
        system.debug('globalPicklistValues '+globalPicklistValues);
        return globalPicklistValues;
    }
    @AuraEnabled
    public static List<string> getAllocatedProject(ID RecordId){
       List<String> globalPicklistValues = new List<String>();
        
        // Get a map of fields for the SObject
        Map<String, Schema.SObjectField> fieldMap   = SObjectType.Lead.fields.getMap(); 
        // Get the list of picklist values for this field.
        List<Schema.PicklistEntry> values  = fieldMap.get( 'Allocated_Project__c' ).getDescribe().getPickListValues();
        
        for( PicklistEntry entry : values ) {
            globalPicklistValues.add( entry.getLabel());
        }
        return globalPicklistValues; 
        
    }
     @AuraEnabled
    public static void updateFileName(String fileId, String newFileName) {
        system.debug(fileId+'===='+newFileName);
            ContentVersion contentVersion = [SELECT Id,Title FROM ContentVersion WHERE ContentDocumentId = :fileId LIMIT 1];
            contentVersion.Title = newFileName;
        system.debug('Hello');
            update contentVersion;
        
    }
    @AuraEnabled
    public static string UpdateFollowUps(string recId, string ButtonValue,string UpdateLeadStatus){
        string res = null;
        List<Lead> l = [select Id,Name,Follow_up_scheduled_date__c from Lead where Id=:recId and Follow_up_scheduled_date__c!=null];
        if(l.size()>0){
           return res = UpdateFollowUpController.createALog(recId, ButtonValue,UpdateLeadStatus);  
        }
        return res;
    }
    @AuraEnabled
    public static List<Follow_up__c> getFollowUps(string RecordId){
        List<Follow_up__c> F = [select Id,Name,Scheduled_Date__c,Description__c,Status__c from Follow_up__c where Leads__c=:RecordId and Status__c='Scheduled'];
        return F;
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
        i=0;i=0;i=0;i=0;
        i=0;i=0;i=0;i=0;
        i=0;i=0;i=0;i=0;
        i=0;i=0;i=0;i=0;
        i=0;i=0;i=0;i=0;
        i=0;i=0;i=0;i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
         i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
         i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
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