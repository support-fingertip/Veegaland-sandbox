public class UnitPriceChange 
{
     @AuraEnabled
    public static List<user> getuserdetails(){
        return [SELECT Id,Name,Profile.Name,isActive FROM user where isActive=true];
    }
   
    @AuraEnabled
    public static List<Plot__c> getcon(string currentUserId, String projectId, String leadStatus,String leadSource,Date fromCreatedDate, Date toCreatedDate, String filterCreatedDate) 
    {
        system.debug('leadStatus-->'+ leadStatus +'  filterCreatedDate-->'+ filterCreatedDate +'  projectName-->'+ projectId +'  leadsource-->'+ leadSource );
        String fields ='id,name,Basic_Price__c,Property_Type__c,BHK_Type__c,Project_Name__c,Project__c,CreatedDate,Status__c';
        String ObjectName ='Plot__c';
        string wherefilter = '';
      
        set<Id> dateFilterCustomerIds = new set<Id>();
        
        if(!String.isEmpty(currentUserId))
        {
           // wherefilter = wherefilter+' where (OwnerId=:currentUserId )';
            
        }
        
        if(!String.isEmpty(projectId))
        {
            if(!String.isEmpty(currentUserId) )
            {  
                wherefilter = wherefilter+' and Project__c=:projectId';
            }
            else{
                wherefilter = wherefilter+' where Project__c=:projectId'; 
            }
        }
      
        
       
        if(!String.isEmpty(leadStatus))
        {
            if(!String.isEmpty(currentUserId) || !String.isEmpty(projectId) || !String.isEmpty(filterCreatedDate) )
            {  
                wherefilter = wherefilter+' and BHK_Type__c =: leadStatus';
            }
            else{
                wherefilter = wherefilter+' where BHK_Type__c =: leadStatus'; 
            }
        }
         if(!String.isEmpty(leadSource))
        {
            if(!String.isEmpty(currentUserId) || !String.isEmpty(projectId) || !String.isEmpty(filterCreatedDate) )
            {  
                wherefilter = wherefilter+' and Status__c =: leadSource';
            }
            else{
                wherefilter = wherefilter+' where Status__c =: leadSource'; 
            }
        }
       
        
        string query = 'Select '+ fields + ' FROM '+ ObjectName+wherefilter ; 
        
        
        system.debug('query --'+query);
        
        list<Plot__c> leadlist = Database.Query(query);
       
        return leadlist;
    }
   
    @AuraEnabled 
    public static Map<String, String> getprojectFieldValue(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Plot__c.BHK_Type__c.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            options.put(p.getValue(), p.getLabel());
        }
        
        return options;
    }
    
    @AuraEnabled 
    public static Map<String, String> getleadstatusFieldValue(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Plot__c.BHK_Type__c.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            options.put(p.getValue(), p.getLabel());
        }
        
        return options;
    }
     @AuraEnabled 
    public static Map<String, String> getLeadSource(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Plot__c.Status__c.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            options.put(p.getValue(), p.getLabel());
        }
        
        return options;
    }
    
    @AuraEnabled
    public static List<Plot__c> updateOwner(List<Plot__c> contacts, string currentUserId,Double price){
        
        List<Plot__c> ldList = new List<Plot__c>();
        set<Id> ldid= new set<Id>();
        for(Plot__c con : contacts){
            Plot__c c = new Plot__c();
            c.Id = con.Id;
           ldid.add(con.Id);
            if(price != null){
                c.Basic_Price__c =price;
                ldList.add(c);
            } 
        }
       
      
        
        system.debug('ldList'+ ldList);
        if(ldList.size() > 0){
            update ldList;
        }
        
        return getcon(currentUserId,null,null,null,null,null,null);
    } 

}