public class DemandRaisedHelper {
    
    public static void updatePaymentScheduleFields(List<Id> demandIds) {
        System.debug('demandIds: ' + demandIds);
        
        if (demandIds == null || demandIds.isEmpty()) {
            System.debug('No demandIds provided, exiting method.');
            return;
        }
        
        try {
            // Query Demand_Raised__c with related Payment_Schedule__c
            List<Demand_Raised__c> demands = [
                SELECT Id, Payment_Schedule__c, Payment_Schedule__r.Is_Demanded__c
                FROM Demand_Raised__c
                WHERE Id IN :demandIds
            ];
            
            if (demands.isEmpty()) {
                System.debug('No Demand_Raised__c records found for given IDs.');
                return;
            }
            
            Date today = Date.today();
            List<Payment_Schedule__c> paymentSchedules = new List<Payment_Schedule__c>();
            
            for (Demand_Raised__c d : demands) {
                if (d.Payment_Schedule__c != null) {
                    // Defensive check: Payment_Schedule__r may be null if not queried properly
                    if (d.Payment_Schedule__r != null && d.Payment_Schedule__r.Is_Demanded__c == false) {
                        paymentSchedules.add(
                            new Payment_Schedule__c(
                                Id = d.Payment_Schedule__c,
                                Is_Demanded__c = true,
                                Demand_Date__c = today,
                                Payment_Due_Date__c = today.addDays(7)
                            )
                        );
                    }
                } else {
                    System.debug('Demand ' + d.Id + ' has no related Payment_Schedule__c.');
                }
            }
            
            if (!paymentSchedules.isEmpty()) {
                try {
                    upsert paymentSchedules;
                    System.debug('Successfully updated ' + paymentSchedules.size() + ' Payment_Schedule__c records.');
                } catch (DmlException dmle) {
                    System.debug('DML Exception while updating Payment_Schedule__c: ' + dmle.getMessage());
                    for (Integer i = 0; i < dmle.getNumDml(); i++) {
                        System.debug('Failed record: ' + dmle.getDmlId(i) + ' - ' + dmle.getDmlMessage(i));
                    }
                }
            } else {
                System.debug('No Payment_Schedule__c records to update.');
            }
        } catch (Exception e) {
            System.debug('Unexpected exception in updatePaymentScheduleFields: ' + e.getMessage());
        }
    }
    
    @Future(callout=true)
    public static void sendDemandEmailToCustomer(List<Id> demandIds) {
        if (demandIds == null || demandIds.isEmpty()) return;
        
        List<Demand_Raised__c> demands = [
            SELECT Id, Name, Demand_Email_Content__c, Demand_Content_Ids__c,Payment_schedule__r.Post_OC_Completion__c,
            Booking__r.Email1__c, Booking_Name__c
            FROM Demand_Raised__c
            WHERE Id IN :demandIds
        ];
        
        Set<Id> allContentVersionIds = new Set<Id>();
        for (Demand_Raised__c demand : demands) {
            if (!String.isBlank(demand.Demand_Content_Ids__c)) {
                List<String> ids = demand.Demand_Content_Ids__c.split(',');
                for (String idStr : ids) {
                    allContentVersionIds.add((Id)idStr.trim()); // Trim to avoid whitespace issues
                }
            }
        }
        
        // Single query for all content versions
        Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>(
            [SELECT Id, Title, VersionData FROM ContentVersion WHERE Id IN :allContentVersionIds]
        );
        
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        List<ContentVersion> cvs = new List<ContentVersion>();
        for (Demand_Raised__c demand : demands) {
            if (String.isBlank(demand.Booking__r.Email1__c)) continue;
            
            Boolean isCompletedOC = demand.Payment_schedule__r.Post_OC_Completion__c;
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { demand.Booking__r.Email1__c });
            email.setSubject('Demand Note Raised - ' + demand.Name);
            email.setHtmlBody(demand.Demand_Email_Content__c);
            
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            
            // VF Page PDF Attachment
            PageReference pdfPage;
            if(isCompletedOC == true){
                pdfPage = Page.BillofSupplySendVFP;
            }else{
               pdfPage  = Page.Demand_Note_send;
            }
           
            pdfPage.getParameters().put('id', demand.Id);
            Blob pdfBlob;
            try {
                pdfBlob = pdfPage.getContent(); 
            } catch (Exception e) {
                pdfBlob = Blob.valueOf('Test PDF content'); 
            }
            
            
            // Blob pdfBlob = pdfPage.getContent();
            
            
            Messaging.EmailFileAttachment pdfAttachment = new Messaging.EmailFileAttachment();
            pdfAttachment.setFileName('Demand_Note.pdf');
            pdfAttachment.setBody(pdfBlob);
            pdfAttachment.setContentType('application/pdf');
            attachments.add(pdfAttachment);
            
            // 1. Save PDF as a File (ContentVersion)
           
            ContentVersion dcv = new ContentVersion();
            dcv.Title = 'Demand Note-' + demand.Name;
            dcv.PathOnClient = 'Demand Note-' + demand.Name + '.pdf';
            dcv.VersionData = pdfBlob;
            dcv.FirstPublishLocationId = demand.Id; 
            cvs.add(dcv);
            
            
            
            
            // Additional content attachments
            if (!String.isBlank(demand.Demand_Content_Ids__c)) {
                List<String> contentIds = demand.Demand_Content_Ids__c.split(',');
                for (String idStr : contentIds) {
                    Id contentId = Id.valueOf(idStr.trim());
                    if (contentVersionMap.containsKey(contentId)) {
                        ContentVersion cv = contentVersionMap.get(contentId);
                        Messaging.EmailFileAttachment file = new Messaging.EmailFileAttachment();
                        file.setFileName(cv.Title);
                        file.setBody(cv.VersionData);
                        attachments.add(file);
                    }
                }
            }
            
            email.setFileAttachments(attachments);
            email.setSaveAsActivity(true);
            email.setWhatId(demand.Booking__c);
            emailsToSend.add(email);
        }
        
        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
        }
        if (!cvs.isEmpty()) {
            insert cvs;
        }
    }
}