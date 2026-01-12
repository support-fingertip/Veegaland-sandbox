public class HomeNotificationController {
@auraEnabled
    public static list<Follow_Up__c> getFollowUpInformation()
    {
        System.debug(userinfo.getFirstName()+'===>'+userinfo.getUserId());
        List<Follow_Up__c> followUpDetails=[Select Scheduled_Date__c,Status__c,Owner.Name,Leads__c,Leads__r.Name,Leads__r.Lead_status__c,Leads__r.Last_Comment__c,Leads__r.Id from Follow_Up__c  where Status__c='Scheduled' AND Scheduled_Date__c=today AND (Leads__r.OwnerId =:userInfo.getUserId() or Leads__r.Pre_sales_user__c =:userInfo.getUserId()) order by Scheduled_Date__c  ];
        System.debug(followUpDetails);
        return followUpDetails;
    }
@auraEnabled
    public static list<Site_Visit__c> getSiteVistInformation()
    {
        System.debug('Sv Details');
        List<Site_Visit__c> svDetails=[Select Date__c,Status__c,Owner.Name,Lead__r.Name,Lead__r.Lead_status__c,Lead__r.Last_Comment__c,Lead__r.Id from Site_Visit__c  where (Status__c='Scheduled' OR Status__c='Reschedule' ) AND Date__c=today AND (Lead__r.OwnerId =:userInfo.getUserId() or Lead__r.Pre_sales_user__c =:userInfo.getUserId()) order by Date__c ];
        return svDetails;
    }
@auraEnabled
    public static list<Follow_Up__c> getPendingFollowUpInformation()
    {
        List<Follow_Up__c> followUpDetails=[Select Scheduled_Date__c,Status__c,Owner.Name,Leads__c,Leads__r.Last_Comment__c,Leads__r.Name,Leads__r.Lead_status__c,Leads__r.Id from Follow_Up__c  where (Status__c='Scheduled' OR Status__c='Missed' ) AND Scheduled_Date__c=yesterday AND (Leads__r.OwnerId =:userInfo.getUserId() or Leads__r.Pre_sales_user__c =:userInfo.getUserId()) order by Scheduled_Date__c  ];
       System.debug(followUpDetails);
        return followUpDetails;
    }
@auraEnabled
    public static list<Site_Visit__c> getPendingSiteVistInformation()
    {
        System.debug('Sv Details');
        List<Site_Visit__c> svDetails=[Select Date__c,Status__c,Owner.Name,Lead__r.Last_Comment__c,Lead__r.Name,Lead__r.Lead_status__c,Lead__r.Id from Site_Visit__c  where (Status__c='Scheduled' OR Status__c='Reschedule' OR Status__c='Missed' ) AND Date__c=yesterday AND (Lead__r.OwnerId =:userInfo.getUserId() or Lead__r.Pre_sales_user__c =:userInfo.getUserId()) order by Date__c ];
        return svDetails;
    }
 /*@auraEnabled
    public static list<Task> getMissedCallTask()
    {
        List<Task> taskDetails=[select  id,subject,TaskSubtype,Status,Owner.Name,whoid,who.Name from task where subject='Missed Call' AND TaskSubtype='Task' AND Status='Open' AND whoid!=null AND ownerId=:userinfo.getUserId()];
        System.debug(taskDetails);
        return taskDetails;
    }*/
    
    @auraEnabled
    public static list<Call_Detail__c> getMissedCallTask()
    {
        List<Call_Detail__c> taskDetails=[select  id,Lead__c,Lead__r.Name,Lead__r.Lead_Status__c,callStartTime__c,Lead__r.OwnerId,Owner.Name,callStatus__c,calledNumber__c from Call_Detail__c where (callStatus__c='Not Connected' or callStatus__c='Not Connected') AND createddate=today  AND Lead__r.OwnerId=:userinfo.getUserId()];
        System.debug(taskDetails);
        return taskDetails;
    }
    

@auraEnabled
    public static String updateSvDetils(String recID,String svStatus,String updateValue,String conducatedDate)
    {
        System.debug(conducatedDate);
        list<Site_Visit__c> svData=[select Status__c,Cancelled_Reason__c,Feedback__c,Date__c from Site_Visit__c where id=:recID];
        if(svData.size()>0)
        {
            svData[0].Status__c=svStatus;
            if(svStatus=='Cancelled')
            	svData[0].Cancelled_Reason__c=updateValue;
       		 else if(svStatus=='Completed') 
             {	 if(conducatedDate!=null && conducatedDate!='')
             {String formattedFollowUpDate = followUpController.dateFormat(conducatedDate);
              svData[0].Date__c=datetime.valueOf(formattedFollowUpDate);}
                 svData[0].Feedback__c=updateValue;
             }
            else if(svStatus=='Rescheduled')
            {
                String formattedFollowUpDate = followUpController.dateFormat(updateValue);
                svData[0].Reschedule_Date__c = datetime.valueOf(formattedFollowUpDate);
            }
            
            //try{
                update  svData[0];
                return 'Updated';
            //}
            /*catch (DMLEXCEPTION e){
                return null;
            } */
        }
        return null;
    }

        
}