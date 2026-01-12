public with sharing class SaleDeedFlowController {

    @AuraEnabled(cacheable = true)
    public static Booking__c getBookingDetails(Id bookingId) {
        List < Booking__c > booking = [SELECT Id, Email1__c, CRM_Manager__c, Draft_Sale_Deed_Uploaded__c,
            Final_Sale_Deed_Document_Uploaded__c, Final_Sale_Deed_Send_to_Customer__c, Draft_Sale_Deed_Send__c,
            Sale_Deed_Status__c, Draft_Sale_Deed_Send_Date__c, Sale_Deed_Rejection_Comments__c, Sale_deed_Approval_Status__c
            FROM Booking__c WHERE Id =: bookingId LIMIT 1
        ];
        if (booking.isEmpty()) {
            throw new CustomException('Booking record not found.');
        }
        Booking__c bookingRecord = booking[0];
        System.debug('Booking Record: ' + bookingRecord);
        return bookingRecord;
    }

    @AuraEnabled
    public static void sendDraftSaleDeedEmail(Id bookingId) {
        // Query the Booking record to get the necessary fields
        Booking__c booking = [SELECT Id, Email1__c, CRM_Manager__c, Draft_Sale_Deed_Send__c,
            Sale_Deed_Status__c, Draft_Sale_Deed_Send_Date__c, Sale_deed_Approval_Status__c, First_Applicant_Name__c,
             project1__r.Name, plot__r.Name
            FROM Booking__c WHERE Id =: bookingId LIMIT 1
        ];

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
            WHERE LinkedEntityId =: bookingId
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
        List < ContentVersion > draftSaleDeeds = [SELECT Id, Title, VersionData
            FROM ContentVersion
            WHERE ContentDocumentId IN: contentDocumentIds
            AND Title LIKE '%Draft Sale Deed%'
            ORDER BY CreatedDate DESC LIMIT 1
        ];

        // Check if a valid Draft Sale Deed document was found
        if (draftSaleDeeds.isEmpty()) {
            throw new CustomException('No Draft Sale Deed document found.');
        }

        ContentVersion draftSaleDeed = draftSaleDeeds[0]; // Get the most recent one
        List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
        string companyName;
        string Address1;
        string Address2;
        string Address3;
        if(!companyDetails.isEmpty()){
            companyName = companyDetails[0].Label;
            Address1 = companyDetails[0].Registered_Address__c;
            Address2 = companyDetails[0].Address2__c;
            Address3 = companyDetails[0].Address3__c;    
        }
        // Create an email message to send the document
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {
            recipientEmail
        });
        mail.setSubject('Approval/Reject: Draft Sale Deed');
        string urllink = 'https://site-speed-6226.my.salesforce-sites.com/saledeed?id=' + bookingId;
        // HTML Body
        String emailbody = 'Dear ' + booking.First_Applicant_Name__c + ',<br/><br/>' +
            'Please find the attached draft sale deed  of your unit ' + booking.plot__r.Name + ' at ' + booking.project1__r.Name + ' for your review and approval.' +
            'Kindly go through the draft carefully and share your consent or comments, if any, using the link below:<br/>' +
            '<a href="' + urllink + '">Click here to provide your consent</a><br/><br/>' +
            'Once we receive your confirmation, we will proceed with the final execution of the document.<br/><br/>' +
            'Should you have any queries or require clarifications, please feel free to reach out to us.<br/><br/>' +
            'Should you have any further questions, feel free to reach out.<br/><br/>' +
            'Thank you for choosing '+companyName+'.<br/><br/>'+
            'Best regards,<br/>' +
            companyName+'<br/><br/>' +
            '<b>Midhu Siju</b> | Officer - Customer Relations | <a href="tel:+919207054444">9207054444</a><br/>' +
            '<b>Alitta Lijoy</b> | Customer Relation Executive | <a href="tel:+919048237066">90482 37066</a><br/><br/>' +
            '<b>'+companyName+'</b><br/>' +
            'Regd. Office: '+Address1+' '+Address2+' '+Address3+'<br/>' +
            'Tel: +91 484 2584000 / 2973944, +91 6235051144<br/>' +
            '<a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a><br/><br/>' +
            'Follow us on:<br/>' +
            '<a href="https://www.facebook.com/veegalanddevelopers" target="_blank">Facebook</a> | ' +
            '<a href="https://www.instagram.com/veegalanddevelopers" target="_blank">Instagram</a> | ' +
            '<a href="https://www.linkedin.com/company/veegalanddevelopers" target="_blank">LinkedIn</a> | ' +
            '<a href="https://www.youtube.com/c/VeegalandDevelopers" target="_blank">YouTube</a><br/>';

        mail.setHtmlBody(emailbody); 

        // Set the email from the CRM Manager
        mail.setReplyTo(crmManager.Email);
        mail.setSenderDisplayName('CRM Manager');

        // Attach the Draft Sale Deed document
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('Draft Sale Deed.pdf'); // Assumes the document is a PDF; change if necessary
        attachment.setBody(draftSaleDeed.VersionData);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {
            attachment
        });
        mail.setSaveAsActivity(true);
        mail.setWhatId(bookingId);
        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            mail
        });
        booking.Draft_Sale_Deed_Send__c = true;
        booking.Sale_Deed_Status__c = 'Customer Approval';
        booking.Draft_Sale_Deed_Send_Date__c = system.now();
        booking.Sale_deed_Approval_Status__c = 'Pending';
        update booking;
    }


    public class CustomException extends Exception {}

    @AuraEnabled
    public static void updateBookingRecord(Id bookingId, String documentId) {
        if (bookingId == null) {
            throw new AuraHandledException('Booking Id is required.');
        }

        try {
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
                Draft_Sale_Deed_URL__c = draftUrl,
                Draft_Sale_Deed_Uploaded__c = true
            );
            update bookingToUpdate;

            List < ContentDocumentLink > oldLinks = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId =: bookingId
                AND ContentDocument.LatestPublishedVersion.Title = 'Draft Sale Deed'
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
    public static void updatefinalSaleDeedStatus(Id bookingId) {
        if (bookingId == null) {
            throw new AuraHandledException('Booking Id is required.');
        }

        try {
            Booking__c bookingToUpdate = new Booking__c(
                Id = bookingId,
                Final_Sale_Deed_Document_Uploaded__c = true
            );
            update bookingToUpdate;
        } catch (Exception e) {
            throw new AuraHandledException('Error updating booking: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void sendFinalSaleDeedEmail(Id bookingId) {
        // Query the Booking record to get the necessary fields
        Booking__c booking = [SELECT Id, Email1__c, CRM_Manager__c, Sale_Deed_Status__c, Final_Sale_Deed_Send_to_Customer__c, Final_Sale_Deed_Send_Date__c,
        First_Applicant_Name__c, project1__r.Name, plot__r.Name
            FROM Booking__c WHERE Id =: bookingId LIMIT 1
        ];

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
            WHERE LinkedEntityId =: bookingId
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
        List < ContentVersion > draftSaleDeeds = [SELECT Id, Title, VersionData
            FROM ContentVersion
            WHERE ContentDocumentId IN: contentDocumentIds
            AND Title LIKE '%Final Sale Deed%'
            ORDER BY CreatedDate DESC LIMIT 1
        ];

        // Check if a valid Draft Sale Deed document was found
        if (draftSaleDeeds.isEmpty()) {
            throw new CustomException('No Draft Sale Deed document found.');
        }

        ContentVersion draftSaleDeed = draftSaleDeeds[0]; // Get the most recent one

        // Create an email message to send the document
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {
            recipientEmail
        });
        mail.setSubject('Approval/Reject: Draft Sale Deed');
		List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
                string companyName;
                string Address1;
                string Address2;
                string Address3;
                if(!companyDetails.isEmpty()){
                    companyName = companyDetails[0].Label;
                    Address1 = companyDetails[0].Registered_Address__c;
                    Address2 = companyDetails[0].Address2__c;
                    Address3 = companyDetails[0].Address3__c;    
                }
        // HTML Body
       String emailbody = 'Dear ' + booking.First_Applicant_Name__c + ',<br/><br/>' +
            'We are pleased to share the final draft of your Sale Deed for the unit ' + booking.plot__r.Name + ' at ' + booking.project1__r.Name + '.' +
            'Should you have any queries or require clarifications, please feel free to reach out to us.<br/><br/>' +
            'Thank you for choosing '+companyName+'.<br/><br/>' +
            'Best regards,<br/><br/>' +
            companyName+'<br/><br/>' +
            '<b>Midhu Siju</b> | Officer - Customer Relations | <a href="tel:+919207054444">9207054444</a><br/>' +
            '<b>Alitta Lijoy</b> | Customer Relation Executive | <a href="tel:+919048237066">90482 37066</a><br/><br/>' +
            '<b>'+companyName+'</b><br/>' +
            'Regd. Office: '+Address1+' '+Address2+' '+Address3+'<br/>' +
            'Tel: +91 484 2584000 / 2973944, +91 6235051144<br/>' +
            '<a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a><br/><br/>' +
            'Follow us on:<br/>' +
            '<a href="https://www.facebook.com/veegalanddevelopers" target="_blank">Facebook</a> | ' +
            '<a href="https://www.instagram.com/veegalanddevelopers" target="_blank">Instagram</a> | ' +
            '<a href="https://www.linkedin.com/company/veegalanddevelopers" target="_blank">LinkedIn</a> | ' +
            '<a href="https://www.youtube.com/c/VeegalandDevelopers" target="_blank">YouTube</a><br/>';

        mail.setHtmlBody(emailbody); // Set HTML body

        // Set the email from the CRM Manager
        mail.setReplyTo(crmManager.Email);
        mail.setSenderDisplayName('CRM Manager');

        // Attach the Draft Sale Deed document
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('Final Sale Deed.pdf'); // Assumes the document is a PDF; change if necessary
        attachment.setBody(draftSaleDeed.VersionData);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {
            attachment
        });
        mail.setSaveAsActivity(true);
        mail.setWhatId(bookingId);
        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            mail
        });
        booking.Final_Sale_Deed_Send_to_Customer__c = true;
        booking.Final_Sale_Deed_Send_Date__c = system.now();
        update booking;
    }

}