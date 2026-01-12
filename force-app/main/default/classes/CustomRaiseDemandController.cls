public class CustomRaiseDemandController {
    public Decimal totAmtDueTillPrevMilestone { get; set; }
    public Decimal paidTillPrevMilestone { get; set; }
    public Decimal balanceDueTillPrevMilestone { get; set; }
    public Decimal interestDelayTillPrevious { get; set; }
    public Decimal interestPaidTillPrevious { get; set; }
    public Decimal presentDue { get; set; }
    public String milestoneAmountInWords { get; set; }
    public Decimal balanceInterest { get; set; }
    public Decimal totalAmountPayable { get; set; }
    public String totalAmountPayableInWords { get; set; }
    public String currentCompletedStage { get; set; }
    public Date currentCompletedStageDate { get; set; }
    public String currentMilestoneNumber { get; set; }
    public Date demandDueDate { get; set; }
    public Decimal currentMilestonePaymentPercent { get; set; }
    public Decimal milestonePaymentPercentTill { get; set; }
    public Decimal TDSonePercentage { get; set; }
    public String formattedPin {Get; set;}

    public Decimal totalAmountWithoutInterest { get; set; }
    public Decimal valueOfSupply { get; set; }
    public Decimal landCost { get; set; }
    public Decimal taxableValue { get; set; }
    public Decimal cgst { get; set; }
    public Decimal sgst { get; set; }
    public Id recordId { get; set; }
    public Id paymentScheduledId { get; set; }
    
    public static Map<Integer, String> daySuffixMap = new Map<Integer, String>{1 => 'st', 2 => 'nd', 3 => 'rd', 21 => 'st', 22 => 'nd', 23 => 'rd', 31 => 'st'};
        
        public CustomRaiseDemandController(ApexPages.StandardController controller) {
            
            totAmtDueTillPrevMilestone =0;
            paidTillPrevMilestone =0;
            balanceDueTillPrevMilestone =0;
            interestDelayTillPrevious =0;
            presentDue =0;
            totalAmountPayable =0;
            TDSonePercentage=0;
            interestPaidTillPrevious =0;
            totalAmountWithoutInterest = 0;
            valueOfSupply = 0;
            landCost = 0;
            taxableValue = 0;
            cgst = 0;
            sgst = 0;
            
            paymentScheduledId = ApexPages.currentPage().getParameters().get('PId');
            recordId = ApexPages.currentPage().getParameters().get('Id');
            system.debug('paymentScheduledId'+paymentScheduledId+'  recordId'+recordId);
            if (paymentScheduledId == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Booking record Id is null.'));
                return;
            }
            
            Payment_Schedule__c psRecord = [
                SELECT Id,
                Name,
                S_No__c,
                Completed_Date__c,
                Payment_percent__c,
                Booking__r.Property_Type_For__c,
                Booking__r.Tower__c,
                Booking__c,
                Master_Payment_Schedule__r.S_No__c,
                Master_Payment_Schedule__c
                FROM Payment_Schedule__c
                WHERE Id = :paymentScheduledId
            ];
            Booking__c book = [SELECT Id,Permanent_Postal_Code__c, Interest_Waive_Off__c,Debit_Amount__c,Total__c,GST__c,Finance_User__c, Name, Project__c,Project1__r.Name, Property_Type_For__c, Block__c, Tower__c FROM Booking__c WHERE Id = :psRecord.Booking__c];
            if(book.Permanent_Postal_Code__c !=null){
                formattedPin = String.valueOf((Integer)book.Permanent_Postal_Code__c);
            }
                apartmentScheduleCalculations(psRecord.Id,book);
            /*
            }else if (psRecord.Booking__r.Property_Type_For__c == 'Villas')  {
                villaScheduleCalculations(psRecord.Master_Payment_Schedule__c,book);
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No "Property Type" selected for this booking.'));
                return;
            }*/
        }
    private void apartmentScheduleCalculations(Id masterId,Booking__c book) {
        
        List<Payment_Schedule__c> psRecordList = [
            SELECT Id, S_No__c, Is_Demanded__c, Booking__c,Name,Payment_percent__c,
            Interest_Paid__c,Received_Amount1__c,Completed_Date__c,Interest_Up_to_Date__c,
            AmountB__c,Interest_Amount__c,Pending_Amount__c, Amount__c, Land_Cost__c, 
            Taxable_Value__c, CGST_Amount__c, SGST_Amount__c
            FROM Payment_Schedule__c
            WHERE Id =: masterId
        ];
        
        if (psRecordList.isEmpty()) {
            // Handle case where no milestones are completed
            currentCompletedStage = 'No milestone completed';
            currentCompletedStageDate = null;
            demandDueDate = null;
            currentMilestonePaymentPercent = 0;
            currentMilestoneNumber = null;
            totalAmountPayableInWords = 'Zero';
            return;
        }
        
        Payment_Schedule__c psRecord = psRecordList[0]; 
        
        if (psRecord != null) {
            currentCompletedStage = psRecord.Name;
            currentCompletedStageDate = psRecord.Completed_Date__c;
            demandDueDate = System.today().addDays(7);
            currentMilestonePaymentPercent = psRecord.Payment_percent__c != null ? psRecord.Payment_percent__c.setScale(0) : 0;
            
            Decimal stNumber = psRecord.S_No__c;
            if (stNumber != null) {
                currentMilestoneNumber = getMilestoneLabel(stNumber.intValue());
            }
            
            AggregateResult[] aggregateResults = [
                SELECT SUM(Pending_Amount__c) totalPendingAmount, SUM(Interest_Amount__c) totalInterestAmount,
                SUM(AmountB__c) totalPayableAmount,
                SUM(Interest_Up_to_Date__c) totalInterestUplodateAmount, SUM(Interest_Paid__c) totalInterestPaid,
                SUM(Payment_percent__c) paymentPercentageTill
                FROM Payment_Schedule__c
                WHERE Status__c = 'Completed' 
                AND S_No__c < :psRecord.S_No__c 
                AND Booking__c = :book.Id
            ];
            
            Decimal totalPendingAmount = 0;
            Decimal totalInterestAmount = 0;
            Decimal totalPayableAmount = 0;
            Decimal totalReceivedAmount = 0;
            Decimal paidPreMilestone = 0;
            Decimal totalInterestUplodateAmount = 0;
            Decimal totalInterestPaid = 0;
            Decimal waveOff = 0;
            Decimal milestonePaymentPercent = 0;
            Decimal balanceDueTillPrevMilestoneMod = 0;
            Decimal milestonePaymentPercentResult =0;
            if (!aggregateResults.isEmpty()) {
                totalPendingAmount = (Decimal) aggregateResults[0].get('totalPendingAmount') != null ? (Decimal) aggregateResults[0].get('totalPendingAmount') : 0;
                totalInterestAmount = (Decimal) aggregateResults[0].get('totalInterestAmount') != null ? (Decimal) aggregateResults[0].get('totalInterestAmount') : 0;
                totalPayableAmount = (Decimal) aggregateResults[0].get('totalPayableAmount') != null ? (Decimal) aggregateResults[0].get('totalPayableAmount') : 0;
                totalInterestUplodateAmount = (Decimal) aggregateResults[0].get('totalInterestUplodateAmount') != null ? (Decimal) aggregateResults[0].get('totalInterestUplodateAmount') : 0;
                totalInterestPaid = (Decimal) aggregateResults[0].get('totalInterestPaid') != null ? (Decimal) aggregateResults[0].get('totalInterestPaid') : 0;
                milestonePaymentPercent = aggregateResults[0].get('paymentPercentageTill') != null ? (Decimal) aggregateResults[0].get('paymentPercentageTill') : 0;
            }
            system.debug('paidPreMilestone'+paidPreMilestone);
            totAmtDueTillPrevMilestone = totalPayableAmount;
            interestPaidTillPrevious = totalInterestPaid;
            interestDelayTillPrevious = (totalInterestUplodateAmount > 0) ? (totalInterestUplodateAmount + totalInterestAmount) : totalInterestAmount;
            
            double paidTotalAmount = 0;
            AggregateResult presentDueResult = [
                SELECT SUM(AmountB__c) totalAmountB,SUM(Payment_percent__c) paymentPercentageTill
                FROM Payment_Schedule__c
                WHERE S_No__c = :psRecord.S_No__c
                AND Booking__c = :book.Id
            ];
            Decimal presentDueAmount = 0;
            if (presentDueResult != null && presentDueResult.get('totalAmountB') != null) {
                presentDueAmount = (Decimal) presentDueResult.get('totalAmountB');
            }
            if (presentDueResult != null && presentDueResult.get('paymentPercentageTill') != null) {
                milestonePaymentPercentResult = milestonePaymentPercent + currentMilestonePaymentPercent;
            }
           
            if (book.Interest_Waive_Off__c != null) {
                waveOff = book.Interest_Waive_Off__c;
            }
            
            AggregateResult totalReceied = [
                SELECT SUM(Received_Amount1__c) totalReceivedAmount
                FROM Payment_Schedule__c
                WHERE Booking__c = :book.Id
            ];
            
            if (totalReceied != null && totalReceied.get('totalReceivedAmount') != null) {
                paidTotalAmount = (Decimal) totalReceied.get('totalReceivedAmount');
            }
            if (book.Debit_Amount__c != null){
                paidTotalAmount-= book.Debit_Amount__c;
            }
            
            paidTillPrevMilestone =  paidTotalAmount;
            if(psRecord.S_No__c == 1){
                paidTotalAmount = 0;
            }
            balanceDueTillPrevMilestoneMod = totalPayableAmount - paidTotalAmount;
            if(balanceDueTillPrevMilestoneMod > 0){
                balanceDueTillPrevMilestone = totalPayableAmount - paidTotalAmount;
            }
            milestonePaymentPercentTill = milestonePaymentPercentResult.setScale(0);
            
            presentDue = presentDueAmount.setScale(0);
            
            Decimal gstPercentage = (book.GST__c != null) ? book.GST__c / 100 : 0;
            Decimal amountExcludingGST = presentDue / (1 + gstPercentage);
            TDSonePercentage = paidTotalAmount > 4999999 ? (amountExcludingGST * 0.01).setScale(0): 0;

            balanceInterest = interestDelayTillPrevious - waveOff -interestPaidTillPrevious;
            
            double totalAmount = 0;
            
            Decimal calculatedAmountWithoutInterest = balanceDueTillPrevMilestoneMod + presentDue - TDSonePercentage;
            if (calculatedAmountWithoutInterest > 0) {
                totalAmountWithoutInterest = calculatedAmountWithoutInterest.setScale(0);
            } else {
                totalAmountWithoutInterest = 0;
            }            
            if (presentDue != null && presentDue > 0) {
                valueOfSupply = (psRecord.Amount__c != null) ? psRecord.Amount__c : 0;
                landCost = (psRecord.Land_Cost__c != null) ? psRecord.Land_Cost__c : 0;
                taxableValue  = (psRecord.Taxable_Value__c != null) ? psRecord.Taxable_Value__c : 0;
                cgst = (psRecord.CGST_Amount__c != null) ? psRecord.CGST_Amount__c : 0;
                sgst = (psRecord.SGST_Amount__c != null) ? psRecord.SGST_Amount__c : 0;
            }
            
            
            totalAmount = (balanceDueTillPrevMilestoneMod + balanceInterest + presentDue - TDSonePercentage).setScale(0) ;
            
            if(totalAmount > -1){
                totalAmountPayable = totalAmount;
            }
            
            NumberTOWordConvertion convert = new NumberTOWordConvertion();
            if (totalAmountPayable != null && totalAmountPayable > -1) {
                totalAmountPayableInWords = convert.getNumberTOWordConvertion(totalAmountPayable);
            }
            if (presentDue != null && presentDue > -1) {
                milestoneAmountInWords = convert.getNumberTOWordConvertion(presentDue);
            }
        }
    }
    /*
    private void villaScheduleCalculations(Id masterId,Booking__c book) {
        
        List<Payment_Schedule__c> psRecordList = [
            SELECT Id, Name, S_No__c, Completed_Date__c, Payment_percent__c
            FROM Payment_Schedule__c
            WHERE Status__c = 'Completed' AND Booking__c = :book.Id
            ORDER BY S_No__c DESC LIMIT 1
        ];
        if (psRecordList.isEmpty()) {
            // Handle case where no milestones are completed
            currentCompletedStage = 'No milestone completed';
            currentCompletedStageDate = null;
            demandDueDate = null;
            currentMilestonePaymentPercent = 0;
            currentMilestoneNumber = null;
            totalAmountPayableInWords = 'Zero';
            
            // Optionally, you could log or show a message
            System.debug('No milestone completed for the booking.');
            return;
        }
        
        Payment_Schedule__c psRecord = psRecordList[0]; 
        
        if (psRecord != null) {
            currentCompletedStage = psRecord.Name;
            currentCompletedStageDate = psRecord.Completed_Date__c;
            demandDueDate = System.today().addDays(7);
            currentMilestonePaymentPercent = psRecord.Payment_percent__c != null ? psRecord.Payment_percent__c.setScale(0) : 0;
            
            Decimal stNumber = psRecord.S_No__c;
            if (stNumber != null) {
                currentMilestoneNumber = getMilestoneLabel(stNumber.intValue());
            }
            
            AggregateResult[] aggregateResults = [
                SELECT SUM(Pending_Amount__c) totalPendingAmount, 
                SUM(Interest_Amount__c) totalInterestAmount,
                SUM(AmountB__c) totalPayableAmount,
                SUM(Interest_Up_to_Date__c) totalInterestUplodateAmount, 
                SUM(Interest_Paid__c) totalInterestPaid,
                SUM(Payment_percent__c) paymentPercentageTill
                FROM Payment_Schedule__c
                WHERE Status__c = 'Completed' 
                AND S_No__c != :psRecord.S_No__c 
                AND Booking__c = :book.Id
            ];
            
            Decimal totalPendingAmount = 0;
            Decimal totalInterestAmount = 0;
            Decimal totalPayableAmount = 0;
            Decimal paidPreMilestone = 0;
            Decimal totalInterestUplodateAmount = 0;
            Decimal totalInterestPaid = 0;
            Decimal waveOff = 0;
            Decimal milestonePaymentPercent =0;
            Decimal balanceDueTillPrevMilestoneMod = 0;
            if (!aggregateResults.isEmpty()) {
                totalPendingAmount = (Decimal) aggregateResults[0].get('totalPendingAmount') != null ? (Decimal) aggregateResults[0].get('totalPendingAmount') : 0;
                totalInterestAmount = (Decimal) aggregateResults[0].get('totalInterestAmount') != null ? (Decimal) aggregateResults[0].get('totalInterestAmount') : 0;
                totalPayableAmount = (Decimal) aggregateResults[0].get('totalPayableAmount') != null ? (Decimal) aggregateResults[0].get('totalPayableAmount') : 0;
                totalInterestUplodateAmount = (Decimal) aggregateResults[0].get('totalInterestUplodateAmount') != null ? (Decimal) aggregateResults[0].get('totalInterestUplodateAmount') : 0;
                totalInterestPaid = (Decimal) aggregateResults[0].get('totalInterestPaid') != null ? (Decimal) aggregateResults[0].get('totalInterestPaid') : 0;
                milestonePaymentPercent = (Decimal) aggregateResults[0].get('paymentPercentageTill') != null ? (Decimal) aggregateResults[0].get('paymentPercentageTill') : 0;
            }
            
            totAmtDueTillPrevMilestone = totalPayableAmount;
            interestPaidTillPrevious = totalInterestPaid;
            interestDelayTillPrevious = (totalInterestUplodateAmount > 0) ? (totalInterestUplodateAmount + totalInterestAmount) : totalInterestAmount;
            
            double paidTotalAmount = 0;
            AggregateResult presentDueResult = [
                SELECT SUM(AmountB__c) totalAmountB,
                SUM(Payment_percent__c) paymentPercentageTill
                FROM Payment_Schedule__c
                WHERE S_No__c = :psRecord.S_No__c
                AND Booking__c = :book.Id
            ];
            
            Decimal presentDueAmount = 0;
            if (presentDueResult != null && presentDueResult.get('totalAmountB') != null) {
                presentDueAmount = (Decimal) presentDueResult.get('totalAmountB');
            }
            presentDue = presentDueAmount;
            TDSonePercentage = presentDue * 0.01;
            balanceInterest = interestDelayTillPrevious - waveOff - interestPaidTillPrevious;
            if (presentDueResult != null && presentDueResult.get('paymentPercentageTill') != null) {
                milestonePaymentPercent = milestonePaymentPercent + (Decimal) presentDueResult.get('paymentPercentageTill');
            }
            if (book.Interest_Waive_Off__c != null) {
                waveOff = book.Interest_Waive_Off__c;
            }
             AggregateResult totalReceied = [
                SELECT SUM(Received_Amount1__c) totalReceivedAmount
                FROM Payment_Schedule__c
                WHERE Booking__c = :book.Id
            ];
            
            if (totalReceied != null && totalReceied.get('totalReceivedAmount') != null) {
                paidTotalAmount = (Decimal) totalReceied.get('totalReceivedAmount');
            }
            if (book.Debit_Amount__c != null){
                paidTotalAmount-= book.Debit_Amount__c;
            }
            paidTillPrevMilestone =  paidTotalAmount;          
            balanceDueTillPrevMilestoneMod = totalPayableAmount - paidTotalAmount;
            if(balanceDueTillPrevMilestoneMod > 0){
                balanceDueTillPrevMilestone = totalPayableAmount - paidTotalAmount;
            }
            milestonePaymentPercentTill = milestonePaymentPercent.setScale(0);
            
            double totalAmount = (balanceDueTillPrevMilestoneMod + (interestDelayTillPrevious - waveOff - interestPaidTillPrevious) + presentDue).setScale(0);
            
            if(totalAmount > -1){
                totalAmountPayable = totalAmount;
            }
            
            NumberTOWordConvertion convert = new NumberTOWordConvertion();
            
            if (totalAmountPayable != null && totalAmountPayable > -1) {
                totalAmountPayableInWords = convert.getNumberTOWordConvertion(totalAmountPayable);
            }
        }
    }*/
    public static String getMilestoneLabel(Integer sNo) {
        if (sNo == null) {
            return 'Invalid milestone';
        }
        // Determine the suffix, default to 'th'
        String suffix = daySuffixMap.containsKey(sNo) ? daySuffixMap.get(sNo) : 'th';
        
        return sNo + suffix;
    }
}