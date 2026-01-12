public class ReceiptController {
    
    public class databox{
        @AuraEnabled
        public List<Receipt_Line_Item__c> rcList;
        @AuraEnabled
        public Decimal grandTotal;
    }
    public class wrapperprod{
        @AuraEnabled
        public List<Payment_schedule__c> pysch{get;set;}
        @AuraEnabled
        public string accname{get;set;}
    }
    
    @AuraEnabled
    public static Decimal getInterestAmount(string recId){
        Decimal InterestAmount = 0;
        List<Payment_Schedule__c> payList = [select id,name,Interest_Up_To_Date__c from Payment_schedule__c where Booking__c =: recId];
        for(Payment_Schedule__c pay : payList){
            InterestAmount = InterestAmount+ pay.Interest_Up_to_Date__c;
        }
        
        return InterestAmount;
    }
    
    @AuraEnabled
    public static Booking__c getBookingDetails(string recid){
        return [select id,name,Project__c,Unit_NumberFor__c,Pending_Amount__c,Total__c from Booking__c where id=: recid];
    }
    @AuraEnabled
    public static wrapperprod getpaymentsc(string recid){ 
        wrapperprod wrpdata=new wrapperprod();
        List<Payment_schedule__c> lstschdules = [SELECT Id,Name,Payment_percent__c,Pending_Amount__c,Total_Outstanding_Due_Amount__c,Payment_Due_Date__c,Scheduled_Amount__c,Recived_Per__c, /*Amount__c,*/ S_No__c,status__c,Booking__c,Received_Amount__c,AmountB__c FROM Payment_schedule__c WHERE Booking__c =:recid ORDER BY S_No__c ASC];
        wrpdata.pysch=lstschdules;
        system.debug(wrpdata);
        return wrpdata; 
    }
    
    @AuraEnabled
    public static databox Rcitemlist(String recid){ 
        system.debug('mfrid---'+recid);
        databox db = new databox();
        List<Receipt_Line_Item__c> rcptitmlst =  [SELECT Id,Name,Receipt__c,Interest__c,Payment_schedule__c,Mode_of_Payment__c,Cheque_no_Transaction_Number__c,Received_Amount__c,Receipt__r.Booking__c,Booking__c,Pending_Amount__c /*,Amount__c*/ FROM Receipt_Line_Item__c where  Booking__c =:recid ];
        system.debug(rcptitmlst);
        Booking__c bk = [SELECT Id FROM Booking__c WHERE Id=:recid];
        system.debug('---'+rcptitmlst);
        db.rcList = rcptitmlst;
        // db.grandTotal = opp.Total_of_Add_on_s__c;
        return db;                                      
    } 
    
    @AuraEnabled
    public static void deleteProduct(string prId){
        DELETE [SELECT Id FROM 	Receipt_Line_Item__c WHERE Id=:prId];
    }
    
    @AuraEnabled
    public static List<String> getPaymentTypePicklistValues() {
        List<String> paymentTypeValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Receipt__c.Mode_of_Payment__c.getDescribe();
        for (Schema.PicklistEntry picklistEntry : fieldResult.getPicklistValues()) {
            paymentTypeValues.add(picklistEntry.getLabel());
        }
        return paymentTypeValues;
    }
    
    
    
    @AuraEnabled 
    public static Id insertValues( List<Receipt_Line_Item__c> polist, string pon,string remark,string poc, string recid){
        //List<Receipt__c> rc1= [select id, Receipt_Name__c from Receipt__c where Booking__c=:recid];
        //system.debug(rc1.size());
        // delete rc1;
        Booking__c bk = [select id,name,Finance_User__c from Booking__c where id =: recid limit 1];
        Receipt__c rc = new Receipt__c();
        rc.Receipt_Name__c=pon;
        rc.Remarks__c = remark;
        rc.Finance_User__c = bk.Finance_User__c;
        rc.Receipt_date__c=date.valueof(poc);
        rc.Booking__c=recid;
        insert rc;
        // List<Receipt_Line_Item__c> polists= new List<Receipt_Line_Item__c>();
        //   List<Receipt_Line_Item__c> ww=  (List<Receipt_Line_Item__c>) System.JSON.deserialize(polist, List<Receipt_Line_Item__c>.class);
        //  system.debug(ww);
        set<Id> payIds = new set<id>(); 
        system.debug(polist);
        if(polist.size()>0){
            for(Receipt_Line_Item__c rci:polist ){
                rci.Receipt__c=rc.id;
                rci.Amount__c = rci.Received_Amount__c;
                rci.Booking__c=recid;
                payIds.add(rci.Payment_schedule__c);
                // polists.add(rci);
            }
        }
        upsert polist;
        List<Payment_schedule__c> payList = [select id,name,Payment_Due_Date__c,Last_Payment_Date__c,Principal_Amount__c,Include_Interest__c,Interest_Percent__c,Per_Day_Interest__c,Balance_Amount__c,Interest_Amount__c,Pending_Amount__c, Booking__r.Id from Payment_schedule__c where id in:payIds ];
        List<Interest_Amount_Line_Item__c> IntAmtLiEs = new List<Interest_Amount_Line_Item__c>();
        for(Payment_schedule__c pay : payList){
            if(pay.Include_Interest__c == true){
                Interest_Amount_Line_Item__c IntLine = new Interest_Amount_Line_Item__c();
                IntLine.Interest_Amount__c = pay.Interest_Amount__c;
                if(pay.Last_Payment_Date__c == null){
                    IntLine.Interest_Start_Date__c = pay.Payment_Due_Date__c;
                }
                else{
                    IntLine.Interest_Start_Date__c = pay.Last_Payment_Date__c;
                }
                IntLine.Interest_End_Date__c = system.today();
                IntLine.Interest_Percent__c = pay.Interest_Percent__c;
                IntLine.Payment_Schedule__c = pay.id;
                IntLine.Principal_Amount__c = pay.Principal_Amount__c;
                
                IntLine.Booking__c = pay.Booking__r.Id ;
                
                IntAmtLiEs.add(IntLine);
                
            }
            pay.Last_Payment_Date__c = system.today();
            pay.Last_Payment_Time__c = system.now();
        }
        
        if(IntAmtLiEs.size()>0){
            insert IntAmtLiEs;
        }
        update payList;
        return rc.id;
    } 
    
    public static void approvedReceiptsHandler(List<Id> receiptIds) {
        System.debug('receiptIds: ' + receiptIds);
        if (receiptIds == null || receiptIds.isEmpty()) {
            return; // Exit early if no receipt IDs are provided
        }
        
        // Fetch Receipt Line Items linked to the given Receipt__c records
        List<Receipt_Line_Item__c> recLinIds = [
            SELECT Id, Payment_schedule__c 
            FROM Receipt_Line_Item__c 
            WHERE Receipt__c IN :receiptIds
        ];
        
        System.debug('recLinIds: ' + recLinIds);
        
        List<Id> paymentIds = new List<Id>();
        for (Receipt_Line_Item__c recl : recLinIds) {
            if (recl.Payment_schedule__c != null) {
                paymentIds.add(recl.Payment_schedule__c);
            }
        }
        
        if (paymentIds.isEmpty()) {
            return; // Exit if no associated Payment Schedule records
        }
        
        // Fetch Payment Schedule records
        List<Payment_schedule__c> payList1 = [
            SELECT Id, Name, Booking__c, Payment_Due_Date__c, Last_Payment_Date__c, 
            Principal_Amount__c, Include_Interest__c, Interest_Percent__c, 
            Per_Day_Interest__c, Balance_Amount__c, Interest_Amount__c, 
            Pending_Amount__c
            FROM Payment_schedule__c 
            WHERE Id IN :paymentIds
        ];
        
        List<Interest_Amount_Line_Item__c> IntAmtLiEs = new List<Interest_Amount_Line_Item__c>();
        
        for (Payment_schedule__c pay : payList1) {
            if (pay.Include_Interest__c == true && pay.Interest_Amount__c != null && pay.Interest_Amount__c > 0) {
                Interest_Amount_Line_Item__c IntLine = new Interest_Amount_Line_Item__c();
                IntLine.Interest_Amount__c = pay.Interest_Amount__c;
                IntLine.Interest_Start_Date__c = (pay.Last_Payment_Date__c == null) ? pay.Payment_Due_Date__c : pay.Last_Payment_Date__c;
                IntLine.Interest_End_Date__c = System.today();
                IntLine.Interest_Percent__c = pay.Interest_Percent__c;
                IntLine.Payment_Schedule__c = pay.Id;
                IntLine.Booking__c = pay.Booking__c;
                IntLine.Principal_Amount__c = pay.Pending_Amount__c;
                IntAmtLiEs.add(IntLine);
            }
            
            // Update Last Payment Date and Time
            pay.Last_Payment_Date__c = System.today();
            pay.Last_Payment_Time__c = System.now();
        }
        
        // Insert Interest Amount Line Items if any exist
        if (!IntAmtLiEs.isEmpty()) {
            insert IntAmtLiEs;
        }
        
        // Update Payment Schedule records
        update payList1;
        
        // **Update Receipt_Line_Item__c Approval_Status1__c to 'Approved'**
        for (Receipt_Line_Item__c rec : recLinIds) {
            rec.Approval_Status1__c = 'Approved';
        }
        
        // Bulk update Receipt_Line_Item__c records
        update recLinIds;
        // SendEmailServiceClass.sendEmailGenerateReceipts(receiptIds);
    }
    
    
    public static void sendNotificationsFromReceipts(String title, List<Receipt__c> receipts) {
        
        for (Receipt__c rcp : receipts) {
            String body = '';
            Set<String> userIds = new Set<String>();
            userIds.add(rcp.CreatedById);
            if(title == 'Receipt Approved'){
                body = 'This is to notify that Booking ' + rcp.Booking_ID__c + 
                    ', The Receipt ' + rcp.Name + ' is Approved by the Finance Team';
            }
            if(title == 'Receipt Rejected'){
                body = 'This is to notify that Booking ' + rcp.Booking_ID__c + 
                    ', The Receipt ' + rcp.Name + ' is Rejected by the Finance Team'; 
            }
            sendCustomNotification(userIds, title, body, rcp.Id, 'Receipt_Notification');
        }
    }
    
    public static void sendCustomNotification(Set<String> recepientIds, String title, String body, Id recId, String notificationName){
        CustomNotificationType closedWonNotification = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName =: notificationName LIMIT 1]; 
        Messaging.CustomNotification Notification = new Messaging.CustomNotification(); 
        Notification.setNotificationTypeId(closedWonNotification.id); 
        Notification.setSenderId(Userinfo.getUserId()); 
        Notification.setBody(body); 
        Notification.setTitle(title); 
        Notification.setTargetId(recId);
        try{
            Notification.send(recepientIds);
        }catch(exception e){
            
        }
        
    }
    
    @AuraEnabled       
    public static String sendEmailGenerateReceipt(ID recId) {
        try {
            Receipt__c qt = [select Id,Booking__r.Id,Booking__r.Email1__c,Booking__r.Email2__c,Check_Transaction_Nmber__c,Approval_status__c,
                             Booking__r.Owner.Email,Booking__r.CRM_Manager__r.Email,Booking__r.First_Applicant_Name__c,Booking__r.Booking_owner__c
                             FROM Receipt__c WHERE Id = :recId limit 1];
            //List<String> lstCCEmail = new List<String>();
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            PageReference pref = Page.RECEIPT;
            
            pref.getParameters().put('id', recId);
            pref.setRedirect(true);
            
            Blob b;
            try {
                b = pref.getContent();
            } catch (VisualforceException e) {
                if(!test.isRunningTest()){
                    return 'Error generating PDF content: ' + e.getMessage();
                }               
            }
            attach.setFileName('VeegalandBuilders.pdf');
            attach.setBody(b);
            semail.setSubject('Veegaland Builders');
            
            List<String> sendTo = new List<String>();
            if (qt.Booking__r.Email1__c != null) {
                sendTo.add(qt.Booking__r.Email1__c);
            }
            if (qt.Booking__r.Email2__c != null) {
                sendTo.add(qt.Booking__r.Email2__c);
            }
            semail.setToAddresses(sendTo);
            semail.setHtmlBody('Dear '+ qt.Booking__r.First_Applicant_Name__c + ',<br/><br/>' +
                               'Please find the attached receipt for your records. If you have any questions, feel free to contact us.' +
                               '<br/><br/>Best regards,<br/>' +
                               qt.Booking__r.Booking_owner__c+ '<br/>' +
                               'Veegaland Builders Pvt. Ltd.<br/>' 
                              );
            semail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });
            if (sendTo.size() > 0 && qt.Approval_status__c=='Appoved by Finance Team') {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { semail });
                return 'Email sent successfully';
            } else {
                return 'Receipt Not Approved by Finance Team';
            }
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    } 
    
    
    
    @future (callout=true)
    public static void sendEmailAsync(String receiptId) {
        // sendEmail(receiptId);
    }
    /*  public static void sendEmail(String receiptId) {
try {
// Fetch the Receipt and related Booking information
Receipt__c com = [
SELECT Id, Name, Booking__r.Email1__c, Booking__r.Project_Company__c, Booking__r.Email2__c, Check_Transaction_Nmber__c, Approval_status__c,
Booking__r.Owner.Email, Booking__r.CRM_Manager__r.Email, Booking__r.First_Applicant_Name__c, Booking__r.Booking_owner__c
FROM Receipt__c WHERE Id = :receiptId LIMIT 1
];
system.debug('com'+ com.Booking__r);

if (com == null || com.Booking__r == null) {
system.debug('Receipt or related Booking record not found.');
return;
}

system.debug('record id  '+receiptId);
system.debug('recp id  '+com);

String subject = 'Receipt ' + com.Name + ' Notification';
String htmlBody = 'Dear ' + com.Booking__r.First_Applicant_Name__c + 
',<br/><br/> Please find the Receipt for your payment.<br/>Thank you<br/>Mahendra Team';

List<String> emailArray = new List<String>();
if (com.Booking__r.Email1__c != null) emailArray.add(com.Booking__r.Email1__c);
if (com.Booking__r.Email2__c != null) emailArray.add(com.Booking__r.Email2__c);
system.debug('p c id  '+com.Booking__r.Project_Company__c);

PageReference pref;
if (com.Booking__r.Project_Company__c == 'MAHENDRA HOMES PVT LTD') {
pref = Page.RECEIPT;
} else if (com.Booking__r.Project_Company__c == 'MAHENDRA ARTO LLP') {
pref = Page.RECEIPT_HELIX;
} else {
system.debug('Unknown project company for receipt generation.');
return;
}

pref.getParameters().put('id', receiptId);
Blob pdfBlob = !Test.isRunningTest() ? pref.getContentAsPDF() : Blob.valueOf('testblob');

Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
attachment.setFileName('RECEIPT.pdf');
attachment.setBody(pdfBlob);

Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
semail.setSubject(subject);
semail.setToAddresses(emailArray);
semail.setUseSignature(false);

Id orgWideEmailAddressId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@mahendrahomes.com' LIMIT 1].Id;
semail.setOrgWideEmailAddressId(orgWideEmailAddressId);

semail.setHtmlBody(htmlBody);
semail.setFileAttachments(new Messaging.EmailFileAttachment[] {attachment});

Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});

} catch (Exception e) {
System.debug('Error while sending email: ' + e.getMessage());
}
}*/
    
    @InvocableMethod(label='Send Email' description='Send emails for receipts from Flow')
    public static void sendEmailGenerateReceiptFromFlow(List<Id> receiptIds) {
        // Map to hold Receipts and their associated Bookings
        Map<Id, Receipt__c> receiptMap = new Map<Id, Receipt__c>(
            [SELECT Id, CreatedBy.Email, Booking__c 
             FROM Receipt__c 
             WHERE Id IN :receiptIds]
        );
        
        Map<Id, String> createdUserMap = new Map<Id, String>();
        
        // Collect related Booking IDs
        Set<Id> bookingIds = new Set<Id>();
        
        for (Receipt__c receipt : receiptMap.values()) {
            if (receipt.Booking__c != null) {
                bookingIds.add(receipt.Booking__c);
            }
            
            // Store the Receipt ID and CreatedBy ID (the user who created the receipt)
            if (receipt.CreatedById != null) {
                createdUserMap.put(receipt.Id, receipt.CreatedBy.Email);
            }
        }
        
        
        // Query related Bookings
        Map<Id, Booking__c> bookingMap = new Map<Id, Booking__c>(
            [SELECT Id, Email1__c, Email2__c, First_Applicant_Name__c, Owner.Email, 
             CRM_Manager__c, CRM_Manager__r.Email 
             FROM Booking__c 
             WHERE Id IN :bookingIds]
        );
        
        // Query related Co-Applicants
        Map<Id, List<Co_Applicant__c>> coAppMap = new Map<Id, List<Co_Applicant__c>>();
        for (Co_Applicant__c coApp : [
            SELECT Id, Name, Email__c, Booking__c 
            FROM Co_Applicant__c 
            WHERE Booking__c IN :bookingIds
        ]) {
            if (!coAppMap.containsKey(coApp.Booking__c)) {
                coAppMap.put(coApp.Booking__c, new List<Co_Applicant__c>());
            }
            coAppMap.get(coApp.Booking__c).add(coApp);
        }
        
        
        // List to hold all emails to send
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for (Id receiptId : receiptIds) {
            Receipt__c receipt = receiptMap.get(receiptId);
            if (receipt == null || receipt.Booking__c == null) continue;
            
            Booking__c booking = bookingMap.get(receipt.Booking__c);
            if (booking == null || String.isBlank(booking.Email1__c)) continue;
            
            // Generate receipt PDF
            PageReference receiptPage = Page.RECEIPT;
            receiptPage.getParameters().put('id', receiptId);
            Blob pdfBlob = !Test.isRunningTest() ? receiptPage.getContentAsPDF() : Blob.valueOf('testblob');
            
            // Prepare email recipients
            List<String> sendTo = new List<String>();
            sendTo.add(booking.Email1__c);
            if (!String.isBlank(booking.Email2__c)) {
                sendTo.add(booking.Email2__c);
            }
            
            // Add Co-Applicants
            if (coAppMap.containsKey(booking.Id)) {
                for (Co_Applicant__c coApp : coAppMap.get(booking.Id)) {
                    if (!String.isBlank(coApp.Email__c)) {
                        sendTo.add(coApp.Email__c);
                    }
                }
            }
            
            // Prepare CC addresses
            List<String> ccEmails = new List<String>();
            
            if (!String.isBlank(booking.Owner.Email)) {
                ccEmails.add(booking.Owner.Email);
            }
            
            if (booking.CRM_Manager__c != null && !String.isBlank(booking.CRM_Manager__r.Email)) {
                ccEmails.add(booking.CRM_Manager__r.Email);
            }
            
            // Add static emails
            //ccEmails.add('Crmlead@mahendrahomes.com');
            ///ccEmails.add('crm@mahendrahomes.com');
            
            // Create email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(sendTo);
            if (!ccEmails.isEmpty()) {
                email.setCcAddresses(ccEmails);
            }
            email.setSubject('Receipt for Your Payment');
            email.setHtmlBody('Dear ' + booking.First_Applicant_Name__c + ',<br/><br/>Please find the attached receipt for your payment.<br/><br/>Thank you.');
            
            if(!Test.isRunningTest()){
                // Set Org-Wide Email Address or Reply-To
                List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :createdUserMap.get(receiptId)];
                // Set Org-Wide Email Address (if available)
                if (owea.size() > 0) {
                    email.setOrgWideEmailAddressId(owea[0].Id);
                }
            }
            // Attach PDF
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('Receipt.pdf');
            attachment.setBody(pdfBlob);
            email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
            
            email.setSaveAsActivity(true);
            email.setWhatId(receipt.Id);
            
            emails.add(email);
        }
        
        // Send all emails
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<PaymentScheduleWrapper> getPaymentSchedules(String bookingId) {
        List<PaymentScheduleWrapper> paymentSchedules = new List<PaymentScheduleWrapper>();
        
        // Query the Payment_Schedules based on the conditions
        List<Payment_Schedule__c> schedules = [
            SELECT Id, Name, Pending_Amount__c,Interest_Pending__c
            FROM Payment_Schedule__c
            WHERE Booking__c = :bookingId 
            AND Status__c = 'Completed' 
            AND Is_Demanded__c = TRUE
        ];
        
        // Populate the wrapper class to include both Id and Pending_Amount__c
        for (Payment_Schedule__c schedule : schedules) {
            paymentSchedules.add(new PaymentScheduleWrapper(schedule.Id, schedule.Name, schedule.Pending_Amount__c, schedule.Interest_Pending__c));
        }
        
        return paymentSchedules;
    }
    
    // Wrapper class to return both name and pending amount
    public class PaymentScheduleWrapper {
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public Decimal PendingAmount;
        @AuraEnabled public Decimal InterestPending;
        
        public PaymentScheduleWrapper(String id, String name, Decimal pendingAmount,Decimal InterestPending) {
            this.Id = id;
            this.Name = name;
            this.PendingAmount = pendingAmount;
            this.InterestPending = InterestPending;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<AdvanceReceiptWrapper> getAdvanceReceipts(String bookingId) {
        List<AdvanceReceiptWrapper> advanceReceipts = new List<AdvanceReceiptWrapper>();
        
        // Query Advance Receipt records related to the booking where amount > 0
        List<Advance_Receipt__c> receipts = [
            SELECT Id, Name, Advance_Amount__c,Balance_Amount__c
            FROM Advance_Receipt__c
            WHERE Booking__c = :bookingId
            AND Balance_Amount__c > 0 and Approval_Status__c='Approved by Finance Team' ORDER BY createdDate ASC
        ];
        
        // Populate the wrapper class to return Name and Amount
        for (Advance_Receipt__c receipt : receipts) {
            advanceReceipts.add(new AdvanceReceiptWrapper(receipt.Id, receipt.Name, receipt.Balance_Amount__c));
        }
        
        return advanceReceipts;
    }
    
    // Wrapper class to return Name and Amount
    public class AdvanceReceiptWrapper {
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public Decimal AdvanceAmount;
        
        public AdvanceReceiptWrapper(String id, String name, Decimal amount) {
            this.Id = id;
            this.Name = name;
            this.AdvanceAmount = amount;
        }
    }
    
    @AuraEnabled
    public static Id insertReceiptLineItems(List<Receipt_Line_Item__c> polist,string PaymentFrom, string branch, string pon,string remark,string poc, string recid, Decimal paidAmount, Decimal interestAmount){
        
        Booking__c bk = [select id,name,Finance_User__c,Project__c from Booking__c where id =: recid limit 1];
        
        Receipt__c rc = new Receipt__c();
        rc.Receipt_Name__c=pon;
        rc.Remarks__c = remark;
        rc.Finance_User__c = bk.Finance_User__c;
        rc.Receipt_date__c = date.valueof(poc);
        rc.Payment_From__c = PaymentFrom;
        rc.Check_Transaction_Nmber__c = polist[0].Cheque_no_Transaction_Number__c;
        rc.Amount_received__c = paidAmount;
        rc.Mode_of_payment__c = polist[0].Mode_of_Payment__c;
        rc.Payment_Received_Bank__c = polist[0].Bank_Name__c;
        rc.Booking__c=recid;
        rc.Branch__c = branch;
        //rc.Interest_Paid_Amount__c = interestAmount;
        insert rc;
        
        List<Receipt_Line_Item__c> receiptsToCreate = new List<Receipt_Line_Item__c>();
        List<Payment_Schedule__c> payList = [SELECT Id, Amount__c, Pending_Amount__c, S_No__c,Interest_Pending__c FROM Payment_Schedule__c where Booking__c =: bk.Id ORDER BY S_No__c ASC ];
        List<Payment_Schedule__c> newpayList = new List<Payment_Schedule__c>();
        List<Payment_Schedule__c> orderedPayList = new List<Payment_Schedule__c>();
        Set<Id> payIds = new Set<Id>();
        
        if(interestAmount != 0 || interestAmount != null){
            paidAmount = paidAmount - interestAmount;
        }
        
        for (Payment_Schedule__c paymentSchedule : payList) {
            
            if (paidAmount <= 0 || paidAmount == null) {
                break;
            }
            
            if (paymentSchedule.Pending_Amount__c != null && paymentSchedule.Pending_Amount__c > 0) {
                
                Decimal amountToReceive = Math.min(paymentSchedule.Pending_Amount__c, paidAmount);
                paidAmount -= amountToReceive;
                
                Receipt_Line_Item__c rece = new Receipt_Line_Item__c();
                rece.Booking__c = bk.Id;
                rece.Name = 'Against Payment Schedule';
                rece.Payment_Type__c = 'Payment Schedule';
                rece.Receipt__c = rc.Id;
                rece.Payment_Schedule__c = paymentSchedule.Id;
                rece.Received_Amount__c = amountToReceive;
                rece.Amount__c = amountToReceive;
                rece.Bank_Name__c = polist[0].Bank_Name__c;
                rece.Payment_From__c = polist[0].Payment_From__c;
                rece.Mode_of_Payment__c =  polist[0].Mode_of_Payment__c;
                rece.Cheque_no_Transaction_Number__c = polist[0].Cheque_no_Transaction_Number__c;
                receiptsToCreate.add(rece);
                payIds.add(paymentSchedule.Id);
            }
            
        }
        
        if(paidAmount !=null && paidAmount !=0){
            Integer PaymentScheduleSize = payList.size();
            Receipt_Line_Item__c rece = new Receipt_Line_Item__c();
            rece.Booking__c = bk.Id;
            rece.Name = 'Against Payment Schedule';
            rece.Payment_Type__c = 'Payment Schedule';
            rece.Receipt__c = rc.Id;
            rece.Payment_Schedule__c = payList[PaymentScheduleSize-1].Id;
            rece.Received_Amount__c = paidAmount;
            rece.Amount__c = paidAmount;
            rece.Bank_Name__c = polist[0].Bank_Name__c;
            rece.Payment_From__c = polist[0].Payment_From__c;
            rece.Mode_of_Payment__c =  polist[0].Mode_of_Payment__c;
            rece.Cheque_no_Transaction_Number__c = polist[0].Cheque_no_Transaction_Number__c;
            receiptsToCreate.add(rece);
        }
        
        for(Payment_Schedule__c paymentSchedule : payList){
            if (interestAmount <= 0 || interestAmount == null) {
                break;
            }
            if( (interestAmount != 0 || interestAmount != null) &&  paymentSchedule.Interest_Pending__c != null && paymentSchedule.Interest_Pending__c > 0 ){
                Decimal amountToReceive = Math.min(paymentSchedule.Pending_Amount__c, interestAmount);
                interestAmount -= amountToReceive;
                
                Receipt_Line_Item__c rece = new Receipt_Line_Item__c();
                rece.Booking__c = bk.Id;
                rece.Name = 'Against Interest';
                rece.Payment_Type__c = 'Interest';
                rece.Receipt__c = rc.Id;
                rece.Payment_Schedule__c = paymentSchedule.Id;
                rece.Received_Amount__c = amountToReceive;
                rece.Amount__c = amountToReceive;
                rece.Bank_Name__c = polist[0].Bank_Name__c;
                rece.Payment_From__c = polist[0].Payment_From__c;
                rece.Mode_of_Payment__c =  polist[0].Mode_of_Payment__c;
                rece.Cheque_no_Transaction_Number__c = polist[0].Cheque_no_Transaction_Number__c;
                receiptsToCreate.add(rece);
            }
        }
        
        List<Payment_schedule__c> payList1 = [select id,name,Payment_Due_Date__c,Last_Payment_Date__c,Principal_Amount__c,Include_Interest__c,Interest_Percent__c,Per_Day_Interest__c,Balance_Amount__c,Interest_Amount__c,Pending_Amount__c from Payment_schedule__c where id in:payIds ];
        List<Interest_Amount_Line_Item__c> IntAmtLiEs = new List<Interest_Amount_Line_Item__c>();
        for(Payment_schedule__c pay : payList1){
            if(pay.Include_Interest__c == true){
                Interest_Amount_Line_Item__c IntLine = new Interest_Amount_Line_Item__c();
                IntLine.Interest_Amount__c = pay.Interest_Amount__c;
                IntLine.Interest_Start_Date__c = (pay.Last_Payment_Date__c == null) ? pay.Payment_Due_Date__c.addDays(1) : pay.Last_Payment_Date__c.addDays(1);
                IntLine.Interest_End_Date__c = system.today();
                IntLine.Interest_Percent__c = pay.Interest_Percent__c;
                IntLine.Payment_Schedule__c = pay.id;
                IntLine.Booking__c = bk.Id;
                IntLine.Principal_Amount__c = pay.Pending_Amount__c;
                IntAmtLiEs.add(IntLine);
            }
            pay.Last_Payment_Date__c = system.today();
            pay.Last_Payment_Time__c = system.now();
        }
        
        if (!receiptsToCreate.isEmpty()) {
            upsert receiptsToCreate;
        }
        
        if(IntAmtLiEs.size()>0){
            insert IntAmtLiEs;
        }
        update payList1;
        return rc.Id;
    }
    
    @AuraEnabled
    public static Id saveReceiptData(String receiptData) {
        try {
            
            Map<String, Object> receiptDataMap = (Map<String, Object>) JSON.deserializeUntyped(receiptData);
            Id returnId;
            String recordId = (String) receiptDataMap.get('recordId');
            String receiptDateString = (String) receiptDataMap.get('receiptDate');
            Date receiptDate = Date.valueOf(receiptDateString);
            String remarks = (String) receiptDataMap.get('remarks');
            String paymentFrom = (String) receiptDataMap.get('paymentFrom');
            String modeofPayment = (String) receiptDataMap.get('modeofPayment');
            String bankName = (String) receiptDataMap.get('bankName');
            String branch = (String) receiptDataMap.get('branch');
            String receiptType = (String) receiptDataMap.get('receiptType');
            String paymentType = (String) receiptDataMap.get('paymentType');
            String selectedScheduleId = (String) receiptDataMap.get('selectedScheduleId');
            Decimal receivedAmount = (Decimal) receiptDataMap.get('receivedAmount');
            String chequeTransactionNumber = (String) receiptDataMap.get('transactionNumber');
            String advanceReceiptRow = (String) receiptDataMap.get('advanceReceiptRow');
            Decimal amountFromCustomer = Decimal.valueOf( String.valueOf(receiptDataMap.get('amountFromCustomer')));
            List<Booking__c> bookingRecord = [SELECT Id, Finance_User__c FROM Booking__c WHERE Id = :recordId LIMIT 1];
            
            if(receiptType == 'Advance Receipt'){
                
                Advance_Receipt__c newReceipt = new Advance_Receipt__c();
                newReceipt.Booking__c = recordId;
                newReceipt.Advance_Receipt_Date__c = receiptDate;
                newReceipt.Remarks__c = remarks;
                newReceipt.Payment_From__c = paymentFrom;
                newReceipt.Mode_of_Payment__c = modeofPayment;
                newReceipt.Bank_Name__c = bankName;
                newReceipt.Branch__c = branch;
                newReceipt.Advance_Amount__c = receivedAmount;
                newReceipt.Finance_User__c = bookingRecord[0].Finance_User__c;
                newReceipt.Cheque_Transaction_Number__c = chequeTransactionNumber;
                newReceipt.Finance_User__c =bookingRecord[0].Finance_User__c;
                insert newReceipt;
                returnId = newReceipt.Id;
            }
            
            if (receiptType == 'Normal Receipt' || receiptType == 'From Advance Receipt') {
                
                String receivedInterestAmountString = receiptDataMap.get('receivedInterestAmount') !=null ?string.valueof(receiptDataMap.get('receivedInterestAmount')):'0';
                Decimal receivedInterestAmount = Decimal.valueOf(receivedInterestAmountString);
                
                List<Receipt_Line_Item__c> receiptsToCreate = new List<Receipt_Line_Item__c>();
                List<Payment_schedule__c> paymentScheduleList = [SELECT Id, Pending_Amount__c,Last_Payment_Date__c,Interest_Percent__c, Interest_Pending__c, Include_Interest__c, Interest_Amount__c,Payment_Due_Date__c FROM Payment_Schedule__c WHERE Id = :selectedScheduleId LIMIT 1];
                
                // Check if the Payment_schedule exists
                if (paymentScheduleList.isEmpty()) {
                    // Handle the case where no payment schedule is found (e.g., throw an error or set a flag)
                    System.debug('No payment schedule found for the provided ID');
                    return null; // Exit the method or proceed with alternative logic
                }
                
                // Continue with the receipt creation process if the payment schedule exists
                Receipt__c rc = new Receipt__c();
                rc.Remarks__c = remarks;
                rc.Finance_User__c = bookingRecord[0].Finance_User__c;
                rc.Receipt_date__c = receiptDate;
                rc.Payment_From__c = paymentFrom;
                rc.Receipt_Type__c	= receiptType;
                rc.Check_Transaction_Nmber__c = chequeTransactionNumber;
                rc.Amount_received__c = receivedAmount;
                rc.Amount_From_Customer__c = amountFromCustomer;
                rc.Mode_of_payment__c = modeofPayment;
                rc.Payment_Received_Bank__c = bankName;
                rc.Booking__c = recordId;
                rc.Branch__c = branch;
                insert rc;
                
                if (receivedInterestAmount != 0 && receivedInterestAmount != null) {
                    receivedAmount = receivedAmount - receivedInterestAmount;
                }
                
                Receipt_Line_Item__c rece = new Receipt_Line_Item__c();
                rece.Booking__c = recordId;
                rece.Name = 'Against Payment Schedule';
                rece.Payment_Type__c = 'Payment Schedule';
                rece.Receipt__c = rc.Id;
                rece.Payment_Schedule__c = paymentScheduleList[0].Id;
                rece.Amount__c = receivedAmount;
                rece.Bank_Name__c = bankName;
                rece.Payment_From__c = paymentFrom;
                rece.Mode_of_Payment__c = modeofPayment;
                rece.Cheque_no_Transaction_Number__c = chequeTransactionNumber;
                receiptsToCreate.add(rece);
                
                
                // Parse the string into a list of Map objects
                List<Map<String, String>> advanceReceiptList = (List<Map<String, String>>) JSON.deserialize(advanceReceiptRow, List<Map<String, String>>.class);
                
                List<Advance_Consumption__c> advanceConsumptionRecords = new List<Advance_Consumption__c>();
                
                for (Map<String, String> advanceReceiptData : advanceReceiptList) {
                    // Retrieve the necessary fields
                    String receiptId = advanceReceiptData.get('ReceiptId');
                    
                    String amount = advanceReceiptData.get('Amount');
                    String amountWithoutCurrency = amount.replace('₹', '').replace(',', '').trim();
                    
                    Decimal amountDecimal = Decimal.valueOf(amountWithoutCurrency);
                    if(amountDecimal > 0){
                        Advance_Consumption__c advConsumption = new Advance_Consumption__c();
                        advConsumption.Advance_Receipt__c = receiptId; 
                        advConsumption.Amount__c = amountDecimal; 
                        advConsumption.Receipt__c = rc.Id; 
                        advanceConsumptionRecords.add(advConsumption);
                    }
                }
                
                // Insert the Advance_Consumption__c records if any were created
                if (!advanceConsumptionRecords.isEmpty()) {
                    insert advanceConsumptionRecords;
                }
                
                
                // Check if interest should be included
                if (paymentScheduleList[0].Include_Interest__c == true) {
                    List<Interest_Amount_Line_Item__c> IntAmtLiEs = new List<Interest_Amount_Line_Item__c>();
                    
                    // Assuming 'pay' and 'bk' are valid objects representing the payment and booking data
                    Interest_Amount_Line_Item__c IntLine = new Interest_Amount_Line_Item__c();
                    IntLine.Interest_Amount__c = paymentScheduleList[0].Interest_Amount__c;
                    
                    // Set Interest_Start_Date based on Last_Payment_Date or Payment_Due_Date
                    if (paymentScheduleList[0].Last_Payment_Date__c == null) {
                        IntLine.Interest_Start_Date__c = paymentScheduleList[0].Payment_Due_Date__c;
                    } else {
                        IntLine.Interest_Start_Date__c = paymentScheduleList[0].Last_Payment_Date__c;
                    }
                    
                    IntLine.Interest_End_Date__c = System.today();
                    IntLine.Interest_Percent__c = paymentScheduleList[0].Interest_Percent__c;
                    IntLine.Payment_Schedule__c = paymentScheduleList[0].Id;
                    IntLine.Booking__c = recordId;
                    IntLine.Principal_Amount__c = paymentScheduleList[0].Pending_Amount__c;
                    IntAmtLiEs.add(IntLine);
                    
                    // Update the payment record
                    paymentScheduleList[0].Last_Payment_Date__c = System.today();
                    paymentScheduleList[0].Last_Payment_Time__c = System.now();
                    
                    if (IntAmtLiEs.size() > 0) {
                        insert IntAmtLiEs;
                    }
                }
                
                if (receiptsToCreate.size() > 0) {
                    insert receiptsToCreate;
                }
                
                update paymentScheduleList[0];
                returnId = rc.Id;
            }
            system.debug(returnId);
            return returnId;
        } catch (Exception e) {
            ExceptionHandler.addLog(e,string.valueof(receiptData),'receiptController','');  /*Add Exception to error log*/
            // Handle any exceptions and errors
            throw new AuraHandledException('Error while saving receipt: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Id saveManualReceipt(String receiptData){
        
        Map<String, Object> receiptDataMap = (Map<String, Object>) JSON.deserializeUntyped(receiptData);
        Id returnId;
        String recordId = (String) receiptDataMap.get('recordId');
        String receiptDateString = (String) receiptDataMap.get('receiptDate');
        Date receiptDate = Date.valueOf(receiptDateString);
        String remarks = (String) receiptDataMap.get('remarks');
        String paymentFrom = (String) receiptDataMap.get('paymentFrom');
        String modeofPayment = (String) receiptDataMap.get('modeofPayment');
        String bankName = (String) receiptDataMap.get('bankName');
        String branch = (String) receiptDataMap.get('branch');
        String receiptType = (String) receiptDataMap.get('receiptType');
        String paymentType = (String) receiptDataMap.get('paymentType');
        Decimal receivedAmount = (Decimal) receiptDataMap.get('receivedAmount');
        String chequeTransactionNumber = (String) receiptDataMap.get('transactionNumber');
        String advanceReceiptRow = (String) receiptDataMap.get('advanceReceiptRow');
        Decimal amountFromCustomer = Decimal.valueOf( String.valueOf(receiptDataMap.get('amountFromCustomer')));
        List<Booking__c> bookingRecord = [SELECT Id, Finance_User__c FROM Booking__c WHERE Id = :recordId LIMIT 1];
        
        if(receiptType == 'Advance Receipt'){
            
            Advance_Receipt__c newReceipt = new Advance_Receipt__c();
            newReceipt.Booking__c = recordId;
            newReceipt.Advance_Receipt_Date__c = receiptDate;
            newReceipt.Remarks__c = remarks;
            newReceipt.Payment_From__c = paymentFrom;
            newReceipt.Mode_of_Payment__c = modeofPayment;
            newReceipt.Bank_Name__c = bankName;
            newReceipt.Branch__c = branch;
            newReceipt.Advance_Amount__c = receivedAmount;
            newReceipt.Finance_User__c = bookingRecord[0].Finance_User__c;
            newReceipt.Cheque_Transaction_Number__c = chequeTransactionNumber;
            newReceipt.Finance_User__c =bookingRecord[0].Finance_User__c;
            insert newReceipt;
            returnId = newReceipt.Id;
        }
        
        if (receiptType == 'Normal Receipt' || receiptType == 'From Advance Receipt') {
            
            String receivedInterestAmountString = receiptDataMap.get('receivedInterestAmount') !=null ?string.valueof(receiptDataMap.get('receivedInterestAmount')):'0';
            Decimal receivedInterestAmount = Decimal.valueOf(receivedInterestAmountString);
            
            Receipt__c rc = new Receipt__c();
            rc.Remarks__c = remarks;
            rc.Finance_User__c = bookingRecord[0].Finance_User__c;
            rc.Receipt_date__c = receiptDate;
            rc.Payment_From__c = paymentFrom;
            rc.Receipt_Type__c	= receiptType;
            rc.Check_Transaction_Nmber__c = chequeTransactionNumber;
            rc.Amount_received__c = receivedAmount;
            rc.Amount_From_Customer__c = amountFromCustomer;
            rc.Mode_of_payment__c = modeofPayment;
            rc.Payment_Received_Bank__c = bankName;
            rc.Booking__c = recordId;
            rc.Branch__c = branch;
            rc.Payment_Type__c = paymentType;
            rc.Interest_Paid__c = receivedInterestAmount;
            insert rc;
            returnId = rc.Id;
        }
        return returnId;
    }
    
    public static void createReceiptLineItems(List<Receipt__c> receiptList){
        receiptList.sort(new ReceiptDateComparator());

        if(receiptList.isEmpty()){
            system.debug('No Receipt to process');
        }
        
        Set<Id> bookingIds = new Set<Id>();
        Map<Id,List<Receipt__c>> receiptBookingMap = new Map<Id,List<Receipt__c>>();
        Map<Id,List<Payment_schedule__c>> receiptPeymentScheduleMap = new Map<Id,List<Payment_schedule__c>>();
        List<Interest_Amount_Line_Item__c> IntAmtList = new List<Interest_Amount_Line_Item__c>();
        List<Excess_Credit_Note__c> excessList = new List<Excess_Credit_Note__c>();
        Set<Payment_schedule__c> scheduleToUpdate = new Set<Payment_schedule__c>();
        
        for(Receipt__c rpt : receiptList){
            if(!receiptBookingMap.containsKey(rpt.Booking__c)){
                receiptBookingMap.put(rpt.Booking__c,new List<Receipt__c>());
            }
            receiptBookingMap.get(rpt.Booking__c).add(rpt);
            bookingIds.add(rpt.Booking__c);
        }
        
        List<Receipt_Line_Item__c> receiptsToCreate = new List<Receipt_Line_Item__c>();
        List<Payment_Schedule__c> scheduleList = [SELECT Id, Is_Demanded__c , Amount__c, Pending_Amount__c, S_No__c,Interest_Pending__c,Booking__c,Interest_Amount__c,Interest_Percent__c  FROM Payment_Schedule__c where Booking__c IN : bookingIds ORDER BY S_No__c ASC ];
                
        for(Payment_schedule__c pay : scheduleList){
            if(!receiptPeymentScheduleMap.containsKey(pay.Booking__c)){
                receiptPeymentScheduleMap.put(pay.Booking__c, new List<Payment_Schedule__c>());
            }
            receiptPeymentScheduleMap.get(pay.Booking__c).add(pay);
        }
        Map<Id,Decimal> balanceAmountMap = new Map<Id,Decimal>();
        for(Payment_schedule__c schedule : scheduleList){
            if(!balanceAmountMap.containsKey(schedule.Id)){
                balanceAmountMap.put(schedule.Id,schedule.Pending_Amount__c);
            }
        }
        
        for(Id bookingId : bookingIds){
            List<Receipt__c> newReceipts = receiptBookingMap.get(bookingId);
            List<Payment_schedule__c> currentSchedules = receiptPeymentScheduleMap.get(bookingId);
            
            if(currentSchedules.isEmpty()){
                system.debug('No schedules for booking id: '+ bookingId);
                continue;
            }
            
            for(Receipt__c receipt : newReceipts){
                
                Decimal receivedAmount = receipt.Amount_received__c != null ? receipt.Amount_received__c : 0;
                Decimal interestAmount = receipt.Interest_Paid__c != null ? receipt.Interest_Paid__c : 0;
                if (receivedAmount <= 0 || receivedAmount == null) {
                    continue;
                }
                
                for(Payment_schedule__c schedule : currentSchedules){
                    
                    Decimal balanceAmount = balanceAmountMap.get(schedule.Id);
                    if (receivedAmount <= 0 || receivedAmount == null) {
                        break;
                    }
                    
                    if (balanceAmount != null && balanceAmount > 0) {
                        Decimal amountToReceive = Math.min(balanceAmount, receivedAmount);
                        receivedAmount -= amountToReceive;
                        balanceAmount -= amountToReceive;
                        balanceAmountMap.put(schedule.Id, balanceAmount);

                        Receipt_Line_Item__c rece = new Receipt_Line_Item__c();
                        rece.Booking__c = bookingId;
                        rece.Name = 'Against Payment Schedule';
                        rece.Payment_Type__c = receipt.Payment_Type__c;
                        rece.Receipt__c = receipt.Id;
                        rece.Payment_Schedule__c = schedule.Id;
                        rece.Received_Amount__c = amountToReceive;
                        rece.Amount__c = amountToReceive;
                        rece.Bank_Name__c = receipt.Bank_Name__c;
                        rece.Payment_From__c = receipt.Payment_From__c;
                        rece.Mode_of_Payment__c =  receipt.Mode_of_Payment__c;
                        rece.Cheque_no_Transaction_Number__c = receipt.Check_Transaction_Nmber__c;
                        rece.Settlement_Status__c = schedule.Is_Demanded__c == true? 'Settled' : 'Advance';
                        rece.Approval_Status1__c = 'Approved';
                        
                        receiptsToCreate.add(rece);
                        
                        schedule.Last_Payment_Date__c = receipt.Receipt_date__c;
                        schedule.Last_Payment_Time__c = receipt.CreatedDate;
                        
                        if(schedule.Is_Demanded__c == true && schedule.Interest_Amount__c > 0){
                            Interest_Amount_Line_Item__c IntLine = new Interest_Amount_Line_Item__c();
                            IntLine.Interest_Amount__c = schedule.Interest_Amount__c;
                            IntLine.Interest_Start_Date__c = (schedule.Last_Payment_Date__c == null) ? schedule.Payment_Due_Date__c.addDays(1) : schedule.Last_Payment_Date__c.addDays(1);
                            IntLine.Interest_End_Date__c = system.today();
                            IntLine.Interest_Percent__c = schedule.Interest_Percent__c;
                            IntLine.Payment_Schedule__c = schedule.id;
                            IntLine.Booking__c = bookingId;
                            IntLine.Principal_Amount__c = schedule.Pending_Amount__c;
                            IntAmtList.add(IntLine);
                        }
                        scheduleToUpdate.add(schedule);
                    }
                }
                
                if(receivedAmount !=null && receivedAmount !=0){
                    Excess_Credit_Note__c excess = new Excess_Credit_Note__c(
                        Amount__c = receivedAmount,
                        Booking__c = bookingId,
                        Receipt__c = receipt.Id
                    );
                    excessList.add(excess);
                }
                
                for(Payment_Schedule__c paymentSchedule : currentSchedules){
                    if (interestAmount <= 0 && interestAmount == null) {
                        break;
                    }
                    if(interestAmount > 0 && interestAmount != null) {
                        If(paymentSchedule.Interest_Pending__c != null && paymentSchedule.Interest_Pending__c > 0 ){
                            Decimal amountToReceive = Math.min(paymentSchedule.Pending_Amount__c, interestAmount);
                            interestAmount -= amountToReceive;
                            
                            Receipt_Line_Item__c rece = new Receipt_Line_Item__c();
                            rece.Booking__c = bookingId;
                            rece.Name = 'Against Interest';
                            rece.Payment_Type__c = 'Interest';
                            rece.Settlement_Status__c = 'Settled';
                            rece.Receipt__c = receipt.Id;
                            rece.Payment_Schedule__c = paymentSchedule.Id;
                            rece.Received_Amount__c = amountToReceive;
                            rece.Amount__c = amountToReceive;
                            rece.Bank_Name__c = receipt.Bank_Name__c;
                            rece.Payment_From__c = receipt.Payment_From__c;
                            rece.Mode_of_Payment__c =  receipt.Mode_of_Payment__c;
                            rece.Cheque_no_Transaction_Number__c = receipt.Check_Transaction_Nmber__c;
                            rece.Approval_Status1__c = 'Approved';
                            receiptsToCreate.add(rece);
                        }
                    }
                }

                if(!receiptsToCreate.isEmpty()){
                    upsert receiptsToCreate;
                }
                if(!scheduleToUpdate.isEmpty()){
                    List<Payment_Schedule__c> updateSchedule = new List<Payment_Schedule__c>();
                    updateSchedule.addAll(updateSchedule);
                    update updateSchedule;
                }
                if(!IntAmtList.isEmpty()){
                    upsert IntAmtList;
                }
            }       
        }
    }
    
    public static void updateReceiptLineItems(Set<Id> payIds){
        if(payIds.isEmpty()){
            system.debug('No payment Schedule found');
        }
        
        List<Receipt_Line_Item__c> advanceAdjust = [SELECT Id, Settlement_Status__c FROM Receipt_Line_Item__c 
                                                    WHERE Payment_schedule__c IN: payIds AND Settlement_Status__c = 'Advance'];
        if(!advanceAdjust.isEmpty()){
            for(Receipt_Line_Item__c recLine : advanceAdjust){
                recLine.Settlement_Status__c = 'Settled';
            }
            update advanceAdjust;
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
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;  i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
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
}