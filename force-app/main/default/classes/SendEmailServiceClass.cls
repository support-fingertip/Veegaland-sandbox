public class SendEmailServiceClass {
    @AuraEnabled
    public static void sendRequestDocumentMail(Id recordId, String emailContent, List<String> contentIds) {
        system.debug('recordId '+recordId);
        system.debug('contentId' +contentIds);
        Quote__c Quote = [SELECT Id, Name, Lead_Name__c,Lead_Email__c,Primary_Applicant_Name__c,Encrypted_Key__c,Primary_Applicant_Saluaion__c,Primary_Applicant_Email__c,Primary_Applicant_Mobile_No__c,OwnerId,Owner.Name,Owner.Phone,Owner.Email
                          FROM Quote__c WHERE Id = :recordId LIMIT 1];
        
        Map<String, Id> ownerEmailToOrgWideIdMap = new Map<String, Id>();
        for (OrgWideEmailAddress ow : [SELECT Id, Address FROM OrgWideEmailAddress]) {
            ownerEmailToOrgWideIdMap.put(ow.Address.toLowerCase(), ow.Id);
        }
        List<String> ccAddresses = new List<String>();
        
        // ccAddresses.add('customercare@veegaland.in');
        List<String> toAddresses = new List<String>();
        
        if (Quote != null && Quote.Lead_Email__c != null) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
            Set<Id> contentDocumentIds = new Set<Id>();
            
            
            
            
            
            for (ContentDocumentLink docLink : Quote.ContentDocumentLinks) {
                contentDocumentIds.add(docLink.ContentDocumentId);
            }
            if (!contentDocumentIds.isEmpty()) {
                
                
                List<ContentVersion> contentVersions = [SELECT Title,FileExtension, VersionData FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds];
                for (ContentVersion cv : contentVersions) {
                    Messaging.EmailFileAttachment contentAttach = new Messaging.EmailFileAttachment();
                    String fileNameWithExtension = cv.Title + '.' + cv.FileExtension;
                    contentAttach.setFileName(fileNameWithExtension);
                    //contentAttach.setFileName(cv.Title);
                    contentAttach.setBody(cv.VersionData);
                    emailAttachments.add(contentAttach);
                }
            }
            toAddresses.add(Quote.Lead_Email__c);
            List<PageReference> vfPages = new List<PageReference>();
            
            if (!String.isBlank(Quote.Owner.Email)) {
                ccAddresses.add(Quote.Owner.Email);
                
            }
            if (!ccAddresses.isEmpty()) {
                mail.setCcAddresses(ccAddresses);
            }
            mail.setToAddresses(toAddresses);
            
            
            String projectDetails = 'Veegaland: Request for Customer Details and Documents';
            
            // Set the subject line
            mail.setSubject(projectDetails);
            mail.setHtmlBody(emailContent);
            mail.setSaveAsActivity(true);
            mail.setWhatId(Quote.Id);
            String ownerEmail = Quote.Owner.Email;
            if (ownerEmail != null && ownerEmailToOrgWideIdMap.containsKey(ownerEmail.toLowerCase())) {
                mail.setOrgWideEmailAddressId(ownerEmailToOrgWideIdMap.get(ownerEmail.toLowerCase()));
            }
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            List<Id> recIdList = new List<Id>{ Quote.Id };
                WhatsappController.CollectBookingFormDetails(recIdList);
            
            Quote.Document_Request_Email_Send_Time__c = system.now();
            Quote.Document_Request_Email_send__c = true;
            update Quote;
        }
    }
    @AuraEnabled
    public static void sendCostSheettoCustomer(Id recordId, String emailContent, List<String> contentIds) {
        system.debug('recordId '+recordId);
        Quote__c Quote = [SELECT Id, Lead_Name__c,Lead_Email__c,Quote_status__c,Name, Primary_Applicant_Name__c,Encrypted_Key__c,Primary_Applicant_Saluaion__c,Primary_Applicant_Email__c,Primary_Applicant_Mobile_No__c,OwnerId,Owner.Name,Owner.Phone,Owner.Email
                          FROM Quote__c WHERE Id = :recordId LIMIT 1];
        
        Map<String, Id> ownerEmailToOrgWideIdMap = new Map<String, Id>();
        for (OrgWideEmailAddress ow : [SELECT Id, Address FROM OrgWideEmailAddress]) {
            ownerEmailToOrgWideIdMap.put(ow.Address.toLowerCase(), ow.Id);
        }
        
        List<String> ccAddresses = new List<String>();
        // ccAddresses.add('customercare@veegaland.in');
        List<String> toAddresses = new List<String>();
        
        if (Quote != null && Quote.Lead_Email__c != null) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
            
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            PageReference pref;
            
            pref= page.VeegalandQuotePdf;
            pref.getParameters().put('id',recordId);
            pref.setRedirect(true);
            Blob b;
            if(Test.isRunningTest()){
                b = blob.valueOf('Unit.Test');
            }else{
                b = pref.getContent();
            }
            attach.setFileName('Veegaland_Quotation.pdf');
            attach.setBody(b); 
            emailAttachments.add(attach);
            
            Set<Id> contentDocumentIds = new Set<Id>();
            for (ContentDocumentLink docLink : Quote.ContentDocumentLinks) {
                contentDocumentIds.add(docLink.ContentDocumentId);
            }
            if (!contentDocumentIds.isEmpty()) {
                List<ContentVersion> contentVersions = [SELECT Title,FileExtension, VersionData FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds];
                for (ContentVersion cv : contentVersions) {
                    Messaging.EmailFileAttachment contentAttach = new Messaging.EmailFileAttachment();
                    String fileNameWithExtension = cv.Title + '.' + cv.FileExtension;
                    contentAttach.setFileName(fileNameWithExtension);
                    //contentAttach.setFileName(cv.Title);
                    contentAttach.setBody(cv.VersionData);
                    emailAttachments.add(contentAttach);
                }
            }
            toAddresses.add(Quote.Lead_Email__c);
            List<PageReference> vfPages = new List<PageReference>();
            
            if (!String.isBlank(Quote.Owner.Email)) {
                ccAddresses.add(Quote.Owner.Email);
                mail.setCcAddresses(ccAddresses);
            }
            mail.setToAddresses(toAddresses);
            
            if (!emailAttachments.isEmpty()) {
                mail.setFileAttachments(emailAttachments);
            }
            String projectDetails = 'Veegaland: Cost Sheet';
            
            // Set the subject line
            mail.setSubject(projectDetails);
            mail.setHtmlBody(emailContent);
            mail.setSaveAsActivity(true);
            mail.setWhatId(Quote.Id);
            
            String ownerEmail = Quote.Owner.Email;
            if (ownerEmail != null && ownerEmailToOrgWideIdMap.containsKey(ownerEmail.toLowerCase())) {
                mail.setOrgWideEmailAddressId(ownerEmailToOrgWideIdMap.get(ownerEmail.toLowerCase()));
            }
            
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            Quote.Quote_Customer_Approval_Mail_Sent_Time__c = system.now();
            Quote.Quote_Customer_Approval_Mail_Sent__c = true;
            if(Quote.Quote_status__c == 'Drafted'){
                Quote.Quote_status__c = 'Quote Sent';
            }
            update Quote;
        }
    }
    @AuraEnabled
    public static void sendBookingFormtoCustomer(Id recordId, String emailContent, List<String> contentIds) {
        system.debug('recordId '+recordId);
        Quote__c Quote = [SELECT Id, Lead_Name__c,Lead_Email__c,Name, Primary_Applicant_Name__c,Encrypted_Key__c,Primary_Applicant_Saluaion__c,Primary_Applicant_Email__c,Primary_Applicant_Mobile_No__c,OwnerId,Owner.Name,Owner.Phone,Owner.Email
                          FROM Quote__c WHERE Id = :recordId LIMIT 1];
        
        Map<String, Id> ownerEmailToOrgWideIdMap = new Map<String, Id>();
        for (OrgWideEmailAddress ow : [SELECT Id, Address FROM OrgWideEmailAddress]) {
            ownerEmailToOrgWideIdMap.put(ow.Address.toLowerCase(), ow.Id);
        }
        
        List<String> ccAddresses = new List<String>();
        List<String> toAddresses = new List<String>();
        
        if (Quote != null && Quote.Primary_Applicant_Email__c != null) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
            
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            PageReference pref;
            
            pref= page.FinalBookingForm;
            pref.getParameters().put('id',recordId);
            
            pref.setRedirect(true);
            system.debug(pref);
            Blob b;
            if(Test.isRunningTest()){
                b = blob.valueOf('Unit.Test');
            }else{
                b = pref.getContent();
            }
            attach.setFileName('BookingForm.pdf');
            attach.setBody(b); 
            emailAttachments.add(attach);
            
            Set<Id> contentDocumentIds = new Set<Id>();
            for (ContentDocumentLink docLink : Quote.ContentDocumentLinks) {
                contentDocumentIds.add(docLink.ContentDocumentId);
            }
            if (!contentDocumentIds.isEmpty()) {
                List<ContentVersion> contentVersions = [SELECT Title,FileExtension, VersionData FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds];
                for (ContentVersion cv : contentVersions) {
                    Messaging.EmailFileAttachment contentAttach = new Messaging.EmailFileAttachment();
                    String fileNameWithExtension = cv.Title + '.' + cv.FileExtension;
                    contentAttach.setFileName(fileNameWithExtension);
                    //contentAttach.setFileName(cv.Title);
                    contentAttach.setBody(cv.VersionData);
                    emailAttachments.add(contentAttach);
                }
            }
            toAddresses.add(Quote.Primary_Applicant_Email__c);
            List<PageReference> vfPages = new List<PageReference>();
            
            // ccAddresses.add('customercare@veegaland.in');
            
            if (!String.isBlank(Quote.Owner.Email)) {
                ccAddresses.add(Quote.Owner.Email);
                
            }
            if (!ccAddresses.isEmpty()) {
                mail.setCcAddresses(ccAddresses);
            }
            mail.setToAddresses(toAddresses);
            
            if (!emailAttachments.isEmpty()) {
                mail.setFileAttachments(emailAttachments);
            }
            String projectDetails = 'Veegaland: Request for Booking Form Approval and DIgital Signature Mail';
            
            // Set the subject line
            mail.setSubject(projectDetails);
            
            mail.setHtmlBody(emailContent);
            
            mail.setSaveAsActivity(true);
            mail.setWhatId(Quote.Id);
            
            String ownerEmail = Quote.Owner.Email;
            if (ownerEmail != null && ownerEmailToOrgWideIdMap.containsKey(ownerEmail.toLowerCase())) {
                mail.setOrgWideEmailAddressId(ownerEmailToOrgWideIdMap.get(ownerEmail.toLowerCase()));
            }
            
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            List<Id> recIdList = new List<Id>{ Quote.Id };
                WhatsappController.SendBookingFormApproval(recIdList);
            
            Quote.Booking_Form_Generated_Time__c = system.now();
            Quote.Booking_Form_Generated__c = true;
            Quote.Booking_Form_Approval_Status__c = 'Pending';
            update Quote;
        }
    }
    
    public static void sendQuoteApprovalEmail(Set<Id> quoteIds,String status) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        // Fetch Quote records with Owner Email
        List<Quote__c> quoteList = [SELECT Id, Name,Primary_Applicant_Mobile_No__c,Primary_Applicant_Name__c,Lead_Name__c, Owner.Email FROM Quote__c WHERE Id IN :quoteIds];
        
        for (Quote__c quote : quoteList) {
            if (quote.Owner.Email != null) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{quote.Owner.Email});
                mail.setSubject('Booking Form '+ status +' for Quote: ' + quote.Name);
                mail.setPlainTextBody('Dear User,\n\nThe Booking Form for Quote "' + quote.Name + '" has been '+status+' by the customer. Please review and proceed with further steps.\n \n Primary Applicant Name: '+quote.Primary_Applicant_Name__c+'\n Primary Applicant Phone: '+quote.Primary_Applicant_Mobile_No__c+' \n\nThank you.');
                mail.setSaveAsActivity(true);
                mail.setWhatId(Quote.Id);
                emails.add(mail);
            }
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
    public static void sendBookingFormUpdatedEmail(Set<Id> quoteIds) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        // Fetch Quote records with Owner Email
        List<Quote__c> quoteList = [SELECT Id, Name,Primary_Applicant_Mobile_No__c,Primary_Applicant_Name__c,Lead_Name__c, Owner.Email FROM Quote__c WHERE Id IN :quoteIds];
        system.debug('quoteList'+ quoteList);
        
        
        for (Quote__c quote : quoteList) {
            if (quote.Owner.Email != null) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{quote.Owner.Email});
                
                List<String> lstCCEmail = new List<String>();
                //lstCCEmail.add('customercare@veegaland.in');
                if (!lstCCEmail.isEmpty()) {
                    mail.setCcAddresses(lstCCEmail);
                }
                
                mail.setSubject('Customer Updated Booking Form for Quote: ' + quote.Name);
                mail.setPlainTextBody('Dear User,\n\nThe customer has updated the booking form and KYC documents for Quote "' + quote.Name + '".Please review and approve if everything is correct.\n \n Primary Applicant Name: '+quote.Primary_Applicant_Name__c+'\n Primary Applicant Phone: '+quote.Primary_Applicant_Mobile_No__c+' \n\nThank you.');
                mail.setSaveAsActivity(true);
                mail.setWhatId(Quote.Id);
                emails.add(mail);
            }
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
    
    public static void sendEmailFinalBookingForm(String quoteId) {
        System.debug('quoteId: ' + quoteId);
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        // Fetch Quote records with Owner Email
        List<Quote__c> quoteList = [
            SELECT Id, Name, Primary_Applicant_Mobile_No__c, Primary_Applicant_Email__c, 
            Primary_Applicant_Name__c, Lead_Name__c, Owner.Email ,Booking_Form_Generated_Time__c,
            Booking_Form_Generated__c 
            FROM Quote__c 
            WHERE Id = :quoteId 
            LIMIT 1
        ];
        
        if (!quoteList.isEmpty()) { 
            Quote__c quote = quoteList[0];
            
            Map<String, Id> ownerEmailToOrgWideIdMap = new Map<String, Id>();
            for (OrgWideEmailAddress ow : [SELECT Id, Address FROM OrgWideEmailAddress]) {
                ownerEmailToOrgWideIdMap.put(ow.Address.toLowerCase(), ow.Id);
            }
            
            if (!String.isBlank(quote.Primary_Applicant_Email__c)) {
                // Generate PDF
                PageReference vfPage = Page.FinalBookingForm;
                vfPage.getParameters().put('id', quote.Id);
                Blob pdfBlob = !Test.isRunningTest() ? vfPage.getContentAsPDF() : Blob.valueOf('testblob');
                List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
                string companyName;
                
                if(!companyDetails.isEmpty()){
                    companyName = companyDetails[0].Label;
                    
                }
                // Create Email
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{quote.Primary_Applicant_Email__c});
                mail.setSubject('Final Booking Form');
                
                mail.setHtmlBody(
                    'Dear ' + quote.Primary_Applicant_Name__c + ',<br/><br/>' + 
                    'The Final Booking Form for Quote <b>"' + quote.Name + '"</b> is attached.<br/><br/>' + 
                    'Thank you for choosing Veegaland Homes<b></b>.<br/><br/>Regards,<br/>'+companyName
                );
                
                //CC to veegaland customercare 
                List<String> lstCCEmail = new List<String>();
                //lstCCEmail.add('customercare@veegaland.in');
                if (!lstCCEmail.isEmpty()) {
                    mail.setCcAddresses(lstCCEmail);
                }
                
                // Attach PDF
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('Booking Form PDF.pdf');
                attachment.setBody(pdfBlob);
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
                
                mail.setSaveAsActivity(true);
                mail.setWhatId(quote.Id);
                String ownerEmail = quote.Owner.Email;
                if (ownerEmail != null && ownerEmailToOrgWideIdMap.containsKey(ownerEmail.toLowerCase())) {
                    mail.setOrgWideEmailAddressId(ownerEmailToOrgWideIdMap.get(ownerEmail.toLowerCase()));
                }
                emails.add(mail);
            }
            quote.Booking_Form_Generated_Time__c = system.now();
            quote.Booking_Form_Generated__c = true;
            update quote;
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
            System.debug('Email sent successfully');
        } else {
            System.debug('No emails to send');
        }
        
    }
    public static void sendFailureEmail(Id ownerId, Id bookingId, String bookingName, String stage) {
        // Fetch only if necessary
        User owner = [SELECT Email FROM User WHERE Id = :ownerId LIMIT 1];
        
        // Use a Map for easier lookup and scalability
        Map<String, String> nextStageMap = new Map<String, String>{
            'Token'   => 'Welcome Email',
                'Advance' => 'Sale Agreement Registration'
                };
                    
                    Map<String, String> amountTypeMap = new Map<String, String>{
                        'Token'   => 'token advance payment',
                            'Advance' => 'advance payment'
                            };
                                
                                String nextStage = nextStageMap.get(stage);
        String amountType = amountTypeMap.get(stage);
        
        // Send email only if everything is present
        if (owner.Email != null && nextStage != null && amountType != null) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{ owner.Email });
            email.setSubject('Booking ' + amountType +'  not cleared');
            email.setPlainTextBody(
                'The booking stage could not be moved to "' + nextStage + 
                '" because the ' + amountType + 
                ' has not been fully received for Booking: ' + bookingName + 
                '. Please follow up with the customer.'
            );
            
            //CC to veegaland customercare 
            List<String> lstCCEmail = new List<String>();
            // lstCCEmail.add('customercare@veegaland.in');
            if (!lstCCEmail.isEmpty()) {
                email.setCcAddresses(lstCCEmail);
            }
            email.setSaveAsActivity(true);
            email.setWhatId(bookingId);
            
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
        }
    }
    
    @Future(callout=true)
    public static void sendEmailGenerateReceipts(List<Id> receiptIds) {
        system.debug('Here inside sendEmailGenerateReceipts');
        Map<Id, String> resultMap = new Map<Id, String>();
        NumberTOWordConvertion convert = new NumberTOWordConvertion();
        
        try {
            List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
            string companyName;
            
            if(!companyDetails.isEmpty()){
                companyName = companyDetails[0].Label;
                
            }
            if (receiptIds == null || receiptIds.isEmpty()) {
                system.debug('No Receipt Ids provided');
            }
            
            // Retrieve all Receipt records
            Map<Id, Receipt__c> receiptMap = new Map<Id, Receipt__c>(
                [SELECT Id, Name,Booking__c,Check_Transaction_Nmber__c,Amount_In_Words__c,Total_Received_Amount__c, CreatedBy.Email FROM Receipt__c WHERE Id IN :receiptIds]
            );
            
            // Collect Booking Ids
            Set<Id> bookingIds = new Set<Id>();
            for (Receipt__c receipt : receiptMap.values()) {
                if (receipt.Booking__c != null) {
                    bookingIds.add(receipt.Booking__c);
                } else {
                    resultMap.put(receipt.Id, 'Receipt or associated Booking record not found.');
                }
            }
            
            // Retrieve Booking records
            Map<Id, Booking__c> bookingMap = new Map<Id, Booking__c>(
                [SELECT Id, Email1__c, First_Applicant_Name__c, Owner.Email,Owner.Phone, Owner.Name, 
                 CRM_Manager__c, CRM_Manager__r.Email 
                 FROM Booking__c WHERE Id IN :bookingIds]
            );
            
            // Retrieve Co-Applicants
            Map<Id, List<Co_Applicant__c>> coApplicantMap = new Map<Id, List<Co_Applicant__c>>();
            for (Co_Applicant__c coApp : [SELECT Id, Name, Email__c, Booking__c FROM Co_Applicant__c WHERE Booking__c IN :bookingIds]) {
                if (!coApplicantMap.containsKey(coApp.Booking__c)) {
                    coApplicantMap.put(coApp.Booking__c, new List<Co_Applicant__c>());
                }
                coApplicantMap.get(coApp.Booking__c).add(coApp);
            }
            
            // Retrieve Org Wide Email Addresses
            Map<String, OrgWideEmailAddress> oweaMap = new Map<String, OrgWideEmailAddress>();
            for (OrgWideEmailAddress owea : [SELECT Id, Address FROM OrgWideEmailAddress]) {
                oweaMap.put(owea.Address, owea);
            }
            
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
            List<ContentVersion> cvs = new List<ContentVersion>();
            for (Id receiptId : receiptMap.keySet()) {
                Receipt__c receipt = receiptMap.get(receiptId);
                Booking__c booking = bookingMap.get(receipt.Booking__c);
                
                if (receipt == null || receipt.Id == null) {
                    system.debug('Error: Receipt or Receipt.Id is null for receiptId: ' + receiptId);
                    resultMap.put(receiptId, 'Invalid Receipt record.');
                    continue;
                }
                
                if (booking == null || String.isBlank(booking.Email1__c)) {
                    system.debug('Error: Booking not found or missing email for bookingId: ' + receipt.Booking__c);
                    resultMap.put(receiptId, 'Booking record not found or missing email.');
                    continue;
                }
                
                // Generate receipt PDF
                PageReference receiptPage = Page.RECEIPT;
                receiptPage.getParameters().put('id', receipt.Id);
                Blob pdfBlob = !Test.isRunningTest() ? receiptPage.getContentAsPDF() : Blob.valueOf('testblob');
                
                // 1. Save PDF as a File (ContentVersion)
                ContentVersion cv = new ContentVersion();
                cv.Title = 'Receipt-' + receipt.Name;
                cv.PathOnClient = 'Receipt-' + receipt.Name + '.pdf';
                cv.VersionData = pdfBlob;
                cv.FirstPublishLocationId = receipt.Id; // This auto-links the file to the Receipt__c record!
                cvs.add(cv);
                
                List<String> sendTo = new List<String>{ booking.Email1__c }; 
                    
                    List<String> lstCCEmail = new List<String>{ booking.Owner.Email };
                        if (booking.CRM_Manager__c != null) {
                            lstCCEmail.add(booking.CRM_Manager__r.Email);
                        }
                lstCCEmail.add('customercare@veegaland.in');
                
                // Add Co-Applicant Emails
                if (coApplicantMap.containsKey(booking.Id)) {
                    for (Co_Applicant__c coApp : coApplicantMap.get(booking.Id)) {
                        if (!String.isBlank(coApp.Email__c)) {
                            sendTo.add(coApp.Email__c);
                        }
                    }
                }
                String Total_Received_Amount_In_Words='';
                if (receipt.Total_Received_Amount__c != null) {
                    Total_Received_Amount_In_Words = convert.getNumberTOWordConvertion(receipt.Total_Received_Amount__c);
                }
                // Prepare Email
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(sendTo);
                if (!lstCCEmail.isEmpty()) {
                    email.setCcAddresses(lstCCEmail);
                }
                email.setSubject('Receipt for Your Payment');
                email.setHtmlBody('Dear '+booking.First_Applicant_Name__c+
                                  ',<br/><br/>'+'We are pleased to inform you that your payment Rs.'+ receipt.Total_Received_Amount__c +
                                  ' ('+Total_Received_Amount_In_Words+' ) against reference'+ ' Cheque/NEFT number '+ 
                                  receipt.Check_Transaction_Nmber__c +' has been successfully credited to our account. '+ 
                                  'Thank you for your timely payment. Please find the attached receipt for your reference.<br/>'+
                                  'Should you have any further questions, feel free to reach out.<br/>'+
                                  'Thank you for choosing Veegaland Homes.<br/><br/>'+'Best regards,<br/>'+
                                  companyName+'<br/>'+
                                  booking.Owner.Name+'<br/>'+
                                  booking.Owner.Phone
                                 );
                
                
                // Set Org-Wide Email Address if available
                if (!Test.isRunningTest() && oweaMap.containsKey(receipt.CreatedBy.Email)) {
                    email.setOrgWideEmailAddressId(oweaMap.get(receipt.CreatedBy.Email).Id);
                }
                
                // Attach PDF
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('Receipt.pdf');
                attachment.setBody(pdfBlob);
                email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
                
                email.setSaveAsActivity(true);
                email.setWhatId(receipt.Id);
                emailsToSend.add(email);
                resultMap.put(receipt.Id, 'Email queued for sending.');
            }
            
            // Send emails in bulk
            if (!emailsToSend.isEmpty()) {
                system.debug('Here inside emailsToSend' + emailsToSend.size());
                Messaging.sendEmail(emailsToSend);
            }
            
            if (!cvs.isEmpty()) {
                insert cvs;
            }
        } catch (Exception e) {
            system.debug('Error sending emails: ' + e.getMessage());
        }
        
        
    }
    /*  public static void testCover(){
decimal i =0;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
}*/
    
}