public class BulkReassignmenController {
    

    @AuraEnabled
    public static List<user> getuserdetails(){
        return [SELECT Id,Name,Profile.Name,isActive FROM user where isActive=true];
    }
   
    @AuraEnabled
    public static List<Lead> getcon(string currentUserId, String projectId, String leadStatus,String leadSource,String leadstage,Date fromCreatedDate, Date toCreatedDate, String filterCreatedDate ) {
        system.debug('leadStatus-->'+ leadStatus +'  filterCreatedDate-->'+ filterCreatedDate +'  projectName-->'+ projectId +'  leadsource-->'+ leadSource );
        String fields ='id,name,Allocated_Project__c,Lead_Stage__c,Leadsource__c,Lead_status__c,CreatedDate,Lead_ID__c,OwnerId';
        String ObjectName ='Lead';
        string wherefilter = '';
      
        set<Id> dateFilterCustomerIds = new set<Id>();
        
        if(!String.isEmpty(currentUserId))
        {
            wherefilter = wherefilter+' where (OwnerId=:currentUserId )';
            
        }
        
        if(!String.isEmpty(projectId))
        {
            if(!String.isEmpty(currentUserId) )
            {  
                wherefilter = wherefilter+' and Allocated_Project__c=:projectId';
            }
            else{
                wherefilter = wherefilter+' where Allocated_Project__c=:projectId'; 
            }
        }
        if(fromCreatedDate != null )
        {
            if(!String.isEmpty(currentUserId) || !String.isEmpty(projectId))
            {  
                wherefilter = wherefilter+' and CreatedDate >=: fromCreatedDate';
            }
            else{
                wherefilter = wherefilter+' where CreatedDate >=: fromCreatedDate'; 
            }
        }
        if(toCreatedDate != null)
        {
            if(!String.isEmpty(currentUserId) || !String.isEmpty(projectId)||fromCreatedDate != null)
            {  
                wherefilter = wherefilter+' and CreatedDate <=: toCreatedDate';
            }
            else{
                wherefilter = wherefilter+' where CreatedDate <=: toCreatedDate'; 
            }
        }
        if(!String.isEmpty(filterCreatedDate))
        {
            if(!String.isEmpty(currentUserId) || !String.isEmpty(projectId)||fromCreatedDate != null||toCreatedDate != null)
            {  
                wherefilter = wherefilter+' and CreatedDate =: valuedate';
            }
            else{
                wherefilter = wherefilter+' where CreatedDate =: filterCreatedDate'; 
            }
        }
        if(!String.isEmpty(leadStatus))
        {
            if(!String.isEmpty(currentUserId) || !String.isEmpty(projectId) || !String.isEmpty(filterCreatedDate)||fromCreatedDate != null||toCreatedDate != null )
            {  
                wherefilter = wherefilter+' and Lead_status__c =: leadStatus';
            }
            else{
                wherefilter = wherefilter+' where Lead_status__c =: leadStatus'; 
            }
        }
        if(!String.isEmpty(leadSource))
        {
            if(!String.isEmpty(currentUserId) || !String.isEmpty(projectId) || !String.isEmpty(filterCreatedDate) || !String.isEmpty(leadStatus)||fromCreatedDate != null||toCreatedDate != null)
            {  
                wherefilter = wherefilter+' and Leadsource__c =: leadSource';
            }
            else{
                wherefilter = wherefilter+' where Leadsource__c =: leadSource'; 
            }
        }
        if(!String.isEmpty(leadstage))
        {
            if(!String.isEmpty(currentUserId) || !String.isEmpty(projectId) || !String.isEmpty(filterCreatedDate) || !String.isEmpty(leadStatus) ||!String.isEmpty(leadSource)||fromCreatedDate != null||toCreatedDate != null )
            {  
                wherefilter = wherefilter+' and Lead_Stage__c =: leadstage';
            }
            else{
                wherefilter = wherefilter+' where Lead_Stage__c =: leadstage'; 
            }
        }
        
        string query = 'Select '+ fields + ' FROM '+ ObjectName+wherefilter ; 
        
        
        system.debug('query --'+query);
        
        list<Lead> leadlist = Database.Query(query);
       
        return leadlist;
    }
    
    
    
    
    
    
    
    
 /*   @AuraEnabled
    public static List<Contact> getcon(string currentUserId, String projectId, Date createdDate, String leadStatus){
        user u = [SELECT Id,Name,Profile.Name FROM User WHERE Id=:currentUserId];
        List<Contact> conlst = new List<Contact>();
        
        if (String.isNotBlank(projectId) && createdDate != null && String.isNotBlank(leadStatus)) {
            conlst = [SELECT Id, Name, Allocated_Project__c, CreatedDate, Lead_status__c 
                      FROM Contact 
                      WHERE OwnerId=:currentUserId AND Allocated_Project__c=:projectId AND DAY_ONLY(CreatedDate) =: createdDate AND Lead_status__c = :leadStatus];
        } else if (String.isNotBlank(projectId) && createdDate != null) {
            conlst = [SELECT Id, Name, Allocated_Project__c, CreatedDate, Lead_status__c 
                      FROM Contact 
                      WHERE OwnerId=:currentUserId AND Allocated_Project__c=:projectId AND DAY_ONLY(CreatedDate) =: createdDate];
        } else if (String.isNotBlank(projectId) && String.isNotBlank(leadStatus)) {
            conlst = [SELECT Id, Name, Allocated_Project__c, CreatedDate, Lead_status__c 
                      FROM Contact 
                      WHERE OwnerId=:currentUserId AND Allocated_Project__c=:projectId AND Lead_status__c = :leadStatus];
        } else if (createdDate != null && String.isNotBlank(leadStatus)) {
            conlst = [SELECT Id, Name, Allocated_Project__c, CreatedDate, Lead_status__c 
                      FROM Contact 
                      WHERE OwnerId=:currentUserId AND DAY_ONLY(CreatedDate) =: createdDate AND Lead_status__c = :leadStatus];
        } else if (String.isNotBlank(projectId)) {
            conlst = [SELECT Id, Name, Allocated_Project__c, CreatedDate, Lead_status__c 
                      FROM Contact 
                      WHERE OwnerId=:currentUserId AND Allocated_Project__c=:projectId];
        } else if (createdDate != null) {
            conlst = [SELECT Id, Name, Allocated_Project__c, CreatedDate, Lead_status__c 
                      FROM Contact 
                      WHERE OwnerId=:currentUserId AND DAY_ONLY(CreatedDate) =: createdDate];
        } else if (String.isNotBlank(leadStatus)) {
            conlst = [SELECT Id, Name, Allocated_Project__c, CreatedDate, Lead_status__c 
                      FROM Contact 
                      WHERE OwnerId=:currentUserId AND Lead_status__c = :leadStatus];
        } else {
            conlst = [SELECT Id, Name, Allocated_Project__c, CreatedDate, Lead_status__c 
                      FROM Contact 
                      WHERE OwnerId=:currentUserId];
        }
        
        return conlst;
    } */
    
