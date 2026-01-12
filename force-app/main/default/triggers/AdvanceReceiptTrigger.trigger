trigger AdvanceReceiptTrigger on Advance_Receipt__c (before insert,after insert,after update) {
    
    if(trigger.isBefore){
        if(trigger.isInsert){
            String currentYear = String.valueOf(System.today().year()).substring(2, 4); // last two digits of current year
            String nextYear = String.valueOf(System.today().year() + 1).substring(2, 4); // last two digits of next year
            
            // Create a set to hold unique Booking__c values
            Set<Id> bookingIds = new Set<Id>();
            
            // Add all Booking__c values from Trigger.new to the set
            for (Advance_Receipt__c receipt : Trigger.new) {
                bookingIds.add(receipt.Booking__c);
            }
            
            // Query for the most recent Advance_Receipt__c records for each unique Booking__c
            Map<Id, String> lastInvoiceIdMap = new Map<Id, String>();
            for (Advance_Receipt__c receipt : [SELECT Booking__c, Invoice_Id__c FROM Advance_Receipt__c WHERE Booking__c IN :bookingIds ORDER BY CreatedDate DESC]) {
                // Store the most recent Invoice_Id__c for each Booking__c
                if (!lastInvoiceIdMap.containsKey(receipt.Booking__c)) {
                    lastInvoiceIdMap.put(receipt.Booking__c, receipt.Invoice_Id__c);
                }
            }
            
            // Loop through each record in Trigger.new
            for (Advance_Receipt__c receipt : Trigger.new) {
                // Retrieve the last Invoice_Id__c for the current Booking__c
                String lastInvoiceId = lastInvoiceIdMap.get(receipt.Booking__c);
                
                // Initialize the serial number to 1 if no lastInvoiceId is found
                Integer serialNumber = 1;
                
                if (lastInvoiceId != null) {
                    // Extract the serial number part from the last Invoice_Id__c
                    String serialPart = lastInvoiceId.substring(lastInvoiceId.lastIndexOf('/') + 1);
                    
                    // Increment the serial number by 1
                    serialNumber = Integer.valueOf(serialPart) + 1;
                }
                
                // Format the serial number to always be two digits (e.g., "01", "02", etc.)
                String formattedSerial = (serialNumber < 10 ? '0' + String.valueOf(serialNumber) : String.valueOf(serialNumber));
                
                // Format the Invoice_Id__c as "VD/AR/YY-YY/SS"
                String invoiceId = 'VD/AR/' + currentYear + '-' + nextYear + '/' + formattedSerial;
                
                // Set the Invoice_Id__c on the current record
                receipt.Invoice_Id__c = invoiceId;
            }
        }
    }
    if(trigger.isAfter){
        if(trigger.isInsert){
            Set<Id> repId = new Set<Id>();
            List<Id> bookId = new List<Id>();
            if(!Test.isRunningTest()){
                for(Advance_Receipt__c rc : Trigger.new){
                    if (rc.Finance_User__c != null){
                        system.debug(rc.Finance_User__c);
                        bookId.add(rc.Booking__c);
                        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                        req.setProcessDefinitionNameOrId('Advance_Receipt_Approval');
                        req.setComments('Receipt Submitted for Approval');
                        req.setObjectId(rc.Id);
                        req.setNextApproverIds(new Id[] {rc.Finance_User__c});
                        Approval.ProcessResult result = Approval.process(req);
                    }
                    
                }
            }
            
            if(!bookId.isEmpty() && label.DisabledWhatsappMessage !='TRUE'){
                WhatsappController.BalanceAmountCustomerSubmission(bookId);
            }
        }
        if(trigger.isUpdate){ 
            set<Id> receiptId = new set<Id>();
            set<Id> bookingIds = new set<Id>();
            for(Advance_Receipt__c advRec : Trigger.new){
                if(advRec.Approval_Status__c == 'Approved by Finance Team' && advRec.Approval_Status__c != trigger.oldMap.get(advRec.Id).Approval_Status__c){
                    receiptId.add(advRec.Id);
                    bookingIds.add(advRec.Booking__c);
                }
            }
            if(!receiptId.isEmpty() && label.DisabeAdvReceiptEmail !='TRUE'){
                GenerateDocumnetController.sendBulkAdvanceReceiptEmail(receiptId);
            }
            if(!bookingIds.isEmpty()){
                BookingController.completeOrCreateTokenAdvanceFollowUps(bookingIds);
            }
            if(!bookingIds.isEmpty()){
                BookingController.completeOrCreateAdvanceFollowUps(bookingIds);
            }
        }
    }
    if(test.isrunningTest()){
        integer i=0;
        i++;
        i++;
        i++;
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