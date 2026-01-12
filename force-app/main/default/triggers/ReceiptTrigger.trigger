trigger ReceiptTrigger on Receipt__c (before insert, after insert, before update, after update) {
    
    if(trigger.isBefore){
        if(trigger.isInsert){
            for(Receipt__c rc : Trigger.new){
                if( rc.Payment_From__c == 'Advance Receipt'){
                    rc.Approval_status__c = 'Approved by Finance Team';
                }
            }
        }
    }
    
    if(trigger.isAfter){
        if(trigger.isInsert){
            Set<Id> repId = new Set<Id>();
            List<Id> bookId = new List<Id>();
            list<Receipt__c> approvedReciepts = new list<Receipt__c>();
            list<Receipt__c> rejectedReciepts = new list<Receipt__c>();
            
            for(Receipt__c rc : Trigger.new){
                if (rc.Approval_status__c == 'Approved by Finance Team' || rc.Approval_status__c == 'Rejected by Finance Team') {
                    String body;
                    String title;
                    if (rc.Approval_status__c == 'Approved by Finance Team' ) {
                        approvedReciepts.add(rc);
                    }else if (rc.Approval_status__c == 'Rejected by Finance Team') {
                        rejectedReciepts.add(rc);
                    }
                }
                if(!Test.isRunningTest()){
                    if(rc.Approval_status__c != 'Approved by Finance Team' && rc.Approval_status__c != 'Rejected by Finance Team'){
                        if (rc.Finance_User__c != null && rc.Payment_From__c != 'Advance Receipt' &&  rc.Skip_Approval__c == false && !test.IsrunningTest()){
                            bookId.add(rc.Booking__c);
                            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                            req.setComments('Receipt Submitted for Approval');
                            req.setObjectId(rc.Id);
                            Approval.ProcessResult result = Approval.process(req);
                        }
                    }
                }
            }
            String title='';
            if(!approvedReciepts.isEmpty()){
                title = 'Receipt Approved';
                ReceiptController.createReceiptLineItems(approvedReciepts);
                ReceiptController.sendNotificationsFromReceipts(title,approvedReciepts);
            }
            if(!rejectedReciepts.isEmpty()){
                title = 'Receipt Rejected';
                ReceiptController.sendNotificationsFromReceipts(title,rejectedReciepts);
            }
            
            if(!bookId.isEmpty() && label.DisabledWhatsappMessage !='TRUE'){
                WhatsappController.BalanceAmountCustomerSubmission(bookId);
            }
        } 
        
        if (Trigger.isUpdate) {
            list<Receipt__c> approvedReciepts = new list<Receipt__c>();
            list<Id> approvedRecieptIds = new list<Id>();
            list<Id> approvedRecieptIdsExFrAdv = new list<Id>();
            list<Receipt__c> rejectedReciepts = new list<Receipt__c>();
            for (Receipt__c rcp : Trigger.new) {
                // Check if the Approval status has changed
                if (rcp.Approval_status__c != Trigger.oldMap.get(rcp.Id).Approval_status__c && (rcp.Approval_status__c == 'Approved by Finance Team' || rcp.Approval_status__c == 'Rejected by Finance Team')) {
                    // Define the message body and title based on approval status
                    
                    if (rcp.Approval_status__c == 'Approved by Finance Team' ) {
                        approvedRecieptIds.add(rcp.Id);
                        approvedReciepts.add(rcp);
                        if(rcp.Payment_From__c != 'Advance Receipt' && label.DisableReceiptEmail !='TRUE'){
                            approvedRecieptIdsExFrAdv.add(rcp.Id); 
                        }
                    } else if (rcp.Approval_status__c == 'Rejected by Finance Team') {
                        rejectedReciepts.add(rcp);
                    }
                }
            }
            String title='';
            if(!approvedReciepts.isEmpty()){
                title = 'Receipt Approved';
                ReceiptController.createReceiptLineItems(approvedReciepts);
                ReceiptController.approvedReceiptsHandler(approvedRecieptIds);
                ReceiptController.sendNotificationsFromReceipts(title,approvedReciepts);
                if(approvedRecieptIdsExFrAdv.size() > 0){
                    SendEmailServiceClass.sendEmailGenerateReceipts(approvedRecieptIdsExFrAdv);
                }
            }
            if(!rejectedReciepts.isEmpty()){
                title = 'Receipt Rejected';
                ReceiptController.sendNotificationsFromReceipts(title,rejectedReciepts);
            }
        }
    }
}