public class leadToSFController {
    public string status{get;set;}
    public void captureLead()
    {
        string Name =   apexpages.currentpage().getparameters().get('Name');
        string mobile = apexpages.currentpage().getparameters().get('mobile'); 
        string email = apexpages.currentpage().getparameters().get('email'); 
        string mobile2 = apexpages.currentpage().getparameters().get('mobile2');
        string project = apexpages.currentpage().getparameters().get('Project');
        string city = apexpages.currentpage().getparameters().get('city');
        string source = apexpages.currentpage().getparameters().get('source');
        string subSource = apexpages.currentpage().getparameters().get('subSource');
        string channelPartnerFirm = apexpages.currentpage().getparameters().get('channelPartnerFirm');
        string channelPartnerEmployeeName = apexpages.currentpage().getparameters().get('channelPartnerEmployeeName');
        string channelPartnerPhone = apexpages.currentpage().getparameters().get('channelPartnerPhone');
        string remarks = apexpages.currentpage().getparameters().get('remarks');
        string Country = apexpages.currentpage().getparameters().get('Country');
        string CountryCode = apexpages.currentpage().getparameters().get('CountryCode');
        string requestBody = 'Name:'+Name+' mobile:'+mobile+' email:'+email+' mobile2:'+mobile2+' project:'+project+' city:'+city+' source:'+source+' subSource:'+subSource+' channelPartnerFirm:'+channelPartnerFirm+' channelPartnerEmployeeName:'+channelPartnerEmployeeName+' channelPartnerPhone:'+channelPartnerPhone+' remarks:'+remarks+' Country:'+Country+' CountryCode:'+CountryCode;    
        List<Apex_Log__c> logList = new List<Apex_Log__c>();
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c = source;
        log.Request__c =requestBody;
        Lead l = new Lead();
        l.LastName = Name;
        l.Phone = mobile;
        l.Email = email;
        l.Leadsource__c = source;
        l.Sub_Source__c = subSource;
        l.Secondary_Phone__c = mobile2;
        l.Allocated_Project__c = project;
        l.City__c = city;
        l.Company = 'abc';
        l.Channel_partner_Name__c = channelPartnerEmployeeName;
        l.Channel_partner_Phone__c = channelPartnerPhone;
        l.Channel_Partner_Firm__c = channelPartnerFirm;
        l.Channel_partner_Name__c = channelPartnerEmployeeName;
        l.Last_Comment__c = remarks;
        l.Country_Name__c = Country;
        l.Country_Code__c =  CountryCode;
        if(isValidPicklistValue(CountryCode))
        {
           l.Country_Code__c =  CountryCode;
        }
        if(Country != null)
        {
            if (isValidPicklistValue(Country)) 
            {
                l.Country__c = Country;
            }  
        }
        try{
             if(source=='Channel partner')
            { 
                List<Lead> ldlst=new List<Lead>();
                ldlst.add(l);
                insert ldlst;
                RelatedSourceHandler.afterinsertLogic(ldlst);
                status = 'SUCCESS';
                log.status__c='SUCCESS';
        
            }
            else
            {
                insert l;
               status = 'SUCCESS';
               log.status__c='SUCCESS'; 
            }
        }catch(exception e){
            
           if(e.getMessage().contains('ENTITY_IS_DELETED'))
           {
             log.status__c='FAILED'; 
             status = 'Lead already existed';
             log.Error_Message__c = status;
           }
            else
            {
            status = 'FAIL '+e.getMessage();
            log.status__c='FAILED';
            log.Error_Message__c = e.getMessage();
            }
            
        } 
        logList.add(log);
        insert logList; 
    } 
    // Method to validate picklist value
    public Boolean isValidPicklistValue(String value) {
        // Get the describe result for the Lead object
        Schema.DescribeSObjectResult leadDescribe = Lead.SObjectType.getDescribe();
        
        // Get the field describe for the Country__c picklist field
        Schema.DescribeFieldResult countryFieldDescribe = leadDescribe.fields.getMap().get('Country__c').getDescribe();
        
        // Check if it's a picklist field
        if (countryFieldDescribe.getType() == Schema.DisplayType.PICKLIST) {
            // Get the picklist values for the Country__c field
            List<Schema.PicklistEntry> picklistValues = countryFieldDescribe.getPicklistValues();
            
            // Loop through picklist values to check if the provided value exists
            for (Schema.PicklistEntry entry : picklistValues) {
                if (entry.getValue().equals(value)) {
                    return true; // Value found, it's valid
                }
            }
        }
        return false; // Value not found, it's invalid
    }
    
}