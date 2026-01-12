public without sharing class RoundRobinHandler {  

   /* public static void assignLead(List<Lead> leadList,boolean UpdateLead,string types){
    
        
         list<Round_Robin_Member__c> rrMembers = [select id,user__c FROM Round_Robin_Member__c  
                                                 WHERE Round_Robin__r.Active__c=true  AND User_Type__c=:types 
                                                 AND  Active__c = true AND Round_Robin__r.Name='Sales Team'
                                                 Order By 	Last_Assignment__c asc nulls first];
        
        system.debug('rrMembers '+rrMembers);
        if(!rrMembers.isEmpty() && !leadList.isEmpty()){
            list<user> userToUpdate = new list<user> ();
            Set<id> userIdSet = new Set<id>();
           	Integer userIndex=0;
            for(Lead s:leadList){
                userIndex= userIndex>rrMembers.size()-1?0:userIndex;
                s.put('OwnerId',rrMembers[userIndex].user__c);
                userIdSet.add(rrMembers[userIndex].user__c);
                userIndex++;
            	}
            //Update Sobject
             // update objectList;
            //Update the User
            for(User u:[select id,name,Last_assignment_on__c from user where id In :userIdSet ]){
                u.Last_assignment_on__c=System.now();
                userToUpdate.add(u);
            	}
            update userToUpdate;
            }else{
                throw new IllegalArgumentException('No Round Robin Member found for the Round Robin type: '+types);
            }
    }
        
        
       
     
    
    public static void assignToQueaue(List<Lead> leadList, string usType){  
        
        List<string>  projectinterested  = new List<string>();
        Map<string,List<Round_Robin_Member__c>>  projectQueMap = new Map<string,List<Round_Robin_Member__c>>();
        Map<string,List<Lead>>  projectContactMap = new Map<string,List<Lead>>();  
        for(Lead l:leadList){
            string project;
            
                project = l.Allocated_Project__c;
         
            if(project != null && project != '' && l.Lead_Assigned__c !=true && l.Delete_Lead__c !=true){ 
                projectinterested.add(project);
                List<Lead>  projectQue = projectContactMap.get(project); 
                if(projectQue  == null){
                    projectContactMap.put(project, new   List<Lead>{l} );
                }else{ 
                    projectQue.add(l);  
                    projectContactMap.put(project,  projectQue);
                } 
            }  
        }
       // system.debug(projectinterested);
        if(projectinterested.size() >0){
             system.debug(projectinterested);
           List<Round_Robin__c>  queList = [Select id,Project_Assigned__c, (select Name,User__c from  Round_Robin_Members__r  where Active__c =true AND User_Type__c='Sales'  order by Last_Assigned_Time__c asc  ) from Round_Robin__c where Project_Assigned__c in :projectinterested ]   ;
           system.debug(queList);
            if(queList.size() >0){
                for(Round_Robin__c r: queList ){  
                    List<Round_Robin_Member__c>  projectQue = projectQueMap.get(r.Project_Assigned__c); 
                    if(projectQue  == null){
                        projectQueMap.put(r.Project_Assigned__c,  r.Round_Robin_Members__r);
                    }else{ 
                        projectQue.add(r.Round_Robin_Members__r );
                        projectQueMap.put(r.Project_Assigned__c,  projectQue );
                        system.debug('projectQueMap'+projectQueMap);
                        
                    }
                    
                }
                
                Map<id,Round_Robin_Member__c>  rrMemberMapToUpdate = new  Map<id,Round_Robin_Member__c> ();
                for(string prj: projectContactMap.keyset()){ 
                    List<Lead>    leadsQue  =  projectContactMap.get(prj);
                    List<Round_Robin_Member__c>  projectQue = projectQueMap.get(prj); 
                    List<Round_Robin_Member__c>suser=[select id ,User__c,Round_Robin__r.name,Round_Robin__r.Project_Assigned__c 
                                                      from Round_Robin_Member__c where  Active__c =true AND User_Type__c='Site visit' 
                                                      AND Round_Robin__r.Project_Assigned__c IN:projectinterested  order by Last_Assigned_Time__c asc ];
                    id siteVisteUser;
                    if(!suser.isEmpty()){
                    siteVisteUser=suser[0].User__c;
                    system.debug(siteVisteUser);
                    }
                    
                    integer counter = 0; 
                    for(Lead  l :leadsQue   ){ 
                        
                        if(projectQue != null && projectQue.size() != 0 && projectQue[counter] != null && projectQue[counter].user__c != null){
                            system.debug('projectQue[counter].user__c: ' + projectQue[counter].user__c);
                            l.ownerId = projectQue[counter].user__c;
                            
                                l.Pre_sales_user__c =projectQue[counter].user__c;
                            
                                system.debug(projectQue[counter].user__c);
                                system.debug('here'+projectQue);
                                
                                l.sales_user__c =projectQue[counter].user__c;
                                
                                l.SV_User__c=siteVisteUser;
                                
                            
                            
                            l.Lead_Assigned__c = true;
                            l.Reassigned_By__c = UserInfo.getUserId();
                            l.Re_assigned_date__c = system.now();
                            // l.Assign_to_Queue__c  = false;
                            projectQue[counter].Last_Assigned_Time__c = system.now().getTime(); 
                            rrMemberMapToUpdate.put(projectQue[counter].id,projectQue[counter] ) ; 
                            counter ++; 
                            if(projectQue.size() == counter){
                                counter  =0; 
                            } 
                        } 
                        
                    }   
                }
                update rrMemberMapToUpdate.values();
            }
            
        }
        
    } */
    public static void assignCallEnquiryLeads(List<Lead> leadList,boolean updateLeads,string usertype) {
        Set<string>  projectinterested  = new Set<string>();
        Map<string,List<Lead>>  projectLeadMap = new Map<string,List<Lead>>(); 
        Map<id,user>  rrMemberMapToUpdate = new  Map<id,user> ();
        Map<id,Round_Robin_Member__c>  rrMemberMapToUpdateList = new  Map<id,Round_Robin_Member__c> ();
        for(Lead l:leadList){
            string project = l.Project_City__c;
            system.debug('========'+ project);
            
            
            
            if(project != null && project != '' && l.Lead_Assigned__c !=true && l.Delete_Lead__c !=true && l.Leadsource__c != 'Channel partner'){ 
                projectinterested.add(project);
                List<Lead>  projectQue = projectLeadMap.get(project);
                if(projectQue  == null){
                    projectLeadMap.put(project, new   List<Lead>{l} );
                }else{
                    projectQue.add(l);
                    projectLeadMap.put(project,  projectQue);
                } 
            }
        }
     
             Map<string,List<Round_Robin_Member__c>>  projectAvaliableQueMap = new Map<string,List<Round_Robin_Member__c>>();
        Map<string,List<Round_Robin_Member__c>>  projectQueMap = new Map<string,List<Round_Robin_Member__c>>();
        
        List<Round_Robin__c> RRAvaliablequeList=[Select id,Project_Assigned__c,Project_Assigned_City__c, (select Name,User__c from  Round_Robin_Members__r  where Active__c =true  AND user__r.isActive=true AND user__r.Availability__c=true AND user__r.Working__c=true AND User_Type__c=:usertype AND user__c !=:userinfo.getUserId()  order by Last_Assignment_Date_Time__c,createddate	 asc nulls first ) from Round_Robin__c where Project_Assigned_City__c in :projectinterested and Active__c = true ];
        List<Round_Robin__c> RRqueList=[Select id,Project_Assigned__c,Project_Assigned_City__c, (select Name,User__c from  Round_Robin_Members__r  where Active__c =true AND user__r.Working__c=true AND user__r.isActive=true AND User_Type__c=:usertype AND user__c !=:userinfo.getUserId() order by Last_Assignment_Date_Time__c,createddate	 asc nulls first  ) from Round_Robin__c where Project_Assigned_City__c in :projectinterested and Active__c = true ];
        system.debug('RRAvaliablequeList'+RRAvaliablequeList);
        //system.debug('RRqueList'+RRqueList);
        if(RRAvaliablequeList.size()>0){
            for(Round_Robin__c rr : RRAvaliablequeList){
                if(rr.Round_Robin_Members__r.size()>0){
                    system.debug(rr.Round_Robin_Members__r.size());
                    projectAvaliableQueMap.put(rr.Project_Assigned_City__c,rr.Round_Robin_Members__r);
                }
            }
        }
        if(RRqueList.size()>0){
            for(Round_Robin__c rr : RRqueList){
                if(rr.Round_Robin_Members__r.size()>0){
                    system.debug(rr.Round_Robin_Members__r.size());
                    projectQueMap.put(rr.Project_Assigned_City__c,rr.Round_Robin_Members__r);
                }
            }
        }
        system.debug('last step'+projectinterested);
        for(string prj : projectinterested){
           
            if(projectAvaliableQueMap.containskey(prj) && projectAvaliableQueMap.get(prj).size()>0){
                List<Round_Robin_Member__c>  projectQue = projectAvaliableQueMap.get(prj);  
                integer counter = 0; 
                for(Lead l : projectLeadMap.get(prj)){
                    if(projectQue!=null && projectQue.size() > 0 && projectQue[counter] != null && projectQue[counter].user__c != null){
                        system.debug('projectQue[counter].user__c: ' + projectQue[counter].user__c);
                        l.ownerId = projectQue[counter].user__c;
                        //l.Assign_To__c = projectQue[counter].user__c;
                        //l.last_re_assign_date__c = system.today();
                        l.Lead_Assigned__c = true;
                        l.Pre_sales_user__c =projectQue[counter].user__c;
                        l.Sales_User__c =projectQue[counter].user__c;
                        l.SV_User__c=projectQue[counter].user__c;
                          
                        l.Reassigned_By__c = UserInfo.getUserId();
                        l.Re_assigned_date__c = system.now();
                        
                        Round_Robin_Member__c rrList = new Round_Robin_Member__c();
                        rrList.Last_Assignment_Date_Time__c =  system.now().getTime(); 
                        rrList.Id = projectQue[counter].Id;
                        rrMemberMapToUpdateList.put(projectQue[counter].Id,rrList);
                        /*user u = new user();
                        u.Id = projectQue[counter].user__c;
                        u.Last_Assignment_Time1__c = system.now().getTime(); 
                        //projectQue[counter].Last_Assigned_Time__c = system.now().getTime();*/
                       
                        //rrMemberMapToUpdate.put(projectQue[counter].user__c,u ) ; 
                        counter ++; 
                        if(projectQue.size() == counter  ){
                            counter  =0; 
                        } 
                    }
                }
            }
            else if(projectQueMap.containsKey(prj) && projectQueMap.get(prj).size()>0){
                List<Round_Robin_Member__c>  projectQue = projectQueMap.get(prj);  
                integer counter = 0; 
                for(Lead l : projectLeadMap.get(prj)){
                    if(projectQue!=null && projectQue.size() > 0 && projectQue[counter] != null && projectQue[counter].user__c != null){
                        system.debug('projectQue[counter].user__c: ' + projectQue[counter].user__c);
                        l.ownerId = projectQue[counter].user__c;
                        l.last_re_assign_date__c = system.today();
                        l.Lead_Assigned__c = true;
                        l.Pre_sales_user__c =projectQue[counter].user__c;
                        l.Sales_User__c =projectQue[counter].user__c;
                        l.SV_User__c=projectQue[counter].user__c;
                        l.Reassigned_By__c = UserInfo.getUserId();
                        l.Re_assigned_date__c = system.now();
                        /*user u = new user();
                        u.Id = projectQue[counter].user__c;
                        u.Last_Assignment_Time1__c = system.now().getTime();
                        //projectQue[counter].Last_Assigned_Time__c = system.now().getTime(); 
                        rrMemberMapToUpdate.put(projectQue[counter].user__c,u ) ; */
                        Round_Robin_Member__c rrList = new Round_Robin_Member__c();
                        rrList.Last_Assignment_Date_Time__c =  system.now().getTime(); 
                        rrList.Id = projectQue[counter].Id;
                        rrMemberMapToUpdateList.put(projectQue[counter].Id,rrList);
                        counter ++; 
                        if(projectQue.size() == counter  ){
                            counter  =0; 
                        } 
                    }
                }
            }
        
    }
        if(rrMemberMapToUpdateList.values().size()>0){
            system.debug('rrMemberMapToUpdateList '+rrMemberMapToUpdateList);
            If(!test.IsrunningTest())
            {
               UPDATE rrMemberMapToUpdateList.values();
               rrMemberMapToUpdateList.clear();
            }
        }
        if(updateLeads){
            Update leadList;
        } 
    }
    public static void assignLead(List<Lead> leadList,boolean updateLeads,string usertype){
        system.debug('inside RoundRobin Handler');
        Set<string>  projectinterested  = new Set<string>();
        Map<string,List<Lead>>  projectLeadMap = new Map<string,List<Lead>>(); 
        Map<id,user>  rrMemberMapToUpdate = new  Map<id,user> ();
        for(Lead l:leadList){
            string project = l.Project_City__c;
            system.debug('========'+ project);
            if(project != null && project != '' && l.Lead_Assigned__c !=true && l.Delete_Lead__c !=true && l.Leadsource__c != 'Channel partner'){ 
                projectinterested.add(project);
                List<Lead>  projectQue = projectLeadMap.get(project);
                if(projectQue  == null){
                    projectLeadMap.put(project, new   List<Lead>{l} );
                }else{
                    projectQue.add(l);
                    projectLeadMap.put(project,  projectQue);
                } 
            }
        }
        system.debug('projectinterested'+ projectinterested.size());
        Map<string,List<Round_Robin_Member__c>>  projectAvaliableQueMap = new Map<string,List<Round_Robin_Member__c>>();
        Map<string,List<Round_Robin_Member__c>>  projectQueMap = new Map<string,List<Round_Robin_Member__c>>();
        
        List<Round_Robin__c> RRAvaliablequeList=[Select id,Project_Assigned__c,Project_Assigned_City__c, (select Name,User__c from  Round_Robin_Members__r  where Active__c =true  AND user__r.isActive=true AND user__r.Availability__c=true AND user__r.Working__c=true AND User_Type__c=:usertype AND user__c !=:userinfo.getUserId()  order by Last_Assigned_time_user__c,createddate	 asc nulls first ) from Round_Robin__c where Project_Assigned_City__c in :projectinterested and Active__c = true ];
        List<Round_Robin__c> RRqueList=[Select id,Project_Assigned__c,Project_Assigned_City__c, (select Name,User__c from  Round_Robin_Members__r  where Active__c =true AND user__r.Working__c=true AND user__r.isActive=true AND User_Type__c=:usertype AND user__c !=:userinfo.getUserId() order by Last_Assigned_time_user__c,createddate	 asc nulls first  ) from Round_Robin__c where Project_Assigned_City__c in :projectinterested and Active__c = true ];
        system.debug('RRAvaliablequeList'+RRAvaliablequeList);
        //system.debug('RRqueList'+RRqueList);
        if(RRAvaliablequeList.size()>0){
            for(Round_Robin__c rr : RRAvaliablequeList){
                if(rr.Round_Robin_Members__r.size()>0){
                    system.debug(rr.Round_Robin_Members__r.size());
                    projectAvaliableQueMap.put(rr.Project_Assigned_City__c,rr.Round_Robin_Members__r);
                }
            }
        }
        if(RRqueList.size()>0){
            for(Round_Robin__c rr : RRqueList){
                if(rr.Round_Robin_Members__r.size()>0){
                    system.debug(rr.Round_Robin_Members__r.size());
                    projectQueMap.put(rr.Project_Assigned_City__c,rr.Round_Robin_Members__r);
                }
            }
        }
        system.debug('last step'+projectinterested);
        for(string prj : projectinterested){
           
            if(projectAvaliableQueMap.containskey(prj) && projectAvaliableQueMap.get(prj).size()>0){
                List<Round_Robin_Member__c>  projectQue = projectAvaliableQueMap.get(prj);  
                integer counter = 0; 
                for(Lead l : projectLeadMap.get(prj)){
                    if(projectQue!=null && projectQue.size() > 0 && projectQue[counter] != null && projectQue[counter].user__c != null){
                        system.debug('projectQue[counter].user__c: ' + projectQue[counter].user__c);
                        l.ownerId = projectQue[counter].user__c;
                        //l.Assign_To__c = projectQue[counter].user__c;
                        //l.last_re_assign_date__c = system.today();
                        l.Lead_Assigned__c = true;
                        l.Pre_sales_user__c =projectQue[counter].user__c;
                        l.Sales_User__c =projectQue[counter].user__c;
                        l.SV_User__c=projectQue[counter].user__c;
                          
                        l.Reassigned_By__c = UserInfo.getUserId();
                        l.Re_assigned_date__c = system.now();
                        
                        user u = new user();
                        u.Id = projectQue[counter].user__c;
                        u.Last_Assignment_Time1__c = system.now().getTime(); 
                        //projectQue[counter].Last_Assigned_Time__c = system.now().getTime(); 
                       
                        rrMemberMapToUpdate.put(projectQue[counter].user__c,u ) ; 
                        counter ++; 
                        if(projectQue.size() == counter  ){
                            counter  =0; 
                        } 
                    }
                }
            }
            else if(projectQueMap.containsKey(prj) && projectQueMap.get(prj).size()>0){
                List<Round_Robin_Member__c>  projectQue = projectQueMap.get(prj);  
                integer counter = 0; 
                for(Lead l : projectLeadMap.get(prj)){
                    if(projectQue!=null && projectQue.size() > 0 && projectQue[counter] != null && projectQue[counter].user__c != null){
                        system.debug('projectQue[counter].user__c: ' + projectQue[counter].user__c);
                        l.ownerId = projectQue[counter].user__c;
                        l.last_re_assign_date__c = system.today();
                        l.Lead_Assigned__c = true;
                        l.Pre_sales_user__c =projectQue[counter].user__c;
                        l.Sales_User__c =projectQue[counter].user__c;
                        l.SV_User__c=projectQue[counter].user__c;
                        l.Reassigned_By__c = UserInfo.getUserId();
                        l.Re_assigned_date__c = system.now();
                        user u = new user();
                        u.Id = projectQue[counter].user__c;
                        u.Last_Assignment_Time1__c = system.now().getTime(); 
                        //projectQue[counter].Last_Assigned_Time__c = system.now().getTime(); 
                        rrMemberMapToUpdate.put(projectQue[counter].user__c,u ) ; 
                        counter ++; 
                        if(projectQue.size() == counter  ){
                            counter  =0; 
                        } 
                    }
                }
            }
        
    }
        if(rrMemberMapToUpdate.values().size()>0){
            If(!test.IsrunningTest())
            {
               UPDATE rrMemberMapToUpdate.values();
               rrMemberMapToUpdate.clear();
            }
        }
        if(updateLeads){
            Update leadList;
        }
    } 
    public static void assignToSiteVisit(List<Site_visit__c> sitevisits){
        system.debug('sitevisits '+sitevisits);
        set<Id> leadId = new set<Id>(); 
        for(Site_Visit__c sv: sitevisits){
            if(sv.Lead__c != null)
            {
               leadId.add(sv.Lead__c); 
            }
        	
        }
        Map<Id,Lead>  Mapid = new Map<Id,Lead>([select OwnerId from Lead where Id in :leadId]);
        for(Site_Visit__c sv: sitevisits){
            if(sv.Lead__c != null && Mapid.containsKey(sv.Lead__c))
            {
                sv.ownerId = Mapid.get(sv.Lead__c).OwnerId;
            }
        }
    }
    public static void assignToFollowup(List<Follow_up__c> follow)
    {
        set<Id> leadId = new set<Id>(); 
        for(Follow_up__c fw: follow){
            if(fw.Leads__c != null)
            {
               leadId.add(fw.Leads__c); 
            }
        	
        }
        List<Follow_up__c> lst=new List<Follow_up__c>();
        Map<Id,Lead>  Mapid = new Map<Id,Lead>([select OwnerId,No_of_Follow_Up__c,(SELECT Id FROM Follow_ups__r) from Lead where Id in :leadId]);
        for(Follow_up__c fw1: follow){
            if(fw1.Leads__c != null && Mapid.containsKey(fw1.Leads__c))
            {
                fw1.ownerId = Mapid.get(fw1.Leads__c).OwnerId;
            }
            if(fw1.Leads__c != null && Mapid.containsKey(fw1.Leads__c)&&Mapid.get(fw1.Leads__c).No_of_Follow_Up__c>=1)
            {
                lst=Mapid.get(fw1.Leads__c).Follow_ups__r;
                if(lst.size()>0)
                {
                    fw1.Follow_up__c=lst[lst.size()-1].Id;
               }
            }
        }
    }
}