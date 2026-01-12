public class DemandRaisedSave {
    @AuraEnabled
    public static Demand_Raised__c getDemandRaised(id recordId){
        Demand_Raised__c demand = [SELECT Total_Amount_till_Current_Milestone__c, 
                                   Total_Paid_Till__c, 
                                   Previous_pendings__c,
                                   Interest_Delay_Till_Previous_Milestone__c, 
                                   Total_Interest_Paid__c,
                                   Current_Demand_amount__c,
                                   Intrest_Amount__c,
                                   Grand_Total__c,
                                   Grand_Total_In_Words__c,
                                   Current_Milestone__c,
                                   Payment_schedule__r.Post_OC_Completion__c,
                                   Milestone_Completed_Date__c,
                                   Milestone_Number__c,
                                   Due_Date__c,
                                   Current_Milestone_Percentage__c,
                                   Total_Percentage_till_Current_Milestone__c,
                                   TDS_Amount__c,
                                   Booking__c,
                                   Project_Company__c,
                                   Total_Flat_Cost__c,
                                   Finance_User__c,
                                   Demand_Email_Content__c,
                                   Demand_Content_Ids__c,
                                   Demanded_Date__c 
                                   FROM Demand_Raised__c WHERE id =: recordId LIMIT 1];
        return demand;
    }
    @AuraEnabled
    public static void ResendRaiseDemand(list<Id> recordIds){
        if(recordIds.size() > 0){
            try {
                GenerateDocumnetController.sendEmailGenerateDemand(recordIds);
                List<Demand_Raised__c> recordsToUpdate = [SELECT Id, Demand_Email_Send__c FROM Demand_Raised__c WHERE Id IN :recordIds];
                for (Demand_Raised__c record : recordsToUpdate) {
                    record.Demand_Email_Send__c = true;
                }
                update recordsToUpdate;
            } catch (Exception e) {
                System.debug('Error during email sending: ' + e.getMessage());
                throw new AuraHandledException('Failed to resend demand. Please try again later.');
            }
        }
    }
    
    @AuraEnabled
    public Static String RaiseDemand(List<Id> bookingIds, Map<Id,String> emailContents, map<Id,List<String>> contentIds,Map<Id,String> invoiceNumbers ) {
        
        String demandRaisedReturn='';
        
        // Check if the bookingIds list is not empty
        if (bookingIds == null || bookingIds.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Booking records provided.'));
            return 'No Booking records provided';
        }
        
        // Query all the Booking records based on the provided bookingIds
        List<Booking__c> bookings = [SELECT Id,First_Applicant_Name__c,Plot__r.Name,Interest_Waive_Off__c,Total_Interest_Waive_Off__c,GST__c,Debit_Amount__c, Total__c, Name, Project__c, 
                                     Project1__r.Name, Property_Type_For__c, Block__c, Tower__c,Finance_User__c,Project1__r.Beneficiary_Account_No__c,
                                     Project1__r.Bank_Name__c,Project1__r.Branch_Name__c,Project1__r.IFSC_CODE__c
                                     FROM Booking__c 
                                     WHERE Id IN :bookingIds];
        
        // Check if there are any bookings returned
        if (bookings.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Booking records found.'));
            return 'No Booking records found';
        }
        
        // Split bookings based on Property_Type_For__c (Apartments and Villas)
        List<Booking__c> apartmentBookings = new List<Booking__c>();
        
        for (Booking__c book : bookings) {
            apartmentBookings.add(book);
        }
        
        // Call bulk apartment schedule calculations for apartment bookings
        if (!apartmentBookings.isEmpty()) {
            List<Demand_Raised__c> apartmentDemands = bulkScheduleCalculations(apartmentBookings,emailContents,contentIds,invoiceNumbers);
            if (apartmentDemands != null && !apartmentDemands.isEmpty()) {
                demandRaisedReturn = 'Demand Raise records created';
            }
        }
        
        // Return the final list of all demands raised
        return demandRaisedReturn;
    }
    
    @TestVisible
    private Static List<Demand_Raised__c> bulkScheduleCalculations(List<Booking__c> bookings,Map<Id,String> emailContents, map<Id,List<String>> contentIds,Map<Id,String> invoiceNumbers) {
        system.debug('invoiceNumbers '+invoiceNumbers);
        system.debug('bookings '+bookings);
        
        
        List<Demand_Raised__c> demands = new List<Demand_Raised__c>();
        Map<Id, Payment_Schedule__c> bookingLatestPaymentSchedules = new Map<Id, Payment_Schedule__c>();
        Map<Id, List<Payment_Schedule__c>> groupedByBooking = new Map<Id, List<Payment_Schedule__c>>();
        Map<Id, Booking__c> bookingProjectMap = new Map<Id, Booking__c>();
        map<id,Decimal> debitAmountMap = new map<id,Decimal>();
        map<id,Decimal> WaveOffMap = new map<id,Decimal>();
        
        for (Booking__c book : bookings) {
            bookingProjectMap.put(book.Id, book);
            debitAmountMap.put(book.Id, book.Debit_Amount__c);
            WaveOffMap.put(book.Id,book.Total_Interest_Waive_Off__c);
        }
        
        List<Payment_Schedule__c> psRecords = [
            SELECT Id, S_No__c, Is_Demanded__c, Booking__c,Name,Payment_percent__c,Interest_Paid__c,Received_Amount1__c,Completed_Date__c,Interest_Up_to_Date__c,AmountB__c,Interest_Amount__c,Pending_Amount__c
            FROM Payment_Schedule__c
            WHERE Status__c = 'Completed' AND Booking__c IN :bookings
            
        ];
        
        //system.debug('psRecords'+psRecords);
        
        for (Payment_Schedule__c ps : psRecords) {
            if (!groupedByBooking.containsKey(ps.Booking__c)) {
                groupedByBooking.put(ps.Booking__c, new List<Payment_Schedule__c>());
            }
            groupedByBooking.get(ps.Booking__c).add(ps);
        }
        
        for (Id bookingId : groupedByBooking.keySet()) {
            List<Payment_Schedule__c> schedules = groupedByBooking.get(bookingId);
            Decimal highestSNo = 0;
            Payment_Schedule__c latestps;
            for (Payment_Schedule__c schedule : schedules) {
                if (schedule.S_No__c != null && schedule.S_No__c > highestSNo) {
                    highestSNo = schedule.S_No__c;
                    latestps = schedule;
                }
            }
            bookingLatestPaymentSchedules.put(bookingId, latestps);         
        }
        
        List<AggregateResult> aggregateResults = [
            SELECT Booking__c, 
            SUM(Pending_Amount__c) totalPendingAmount, 
            SUM(Interest_Amount__c) totalInterestAmount,
            SUM(AmountB__c) totalPayableAmount, 
            SUM(Interest_Up_to_Date__c) totalInterestUplodate, 
            SUM(Received_Amount1__c) totalReceivedAmount,
            SUM(Interest_Paid__c) totalInterestPaid, 
            SUM(Payment_percent__c) paymentPercentageTill
            FROM Payment_Schedule__c
            WHERE Status__c = 'Completed' 
            AND Booking__c IN :bookings
            GROUP BY Booking__c
        ];
        
        Map<Id, AggregateResult> bookingToAggregateResultMap = new Map<Id, AggregateResult>();
        Map<Id, Decimal> bookingToPendingAmountMap = new Map<Id, Decimal>();
        Map<Id, Decimal> bookingToInterestAmountMap = new Map<Id, Decimal>();
        Map<Id, Decimal> bookingToPayableAmountMap = new Map<Id, Decimal>();
        Map<Id, Decimal> bookingToInterestUpToDateAmountMap = new Map<Id, Decimal>();
        Map<Id, Decimal> bookingToReceivedAmountMap = new Map<Id, Decimal>();
        Map<Id, Decimal> bookingToInterestPaidMap = new Map<Id, Decimal>();
        Map<Id, Decimal> bookingToPaymentPercentageMap = new Map<Id, Decimal>();
        
        for (AggregateResult result : aggregateResults) {
            Id bookingId = (Id) result.get('Booking__c');
            
            bookingToPendingAmountMap.put(bookingId, (Decimal) result.get('totalPendingAmount'));
            bookingToInterestAmountMap.put(bookingId, (Decimal) result.get('totalInterestAmount'));
            bookingToPayableAmountMap.put(bookingId, (Decimal) result.get('totalPayableAmount'));
            bookingToInterestUpToDateAmountMap.put(bookingId, (Decimal) result.get('totalInterestUplodate'));
            bookingToReceivedAmountMap.put(bookingId, (Decimal) result.get('totalReceivedAmount'));
            bookingToInterestPaidMap.put(bookingId, (Decimal) result.get('totalInterestPaid'));
            // Object percentVal = result.get('paymentPercentageTill');
            //Decimal paymentPercent = (percentVal != null) ? (Decimal) percentVal : 0;
            bookingToPaymentPercentageMap.put(bookingId, (Decimal) result.get('paymentPercentageTill'));
            
            bookingToAggregateResultMap.put(bookingId, result);
        }
        
        for (Id bookingId : bookingToPendingAmountMap.keySet()) {
            
            if (bookingLatestPaymentSchedules.containsKey(bookingId) && 
                bookingLatestPaymentSchedules.get(bookingId).Is_Demanded__c == true) {
                    continue;
                }
            
            system.debug('bookingLatestPaymentSchedules.get(bookingId).Pending_Amount__c'+ bookingLatestPaymentSchedules.get(bookingId));
            
            Decimal pendingAmount = bookingToPendingAmountMap.get(bookingId) - bookingLatestPaymentSchedules.get(bookingId).Pending_Amount__c;
            Decimal interestAmount = bookingToInterestAmountMap.get(bookingId) - bookingLatestPaymentSchedules.get(bookingId).Interest_Amount__c;
            Decimal payableAmount = bookingToPayableAmountMap.get(bookingId) - bookingLatestPaymentSchedules.get(bookingId).AmountB__c;
            
            Decimal receivedAmount = bookingToReceivedAmountMap.get(bookingId);
            
            if(debitAmountMap.get(bookingId) != null){
                receivedAmount -= debitAmountMap.get(bookingId);
            }
            
            Decimal PaymentPercentage = bookingToPaymentPercentageMap.get(bookingId);
            Decimal CurrentPaymentPercentage = bookingLatestPaymentSchedules.get(bookingId).Payment_percent__c;
            Decimal totalInterestUplodateAmount = bookingToInterestUpToDateAmountMap.get(bookingId) - bookingLatestPaymentSchedules.get(bookingId).Interest_Up_to_Date__c;
            Decimal totalInterestPaid = bookingToInterestPaidMap.get(bookingId);
            Decimal balanceDueTillPrevMilestoneMod = payableAmount - receivedAmount;
            Decimal balanceDueTillPrevMilestone = balanceDueTillPrevMilestoneMod > 0 ? balanceDueTillPrevMilestoneMod : 0;
            Decimal balanceInterest = totalInterestUplodateAmount - totalInterestPaid - WaveOffMap.get(bookingId);
            Decimal presentDue = bookingLatestPaymentSchedules.get(bookingId).AmountB__c;
            
            Decimal gstPercentage = (bookingProjectMap.get(bookingId).GST__c  != null) ? bookingProjectMap.get(bookingId).GST__c / 100 : 0;
            Decimal amountExcludingGST = presentDue / (1 + gstPercentage);
            
            Decimal TDSonePercentage = receivedAmount > 4999999 ? (amountExcludingGST * 0.01).setScale(0): 0;
            
            String currentMilestone = bookingLatestPaymentSchedules.get(bookingId).Name;
            Date currentMilestoneCompletedDate = bookingLatestPaymentSchedules.get(bookingId).Completed_Date__c;
            String currentMilestoneNumber =getMilestoneLabel(bookingLatestPaymentSchedules.get(bookingId).S_No__c.intValue());
            Decimal totalFlatCost = bookingProjectMap.get(bookingId).Total__c;
            id FinanceUser = bookingProjectMap.get(bookingId).Finance_User__c;
            Id currentMilestoneId = bookingLatestPaymentSchedules.get(bookingId).Id;
            
            Decimal actualTotalAmountPayable;
            actualTotalAmountPayable = (balanceDueTillPrevMilestoneMod + balanceInterest + presentDue - TDSonePercentage).setScale(0);
            
            Decimal actualTotalWithoutInterest = (balanceDueTillPrevMilestoneMod + presentDue - TDSonePercentage).setScale(0);
            Decimal TotalWithoutInterest = actualTotalWithoutInterest > 0 ? actualTotalWithoutInterest : 0;
            
            Decimal totalAmountPayable = actualTotalAmountPayable > 0 ? actualTotalAmountPayable : 0;
            
            NumberTOWordConvertion convert = new NumberTOWordConvertion();
            String totalAmountPayableInWords = convert.getNumberTOWordConvertion(totalAmountPayable);
            String TotalWithoutInterestInwords = convert.getNumberTOWordConvertion(TotalWithoutInterest);
            String totaCurrentMilestoneAmount = convert.getNumberTOWordConvertion(presentDue);
            
            List<String> allFileIds = new List<String>();
            allFileIds.addAll(contentIds.get(bookingId));
            String fileIdsString = String.join(allFileIds, ',');
            String projectIfscCode = '';
            String projectBranchName = '';
            String projectBankName = '';
            String projectBeneficiaryAccountNo = '';
            
            if (bookingProjectMap.get(bookingId).Project1__r != null) {
                projectIfscCode = (bookingProjectMap.get(bookingId).Project1__r.IFSC_CODE__c == null) ? '' : bookingProjectMap.get(bookingId).Project1__r.IFSC_CODE__c;
                projectBranchName = (bookingProjectMap.get(bookingId).Project1__r.Branch_Name__c == null) ? '' : bookingProjectMap.get(bookingId).Project1__r.Branch_Name__c;
                projectBankName = (bookingProjectMap.get(bookingId).Project1__r.Bank_Name__c == null) ? '' : bookingProjectMap.get(bookingId).Project1__r.Bank_Name__c;
                projectBeneficiaryAccountNo = (bookingProjectMap.get(bookingId).Project1__r.Beneficiary_Account_No__c == null) ? '' : bookingProjectMap.get(bookingId).Project1__r.Beneficiary_Account_No__c;
            } else {
                projectIfscCode = '';
                projectBranchName = '';
                projectBankName = '';
                projectBeneficiaryAccountNo = '';
            }
            
            system.debug('bookingId '+bookingId);
            String content = emailContents.get(bookingId);
            String invoiceNumber = invoiceNumbers.get(bookingId);
            String tdsMessage = '';
            
            if (TDSonePercentage > 0) {
                tdsMessage = 'Please pay and upload the receipt of 1% TDS amount of current milestone base amount = ' 
                    + String.valueOf(TDSonePercentage) 
                    + '%. Receipt upload link: '
                    + '<a href="https://site-speed-6226--postsbox1.sandbox.my.salesforce-sites.com/DocumentUploader?Id=' 
                    + bookingId 
                    + '&filename=TDS_' 
                    + currentMilestone.replace(' ', '_') 
                    + '_Challan_Receipt" target="_blank">Upload TDS Challan Receipt</a>';
            }
            if (String.isBlank(content)) {
                if(currentMilestoneNumber != '1st'){
                    content = ''
                        + '<div style="color: black;">'
                        + 'Dear <strong>' + bookingProjectMap.get(bookingId).First_Applicant_Name__c + '</strong>,'
                        + '</div><br/>'
                        + '<div>'
                        + '<strong>Greetings from Veegaland Developers !!</strong><br/><br/>'
                        + 'Hope this mail finds you in good health and spirit.<br/><br/>'
                        + '<strong>Sub: Requisition for release of instalment.</strong><br/>'
                        + '<strong>Ref: ' + bookingProjectMap.get(bookingId).Project1__r.Name + ', Apartment No. ' + bookingProjectMap.get(bookingId).Plot__r.Name + ' - ' + bookingProjectMap.get(bookingId).First_Applicant_Name__c + '</strong><br/><br/>'
                        + 'This is to remind you that an amount of <strong>INR '+presentDue+'/-</strong> ('+totaCurrentMilestoneAmount+') will be due against apartment No. '
                        + bookingProjectMap.get(bookingId).Plot__r.Name + ' at <strong>' + bookingProjectMap.get(bookingId).Project1__r.Name + '</strong>.<br/><br/>'
                        + 'Request you to kindly release the amount to our below mentioned bank account:<br/><br/>'
                        
                        + '<table style="border-collapse: collapse; width: 100%; font-size: 14px;" border="1">'
                        + '<tr><th style="padding: 8px; text-align: left;">Account No.</th><td style="padding: 8px;"> '+projectBeneficiaryAccountNo+' </td></tr>'
                        + '<tr><th style="padding: 8px; text-align: left;">Bank Name</th><td style="padding: 8px;"> '+projectBankName+' </td></tr>'
                        + '<tr><th style="padding: 8px; text-align: left;">Branch Name</th><td style="padding: 8px;"> '+projectBranchName+' </td></tr>'
                        + '<tr><th style="padding: 8px; text-align: left;">IFSC Code</th><td style="padding: 8px;"> '+projectIfscCode+' </td></tr>'
                        + '</table> <br/>'
                        
                        + tdsMessage
                        
                        + '<br/><br/>Thank you for choosing <strong>Veegaland Developers Pvt Ltd.</strong><br/><br/>'
                        + 'Best regards,<br/><br/>'
                        
                        + '<strong>Midhu Siju | Officer - Customer Relations | 9207054444 </strong><br/>'
                        + '<strong>Alitta Lijoy | Customer Relation Executive | 90482 37066 </strong><br/><br/>'
                        
                        + 'Veegaland Developers Pvt.Ltd.<br/>'
                        + 'Regd. Office: XIII/300 E-26, 4th Floor,<br/>'
                        + 'K Chittilappilly Tower, BMC Road,<br/>'
                        + 'Thrikkakara P.O, Ernakulam-682021<br/>'
                        + 'Tel: +91 484 2584000 / 2973944, +916235051144<br/>'
                        + '<a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a><br/><br/>'
                        
                        + 'Follow us on: '
                        + '<a href="https://www.facebook.com/veegalanddevelopers" target="_blank">Facebook</a> | '
                        + '<a href="https://www.instagram.com/veegalanddevelopers" target="_blank">Instagram</a> | '
                        + '<a href="https://www.linkedin.com/company/veegalanddevelopers" target="_blank">LinkedIn</a> | '
                        + '<a href="https://www.youtube.com/channel/veegalanddevelopers" target="_blank">YouTube</a>'
                        + '</div>';
                }else{
                    content = ''
                        + '<div style="color: black;">'
                        + 'Dear <strong>' +  bookingProjectMap.get(bookingId).First_Applicant_Name__c + '</strong>,'
                        + '</div><br/>'
                        + '<div>'
                        + '<strong>Greetings from Veegaland Developers !!</strong><br/><br/>'
                        + 'This is just to share the invoice related to the advance amount already received for Apartment No. '+ bookingProjectMap.get(bookingId).Plot__r.Name +' at '+ bookingProjectMap.get(bookingId).Project1__r.Name + '.<br/><br/>'
                        + tdsMessage
                        
                        + '<br/>Thank you for choosing <strong>Veegaland Developers Pvt Ltd.</strong><br/><br/>'
                        + 'Best regards,<br/><br/>'
                        
                        + '<strong>Midhu Siju | Officer - Customer Relations | 9207054444 </strong><br/>'
                        + '<strong>Alitta Lijoy | Customer Relation Executive | 90482 37066 </strong><br/><br/>'
                        
                        + 'Veegaland Developers Pvt.Ltd.<br/>'
                        + 'Regd. Office: XIII/300 E-26, 4th Floor,<br/>'
                        + 'K Chittilappilly Tower, BMC Road,<br/>'
                        + 'Thrikkakara P.O, Ernakulam-682021<br/>'
                        + 'Tel: +91 484 2584000 / 2973944, +916235051144<br/>'
                        + '<a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a><br/><br/>'
                        
                        + 'Follow us on: '
                        + '<a href="https://www.facebook.com/veegalanddevelopers" target="_blank">Facebook</a> | '
                        + '<a href="https://www.instagram.com/veegalanddevelopers" target="_blank">Instagram</a> | '
                        + '<a href="https://www.linkedin.com/company/veegalanddevelopers" target="_blank">LinkedIn</a> | '
                        + '<a href="https://www.youtube.com/channel/veegalanddevelopers" target="_blank">YouTube</a>'
                        + '</div>';
                }
            }
            system.debug('invoiceNumber '+invoiceNumber);
            Demand_Raised__c re = new Demand_Raised__c();
            re.Total_Amount_till_Current_Milestone__C = payableAmount;
            re.Total_Paid_Till__c = receivedAmount > 0 ? receivedAmount : 0;
            re.Previous_pendings__c = balanceDueTillPrevMilestone;
            re.Interest_Delay_Till_Previous_Milestone__c = totalInterestUplodateAmount;
            re.Total_Interest_Paid__c = totalInterestPaid;
            re.Current_Demand_amount__c = presentDue;
            re.Current_Demand_Amount_In_Words__c = totaCurrentMilestoneAmount;
            re.Intrest_Amount__c = balanceInterest;
            re.Grand_Total__c = totalAmountPayable;
            re.Grand_Total_In_Words__c = totalAmountPayableInWords;
            re.Current_Milestone__c = currentMilestone;
            re.Milestone_Completed_Date__c = currentMilestoneCompletedDate;
            re.Milestone_Number__c = currentMilestoneNumber;
            re.Due_Date__c = System.Now().addDays(7);
            re.Current_Milestone_Percentage__c = CurrentPaymentPercentage;
            re.Total_Percentage_till_Current_Milestone__c = PaymentPercentage;
            re.TDS_Amount__c = TDSonePercentage;
            re.Booking__c = bookingId;
            re.Total_Flat_Cost__c = totalFlatCost;
            re.Finance_User__c = FinanceUser;
            re.Demand_Email_Content__c = content;
            re.Demand_Content_Ids__c = fileIdsString;
            re.Demanded_Date__c = System.Now();
            re.Payment_schedule__c = currentMilestoneId;
            re.Total_Amount_Without_Interest__c = TotalWithoutInterest;
            re.Total_Amount_Without_Interest_In_words__c = TotalWithoutInterestInwords;
            re.Demand_Email_Send__c = true;
            re.Invoice_Serial_Number__c = invoiceNumber;
            demands.add(re); // Add the record to the list
        }
        
        // Insert all Demand_Raised__c records into the database
        if (!demands.isEmpty()) {
            insert demands;
        }
        list<Payment_Schedule__c> updatePS = new list<Payment_Schedule__c>();
        for (Id bookingId : bookingLatestPaymentSchedules.keySet()) {
            Payment_Schedule__c schedule = bookingLatestPaymentSchedules.get(bookingId);
            schedule.Is_Demanded__c = true;
            updatePS.add(schedule);
        }
        if(!updatePS.isEmpty()){
            update updatePS;
        }
        return demands;
    }
    
    
    public static Map<Integer, String> daySuffixMap = new Map<Integer, String>{1 => 'st', 2 => 'nd', 3 => 'rd', 21 => 'st', 22 => 'nd', 23 => 'rd', 31 => 'st'};
        public static String getMilestoneLabel(Integer sNo) {
            if (sNo == null) {
                return 'Invalid milestone';
            }
            // Determine the suffix, default to 'th'
            String suffix = daySuffixMap.containsKey(sNo) ? daySuffixMap.get(sNo) : 'th';
            
            return sNo + suffix;
        }
    @AuraEnabled
    public static BookingWrapper getBookingRecord(Id recordId) {
        Booking__c booking = [
            SELECT Id, Project_Company__c, Project__c, Project1__r.Name, Agreement_Cost__c, Bank__c, 
            Total_received_Amount__c, First_Applicant_Name__c, salutation_Applicant1__c,Plot__r.Name,Total__c,
            salutation_Applicant2__c, Second_Applicant_Name__c
            FROM Booking__c 
            WHERE Id = :recordId 
            LIMIT 1
        ];
        
        List<Payment_Schedule__c> psRecordList = [
            SELECT Id, Name, S_No__c, Completed_Date__c, Payment_percent__c
            FROM Payment_Schedule__c
            WHERE Status__c = 'Completed' AND Booking__c = :recordId
            ORDER BY S_No__c DESC 
            LIMIT 1
        ];
        
        Payment_Schedule__c currentMilestone = psRecordList.isEmpty() ? null : psRecordList[0];
        
        // Return the wrapper instance
        return new BookingWrapper(booking, currentMilestone);
    }
    
    public class BookingWrapper {
        @AuraEnabled
        public Booking__c booking { get; set; }
        @AuraEnabled
        public Payment_Schedule__c currentMilestone { get; set; }
        
        // Constructor
        public BookingWrapper(Booking__c booking, Payment_Schedule__c currentMilestone) {
            this.booking = booking;
            this.currentMilestone = currentMilestone;
        }
    }
    
}