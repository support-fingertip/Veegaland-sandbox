public class getRelatedList {
    public class databox{
        @auraEnabled
        public List<Related_Source__c> relatedSource{get;set;}
        @auraEnabled
        public List<Site_Visit__c> SiteVisit{get;set;}
        @auraEnabled
        public List<Quote__c> Followups{get;set;}
        @auraEnabled
        public List<Follow_up__c>Followup{get;set;}
    }
    @auraEnabled
    public static databox getRelatedList(string parentId){
        databox db = new databox();
        db.relatedSource = [SELECT Id,Name,Source__c,Sub_Source__c,Created_Date__c,Phone__c,Email__c,Lead__c FROM Related_Source__c WHERE Lead__c=:parentId];
        return db;
    }
    @auraEnabled
	public static databox getSiteVisit(string parentId){
        databox db = new databox();
        db.SiteVisit = [SELECT Id,Name,Project__c, Projects__r.Name ,Reschedule_Date__c,SV_Completed_Date_Time__c,Status__c,Date__c,Comments__c,Feedback__c,Visit_Notes__c,Visit_Type__c,Lead__c FROM Site_Visit__c WHERE Lead__c=:parentId];
        return db; 
    }
    @auraEnabled
    public static databox getFollowUp(string parentId){
        databox db = new databox();
        db.Followups = [SELECT Id,Name,Quote_date__c,Quote_status__c,Unit__c,Property_Type__c,Unit__r.Name,Leads__c FROM Quote__c WHERE 	Leads__c=:parentId];
        return db; 
        
    }
     @auraEnabled
    public static databox FollowUpdetails(string parentId){
        databox db = new databox();
        db.Followup = [SELECT Id,Name,	/*Booking__c,*/	Description__c,Followup_date_before__c,	OwnerId, 	Scheduled_Date__c,Status__c,Subject__c,Leads__c FROM Follow_up__c WHERE 	Leads__c=:parentId];
        return db; 
        
    }
}