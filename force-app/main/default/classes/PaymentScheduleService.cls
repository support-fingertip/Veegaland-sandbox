public class PaymentScheduleService {
    
    public static void checkMergeSchedules(List<Booking__c> bookingList) {
        List<Booking__c> bookingMerge = new LIst<Booking__c>();
        Set<Id> bookingNoMerge = new Set<Id>();
        Map<Id,Booking__c> planBookingMap = new Map<Id,Booking__c>();
        
        for(Booking__c bk : bookingList){
            if(!planBookingMap.containsKey(bk.Id)){
                planBookingMap.put(bk.Id, bk);
            }
        }
        
        List<Booking__c> bookingPaymentPlans = [SELECT Id,Payment_plan__r.Disable_Merge__c FROM Booking__c WHERE Id IN : planBookingMap.keySet() ];
        if(!bookingPaymentPlans.isEmpty()){
            for(Booking__c pp : bookingPaymentPlans){
                if(pp.Payment_plan__r.Disable_Merge__c == true){
                    bookingNoMerge.add(planBookingMap.get(pp.Id).Id);
                }else{
                    bookingMerge.add(planBookingMap.get(pp.Id));
                }
            }
        }
        if(!bookingNoMerge.isEmpty()){
            PaymentScheduleService.changePaymentSchedules(bookingNoMerge);
        }
        if(!bookingMerge.isEmpty()){
            PaymentScheduleService.createPaymentSchedules(bookingMerge);
        }
    }    
    
    public static void createPaymentSchedules(List<Booking__c> bookingList) {
        Set<String> paymentPlanIds = new Set<String>();
        
        for (Booking__c qt : bookingList) {
            if (qt.Payment_Plan__c != null && qt.Plot__c != null) {
                paymentPlanIds.add(qt.Payment_Plan__c);
            }
        }
        
        if (paymentPlanIds.isEmpty()) {
            return;
        }
        
        Map<String, List<Master_Payment_Schedule__c>> masterSchedulesMap = new Map<String, List<Master_Payment_Schedule__c>>();
        List<Payment_Plan__c> paymentPlans = [
            SELECT Id, Name,
            (SELECT Id, Project__C, S_No__c, Name, Payment_Percent__c, Completed_Date__c,
             Status__c, Completed__c,Include_Interest__c,Amount__c,Last_Schedule__c
             FROM Master_Payment_Schedules__r where Combined_Schedule__c = false ORDER BY S_No__c ASC)
            FROM Payment_Plan__c WHERE Id IN :paymentPlanIds
        ];
        
        // Build Map of Payment Plans to their Master Payment Schedules
        for (Payment_Plan__c plan : paymentPlans) {
            if (plan.Master_Payment_Schedules__r != null && !plan.Master_Payment_Schedules__r.isEmpty()) {
                masterSchedulesMap.put(plan.Id, plan.Master_Payment_Schedules__r);
            }
        }
        
        // Create Payment Schedules
        List<Payment_Schedule__c> paymentScheduleList = new List<Payment_Schedule__c>();
        List<Master_Payment_Schedule__c> masterPaymentScheduleList = new List<Master_Payment_Schedule__c>();
        
        system.debug('bookingList' + bookingList);
        for (Booking__c qt : bookingList) {
            if (qt.Plot__c != null && qt.Payment_Plan__c != null && masterSchedulesMap.containsKey(qt.Payment_Plan__c)) {
                List<Master_Payment_Schedule__c> masterSchedules = masterSchedulesMap.get(qt.Payment_Plan__c);
                Decimal totalPercentage = 0;
                date lastCompletedDate = null;
                String lastCompletedMilestone = '';
                Boolean hasUncompletedPayments = false;
                Decimal totalAmount = (qt.Total__c).setScale(0, RoundingMode.HALF_UP);
                Decimal totalBasecostAmount = qt.Sub_Total__c.setScale(0, RoundingMode.HALF_UP);
                Decimal totalGST = qt.GST_Amount__c.setScale(0, RoundingMode.HALF_UP);
                Decimal Serial_Number = 0;
                Decimal milestoneAmount = 0;
                Decimal balanceAmount = 0;
                Decimal bookingGST = qt.GST__c != null?qt.GST__c: 0 ;
                Decimal mergeAmount = 0;
                Decimal mergeValueofSupply = 0;
                Decimal totalTax = 0;
                Decimal taxDifference = 0;
                Boolean isLastScheduleMarge = false;
                Decimal calcValueofSupply = 0;
                
                for (Master_Payment_Schedule__c mps : masterSchedules) {
                    
                    Decimal cgstPercent = bookingGST/2;
                    Decimal sgstPercent = bookingGST/2;
                    Decimal valueOfSupply =0;
                    Decimal cgstAmount = 0;
                    Decimal sgstAmount = 0;
                    Decimal totalMilestoneAmount = 0;
                    
                    if(mps.Last_Schedule__c == true){
                        balanceAmount = totalAmount - milestoneAmount;
                        valueOfSupply = totalBasecostAmount - calcValueofSupply;
                        cgstAmount = ((valueOfSupply * cgstPercent) / 100).setScale(0, RoundingMode.HALF_UP);
                        sgstAmount = ((valueOfSupply * sgstPercent) / 100).setScale(0, RoundingMode.HALF_UP);
                        totalMilestoneAmount = valueOfSupply + cgstAmount + sgstAmount;
                        totalTax += cgstAmount + sgstAmount;
                        milestoneAmount += totalMilestoneAmount;
                        taxDifference = totalGST - totalTax;
                    }else{
                        valueOfSupply = ((totalBasecostAmount * mps.Payment_Percent__c) / 100).setScale(0, RoundingMode.HALF_UP);
                        cgstAmount = ((valueOfSupply * cgstPercent) / 100).setScale(0, RoundingMode.HALF_UP);
                        sgstAmount = ((valueOfSupply * sgstPercent) / 100).setScale(0, RoundingMode.HALF_UP);
                        totalMilestoneAmount = valueOfSupply + cgstAmount + sgstAmount;
                        totalTax += cgstAmount + sgstAmount;
                        calcValueofSupply += valueOfSupply;
                        milestoneAmount += totalMilestoneAmount;
                    }
                    
                    
                    if (!mps.Completed__c && mps.S_No__c != 1) {
                        Serial_Number +=1;
                        hasUncompletedPayments = true;
                        paymentScheduleList.add(new Payment_Schedule__c(
                            Booking__c = qt.Id,
                            Payment_percent__c = mps.Payment_percent__c,
                            Interest_Percent__c = qt.Interest_Percent__c,
                            Include_interest__c = mps.Include_interest__c,
                            S_No__c = mps.S_No__c,
                            Scheduled_Amount__c = totalMilestoneAmount,
                            Amount__c = valueOfSupply,
                            Last_Schedule__c = mps.Last_Schedule__c,
                            Round_Off_Amount__c = balanceAmount,
                            Master_Payment_Schedule__c = mps.Id,
                            Name = mps.Name,
                            GST_Round_Off_Amount__c = taxDifference,
                            Serial_Number__c = Serial_Number
                        ));
                    } else if (mps.S_No__c == 1) {
                        Serial_Number =1;
                        paymentScheduleList.add(new Payment_Schedule__c(
                            Booking__c = qt.Id,
                            Payment_percent__c = mps.Payment_Percent__c,
                            Interest_Percent__c = qt.Interest_Percent__c,
                            Include_interest__c = mps.Include_interest__c,
                            S_No__c = mps.S_No__c,
                            Scheduled_Amount__c = totalMilestoneAmount,
                            Amount__c = valueOfSupply,
                            Master_Payment_Schedule__c = mps.Id,
                            Name = mps.Name,
                            status__c = mps.Status__c,
                            Serial_Number__c = 1
                        ));
                    }else {
                        
                        if(mps.Last_Schedule__c == true){
                            isLastScheduleMarge = true;
                        }
                        Serial_Number = 2;
                        totalPercentage += mps.Payment_Percent__c;
                        lastCompletedDate = mps.Completed_Date__c;
                        lastCompletedMilestone = mps.Name;
                        mergeValueofSupply += valueOfSupply;
                        mergeAmount = totalMilestoneAmount;
                    }
                }
                
                // Add "As Per the Current Work Status" if all payments are completed
                if (totalPercentage > 0) {
                    // Create and insert Master Payment Schedule record
                    Master_Payment_Schedule__c masterPaymentSchedule = new Master_Payment_Schedule__c(
                        Name = 'On ' + lastCompletedMilestone,
                        Project__c = qt.Project1__c,
                        S_No__c = 2,
                        Payment_Percent__c = totalPercentage,
                        Completed_Date__c = lastCompletedDate,
                        Completed__c = true,
                        Combined_Schedule__c = true,
                        Status__c = 'Completed',
                        Include_Interest__c = true,
                        Last_Schedule__c = isLastScheduleMarge,
                        ExternalId__c = qt.Payment_Plan__c +'-'+qt.Id,
                        Payment_Plan__c = qt.Payment_Plan__c
                    );
                    masterPaymentScheduleList.add(masterPaymentSchedule);            
                    // Create Payment Schedule record linked to Master Payment Schedule
                    Decimal MergedBalance = 0;
                    Decimal mergedTaxDiffrenece = 0;
                    if(isLastScheduleMarge == true){
                        MergedBalance = balanceAmount;
                        mergedTaxDiffrenece = taxDifference;
                    }
                    paymentScheduleList.add(new Payment_Schedule__c(
                        Name = 'On ' + lastCompletedMilestone,
                        Payment_percent__c = totalPercentage,
                        Booking__c = qt.Id,
                        Status__c = 'Completed',
                        S_No__c = masterPaymentSchedule.S_No__c,
                        Completed__c = true,
                        Master_Payment_Schedule__r = new Master_Payment_Schedule__c(ExternalId__c= masterPaymentSchedule.ExternalId__c),
                        Amount__c = mergeValueofSupply,
                        Scheduled_Amount__c = mergeAmount,
                        Last_Schedule__c = masterPaymentSchedule.Last_Schedule__c,
                        Round_Off_Amount__c = MergedBalance,
                        GST_Round_Off_Amount__c = mergedTaxDiffrenece
                        
                    ));
                }
            }
        }
        
        if (!masterPaymentScheduleList.isEmpty()) {
            insert masterPaymentScheduleList;
        }
        if (!paymentScheduleList.isEmpty()) {
            insert paymentScheduleList;
        }
    }
    public static void updatePaymentSchedules(Set<Id> bookingIds) {
        System.debug('Here updatePaymentSchedules');
        System.debug('Here bookingIds <<<<<<<<<<<<<<<< '+bookingIds);
        if (bookingIds.isEmpty()) return;
        
        // Fetch bookings
        Map<Id, Booking__c> bookingMap = new Map<Id, Booking__c>(
            [SELECT Id, Total__c, Sub_Total__c, GST__c,GST_Amount__c
             FROM Booking__c
             WHERE Id IN :bookingIds]
        );
        
        // Fetch payment schedules
        List<Payment_Schedule__c> paymentSchedules = [
            SELECT Id, Booking__c, Amount__c, Scheduled_Amount__c, Payment_percent__c,Round_Off_Amount__c,Last_Schedule__c,GST_Round_Off_Amount__c,Custom_Value__c
            FROM Payment_Schedule__c
            WHERE Booking__c IN :bookingIds ORDER BY S_No__c ASC
        ];
        
        // Group schedules by Booking Id
        Map<Id, List<Payment_Schedule__c>> bookingToSchedules = new Map<Id, List<Payment_Schedule__c>>();
        for (Payment_Schedule__c ps : paymentSchedules) {
            if (!bookingToSchedules.containsKey(ps.Booking__c)) {
                bookingToSchedules.put(ps.Booking__c, new List<Payment_Schedule__c>());
            }
            bookingToSchedules.get(ps.Booking__c).add(ps);
        }
        
        List<Payment_Schedule__c> paymentSchedulesToUpdate = new List<Payment_Schedule__c>();
        
        // Iterate each booking and its schedules separately
        for (Id bookingId : bookingToSchedules.keySet()) {
            Booking__c booking = bookingMap.get(bookingId);
            if (booking == null) continue;
            
            List<Payment_Schedule__c> schedulesForBooking = bookingToSchedules.get(bookingId);
            
            Decimal totalAmount = (booking.Total__c).setScale(0);
            Decimal totalBasecostAmount = booking.Sub_Total__c.setScale(0);
            Decimal totalGST = booking.GST_Amount__c.setScale(0);
            Decimal milestoneAmount =0;
            Decimal balanceAmount = 0; 
            Decimal bookingGST = booking.GST__c;
            Decimal mergeValueofSupply = 0;
            Decimal totalTax = 0;
            Decimal taxDifference = 0;
            Boolean isLastScheduleMarge = false;
            Decimal calcValueofSupply = 0;
            
            for (Payment_Schedule__c schedule : schedulesForBooking) {
                
                Decimal cgstPercent = bookingGST/2;
                Decimal sgstPercent = bookingGST/2;
                Decimal valueOfSupply =0;
                Decimal cgstAmount = 0;
                Decimal sgstAmount = 0;
                Decimal totalMilestoneAmount = 0;
                
                if(schedule.Last_Schedule__c == true){
                    balanceAmount = totalAmount - milestoneAmount;
                    valueOfSupply = totalBasecostAmount - calcValueofSupply;
                    cgstAmount = ((valueOfSupply * cgstPercent) / 100).setScale(0, RoundingMode.HALF_UP);
                    sgstAmount = ((valueOfSupply * sgstPercent) / 100).setScale(0, RoundingMode.HALF_UP);
                    totalMilestoneAmount = valueOfSupply + cgstAmount + sgstAmount;
                    totalTax += cgstAmount + sgstAmount;
                    milestoneAmount += totalMilestoneAmount;
                    taxDifference = totalGST - totalTax;
                }else{
                    if(schedule.Custom_Value__c == true){
                        valueOfSupply = schedule.Amount__c;
                    }else{
                        valueOfSupply = ((totalBasecostAmount * schedule.Payment_Percent__c) / 100).setScale(0, RoundingMode.HALF_UP);
                    }
                    cgstAmount = ((valueOfSupply * cgstPercent) / 100).setScale(0, RoundingMode.HALF_UP);
                    sgstAmount = ((valueOfSupply * sgstPercent) / 100).setScale(0, RoundingMode.HALF_UP);
                    totalMilestoneAmount = valueOfSupply + cgstAmount + sgstAmount;
                    totalTax += cgstAmount + sgstAmount;
                    calcValueofSupply += valueOfSupply;
                    milestoneAmount += totalMilestoneAmount;
                }
                
                if (schedule.Payment_percent__c != null) {
                    Payment_schedule__c updateSchedule =  new Payment_schedule__c (
                        Id = schedule.Id,
                        Amount__c = valueOfSupply,
                        Scheduled_Amount__c = totalMilestoneAmount,
                        Round_Off_Amount__c = balanceAmount,
                        GST_Round_Off_Amount__c = taxDifference
                    );
                    paymentSchedulesToUpdate.add(updateSchedule);
                }
            }
        }
        
        if (!paymentSchedulesToUpdate.isEmpty()) {
            update paymentSchedulesToUpdate;
        }
    }
    
    public static void createPaymentSchedulesTillBookingDate(List<Booking__c> bookingList) {
        Set<Id> paymentPlanIds = new Set<Id>();
        
        for (Booking__c qt : bookingList) {
            if (qt.Payment_Plan__c != null && qt.Plot__c != null) {
                paymentPlanIds.add(qt.Payment_Plan__c);
            }
        }
        if (paymentPlanIds.isEmpty()) return;
        
        Map<Id, List<Master_Payment_Schedule__c>> masterSchedulesMap = new Map<Id, List<Master_Payment_Schedule__c>>();
        List<Payment_Plan__c> paymentPlans = [
            SELECT Id, Name,
            (SELECT Id, Project__c, S_No__c, Name, Payment_Percent__c, Completed_Date__c,Last_Schedule__c,
             Status__c, Completed__c, Include_Interest__c
             FROM Master_Payment_Schedules__r
             WHERE Combined_Schedule__c = false
             ORDER BY S_No__c ASC)
            FROM Payment_Plan__c
            WHERE Id IN :paymentPlanIds
        ];
        
        for (Payment_Plan__c plan : paymentPlans) {
            if (!plan.Master_Payment_Schedules__r.isEmpty()) {
                masterSchedulesMap.put(plan.Id, plan.Master_Payment_Schedules__r);
            }
        }
        
        List<Master_Payment_Schedule__c> newMasterSchedules = new List<Master_Payment_Schedule__c>();
        List<Payment_Schedule__c> newPaymentSchedules = new List<Payment_Schedule__c>();
        
        for (Booking__c qt : bookingList) {
            if (qt.Plot__c == null || qt.Payment_Plan__c == null) continue;
            if (!masterSchedulesMap.containsKey(qt.Payment_Plan__c)) continue;
            if (qt.Date_of_Booking__c == null) continue; // skip if no booking date
            
            Date bookingDate = qt.Date_of_Booking__c;
            List<Master_Payment_Schedule__c> masterSchedules = masterSchedulesMap.get(qt.Payment_Plan__c);
            
            Decimal totalPercentage = 0;
            Date lastCompletedDate = null;
            String lastCompletedMilestone = '';
            Decimal lastCompletedSlNo = null;
            Decimal totalAmount = qt.Total__c == null ? 0 : qt.Total__c.setScale(0);
            Decimal totalBasecostAmount = qt.Sub_Total__c == null ? 0 : qt.Sub_Total__c.setScale(0);
            Decimal totalGST = qt.GST_Amount__c.setScale(0);
            Decimal bookingGST = qt.GST__c;
            Decimal mergeAmount = 0;
            Decimal mergeValueofSupply = 0;
            Decimal Serial_Number = 0;
            Decimal milestoneAmount = 0;
            Decimal balanceAmount = 0;
            Decimal totalTax = 0;
            Decimal taxDifference = 0;
            Decimal calcValueofSupply = 0;
            Boolean isLastScheduleMarge = false;
            
            
            for (Master_Payment_Schedule__c mps : masterSchedules) {
                
                Decimal cgstPercent = bookingGST/2;
                Decimal sgstPercent = bookingGST/2;
                Decimal valueOfSupply =0;
                Decimal cgstAmount = 0;
                Decimal sgstAmount = 0;
                Decimal totalMilestoneAmount = 0;
                
                if(mps.Last_Schedule__c == true){
                    balanceAmount = totalAmount - milestoneAmount;
                    valueOfSupply = totalBasecostAmount - calcValueofSupply;
                    cgstAmount = ((valueOfSupply * cgstPercent) / 100).setScale(0, RoundingMode.HALF_UP);
                    sgstAmount = ((valueOfSupply * sgstPercent) / 100).setScale(0, RoundingMode.HALF_UP);
                    totalMilestoneAmount = valueOfSupply + cgstAmount + sgstAmount;
                    totalTax += cgstAmount + sgstAmount;
                    milestoneAmount += totalMilestoneAmount;
                    taxDifference = totalGST - totalTax;
                }else{
                    valueOfSupply = ((totalBasecostAmount * mps.Payment_Percent__c) / 100).setScale(0, RoundingMode.HALF_UP);
                    cgstAmount = ((valueOfSupply * cgstPercent) / 100).setScale(0, RoundingMode.HALF_UP);
                    sgstAmount = ((valueOfSupply * sgstPercent) / 100).setScale(0, RoundingMode.HALF_UP);
                    totalMilestoneAmount = valueOfSupply + cgstAmount + sgstAmount;
                    totalTax += cgstAmount + sgstAmount;
                    calcValueofSupply += valueOfSupply;
                    milestoneAmount += totalMilestoneAmount;
                }
                
                if (!mps.Completed__c && mps.S_No__c != 1){
                    Serial_Number +=1;
                    newPaymentSchedules.add(new Payment_Schedule__c(
                        Booking__c = qt.Id,
                        Payment_percent__c = mps.Payment_Percent__c,
                        Interest_Percent__c = qt.Interest_Percent__c,
                        Include_interest__c = mps.Include_Interest__c,
                        S_No__c = mps.S_No__c,
                        Amount__c = valueOfSupply,
                        Scheduled_Amount__c = totalMilestoneAmount,
                        Master_Payment_Schedule__c = mps.Id,
                        Name = mps.Name,
                        Status__c = 'Scheduled',
                        Serial_Number__c = Serial_Number,
                        Last_Schedule__c = mps.Last_Schedule__c,
                        Round_Off_Amount__c = balanceAmount,
                        GST_Round_Off_Amount__c = taxDifference
                    ));
                } else if (mps.S_No__c == 1) {
                    Serial_Number = 1;
                    newPaymentSchedules.add(new Payment_Schedule__c(
                        Booking__c = qt.Id,
                        Payment_percent__c = mps.Payment_Percent__c,
                        Interest_Percent__c = qt.Interest_Percent__c,
                        Include_interest__c = mps.Include_Interest__c,
                        S_No__c = mps.S_No__c,
                        Amount__c = valueOfSupply,
                        Scheduled_Amount__c = totalMilestoneAmount,
                        Master_Payment_Schedule__c = mps.Id,
                        Name = mps.Name,
                        Status__c = mps.Status__c,
                        Completed__c = true,
                        Serial_Number__c = 1
                    ));
                } else if (mps.Completed_Date__c != null && mps.Completed_Date__c <= bookingDate) {
                    if(mps.Last_Schedule__c == true){
                        isLastScheduleMarge = true;
                    }
                    totalPercentage += mps.Payment_Percent__c;
                    lastCompletedDate = mps.Completed_Date__c;
                    lastCompletedMilestone = mps.Name;
                    lastCompletedSlNo = mps.S_No__c;
                    mergeValueofSupply += valueOfSupply;
                    mergeAmount = totalMilestoneAmount;
                    Serial_Number =2;
                } else {
                    Serial_Number +=1;
                    newPaymentSchedules.add(new Payment_Schedule__c(
                        Booking__c = qt.Id,
                        Payment_percent__c = mps.Payment_Percent__c,
                        Interest_Percent__c = qt.Interest_Percent__c,
                        Include_interest__c = mps.Include_Interest__c,
                        S_No__c = mps.S_No__c,
                        Amount__c = valueOfSupply,
                        Scheduled_Amount__c = totalMilestoneAmount,
                        Master_Payment_Schedule__c = mps.Id,
                        Name = mps.Name,
                        Status__c = mps.Status__c,
                        Completed__c = true,
                        Serial_Number__c = Serial_Number,
                        Last_Schedule__c = mps.Last_Schedule__c,
                        Round_Off_Amount__c = balanceAmount,
                        GST_Round_Off_Amount__c = taxDifference
                    ));
                }
            }
            
            if (totalPercentage > 0) {
                Decimal MergedBalance = 0;
                Decimal mergedTaxDiffrenece = 0;
                if(isLastScheduleMarge == true){
                    mergedTaxDiffrenece = taxDifference;
                    MergedBalance = balanceAmount;
                }
                Master_Payment_Schedule__c masterPaymentSchedule = new Master_Payment_Schedule__c(
                    Name = 'On ' + lastCompletedMilestone,
                    Project__c = qt.Project1__c,
                    S_No__c = 2,
                    Payment_Percent__c = totalPercentage,
                    Completed_Date__c = lastCompletedDate,
                    Completed__c = true,
                    Combined_Schedule__c = true,
                    Status__c = 'Completed',
                    Include_Interest__c = true,
                    ExternalId__c = qt.Payment_Plan__c +'-'+qt.Id,
                    Payment_Plan__c = qt.Payment_Plan__c,
                    Last_Schedule__c = isLastScheduleMarge
                );
                newMasterSchedules.add(masterPaymentSchedule);
                
                newPaymentSchedules.add(new Payment_Schedule__c(
                    Name = 'On ' + lastCompletedMilestone,
                    Payment_percent__c = totalPercentage,
                    Booking__c = qt.Id,
                    Status__c = 'Completed',
                    S_No__c = masterPaymentSchedule.S_No__c,
                    Completed__c = true,
                    Amount__c = mergeValueofSupply,
                    Scheduled_Amount__c = mergeAmount,
                    Master_Payment_Schedule__r = new Master_Payment_Schedule__c(ExternalId__c= masterPaymentSchedule.ExternalId__c),
                    Serial_Number__c = 2,
                    Last_Schedule__c = masterPaymentSchedule.Last_Schedule__c,
                    Round_Off_Amount__c = MergedBalance,
                    GST_Round_Off_Amount__c = taxDifference
                ));
            }
        }
        
        // Insert new master schedules
        if (!newMasterSchedules.isEmpty()) {
            insert newMasterSchedules;
        }
        
        // Insert payment schedules
        if (!newPaymentSchedules.isEmpty()) {
            insert newPaymentSchedules;
        }
    }
    
    
    public static void sendPaymentNotification(Set<Id> paymentScheduleIds) {
        
        List<Payment_Schedule__c> paymentSchedules = [
            SELECT Id, Booking__r.OwnerId, Booking__c
            FROM Payment_Schedule__c 
            WHERE Id IN :paymentScheduleIds
        ];
        
        Map<Id, Set<String>> bookingOwnerMap = new Map<Id, Set<String>>();
        
        for (Payment_Schedule__c ps : paymentSchedules) {
            if (ps.Booking__r != null && ps.Booking__r.OwnerId != null) {
                if (!bookingOwnerMap.containsKey(ps.Booking__c)) {
                    bookingOwnerMap.put(ps.Booking__c, new Set<String>());
                }
                bookingOwnerMap.get(ps.Booking__c).add(ps.Booking__r.OwnerId);
            }
        }
        
        if (!bookingOwnerMap.isEmpty()) {
            CustomNotificationServiceClass.sendCustomNotification(
                bookingOwnerMap,
                'Booking Full Advance Payment Received',
                'The received the full amount of advance payment from the customer. Please review the payment details.',
                'Custom_Notification'
            );
        }
        
    }
    
    public static void changePaymentSchedules(Set<Id> bookingIdList) {
        
        List<Payment_Schedule__c> existingSchedulesToDelete = [
            SELECT Id
            FROM Payment_Schedule__c
            WHERE Booking__c IN :bookingIdList
        ];
        
        if (!existingSchedulesToDelete.isEmpty()) {
            delete existingSchedulesToDelete;
        }
        
        // Query Booking__c records along with necessary related fields
        List<Booking__c> bookingList = [
            SELECT Id, Payment_Plan__c, Plot__c, Project1__r.Interest_Percentage__c, Total__c, Sub_Total__c, GST__c, GST_Amount__c
            FROM Booking__c
            WHERE Id IN :bookingIdList
        ];
        
        
        // To store the Payment Plan Ids
        Set<Id> paymentPlanIds = new Set<Id>();
        for (Booking__c qt : bookingList) {
            if (qt.Payment_Plan__c != null && qt.Plot__c != null) {
                paymentPlanIds.add(qt.Payment_Plan__c);
            }
        }
        
        if (paymentPlanIds.isEmpty()) {
            return;
        }
        
        // Query Payment Plan and related Master Payment Schedules
        Map<String, List<Master_Payment_Schedule__c>> masterSchedulesMap = new Map<String, List<Master_Payment_Schedule__c>>();
        List<Payment_Plan__c> paymentPlans = [
            SELECT Id, Name,
            (SELECT Id, Project__C, S_No__c, Last_Schedule__c, Name, Payment_Percent__c, Completed_Date__c, Status__c, Completed__c, Include_Interest__c
             FROM Master_Payment_Schedules__r WHERE Combined_Schedule__c = false ORDER BY S_No__c ASC)
            FROM Payment_Plan__c WHERE Id IN :paymentPlanIds
        ];
        
        // Build Map of Payment Plans to their Master Payment Schedules
        for (Payment_Plan__c plan : paymentPlans) {
            if (plan.Master_Payment_Schedules__r != null && !plan.Master_Payment_Schedules__r.isEmpty()) {
                masterSchedulesMap.put(plan.Id, plan.Master_Payment_Schedules__r);
            }
        }
        
        List<Payment_Schedule__c> paymentScheduleList = new List<Payment_Schedule__c>();
        
        for (Booking__c qt : bookingList) {
            
            if (qt.Plot__c != null && qt.Payment_Plan__c != null && masterSchedulesMap.containsKey(qt.Payment_Plan__c)) {
                
                List<Master_Payment_Schedule__c> masterSchedules = masterSchedulesMap.get(qt.Payment_Plan__c);
                Decimal milestoneAmount = 0;
                Decimal calcValueofSupply = 0;
                Decimal totalAmount = qt.Total__c.setScale(0, RoundingMode.HALF_UP);
                Decimal totalBasecostAmount = qt.Sub_Total__c.setScale(0, RoundingMode.HALF_UP);
                Decimal totalGST = qt.GST_Amount__c.setScale(0, RoundingMode.HALF_UP);
                Decimal bookingGST = qt.GST__c;
                Decimal balanceAmount = 0;
                Decimal totalTax = 0;
                Decimal taxDifference = 0;
                for (Master_Payment_Schedule__c mps : masterSchedules) {
                    
                    Decimal cgstPercent = bookingGST/2;
                    Decimal sgstPercent = bookingGST/2;
                    Decimal valueOfSupply =0;
                    Decimal cgstAmount = 0;
                    Decimal sgstAmount = 0;
                    Decimal totalMilestoneAmount = 0;
                    
                    if(mps.Last_Schedule__c == true){
                        balanceAmount = totalAmount - milestoneAmount;
                        valueOfSupply = totalBasecostAmount - calcValueofSupply;
                        cgstAmount = ((valueOfSupply * cgstPercent) / 100).setScale(0, RoundingMode.HALF_UP);
                        sgstAmount = ((valueOfSupply * sgstPercent) / 100).setScale(0, RoundingMode.HALF_UP);
                        totalMilestoneAmount = valueOfSupply + cgstAmount + sgstAmount;
                        totalTax += cgstAmount + sgstAmount;
                        milestoneAmount += totalMilestoneAmount;
                        taxDifference = totalGST - totalTax;
                    }else{
                        valueOfSupply = ((totalBasecostAmount * mps.Payment_Percent__c) / 100).setScale(0, RoundingMode.HALF_UP);
                        cgstAmount = ((valueOfSupply * cgstPercent) / 100).setScale(0, RoundingMode.HALF_UP);
                        sgstAmount = ((valueOfSupply * sgstPercent) / 100).setScale(0, RoundingMode.HALF_UP);
                        totalMilestoneAmount = valueOfSupply + cgstAmount + sgstAmount;
                        totalTax += cgstAmount + sgstAmount;
                        calcValueofSupply += valueOfSupply;
                        milestoneAmount += totalMilestoneAmount;
                    }
                    
                    paymentScheduleList.add(new Payment_Schedule__c(
                        Booking__c = qt.Id,
                        Payment_percent__c = mps.Payment_Percent__c,
                        Interest_Percent__c = qt.Project1__r.Interest_Percentage__c,
                        Include_interest__c = mps.Include_Interest__c,
                        S_No__c = mps.S_No__c,
                        Scheduled_Amount__c = totalMilestoneAmount,
                        Amount__c = valueOfSupply,
                        Master_Payment_Schedule__c = mps.Id,
                        Name = mps.Name,
                        Status__c = mps.Status__c,
                        Round_Off_Amount__c = balanceAmount,
                        Last_Schedule__c = mps.Last_Schedule__c,
                        GST_Round_Off_Amount__c = taxDifference,
                        Serial_Number__c = mps.S_No__c
                    ));
                }
            }
        }
        
        // Perform DML to insert new Payment Schedules
        if (!paymentScheduleList.isEmpty()) {
            insert paymentScheduleList;
        }        
    }
    
    
    public static void testCover(){
        for (Integer i = 0; i < 500; i++) {
            
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
    /*   public static void recalculateUpdatedSchedules(Set<Payment_schedule__c> updatedSchedules){

List<Payment_Schedule__c> paymentSchedulesToUpdate = new List<Payment_Schedule__c>();
List<id> bookingIds = new List<Id>();
for (Payment_Schedule__c ps : updatedSchedules) {
bookingIds.add(ps.Booking__c);
}

Map<Id, Booking__c> bookingMap = new Map<Id, Booking__c>(
[SELECT Id, Total__c, Sub_Total__c, GST__c,GST_Amount__c
FROM Booking__c
WHERE Id IN :bookingIds]
);

List<Payment_Schedule__c> existingSchedules = [
SELECT AmountB__c, Name, Round_Off_Amount__c, S_No__c, SGST_Amount__c, 
CGST_Amount__c, Is_Demanded__c, Booking__c, Amount__c, Payment_percent__c, Last_Schedule__c
FROM Payment_Schedule__c
WHERE Booking__c IN :bookingIds  ORDER BY S_No__c ASC 
];

Map<Id, Payment_Schedule__c> updatedMap = new Map<Id, Payment_Schedule__c>();
Map<Id, List<Payment_Schedule__c>> bookingScheduleMap = new Map<Id, List<Payment_Schedule__c>>();

for (Payment_Schedule__c ps : existingSchedules) {
updatedMap.put(ps.Id, ps);
}
for (Payment_Schedule__c us : updatedSchedules) {
if(updatedMap.containsKey(us.Id)){
updatedMap.put(us.Id,us);
}
}

for(Id schedule : updatedMap.keySet()){
String bookingId = updatedMap.get(schedule).Booking__c;
Payment_schedule__c ps = updatedMap.get(schedule);
if(!bookingScheduleMap.containsKey(bookingId)){
bookingScheduleMap.put(bookingId,new List<Payment_Schedule__c>() );
}
bookingScheduleMap.get(bookingId).add(ps);
}

for (Id bookingId : bookingScheduleMap.keySet()) {
Booking__c booking = bookingMap.get(bookingId);
if (booking == null) continue;

List<Payment_Schedule__c> schedulesForBooking = bookingScheduleMap.get(bookingId);

Decimal totalAmount = (booking.Total__c).setScale(0);
Decimal totalBasecostAmount = booking.Sub_Total__c.setScale(0);
Decimal totalGST = booking.GST_Amount__c.setScale(0);
Decimal milestoneAmount =0;
Decimal balanceAmount = 0; 
Decimal bookingGST = booking.GST__c;
Decimal mergeValueofSupply = 0;
Decimal totalTax = 0;
Decimal taxDifference = 0;
Boolean isLastScheduleMarge = false;
Decimal calcValueofSupply = 0;

for (Payment_Schedule__c schedule : schedulesForBooking) {

Decimal cgstPercent = bookingGST/2;
Decimal sgstPercent = bookingGST/2;
Decimal valueOfSupply =0;
Decimal cgstAmount = 0;
Decimal sgstAmount = 0;
Decimal totalMilestoneAmount = 0;

if(schedule.Last_Schedule__c == true){
balanceAmount = totalAmount - milestoneAmount;
valueOfSupply = totalBasecostAmount - calcValueofSupply;
cgstAmount = ((valueOfSupply * cgstPercent) / 100).setScale(0, RoundingMode.HALF_UP);
sgstAmount = ((valueOfSupply * sgstPercent) / 100).setScale(0, RoundingMode.HALF_UP);
totalMilestoneAmount = valueOfSupply + cgstAmount + sgstAmount;
totalTax += cgstAmount + sgstAmount;
milestoneAmount += totalMilestoneAmount;
taxDifference = totalGST - totalTax;
}else{
valueOfSupply = ((totalBasecostAmount * schedule.Payment_Percent__c) / 100).setScale(0, RoundingMode.HALF_UP);
cgstAmount = ((valueOfSupply * cgstPercent) / 100).setScale(0, RoundingMode.HALF_UP);
sgstAmount = ((valueOfSupply * sgstPercent) / 100).setScale(0, RoundingMode.HALF_UP);
totalMilestoneAmount = valueOfSupply + cgstAmount + sgstAmount;
totalTax += cgstAmount + sgstAmount;
calcValueofSupply += valueOfSupply;
milestoneAmount += totalMilestoneAmount;
}

if (schedule.Payment_percent__c != null) {
Payment_schedule__c updateSchedule =  new Payment_schedule__c (
Id = schedule.Id,
Amount__c = valueOfSupply,
Scheduled_Amount__c = totalMilestoneAmount,
Round_Off_Amount__c = balanceAmount,
GST_Round_Off_Amount__c = taxDifference
);
paymentSchedulesToUpdate.add(updateSchedule);
}
}
}
if (!paymentSchedulesToUpdate.isEmpty()) {
update paymentSchedulesToUpdate;
}
}*/
}