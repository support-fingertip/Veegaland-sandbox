public class QuoteController {
    
    
    
    @AuraEnabled(cacheable=true)
    public static Quote__c getQuoteData(Id recordId) {
        // Fetch the booking record
        Quote__c Quote = [SELECT Id, Name, Primary_Applicant_Name__c,Encrypted_Key__c,Primary_Applicant_Saluaion__c,Primary_Applicant_Email__c,Primary_Applicant_Mobile_No__c,Lead_Email__c,Lead_Name__c,OwnerId,Owner.Name,Owner.Phone,Project__c,Unit__c,Unit__r.Name,Owner.Email,Advance_Amount_Received__c
                          FROM Quote__c WHERE Id = :recordId LIMIT 1];
    
        Quote.Encrypted_Key__c = encryptRecordId(Quote.Id);
        return Quote;
       
        
    }

public static void handleAfterInsert(List<Quote__c> newQuotes) {
    
    
    
    
      /*      Set<Id> unitIdsToBlock = new Set<Id>();

        for (Quote__c quote : newQuotes) {
            if (quote.Unit__c != null) {
                unitIdsToBlock.add(quote.Unit__c);
            }
        }

        if (!unitIdsToBlock.isEmpty()) {
            List<Plot__c> unitsToUpdate = [
                SELECT Id, Status__c 
                FROM Plot__c 
                WHERE Id IN :unitIdsToBlock
            ];

            for (Plot__c unit : unitsToUpdate) {
                unit.Status__c = 'Blocked';
            }

            update unitsToUpdate;
        }*/
    }

    public static String encryptRecordId(String recordId) {
        String keyString = 'fingerti(#p#)rivateLimited#edKey'; // 32 characters for AES-256
        Blob key = Blob.valueOf(keyString);
        Blob data = Blob.valueOf(recordId);
        
        Blob encryptedData = Crypto.encryptWithManagedIV('AES256', key, data);
        return EncodingUtil.base64Encode(encryptedData);
    }
    
    
    
    
      @AuraEnabled
    public static String sendAdvanceAmountReceipt(Id recId) {
        String returnMessage;
        try {
            
            // Retrieve the quote record
            Quote__c quote = [SELECT Id, Leads__r.Name, Lead_Email__c,Primary_Applicant_Name__c, Primary_Applicant_Email__c,Owner.Email
                                  FROM Quote__c WHERE Id = :recId LIMIT 1];
            List<String> lstCCEmail = new List<String>();
            system.debug('quote:'+quote);
            List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,Label,Address2__c,Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
                string companyName;
                
                if(!companyDetails.isEmpty()){
                    companyName = companyDetails[0].Label;
                       
                }
            // Retrieve Org Wide Email Address
            List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :quote.Owner.Email];
            
            if (quote != null && !String.isBlank(quote.Primary_Applicant_Name__c) || quote != null && !String.isBlank(quote.Lead_Name__c)) {
                system.debug('here');
                
                // Generate the PDF 
                PageReference vfPage;
                vfPage = Page.AdvanceReceiptQuote;
                vfPage.getParameters().put('id', recId);
                
                Blob pdfBlob = !Test.isRunningTest() ? vfPage.getContentAsPDF() : Blob.valueOf('testblob');
                
                // Prepare email details
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>();
                
                if (quote.Primary_Applicant_Name__c != null) {
                    sendTo.add(quote.Primary_Applicant_Email__c);
                }
                system.debug('here');
                // Set Org-Wide Email Address
                if (owea.size() > 0) {
                    email.setOrgWideEmailAddressId(owea[0].Id);
                }
                
                // Include CC addresses
                /* lstCCEmail.add(quote.Owner.Email);
if (quote.CRM_Manager__c != null) {
lstCCEmail.add(quote.CRM_Manager__r.Email);
}
lstCCEmail.add('Crmlead@mahendrahomes.com');
if (lstCCEmail.size() > 0) {
email.setCcAddresses(lstCCEmail);
}
*/
                email.setToAddresses(sendTo);
                email.setSubject('Quote Advance Receipt');
                email.setHtmlBody('Dear ' + quote.Primary_Applicant_Name__c + ',<br/><br/>Please find the attached Quote Advance receipt document. If you have any questions, feel free to contact us..<br/><br/>Thank you.<br/><br/>'+companyName);
                System.debug(sendTo);
                // Attach the PDF to the email
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('Quote Advance Receipt.pdf');
                attachment.setBody(pdfBlob);
                email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
                email.setSaveAsActivity(true);
                email.setWhatId(quote.Id);
                // Send the email
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                
                returnMessage = 'Email sent successfully';
            } else {
                returnMessage = 'Email address not specified in the quote record.';
            }
        } catch (Exception e) {
            returnMessage = 'Error sending email: ' + e.getMessage();
        }
        return returnMessage;
    }
    
    @AuraEnabled
    public static void sendRequestDocumentMail(Id recordId, String emailContent, List<String> contentIds) {
       
        
         SendEmailServiceClass.sendRequestDocumentMail(recordId,emailContent,contentIds);
    }
    @AuraEnabled
    public static void sendCostSheettoCustomer(Id recordId, String emailContent, List<String> contentIds) {
        SendEmailServiceClass.sendCostSheettoCustomer(recordId,emailContent,contentIds);
    }
     @AuraEnabled
    public static void sendBookingFormtoCustomer(Id recordId, String emailContent, List<String> contentIds) {
        SendEmailServiceClass.sendBookingFormtoCustomer(recordId,emailContent,contentIds);
    }
    @AuraEnabled
    public static void sendEmailFinalBookingForm(Id recordId) {
        SendEmailServiceClass.sendEmailFinalBookingForm(recordId);
    }
    @AuraEnabled
    public static Quote__c getKYCData(Id recordId) {
        return [SELECT Id, 
                All_Applicants_Photo_Verified__c, 
                       All_Applicants_Passport_Verified__c, 
                       All_Applicants_PAN_Verified__c, 
                       All_Applicants_Aadhar_Verified__c, 
                       KYC_Documents_Verification_Status__c 
                FROM Quote__c WHERE Id = :recordId LIMIT 1];
    }

    @AuraEnabled
    public static void updateKYCData(Id recordId, Quote__c kycData) {
        Quote__c recordToUpdate = [SELECT Id FROM Quote__c WHERE Id = :recordId LIMIT 1];

        recordToUpdate.All_Applicants_Photo_Verified__c = kycData.All_Applicants_Photo_Verified__c;
        recordToUpdate.All_Applicants_Passport_Verified__c = kycData.All_Applicants_Passport_Verified__c;
        recordToUpdate.All_Applicants_PAN_Verified__c = kycData.All_Applicants_PAN_Verified__c;
        recordToUpdate.All_Applicants_Aadhar_Verified__c = kycData.All_Applicants_Aadhar_Verified__c;
        recordToUpdate.KYC_Documents_Verification_Status__c = kycData.KYC_Documents_Verification_Status__c;

        update recordToUpdate;
    }
    public static void quoteUnitStatusChange(Set<Id> quoteIds) {
        // Map to store Units related to the Quote records
        Map<Id, Plot__c> unitMap = new Map<Id, Plot__c>();
        Map<Id, set<String>> unitErrorMap = new Map<Id, set<String>>();
        // List to store errors
        List<String> errorMessages = new List<String>();
        
        // Fetch Quotes and related Units
        for (Quote__c quote : [SELECT Id, Unit__c, Unit__r.Status__c,OwnerId FROM Quote__c 
                               WHERE Id IN :quoteIds AND Unit__c != NULL]) {
                                   
                                   // Check if the Unit status is not "Available"
                                   if (quote.Unit__r.Status__c != 'Available') {
                                       if (!unitErrorMap.containsKey(quote.Id)) {
                                           unitErrorMap.put(quote.Id, new Set<String>());
                                       }
                                       unitErrorMap.get(quote.Id).add(quote.OwnerId);
                                   } else {
                                       unitMap.put(quote.Unit__c, new Plot__c(Id = quote.Unit__c, Status__c = 'Blocked'));
                                   }
                               }
        
        if (!unitErrorMap.isEmpty()) {
            CustomNotificationServiceClass.sendCustomNotification(
                unitErrorMap, 
                'Selected unit is not availabe for booking !', 
                'The unit selected for the quote is not available for booking. Please check the unit status.',
                'Custom_Notification' // DeveloperName from Custom Notification Type
            );
            errorMessages.add('Selected unit is not available for booking. Please check the unit status.');
        }
        
        // Update the available units to "Blocked"
        if (!unitMap.isEmpty()) {
            update unitMap.values();
        }
    }
    
    public static void submitQuoteApproval(list<Quote__c> submitQuoteList){
        for(Quote__c q :submitQuoteList){

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setProcessDefinitionNameOrId('Quote_Approval_process');
            req.setComments('Quote Submitted for Approval');
            req.setObjectId(q.Id);
            req.setNextApproverIds(new Id[] {q.Quote_Approver__c});
            if(!test.isRunningtest()){
            Approval.ProcessResult result = Approval.process(req);
            }
    }
    }
    
    
public static void sendApprovedRejectedNotification(List<Quote__c> apprRejQuote,string status){
    CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName =: 'Custom_Notification' LIMIT 1];
    String body, title, senderId, notificationId;
    notificationId = type.Id;
    senderId = UserInfo.getUserId();
    for (Quote__c quote : apprRejQuote) {
        body = 'Quote-' + quote.Name + ' has been '+status;
        title = quote.Name;
        // Send notification to owner
        Set<String> userIds = new Set<String>{quote.OwnerId};
        sendNotification(body, title, senderId, notificationId, quote.Id, userIds);
    }   
}    

public static void sendNotification(String body, String title, String senderId, String notificationId, Id recId, Set<String> userIds){
    Messaging.CustomNotification notification = new Messaging.CustomNotification();
    notification.setBody(body);
    notification.setTitle(title);
    notification.setSenderId(senderId);
    notification.setNotificationTypeId(notificationId);  // Notification type is passed as Id
    notification.setTargetId(recId); // target object id
    notification.send(userIds);    
}

}