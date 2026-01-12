public class DraftAgreementController {
    
    @AuraEnabled(cacheable=true)
    public static BookingWrapper getAgreementDetails(Id bookingId) {
        if (String.isBlank(bookingId)) {
            throw new AuraHandledException('Booking Id is required');
        }
        List<BookingController.BookingWrapper> resultList = new List<BookingController.BookingWrapper>();
        
        Booking__c booking = [
            SELECT Id,
            Draft_Agreement_Uploaded__c,
            Draft_Agreement_URL__c,
            Agreement_Approval_Status__c,
            Agreement_Details_Request_Send__c,
            Received_Agreement_Details_from_Customer__c,
            Agreement_Details_Verified__c,
            Sale_Agreement_Approval_time__c,
            Agreement_Details_Verification__c,
            FInal_Draft_Agreement_Uploaded__c,
            Final_Draft_Agreement_Mail_Send__c,
            Draft_Agreement_Email_Send__c,
            Draft_Agreement_Status__c
            FROM Booking__c
            WHERE Id = :bookingId
            LIMIT 1
        ];
        
        String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()LIMIT 1].Profile.Name;
        
        BookingWrapper wrap = new BookingWrapper();
        wrap.UserProfile = profileName;
        wrap.Draft_Agreement_Uploaded = booking.Draft_Agreement_Uploaded__c;
        wrap.Draft_Agreement_Email_Send = booking.Draft_Agreement_Email_Send__c;
        wrap.Draft_Agreement_URL = booking.Draft_Agreement_URL__c;
        wrap.Agreement_Approval_Status = booking.Agreement_Approval_Status__c;
        wrap.Agreement_Details_Request_Send = booking.Agreement_Details_Request_Send__c;
        wrap.Received_Agreement_Details_from_Customer = booking.Received_Agreement_Details_from_Customer__c;
        wrap.Agreement_Details_Verified = booking.Agreement_Details_Verified__c;
        wrap.Sale_Agreement_Approval_time = booking.Sale_Agreement_Approval_time__c;
        wrap.Email_content = BookingController.getBookingAndApplicantDetails(bookingId);
        wrap.Agreement_Details_Verification = booking.Agreement_Details_Verification__c;
        wrap.FInal_Draft_Agreement_Email_Send = booking.Final_Draft_Agreement_Mail_Send__c;
        wrap.FInal_Draft_Agreement_Uploaded = booking.FInal_Draft_Agreement_Uploaded__c;
        wrap.Draft_Agreement_Status = booking.Draft_Agreement_Status__c;
        return wrap;
    }
    
    public class BookingWrapper {
        @AuraEnabled public Boolean Draft_Agreement_Uploaded {get; set;}
        @AuraEnabled public Boolean Draft_Agreement_Email_Send {get; set;}
        @AuraEnabled public String Draft_Agreement_URL {get; set;}
        @AuraEnabled public String Agreement_Approval_Status {get; set;}
        @AuraEnabled public Boolean Agreement_Details_Request_Send {get; set;}
        @AuraEnabled public Boolean Received_Agreement_Details_from_Customer {get; set;}
        @AuraEnabled public Boolean Agreement_Details_Verified {get; set;}
        @AuraEnabled public Datetime Sale_Agreement_Approval_time {get; set;}
        @AuraEnabled public List<BookingController.BookingWrapper> Email_content {get; set;}
        @AuraEnabled public String Agreement_Details_Verification {get; set;}
        @AuraEnabled public Boolean FInal_Draft_Agreement_Email_Send {get; set;}
        @AuraEnabled public Boolean FInal_Draft_Agreement_Uploaded {get; set;}
        @AuraEnabled public String UserProfile {get; set;}
        @AuraEnabled public Boolean FInal_Agreement_Upload_and_Email_Send {get; set;}
        @AuraEnabled public String Draft_Agreement_Status {get; set;}
    }
    
    @AuraEnabled
    public static void saveFileAndSendEmail(String recordId) {
        
        // Retrieve the Booking record
        Booking__c booking = [SELECT Id, salutation_Applicant1__c,Email1__c,Agreement_Approval_Status__c, CRM_Manager__r.Email, First_Applicant_Name__c, Draft_Agreement_Uploaded__c 
                              FROM Booking__c WHERE Id = :recordId LIMIT 1];
        // Check if the booking record is found
        if (booking == null) {
            throw new CustomException('Booking record not found.');
        }
        
        // Get the CRM Manager's email from the booking record
        User crmManager = [SELECT Email FROM User WHERE Id =: booking.CRM_Manager__c LIMIT 1];
        if (crmManager == null) {
            throw new CustomException('CRM Manager not found.');
        }
        
        // Get the recipient email (Email1__c)
        String recipientEmail = booking.Email1__c;
        if (String.isBlank(recipientEmail)) {
            throw new CustomException('Recipient email not found.');
        }
        
        // Query ContentDocumentLink to get all linked documents for this booking
        List < ContentDocumentLink > docLinks = [SELECT ContentDocumentId
                                                 FROM ContentDocumentLink
                                                 WHERE LinkedEntityId =: recordId
                                                ];
        if (docLinks.isEmpty()) {
            throw new CustomException('No documents found for the booking.');
        }
        
        // Extract ContentDocumentIds from the ContentDocumentLink records
        Set < Id > contentDocumentIds = new Set < Id > ();
        for (ContentDocumentLink docLink: docLinks) {
            contentDocumentIds.add(docLink.ContentDocumentId);
        }
        
        // Get the most recent "Draft Sale Deed" document from ContentVersion
        List < ContentVersion > draftSaleAgreement = [SELECT Id, Title, VersionData
                                                      FROM ContentVersion
                                                      WHERE ContentDocumentId IN: contentDocumentIds
                                                      AND Title LIKE '%Draft Sale Agreement%'
                                                      ORDER BY CreatedDate DESC LIMIT 1
                                                     ];
        
        // Check if a valid Draft Sale Deed document was found
        if (draftSaleAgreement.isEmpty()) {
            throw new CustomException('No Draft Sale Agreement document found.');
        }
        
        ContentVersion draftAgreement = draftSaleAgreement[0]; 
        String customerName = booking.salutation_Applicant1__c + ' ' + booking.First_Applicant_Name__c;
        
        // Construct secure link
        String secureLink = 'https://site-speed-6226.my.salesforce-sites.com/AgreementApproval?id=' + recordId;
        //String secureLink = 'https://site-speed-6226--postsbox1.sandbox.my.salesforce-sites.com/AgreementApproval?id=' + recordId;
        List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
        string companyName;
        string companyAddress1;
        string companyAddress2;
        string companyAddress3;
        if(!companyDetails.isEmpty()){
            companyName = companyDetails[0].Label;
            companyAddress1 =   companyDetails[0].Registered_Address__c;
            companyAddress2 =   companyDetails[0].Address2__c;
            companyAddress3 =   companyDetails[0].Address3__c;
        }
        // Construct email content with safe values
        String defaultEmailContent = '<div style="color: black;"><strong>Dear ' + customerName + ',</strong><br/><br/>' +
            'We hope this message finds you well.<br/>' +
            'Please find below a secure link to review the draft version of your agreement:<br/>' +
            'Secure Link: <a href="' + secureLink + '" style="color: blue; text-decoration: underline;" target="_blank">Click here to review the agreement</a><br/>' +
            'You can add your comments or suggestions directly through the review page. This link has also been sent to your WhatsApp for your convenience.<br/>' +
            'If you have any questions or need assistance, feel free to reach out to us.<br/>' +
            '<p>Thanks & Regards,</p><br/>' +
            '<p><strong>Midhu Siju | Officer - Customer Relations | 9207054444</strong></p>' +
            '<p><strong>Alitta Lijoy | Customer Relation Executive | 90482 37066</strong></p>' +
            '<br/>' +
            '<p><strong>'+companyName+'</strong></p>' +
            '<p>Regd. Office: '+companyAddress1+' '+companyAddress2+' '+companyAddress3+'</p>' +
            '<p>Tel: +91 484 2584000 / 2973944, +91 6235051144</p>' +
            '<p><a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a></p>' +
            '<br/>' +
            '<p>Follow us on: ' +
            '<a href="https://www.facebook.com/veegalanddevelopers" target="_blank">Facebook</a> | ' +
            '<a href="https://www.instagram.com/veegalanddevelopers" target="_blank">Instagram</a> | ' +
            '<a href="https://www.linkedin.com/company/veegalanddevelopers" target="_blank">LinkedIn</a> | ' +
            '<a href="https://www.youtube.com/c/VeegalandDevelopers" target="_blank">YouTube</a>' +
            '</p>' +
            '</div>';
        
        // Send an email with the file attached
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :booking.CRM_Manager__r.Email];
        
        List<String> sendTo = new List<String>();
        List<String> lstCCEmail = new List<String>();
        sendTo.add(booking.Email1__c);
        if (booking.Email1__c != null) {
            sendTo.add(booking.Email1__c);
        }
        
        if (sendTo.size() > 0) {
            mail.setToAddresses(sendTo);
        }
        
        // Set Org-Wide Email Address
        if (owea.size() > 0) {
            mail.setOrgWideEmailAddressId(owea[0].Id);
        }
        
        // Include CC addresses
        //lstCCEmail.add(bookingRecord.Owner.Email);
        if (booking.CRM_Manager__c != null) {
            lstCCEmail.add(booking.CRM_Manager__r.Email);
        }
       // lstCCEmail.add('customercare@veegaland.in');
        if (lstCCEmail.size() > 0) {
            mail.setCcAddresses(lstCCEmail);
        }
        
        
        mail.setSubject(+companyName+': Draft Sale Agreement Approval Request');
        mail.setHtmlBody(defaultEmailContent);
        
        /* if (!Test.isRunningTest()) {
String CreatedEmail = bookingRecord.CRM_Manager__r.Email;
List<OrgWideEmailAddress> orgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :CreatedEmail LIMIT 1];
if (orgWideEmail.size() > 0) {
mail.setOrgWideEmailAddressId(orgWideEmail[0].Id);
}
}*/
        
        // Create the EmailFileAttachment and set its properties
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        String fileNameWithExtension = 'Draft Sale Agreement' + '.pdf';
        attachment.setFileName(fileNameWithExtension); 
        attachment.setBody(draftAgreement.VersionData); 
        
        // Attach the file to the email
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
        mail.setSaveAsActivity(true);
        mail.setWhatId(recordId);
        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        // Update the Draft_Agreement_Uploaded__c field to true
        booking.Draft_Agreement_Status__c = 'Customer Approval';
        booking.Draft_Agreement_Email_Send__c = true;
        booking.Agreement_Approval_Status__c = 'Pending';
        // Update the Booking record
        update booking;
    }
    
    @AuraEnabled
    public static void saveFinalFileAndSendEmail(String recordId) {
        
        Booking__c booking = [SELECT Id, Final_Draft_Agreement_Mail_Send__c, Email1__c, CRM_Manager__r.Email, salutation_Applicant1__c, First_Applicant_Name__c, Draft_Agreement_Uploaded__c FROM Booking__c WHERE Id = :recordId LIMIT 1];
        
        // Check if the booking record is found
        if (booking == null) {
            throw new CustomException('Booking record not found.');
        }
        
        // Get the CRM Manager's email from the booking record
        User crmManager = [SELECT Email FROM User WHERE Id =: booking.CRM_Manager__c LIMIT 1];
        if (crmManager == null) {
            throw new CustomException('CRM Manager not found.');
        }
        
        // Get the recipient email (Email1__c)
        String recipientEmail = booking.Email1__c;
        if (String.isBlank(recipientEmail)) {
            throw new CustomException('Recipient email not found.');
        }
        
        // Query ContentDocumentLink to get all linked documents for this booking
        List < ContentDocumentLink > docLinks = [SELECT ContentDocumentId
                                                 FROM ContentDocumentLink
                                                 WHERE LinkedEntityId =: recordId
                                                ];
        if (docLinks.isEmpty()) {
            throw new CustomException('No documents found for the booking.');
        }
        
        // Extract ContentDocumentIds from the ContentDocumentLink records
        Set < Id > contentDocumentIds = new Set < Id > ();
        for (ContentDocumentLink docLink: docLinks) {
            contentDocumentIds.add(docLink.ContentDocumentId);
        }
        
        // Get the most recent "Draft Sale Deed" document from ContentVersion
        List < ContentVersion > draftFinalAgreement = [SELECT Id, Title, VersionData
                                                       FROM ContentVersion
                                                       WHERE ContentDocumentId IN: contentDocumentIds
                                                       AND Title LIKE '%Final Draft Agreement%'
                                                       ORDER BY CreatedDate DESC LIMIT 1
                                                      ];
        
        // Check if a valid Draft Sale Deed document was found
        if (draftFinalAgreement.isEmpty()) {
            throw new CustomException('No Draft Sale Deed document found.');
        }
        ContentVersion finalAgreement = draftFinalAgreement[0]; 
        
        List<Company_Name__mdt> companyDetails = [select Id, DeveloperName, CIN__c,Address2__c,Address3__c,Label, Registered_Address__c from Company_Name__mdt limit 1];
        string companyName;
        string companyAddress1;
        string companyAddress2;
        string companyAddress3;
        if(!companyDetails.isEmpty()){
            companyName = companyDetails[0].Label;
            companyAddress1 =   companyDetails[0].Registered_Address__c;
            companyAddress2 =   companyDetails[0].Address2__c;
            companyAddress3 =   companyDetails[0].Address3__c;
        }
        
        String customerName = booking.salutation_Applicant1__c +' ' + booking.First_Applicant_Name__c;
        
        // Construct email content with safe values
        String defaultEmailContent = '<div style="color: black;"><strong>Dear ' + customerName + ',</strong><br/><br/>' +
            'We are pleased to share the final version of your sale agreement.<br/>' +
            'The final document has been attached for your reference.<br/>' +
            'If you have any questions or need assistance, feel free to reach out to us.<br/>' +
            '<p>Thanks & Regards,</p><br/>' +
            '<p><strong>Midhu Siju | Officer - Customer Relations | 9207054444</strong></p>' +
            '<p><strong>Alitta Lijoy | Customer Relation Executive | 90482 37066</strong></p>' +
            '<br/>' +
            '<p><strong>'+companyName+'</strong></p>' +
            '<p>Regd. Office: '+companyAddress1+' '+companyAddress2+' '+companyAddress3+'</p>' +
            '<p>Tel: +91 484 2584000 / 2973944, +91 6235051144</p>' +
            '<p><a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a></p>' +
            '<br/>' +
            '<p>Follow us on: ' +
            '<a href="https://www.facebook.com/veegalanddevelopers" target="_blank">Facebook</a> | ' +
            '<a href="https://www.instagram.com/veegalanddevelopers" target="_blank">Instagram</a> | ' +
            '<a href="https://www.linkedin.com/company/veegalanddevelopers" target="_blank">LinkedIn</a> | ' +
            '<a href="https://www.youtube.com/c/VeegalandDevelopers" target="_blank">YouTube</a>' +
            '</p>' +
            '</div>';
        
        // Send an email with the file attached
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :booking.CRM_Manager__r.Email];
        
        List<String> sendTo = new List<String>();
        List<String> lstCCEmail = new List<String>();
        sendTo.add(booking.Email1__c);
        if (booking.Email1__c != null) {
            sendTo.add(booking.Email1__c);
        }
        
        if (sendTo.size() > 0) {
            mail.setToAddresses(sendTo);
        }
        
        // Set Org-Wide Email Address
        if (owea.size() > 0) {
            mail.setOrgWideEmailAddressId(owea[0].Id);
        }
        
        // Include CC addresses
        //lstCCEmail.add(bookingRecord.Owner.Email);
        if (booking.CRM_Manager__c != null) {
            lstCCEmail.add(booking.CRM_Manager__r.Email);
        }
        //lstCCEmail.add('customercare@veegaland.in');
        if (lstCCEmail.size() > 0) {
            mail.setCcAddresses(lstCCEmail);
        }
        
        mail.setSubject(+companyName+' : Final Draft Sale Agreement');
        mail.setHtmlBody(defaultEmailContent);
        
        /*  if(!Test.isRunningTest()){
String CreatedEmail = bookingRecord.CRM_Manager__r.Email;
list<OrgWideEmailAddress> orgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :CreatedEmail LIMIT 1];
if (orgWideEmail.size() > 0) {
mail.setOrgWideEmailAddressId(orgWideEmail[0].Id);
}
}*/
        // Create the EmailFileAttachment and set its properties
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        String fileNameWithExtension = 'Final Sale Agreement Draft' + '..pdf';
        attachment.setFileName(fileNameWithExtension); // Assumes the document is a PDF; change if necessary
        attachment.setBody(finalAgreement.VersionData);  // Set the file content (base64 decoded data)
        
        // Attach the file to the email
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
        mail.setSaveAsActivity(true);
        mail.setWhatId(recordId);
        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        // Update the Draft_Agreement_Uploaded__c field to true
        booking.Final_Draft_Agreement_Mail_Send__c = true;
        // Update the Booking record
        update booking;
    }
    
    public class CustomException extends Exception {}
    
    @AuraEnabled
    public static void updateBookingURL(Id bookingId, String documentId) {
        if (bookingId == null) {
            throw new AuraHandledException('Booking Id is required.');
        }
        
       // try {
            list < ContentVersion > draftAgreement = [
                SELECT ContentDocumentId, Title
                FROM ContentVersion
                WHERE ContentDocumentId =: documentId
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            if (draftAgreement.isEmpty()) return;
            
            ContentDistribution dist = [
                SELECT ContentDocumentId, DistributionPublicUrl, ContentDownloadUrl
                FROM ContentDistribution
                WHERE ContentDocumentId =: draftAgreement[0].ContentDocumentId
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            
            String draftUrl = dist.ContentDownloadUrl;
            
            Booking__c bookingToUpdate = new Booking__c(
                Id = bookingId,
                Draft_Agreement_URL__c = draftUrl,
                Draft_Agreement_Uploaded__c = true
            );
            update bookingToUpdate;
            
            List < ContentDocumentLink > oldLinks = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId =: bookingId
                AND ContentDocument.LatestPublishedVersion.Title = 'Draft Sale Agreement'
                AND ContentDocumentId !=: documentId
            ];
            
            if (!oldLinks.isEmpty()) {
                Set < Id > oldDocIds = new Set < Id > ();
                for (ContentDocumentLink link: oldLinks) {
                    oldDocIds.add(link.ContentDocumentId);
                }
                
                List < ContentDocument > docsToDelete = [
                    SELECT Id FROM ContentDocument WHERE Id IN: oldDocIds
                ];
                delete docsToDelete;
            }
       // } catch (Exception e) {
        //    throw new AuraHandledException('Error updating booking: ' + e.getMessage());
       // }
    }
    
    @AuraEnabled
    public static void updatefinalSaleAgreementUpload(Id bookingId, String documentId) {
        if (bookingId == null) {
            throw new AuraHandledException('Booking Id is required.');
        }
        
        try {
            Booking__c bookingToUpdate = new Booking__c(
                Id = bookingId,
                FInal_Draft_Agreement_Uploaded__c = true
            );
            update bookingToUpdate;

             List < ContentDocumentLink > oldLinks = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId =: bookingId
                AND ContentDocument.LatestPublishedVersion.Title = 'Final Draft Agreement'
                AND ContentDocumentId !=: documentId
            ];
            
            if (!oldLinks.isEmpty()) {
                Set < Id > oldDocIds = new Set < Id > ();
                for (ContentDocumentLink link: oldLinks) {
                    oldDocIds.add(link.ContentDocumentId);
                }
                
                List < ContentDocument > docsToDelete = [
                    SELECT Id FROM ContentDocument WHERE Id IN: oldDocIds
                ];
                delete docsToDelete;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error updating booking: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String sendAgreementdetailsrequest(Id recId, String emailContent){
        return GenerateDocumnetController.sendEmailGenerateAgreementdetailsrequest(recId,emailContent);
    }
    
    @AuraEnabled
    public static void updateBookingVerificationStatus(Id bookingId, String status, String rejectionComment) {
        try {
            // Retrieve the booking record
            Booking__c booking = [SELECT Id, Agreement_Details_Verification__c, CRM_Manager__c, CRM_Manager__r.Email,Draft_Agreement_Status__c
                                  FROM Booking__c WHERE Id = :bookingId LIMIT 1];
            
            if (status == 'Rejected') {
                // Update the Agreement_Details_Verification__c field to 'Rejected'
                booking.Agreement_Details_Verification__c = 'Rejected';
                booking.Agreement_Details_Rejection_Comments__c = rejectionComment;
            } else if (status == 'Verified') {
                // Handle status update to 'Verified'
                booking.Agreement_Details_Verification__c = 'Verified';
                booking.Draft_Agreement_Status__c = 'Draft Agreement';
            }
            
            // Update the booking
            update booking;
        } catch (Exception e) {
            throw new AuraHandledException('Error updating booking status: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void sendRejectionEmail(Id bookingId, String rejectionComment) {
        try {
            // Retrieve Booking record with CRM Manager, Legal Team, Unit, and Project details
            Booking__c booking = [
                SELECT Id, Name, 
                CRM_Manager__r.Email, 
                First_Applicant_Name__c,
                Legal_team__r.Email,
                Plot__r.Name,
                Project1__r.Name
                FROM Booking__c 
                WHERE Id = :bookingId 
                LIMIT 1
            ];
            
            // Logged-in user name
            String currentUserName = UserInfo.getName();
            List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :booking.Legal_team__r.Email];
            // Build the booking link using org domain
            String baseUrl = System.URL.getOrgDomainUrl().toExternalForm();
            String bookingLink = baseUrl + '/' + booking.Id;
            List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
            string companyName;
            if(!companyDetails.isEmpty()){
                companyName = companyDetails[0].Label;
            }
            // Build the email body
            String body = 'Dear Team,\n\n' +
                'The Draft Sale Agreement for the following booking could not be prepared as the legal team found the data provided to be insufficient or incorrect.' +
                'Applicant: ' + booking.First_Applicant_Name__c + '\n' +
                'Project: ' + booking.Project1__r.Name + '\n' +
                'Unit: ' + booking.Plot__r.Name + '\n\n' +
                'Reason for rejection:\n' + rejectionComment + '\n\n' +
                'Rejected by: ' + currentUserName + '\n' +
                'Booking Link: ' + bookingLink + '\n\n' +
                'Please review and correct any missing or inaccurate information in the draft agreement, then resubmit it.\n\n' +
                'Regards,\n' +
                companyName;
            
            
            List<String> toAddresses = new List<String>();
            if (booking.CRM_Manager__r.Email != null) {
                toAddresses.add(booking.CRM_Manager__r.Email);
            }
            if (booking.Legal_team__r.Email != null) {
                toAddresses.add(booking.Legal_team__r.Email);
            }
            
            // Send rejection email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(toAddresses);
            if (owea.size() > 0) {
                email.setOrgWideEmailAddressId(owea[0].Id);
            }
            
            email.setSaveAsActivity(true);
            email.setWhatId(booking.Id);
            email.setSubject('Draft Sale Agreement Rejected: ' + booking.Project1__r.Name +' '+ booking.Plot__r.Name +' '+ booking.First_Applicant_Name__c);
            email.setPlainTextBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            
        } catch (Exception e) {
            throw new AuraHandledException('Error sending rejection email: ' + e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static String submitForApproval(Id bookingId) {
        try {
            // Fetch booking details
            Booking__c booking = [
                SELECT Id, Name, Unit_Number__c, Plot__r.Name, 
                Agreement_Details_Verification__c,
                Legal_Team__c, Legal_Team__r.Email,Project1__r.Name,
                CRM_Manager__c, CRM_Manager__r.Email
                FROM Booking__c
                WHERE Id = :bookingId
                LIMIT 1
            ];
            
            // Update field
            booking.Agreement_Details_Verification__c = 'Pending';
            booking.Draft_Agreement_Status__c = 'Agreement Details';
            update booking;
            //fetch company name
            List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,Label, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
            string companyName;
            if(!companyDetails.isEmpty()){
                companyName = companyDetails[0].Label;
            }
            // Prepare email
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :booking.CRM_Manager__r.Email];
            
            if (booking.Legal_Team__r.Email != null) {
                mail.setToAddresses(new List<String>{ booking.Legal_Team__r.Email });
            }
            if (booking.CRM_Manager__r.Email != null) {
                mail.setCcAddresses(new List<String>{ booking.CRM_Manager__r.Email });
            }
            
            String bookingLink = System.URL.getOrgDomainUrl().toExternalForm() + '/' + booking.Id;
            String subject = 'Booking Verification Required - ' + booking.Name;
            String body = 'Dear Legal Team,<br/><br/>' +
                'The booking details have been submitted for verification.<br/><br/>' +
                '<b>Booking Link:</b> <a href="' + bookingLink + '">' + booking.Name + '</a><br/>' +
                '<b>Booking Id:</b> ' + booking.Name + '<br/>' +
                '<b>Unit Number:</b> ' + (booking.Plot__r != null ? booking.Plot__r.Name +'-'+booking.Project1__r.Name: 'N/A') + '<br/>' +
                'Please verify the booking details.<br/><br/>' +
                'Thanks ,<br/>Veegaland CRM<br/>'+companyName;
            
            mail.setSubject(subject);
            mail.setHtmlBody(body);
            if (owea.size() > 0) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }
            
            mail.setSaveAsActivity(true);
            mail.setWhatId(booking.Id);
            mails.add(mail);
            Messaging.sendEmail(mails);
            
            return 'Booking submitted for approval successfully and email sent.';
        } catch (Exception ex) {
            System.debug('Error in submitForApproval: ' + ex.getMessage());
            return 'Error: ' + ex.getMessage();
        }
    }

    public static void notifyAgreementDetailsApproved(Set<Id> bookingIds) {
    if (bookingIds == null || bookingIds.isEmpty()) {
        return;
    }
    
    List<Booking__c> bookings = [
        SELECT Id,
               Name,
               First_Applicant_Name__c,
               Agreement_Details_Rejection_Comments__c,
               Draft_Agreement_Status__c,
               CRM_Manager__r.Email,
               CRM_Manager__r.Name,
               Plot__r.Name,
               Project1__r.Name
        FROM Booking__c
        WHERE Id IN :bookingIds
    ];
    
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    
    for (Booking__c bk : bookings) {
        // No valid recipient, skip
        if (bk.CRM_Manager__r == null || String.isBlank(bk.CRM_Manager__r.Email)) {
            continue;
        }
        
        String bookingLink = URL.getOrgDomainUrl().toExternalForm() + '/' + bk.Id;
                          
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{ bk.CRM_Manager__r.Email });
        mail.setSubject(
            'Agreement Details Approved by Legal - ' +
            nvl(bk.Plot__r.Name, '--') + ' - ' +
            nvl(bk.Project1__r.Name, '--')
        );
        
        String body =
            'Hello CRM Team' + ',<br/><br/>' +
            'The agreement details for the below booking has been <b>approved by the Legal team</b>.<br/><br/>' +

            '<b>Booking Details</b><br/>' +
            'Customer: ' + nvl(bk.First_Applicant_Name__c, '--') + '<br/>' +
            'Booking Name: ' + nvl(bk.Name, '--') + '<br/>' +
            'Unit: ' + nvl(bk.Plot__r.Name, '--') + ' / ' + nvl(bk.Project1__r.Name, '--') + '<br/>' +

            'Open the booking record: <a href="' + bookingLink + '">' + bookingLink + '</a><br/><br/>' +

            'Thanks,<br/>' +
            'Admin<br/>' +
            'Veegaland Developers Limited<br/>' +
            'System Notification';
        
        mail.setHtmlBody(body);
        mail.setSaveAsActivity(true);
        mail.setWhatId(bk.Id);
        
        emails.add(mail);
    }
    
    if (!emails.isEmpty()) {
        Messaging.sendEmail(emails);
    }
}

public static void notifyAgreementDetailsRejected(Set<Id> bookingIds) {
    if (bookingIds == null || bookingIds.isEmpty()) {
        return;
    }
    
    List<Booking__c> bookings = [
        SELECT Id,
               Name,
               First_Applicant_Name__c,
               Agreement_Details_Rejection_Comments__c,
               Draft_Agreement_Status__c,
               CRM_Manager__r.Email,
               CRM_Manager__r.Name,
               Plot__r.Name,
               Project1__r.Name
        FROM Booking__c
        WHERE Id IN :bookingIds
    ];
    
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    
    for (Booking__c bk : bookings) {
        // No recipient? skip.
        if (bk.CRM_Manager__r == null || String.isBlank(bk.CRM_Manager__r.Email)) {
            continue;
        }
        
        String bookingLink = URL.getOrgDomainUrl().toExternalForm() + '/' + bk.Id;
        String comments = nvl(bk.Agreement_Details_Rejection_Comments__c, '--');
       
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{ bk.CRM_Manager__r.Email });
        
        mail.setSubject(
            'Agreement Details Rejected by Legal - ' +
            nvl(bk.Plot__r.Name, '--') + ' - ' +
            nvl(bk.Project1__r.Name, '--')
        );
        
        String body =
            'Hello CRM Team' + ',<br/><br/>' +
            'The Draft Sale Agreement for the following booking could not be prepared as the legal team found the data provided to be insufficient or incorrect.' +
            
            '<b>Booking Details</b><br/>' +
            'Customer: ' + nvl(bk.First_Applicant_Name__c, '--') + '<br/>' +
            'Booking Name: ' + nvl(bk.Name, '--') + '<br/>' +
            'Unit: ' + nvl(bk.Plot__r.Name, '--') + ' / ' + nvl(bk.Project1__r.Name, '--') + '<br/>' +
            'Current Status: ' + nvl(bk.Draft_Agreement_Status__c, '--') + '<br/>' +
            '<b>Rejection Comments:</b><br/>' + comments + '<br/><br/>' +
            
            'Please review and correct any missing or inaccurate information in the draft agreement, then resubmit for approval.<br/><br/>' +
            'Open the booking record: <a href="' + bookingLink + '">' + bookingLink + '</a><br/><br/>' +
            'Thanks,<br/>' +
            'Admin<br/>' +
            'System Notification';
        
        mail.setHtmlBody(body);
        mail.setSaveAsActivity(true);
        mail.setWhatId(bk.Id);
        
        emails.add(mail);
    }
    
    if (!emails.isEmpty()) {
        Messaging.sendEmail(emails);
    }
}


private static String nvl(String value, String fallback) {
    // Treat null or blank as "no value"
    return String.isBlank(value) ? fallback : value;
}

}