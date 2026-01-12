public class followUpController {
    
    @AuraEnabled
    public static List<Follow_Up__c> getFollowUpDetails(String leadId)
    {
        
        List<Follow_Up__c> folloUpDetails=[Select Scheduled_Date__c,Status__c from Follow_Up__c where Leads__c=:leadId and Status__c='Scheduled' order by createdDate Desc limit 1];
        return folloUpDetails;
    }
    
    public static String dateFormat(String followupdate)
    { 	String dateTimeFormatted='';	
     String formattedDate='';
     String[] splitDateTime=followupdate.split(',');
     String[] splitDate=splitDateTime[0].split('/');
     for(integer i=splitDate.size()-1;i>=0;i--)
     {
         formattedDate+=splitDate[i];
         if(i!=0)
             formattedDate+='-';
     }
     
     dateTimeFormatted=	formattedDate+' '+splitDateTime[1];
     
     return dateTimeFormatted;
    }
}