public class MassDeletedLeadController {
    public List<Lead> getIDs{set;get;}
    public MassDeletedLeadController(ApexPages.StandardSetController controller){
        getIDs = controller.getSelected();
    }
    public PageReference massdeleted(){
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
            list<Lead> listLead=[Select Id from Lead where Id in:leadId];
            
            string u = string.valueOf(URL.getSalesforceBaseUrl().getHost());
            List<ListView> listviews = [SELECT Id, Name FROM ListView WHERE SobjectType = 'Lead' and Name='All'];
            
            returnUrl = 'https://'+u+'/lightning/o/Lead/list?filterName='+listviews[0].id;
            system.debug('===='+returnUrl);
            try{
                delete  listLead;
                
            }
            catch(exception e) {
                //  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,e.getMessage()));
                return null;
            }
            
            
            PageReference pgReturnPage=null;
            if(listLead.size()==0){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Select atleast one Lead Record'));
                
            }   
            else{
                pgReturnPage = new PageReference(returnUrl);
                pgReturnPage.setRedirect(true);
            }
            return pgReturnPage;
        }
        
        
    }
}