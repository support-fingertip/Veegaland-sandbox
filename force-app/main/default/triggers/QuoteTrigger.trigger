trigger QuoteTrigger on Quote__c (After insert,After update,Before update) {
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate) ){
        
        CreatedChargeDetail.createdcharge(Trigger.new);
        
    }
    
    if (Trigger.isAfter && Trigger.isInsert) {
        list<Quote__c> submitQuoteList = new list<Quote__c>();
        
        Set<String> ProjectName = new Set<String>();
        for (Quote__c qt : Trigger.New) {
            if (String.isNotBlank(qt.Project__c)) {
                ProjectName.add(qt.Project__c); 
            }
        }
        System.debug('ProjectName: ' + ProjectName);
        // Query for Discount_Limit__c records based on Project__c
        List<Discount_Limit__c> DisList = [
            SELECT Id, Name, Project__c, Maximum_Discount__c 
            FROM Discount_Limit__c 
            WHERE Project__c IN :ProjectName
        ];
        System.debug('DisList: ' + DisList);
        // Store maximum discount in a map
        Map<String, Decimal> DisMap = new Map<String, Decimal>();
        for (Discount_Limit__c Dis : DisList) {
            DisMap.put(Dis.Project__c, Dis.Maximum_Discount__c);
        }
        System.debug('DisMap: ' + DisMap);
        
       // QuoteController.handleAfterInsert(Trigger.new);
        for (Quote__c quote : Trigger.new) {
            if (DisMap.containsKey(quote.Project__c)) {
                System.debug('qts.Project__c: ' + quote.Project__c);
                System.debug('Discount amount: ' + DisMap.get(quote.Project__c));
                if((quote.Unit_Floor_Raise_Charge__c != quote.Floor_Rise_Charges__c ) || (quote.Special_Launch__c==true && quote.Discount_In_Rupees__c > DisMap.get(quote.Project__c))){
                    submitQuoteList.add(quote);  
                }
            }
        }
        if(!submitQuoteList.isEmpty()){
           QuoteController.submitQuoteApproval(submitQuoteList); 
        }
    }
    
    if(Trigger.isBefore && Trigger.isUpdate ){
        Map<Id, set<String>> approvedBookingMap = new Map<Id, set<String>>();
        Map<Id, set<String>> rejectedBookingMap = new Map<Id, set<String>>();
        Map<Id, set<String>> updatedBookingMap = new Map<Id, set<String>>();
        Set<Id> approvedQuoteIdsToNotify = new Set<Id>();
        Set<Id> rejectedQuoteIdsToNotify = new Set<Id>();
        Set<Id> updatedBookingFormNotify = new Set<Id>();
        
        
        for (Quote__c quote : Trigger.new) {
            Quote__c oldQuote = Trigger.oldMap.get(quote.Id);

            
            // Check if Quote_Customer_Approval_Mail_Sent_Time__c has value and is different from before
            if (quote.Quote_Customer_Approval_Mail_Sent_Time__c != null &&
                quote.Quote_Customer_Approval_Mail_Sent__c == true && oldQuote.Quote_status__c == 'Drafted' && oldQuote.Quote_status__c != 'Quote Sent') {
                    quote.Quote_status__c = 'Quote Sent';
                }
            
            // Check if Document_Request_Email_Send_Time__c has value, is true, and different from before
            if (quote.Booking_Form_Updated_By_Customer__c == true && quote.Booking_Form_Updated_By_Customer__c != oldQuote.Booking_Form_Updated_By_Customer__c &&
                oldQuote.Quote_status__c != 'KYC Collection' && oldQuote.Quote_status__c == 'Quote Sent') {
                    quote.Quote_status__c = 'KYC Collection';
                }
            if (quote.Quote_status__c == 'KYC Collection' && oldQuote.Booking_Form_Updated_By_Customer__c == false && quote.Booking_Form_Updated_By_Customer__c == true) {
                quote.KYC_Documents_Verification_Status__c = 'Pending';
                quote.All_Applicants_Photo_Verified__c = false;
                quote.All_Applicants_Passport_Verified__c= false;
                quote.All_Applicants_PAN_Verified__c= false;
                quote.All_Applicants_Aadhar_Verified__c= false;
                updatedBookingFormNotify.add(quote.Id);
                if (!updatedBookingMap.containsKey(quote.Id)) {
                    updatedBookingMap.put(quote.Id, new Set<String>());
                }
                updatedBookingMap.get(quote.Id).add(quote.OwnerId);
            }
            /* // If Approval_status__c is Rejected and status is not already Quote Rejected
if (quote.Cost_Sheet_Acceptance_Status__c == 'Rejected' && oldQuote.Quote_status__c != 'Quote Rejected' && quote.Document_Request_Email_send__c == false) {
quote.Quote_status__c = 'Quote Rejected';
            }
            
            // If Approval_status__c is Accepted and status is not already Quote Approved
            if (quote.Cost_Sheet_Acceptance_Status__c == 'Approved' && oldQuote.Quote_status__c != 'Quote Approved' && quote.Document_Request_Email_send__c == false) {
                quote.Quote_status__c = 'Quote Approved';
            }*/
            
           /* // If Booking_Form_Approval_Status__c is Approved and status is not already Booking Form Accepted
            if (quote.Booking_Form_Approval_Status__c == 'Approved' && oldQuote.Quote_status__c != 'Booking Form Accepted' &&  quote.Booking__c == null ) {
                quote.Quote_status__c = 'Booking Form Accepted';
            }
            
            // If Booking_Form_Approval_Status__c is Denied and status is not already Booking Form Denied
            if (quote.Booking_Form_Approval_Status__c == 'Denied' && oldQuote.Quote_status__c != 'Booking Form Denied') {
                quote.Quote_status__c = 'Booking Form Denied';
            }*/
            if(quote.Booking__c != null && quote.Booking_Created_Time__c != null){
                quote.Quote_status__c = 'Booking Created';
            }
            
             if (quote.Quote_status__c == 'KYC Collection' &&
                quote.KYC_Documents_Verification_Status__c == 'Verified' && oldQuote.KYC_Documents_Verification_Status__c != 'Verified') {
                    quote.Quote_status__c = 'Documents Verified';
                }
             if (quote.Booking_Form_Generated_Time__c != null &&
                quote.Booking_Form_Generated__c == true && oldQuote.Booking_Form_Generated__c != true && oldQuote.Quote_status__c != 'Booking Form Generated' && quote.Quote_status__c == 'Documents Verified') {
                    quote.Quote_status__c = 'Booking Form Generated';
                }
            if(quote.Booking_Form_Approval_Status__c == 'Approved' && oldQuote.Booking_Form_Approval_Status__c != 'Approved' && oldQuote.Quote_status__c == 'Booking Form Generated'){
                quote.Quote_status__c = 'Booking Form Accepted';
                approvedQuoteIdsToNotify.add(quote.Id);
                
                if (!approvedBookingMap.containsKey(quote.Id)) {
                    approvedBookingMap.put(quote.Id, new Set<String>());
                }
                approvedBookingMap.get(quote.Id).add(quote.OwnerId);
            }
            /*
            if(quote.Booking_Form_Approval_Status__c == 'Denied' && oldQuote.Booking_Form_Approval_Status__c != 'Denied'){
                quote.Quote_status__c = 'Booking Form Denied';
                rejectedQuoteIdsToNotify.add(quote.Id);
                if (!rejectedBookingMap.containsKey(quote.Id)) {
                    rejectedBookingMap.put(quote.Id, new Set<String>());
                }
                rejectedBookingMap.get(quote.Id).add(quote.OwnerId);
            }*/
            
        }
        if (!updatedBookingMap.isEmpty()) {
            CustomNotificationServiceClass.sendCustomNotification(
                updatedBookingMap, 
                'Customer Updated Booking Form', 
                'The customer has updated the booking form and KYC documents. Please review and approve if everything is correct.',
                'Custom_Notification' // DeveloperName from Custom Notification Type
            );
        }
         if (!approvedBookingMap.isEmpty()) {
            CustomNotificationServiceClass.sendCustomNotification(
                approvedBookingMap, 
                'Booking Form Approved !', 
                'Booking Form has been approved by the customer. Please review and proceed with further steps',
                'Custom_Notification' // DeveloperName from Custom Notification Type
            );
        }
        
        if (!rejectedBookingMap.isEmpty()) {
            CustomNotificationServiceClass.sendCustomNotification(
                rejectedBookingMap, 
                'Booking Full Advance Payment Received!', 
                'The received the full amount of advance payment from the customer. Please review the payment details..',
                'Custom_Notification' 
            );
        }
       
        if (approvedQuoteIdsToNotify.size() > 0) {
            SendEmailServiceClass.sendQuoteApprovalEmail(approvedQuoteIdsToNotify, 'Approved');
        }
        if (rejectedQuoteIdsToNotify.size() > 0) {
            SendEmailServiceClass.sendQuoteApprovalEmail(rejectedQuoteIdsToNotify, 'Denied');
        }
        if (updatedBookingFormNotify.size() > 0) {
            SendEmailServiceClass.sendBookingFormUpdatedEmail(updatedBookingFormNotify);
        }
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        Set<Id> quoteUnitBlocked = new Set<Id>();
        Map<Id, set<String>> createBookingMap = new Map<Id, set<String>>();
         list<Quote__c> approvedQuote = new list<Quote__c>();
        list<Quote__c> rejectedQuote = new list<Quote__c>();
        
        for (Quote__c quote : Trigger.new) {
            Quote__c oldQuote = Trigger.oldMap.get(quote.Id);
            
            if(quote.Approval_status__c =='Approved' && oldQuote.Approval_status__c != quote.Approval_status__c){
                approvedQuote.add(quote);
            }
             if(quote.Approval_status__c =='Rejected' && oldQuote.Approval_status__c != quote.Approval_status__c){
                rejectedQuote.add(quote);
            }
            if( quote.Quote_status__c == 'Quote Approved' && oldQuote.Quote_status__c != 'Quote Approved' ){
                quoteUnitBlocked.add(quote.Id);
            }
            if( quote.Quote_status__c == 'Create Booking' && oldQuote.Quote_status__c != 'Create Booking' ){
                if (!createBookingMap.containsKey(quote.Id)) {
                    createBookingMap.put(quote.Id, new Set<String>());
                }
                createBookingMap.get(quote.Id).add(quote.OwnerId);
            }
        }
        if(!quoteUnitBlocked.isEmpty()){
            QuoteController.quoteUnitStatusChange(quoteUnitBlocked);
        }
         if (!createBookingMap.isEmpty()) {
            CustomNotificationServiceClass.sendCustomNotification(
                createBookingMap, 
                'Quote is ready to create Booking !', 
                'Please proceed to create the booking',
                'Custom_Notification' // DeveloperName from Custom Notification Type
            );
        }
        if(!approvedQuote.isEmpty()){
            QuoteController.sendApprovedRejectedNotification(approvedQuote,'Approved');
        }
        if(!rejectedQuote.isEmpty()){
              QuoteController.sendApprovedRejectedNotification(rejectedQuote,'Rejected');
        }
    }
    /*   if (Trigger.isAfter && Trigger.isIns
     * ert) {crea
PaymentScheduleService.createPaymentSchedules(Trigger.new);
}

if(Trigger.isAfter && Trigger.isInsert){
set<string> prjIds = new set<string>();

for(Quote__c qt : Trigger.new){
if(qt.Payment_Plan__c !=null&& qt.Unit__c !=null){
prjIds.add(qt.Payment_Plan__c);
}
}
if(prjIds.size()>0){
// List<project__c> prjList = [SELECT Id,Name,(select id,Project__C,S_No__c,Name,Payment_Percent__c,Completed_Date__c,Completed__c from Master_payment_schedules__r ORDER BY S_No__c ASC) FROM Project__c WHERE Id IN : prjIds];
list<Payment_Plan__c> pymntsch = [select id, Name,(select id,Project__C,S_No__c,Name,Payment_Percent__c,Completed_Date__c,Completed__c from Master_payment_schedules__r ORDER BY S_No__c ASC) from Payment_Plan__c where Id IN : prjIds ];
Map<string,List<Master_payment_schedule__c>> masters = new Map<string,List<Master_payment_schedule__c>>();
for(Payment_Plan__c prj : pymntsch){
if(prj.Master_payment_schedules__r.size()>0){
masters.put(prj.Id, prj.Master_payment_schedules__r);
}
}
List<Payment_schedule__c> payList = new List<Payment_schedule__c>();
String id;
Decimal totalPercentage = 0;
for(Quote__c qt : Trigger.new){
if(qt.Unit__c!=null && qt.Payment_Plan__c!=null){
if(masters.containskey(qt.Payment_Plan__c)){
for(Master_payment_schedule__c mps : masters.get(qt.Payment_Plan__c)){
if(!mps.Completed__c){
Payment_schedule__c ps = new Payment_schedule__c();
ps.Master_Payment_Schedule__c = mps.Id;
ps.Payment_percent__c = mps.Payment_Percent__c;
ps.Completed_Date__c = mps.Completed_Date__c;
ps.Name = mps.Name;
ps.S_No__c = mps.S_No__c;
ps.quote__c = qt.Id;
payList.add(ps);

}
else {

totalPercentage = calculateTotalPercentage(masters.get(qt.Payment_Plan__c));
id=qt.Id;
}
}
}

}
}
if(totalPercentage!=null){
Payment_schedule__c completedPs = new Payment_schedule__c();
completedPs.Name = 'As Per the Current Work Status';
completedPs.Completed_Date__c=System.Today();
completedPs.Payment_percent__c=totalPercentage;
completedPs.Quote__c =id ;
payList.add(completedPs);     
}
if(payList.size()>0){
insert payList;
}
}

}
private Decimal calculateTotalPercentage(List<Master_payment_schedule__c> masterSchedules) {
Decimal totalPercentage = 0;
for (Master_payment_schedule__c mps : masterSchedules) {
if(mps.Completed__c){

totalPercentage += mps.Payment_Percent__c;
}
}
return totalPercentage;
}
*/
}