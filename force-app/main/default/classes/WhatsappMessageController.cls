public class WhatsappMessageController {
    /*
    @AuraEnabled
    public static String sendAdvanceAmountReceiptAndWhatsApp(Id recId) {
        String returnMessage;
        try {
            // Step 1: Retrieve Booking
            Booking__c booking = [SELECT Id, Project__c, Email1__c, Mobile_Primary__c, First_Applicant_Name__c, Owner.Email 
                                  FROM Booking__c WHERE Id = :recId LIMIT 1];
            
            if (booking == null || String.isBlank(booking.Mobile_Primary__c)) {
                return 'Booking record or mobile number not found.';
            }
            
            // Step 2: Generate PDF
            PageReference vfPage = Page.AdvanceReceipt;
            vfPage.getParameters().put('id', recId);
            Blob pdfBlob = !Test.isRunningTest() ? vfPage.getContentAsPDF() : Blob.valueOf('test');
            
            // Step 3: Save PDF to ContentVersion
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Advance_Receipt_' + Date.today();
            cv.PathOnClient = ' ';
            cv.VersionData = pdfBlob;
            insert cv;
            
            // Step 4: Create public ContentDistribution link
            cv = [SELECT Id, Title FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
            ContentDistribution cd = new ContentDistribution();
            cd.Name = cv.Title;
            cd.ContentVersionId = cv.Id;
            cd.PreferencesAllowViewInBrowser = true;
            cd.PreferencesLinkLatestVersion = true;
            cd.PreferencesNotifyOnVisit = false;
            insert cd;
            
            String publicUrl = cd.DistributionPublicUrl;
            
            // Step 5: Prepare dynamic variables for template
            Map<String, String> templateVars = new Map<String, String>();
            templateVars.put('var1', booking.First_Applicant_Name__c);  // Customize template variable here
            
            List<String> varValues = new List<String>();
            varValues.add(booking.First_Applicant_Name__c);
            // Step 6: Call WhatsApp utility to send message
            String phone = booking.Mobile_Primary__c.replaceAll('\\D', '');
            if (!phone.startsWith('91')) {
                phone = '917025552444'; // Add country code if necessary
            }
            
            // Call the WhatsAppMessageSender utility method
            WhatsAppMessageSender.sendWhatsAppMessage(
                phone,                        // Phone number
                'send_draft_agreement_for_review',                    // Template name
                varValues,                 // Template variables
                publicUrl                     // File URL
            );
            
        } catch (Exception e) {
            returnMessage = 'Error: ' + e.getMessage();
            system.debug('returnMessage >>>>>>>>>>>>>>>'+returnMessage);
        }
        
        return returnMessage;
    }*/
    
}