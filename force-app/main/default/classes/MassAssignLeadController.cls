public class MassAssignLeadController {
    public List<Lead> getIDs{set;get;}
    public MassAssignLeadController(ApexPages.StandardSetController controller){
        getIDs = controller.getSelected();
        system.debug(getIDs);
    }
    public PageReference massassign(){
        System.debug('Inside method ');
        Id profileId=userinfo.getProfileId();
        list<Profile> profileName=[Select Id,Name from Profile where Name!='Sales executive' and Id=:profileId];
        system.debug('profileName'+profileName);
        string returnUrl;
        if(profileName.size()==0)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The user can not have delete permission.'));
            return null;
        }
        else{
            set<Id> leadId = new set<Id>();
            for(Lead l : getIDs){
                leadId.add(l.id);  
            }
            //fetch available users
            List<User> availableUsers = [select Id,Name from User where isActive=true and Availability__c=true and Working__c=true and Profile.Name='Sales executive'];
            system.debug('availableUsers'+availableUsers);
            List<Lead> recordsToUpdate = new List<Lead>();
            if(availableUsers.size()>0){
                // Calculate number of records to assign to each user
                Integer recordsPerUser =  getIDs.size()/ availableUsers.size();
                Integer remainingRecords = Math.mod(getIDs.size(), availableUsers.size());
                // Retrieve the records to be assigned (replace this with your query)
                List<Lead> recordsToAssign = [select id,Name from Lead where id IN :leadId];
                Integer index = 0;
                
                for(User u : availableUsers) {
                    Integer recordsToAssignToThisUser = recordsPerUser;  
                    // Distribute any remaining records  
                    if(remainingRecords > 0) {
                        recordsToAssignToThisUser++;
                        remainingRecords--;
                    } 
                    // Assign records to this user
                    
                    for(Integer i = 0; i < recordsToAssignToThisUser && index < recordsToAssign.size(); i++) {
                        recordsToAssign[index].OwnerId = u.Id;
                        recordsToUpdate.add(recordsToAssign[index]);
                        index++;
                    }
                    
                }
                try{
                // Update records
                update recordsToUpdate;
                
            }
            catch(exception e) {
                   //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There are no active sales executives.'));
                  //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,e.getMessage()));
                return null;
            }
            }
            /*else{
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There are no active sales executives.'));
            }*/
            string u = string.valueOf(URL.getSalesforceBaseUrl().getHost());
            List<ListView> listviews = [SELECT Id, Name FROM ListView WHERE SobjectType = 'Lead' and Name='All'];
            
            returnUrl = 'https://'+u+'/lightning/o/Lead/list?filterName='+listviews[0].id;
            system.debug('===='+returnUrl);
            
            
            
            PageReference pgReturnPage=null;
            if(getIDs.size()==0){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Select atleast one Lead Record'));
                
            } 
            else if(recordsToUpdate.size()==0){
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There are no active sales executives.')); 
            }
            else{
                pgReturnPage = new PageReference(returnUrl);
                pgReturnPage.setRedirect(true);
            }
            return pgReturnPage;
        }
        
        
    }
}