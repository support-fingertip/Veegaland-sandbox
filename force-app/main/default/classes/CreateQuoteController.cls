public class CreateQuoteController {
    @AuraEnabled
    public static List<Plot__c> getPlots(string project){
       // system.debug('recId:' + recId);
        //list<Lead__c>clist=[select id ,Project_Name1__c,Project_Name1__r.Name from Lead__c where id =:recId ];
       // list<Lead>clist=[select id ,Allocated_Project__c from Lead where id =:recId ];
        //string project=clist[0].Project_Name1__r.Name;
      //  string project=clist[0].Allocated_Project__c;
        system.debug('Project Name'+project);
        List<Plot__c>plotList=new List<Plot__c>();
        
        string obj='Plot__c';
        plotList = [select Id,Name,Project__r.Name,Project__r.Property_Type__c,Plot_Number__c,Plot_Size__c,Unit_Facing_Direction__c,Landscape_Charge__c,Additional_Car_Parking__c,Floor__c,No_of_Back_to_Back_Car_Parking__c,No_of_Indivisual_Car_Parking__c,
                    BHK_Type__c,Basic_Price__c,Corner_Facing__c,East_Facing__c,Sale_Area__c,Club_House__c,Car_Parking_Charge__c,Infrastructure_Charges_per_sqft__c,Floor_Rise__c,
                    Terrace_Area_SqFt__c,Garden_Area_SqFt__c,Land_Plot_Area_SqFt__c,Common_Area_SqFt__c,RERA_Area_SqFt__c,Open_Terrace_Area_Charges__c,Project__c,
                    Super_built_up_area__c,Built_up_area__c,Carpet_Area__c,Terrace_Area__c,GST1__c,Building__c,Block__c,Project__r.Project__c from Plot__c where Project__r.Name =:project and Status__c = 'Available' order by Unit_Number__c,Name asc ];
        
        system.debug('recId:' + plotList);
        return plotList;
    }
    @AuraEnabled
    public static List<Payment_Plan__c> getPyamentPlan(string project){
        
       // list<Lead>clist=[select id ,Allocated_Project__c from Lead where id =:recId ];
        
       // string project=clist[0].Allocated_Project__c;
        
        return [select id, Name,Project__c,Active__c, Project__r.Project__c  from Payment_Plan__c where Active__c =true And Project__r.Project__c=:project];
        
    }
    @AuraEnabled
    public static List<String> getPicklistValues(String objectName, String fieldName) {
        List<String> picklistValues = new List<String>();
        
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        if (objectType != null) {
            Schema.DescribeFieldResult fieldDescribe = objectType.getDescribe().fields.getMap().get(fieldName).getDescribe();
            if (fieldDescribe.getType() == Schema.DisplayType.PICKLIST) {
                List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
                for (Schema.PicklistEntry picklistEntry : picklistEntries) {
                    picklistValues.add(picklistEntry.getLabel());
                }
            }
        }
        system.debug(picklistValues);
        return picklistValues;
        
    }
    @AuraEnabled
    public static String saveOppPlot(Quote__c oppPlot) {
        try {
            System.debug('oppPlot: ' + oppPlot);
            insert oppPlot;
            System.debug('------- Inserted with Id: ' + oppPlot.Id);
            return oppPlot.Id;
        } catch (Exception e) {
            System.debug('Error inserting Quote__c: ' + e.getMessage());
            // Return the error message to the Aura component
            return 'ERROR: ' + e.getMessage();
        }
    }

    @AuraEnabled
    public static void submitapproval(string quoteId){
        
        //Quote__c qt = [SELECT Id,Name,Approval_status__c,GRAND_TOTAL__c,Project__c,Unit__c,Payment_Type__c,Quote_status__c FROM Quote__c WHERE Id=:quoteId];
        /*if(qt.Quote_status__c=='Drafted'){
if(qt.Approval_status__c!='Approved' && qt.Approval_status__c!='Pending'){
List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();

Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
req.setObjectId(quoteId);

requests.add(req);

Approval.ProcessResult[] processResults = Approval.process(requests);
}

}
else{
qt.Approval_status__c ='Approved';*/
        //update qt;
        //}
        
    }
    
    @AuraEnabled
    public static List<String> getPaymentTypePicklistValues() {
        List<String> paymentTypeValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Quote__c.Payment_Type__c.getDescribe();
        
        for (Schema.PicklistEntry picklistEntry : fieldResult.getPicklistValues()) {
            paymentTypeValues.add(picklistEntry.getLabel());
        }
        
        return paymentTypeValues;
    }
    
    @AuraEnabled
    public static databox getPaymentSchedules(String Pay, String Project){
        //system.debug('hi');
        databox db = new databox();
        List<Payment_schedule__c> schdules = new List<Payment_schedule__c>();
        list<Payment_Plan__c> pymntsch = [select id, Name,(select id,Project__C,S_No__c,Name,Payment_Percent__c,/*Completed_Date__c,*/Completed__c from Master_payment_schedules__r ORDER BY S_No__c ASC) from Payment_Plan__c where Id =: Pay ];
        Map<string,List<Master_payment_schedule__c>> masters = new Map<string,List<Master_payment_schedule__c>>();
        for(Payment_Plan__c prj : pymntsch){
            if(prj.Master_payment_schedules__r.size()>0){
                masters.put(prj.Id, prj.Master_payment_schedules__r);
            }
        }
        if(pymntsch.size()>0){
            if(masters.containskey(pymntsch[0].Id)){
                for(Master_payment_schedule__c mps : masters.get(pymntsch[0].Id)){
                    Payment_schedule__c ps = new Payment_schedule__c();
                    ps.Master_Payment_Schedule__c = mps.Id;
                    ps.Payment_percent__c = mps.Payment_Percent__c;
                    ps.Name = mps.Name;
                    ps.S_No__c = mps.S_No__c;
                  //  ps.Completed_Date__c=mps.Completed_Date__c;
                    ps.Completed__c=mps.Completed__c;
                    //       ps.Amount__c = (db.grandTotal * mps.Payment_Percent__c)/100;
                    
                    //system.debug(ps.Amount__c);
                    //ps.Amount__c = ps.Amount__c.setScale(2);
                    
                    schdules.add(ps);
                    
                }
            }
            db.payList = schdules;
            db.paymentSum = 0.00;
            db.totalPercent = 0;  
            db.RecivedAmount=0;
            db.RecivedAmountTotal=0;
            db.RecivedPercent=0;
            db.scheduledAmount=0;
            db.projectName = Project;
            system.debug('inside');
            
        }  
        else{
            db.payList = schdules;
            db.paymentSum = 0.00;
            db.totalPercent = 0;
            db.RecivedAmount=0;
            db.RecivedAmountTotal=0;
            db.RecivedPercent=0;
            db.scheduledAmount=0;
            
        }
        
        
        
        List<Master_payment_schedule__c> Master;
        string paymentType;
        /*  
if(Pay =='Standard'){
system.debug('Pay : '+ Pay);
system.debug('Project : '+ Project);


Master=[select id,Project__C,S_No__c,Name,Payment_Percent__c from Master_payment_schedule__c where Project__r.Name =:Project ORDER BY S_No__c ASC];
system.debug('Master : '+ Master);
//system.debug(Master[0]);

for(Master_payment_schedule__c mps : Master){
system.debug('Inside Master Payment For Loop');
Payment_schedule__c ps = new Payment_schedule__c();
ps.Master_Payment_Schedule__c = mps.Id;
ps.Payment_percent__c = mps.Payment_Percent__c;
ps.Name = mps.Name;
ps.S_No__c = mps.S_No__c;
//       ps.Amount__c = (db.grandTotal * mps.Payment_Percent__c)/100;

system.debug(ps.Amount__c);
//ps.Amount__c = ps.Amount__c.setScale(2);

schdules.add(ps); 
}
//db.MasterpayList = Master;
db.payList = schdules;
db.paymentSum = 0.00;
db.totalPercent = 0;  
db.RecivedAmount=0;
db.RecivedAmountTotal=0;
db.RecivedPercent=0;
db.scheduledAmount=0;
system.debug('inside');
}
else 
{
db.payList = schdules;
db.paymentSum = 0.00;
db.totalPercent = 0;
db.RecivedAmount=0;
db.RecivedAmountTotal=0;
db.RecivedPercent=0;
db.scheduledAmount=0;


} 
if(schdules.size()>0 && Pay=='Custom'){


for(Payment_schedule__c ps : schdules){
system.debug(ps.Amount1__c);
db.paymentSum=0.00;
db.paymentSum += ps.Amount1__c;
if(ps.Received_Amount__c ==null){
ps.Received_Amount__c=0;
}
if(ps.Recived_Per__c ==null){
ps.Recived_Per__c=0;
}
db.RecivedAmountTotal +=ps.Received_Amount__c;
system.debug('ps.Payment_percent__c'+ps.Payment_percent__c);
system.debug('db.totalPercent'+db.totalPercent);

db.totalPercent += ps.Payment_percent__c;
system.debug('db.totalPercent'+db.totalPercent);

//db.RecivedAmount +=ps.Received_Amount__c;


}
}
if(db.payList.size()==0){
db.payList = null;
}
*/
        system.debug(db.paymentSum); 
        system.debug(db); 
        
        return db;
    }
    
    public class databox{
        @AuraEnabled
        public List<Payment_schedule__c> payList;
        @AuraEnabled
        public List<Master_payment_schedule__c> MasterpayList;
        @AuraEnabled
        public Decimal grandTotal;
        @AuraEnabled
        public Decimal paymentSum;
        @AuraEnabled
        public Decimal RecivedAmountTotal;
        @AuraEnabled
        public Decimal totalPercent;
        @AuraEnabled
        public Decimal RecivedAmount;
        @AuraEnabled
        public string objectName;
        @AuraEnabled
        public string projectName;
        @AuraEnabled
        public string flatNumber;
        @AuraEnabled
        public Decimal RecivedPercent;
        @AuraEnabled
        public Decimal ScheduledAmount;
        @AuraEnabled
        public Decimal TotalOutStandingDueAmount;
        @AuraEnabled
        public Decimal TotalPaidAmount;
    }
    /*
    @AuraEnabled
    public static void insertSchedules(List<Payment_schedule__c> payList,string quoteid){
        
        List<Payment_schedule__c> schduleList = new List<Payment_schedule__c>();
        List<Payment_schedule__c> completedschduleList = new List<Payment_schedule__c>();
        String id;
        Decimal totalPercentage = 0;
        
      /*  if(quoteid!=null){
            for(Payment_schedule__c mps : payList){
                if( mps.Completed_Date__c>=System.today()||mps.Completed_Date__c==null){
                    Payment_schedule__c ps = new Payment_schedule__c();
                    ps = mps;
                    ps.Quote__c = quoteid;
                    schduleList.add(ps);
                }
                else {
                  
                         completedschduleList.add(mps);
                }
            }
            
            if(completedschduleList.size()>0){
                totalPercentage = calculateTotalPercentage(completedschduleList);
                id=quoteid;
                
            }
            if(totalPercentage!=null){
                Payment_schedule__c completedPs = new Payment_schedule__c();
                completedPs.Name = 'As Per the Current Work Status';
                completedPs.S_No__c=2;
                completedPs.Completed_Date__c=System.Today();
                completedPs.Payment_percent__c=totalPercentage;
                completedPs.Quote__c =id ;
                schduleList.add(completedPs);     
            }
            if(schduleList.size()>0){
                insert schduleList;
            }
            
        }
       
    }
    public static Decimal calculateTotalPercentage(List<Payment_schedule__c> masterSchedules) {
        Decimal totalPercentage = 0;
        for (Payment_schedule__c mps : masterSchedules) {
         
                totalPercentage += mps.Payment_Percent__c;
            
        }
        return totalPercentage;
    }*/
}