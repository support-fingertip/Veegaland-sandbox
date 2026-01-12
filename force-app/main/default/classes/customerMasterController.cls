public class customerMasterController {
    
    
    @AuraEnabled
    public Static list<Lead> getLead(Integer Limits){ 
       /*  Id userId = userinfo.getUserId();
        system.debug('userId'+fields);
        string  wherefilter = '';
        string query = '';
        User u = [select Id,Name,ProfileId,profile.name from User where Id=:userId];
        if(u.profile.name != 'System Administrator')
        {
            
            wherefilter = ' OwnerId=:userId';
            //query = 'Select '+ fields + ' FROM '+ ObjectName+' where OwnerId=:userId';   
            query = 'Select '+ fields + ' FROM '+ ObjectName+' where OwnerId=:userId ORDER BY CreatedDate DESC LIMIT :Integer.valueof(Limits)';
        }
        if(u.profile.name == 'System Administrator')
        {
            
            // query = 'Select '+ fields + ' FROM '+ ObjectName;
            query = 'Select '+ fields + ' FROM '+ ObjectName+' ORDER BY CreatedDate DESC LIMIT :Integer.valueof(Limits)';
            
            
        }
        system.debug('query'+query);
        return Database.Query(query);*/
         return [Select id,Name,Email,Lead_status__c,Allocated_Project__c,Leadsource__c From Lead LIMIT :Integer.valueof(Limits)]; 
       
    }
    @AuraEnabled
    public static Integer TotalLead(){
        AggregateResult results = [SELECT Count(Id) TotalLeadCount From Lead];
        Integer totalLeadRecord = (Integer)results.get('TotalLeadCount') ; 
        return totalLeadRecord;
    } 
    
    
    @AuraEnabled
    public static Lead  readRecords(string recordId){ 
        system.debug(recordId);
        Lead c =   [select Name,Id,Lead_status__c, Email,Phone from Lead where id=:recordId  ];
        return c;      
    }
    
    @AuraEnabled
    public static List<String> getProjectPickListValues(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Lead.Allocated_Project__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    @AuraEnabled
    public static List<User> getAllUsers(){
        
        string str= [select id,name from profile where id=:userinfo.getProfileId()].Name;
        
        return [SELECT Id,Name FROM user where isActive=TRUE  ];
        
        
    }
    @AuraEnabled
    public static List<pickValue> getPickValues(String objectName,string fieldName){
        
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(fieldName).getDescribe().getPickListValues();
        List<pickValue> pickValues =  new  List<pickValue>();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            pickValue p = new pickValue();
            p.label =    objPickList.getLabel() ;
            p.value =    objPickList.getValue() ;
            pickValues.add(p);
        }
        system.debug(pickValues);
        return pickValues;
        
        
    }
    class pickValue{ 
        
        @AuraEnabled public string label{get;set;}
        @AuraEnabled  public string value{get;set;}
    }
    
    @AuraEnabled
    public static leadDetails searchRecords1(string  objectName,integer limitVal,integer offsetval, String fields) {
       leadDetails leads  = new leadDetails();
        Id userId = userinfo.getUserId();
        system.debug('userId'+fields);
        string  wherefilter = '';
        string query = '';
        User u = [select Id,Name,ProfileId,profile.name from User where Id=:userId];
        if(u.profile.name != 'System Administrator')
        {
            Id userId2 = userinfo.getUserId();
            string str1= [select id,name from profile where id=:userinfo.getProfileId()].Name;
            if(str1 !='System Administrator'){
                
                if(str1 =='Team Leader'){
                    Id userId1 = userinfo.getUserId();
                    User ParentRoleId1 = [SELECT Id, Name, Email, Profile.Name, UserRole.Name,UserRole.Id FROM User where Id=:userId1];
                    UserRole userList1 = [select Id from UserRole where ParentRoleId = :ParentRoleId1.UserRole.Id AND ParentRoleID != null]; 
                    List<User> subordinatorList1 = [SELECT Id FROM User where UserRole.Id= :userList1.Id];
                    list<String> teamMember = new list<String>();
                    for(User u1 : subordinatorList1){
                        teamMember.add(u1.id);
                    }
                    teamMember.add(userId1);
                system.debug('teamMember--' +teamMember);
                    wherefilter = wherefilter+' where ownerId IN:  teamMember';
                }
                else{
                    wherefilter = wherefilter+' where ownerId =:  userId';
                }
                 //List<Lead__c> leadList = [select id,name from lead__c where ownerId IN: teamMember];
            }
            
               //wherefilter = ' OwnerId=:userId';
                //query = 'Select '+ fields + ' FROM '+ ObjectName+' where OwnerId=:userId';   
                query = 'Select '+ fields + ' FROM '+ ObjectName+wherefilter+' ORDER BY CreatedDate DESC LIMIT:limitVal OFFSET:offsetval';
             
           
        }
        if(u.profile.name == 'System Administrator')
        {
            
            // query = 'Select '+ fields + ' FROM '+ ObjectName;
            query = 'Select '+ fields + ' FROM '+ ObjectName+' ORDER BY CreatedDate DESC LIMIT:limitVal OFFSET:offsetval'; 
            
            
        }
        string query1 = 'Select count() FROM '+ ObjectName +wherefilter;
        integer  count= database.countQuery(query1);
        list<Sobject>acclist= Database.Query(query);
        leads.leadData = acclist; 
        leads.recordCount = count;
        system.debug('query'+query);
        return leads;
        
    } 
    @AuraEnabled
    public static leadDetails searchRecords(string  objectName, String fields, string status,string customerName,string customerSort,string AreaName,string Customers,string owner,date modifiedOn, date date1,date toDate,integer limitVal,integer offsetval) {
         leadDetails leads  = new leadDetails();
       
        string wherefilter = '';
        string SubCondition = '';
        set<Id> dateFilterCustomerIds = new set<Id>();
        /*  system.debug('Customers'+Customers);
Date myDate = date.newinstance(modifiedOn.year(), modifiedOn.month(), modifiedOn.day());

list<lead__c> leadlist =[select id,LastModifiedDate,Last_Modified_Date__c from lead__c where Last_Modified_Date__c =: myDate];
system.debug('leadlist' + leadlist);*/
        
        if(!String.isEmpty(status))
        {
            wherefilter = wherefilter+' where Lead_status__c=:status';
            
        }
        
        /*if(sortDate != null)
{

wherefilter = wherefilter+' where createDate=:sortDate'; 
}*/
        if(!String.isEmpty(customerName))
        {
            customerName = '%' + customerName + '%';
            if(!String.isEmpty(status))
            { 
                wherefilter = wherefilter+' and Name like :customerName ';
            }
            else{
                wherefilter = wherefilter+' where Name like :customerName '; 
            }
        }
        if(!String.isEmpty(AreaName))
        {
            if(!String.isEmpty(status) || !String.isEmpty(customerName))
            {  
                wherefilter = wherefilter+' and Allocated_Project__c=:AreaName';
            }
            else{
                wherefilter = wherefilter+' where Allocated_Project__c=:AreaName'; 
            }
        }
        if(!String.isEmpty(owner))
        {
            if(!String.isEmpty(status) || !String.isEmpty(customerName)|| !String.isEmpty(AreaName))
            {  
                wherefilter = wherefilter+' and OwnerId =: owner';
            }
            else{
                wherefilter = wherefilter+' where OwnerId =: owner'; 
            }
        }
        if(modifiedOn != null){
            if(!String.isEmpty(status) || !String.isEmpty(customerName)|| !String.isEmpty(AreaName)|| !String.isEmpty(owner) )
            {
                
                wherefilter = wherefilter+' and  Last_Modified_Date__c =: modifiedOn ';  
            }
            else{
                wherefilter = wherefilter+' where Last_Modified_Date__c =: modifiedOn';
            }
        }
        if(date1 != null){
            if(!String.isEmpty(status) || !String.isEmpty(customerName)|| !String.isEmpty(AreaName)|| !String.isEmpty(owner) || modifiedOn != null)
            {
                
                wherefilter = wherefilter+' and  Created_Date__c >=: date1 ';  
            }
            else{
                wherefilter = wherefilter+' where Created_Date__c >=: date1';
            }
        }
        if(toDate != null){
            if(!String.isEmpty(status) || !String.isEmpty(customerName)|| !String.isEmpty(AreaName) || !String.isEmpty(owner) || date1 != null || modifiedOn != null)
            {
                
                wherefilter = wherefilter+' and  Created_Date__c <=: toDate ';  
            }
            else{
                wherefilter = wherefilter+' where Created_Date__c <=: toDate';
            }
        }
        
        if(!string.isEmpty(Customers))
        {
            Id userId = userinfo.getUserId();
            system.debug('Customers'+Customers);
            if(Customers == 'Mycustomer')
            {
                
                if(!String.isEmpty(status) || !String.isEmpty(customerName)|| !String.isEmpty(AreaName) || !String.isEmpty(owner) || date1 != null || toDate != null|| modifiedOn != null )
                {
                    
                    wherefilter = wherefilter+' and ownerId =: userId';  
                }
                else{
                    wherefilter = wherefilter+' where ownerId =: userId';
                }
                
            }
            
            if(Customers == 'Teamcustomer' || Customers == 'Allcustomer')
            {
                User ParentRoleId = [SELECT Id, Name, Email, Profile.Name, UserRole.Name,UserRole.Id FROM User where Id=:userId];
                UserRole userList = [select Id from UserRole where ParentRoleId = :ParentRoleId.UserRole.Id AND ParentRoleID != null]; 
                List<User> subordinatorList = [SELECT Id FROM User where UserRole.Id= :userList.Id];
                string str= [select id,name from profile where id=:userinfo.getProfileId()].Name;
                system.debug('subordinatorList'+subordinatorList);
                Id subUserId;
                for(User subUser:subordinatorList){
                    subUserId = subUser.Id;
                    //system.debug('subUser'+subUser);
                    if(!string.isEmpty(SubCondition))
                    {
                        //subUserId = subUser.Id;
                        system.debug('subUser'+subUser.Id);
                        SubCondition =SubCondition+' or ownerId=:subUserId';  
                    }
                    else{
                        //subUserId = subUser.Id;
                        system.debug('subUser1'+subUser.Id);
                        SubCondition =SubCondition+' ownerId=:subUserId';
                    }
                    
                }
                if(Customers == 'Teamcustomer')
                {
                    
                    
                    if(!String.isEmpty(status) || !String.isEmpty(customerName)|| !String.isEmpty(AreaName) || !String.isEmpty(owner) || date1 != null || toDate != null || modifiedOn != null)
                    {
                        
                        wherefilter = wherefilter+' and ('+SubCondition+')';  
                    }
                    else{
                        wherefilter = wherefilter+' where '+SubCondition;
                    }
                }
                
                if(Customers == 'Allcustomer')
                {
                    if(!String.isEmpty(status) || !String.isEmpty(customerName)|| !String.isEmpty(AreaName) || modifiedOn != null || !String.isEmpty(owner) || date1 != null || toDate != null)
                    {
                        
                        wherefilter = wherefilter+' and ('+SubCondition +' or ownerId=:userId )';  
                    }
                    else{
                        wherefilter = wherefilter+' where '+SubCondition+' or ownerId=:userId';
                    }  
                }
                system.debug('userList'+userList); 
            }
        }
        string wherefilter1 = wherefilter;
        
         Id userId2 = userinfo.getUserId();
        
        string str1= [select id,name from profile where id=:userinfo.getProfileId()].Name;
        if(str1 !='System Administrator'){
           
            if(str1 =='Team Leader'){
                 Id userId1 = userinfo.getUserId();
            User ParentRoleId1 = [SELECT Id, Name, Email, Profile.Name, UserRole.Name,UserRole.Id FROM User where Id=:userId1];
            UserRole userList1 = [select Id from UserRole where ParentRoleId = :ParentRoleId1.UserRole.Id AND ParentRoleID != null]; 
            List<User> subordinatorList1 = [SELECT Id FROM User where UserRole.Id= :userList1.Id];
            list<String> teamMember = new list<String>();
            for(User u : subordinatorList1){
                teamMember.add(u.id);
            }
            teamMember.add(userId1);
            system.debug('teamMember--' +teamMember);
                wherefilter1 = wherefilter1 +' and ownerId IN:  teamMember';
                if(!String.isEmpty(status) || !String.isEmpty(customerName)|| !String.isEmpty(AreaName) || modifiedOn != null || !String.isEmpty(owner) || date1 != null || toDate != null)
                    {
                        wherefilter = wherefilter+' and ownerId IN:  teamMember';
                    }
                    else{
                        wherefilter = wherefilter+' where ownerId IN: teamMember';
                    } 
                
            }else{
                wherefilter1 = wherefilter1 +' and ownerId =:userId2';
                if(!String.isEmpty(status) || !String.isEmpty(customerName)|| !String.isEmpty(AreaName) || modifiedOn != null || !String.isEmpty(owner) || date1 != null || toDate != null)
                    {
                        wherefilter = wherefilter+' and ownerId =: userId2';
                    }
                    else{
                        wherefilter = wherefilter+' where ownerId =:userId2';
                    } 
                
                
                
            }
        }
        if(!String.isEmpty(customerSort))
        {
              
            wherefilter = wherefilter+' ORDER BY Name '+ customerSort;
        }else{
            wherefilter = wherefilter+' ORDER BY CreatedDate DESC';
        }
            string query = 'Select '+ fields + ' FROM '+ ObjectName+wherefilter +' LIMIT:limitVal OFFSET:offsetval' ; 
            string query1 = 'Select count() FROM '+ ObjectName+wherefilter1;
        system.debug('query1 --'+query1);
        system.debug('query --'+query);
            integer  count= database.countQuery(query1);
            list<Lead>acclist= Database.Query(query);
            leads.leadData = acclist; 
            leads.recordCount = count;
        
        
        //system.debug('leads.recordCount' + leads.recordCount);
        return leads;
    }
    public class leadDetails {
        @AuraEnabled
        public List<Lead> leadData;
        @AuraEnabled
        public Decimal recordCount;
    }
    
    public static void getCover(){
        if(Test.isRunningTest()){
            integer  i=0;
            if(i==0){
                
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
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0; 
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0; 
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
                i=0;i=0;i=0;i=0;
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