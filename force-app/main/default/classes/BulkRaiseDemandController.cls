public class BulkRaiseDemandController {
    public class BookingWrapper {
        @AuraEnabled public Booking__c booking;
        @AuraEnabled public Decimal displayAmount;
        @AuraEnabled public Decimal totalPaymentAmount;
        @AuraEnabled public Decimal grandTotal;
        @AuraEnabled public Id paymentScheduleId;
        @AuraEnabled public Decimal previousDemandRaisedPending;
        @AuraEnabled public Boolean demandRaised;
        @AuraEnabled public String includeInterest;
        @AuraEnabled public Id leadId;
        @AuraEnabled public Id unitId;
        @AuraEnabled public String tower;
        @AuraEnabled public String block;
        @AuraEnabled public Id towerId;
        @AuraEnabled public Boolean selected;
        @AuraEnabled public String currentMilestone;
        @AuraEnabled public String invoiceNumber;
        
        public BookingWrapper(Booking__c booking, Decimal displayAmount, Decimal totalPaymentAmount, 
                              Id paymentScheduleId, Decimal previousDemandRaisedPending, 
                              Decimal grandTotal, String includeInterest, Boolean demandRaised, 
                              Id leadId, Id unitId, String tower, String block, Id towerId,Boolean selected,String currentMilestone, String invoiceNumber) {
                                  this.booking = booking;
                                  this.displayAmount = displayAmount;
                                  this.totalPaymentAmount = totalPaymentAmount;
                                  this.paymentScheduleId = paymentScheduleId;
                                  this.previousDemandRaisedPending = previousDemandRaisedPending;
                                  this.grandTotal = grandTotal;
                                  this.demandRaised = demandRaised;
                                  this.includeInterest = includeInterest;
                                  this.leadId = leadId;
                                  this.unitId = unitId;
                                  this.tower = tower;
                                  this.block = block;
                                  this.towerId = towerId;
                                  this.selected = selected;
                                  this.currentMilestone = currentMilestone;
                                  this.invoiceNumber ='';
                              }
    }
    
    @AuraEnabled
    public static List<BookingWrapper> getBookingRecords(String masterPaymentScheduleId) {
        // Query the Master_Payment_Schedule__c and related Project__c in one query
        Master_Payment_Schedule__c masterPaymentSchedule = [
            SELECT Id, Name, S_No__c, Project__r.Project__c, Completed_Date__c 
            FROM Master_Payment_Schedule__c 
            WHERE Id = :masterPaymentScheduleId 
            LIMIT 1
        ];
        
        if (masterPaymentSchedule != null) {
            String projectValue = masterPaymentSchedule.Project__r.Project__c;
            map<id,payment_schedule__c> paymentBookMap = new map<id,payment_schedule__c>();
            // Query all relevant payment_schedule__c records
            List<payment_schedule__c> getPayScheLineItems = [
                SELECT Id, Name, Is_Demanded__c, Booking__c, AmountB__c, 
                Received_Amount1__c, Pending_Amount__c, status__c, 
                Master_Payment_Schedule__r.Completed_Date__c, Demand_Uploaded__c 
                FROM payment_schedule__c 
                WHERE Master_Payment_Schedule__c = :masterPaymentScheduleId
            ];
            
            list<id> bookingLists = new list<id>();
            for(payment_schedule__c pay : getPayScheLineItems){
                bookingLists.add(pay.Booking__c);
                paymentBookMap.put(pay.Booking__c, pay);
            }
            
            List<Booking__c> bookings = [
                SELECT Id, Name, First_Applicant_Name__c,Total_Interest_Waive_Off__c,GST__c,Debit_Amount__c,Plot__r.Block1__r.Name,Plot__r.Block1__c,Tower__c,Project_Company__c,salutation_Applicant1__c,salutation_Applicant2__c,Second_Applicant_Name__c,Block__c,Block__r.Block__c,Block__r.Name,Project1__c,Project1__r.Name, Project__c, Plot__c,Plot__r.Block__c, Plot__r.Name, Lead__c, Email1__c	
                FROM Booking__c
                WHERE id IN :bookingLists AND (Stage__c != 'Cancellation' AND Stage__c != 'Unit Swap')
                ORDER BY CreatedDate ASC
            ];
            
            
            List<BookingWrapper> result = bookingScheduleCalculations(bookings,paymentBookMap,masterPaymentSchedule);
            
            return result;
        }
        
        return new List<BookingWrapper>();
    }
    @AuraEnabled
    public static List<BookingWrapper> getBookingRecordsWithProject(String masterPaymentScheduleId) {
        
        // Query the Master_Payment_Schedule__c and related Project__c in one query
        Master_Payment_Schedule__c masterPaymentSchedule = [
            SELECT Id, Name, S_No__c, Project__r.Project__c, Completed_Date__c 
            FROM Master_Payment_Schedule__c 
            WHERE Id = :masterPaymentScheduleId 
            LIMIT 1
        ];
        
        if (masterPaymentSchedule != null) {
            String projectValue = masterPaymentSchedule.Project__r.Project__c;
            map<id,payment_schedule__c> paymentBookMap = new map<id,payment_schedule__c>();
            // Query all relevant payment_schedule__c records
            List<payment_schedule__c> getPayScheLineItems = [
                SELECT Id, Name, Is_Demanded__c, Booking__c, AmountB__c, 
                Received_Amount1__c, Pending_Amount__c, status__c, 
                Master_Payment_Schedule__r.Completed_Date__c, Demand_Uploaded__c 
                FROM payment_schedule__c 
                WHERE Master_Payment_Schedule__c = :masterPaymentScheduleId
            ];
            
            list<id> bookingLists = new list<id>();
            for(payment_schedule__c pay : getPayScheLineItems){
                bookingLists.add(pay.Booking__c);
                paymentBookMap.put(pay.Booking__c, pay);
            }
            
            system.debug('bookingLists'+bookingLists);
            system.debug('paymentBookMap'+paymentBookMap);
            
            List<Booking__c> bookings = [
                SELECT Id, Name,Tower__c,Total_Interest_Waive_Off__c,Debit_Amount__c,GST__c,Plot__r.Block1__r.Name,Plot__r.Block1__c, First_Applicant_Name__c,Project_Company__c,salutation_Applicant1__c,salutation_Applicant2__c,Second_Applicant_Name__c,Project1__c,Project1__r.Name,Block__c,Block__r.Block__c,Block__r.Name, Project__c, Plot__c,Plot__r.Block__c, Plot__r.Name, Lead__c, Email1__c	
                FROM Booking__c
                WHERE id IN :bookingLists AND (Stage__c != 'Cancellation' AND Stage__c != 'Unit Swap')
                ORDER BY CreatedDate ASC
            ];
            
            
            List<BookingWrapper> result = bookingScheduleProjectCalculations(bookings,paymentBookMap,masterPaymentSchedule);
            
            return result;
        }
        
        return new List<BookingWrapper>();
    }
    
    //Get Blocks 
    @AuraEnabled
    public static List<Block__c> getBlocks(string recId){
        system.debug('recId:' + recId);
        List<Master_Payment_Schedule__c> clist = [select id,name,Project__c,Tower__c,Tower__r.Name from Master_Payment_Schedule__c where id =:recId ];
        string project=clist[0].Tower__r.Name;
        system.debug('sdghvcdchdchdhcdhcdhhdhdhdhhdhd  '+project);
        List<Block__c>plotList=new List<Block__c>();
        string obj='Block__c';
        plotList = [select Id,Name,Project__c from Block__c where Name =: project];
        system.debug('recId:' + plotList);
        return plotList;
    }
    
    @AuraEnabled
    public static void updatePaymentSchedules(Id payIds){
        List<payment_schedule__c> payList = [select id,name, Is_Demanded__c,Payment_Due_Date__c from payment_schedule__c where id =: payIds];
        List<payment_schedule__c> toUpdate = new List<payment_schedule__c>();
        for(payment_schedule__c p : payList){
            p.Is_Demanded__c = true;
            if(p.Payment_Due_Date__c != null){
                p.Payment_Due_Date__c = System.today() + 15;
            }
            toUpdate.add(p);
        }
        if(toUpdate.size()>0){
            update toUpdate;
            system.debug('after updated   '+toUpdate);
        }
    }
    
    @AuraEnabled
    public static List<BookingWrapper> bookingScheduleCalculations(List<Booking__c> bookings,map<id,payment_schedule__c> bookingPaymentMap,Master_payment_Schedule__c masterPaymentSchedule) {
        List<BookingWrapper> result = new List<BookingWrapper>();
        
        List<Demand_Raised__c> demands = new List<Demand_Raised__c>();
        Decimal completed_StageNumber;
        List<Master_Payment_Schedule__c> mps = new List<Master_Payment_Schedule__c>();
        
        mps.add(masterPaymentSchedule);
        
        // Fetch the latest completed Master Payment Schedules for all related towers
        Map<Id, Master_Payment_Schedule__c> towerToMasterPaymentScheduleMap = new Map<Id, Master_Payment_Schedule__c>();
        map<id,Decimal> debitAmountMap = new map<id,Decimal>();
        
        for (Booking__c book : bookings) {
            debitAmountMap.put(book.Id, book.Debit_Amount__c);
            
            if (!mps.isEmpty()) {
                towerToMasterPaymentScheduleMap.put(book.Tower__c, mps[0]);
                completed_StageNumber = masterPaymentSchedule.S_No__c;
            }
        }
        
        // Query all Payment Schedules for the provided bookings
        List<AggregateResult> aggregateResults = [
            SELECT Booking__c, SUM(Pending_Amount__c) totalPendingAmount, SUM(Interest_Amount__c) totalInterestAmount,
            SUM(AmountB__c) totalPayableAmount, SUM(Interest_Up_to_Date__c) totalInterestUplodate,
            SUM(Interest_Paid__c) totalInterestPaid, SUM(Payment_percent__c) paymentPercentageTill
            FROM Payment_Schedule__c
            WHERE Master_Payment_Schedule__r.Status__c = 'Completed' 
            AND Booking__c IN :bookings AND Master_Payment_Schedule__r.S_No__c != :completed_StageNumber
            GROUP BY Booking__c
        ];
        
        // Map to store the aggregated payment schedule results
        Map<Id, AggregateResult> bookingToAggregateResultMap = new Map<Id, AggregateResult>();
        for (AggregateResult result1 : aggregateResults) {
            bookingToAggregateResultMap.put((Id) result1.get('Booking__c'), result1);
        }
        
        // Query total received amounts for all bookings
        List<AggregateResult> totalReceivedResults = [
            SELECT Booking__c, SUM(Received_Amount1__c) totalReceivedAmount,SUM(AmountB__c) totalAmountB
            FROM Payment_Schedule__c
            WHERE Booking__c IN :bookings AND Master_Payment_Schedule__r.S_No__c = :completed_StageNumber
            GROUP BY Booking__c
        ];
        
        List<AggregateResult> totalReceivedAmount = [
            SELECT Booking__c, SUM(Received_Amount1__c) totalReceivedAmount
            FROM Payment_Schedule__c
            WHERE Booking__c IN :bookings
            GROUP BY Booking__c
        ];
        Map<Id, Decimal> bookingToReceivedAmountMap = new Map<Id, Decimal>();
        for (AggregateResult result2 : totalReceivedAmount) {
            bookingToReceivedAmountMap.put((Id) result2.get('Booking__c'), (Decimal) result2.get('totalReceivedAmount'));
        }
        
        // Map to store total received amounts per booking
        Map<Id, Decimal> bookingToThisMSAmountMap = new Map<Id, Decimal>();
        for (AggregateResult result3 : totalReceivedResults) {
            bookingToThisMSAmountMap.put((Id) result3.get('Booking__c'), (Decimal) result3.get('totalAmountB'));
        }
        
        // Process each booking and calculate demand details
        for (Booking__c book : bookings) {
            Master_Payment_Schedule__c msRecord = towerToMasterPaymentScheduleMap.get(book.Tower__c);
            if (msRecord == null) {
                continue;
            }
            
            AggregateResult aggregateResult = bookingToAggregateResultMap.get(book.Id);
            if (aggregateResult == null) {
                continue;
            }
            
            Decimal totalPendingAmount = (Decimal) aggregateResult.get('totalPendingAmount') != null ? (Decimal) aggregateResult.get('totalPendingAmount') : 0;
            Decimal totalInterestAmount = (Decimal) aggregateResult.get('totalInterestAmount') != null ? (Decimal) aggregateResult.get('totalInterestAmount') : 0;
            Decimal totalPayableAmount = (Decimal) aggregateResult.get('totalPayableAmount') != null ? (Decimal) aggregateResult.get('totalPayableAmount') : 0;
            Decimal totalInterestUplodateAmount = (Decimal) aggregateResult.get('totalInterestUplodate') != null ? (Decimal) aggregateResult.get('totalInterestUplodate') : 0;
            Decimal totalInterestPaid = (Decimal) aggregateResult.get('totalInterestPaid') != null ? (Decimal) aggregateResult.get('totalInterestPaid') : 0;
            Decimal milestonePaymentPercent = (Decimal) aggregateResult.get('paymentPercentageTill') != null ? (Decimal) aggregateResult.get('paymentPercentageTill') : 0;
            
            Decimal paidTotalAmount = bookingToReceivedAmountMap.get(book.Id) != null ? bookingToReceivedAmountMap.get(book.Id) : 0;
            if(debitAmountMap.get(book.Id) != null){
                paidTotalAmount -= debitAmountMap.get(book.Id);
            }
            Decimal balanceDueTillPrevMilestoneMod = totalPayableAmount - paidTotalAmount;            
            Decimal balanceDueTillPrevMilestone = balanceDueTillPrevMilestoneMod > 0 ? balanceDueTillPrevMilestoneMod : 0;
            Decimal balanceInterest = totalInterestUplodateAmount - totalInterestPaid - book.Total_Interest_Waive_Off__c;
            
            Decimal presentDue = bookingToThisMSAmountMap.get(book.Id) != null ? bookingToThisMSAmountMap.get(book.Id) : 0;
            
            Decimal gstPercentage = (book.GST__c != null) ? book.GST__c / 100 : 0;
            Decimal amountExcludingGST = presentDue / (1 + gstPercentage);
            Decimal TDSonePercentage = paidTotalAmount > 4999999 ? amountExcludingGST * 0.01: 0;
            
            Decimal actualTotalAmountPayable;
            actualTotalAmountPayable = (balanceDueTillPrevMilestoneMod + balanceInterest + presentDue - TDSonePercentage).setScale(0);
            
            Decimal totalAmountPayable = actualTotalAmountPayable > 0 ? actualTotalAmountPayable : 0;
            
            // Convert total amount payable to words
            NumberTOWordConvertion convert = new NumberTOWordConvertion();
            String totalAmountPayableInWords = convert.getNumberTOWordConvertion(totalAmountPayable);
            
            String bookingBlock =book.Plot__r.Block__c;
            String bookingTower = book.Plot__r.Block1__r.Name;
            String bookingTowerId = book.Plot__r.Block1__c;
            String bookingProject = book.Project1__r.Name;
            Boolean demandRaised = bookingPaymentMap.get(book.id).Is_Demanded__c;
            String currentMilestone = bookingPaymentMap.get(book.id).Name;
            Id unitId = book.Plot__c;
            Id leadId = book.Lead__c;
            
            result.add(new BookingWrapper(
                book, 0, presentDue, null, 
                balanceDueTillPrevMilestone, totalAmountPayable, 'false', demandRaised, leadId, unitId, bookingTower, bookingBlock, bookingTowerId,false,currentMilestone,''
            ));
        }
        return result;
    }
    
    @AuraEnabled
    public static List<BookingWrapper> bookingScheduleProjectCalculations(List<Booking__c> bookings,map<id,payment_schedule__c> bookingPaymentMap,Master_payment_Schedule__c masterPaymentSchedule) {
        List<BookingWrapper> result = new List<BookingWrapper>();
        
        List<Demand_Raised__c> demands = new List<Demand_Raised__c>();
        Decimal completed_StageNumber;
        List<Master_Payment_Schedule__c> mps = new List<Master_Payment_Schedule__c>();
        
        mps.add(masterPaymentSchedule);
        
        // Fetch the latest completed Master Payment Schedules for all related towers
        Map<Id, Master_Payment_Schedule__c> projectToMasterPaymentScheduleMap = new Map<Id, Master_Payment_Schedule__c>();
        map<id,Decimal> debitAmountMap = new map<id,Decimal>();
        
        for (Booking__c book : bookings) {
            
            debitAmountMap.put(book.Id, book.Debit_Amount__c);
            
            if (!mps.isEmpty()) {
                projectToMasterPaymentScheduleMap.put(book.Project1__c, mps[0]);
                completed_StageNumber = masterPaymentSchedule.S_No__c;
            }
        }
        
        // Query all Payment Schedules for the provided bookings
        List<AggregateResult> aggregateResults = [
            SELECT Booking__c, SUM(Pending_Amount__c) totalPendingAmount, SUM(Interest_Amount__c) totalInterestAmount,
            SUM(AmountB__c) totalPayableAmount, SUM(Interest_Up_to_Date__c) totalInterestUplodate,
            SUM(Interest_Paid__c) totalInterestPaid, SUM(Payment_percent__c) paymentPercentageTill
            FROM Payment_Schedule__c
            WHERE Master_Payment_Schedule__r.Status__c = 'Completed' 
            AND Booking__c IN :bookings AND Master_Payment_Schedule__r.S_No__c != :completed_StageNumber
            GROUP BY Booking__c
        ];
        
        // Map to store the aggregated payment schedule results
        Map<Id, AggregateResult> bookingToAggregateResultMap = new Map<Id, AggregateResult>();
        for (AggregateResult result1 : aggregateResults) {
            bookingToAggregateResultMap.put((Id) result1.get('Booking__c'), result1);
        }
        
        // Query total received amounts for all bookings
        List<AggregateResult> totalReceivedResults = [
            SELECT Booking__c, SUM(Received_Amount1__c) totalReceivedAmount,SUM(AmountB__c) totalAmountB
            FROM Payment_Schedule__c
            WHERE Booking__c IN :bookings AND Master_Payment_Schedule__r.S_No__c = :completed_StageNumber
            GROUP BY Booking__c
        ];
        
        List<AggregateResult> totalReceivedAmount = [
            SELECT Booking__c, SUM(Received_Amount1__c) totalReceivedAmount
            FROM Payment_Schedule__c
            WHERE Booking__c IN :bookings
            GROUP BY Booking__c
        ];
        Map<Id, Decimal> bookingToReceivedAmountMap = new Map<Id, Decimal>();
        for (AggregateResult result2 : totalReceivedAmount) {
            bookingToReceivedAmountMap.put((Id) result2.get('Booking__c'), (Decimal) result2.get('totalReceivedAmount'));
        }
        
        // Map to store total received amounts per booking
        Map<Id, Decimal> bookingToThisMSAmountMap = new Map<Id, Decimal>();
        for (AggregateResult result3 : totalReceivedResults) {
            bookingToThisMSAmountMap.put((Id) result3.get('Booking__c'), (Decimal) result3.get('totalAmountB'));
        }
        
        // Process each booking and calculate demand details
        for (Booking__c book : bookings) {
            Master_Payment_Schedule__c msRecord = projectToMasterPaymentScheduleMap.get(book.Project1__c);
            if (msRecord == null) {
                continue;
            }
            
            AggregateResult aggregateResult = bookingToAggregateResultMap.get(book.Id);
            if (aggregateResult == null) {
                continue;
            }
            
            Decimal totalPendingAmount = (Decimal) aggregateResult.get('totalPendingAmount') != null ? (Decimal) aggregateResult.get('totalPendingAmount') : 0;
            Decimal totalInterestAmount = (Decimal) aggregateResult.get('totalInterestAmount') != null ? (Decimal) aggregateResult.get('totalInterestAmount') : 0;
            Decimal totalPayableAmount = (Decimal) aggregateResult.get('totalPayableAmount') != null ? (Decimal) aggregateResult.get('totalPayableAmount') : 0;
            Decimal totalInterestUplodateAmount = (Decimal) aggregateResult.get('totalInterestUplodate') != null ? (Decimal) aggregateResult.get('totalInterestUplodate') : 0;
            Decimal totalInterestPaid = (Decimal) aggregateResult.get('totalInterestPaid') != null ? (Decimal) aggregateResult.get('totalInterestPaid') : 0;
            Decimal milestonePaymentPercent = (Decimal) aggregateResult.get('paymentPercentageTill') != null ? (Decimal) aggregateResult.get('paymentPercentageTill') : 0;
            
            Decimal paidTotalAmount = bookingToReceivedAmountMap.get(book.Id) != null ? bookingToReceivedAmountMap.get(book.Id) : 0;
            if(debitAmountMap.get(book.Id) != null){
                paidTotalAmount -= debitAmountMap.get(book.Id);
            }
            Decimal balanceDueTillPrevMilestoneMod = totalPayableAmount - paidTotalAmount;            
            Decimal balanceDueTillPrevMilestone = balanceDueTillPrevMilestoneMod > 0 ? balanceDueTillPrevMilestoneMod : 0;
            Decimal balanceInterest = totalInterestUplodateAmount - totalInterestPaid - book.Total_Interest_Waive_Off__c;
            
            Decimal presentDue = bookingToThisMSAmountMap.get(book.Id) != null ? bookingToThisMSAmountMap.get(book.Id) : 0;
            
            Decimal gstPercentage = (book.GST__c != null) ? book.GST__c / 100 : 0;
            Decimal amountExcludingGST = presentDue / (1 + gstPercentage);
            Decimal TDSonePercentage = paidTotalAmount > 4999999 ? amountExcludingGST * 0.01: 0;
            
            Decimal actualTotalAmountPayable;
            actualTotalAmountPayable = (balanceDueTillPrevMilestoneMod + balanceInterest + presentDue - TDSonePercentage).setScale(0);
            Decimal totalAmountPayable = actualTotalAmountPayable > 0 ? actualTotalAmountPayable : 0;
            
            // Convert total amount payable to words
            NumberTOWordConvertion convert = new NumberTOWordConvertion();
            String totalAmountPayableInWords = convert.getNumberTOWordConvertion(totalAmountPayable);
            
            String bookingBlock =book.Plot__r.Block__c;
            String bookingTower = book.Plot__r.Block1__r.Name;
            String bookingTowerId = book.Plot__r.Block1__c;
            String bookingProject = book.Project1__r.Name;
            Boolean demandRaised = bookingPaymentMap.get(book.id).Is_Demanded__c;
            String currentMilestone = bookingPaymentMap.get(book.id).Name;
            Id unitId = book.Plot__c;
            Id leadId = book.Lead__c;
            
            result.add(new BookingWrapper(
                book, 0, presentDue, null, 
                balanceDueTillPrevMilestone, totalAmountPayable, 'false', demandRaised, leadId, unitId, bookingTower, bookingBlock, bookingTowerId,false,currentMilestone,''
            ));
        }
        return result;
    }
  
}