trigger UserAvailabalityTrigger on User (after update) 
{
    
    list<Daily_Log__c> dlnewlst=new list<Daily_Log__c>();
    Map<Id, Daily_Log__c> userMap = new Map<Id, Daily_Log__c>();
    Set<id> userid=new Set<id>();
    
    //for user Selection
    for(User us:trigger.new)
    {
        userid.add(us.id);
    }
    
    //To get existing log
    list<Daily_Log__c> dlst=[select id,name,User__c from Daily_Log__c where User__c In: userid];
    
    for (Daily_Log__c du : dlst) 
    {
        userMap.put(du.User__c, du);
    }
    
    
    for(User u:trigger.new)
    {
        
        if(Trigger.oldmap.get(u.id).Availability__c==false&& Trigger.newmap.get(u.id).Availability__c==true&&Trigger.newmap.get(u.id).Working__c==true)
        {
            if(dlst.size()>0)
            {
                if(userMap.containsKey(u.id))
                {
                    Daily_Log__c d=userMap.get(u.id);
                    d.Availabality_Start_Time__c=datetime.now();
                    dlnewlst.add(d);
                }
                
            }
            if(dlst.size()==0)
            {
                Daily_Log__c dl=new  Daily_Log__c();
                dl.Availabality_Start_Time__c=datetime.now();
                dl.user__c=u.id;
                dlnewlst.add(dl);
            }
        }
        
        
        if(Trigger.oldmap.get(u.id).Availability__c==true&& Trigger.newmap.get(u.id).Availability__c==false&&Trigger.newmap.get(u.id).Working__c==true)
        {
            if(dlst.size()>0)
            {
                if(userMap.containsKey(u.id))
                {
                    Daily_Log__c d=userMap.get(u.id);
                    d.Availabality_End_Time__c=datetime.now();
                    dlnewlst.add(d);
                }
                
            }
            if(dlst.size()==0)
            {
                Daily_Log__c dl=new  Daily_Log__c();
                dl.Availabality_End_Time__c=datetime.now();
                dl.user__c=u.id;
                dlnewlst.add(dl);
            }
        }
    }
    
    if(dlnewlst.size()>0)
    {
        upsert dlnewlst;
    }
    
}