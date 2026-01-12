public class MobileIntegrationService {
    
    public static String previousPending(Id bookingId) {
        
        // Fetch the booking record using the bookingId
        Booking__c book = [SELECT Id, Name, Permanent_Postal_Code__c, Total_Interest_Waive_Off__c, Debit_Amount__c 
                           FROM Booking__c 
                           WHERE Id = :bookingId LIMIT 1];
        
        if (book == null) {
            // Handle case where no booking record is found
            System.debug('No booking found for the given bookingId: ' + bookingId);
            return 'Booking not found';
        }
        
        // Initialize variables
        String currentCompletedStage = '';
        Date currentCompletedStageDate = null;
        Date demandDueDate = null;
        Decimal currentMilestonePaymentPercent = 0;
        String currentMilestoneNumber = null;
        String totalAmountPayableInWords = 'Zero';
        Decimal balanceDueTillPrevMilestone = 0;
        
        // Fetch the Master Payment Schedule records related to the booking
        List<Master_Payment_Schedule__c> msRecordList = [
            SELECT Id, Name, S_No__c, Completed_Date__c, Payment_percent__c
            FROM Master_Payment_Schedule__c
            WHERE Status__c = 'Completed' AND Id IN (SELECT Master_Payment_Schedule__c FROM Payment_Schedule__c WHERE Booking__c = :book.Id)
            ORDER BY S_No__c DESC
        ];
        
        if (msRecordList.isEmpty()) {
            // Handle case where no milestones are completed
            currentCompletedStage = 'No milestone completed';
            currentCompletedStageDate = null;
            demandDueDate = null;
            currentMilestonePaymentPercent = 0;
            totalAmountPayableInWords = 'Zero';
            
            
            // Optionally, you could log or show a message
            System.debug('No milestone completed for the booking.');
            return '0';
        }
        
        Master_Payment_Schedule__c msRecord = msRecordList[0];
        
        if (msRecord != null) {
            currentCompletedStage = msRecord.Name;
            currentCompletedStageDate = msRecord.Completed_Date__c;
            demandDueDate = System.today().addDays(7);
            currentMilestonePaymentPercent = msRecord.Payment_percent__c != null ? msRecord.Payment_percent__c.setScale(0) : 0;
            
            Decimal stNumber = msRecord.S_No__c;
            
            
            AggregateResult[] aggregateResults = [
                SELECT SUM(Pending_Amount__c) totalPendingAmount, SUM(Interest_Amount__c) totalInterestAmount,
                SUM(AmountB__c) totalPayableAmount,
                SUM(Interest_Up_to_Date__c) totalInterestUplodate, SUM(Interest_Paid__c) totalInterestPaid,
                SUM(Payment_percent__c) paymentPercentageTill
                FROM Payment_Schedule__c
                WHERE Master_Payment_Schedule__r.Status__c = 'Completed' 
                AND Master_Payment_Schedule__r.S_No__c != :msRecord.S_No__c 
                AND Booking__c = :book.Id
            ];
            System.debug('aggregateResults: ' + aggregateResults);
            
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
            Decimal milestonePaymentPercentResult = 0;
            Decimal paidTillPrevMilestone = 0;
            
            if (!aggregateResults.isEmpty()) {
                totalPendingAmount = (Decimal) aggregateResults[0].get('totalPendingAmount') != null ? (Decimal) aggregateResults[0].get('totalPendingAmount') : 0;
                totalInterestAmount = (Decimal) aggregateResults[0].get('totalInterestAmount') != null ? (Decimal) aggregateResults[0].get('totalInterestAmount') : 0;
                totalPayableAmount = (Decimal) aggregateResults[0].get('totalPayableAmount') != null ? (Decimal) aggregateResults[0].get('totalPayableAmount') : 0;
                totalInterestUplodateAmount = (Decimal) aggregateResults[0].get('totalInterestUplodate') != null ? (Decimal) aggregateResults[0].get('totalInterestUplodate') : 0;
                totalInterestPaid = (Decimal) aggregateResults[0].get('totalInterestPaid') != null ? (Decimal) aggregateResults[0].get('totalInterestPaid') : 0;
                milestonePaymentPercent = aggregateResults[0].get('paymentPercentageTill') != null ? (Decimal) aggregateResults[0].get('paymentPercentageTill') : 0;
            }
            
            System.debug('paidPreMilestone: ' + paidPreMilestone);
            Decimal totAmtDueTillPrevMilestone = totalPayableAmount;
            Decimal interestPaidTillPrevious = totalInterestPaid;
            Decimal interestDelayTillPrevious = (totalInterestUplodateAmount > 0) ? (totalInterestUplodateAmount) : totalInterestAmount;
            
            double paidTotalAmount = 0;
            AggregateResult presentDueResult = [
                SELECT SUM(AmountB__c) totalAmountB, SUM(Payment_percent__c) paymentPercentageTill
                FROM Payment_Schedule__c
                WHERE Master_Payment_Schedule__r.S_No__c = :msRecord.S_No__c
                AND Booking__c = :book.Id
            ];
            
            Decimal presentDueAmount = 0;
            if (presentDueResult != null && presentDueResult.get('totalAmountB') != null) {
                presentDueAmount = (Decimal) presentDueResult.get('totalAmountB');
            }
            
            if (presentDueResult != null && presentDueResult.get('paymentPercentageTill') != null) {
                milestonePaymentPercentResult = milestonePaymentPercent + currentMilestonePaymentPercent;
            }
            
            if (book.Total_Interest_Waive_Off__c != null) {
                waveOff = book.Total_Interest_Waive_Off__c;
            }
            
            AggregateResult totalReceived = [
                SELECT SUM(Received_Amount1__c) totalReceivedAmount
                FROM Payment_Schedule__c
                WHERE Booking__c = :book.Id
            ];
            
            if (totalReceived != null && totalReceived.get('totalReceivedAmount') != null) {
                paidTotalAmount = (Decimal) totalReceived.get('totalReceivedAmount');
            }
            
            if (book.Debit_Amount__c != null){
                paidTotalAmount -= book.Debit_Amount__c;
            }
            
            paidTillPrevMilestone = paidTotalAmount;   
            balanceDueTillPrevMilestoneMod = totalPayableAmount - paidTotalAmount;
            
            if (balanceDueTillPrevMilestoneMod > 0) {
                balanceDueTillPrevMilestone = totalPayableAmount - paidTotalAmount;
            }
            
            // Format the balanceDueTillPrevMilestone as currency with comma separators
            
            
        }
        String formattedBalanceDue = balanceDueTillPrevMilestone.format();
   //     String currencyFormatted = 'INR ' + formattedBalanceDue; 
        // Return the formatted balance due
        return formattedBalanceDue;
    }
    
}