    @AuraEnabled 
    public static Map<String, String> getprojectFieldValue(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Lead.Allocated_Project__c.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            options.put(p.getValue(), p.getLabel());
        }
        
        return options;
    }
    
    @AuraEnabled 
    public static Map<String, String> getleadstatusFieldValue(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Lead.Lead_status__c.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            options.put(p.getValue(), p.getLabel());
        }
        
        return options;
    }
     @AuraEnabled 
    public static Map<String, String> getLeadSource(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Lead.Leadsource__c.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            options.put(p.getValue(), p.getLabel());
        }
        
        return options;
    }
    @AuraEnabled 
    public static Map<String, String> getLeadStageFieldValue(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Lead.Lead_Stage__c.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            options.put(p.getValue(), p.getLabel());
        }
        
        return options;
    }
    
    @AuraEnabled
    public static List<Lead> updateOwner(List<Lead> contacts, string currentUserId, string assignToId){
        system.debug('contacts-->'+contacts +'currentUserId-->'+ currentUserId +'assignToId-->' + assignToId);
        List<Lead> ldList = new List<Lead>();
        set<Id> ldid= new set<Id>();
        for(Lead con : contacts){
            Lead c = new Lead();
            c.Id = con.Id;
           ldid.add(con.Id);
            if(con.OwnerId != null){
                c.OwnerId = assignToId;
                ldList.add(c);
            } 
        }
        list<Related_Source__c> rslist = [select id,Lead__c,OwnerId from Related_Source__c where Lead__c IN:ldid ];
        if(rslist.size()>0){
             for(Related_Source__c rs:rslist){
            rs.OwnerId=assignToId;
        }
       
        }
        database.update(rslist,false); update rslist;
        
        List<Site_Visit__c> lstvt = [select id,OwnerId from Site_Visit__c where Lead__c IN:ldid];
        if(lstvt.size()>0){
            for(Site_Visit__c sv :lstvt){
                sv.OwnerId=assignToId;
            }
        }
        database.update(lstvt,false);
        
        system.debug('ldList'+ ldList);
        if(ldList.size() > 0){
            database.update(ldList,false);
        }
        
        return getcon(currentUserId,null,null,null,null,null,null,null);
    } 
}