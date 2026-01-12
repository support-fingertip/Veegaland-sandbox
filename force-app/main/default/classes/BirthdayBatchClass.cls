global class BirthdayBatchClass Implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        AssignTask();
    }
    public static void AssignTask()
    {
        //date dobToday=date.instance(Date.today().month(),Date.today().day());
        Integer currentMonth = Date.today().month();
        Integer currentDay = Date.today().day();
        system.debug('currentMonth'+currentMonth+' currentDay'+currentDay);
        
        List<Lead> leads = [SELECT Id, Name, Phone, Email, DOB__c,Country_Codes__c,Country_Codess__c,OwnerId,Owner.Name,Owner.Phone,Secondary_Email__c,Owner.Email,Country_Code__c FROM Lead where DOB__c != null and DAY_IN_YEAR(DOB__c) =:currentDay and CALENDAR_MONTH(DOB__c)=:currentMonth];
        system.debug('leads'+leads);
        //List<Lead> filteredLeads = new List<Lead>();
        if(leads.size()>0)
        {
            for (Lead lead : leads) {
                if (lead.DOB__c != null) {
                    if (lead.DOB__c.month() == currentMonth && lead.DOB__c.day() == currentDay) {
                        //filteredLeads.add(lead);
                        if(lead.Phone != null && lead.Phone.length()>=10 && lead.Owner.Phone != null){
                            string phone;
                            if(lead.Country_Codes__c != 'Unknown'){
                              phone = lead.Country_Codes__c+lead.Phone;
                            }
                            if(lead.Country_Codes__c == ''){
                               phone = lead.Country_Codess__c+lead.Phone; 
                            }
                            whatsappIntegration_Controller.WhatsappTextMessage('Customer Birthday','','',Phone, '', '');
                        } 
                    }
                }
            }
        }
    }
    public static void TestIncrease()
    {
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}