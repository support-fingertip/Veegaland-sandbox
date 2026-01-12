public with sharing class DemandCalculatonController {
    
    public static Map<Integer, String> daySuffixMap = new Map<Integer, String>{1 => 'st', 2 => 'nd', 3 => 'rd', 21 => 'st', 22 => 'nd', 23 => 'rd', 31 => 'st'};
        
        @AuraEnabled(cacheable=true)
        public static BookingDemandWrapper getRaiseDemandWithBooking(Id bookingId) {
            BookingDemandWrapper fullWrapper = new BookingDemandWrapper();
            
            Decimal totAmtDueTillPrevMilestone = 0;
            Decimal paidTillPrevMilestone = 0;
            Decimal balanceDueTillPrevMilestone = 0;
            Decimal interestDelayTillPrevious = 0;
            Decimal interestPaidTillPrevious = 0;
            Decimal presentDue = 0;
            Decimal balanceInterest = 0;
            Decimal totalAmountPayable = 0;
            String totalAmountPayableInWords;
            String currentCompletedStage;
            Date currentCompletedStageDate;
            String currentMilestoneNumber;
            Date demandDueDate;
            Decimal currentMilestonePaymentPercent = 0;
            Decimal milestonePaymentPercentTill = 0;
            Decimal TDSonePercentage = 0;
            Boolean isRaised = false;
            String milestoneAmountInWords ='';
            
            // Fetch Booking record
            Booking__c book = [
                SELECT Id, Name, Total_Interest_Waive_Off__c,Project1__r.IFSC_CODE__c, Project1__r.Bank_Name__c,
                Project1__r.Beneficiary_Account_No__c,Project1__r.Branch_Name__c,
                Payment_plan__r.Post_OC_Completion_Plan__c, Debit_Amount__c, GST__c,Plot__r.Name,
                Project1__r.Name,First_Applicant_Name__c,salutation_Applicant1__c
                FROM Booking__c
                WHERE Id = :bookingId
                LIMIT 1
            ];
            fullWrapper.booking = book;
            fullWrapper.PostOC = book.Payment_plan__r.Post_OC_Completion_Plan__c;
            
            if (book.Project1__r != null) {
                fullWrapper.projectIfscCode = (book.Project1__r.IFSC_CODE__c == null) ? '' : book.Project1__r.IFSC_CODE__c;
                fullWrapper.projectBranchName = (book.Project1__r.Branch_Name__c == null) ? '' : book.Project1__r.Branch_Name__c;
                fullWrapper.projectBankName = (book.Project1__r.Bank_Name__c == null) ? '' : book.Project1__r.Bank_Name__c;
                fullWrapper.projectBeneficiaryAccountNo = (book.Project1__r.Beneficiary_Account_No__c == null) ? '' : book.Project1__r.Beneficiary_Account_No__c;
            } else {
                fullWrapper.projectIfscCode = '';
                fullWrapper.projectBranchName = '';
                fullWrapper.projectBankName = '';
                fullWrapper.projectBeneficiaryAccountNo = '';
            }
            
            RaiseDemandWrapper wrapper = new RaiseDemandWrapper();
            
            list<Master_Payment_Schedule__c> msRecordList = [
                SELECT Id, Name, S_No__c, Completed_Date__c, Payment_percent__c
                FROM Master_Payment_Schedule__c
                WHERE Status__c = 'Completed' AND Id IN (SELECT Master_Payment_Schedule__c FROM Payment_Schedule__c WHERE Booking__c = :book.Id)
                ORDER BY S_No__c DESC
            ];
            
            if (msRecordList.isEmpty()) {
                // Handle case where no milestones are completed
                wrapper.currentCompletedStage = 'No milestone completed';
                wrapper.currentCompletedStageDate = null;
                wrapper.demandDueDate = null;
                wrapper.currentMilestonePaymentPercent = 0;
                wrapper.currentMilestoneNumber = null;
                wrapper.totalAmountPayable = 0;
                wrapper.totalAmountPayableInWords = 'Zero';
                
                fullWrapper.raiseDemandDetails = wrapper;
                return fullWrapper;
                
            }
            
            Master_Payment_Schedule__c msRecord = msRecordList[0]; 
            
            if (msRecord != null) {
                
                list<Payment_schedule__c> currentMilestone = [SELECT id, Name,Is_Demanded__c FROM Payment_schedule__c WHERE Master_Payment_Schedule__c =:msRecord.Id AND Booking__c=:book.Id Limit 1 ];
                if (currentMilestone.size() > 0) {
                    isRaised = currentMilestone[0].Is_Demanded__c;
                }
                currentCompletedStage = msRecord.Name;
                currentCompletedStageDate = msRecord.Completed_Date__c;
                demandDueDate = System.today().addDays(7);
                currentMilestonePaymentPercent = msRecord.Payment_percent__c != null ? msRecord.Payment_percent__c.setScale(0) : 0;
                
                Decimal stNumber = msRecord.S_No__c;
                if (stNumber != null) {
                    currentMilestoneNumber = getMilestoneLabel(stNumber.intValue());
                }
                
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
                system.debug('aggregateResults'+aggregateResults);
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
                    totalInterestUplodateAmount = (Decimal) aggregateResults[0].get('totalInterestUplodate') != null ? (Decimal) aggregateResults[0].get('totalInterestUplodate') : 0;
                    totalInterestPaid = (Decimal) aggregateResults[0].get('totalInterestPaid') != null ? (Decimal) aggregateResults[0].get('totalInterestPaid') : 0;
                    milestonePaymentPercent = aggregateResults[0].get('paymentPercentageTill') != null ? (Decimal) aggregateResults[0].get('paymentPercentageTill') : 0;
                }
                system.debug('paidPreMilestone'+paidPreMilestone);
                totAmtDueTillPrevMilestone = totalPayableAmount;
                interestPaidTillPrevious = totalInterestPaid;
                interestDelayTillPrevious = (totalInterestUplodateAmount > 0) ? (totalInterestUplodateAmount) : totalInterestAmount;
                
                double paidTotalAmount = 0;
                AggregateResult presentDueResult = [
                    SELECT SUM(AmountB__c) totalAmountB,SUM(Payment_percent__c) paymentPercentageTill
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
                milestonePaymentPercentTill = milestonePaymentPercentResult.setScale(0);
                presentDue = presentDueAmount;
                
                Decimal gstPercentage = (book.GST__c != null) ? book.GST__c / 100 : 0;
                Decimal amountExcludingGST = presentDue / (1 + gstPercentage);
                TDSonePercentage = paidTotalAmount > 4999999 ? (amountExcludingGST * 0.01).setScale(0): 0;
                
                balanceInterest = interestDelayTillPrevious - interestPaidTillPrevious - waveOff;
                
                double totalAmount = 0;
                system.debug('balanceDueTillPrevMilestoneMod'+balanceDueTillPrevMilestoneMod+' balanceInterest'+balanceInterest+' presentDue'+presentDue+' TDSonePercentage'+TDSonePercentage);
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
            
            wrapper.totAmtDueTillPrevMilestone = totAmtDueTillPrevMilestone;
            wrapper.paidTillPrevMilestone = paidTillPrevMilestone;
            wrapper.balanceDueTillPrevMilestone = balanceDueTillPrevMilestone;
            wrapper.interestDelayTillPrevious = interestDelayTillPrevious;
            wrapper.interestPaidTillPrevious = interestPaidTillPrevious;
            wrapper.presentDue = presentDue;
            wrapper.balanceInterest = balanceInterest;
            wrapper.totalAmountPayable = totalAmountPayable;
            wrapper.totalAmountPayableInWords = totalAmountPayableInWords;
            wrapper.currentCompletedStage = currentCompletedStage;
            wrapper.currentCompletedStageDate = currentCompletedStageDate;
            wrapper.currentMilestoneNumber = currentMilestoneNumber;
            wrapper.demandDueDate = demandDueDate;
            wrapper.currentMilestonePaymentPercent = currentMilestonePaymentPercent;
            wrapper.milestonePaymentPercentTill = milestonePaymentPercentTill;
            wrapper.TDSonePercentage = TDSonePercentage;
            wrapper.isDemanded = isRaised;
            wrapper.milestoneAmountInWords = milestoneAmountInWords;
            
            fullWrapper.raiseDemandDetails = wrapper;
            return fullWrapper;
        }
    @AuraEnabled
    public Static String RaiseDemand(List<Id> bookingIds, Map<Id,String> emailContents, map<Id,List<String>> contentIds,Map<Id,String> invoiceNumbers ) {
        return DemandRaisedSave.RaiseDemand(bookingIds,emailContents,contentIds, invoiceNumbers);
    }
    
    public static String getMilestoneLabel(Integer sNo) {
        if (sNo == null) {
            return 'Invalid milestone';
        }
        
        // Determine the suffix for the number
        String suffix = getOrdinalSuffix(sNo);
        
        return sNo + suffix;
    }
    
    public static String getOrdinalSuffix(Integer num) {
        // Get the last two digits to handle the 11th, 12th, and 13th cases
        Integer lastTwoDigits = num - (num / 100) * 100;
        
        // Handle special cases for 11th, 12th, 13th (since these don't follow the normal pattern)
        if (lastTwoDigits == 11 || lastTwoDigits == 12 || lastTwoDigits == 13) {
            return 'th';
        }
        
        // Get the last digit for general cases
        Integer lastDigit = num - (num / 10) * 10;
        
        // Handle other numbers based on the last digit
        if (lastDigit == 1) {
            return 'st';
        } else if (lastDigit == 2) {
            return 'nd';
        } else if (lastDigit == 3) {
            return 'rd';
        } else {
            return 'th';
        }
    }
    
    
    public class BookingDemandWrapper {
        @AuraEnabled public Booking__c booking;
        @AuraEnabled public RaiseDemandWrapper raiseDemandDetails;
        @AuraEnabled public Boolean PostOC;
        @AuraEnabled public String projectIfscCode;
        @AuraEnabled public String projectBranchName;
        @AuraEnabled public String projectBankName;
        @AuraEnabled public String projectBeneficiaryAccountNo;
    }
    
    public class RaiseDemandWrapper {
        @AuraEnabled public Decimal totAmtDueTillPrevMilestone;
        @AuraEnabled public Decimal paidTillPrevMilestone;
        @AuraEnabled public Decimal balanceDueTillPrevMilestone;
        @AuraEnabled public Decimal interestDelayTillPrevious;
        @AuraEnabled public Decimal interestPaidTillPrevious;
        @AuraEnabled public Decimal presentDue;
        @AuraEnabled public Decimal balanceInterest;
        @AuraEnabled public Decimal totalAmountPayable;
        @AuraEnabled public String totalAmountPayableInWords;
        @AuraEnabled public String currentCompletedStage;
        @AuraEnabled public Date currentCompletedStageDate;
        @AuraEnabled public String currentMilestoneNumber;
        @AuraEnabled public Date demandDueDate;
        @AuraEnabled public Decimal currentMilestonePaymentPercent;
        @AuraEnabled public Decimal milestonePaymentPercentTill;
        @AuraEnabled public Decimal TDSonePercentage;
        @AuraEnabled public Boolean isDemanded;
        @AuraEnabled public String milestoneAmountInWords;
    }
}