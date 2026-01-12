public class LeadOwnerPerformanceReportApex {
    @AuraEnabled
    /*public static List<UserPerformanceWrapper> getRecords(date FromCreatedDateFilter,date ToCreatedDateFilter) {
        system.debug('FromCreatedDateFilter '+FromCreatedDateFilter+' ToCreatedDateFilter '+ToCreatedDateFilter);
        // List to hold the performance wrappers for each user
    List<UserPerformanceWrapper> userPerformanceList = new List<UserPerformanceWrapper>();

    // Query to get users with the 'Sales Executive' profile
    List<User> users = [SELECT Id, Name FROM User WHERE Profile.Name = 'Sales Executive' and IsActive=True];
    
    // Iterate through each user to calculate their lead count and follow-up count
    for (User user : users) {
        // Count leads for the user created today
        List<AggregateResult> leadResults = [SELECT COUNT(Id) totalCount FROM Lead WHERE OwnerId = :user.Id AND Created_Date__c >= :FromCreatedDateFilter 
            AND Created_Date__c <= :ToCreatedDateFilter AND Lead_Stage__c='Qualification'];
        Integer leadCount = (leadResults.size() > 0) ? (Integer)leadResults[0].get('totalCount') : 0;

        // Count follow-ups for leads owned by the user
        List<Lead> leadList = [SELECT Id FROM Lead WHERE OwnerId = :user.Id AND Created_Date__c >= :FromCreatedDateFilter 
            AND Created_Date__c <= :ToCreatedDateFilter AND Lead_Stage__c='Qualification'];
        system.debug('leadList '+leadList);
        List<AggregateResult> followUpList =[SELECT COUNT(Id) followUpCount FROM Follow_up__c WHERE Leads__c IN :leadList AND OwnerId = :user.Id AND Completed_Date__c >= :FromCreatedDateFilter AND Completed_Date__c <= today  group by Leads__c]; 
        Integer followUpCounts = followUpList.size();
        /*List<Follow_up__c> followUpList = [
            SELECT Id, Leads__c 
            FROM Follow_up__c 
            WHERE Leads__c IN :leadList AND Completed_Date__c = TODAY AND OwnerId = :user.Id
        ];
        system.debug('followUpList '+followUpList);
        Integer followUpCount = followUpList.size();*/

        // Calculate percentage of follow-ups
        /*Decimal followUpPercentage = (leadList.size() > 0) ? ((Decimal)followUpCounts / leadList.size()) * 100 : 0;
        followUpPercentage = followUpPercentage.setScale(2, RoundingMode.HALF_UP);
        // Create a wrapper object for the user performance
        UserPerformanceWrapper upw = new UserPerformanceWrapper();
        upw.userId = user.Id;
        upw.userName = user.Name;
        upw.leadCount = leadCount;
        upw.followUpCount = followUpCounts;
        upw.followUpPercentage = followUpPercentage;
        if (followUpPercentage < 50) {
            upw.color = 'background-color:red';
        } else if (followUpPercentage >= 50 && followUpPercentage <= 70) {
            upw.color = 'background-color:orange';
        } else {
            upw.color = 'background-color:green';
        }
		
        // Add the wrapper to the list
        userPerformanceList.add(upw);
    }

    return userPerformanceList;
}*/
   public static List<UserPerformanceWrapper> getRecords(Date FromCreatedDateFilter, Date ToCreatedDateFilter, String CreatedDate) {
       system.debug('CreatedDate '+CreatedDate);
    // List to hold the performance wrappers for each user
    List<UserPerformanceWrapper> userPerformanceList = new List<UserPerformanceWrapper>();

    // Query to get users with the 'Sales Executive' profile
    List<User> users = [SELECT Id, Name FROM User WHERE Profile.Name = 'Sales Executive' AND IsActive = TRUE];

    // Iterate through each user to calculate their lead count and follow-up count
    for (User user : users) {
        List<AggregateResult> leadResults = new List<AggregateResult>();
        List<AggregateResult> leadTotalResults = new List<AggregateResult>();

        // Check if CreatedDate filter is set to "Date_Range"
        if (CreatedDate == 'Date_Range') {
            // Query to count leads for the specified date range (FromCreatedDateFilter and ToCreatedDateFilter)
            leadResults = [
                SELECT COUNT(Id) totalCount 
                FROM Lead 
                WHERE OwnerId = :user.Id 
                AND Create_Date_Formula__c >= :FromCreatedDateFilter 
                AND Create_Date_Formula__c <= :ToCreatedDateFilter 
                AND Lead_Stage__c = 'Qualification'
                AND Leadsource__c != 'Channel partner'
            ];
            
            leadTotalResults = [
                SELECT COUNT(Id) LeadtotalCount 
                FROM Lead 
                WHERE OwnerId = :user.Id 
                AND Create_Date_Formula__c >= :FromCreatedDateFilter 
                AND Create_Date_Formula__c <= :ToCreatedDateFilter
                AND Leadsource__c != 'Channel partner'
            ];
        } else {
            Id userId = user.Id;
            String query = 'SELECT COUNT(Id) totalCount FROM Lead WHERE OwnerId = :userId ';
            if(CreatedDate != 'Date_Range'){
                query += 'AND Create_Date_Formula__c = ' + CreatedDate + ' ';
            }
            query += 'AND Lead_Stage__c = \'Qualification\' AND Leadsource__c != \'Channel partner\'';
            leadResults = Database.query(query);
            /*date CreatedDateValue = Date.valueOf(CreatedDate);
            // Query to count leads for a specific date (CreatedDate)
            leadResults = [
                SELECT COUNT(Id) totalCount 
                FROM Lead 
                WHERE OwnerId = :user.Id 
                AND Created_Date__c = :CreatedDateValue 
                AND Lead_Stage__c = 'Qualification'
                AND Leadsource__c != 'Channel partner'
            ];*/
            String query1 = 'SELECT COUNT(Id) LeadtotalCount FROM Lead WHERE OwnerId = :userId ';
            if(CreatedDate != 'Date_Range'){
                query1 += 'AND Create_Date_Formula__c = ' + CreatedDate + ' ';
            }
            query1 += 'AND Leadsource__c != \'Channel partner\'';
            leadTotalResults = Database.query(query1);
            /*leadTotalResults = [
                SELECT COUNT(Id) LeadtotalCount 
                FROM Lead 
                WHERE OwnerId = :user.Id 
                AND Created_Date__c = :CreatedDateValue
                AND Leadsource__c != 'Channel partner'
            ];*/
        }

        // Initialize counts
        Integer leadCount = (leadResults.size() > 0) ? (Integer)leadResults[0].get('totalCount') : 0;
        Integer totalLeadCountInQualification = (leadResults.size() > 0) ? (Integer)leadResults[0].get('totalCount') : 0;
        Integer totalLeadCount = (leadTotalResults.size() > 0) ? (Integer)leadTotalResults[0].get('LeadtotalCount') : 0;

        Decimal leadPercentage = 0;
        
        // Avoid division by zero
        if (totalLeadCount > 0) {
            integer difference = totalLeadCount - totalLeadCountInQualification;
            leadPercentage = (Decimal.valueOf(difference) / Decimal.valueOf(totalLeadCount)) * 100;
            leadPercentage = leadPercentage.setScale(2, RoundingMode.HALF_UP);
        }
        
        // Create UserPerformanceWrapper instance
        UserPerformanceWrapper upw = new UserPerformanceWrapper();
        upw.userId = user.Id;
        upw.userName = user.Name;
        upw.leadQualificationCount = totalLeadCountInQualification;
        upw.totalLeadCount = totalLeadCount;
        upw.leadPercentage = leadPercentage;

        // Set color based on lead percentage
        if (leadPercentage < 24) {
            upw.color = 'background-color:red';
        } else if (leadPercentage >= 24 && leadPercentage <= 74) {
            upw.color = 'background-color:orange';
        } else {
            upw.color = 'background-color:green';
        }

        // Add the wrapper to the list
        userPerformanceList.add(upw);
    }
    
    return userPerformanceList;  
}

        
    /*@AuraEnabled
    public static List<UserPerformanceWrapper> getAllStageRecords(date FromCreatedDateFilter,date ToCreatedDateFilter) {
        system.debug('FromCreatedDateFilter '+FromCreatedDateFilter+' ToCreatedDateFilter '+ToCreatedDateFilter);
        // List to hold the performance wrappers for each user
        List<UserPerformanceWrapper> userPerformanceList = new List<UserPerformanceWrapper>();
        
        // Query to get users with the 'Sales Executive' profile
        List<User> users = [SELECT Id, Name FROM User WHERE Profile.Name = 'Sales Executive' and IsActive=True];
        
        // Iterate through each user to calculate their lead count and follow-up count
        for (User user : users) {
            // Count leads for the user created today
            List<AggregateResult> leadResults = [SELECT COUNT(Id) totalCount FROM Lead WHERE OwnerId = :user.Id AND Created_Date__c >= :FromCreatedDateFilter 
                                                 AND Created_Date__c <= :ToCreatedDateFilter];
            Integer leadCount = (leadResults.size() > 0) ? (Integer)leadResults[0].get('totalCount') : 0;
            
            // Count follow-ups for leads owned by the user
            List<Lead> leadList = [SELECT Id FROM Lead WHERE OwnerId = :user.Id AND Created_Date__c >= :FromCreatedDateFilter 
                                   AND Created_Date__c <= :ToCreatedDateFilter];
            system.debug('leadList '+leadList);
            List<AggregateResult> followUpList =[SELECT COUNT(Id) followUpCount FROM Follow_up__c WHERE Leads__c IN :leadList AND OwnerId = :user.Id AND Completed_Date__c >= :FromCreatedDateFilter AND Completed_Date__c <= today  group by Leads__c]; 
            Integer followUpCounts = followUpList.size();
            /*List<Follow_up__c> followUpList = [
SELECT Id, Leads__c 
FROM Follow_up__c 
WHERE Leads__c IN :leadList AND Completed_Date__c = TODAY AND OwnerId = :user.Id
];
system.debug('followUpList '+followUpList);
Integer followUpCount = followUpList.size();*/
            
            // Calculate percentage of follow-ups
           /* Decimal followUpPercentage = (leadList.size() > 0) ? ((Decimal)followUpCounts / leadList.size()) * 100 : 0;
            followUpPercentage = followUpPercentage.setScale(2, RoundingMode.HALF_UP);
            // Create a wrapper object for the user performance
            UserPerformanceWrapper upw = new UserPerformanceWrapper();
            upw.userId = user.Id;
            upw.userName = user.Name;
            upw.leadCount = leadCount;
            upw.followUpCount = followUpCounts;
            upw.followUpPercentage = followUpPercentage;
            if (followUpPercentage < 50) {
                upw.color = 'background-color:red';
            } else if (followUpPercentage >= 50 && followUpPercentage <= 70) {
                upw.color = 'background-color:orange';
            } else {
                upw.color = 'background-color:green';
            }
            
            // Add the wrapper to the list
            userPerformanceList.add(upw);
        }
        
        return userPerformanceList;
    }*/
    @AuraEnabled
    public static List<UserPerformanceWrapper> getAllStageRecords(Date FromCreatedDateFilter, Date ToCreatedDateFilter,String CreatedDate) {
        System.debug('FromCreatedDateFilter: ' + FromCreatedDateFilter + ', ToCreatedDateFilter: ' + ToCreatedDateFilter);
        system.debug('CreatedDate '+CreatedDate);
        
        List<UserPerformanceWrapper> userPerformanceList = new List<UserPerformanceWrapper>();
        
        // Query for active users with the 'Sales Executive' profile
        List<User> userList = [SELECT Id, Name FROM User WHERE Profile.Name = 'Sales Executive' AND IsActive = TRUE];
        List<Lead> leadList = new List<Lead>();
        if (CreatedDate == 'Date_Range') {
             // Query for leads owned by those users within the specified date range and without the 'Channel partner' lead source
            leadList = [SELECT Id, Name, OwnerId FROM Lead 
                        WHERE OwnerId IN :userList 
                        AND Leadsource__c != 'Channel partner' 
                        AND Create_Date_Formula__c >= :FromCreatedDateFilter 
                        AND Create_Date_Formula__c <= :ToCreatedDateFilter];  
        }
        else {
             // Query for leads owned by those users within the specified date range and without the 'Channel partner' lead source
            String query = 'SELECT Id, Name, OwnerId FROM Lead WHERE OwnerId IN :userList ';
            if(CreatedDate != 'Date_Range'){
                query += 'AND Create_Date_Formula__c = ' + CreatedDate + ' ';
            }
            query += 'AND Leadsource__c != \'Channel partner\'';
            leadList = Database.query(query);
        }
        
        system.debug('leadList '+leadList);
        
        
        // Prepare a Set of Lead Ids for querying follow-ups
        Set<Id> leadIds = new Set<Id>();
        for (Lead lead : leadList) {
            leadIds.add(lead.Id);
        }
        
        // Query for follow-ups associated with the leads
        List<Follow_up__c> followupList = [SELECT Id, Leads__c, Status__c 
                                           FROM Follow_up__c 
                                           WHERE Leads__c IN :leadIds];
        
        System.debug('Follow-up List Size: ' + followupList.size()); // Debugging line
        System.debug('Lead IDs: ' + leadIds); // Debugging line
        
        // Create a Map to hold follow-up counts per Lead Id
        Map<Id, Map<String, Integer>> followUpCountsMap = new Map<Id, Map<String, Integer>>();
        
        // Initialize follow-up counts for each follow-up record
        for (Follow_up__c follow : followupList) {
            if (!followUpCountsMap.containsKey(follow.Leads__c)) {
                followUpCountsMap.put(follow.Leads__c, new Map<String, Integer>{
                    'Scheduled' => 0,
                        'Missed' => 0,
                        'Completed' => 0
                        });
            }
            // Increment the count based on the follow-up status
            if (follow.Status__c != null) {
                followUpCountsMap.get(follow.Leads__c).put(follow.Status__c, followUpCountsMap.get(follow.Leads__c).get(follow.Status__c) + 1);
            }
        }
        
        // Iterate over users and their leads
        for (User user : userList) {
            integer TotalFollowUp = 0;
            integer TotalScheduled = 0;
            integer TotalMissed = 0;
            integer TotalCompleted = 0;
            if(!leadList.isEmpty()){
                for (Lead lead : leadList) {
                    if (lead.OwnerId == user.Id) {
                        UserPerformanceWrapper upw = new UserPerformanceWrapper();
                        upw.userName = user.Name;
                        upw.leadNames = lead.Name;
                        
                        // Fetch follow-up counts for the lead
                        Map<String, Integer> statusCounts = followUpCountsMap.get(lead.Id);
                        if (statusCounts != null) {
                            upw.scheduledCount = statusCounts.get('Scheduled') != null ? statusCounts.get('Scheduled') : 0;
                            upw.missedCount = statusCounts.get('Missed') != null ? statusCounts.get('Missed') : 0;
                            upw.completedCount = statusCounts.get('Completed') != null ? statusCounts.get('Completed') : 0;
                            TotalScheduled = TotalScheduled + upw.scheduledCount;
                            TotalMissed = TotalMissed + upw.missedCount;
                            TotalCompleted = TotalCompleted + upw.completedCount;
                        } else {
                            // No follow-ups for this lead
                            upw.scheduledCount = 0;
                            upw.missedCount = 0;
                            upw.completedCount = 0;
                        }
                        
                        // Calculate total follow-ups for the lead
                        upw.followUpCount = upw.scheduledCount + upw.missedCount + upw.completedCount;
                        TotalFollowUp = TotalFollowUp + upw.followUpCount; 
                        decimal followUp = upw.followUpCount;
                        system.debug('followUp '+followUp);
                        if(followUp == 0){
                            system.debug('follow up 0');
                            upw.followUpPercentage = 0;
                        }
                        else {
                            system.debug('completedCount '+upw.completedCount);
                            system.debug('followUp '+followUp);
                            upw.followUpPercentage = (upw.completedCount / followUp) * 100;
                            upw.followUpPercentage = upw.followUpPercentage.setScale(2, RoundingMode.HALF_UP);
                            system.debug('followUpPercentage '+upw.followUpPercentage);
                        }
                        
                        
                        // Add the user performance data for this lead
                        //userPerformanceList.add(upw);
                    }
                }
                UserPerformanceWrapper upw = new UserPerformanceWrapper();
                upw.userName = user.Name;
                //upw.leadNames = 'Total';
                upw.followUpCount = TotalFollowUp;
                decimal TotalFollowUps = TotalFollowUp;
                upw.scheduledCount = TotalScheduled;
                upw.missedCount = TotalMissed;
                upw.completedCount = TotalCompleted;
                decimal TotalCompleteds = TotalCompleted;
                if (TotalFollowUps > 0) {
                    upw.followUpPercentage = (TotalCompleteds / TotalFollowUps) * 100;
                    upw.followUpPercentage = upw.followUpPercentage.setScale(2, RoundingMode.HALF_UP);
                } else {
                    upw.followUpPercentage = 0;  // Set percentage to 0 if there are no follow-ups
                }
                
                if (upw.followUpPercentage < 24) {
                    upw.color = 'background-color:red';
                } else if (upw.followUpPercentage >= 24 && upw.followUpPercentage <= 74) {
                    upw.color = 'background-color:orange';
                } else {
                    upw.color = 'background-color:green';
                }
                userPerformanceList.add(upw);
            }
            else{
                UserPerformanceWrapper upw = new UserPerformanceWrapper();
                upw.userName = user.Name;
                upw.followUpCount = 0;
                upw.scheduledCount = 0;
                upw.missedCount = 0;
                upw.completedCount = 0;
                upw.followUpPercentage = 0;
                upw.color = 'background-color:red';
                userPerformanceList.add(upw);
            }
        }
        
        // Debugging output for the final user performance list
        System.debug('User Performance List: ' + userPerformanceList);
        
        return userPerformanceList;
    }



    
    @AuraEnabled
    public static List<LeadWrapper> getLeadRecords(Date FromCreatedDateFilter, Date ToCreatedDateFilter, string CreatedDate) {
        system.debug('FromCreatedDateFilter '+FromCreatedDateFilter+' ToCreatedDateFilter '+ToCreatedDateFilter+' CreatedDate '+CreatedDate);
        List<AggregateResult> groupedResults = new List<AggregateResult>();
        if (CreatedDate == 'Date_Range') {
        groupedResults = [
            SELECT Leads__c, COUNT(Id) followUpCount 
            FROM Follow_up__c 
            WHERE Leads__r.Create_Date_Formula__c >= :FromCreatedDateFilter 
            AND Leads__r.Create_Date_Formula__c <= :ToCreatedDateFilter
            GROUP BY Leads__c  // Ensure using the correct grouping field
            ORDER BY COUNT(Id) DESC  // Use the aggregate function in ORDER BY
            LIMIT 1
        ];
        }
        else {
            String query = 'SELECT Leads__c, COUNT(Id) followUpCount FROM Follow_up__c ';
            if(CreatedDate != 'Date_Range'){
                query += 'WHERE Leads__r.Create_Date_Formula__c = ' + CreatedDate + ' ';
            }
            query += ' GROUP BY Leads__c';
            groupedResults = Database.query(query);
        }
        Integer maxFollowUpCount;
        // Check if any result is returned
        if (!groupedResults.isEmpty()) {
            AggregateResult maxResult = groupedResults[0];
            Id leadWithMaxFollowUps = (Id)maxResult.get('Leads__c');
            maxFollowUpCount = (Integer)maxResult.get('followUpCount');
            
            // Output the lead ID and max follow-up count
            System.debug('Lead with maximum follow-ups: ' + leadWithMaxFollowUps);
            System.debug('Maximum follow-up count: ' + maxFollowUpCount);
        }
        List<Lead> leadList = new List<Lead>();
        if (CreatedDate == 'Date_Range') {
        // Single query to fetch Leads and related Follow-up records
            leadList = [
            SELECT Id, Name, Lead_Stage__c, No_of_Follow_Up__c,Closed_Lost_Reason__c,
            (SELECT Id, Description__c, Scheduled_Date__c,Subject__c,Status__c FROM Follow_ups__r)
            FROM Lead 
            WHERE Create_Date_Formula__c >= :FromCreatedDateFilter 
            AND Create_Date_Formula__c <= :ToCreatedDateFilter 
            LIMIT 100
        ];
        }
        else{
            String query = 'SELECT Id, Name, Lead_Stage__c, No_of_Follow_Up__c,Closed_Lost_Reason__c,(SELECT Id, Description__c, Scheduled_Date__c,Subject__c,Status__c FROM Follow_ups__r) FROM Lead ';
            if(CreatedDate != 'Date_Range'){
                query += 'WHERE Create_Date_Formula__c = ' + CreatedDate + ' ';
            }
            leadList = Database.query(query);  
        }
        system.debug('leadList '+leadList);
        Set<Id> leadIds = new Set<Id>();
        for (Lead lead : leadList) {
            leadIds.add(lead.Id);
        }
        // Query for Site Visits counts
        Map<Id, Integer> siteVisitCounts = new Map<Id, Integer>();
        if (!leadIds.isEmpty()) {
            List<AggregateResult> siteVisitResults = [
                SELECT Lead__c, COUNT(Id) siteVisitCount 
                FROM Site_Visit__c 
                WHERE Lead__c IN :leadIds 
                GROUP BY Lead__c
            ];
            
            // Map the results to the corresponding lead IDs
            for (AggregateResult result : siteVisitResults) {
                siteVisitCounts.put((Id)result.get('Lead__c'), (Integer)result.get('siteVisitCount'));
            }
        }
        
        // Create a list of LeadWrapper to return
        List<LeadWrapper> leadWrappers = new List<LeadWrapper>();
        
        /*for (Lead lead : leadList) {
            LeadWrapper lw = new LeadWrapper();
            lw.leadId = lead.Id;
            lw.leadName = lead.Name;
            lw.leadStage = lead.Lead_Stage__c;
            lw.NoofFollowup = lead.No_of_Follow_Up__c;
            // Loop through the related Follow-up records
            if (lead.Follow_ups__r != null && !lead.Follow_ups__r.isEmpty()) {
                for (Follow_up__c followUp : lead.Follow_ups__r) {
                    String Des = '<b>Description:</b> ' + followUp.Description__c + '<br/><b>Subject:</b> ' + followUp.Subject__c + '<br/><b>Status:</b> ' + followUp.Status__c;
                    lw.followUpDates.add(followUp.Scheduled_Date__c);
                    lw.descriptions.add(Des);
                }
            }
            
            leadWrappers.add(lw);
            system.debug('leadWrappers ' + leadWrappers);
        }*/
         // Create a wrapper for each lead
            for (Lead lead : leadList) {
                LeadWrapper lw = new LeadWrapper();
                lw.leadId = lead.Id;
                lw.leadName = lead.Name;
                lw.leadStage = lead.Lead_Stage__c;
                lw.lostReason = lead.Closed_Lost_Reason__c;
                lw.NoofFollowup = lead.No_of_Follow_Up__c;
                lw.NoofSVCompleted = siteVisitCounts.containsKey(lead.Id) ? siteVisitCounts.get(lead.Id) : 0;
                // Initialize dynamic columns for descriptions
                for (Integer i = 0; i < maxFollowUpCount; i++) {
                    lw.descriptions.add('');  // Fill with empty strings initially
                }

                // Populate the descriptions from the follow-ups
                Integer followUpIndex = 0;
                for (Follow_up__c followUp : lead.Follow_ups__r) {
                    if (followUpIndex < maxFollowUpCount) {
                        String Des = '<b>Description:</b> ' + followUp.Description__c + 
                                     '<br/><b>Subject:</b> ' + followUp.Subject__c + 
                                     '<br/><b>Status:</b> ' + followUp.Status__c;
                        lw.descriptions[followUpIndex] = Des;  // Set the description in the right column
                        followUpIndex++;
                    }
                }

                // Add the wrapper to the list
                leadWrappers.add(lw);
            }
        
        // Assuming `groupedResults` contains the max follow-up counts per lead
        
        // Iterate over the lead list to create LeadWrappers
        /*for (Lead lead : leadList) {
LeadWrapper lw = new LeadWrapper();
lw.leadId = lead.Id;
lw.leadName = lead.Name;
lw.leadStage = lead.Lead_Stage__c;

// Initialize the lists if not done already
lw.followUpDates = new List<Date>();
lw.descriptions = new List<String>();

// Get the max follow-up count for this lead


// Loop through the related Follow-up records
if (lead.Follow_ups__r != null && !lead.Follow_ups__r.isEmpty()) {
for (Follow_up__c followUp : lead.Follow_ups__r) {
lw.followUpDates.add(followUp.Scheduled_Date__c);
lw.descriptions.add(followUp.Description__c); // Add description, may include nulls
}
}

// Fill remaining entries with nulls if less than maxFollowUpCount
if (maxFollowUpCount != null) {
Integer followUpCount = lead.Follow_ups__r != null ? lead.Follow_ups__r.size() : 0;
for (Integer i = followUpCount; i < maxFollowUpCount; i++) {
lw.followUpDates.add(null); // Add null for missing follow-up dates
lw.descriptions.add(null); // Add null for missing descriptions
}
}

leadWrappers.add(lw);
System.debug('leadWrappers ' + leadWrappers);
}*/
        
        
        return leadWrappers;
    }
    
    public class LeadWrapper {
        @AuraEnabled
        public Id leadId;
        @AuraEnabled
        public String leadName;
        @AuraEnabled
        public String leadStage;
        @AuraEnabled
        public String lostReason;
        @AuraEnabled
        public decimal NoofFollowup;
        @AuraEnabled
        public decimal NoofSVCompleted;
        @AuraEnabled
        public List<DateTime> followUpDates = new List<DateTime>();
        @AuraEnabled
        public List<String> descriptions = new List<String>();
    }
    // Define the wrapper class
    public class UserPerformanceWrapper {
        @AuraEnabled public Id userId;
        @AuraEnabled public String userName;
        @AuraEnabled public String leadNames;
        @AuraEnabled public Id leadId;
        @AuraEnabled public Integer leadCount;
        @AuraEnabled public Integer leadQualificationCount;
        @AuraEnabled public Integer followUpCount;
        @AuraEnabled public Integer totalLeadCount;
        @AuraEnabled public Decimal followUpPercentage;
        @AuraEnabled public Decimal leadPercentage;
        @AuraEnabled public string color;
        @AuraEnabled public Integer scheduledCount;
        @AuraEnabled public Integer missedCount;
        @AuraEnabled public Integer completedCount;
    }
    
}