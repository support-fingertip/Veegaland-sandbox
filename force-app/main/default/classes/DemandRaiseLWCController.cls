public with sharing class DemandRaiseLWCController {
    public class ProjectPaymentWrapper {
        @AuraEnabled public String projectLabel { get; set; }
        @AuraEnabled public String projectValue { get; set; }
        @AuraEnabled public List<PicklistOption> paymentPlans { get; set; }
    }
    
    public class PicklistOption {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ProjectPaymentWrapper> getProjectAndPaymentPlan() {
        List<ProjectPaymentWrapper> results = new List<ProjectPaymentWrapper>();
        
        for(Project__c prj : [
            SELECT Id, Name, 
            (SELECT Id, Name FROM Payment_Plans__r WHERE Active__c = true) 
            FROM Project__c WHERE Active__c = true
        ]) {
            ProjectPaymentWrapper wrapper = new ProjectPaymentWrapper();
            wrapper.projectLabel = prj.Name;
            wrapper.projectValue = prj.Id;
            wrapper.paymentPlans = new List<PicklistOption>();
            
            for(Payment_Plan__c pp : prj.Payment_Plans__r) {
                PicklistOption opt = new PicklistOption();
                opt.label = pp.Name;
                opt.value = pp.Id;
                wrapper.paymentPlans.add(opt);
            }
            results.add(wrapper);
        }
        return results;
    }
    
    @AuraEnabled
    public static List<Master_Payment_Schedule__c> getMPSRecords(Id selectedPlan, Boolean combSchedueOn) {
        
        String baseQuery = 
            'SELECT Id, S_No__c, Name, Status__c, Completed_Date__c, ' +
            'Project_Name__c, Combined_Schedule__c ' +
            'FROM Master_Payment_Schedule__c ' +
            'WHERE Payment_Plan__c = :selectedPlan ';
        
        if (!combSchedueOn) {
            baseQuery += 'AND Combined_Schedule__c = false ';
        }
        
        baseQuery += 'ORDER BY S_No__c ASC';
        
        List<Master_Payment_Schedule__c> mpSchedules = Database.query(baseQuery);
        
        if (mpSchedules.isEmpty()) {
            System.debug('No Master Payment Schedules Found');
            return new List<Master_Payment_Schedule__c>(); // safer than returning null
        }
        
        return mpSchedules;
    }  
    
    /*@AuraEnabled
    public static List<demandDetails> getPSRecords(Id selectedMPS) {
        
        if(selectedMPS == null){
            system.debug('No payment Plan');
            return null;
        }
        Map<Id,Decimal> bookSlMap = new Map<Id,Decimal>();
        List<Payment_Schedule__c> paymentSchedules = [SELECT Id, Name,S_No__c, Booking__c, Booking__r.Stage__c, Master_Payment_Schedule__c
                                                      FROM Payment_schedule__c WHERE Master_Payment_Schedule__c = :selectedMPS 
                                                      AND Booking__r.Stage__c != 'Cancellation' Order By S_No__c ASC ];
        
        for (Payment_Schedule__c psRec : paymentSchedules) {
            if(!bookSlMap.containsKey(psRec.Booking__c)){
                bookSlMap.put(psRec.Booking__c,psRec.S_No__c);
            }
        }
        
        List<Payment_Schedule__c> bookingPaymentSchedules = [SELECT Id, Name,S_No__c,Booking__c, Booking__r.Name, Booking__r.Plot__r.Name, Booking__r.Stage__c,
                                                      Is_Demanded__c, Serial_Number__c, Booking__r.Total__c, Booking__r.First_Applicant_Name__c,
                                                      Booking__r.Email1__c,Pending_Amount__c,Interest_Amount__c,AmountB__c,Interest_Up_to_Date__c,
                                                      Received_Amount1__c,Interest_Paid__c, Payment_percent__c
                                                      FROM Payment_schedule__c WHERE Booking__c IN : bookSlMap.keySet()  Order By S_No__c ASC ];
        for (Id bkId : bookSlMap.keySet()) {
            Decimal slNo = bookSlMap.get(bkId);
            Decimal currentMilestoneAmount = 0;
            Decimal previousPendings = 0;
            Decimal totalAmount = 0;
            Decimal
            for (Payment_Schedule__c bookPs : bookingPaymentSchedules) {
                
            }
        }
        
        
    }*/
    
    public class MasterScheuleWrapper {
        @AuraEnabled public String slNo { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public Boolean combSchedule { get; set; }
        @AuraEnabled public List<demandDetails> demandList { get; set; }
    }
    
    public class demandDetails {
        @AuraEnabled public String slNo { get; set; }
        @AuraEnabled public String scheduleName { get; set; }
        @AuraEnabled public String bookingId { get; set; }
        @AuraEnabled public String unitNumber { get; set; }
        @AuraEnabled public String customerName { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String project { get; set; }
        @AuraEnabled public Decimal currentMilestoneAmount { get; set; }
        @AuraEnabled public Decimal previousPendings { get; set; }
        @AuraEnabled public Decimal grandTotal { get; set; }
        @AuraEnabled public Boolean isDemanded { get; set; }
        @AuraEnabled public String invoiceNo { get; set; }
    }
    
}