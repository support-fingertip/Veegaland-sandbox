public without sharing class getSereneQuoteData {
    public Quote__c qout{get;set;}
    public Master_Payment_Schedule__c mps {get;set;}
    public id recid{get;set;}
    public List<WrapperPaymentSchedule> scheduleList { get; set; }
    public Decimal totalDistributedAmount { get; set; }
    public Decimal totalPercent { get; set; }
    public Decimal totalCGSTAmount { get; set; }
    public Decimal totalSGSTAmount { get; set; }
    public Decimal totalAmount { get; set; }
    
    Public getSereneQuoteData(ApexPages.StandardController controller){
        recId = ApexPages.currentPage().getParameters().get('id');
        system.debug('recId >>>>>>>>>>>>>>>>'+recId);
        //  string recordId = controller.getId();
        Quote__c qt = [select Id,GRAND_TOTAL__c,Payment_Plan__c,Actual_Apartment_Cost_Including_Car_Park__c,GST__c from Quote__c where Id=:recId limit 1];  
        //AggregateResult agg = [select sum(Payment_percent__c) perc, sum(Balance_Booking_Advance_Amount__c) amt,Quote__c from Payment_Schedule__c where Quote__c=:recId GROUP BY Quote__c LIMIT 1];
        //totalPercent = (Decimal) agg.get('perc');
        //totalAmount = (Decimal) agg.get('amt');
        
        //qout =[select Id,Booking_Amount__c,(select id ,Name,/*Completed_Date__c,*/Payment_percent__c,Balance_Booking_Advance_Amount__c,S_No__c from Payment_Schedules__r order by S_No__c asc) from Quote__c where Id=:recId limit 1];
        scheduleList = new List<WrapperPaymentSchedule>();
        List<Master_Payment_Schedule__c> schedules = [SELECT Id, Name, Payment_Percent__c,Completed_Date__c,S_No__c
                                                      FROM Master_Payment_Schedule__c 
                                                      WHERE Payment_Plan__c = :qt.Payment_Plan__c AND Combined_Schedule__c = false
                                                      ORDER BY S_No__c ASC];
        
        // Distribute Booking Amount
        totalAmount = qt.Actual_Apartment_Cost_Including_Car_Park__c;
        decimal CGST = 0;
        decimal SGST = 0;
        if(qt.GST__c != null){
            CGST = qt.GST__c/2;
            SGST = qt.GST__c/2;
        }
        Decimal percentage = 0;
        decimal totalDistributed =0;
        decimal totalCGST = 0;
        decimal totalSGST = 0;
        
        date completeddt = null;
        string latestDonePaymentScheduleName = '';
        Date latestDonePaymentScheduleCompletedDate = null;
        decimal slNo = 0;
        decimal sumOfPercentage = 0;
        decimal sumOfAmount = 0.00;
        decimal sumOfCGSTAmount = 0.00;
        decimal sumOfSGSTAmount = 0.00;
        for (Master_Payment_Schedule__c schedule : schedules) {
            Decimal calculatedAmount = (totalAmount * schedule.Payment_Percent__c) / 100;
            decimal CGSTAmount = (calculatedAmount * CGST) / 100;
            decimal SGSTAmount = (calculatedAmount * SGST) / 100;
            //new condition
            if(schedule.S_No__c == 1){
                scheduleList.add(new WrapperPaymentSchedule(schedule.Name, schedule.Payment_Percent__c, schedule.Completed_Date__c, calculatedAmount,schedule.S_No__c, CGSTAmount, SGSTAmount));
            }
            else if(schedule.Completed_Date__c != null && schedule.Completed_Date__c<= System.today()){
                latestDonePaymentScheduleName = 'Till '+schedule.Name;
                latestDonePaymentScheduleCompletedDate = schedule.Completed_Date__c;
                sumOfPercentage += schedule.Payment_Percent__c;
                sumOfAmount += calculatedAmount;
                slNo = schedule.S_No__c;
                sumOfCGSTAmount += CGSTAmount;
                sumOfSGSTAmount += SGSTAmount;
            }
            else{
            scheduleList.add(new WrapperPaymentSchedule(schedule.Name, schedule.Payment_Percent__c, schedule.Completed_Date__c, calculatedAmount, schedule.S_No__c, CGSTAmount, SGSTAmount));
            }
            percentage += schedule.Payment_Percent__c;
            totalDistributed += calculatedAmount;
            totalCGST += CGSTAmount;
            totalSGST += SGSTAmount;
        }
        
        scheduleList.add(new WrapperPaymentSchedule(latestDonePaymentScheduleName, sumOfPercentage, latestDonePaymentScheduleCompletedDate, sumOfAmount, slNo, sumOfCGSTAmount, sumOfSGSTAmount));
        totalPercent = percentage;
        totalDistributedAmount = totalDistributed;
        totalCGSTAmount = totalCGST;
        totalSGSTAmount = totalSGST;
        scheduleList.sort(new SortBySlno());
    }
    
    // Wrapper class to pass data to Visualforce
    public class WrapperPaymentSchedule {
        public String name { get; set; }
        public Decimal percentage { get; set; }
        public Decimal calculatedAmount { get; set; }
        public Decimal CGSTAmount { get; set; }
        public Decimal SGSTAmount { get; set; }
        public date completedDate {get;set;}
        public decimal slNo {get; set;}
        public WrapperPaymentSchedule(String name, Decimal percentage,date completedDate, Decimal calculatedAmount, decimal slNo, decimal CGSTAmount, decimal SGSTAmount) {
            this.name = name;
            this.completedDate = completedDate;
            this.percentage = percentage;
            this.calculatedAmount = calculatedAmount;
            this.slNo = slNo;
            this.CGSTAmount = CGSTAmount;
            this.SGSTAmount = SGSTAmount;
               
        }
        
    }
    //comparator class to sort by slno
    public class SortBySlno implements System.Comparator<WrapperPaymentSchedule> {
        public Integer compare(Object o1, object o2){
            WrapperPaymentSchedule w1 = (WrapperPaymentSchedule) o1;
            WrapperPaymentSchedule w2 = (WrapperPaymentSchedule) o2;
            if(w1.slNo == w2.slNo)
                return 0;
            return (w1.slNo > w2.slNo)? 1 : -1;
        }
    }

}