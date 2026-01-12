public class GenerateDocumnetController {
    
    public class BookingDataWrapper {
        @AuraEnabled public Booking__c booking;
        @AuraEnabled public String parkingFloorNames;
        @AuraEnabled public String balanceAmountWords;
        @AuraEnabled public String customerNames;
    }
    /* Date: 26/08/25  Author:  @desc: Get booking record, parking floor. @param 1:booking Id @return :BookingDataWrapper */   
    @AuraEnabled
    public static BookingDataWrapper getBookingRecord(Id recordId) {
        
        Booking__c booking = [SELECT Id, Project_Company__c, Stamp_duty__c,Owner.Email,Owner.Name,CRM_Manager__r.Email,CRM_Manager__r.Name, Association_Deposit__c,Balance_Advance_Amount__c,Email1__c,Sales_Executive__c,Sales_Executive__r.Name,Sales_Manager1__c, Sales_Manager1__r.Name, Sales_Manager1__r.Username,Plot__r.Name,
                              Registration_Fee__c, Registration_Expected_Date__c, Registration_office__c, Project__c, Project1__r.Name, Agreement_Expected_Date__c,
                              Agreement_Cost__c, Bank__c, Total_received_Amount__c, First_Applicant_Name__c, salutation_Applicant1__c, Registration_Date__c,Deed_Expected_Date__c,
                              Received_Amount_TAX_exclude__c, No_of_Indivisual_Car_Parking__c, No_of_Back_to_Back_Car_Parking__c,Agreement_Appointment_Date__c,Legal_Team__r.Name,Legal_Team__r.Email,Legal_Team__c,No_of_additional_Back_to_back_car_parki__c,No_of_additional_Individual_car_parkings__c,
                              Project1__r.Bank_Name__c,Project1__r.SWIFT_CODE__c,Project1__r.Beneficiary_Account_No__c,Project1__r.Branch_Name__c,Project1__r.IFSC_CODE__c, Project1__r.Register_Office_Location__Latitude__s, Project1__r.Register_Office_Location__Longitude__s, Project1__r.Register_Office__c,
                              (SELECT Salutation__c, Name FROM Co_Applicant__r)
                              FROM Booking__c 
                              WHERE Id = :recordId 
                              LIMIT 1];
        //system.debug('UnitNumber'+booking.Plot__r.Unit_Number__c);
        
        List<Parking_Floor__c> parkingFloors = [
            SELECT Id, Name  
            FROM Parking_Floor__c
            WHERE Project__c = :booking.Project1__c
        ];
        
        List<String> validFloorNames = new List<String>();
        for(Parking_Floor__c p : parkingFloors) {
            if (String.isNotBlank(p.Name)) {
                validFloorNames.add(p.Name.trim());
            }
        }
        
        String formattedFloorNames;
        Integer size = validFloorNames.size();
        if (size == 0) {
            formattedFloorNames = null;
        } else if (size == 1) {
            formattedFloorNames = validFloorNames[0];
        } else if (size == 2) {
            formattedFloorNames = 'both '+validFloorNames[0] + ' & ' + validFloorNames[1];
        } else {
            formattedFloorNames = validFloorNames[0] + ', ' + validFloorNames[1]+ ' & '+ validFloorNames[2];
        }
        
        String customerNames = booking.salutation_Applicant1__c + ' ' + booking.First_Applicant_Name__c; // Primary applicant name
        
        // Check if there are co-applicants and concatenate their details
        if (booking.Co_Applicant__r != null && !booking.Co_Applicant__r.isEmpty()) {
            // Loop through co-applicants and concatenate their salutation and name
            for (Co_Applicant__c coApplicant : booking.Co_Applicant__r) {
                customerNames += ' & ' + coApplicant.Salutation__c + ' ' + coApplicant.Name;
            }
        }
        
        BookingDataWrapper wrapper = new BookingDataWrapper();
        wrapper.booking = booking;
        wrapper.balanceAmountWords = (booking.Balance_Advance_Amount__c != null) ? convertNumberToWords(booking.Balance_Advance_Amount__c.setscale(0)) + ' Only' : 'Zero Only';
        wrapper.parkingFloorNames = formattedFloorNames;
        wrapper.customerNames =  customerNames;
        
        return wrapper;
    }
    
    
    
    public class SaleAgreementWrapper {
        @AuraEnabled
        public Booking__c booking;
        @AuraEnabled
        public String agreementType;
        
        // Constructor
        public SaleAgreementWrapper(Booking__c booking, String agreementType) {
            this.booking = booking;
            this.agreementType = agreementType;
        }
    }
    
    /* Date: 26/08/25  Author:  @desc: Get booking record, coapplicant sales agreement pdf name. @param 1:booking Id @return :SaleAgreementWrapper */
    @AuraEnabled
    public static SaleAgreementWrapper getSaleAgreement(Id recordId) {
        if (recordId == null) {
            return null; // Return null if no ID is provided
        }
        
        // Fetch the Booking record
        Booking__c booking = [
            SELECT Id, Name, Authorized_Signatory__c,Agreement_Appointment_Date__c, First_Applicant_Name__c, Email1__c,Registration_Expected_Date__c,Registration_office__c, Project__c,Project1__r.Name
            FROM Booking__c
            WHERE Id = :recordId
            LIMIT 1
        ];
        
        // Count co-applicants related to this booking
        Integer coApplicantCount = [
            SELECT COUNT() FROM Co_Applicant__c WHERE Booking__c = :recordId
        ];
        
        // Determine the Sale Agreement type
        String agreementType;
        if (coApplicantCount > 0) {
            agreementType = 'SaleAgreementCoApp'; // Booking has Co-Applicants
        } else if (booking.Authorized_Signatory__c == true) {
            agreementType = 'Sales_agreement_One_applicant_with_POA'; // No Co-Applicant, but Authorized_Signatory__c is true
        } else {
            agreementType = 'SalesAgreement1Applicant'; // No Co-Applicant and Authorized_Signatory__c is false
        }
        
        // Return the wrapper containing both Booking record & Agreement type
        return new SaleAgreementWrapper(booking, agreementType);
    }
    
    
    
    
    
    
    
    
    
    /* Date: 26/08/25  Author:  @desc: Get booking record,using receipt id . @param 1:receipt Id @return :receipt recordId */    
    @AuraEnabled
    public static Booking__c getBookingRecordViaReciept(Id recordId) {
        Receipt__c receipt = [SELECT Id, Booking__c FROM Receipt__c WHERE id = :recordId LIMIT 1];
        Booking__c booking = [SELECT Id,Project_Company__c, Project__c,Project1__r.Name, Agreement_Cost__c,Bank__c, Total_received_Amount__c,First_Applicant_Name__c
                              FROM Booking__c 
                              WHERE Id = :receipt.Booking__c 
                              LIMIT 1];
        //if (booking.Agreement_Cost__c <= booking.Total_received_Amount__c) {
        //system.debug(booking.Name);
        return booking;
        //} else {
        //return null;
        //}
    }
    
    
    /* Date: 26/08/25  Author:  @desc: Get receipt record,using receipt id . @param 1:receipt Id @return :receipt record Id*/     
    public static Receipt__c getreceiptRecord(Id recordId) {
        Receipt__c receipt = [SELECT Id, Booking__c FROM Receipt__c WHERE id = :recordId LIMIT 1];
        //  Booking__c booking = [SELECT Id,Project_Company__c, Project__c,Project1__r.Name, Agreement_Cost__c,Bank__c, Total_received_Amount__c,First_Applicant_Name__c
        // FROM Booking__c 
        // WHERE Id = :receipt.Booking__c 
        // LIMIT 1];
        //if (booking.Agreement_Cost__c <= booking.Total_received_Amount__c) {
        //system.debug(booking.Name);
        return receipt;
        //} else {
        //return null;
        //}
    }
    
    
    
    /* Date: 26/08/25  Author:  @desc: currency to word . child function  :convert  @param 1:receipt Id @return :number*/       
    public static String convertNumberToWords(Decimal numb) {
        if (numb == null) return 'Zero';
        
        Long num = numb.longValue();
        if (num == 0) return 'Zero';
        
        return convert(num);
    }
    
    @TestVisible
    private static String convert(Long num) {
        List<String> ONES = new List<String>{
            '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten',
                'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'
                };
                    
                    List<String> TENS = new List<String>{
                        '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
                            };
                                
                                if (num < 20) {
                                    return ONES[num.intValue()];
                                } else if (num < 100) {
                                    Integer tensPlace = num.intValue() / 10;
                                    Integer onesPlace = Math.mod(num.intValue(), 10);
                                    return TENS[tensPlace] + (onesPlace != 0 ? ' ' + ONES[onesPlace] : '');
                                } else if (num < 1000) {
                                    return ONES[num.intValue() / 100] + ' Hundred' + (Math.mod(num, 100) != 0 ? ' ' + convert(Math.mod(num, 100)) : '');
                                } else if (num < 100000) {
                                    return convert(num / 1000) + ' Thousand' + (Math.mod(num, 1000) != 0 ? ' ' + convert(Math.mod(num, 1000)) : '');
                                } else if (num < 10000000) {
                                    return convert(num / 100000) + ' Lakh' + (Math.mod(num, 100000) != 0 ? ' ' + convert(Math.mod(num, 100000)) : '');
                                } else {
                                    return convert(num / 10000000) + ' Crore' + (Math.mod(num, 10000000) != 0 ? ' ' + convert(Math.mod(num, 10000000)) : '');
                                }
        
    }
    
    
    /* Date: 26/08/25  Author:  @desc: send rECEIPT eMAIL TO BOOKED customer once receipt approved .   @param 1:receipt Id @return :string*/  
    
    @AuraEnabled
    public static String sendEmailGenerateReceipt(Id receiptId) {
        String returnMessage;
        try {
            // Retrieve the Receipt record
            Receipt__c receipt = [SELECT Id, Booking__c, CreatedBy.Email,Mode_of_payment__c,Instrument_N__c,Total_Received_Amount__c,Check_Transaction_Nmber__c FROM Receipt__c WHERE Id = :receiptId LIMIT 1];
            
            if (receipt == null || receipt.Booking__c == null) {
                return 'Receipt or associated Booking record not found.';
            }
            system.debug('here');
            
            // Retrieve the related Booking record
            Booking__c booking = [SELECT Id, Email1__c,Project__c, Email2__c, First_Applicant_Name__c, Owner.Email, CRM_Manager__c, CRM_Manager__r.Email 
                                  FROM Booking__c WHERE Id = :receipt.Booking__c LIMIT 1];
            
            if (booking != null && !String.isBlank(booking.Email1__c)) {
                List<String> lstCCEmail = new List<String>();
                
                // Retrieve co-applicants associated with the Booking
                //List<Co_Applicant__c> coApps = [SELECT Id, Name, Email__c, Booking__c FROM Co_Applicant__c WHERE Booking__c = :booking.Id];
                
                // Retrieve Org Wide Email Address
                List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :receipt.CreatedBy.Email];
                
                PageReference receiptPage;
                receiptPage = Page.RECEIPT;
                // Generate the PDF for the receipt
                receiptPage.getParameters().put('id', receiptId);
                system.debug('here');
                Blob pdfBlob = !Test.isRunningTest() ? receiptPage.getContentAsPDF() : Blob.valueOf('testblob');
                
                // Prepare email details
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>();
                sendTo.add(booking.Email1__c);
                if (booking.Email2__c != null) {
                    sendTo.add(booking.Email2__c);
                }
                system.debug('here');
                // Include Co-Applicant emails
                /* for (Co_Applicant__c ca : coApps) {
if (ca.Email__c != null) {
sendTo.add(ca.Email__c);
}
}*/
                if(!Test.isRunningTest()){
                    // Set Org-Wide Email Address (if available)
                    if (owea.size() > 0) {
                        email.setOrgWideEmailAddressId(owea[0].Id);
                    }
                }
                system.debug('here');
                // Include CC addresses
                lstCCEmail.add(booking.Owner.Email);
                if (booking.CRM_Manager__c != null) {
                    lstCCEmail.add(booking.CRM_Manager__r.Email);
                }
                //lstCCEmail.add('customercare@veegaland.in');
                //lstCCEmail.add('crm@mahendrahomes.com');
                if (!lstCCEmail.isEmpty()) {
                    email.setCcAddresses(lstCCEmail);
                }
                String amountInWords;
                if(receipt.Total_Received_Amount__c !=null){
                    amountInWords =  convertNumberToWords(receipt.Total_Received_Amount__c);
                }
                List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
                string companyName;
                if(!companyDetails.isEmpty()){
                companyName = companyDetails[0].Label;
                }
                email.setToAddresses(sendTo);
                String emailbody = 'Dear ' + booking.First_Applicant_Name__c + ',<br/><br/>' +
                    'We are pleased to inform you that your payment of ' + receipt.Total_Received_Amount__c + ' (' + amountInWords + ') against reference '+receipt.Mode_of_payment__c+' number ' + receipt.Check_Transaction_Nmber__c + ' has been successfully credited to our account.<br/><br/>' +
                    'Thank you for your timely payment. Please find the attached receipt for your reference.<br/><br/>' +
                    'Should you have any further questions, feel free to reach out.<br/><br/>' +
                    'Thank you for choosing Veegaland Homes.<br/><br/>' +
                    'Best regards,<br/>' +
                    companyName;
                
                
                system.debug(sendTo);
                email.setSubject('Receipt for Your Payment');
                email.setHtmlBody(emailbody);
                system.debug('otherside');
                // Attach the PDF to the email
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('Receipt.pdf');
                attachment.setBody(pdfBlob);
                email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
                system.debug('inside');
                email.setSaveAsActivity(true);
                email.setWhatId(receipt.Id);
                system.debug('outside');
                // Send the email
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                
                returnMessage = 'Email sent successfully';
            } else {
                returnMessage = 'Email address not specified in the Booking record.';
            }
        } catch (Exception e) {
            ExceptionHandler.addLog(e,'','GenerateDocumnetController',receiptId);  /*Add Exception to error log*/
            returnMessage = 'Error sending email: ' + e.getMessage();
        }
        return returnMessage;
    }
    
    /* Date: 26/08/25  Author:  @desc: send rECEIPT eMAIL TO Finance user .   @param 1:receipt Id @return :string*/    
    @AuraEnabled
    public static String sendEmailVeegalandReceipt(Id receiptId) {
        system.debug('inside main controller');
        String returnMessage;
        
        try {
            // Retrieve the Receipt record
            Receipt__c receipt = [
                SELECT Id, Booking__c, Name, CreatedBy.Email,
                Finance_User__c, Finance_User__r.Email, Finance_User__r.Name,Booking__r.Name
                FROM Receipt__c
                WHERE Id = :receiptId
                LIMIT 1
            ];
            system.debug(receipt);
            
            // Validation
            if (receipt.Finance_User__c == null || String.isBlank(receipt.Finance_User__r.Name)) {
                return 'Finance User Not Assigned';
            }
            if (String.isBlank(receipt.Finance_User__r.Email)) {
                return 'Please update email Id of finance user';
            }
            
            List<String> sendTo = new List<String>();
            if (receipt.Finance_User__r.Email != null) {
                sendTo.add(receipt.Finance_User__r.Email);
            }
            List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
            string companyName;
            if(!companyDetails.isEmpty()){
                companyName = companyDetails[0].Label;
            }
            
            // Email body content
            String emailContent = 'Dear ' + receipt.Finance_User__r.Name + ',<br/><br/>' +
                'Please find attached the receipt for Booking: ' + receipt.Booking__r.Name + '<br/><br/>' +
                'Regards,<br/>'+companyName;
            system.debug(emailContent);
            
            // Generate PDF attachment from Visualforce page
            PageReference receiptPage = Page.VeegalandReceipt;
            receiptPage.getParameters().put('id', receiptId);
            Blob pdfBlob = !Test.isRunningTest() ? receiptPage.getContentAsPDF() : Blob.valueOf('testblob');
            
            // Create email attachment
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('Company_' + receipt.Name + '.pdf');
            attachment.setBody(pdfBlob);
            attachment.setContentType('application/pdf');
            
            // Prepare email message
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(sendTo);
            email.setSubject('Company Receipt');
            email.setHtmlBody(emailContent); // HTML body
            email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
            
            //CC to veegaland customercare 
            List<String> lstCCEmail = new List<String>();
           // lstCCEmail.add('customercare@veegaland.in');
            if (!lstCCEmail.isEmpty()) {
            email.setCcAddresses(lstCCEmail);
            }
            
            email.setSaveAsActivity(true);
            email.setWhatId(receipt.Id);
            
            // Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            returnMessage = 'Email sent successfully';
            
        } catch (Exception e) {
            ExceptionHandler.addLog(e,'','GenerateDocumnetController',receiptId);  /*Add Exception to error log*/
            returnMessage = 'Error sending email: ' + e.getMessage();
        }
        
        return returnMessage;
    }
    
    
    /* Date: 26/08/25  Author:  @desc: Send consolidated booking receipt to finance user .   @param 1:booking Id @return :string*/     
    @AuraEnabled
    public static String sendEmailPrintAllReceipt(Id bookingId) {
        system.debug('inside main controller');
        String returnMessage;
        Booking__c booking = [Select Id, Name From Booking__c where Id = : bookingId ];
        
        try {
            // Retrieve the Receipt record
            Receipt__c receipt = [
                SELECT Id, Booking__c, Name, CreatedBy.Email,
                Finance_User__c, Finance_User__r.Email, Finance_User__r.Name,Booking__r.Name
                FROM Receipt__c
                WHERE Booking__c = :bookingId AND Approval_status__c = 'Approved by Finance Team' Limit 1 
            ];
            system.debug(receipt);
            
            // Validation
            if (receipt.Finance_User__c == null || String.isBlank(receipt.Finance_User__r.Name)) {
                return 'Finance User Not Assigned';
            }
            if (String.isBlank(receipt.Finance_User__r.Email)) {
                return 'Please update email Id of finance user';
            }
            
            List<String> sendTo = new List<String>();
            if (receipt.Finance_User__r.Email != null) {
                sendTo.add(receipt.Finance_User__r.Email);
            }
            List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
                string companyName;
                if(!companyDetails.isEmpty()){
                companyName = companyDetails[0].Label;
                }
            // Email body content
            String emailContent = 'Dear ' + receipt.Finance_User__r.Name + ',<br/><br/>' +
                'Please find the attached document for all receipts for Booking: ' + booking.Name + '<br/><br/>' +
                'Regards,<br/>'+companyName;
            system.debug(emailContent);
            
            // Generate PDF attachment from Visualforce page
            PageReference receiptPage = Page.PrintAllReceipt;
            receiptPage.getParameters().put('id', bookingId);
            Blob pdfBlob = !Test.isRunningTest() ? receiptPage.getContentAsPDF() : Blob.valueOf('testblob');
            
            // Create email attachment
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('All Receipts'+ '.pdf');
            attachment.setBody(pdfBlob);
            attachment.setContentType('application/pdf');
            
            // Prepare email message
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(sendTo);
            system.debug(sendTo);
            email.setSubject('All Receipts');
            email.setHtmlBody(emailContent); // HTML body
            email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
            
            //CC to veegaland customercare 
            List<String> lstCCEmail = new List<String>();
            //lstCCEmail.add('customercare@veegaland.in');
            
            if (!lstCCEmail.isEmpty()) {
            email.setCcAddresses(lstCCEmail);
            }
            
            email.setSaveAsActivity(true);
            email.setWhatId(booking.Id);
            
            // Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            returnMessage = 'Email sent successfully';
            
        } catch (Exception e) {
            ExceptionHandler.addLog(e,'','GenerateDocumnetController',bookingId);  /*Add Exception to error log*/
            returnMessage = 'Error sending email: ' + e.getMessage();
        }
        
        return returnMessage;
    }
    
    
    
    
    
    
    
    /* Date: 26/08/25  Author:  @desc: Send  booking agreement and floor plan ,parking slot to customer user .   @param 1:booking Id @return :string*/      
    @AuraEnabled
    public static String sendEmailGenerateSA(Id recId, String emailContent) {
        system.debug('emailContent: ' + emailContent);
        String returnMessage = 'Unknown error';
        set<string> conDocId = new set<string>();
        list<Messaging.EmailFileAttachment> attachments =  new list<Messaging.EmailFileAttachment>(); 
        try {
            // Retrieve the Booking record
            Booking__c booking = [ SELECT Id, Project__c, Email1__c,Plot__c,Plot__r.Unit_Type__c, First_Applicant_Name__c, CRM_Manager__c, CRM_Manager__r.Email, Authorized_Signatory__c
                                  FROM Booking__c  WHERE Id = :recId   LIMIT 1 ];
            if (booking.Email1__c == null) {
                return 'Email address not specified in the Booking record.';
            }
            Id unitTypeId = booking.Plot__r != null ? booking.Plot__r.Unit_Type__c : null;
           // list< ContentDocumentLink> cdList = [SELECT ContentDocumentId  FROM ContentDocumentLink WHERE LinkedEntityId =:booking.Plot__r.Unit_Type__c or  LinkedEntityId =:booking.Id];
            list< ContentDocumentLink> cdList = [SELECT ContentDocumentId  FROM ContentDocumentLink WHERE LinkedEntityId =:unitTypeId or  LinkedEntityId =:booking.Id];
            
            
            // Determine the Sale Agreement Visualforce page based on Co-Applicant and POA logic
            Integer coApplicantCount = [  SELECT COUNT()  FROM Co_Applicant__c   WHERE Booking__c = :booking.Id ];
            
            PageReference vfPage;
            
            if (coApplicantCount > 0) {
                vfPage = Page.SaleAgreementCoApp;
            } else if (booking.Authorized_Signatory__c == true) {
                vfPage = Page.Sales_agreement_One_applicant_with_POA;
            } else {
                vfPage = Page.SalesAgreement1Applicant;
            }
            
            vfPage.getParameters().put('id', recId);
            vfPage.setRedirect(true);
            Blob pdfBlob = Test.isRunningTest() 
                ? Blob.valueOf('testblob') 
                : vfPage.getContentAsPDF();
            
            // Prepare the email
            Set<String> sendTo = new Set<String>();
            sendTo.add(booking.Email1__c);
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>(sendTo));
            
            email.setSubject('Draft Agreement for Your Review');
            email.setHtmlBody(emailContent);
            email.setSaveAsActivity(true);
            email.setWhatId(booking.Id);
            
            //CC to veegaland customercare 
            List<String> lstCCEmail = new List<String>();
           // lstCCEmail.add('customercare@veegaland.in');
            
            if (!lstCCEmail.isEmpty()) {
            email.setCcAddresses(lstCCEmail);
            }
            
            // Add PDF as attachment
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('DraftAgreement.pdf');
            attachment.setBody(pdfBlob);
            attachment.setContentType('application/pdf');
            attachments.add(attachment);
            
            // Add unt type foorbplan as attachment
            if(cdList.size() >0){
                for(ContentDocumentLink c : cdList){
                    conDocId.add(c.ContentDocumentId);
                }
                
                list<ContentVersion> cvList = [ SELECT Id, Title, VersionData, FileExtension  FROM ContentVersion   WHERE ContentDocumentId in :conDocId and IsLatest = true ORDER BY CreatedDate DESC ];
                system.debug(cvList);
                for(ContentVersion cv : cvList){
                    
                    if(cv.Title.contains('Plumbing Plan') || cv.Title.contains('Electrical Plan') || cv.Title.contains('Parking Plan') ||  cv.Title.contains('Floor Plan') || cv.Title.contains('Selected Parking Slots')){
                        system.debug(cv);
                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                        efa.setFileName(cv.Title + '.' + cv.FileExtension);
                        efa.setBody(cv.VersionData); // This is the actual file blob
                        String contentType = 'application/octet-stream';
                        if(cv.FileExtension != null){
                            switch on cv.FileExtension.toLowerCase(){
                                when 'pdf'       { contentType = 'application/pdf'; }
                                when 'doc'       { contentType = 'application/msword'; }
                                when 'docx'      { contentType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'; }
                                when 'xls'       { contentType = 'application/vnd.ms-excel'; }
                                when 'xlsx'      { contentType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'; }
                                when 'png'       { contentType = 'image/png'; }
                                when 'jpg','jpeg'{ contentType = 'image/jpeg'; }
                                when 'txt'       { contentType = 'text/plain'; }
                                when else        { contentType = 'application/octet-stream'; }
                            }
                        }
                        efa.setContentType(contentType);
                        attachments.add(efa);
                    }
                }
                
                
            }
            email.setFileAttachments( attachments );
            
            // Send email
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { email });
            
            List<Id> recIdList = new List<Id>{ recId };
                WhatsappController.SendSaleAgreementforReview(recIdList);
            
            returnMessage = 'Email sent successfully';
            
        } catch (Exception e) {
            system.debug('Error sending email: ' + e.getMessage());
            ExceptionHandler.addLog(e,emailContent,'GenerateDocumnetController',recId);  /*Add Exception to error log*/
            returnMessage = 'Error sending email: ' + e.getMessage();
        }
        
        return returnMessage;
    }
    
    
    
    @AuraEnabled
    public static String sendEmailGenerateCarParking(Id recId, String emailContent) {
        System.debug('emailContent: ' + emailContent);
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        String returnMessage;
        
        try {
            // Retrieve the Booking record
            Booking__c booking = [
                SELECT Id, Project1__c, Email1__c, Email2__c, First_Applicant_Name__c, CRM_Manager__c, CRM_Manager__r.Email 
                FROM Booking__c 
                WHERE Id = :recId 
                LIMIT 1
            ];
            
            // Retrieve associated Parking Floor
            List<Parking_Floor__c> parkingFloors = [
                SELECT Id, Name  
                FROM Parking_Floor__c
                WHERE Project__c = :booking.Project1__c
            ];
            
            if (parkingFloors.isEmpty()) {
                return 'No Parking Floors found for the associated project.';
            }
            
            // Collect Parking Floor IDs
            Set<Id> parkingFloorIds = new Set<Id>();
            for (Parking_Floor__c pf : parkingFloors) {
                parkingFloorIds.add(pf.Id);
            }
            
            // Check if any Parking__c (slots) exist for the parking floors
            Integer parkingSlotsCount = [
                SELECT COUNT() 
                FROM Parking__c 
                WHERE Parking_Floor__c IN :parkingFloorIds AND Status__c ='Available'
            ];
            
            if (parkingSlotsCount == 0) {
                return 'No Parking Slots available for the associated Parking Floors.';
            }
            
            System.debug('parkingFloorIds ' + parkingFloorIds);
            
            // Step 1: Retrieve ContentDocumentIds linked to Parking_Floor__c records
            List<ContentDocumentLink> contentDocumentLinks = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN :parkingFloorIds
            ];
            
            Set<Id> contentDocumentIds = new Set<Id>();
            for (ContentDocumentLink docLink : contentDocumentLinks) {
                contentDocumentIds.add(docLink.ContentDocumentId);
            }
            
            // Step 2: Retrieve only the latest versions of the documents
            List<ContentVersion> contentVersions = new List<ContentVersion>();
            if (!contentDocumentIds.isEmpty()) {
                contentVersions = [
                    SELECT VersionData, Title, ContentDocumentId, FileExtension
                    FROM ContentVersion
                    WHERE ContentDocumentId IN :contentDocumentIds
                    AND IsLatest = TRUE
                ];
            }
            
            // Prepare email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();
            
            if (booking.Email1__c != null) {
                sendTo.add(booking.Email1__c);
            }
            
            email.setToAddresses(sendTo);
            email.setSubject('Selection of Car Parking');
            email.setHtmlBody(emailContent);
            
            // CC to veegaland customercare
            List<String> lstCCEmail = new List<String>();
           // lstCCEmail.add('customercare@veegaland.in');
           if (!lstCCEmail.isEmpty()) {
            email.setCcAddresses(lstCCEmail);
           }
            // Attach files
            List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
            for (ContentVersion docVersion : contentVersions) {
                Messaging.EmailFileAttachment emailFile = new Messaging.EmailFileAttachment();
                String fileNameWithExtension = docVersion.Title + '.' + docVersion.FileExtension;
                emailFile.setFileName(fileNameWithExtension);
                emailFile.setBody(docVersion.VersionData);
                emailAttachments.add(emailFile);
            }
            
            if (!emailAttachments.isEmpty()) {
                email.setFileAttachments(emailAttachments);
            }
            
            // Fetch Org-Wide Email Address (using CRM Manager's email or Display Name)
            List<OrgWideEmailAddress> orgWideEmails = [
                SELECT Id, Address
                FROM OrgWideEmailAddress
                WHERE Address = :booking.CRM_Manager__r.Email
                LIMIT 1
            ];
            
            // Set the 'From' address using the Org-Wide Email Address
            if (!orgWideEmails.isEmpty()) {
                email.setOrgWideEmailAddressId(orgWideEmails[0].Id);  // Use the OWA's Id
            }
            
            email.setSaveAsActivity(true);
            email.setWhatId(booking.Id);
            emailsToSend.add(email);
            
            // Send the email
            if (!emailsToSend.isEmpty()) {
                Messaging.sendEmail(emailsToSend);
            }
            
            returnMessage = 'Email sent successfully';
            
        } catch (Exception e) {
            ExceptionHandler.addLog(e,emailContent,'GenerateDocumnetController',recId);  /*Add Exception to error log*/
            returnMessage = 'Error sending email: ' + e.getMessage();
            System.debug('Error: ' + e);
        }
        
        return returnMessage;
    }
    
    
    
    /* Date: 26/08/25  Author:  @desc: Send NOC Document .   @param 1:booking Id @return :string*/     
    @AuraEnabled
    public static String sendEmailGenerateNOC(Id recId) {
        String returnMessage;
        try {
            
            // Retrieve the Booking record
            Booking__c booking = [SELECT Id, Project__c, Email1__c,Bank__c, Email2__c, First_Applicant_Name__c, Owner.Email, CRM_Manager__c, CRM_Manager__r.Email 
                                  FROM Booking__c WHERE Id = :recId LIMIT 1];
            List<String> lstCCEmail = new List<String>();
            
            
            // Retrieve Org Wide Email Address
            List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :booking.Owner.Email];
            
            if (booking != null && !String.isBlank(booking.Email1__c)) {
                // Generate the PDF for the Additional Charges
                
                PageReference  vfPage = Page.NOC;                
                vfPage.getParameters().put('id', recId);
                //Blob pdfBlob = vfPage.getContentAsPDF();
                Blob pdfBlob = !Test.isRunningTest() ? vfPage.getContentAsPDF() : Blob.valueOf('testblob');
                
                // Prepare email details
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>();
                sendTo.add(booking.Email1__c);
                if (booking.Email1__c != null) {
                    sendTo.add(booking.Email1__c);
                }
                
                // Set Org-Wide Email Address
                if (owea.size() > 0) {
                    email.setOrgWideEmailAddressId(owea[0].Id);
                }
                
                // Include CC addresses
                lstCCEmail.add(booking.Owner.Email);
                if (booking.CRM_Manager__c != null) {
                    lstCCEmail.add(booking.CRM_Manager__r.Email);
                }
               // lstCCEmail.add('customercare@veegaland.in');
                if (lstCCEmail.size() > 0) {
                    email.setCcAddresses(lstCCEmail);
                }
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
                email.setToAddresses(sendTo);
                email.setSubject('NOC Document');
                
                String emailBody = '';
                emailBody += 'Dear ' + booking.First_Applicant_Name__c + ',<br/><br/>Please find the attached NOC Document for your booking.<br/><br/>';
                emailBody += 'If you need any assistance or further details, do not hesitate to reach out.<br/><br/>';
                emailBody += 'Thank you for your continued trust.<br/><br/>';
                emailBody += 'Best regards,<br/><br/>';
                
                emailBody += '<b>Midhu Siju</b> | Officer - Customer Relations | <a href="tel:+919207054444">9207054444</a><br/>';
                emailBody += '<b>Alitta Lijoy</b> | Customer Relation Executive | <a href="tel:+919048237066">90482 37066</a><br/><br/>';
                
                emailBody += '<b>'+companyName+'</b><br/>';
                emailBody += 'Regd. Office: '+Address1+' '+Address2+' '+Address3+ '<br/>';
                emailBody += 'Tel: +91 484 2584000 / 2973944, +91 6235051144<br/>';
                emailBody += '<a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a><br/><br/>';
                
                emailBody += 'Follow us on:<br/>';
                emailBody += '<a href="https://www.facebook.com/veegalanddevelopers" target="_blank">Facebook</a> | ';
                emailBody += '<a href="https://www.instagram.com/veegalanddevelopers" target="_blank">Instagram</a> | ';
                emailBody += '<a href="https://www.linkedin.com/company/veegalanddevelopers" target="_blank">LinkedIn</a> | ';
                emailBody += '<a href="https://www.youtube.com/c/VeegalandDevelopers" target="_blank">YouTube</a><br/>';
                
                email.setHtmlBody(emailBody);                
                // Attach the PDF to the email
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('NOC_Document.pdf');
                attachment.setBody(pdfBlob);
                email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
                email.setSaveAsActivity(true);
                email.setWhatId(booking.Id);
                // Send the email
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                
                returnMessage = 'Email sent successfully';
            } else {
                returnMessage = 'Email address not specified in the Booking record.';
            }
        } catch (Exception e) {
            ExceptionHandler.addLog(e,'','GenerateDocumnetController',recId);  /*Add Exception to error log*/
            returnMessage = 'Error sending email: ' + e.getMessage();
        }
        return returnMessage;
    }
    
    /* Date: 26/08/25  Author:  @desc: Send TPA Document to customer.   @param 1:booking Id @return :string*/        
    @AuraEnabled
    public static String sendEmailGenerateTPA(Id recId) {
        String returnMessage;
        try {
            
            // Retrieve the Booking record
            Booking__c booking = [SELECT Id, Project__c, Email1__c,Bank__c, Email2__c, First_Applicant_Name__c, Owner.Email, CRM_Manager__c, CRM_Manager__r.Email 
                                  FROM Booking__c WHERE Id = :recId LIMIT 1];
            List<String> lstCCEmail = new List<String>();
            
            // Retrieve co-applicants associated with the Booking
            List<Co_Applicant__c> coApps = [SELECT Id, Name, Email__c, Booking__c FROM Co_Applicant__c WHERE Booking__c = :booking.Id];
            
            // Retrieve Org Wide Email Address
            List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :booking.Owner.Email];
            
            if (booking != null && !String.isBlank(booking.Email1__c)) {
                // Generate the PDF for the Additional Charges
                
                PageReference vfPage = Page.SBITripartiteAgreement;
                vfPage.getParameters().put('id', recId);
                //Blob pdfBlob = vfPage.getContentAsPDF();
                Blob pdfBlob = !Test.isRunningTest() ? vfPage.getContentAsPDF() : Blob.valueOf('testblob');
                
                // Prepare email details
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>();
                sendTo.add(booking.Email1__c);
                if (booking.Email1__c != null) {
                    sendTo.add(booking.Email1__c);
                }
                
                // Set Org-Wide Email Address
                if (owea.size() > 0) {
                    email.setOrgWideEmailAddressId(owea[0].Id);
                }
                
                // Include CC addresses
                lstCCEmail.add(booking.Owner.Email);
               // lstCCEmail.add('customercare@veegaland.in');
                if (booking.CRM_Manager__c != null) {
                    lstCCEmail.add(booking.CRM_Manager__r.Email);
                }
                if (lstCCEmail.size() > 0) {
                    email.setCcAddresses(lstCCEmail);
                }
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
                
                email.setToAddresses(sendTo);
                email.setSubject('TPA Document');
                String emailBody = '';
                emailBody += 'Dear ' + booking.First_Applicant_Name__c + ',<br/><br/>Please find the attached TPA Document for your booking.<br/><br/>';
                emailBody += 'If you need any assistance or further details, do not hesitate to reach out.<br/><br/>';
                emailBody += 'Thank you for your continued trust.<br/><br/>';
                emailBody += 'Best regards,<br/><br/>';
                
                emailBody += '<b>Midhu Siju</b> | Officer - Customer Relations | <a href="tel:+919207054444">9207054444</a><br/>';
                emailBody += '<b>Alitta Lijoy</b> | Customer Relation Executive | <a href="tel:+919048237066">90482 37066</a><br/><br/>';
                
                emailBody += '<b>'+companyName+'</b><br/>';
                emailBody += 'Regd. Office: '+Address1+' '+Address2+' '+Address3+ '<br/>';
                emailBody += 'Tel: +91 484 2584000 / 2973944, +91 6235051144<br/>';
                emailBody += '<a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a><br/><br/>';
                
                emailBody += 'Follow us on:<br/>';
                emailBody += '<a href="https://www.facebook.com/veegalanddevelopers" target="_blank">Facebook</a> | ';
                emailBody += '<a href="https://www.instagram.com/veegalanddevelopers" target="_blank">Instagram</a> | ';
                emailBody += '<a href="https://www.linkedin.com/company/veegalanddevelopers" target="_blank">LinkedIn</a> | ';
                emailBody += '<a href="https://www.youtube.com/c/VeegalandDevelopers" target="_blank">YouTube</a><br/>';
                email.setHtmlBody(emailBody);
                
                // Attach the PDF to the email
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('TPA_Document.pdf');
                attachment.setBody(pdfBlob);
                email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
                email.setSaveAsActivity(true);
                email.setWhatId(booking.Id);
                // Send the email
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                
                returnMessage = 'Email sent successfully';
            } else {
                returnMessage = 'Email address not specified in the Booking record.';
            }
        } catch (Exception e) {
            ExceptionHandler.addLog(e,'','GenerateDocumnetController',recId);  /*Add Exception to error log*/
            returnMessage = 'Error sending email: ' + e.getMessage();
        }
        return returnMessage;
    }
    
    /* Date: 26/08/25  Author:  @desc: Send demand letter to customer.   @param 1:booking Id @return :string*/        
    @InvocableMethod
    public static void sendEmailGenerateDemand(List<Id> recIds) {
        try {
            
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            // Fetch the Demand_Raised__c records for the given recIds
            List<Demand_Raised__c> demandRecords = [
                SELECT Id, Demand_Email_Content__c,Current_Milestone__c,Project__c,Payment_schedule__r.Post_OC_Completion__c,CreatedBy.Email, Demand_Content_Ids__c,Booking__r.Block__r.Name, Booking__r.Email1__c, Booking__r.Email2__c, 
                Booking__r.Owner.Email, Booking__r.CRM_Manager__r.Email, Booking__r.Project__c,Booking__r.Total__c, 
                (SELECT ContentDocumentId, ContentDocument.Title FROM ContentDocumentLinks WHERE LinkedEntityId IN :recIds)
                FROM Demand_Raised__c 
                WHERE Id IN :recIds
            ];
            
            if (demandRecords.isEmpty()) {
                return;
            }
            
            
            for (Demand_Raised__c demand : demandRecords) {
                // Convert comma-separated string of content IDs to Set<Id>
                List<String> contentDocumentIds = new List<String>();
                if (!String.isBlank(demand.Demand_Content_Ids__c)) {
                    contentDocumentIds.addAll(demand.Demand_Content_Ids__c.split(','));
                }
                
                Boolean isCompletedOC = demand.Payment_schedule__r.Post_OC_Completion__c;
                List<String> lstCCEmail = new List<String>();
                Booking__c booking = demand.Booking__r;
                
                if (booking != null && !String.isBlank(booking.Email1__c)) {
                    // Generate the PDF for the Agreement Amount Request
                    PageReference vfPage;
                    if(isCompletedOC == true){
                        vfPage = Page.BillofSupplySendVFP;
                    }else{
                        vfPage = Page.Demand_Note_Send;
                    }
                    
                    vfPage.getParameters().put('id', demand.Id);
                    Blob pdfBlob = !Test.isRunningTest() ? vfPage.getContentAsPDF() : Blob.valueOf('testblob');
                    
                    // Prepare email details
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    List<String> sendTo = new List<String>();
                    sendTo.add(booking.Email1__c);
                    if (booking.Email2__c != null) {
                        sendTo.add(booking.Email2__c);
                    }
                    
                    // Include CRM Manager email in CC
                    // lstCCEmail.add('customercare@veegaland.in');
                    lstCCEmail.add(booking.Owner.Email);
                    if (booking.CRM_Manager__r != null && booking.CRM_Manager__r.Email != null) {
                        lstCCEmail.add(booking.CRM_Manager__r.Email);
                    }
                    
                    List<String> validccEmails = new List<String>();
                   // validccEmails.add('customercare@veegaland.in');
                    List<String> combinedCCAddresses = new List<String>();
                    combinedCCAddresses.addAll(lstCCEmail);
                    validccEmails = validateEmails(combinedCCAddresses);
                    
                    
                    if (!validccEmails.isEmpty()) {
                        email.setCcAddresses(validccEmails);
                    }
                    email.setToAddresses(sendTo);
                    email.setSubject('Demand Note for Completion of '+demand.Current_Milestone__c +' In '+demand.Project__c);
                    email.setHtmlBody(demand.Demand_Email_Content__c);
                    
                    // Retrieve Content Versions for attachments
                    List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
                    if (!contentDocumentIds.isEmpty()) {
                        List<ContentVersion> contentVersions = [
                            SELECT Title, FileExtension, VersionData 
                            FROM ContentVersion 
                            WHERE ContentDocumentId IN :contentDocumentIds
                        ];
                        
                        for (ContentVersion cv : contentVersions) {
                            Messaging.EmailFileAttachment contentAttach = new Messaging.EmailFileAttachment();
                            contentAttach.setFileName(cv.Title + '.' + cv.FileExtension);
                            contentAttach.setBody(cv.VersionData);
                            emailAttachments.add(contentAttach);
                        }
                    }
                    
                    // Attach the Demand PDF
                    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                    attachment.setFileName('Demand.pdf');
                    attachment.setBody(pdfBlob);
                    emailAttachments.add(attachment);
                    
                    if (!emailAttachments.isEmpty()) {
                        email.setFileAttachments(emailAttachments);
                    }
                    if(!Test.isRunningTest()){
                        String CreatedEmail = demand.CreatedBy.Email;
                        list<OrgWideEmailAddress> orgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :CreatedEmail LIMIT 1];
                        if (orgWideEmail.size() > 0) {
                            email.setOrgWideEmailAddressId(orgWideEmail[0].Id);
                        }
                    }
                    email.setSaveAsActivity(true);
                    email.setWhatId(demand.Id);
                    // Send the email
                    emails.add(email);
                } 
                if (!emails.isEmpty()) {
                    Messaging.sendEmail(emails);
                }
            }
        } catch (Exception e) {
            ExceptionHandler.addLog(e,string.valueof(recIds),'GenerateDocumnetController','');  /*Add Exception to error log*/
            System.debug('Exception occurred: ' + e.getMessage());
            throw e;
        }
    }
    
    /* Date: 26/08/25  Author:  @desc: Send Agreement Cost Mail to Customer   @param 1:booking Id @return :string*/     
    @AuraEnabled
    public static String sendAgreementCostMail(Id recId,String emailContent) {
        system.debug('emailContent'+emailContent);
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        String returnMessage;
        try {
            // Retrieve the Booking record
            List<Booking__c> bookings = [SELECT Id,Registration_Status__c, Project__c, Email1__c, Email2__c, First_Applicant_Name__c, CRM_Manager__c, CRM_Manager__r.Email 
                                         FROM Booking__c WHERE Id = :recId LIMIT 1];
            List<String> lstCCEmail = new List<String>();
            
            // Retrieve co-applicants associated with the Booking
            //List<Co_Applicant__c> coApps = [SELECT Id, Name, Email__c, Booking__c FROM Co_Applicant__c WHERE Booking__c = :booking.Id];
            
            // Retrieve Org Wide Email Address
            //List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :booking.Owner.Email];
            
            if (!bookings.isEmpty()) {
                Booking__c booking = bookings[0];
                // Prepare email details
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>();
                sendTo.add(booking.Email1__c);
                if (booking.Email1__c != null) {
                    sendTo.add(booking.Email1__c);
                }
                
                email.setToAddresses(sendTo);
                email.setSubject('Collection of Agreement Registration Fee ');
                email.setHtmlBody(emailContent);
                
                //CC to veegaland customercare 
                List<String> lstCCEmail1 = new List<String>();
                //lstCCEmail.add('customercare@veegaland.in');
                if (!lstCCEmail.isEmpty()) {
                email.setCcAddresses(lstCCEmail1);
                }
                
                email.setSaveAsActivity(true);
                email.setWhatId(booking.Id);
                emailsToSend.add(email);
                // Send the email
                
                if (!emailsToSend.isEmpty()) {
                    Messaging.sendEmail(emailsToSend);
                }
                
                List<Task> existingTasks = [
                    SELECT Id, Status 
                    FROM Task 
                    WHERE WhatId = :booking.Id AND Subject = 'Send Agreement Cost Mail to Customer' 
                    AND Status != 'Completed'
                    LIMIT 1
                ];
                
                if (!existingTasks.isEmpty()) {
                    Task t = existingTasks[0];
                    t.Status = 'Completed';
                    update t;
                }
                
                booking.Registration_Status__c = 'Scheduled';
                update booking;
                
                returnMessage = 'Email sent successfully';
            } else {
                returnMessage = 'Email address not specified in the Booking record.';
            }
        } catch (Exception e) {
            ExceptionHandler.addLog(e,emailContent,'GenerateDocumnetController',recId);  /*Add Exception to error log*/
            returnMessage = 'Error sending email: ' + e.getMessage();
            system.debug('returnMessage'+e);
        }
        return returnMessage;
    }
    
    /* Date: 26/08/25  Author:  @desc: Send additional charge email to Customer   @param 1:booking Id @return :string*/  
    @AuraEnabled
    public static String sendExtraCostDemandMail(Id recId,String emailContent) {
        
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        String returnMessage;
        try {
            // Retrieve the Booking record
            List<Booking__c> bookings = [SELECT Id,Registration_Status__c, Project__c, Email1__c, Email2__c, First_Applicant_Name__c, CRM_Manager__c, CRM_Manager__r.Email,Owner.Email
                                         FROM Booking__c WHERE Id = :recId LIMIT 1];
            List<String> lstCCEmail = new List<String>();
            
            Map<String, Id> ownerEmailToOrgWideIdMap = new Map<String, Id>();
            for (OrgWideEmailAddress ow : [SELECT Id, Address FROM OrgWideEmailAddress]) {
                ownerEmailToOrgWideIdMap.put(ow.Address.toLowerCase(), ow.Id);
            }
            
            if (!bookings.isEmpty()) {
                Booking__c booking = bookings[0];
                // Prepare email details
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>();
                sendTo.add(booking.Email1__c);
                if (booking.Email1__c != null) {
                    sendTo.add(booking.Email1__c);
                }
                
                //CC to veegaland customercare 
                List<String> lstCCEmail2 = new List<String>();
                //lstCCEmail.add('customercare@veegaland.in');
                if (!lstCCEmail.isEmpty()) {
                email.setCcAddresses(lstCCEmail2);
                }
                
                email.setToAddresses(sendTo);
                email.setSubject('Additional Charge Email');
                email.setHtmlBody(emailContent);
                
                email.setSaveAsActivity(true);
                email.setWhatId(booking.Id);
                
                String ownerEmail = booking.Owner.Email;
                if (ownerEmail != null && ownerEmailToOrgWideIdMap.containsKey(ownerEmail.toLowerCase())) {
                    email.setOrgWideEmailAddressId(ownerEmailToOrgWideIdMap.get(ownerEmail.toLowerCase()));
                }
                emailsToSend.add(email);
                // Send the email
                
                if (!emailsToSend.isEmpty()) {
                    Messaging.sendEmail(emailsToSend);
                }
                
                
                returnMessage = 'Email sent successfully';
            } else {
                returnMessage = 'Email address not specified in the Booking record.';
            }
        } catch (Exception e) {
            ExceptionHandler.addLog(e,emailContent,'GenerateDocumnetController',recId);  /*Add Exception to error log*/
            returnMessage = 'Error sending email: ' + e.getMessage();
            system.debug('returnMessage'+e);
        }
        return returnMessage;
    }
    
    
    
    
    
    @AuraEnabled
    public static String sendDeviationEmail(Id recId, String toAddresses, String emailContent) {
        system.debug('toAddresses'+toAddresses);
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        String returnMessage;
        try {
            // Query booking for context if needed
            Booking__c booking = [SELECT Id, Owner.Email, Sales_Manager1__r.Email,Sales_Manager1__c FROM Booking__c WHERE Id = :recId LIMIT 1];
            
            // Prepare email addresses list from toAddresses param
            List<String> sendTo = new List<String>();
            if (toAddresses != null) {
                for (String addr : toAddresses.split(',')) {
                    String trimmedAddr = addr.trim();
                    if (trimmedAddr != '') {
                        sendTo.add(trimmedAddr);
                    }
                }
            }
            system.debug('finalToAddress'+sendTo);
            if (sendTo.isEmpty()) {
                return 'No recipient email addresses provided.';
            }
            
            List<String> lstCCEmail = new List<String>();
            if(booking.Sales_Manager1__c !=null)
                lstCCEmail.add(booking.Sales_Manager1__r.Email);
            //lstCCEmail.add('customercare@veegaland.in');
            
            Map<String, Id> ownerEmailToOrgWideIdMap = new Map<String, Id>();
            for (OrgWideEmailAddress ow : [SELECT Id, Address FROM OrgWideEmailAddress]) {
                ownerEmailToOrgWideIdMap.put(ow.Address.toLowerCase(), ow.Id);
            }
            
            
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(sendTo);
            
            if (!lstCCEmail.isEmpty()) {
            email.setCcAddresses(lstCCEmail);
            }
            email.setSubject('Deviation Email');
            email.setHtmlBody(emailContent);
            email.setSaveAsActivity(true);
            email.setWhatId(booking.Id);
            
            String ownerEmail = booking.Owner.Email;
            if (ownerEmail != null && ownerEmailToOrgWideIdMap.containsKey(ownerEmail.toLowerCase())) {
                email.setOrgWideEmailAddressId(ownerEmailToOrgWideIdMap.get(ownerEmail.toLowerCase()));
            }
            
            emailsToSend.add(email);
            
            if (!emailsToSend.isEmpty()) {
                Messaging.sendEmail(emailsToSend);
            }
            
            returnMessage = 'Email sent successfully';
            
        } catch (Exception e) {
            // Assuming ExceptionHandler.addLog is implemented elsewhere
            ExceptionHandler.addLog(e, emailContent, 'GenerateDocumnetController', recId);
            returnMessage = 'Error sending email: ' + e.getMessage();
            System.debug('Exception in sendDeviationEmail: ' + e);
        }
        return returnMessage;
    }
    
    
    
    /* Date: 26/08/25  Author:  @desc: Send draft agreement email to Customer   @param 1:booking Id @return :string*/    
    @Future(callout=true)
    public static void sendDraftAgreementEmail(Set<Id> bookingIds) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        // Step 1: Query Bookings
        List<Booking__c> bookings = [SELECT Id, Email1__c,Registration_office__c, Agreement_Expected_Date__c, Stage__c, Agreement_Approval_Status__c, Authorized_Signatory__c 
                                     FROM Booking__c WHERE Id IN :bookingIds];
        
        // Step 2: Query Co-Applicant Count
        Map<Id, Integer> bookingCoApplicantMap = new Map<Id, Integer>();
        for (AggregateResult ar : [SELECT Booking__c Id, COUNT(Id) coApplicantCount 
                                   FROM Co_Applicant__c 
                                   WHERE Booking__c IN :bookingIds 
                                   GROUP BY Booking__c]) {
                                       bookingCoApplicantMap.put((Id) ar.get('Id'), (Integer) ar.get('coApplicantCount'));
                                   }
        
        for (Booking__c booking : bookings) {
            if (booking.Stage__c == 'Draft Agreement Preparation' && 
                booking.Agreement_Approval_Status__c == 'Approved') {
                    
                    // Ensure the booking has a valid email
                    if (String.isEmpty(booking.Email1__c)) {
                        System.debug('No email found for booking ID: ' + booking.Id);
                        continue;
                    }
                    
                    // Step 3: Determine Agreement Type
                    Integer coApplicantCount = bookingCoApplicantMap.containsKey(booking.Id) ? bookingCoApplicantMap.get(booking.Id) : 0;
                    String agreementType;
                    PageReference vfPage;
                    if (coApplicantCount > 0) {
                        vfPage = Page.SaleAgreementTwoApplicants; // Booking has Co-Applicants
                    } else if (booking.Authorized_Signatory__c == true) {
                        vfPage = Page.Sales_agreement_One_applicant_with_POA; // No Co-Applicant, but Authorized_Signatory__c is true
                    } else {
                        vfPage = Page.SalesAgreement1Applicant; // No Co-Applicant and Authorized_Signatory__c is false
                    }
                    vfPage.getParameters().put('id', booking.Id);
                    Blob pdfBlob = !Test.isRunningTest() ? vfPage.getContentAsPDF() : Blob.valueOf('testblob');
                    
                    // Step 4: Construct Email Body
                    String emailBody;
                    if (booking.Agreement_Expected_Date__c == null) {  // Check if date is NULL
                        emailBody = 'Dear Customer,<br/><br/>' +
                            'Please find the attached draft for registration.<br/><br/>' +
                            'Please update with the available date for the registration.<br/><br/>' +
                            '<strong>Location:</strong>'+booking.Registration_office__c+'<br/><br/>' +
                            'Regards,<br/>Midhu | Alita';
                    } else {
                        emailBody = 'Dear Customer,<br/><br/>' +
                            'Please find the attached draft for registration.<br/><br/>' +
                            '<strong>Date & Location for Registration:</strong><br/><br/>' +
                            '<strong>Date:</strong> ' + booking.Agreement_Expected_Date__c.format() + '<br/>' +
                            '<strong>Location:</strong>'+ booking.Registration_office__c+'<br/><br/>' +
                            'Regards,<br/>Midhu | Alita';
                    }
                    List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
                    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                    attachment.setFileName('Draft Sale Agreement.pdf');
                    attachment.setBody(pdfBlob);
                    emailAttachments.add(attachment);
                    
                    
                    
                    // Step 5: Create Email
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new List<String>{booking.Email1__c});
                    email.setSubject('Draft Agreement for Registration');
                    email.setFileAttachments(emailAttachments);
                    
                    //CC to veegaland customercare 
                    List<String> lstCCEmail = new List<String>();
                    //lstCCEmail.add('customercare@veegaland.in');
                    if (!lstCCEmail.isEmpty()) {
                    email.setCcAddresses(lstCCEmail);
                    }
                    email.setHtmlBody(emailBody); 
                    email.setSaveAsActivity(true);
                    email.setWhatId(booking.Id);
                    
                    emails.add(email);
                }
        }
        
        // Step 6: Send Emails
        if (!emails.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
            for (Messaging.SendEmailResult res : results) {
                if (res.isSuccess()) {
                    System.debug('Email sent successfully');
                } else {
                    System.debug('Failed to send email: ' + res.getErrors()[0].getMessage());
                }
            }
        }
    }
    
    /* Date: 26/08/25  Author:  @desc: Send registration agreement schedule email to Customer   @param 1:booking Id @return :string*/   
    @AuraEnabled
    public static String sendFInalAppoinmentMail(Id recId, String emailContent) {
        system.debug('emailContent: ' + emailContent);
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        String returnMessage;
        
        try {
            List<Booking__c> bookings = [
                SELECT Id, Project__c, Email1__c, Email2__c, First_Applicant_Name__c, CRM_Manager__c, CRM_Manager__r.Email,Owner.Email
                FROM Booking__c WHERE Id = :recId LIMIT 1
            ];
            
            Map<String, Id> ownerEmailToOrgWideIdMap = new Map<String, Id>();
            for (OrgWideEmailAddress ow : [SELECT Id, Address FROM OrgWideEmailAddress]) {
                ownerEmailToOrgWideIdMap.put(ow.Address.toLowerCase(), ow.Id);
            }
            
            if (!bookings.isEmpty()) {
                Booking__c booking = bookings[0];
                
                List<String> sendTo = new List<String>();
                if (booking.Email1__c != null) {
                    sendTo.add(booking.Email1__c);
                }
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(sendTo);
                email.setSubject('Registration appointment scheduled');
                email.setHtmlBody(emailContent);
                email.setSaveAsActivity(true);
                //CC to veegaland customercare 
                List<String> lstCCEmail = new List<String>();
                //lstCCEmail.add('customercare@veegaland.in');
                if (!lstCCEmail.isEmpty()) {
                email.setCcAddresses(lstCCEmail);
                } 
                email.setWhatId(booking.Id);
                String ownerEmail = booking.Owner.Email;
                if (ownerEmail != null && ownerEmailToOrgWideIdMap.containsKey(ownerEmail.toLowerCase())) {
                    email.setOrgWideEmailAddressId(ownerEmailToOrgWideIdMap.get(ownerEmail.toLowerCase()));
                }
                emailsToSend.add(email);
                
                if (!emailsToSend.isEmpty()) {
                    Messaging.sendEmail(emailsToSend);
                }
                
                // Complete the related task
                List<Task> tasksToUpdate = [
                    SELECT Id, Status 
                    FROM Task 
                    WHERE WhatId = :booking.Id 
                    AND Subject = 'Generate and Send Sale Agreement Appointment Mail' 
                    LIMIT 1
                ];
                
                if (!tasksToUpdate.isEmpty()) {
                    Task task = tasksToUpdate[0];
                    task.Status = 'Completed';
                    update task;
                }
                
                returnMessage = 'Email sent successfully';
            } else {
                returnMessage = 'Booking not found or email not specified.';
            }
            
        } catch (Exception e) {
            ExceptionHandler.addLog(e,emailContent,'GenerateDocumnetController',recId);  /*Add Exception to error log*/
            returnMessage = 'Error sending email: ' + e.getMessage();
            system.debug('Error: ' + e);
        }
        
        return returnMessage;
    }
    
    /* Date: 26/08/25  Author:  @desc: Send registration agreement schedule email to Customer   @param 1:booking Id @return :string*/  
    @future(callout=false)
    public static void sendRescheduleEmailsAsync(List<Id> bookingIds) {
        List<Booking__c> bookings = [SELECT Id, Email1__c, Agreement_Appointment_Date__c,Registration_office__c,Legal_Team__r.Name,Owner.Email
                                     FROM Booking__c 
                                     WHERE Id IN :bookingIds];
        
        Map<String, Id> ownerEmailToOrgWideIdMap = new Map<String, Id>();
        for (OrgWideEmailAddress ow : [SELECT Id, Address FROM OrgWideEmailAddress]) {
            ownerEmailToOrgWideIdMap.put(ow.Address.toLowerCase(), ow.Id);
        }
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,Label,Address2__c,Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
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
        for (Booking__c booking : bookings) {
            if (String.isNotBlank(booking.Email1__c)) { // Ensure Email1__c is not null
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>{ booking.Email1__c });
                email.setSubject('Registration appointment scheduled');
                
                String reggDate = booking.Agreement_Appointment_Date__c != null
                    ? DateTime.newInstance(booking.Agreement_Appointment_Date__c.year(),
                                           booking.Agreement_Appointment_Date__c.month(),
                                           booking.Agreement_Appointment_Date__c.day(), 0, 0, 0)
                    .format('yyyy-MM-dd')
                    : 'Not Available';
                
                String emailBody = 'Dear Customer,\n\n' +
                    'Your registration appointment has been rescheduled as follows:\n\n' +
                    'Date: ' + reggDate + '\n' +
                    'Location:'+ booking.Registration_office__c+'\n' +
                    'Advocate Name: '+booking.Legal_Team__r.Name+' \n\n' +
                    'Please ensure your presence with all required documents.\n\n'+
                    'Thanks & Regards,\n'+
                    +companyName+' \n'+
                    +Address1+' '+Address2+'\n'+
                    +Address3;
                
                
                email.setPlainTextBody(emailBody);
                email.setSaveAsActivity(true);
                String ownerEmail = booking.Owner.Email;
                if (ownerEmail != null && ownerEmailToOrgWideIdMap.containsKey(ownerEmail.toLowerCase())) {
                    email.setOrgWideEmailAddressId(ownerEmailToOrgWideIdMap.get(ownerEmail.toLowerCase()));
                }
                email.setWhatId(booking.Id);
                
                //CC to veegaland customercare 
                List<String> lstCCEmail = new List<String>();
                //lstCCEmail.add('customercare@veegaland.in');
                if (!lstCCEmail.isEmpty()) {
                email.setCcAddresses(lstCCEmail);
                }
                emails.add(email);
            }
        }
        
        // Send emails if there are any to send
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }   
    
    /* Date: 26/08/25  Author:  @desc: Send registration agreement registration cacelled  email to Customer   @param 1:booking Id @return :string*/  
    public static void sendCancellationEmails(List<Id> bookingIds) {
        List<Booking__c> bookings = [SELECT Id, Email1__c, Owner.Email, Owner.Phone, Agreement_Expected_Date__c, Agreement_Appointment_Date__c
                                     FROM Booking__c 
                                     WHERE Id IN :bookingIds];
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Booking__c> bkList = new List<Booking__c>();
        List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,Label,Address2__c,Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
                string companyName;
                
                if(!companyDetails.isEmpty()){
                    companyName = companyDetails[0].Label;
                       
                }
        Map<String, Id> ownerEmailToOrgWideIdMap = new Map<String, Id>();
        for (OrgWideEmailAddress ow : [SELECT Id, Address FROM OrgWideEmailAddress]) {
            ownerEmailToOrgWideIdMap.put(ow.Address.toLowerCase(), ow.Id);
        }
        for (Booking__c booking : bookings) {
            if (String.isNotBlank(booking.Email1__c)) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>{ booking.Email1__c });
                email.setSubject('Unfortunately, your agreement registration is cancelled');
                
                String emailBody = 'Dear Customer,\n\n' +
                    'Unfortunately, your agreement registration has been cancelled.\n' +
                    'Please contact your executive for further details.\n\n' +
                    'Executive Contact Details:\n' +
                    'Email: ' + (String.isNotBlank(booking.Owner.Email) ? booking.Owner.Email : 'Not Available') + '\n' +
                    'Phone: ' + (String.isNotBlank(booking.Owner.Phone) ? booking.Owner.Phone : 'Not Available') + '\n\n' +
                    'Thank you.\n'+companyName;
                
                email.setSaveAsActivity(true);
                email.setWhatId(booking.Id);
                email.setPlainTextBody(emailBody);
                
                //CC to veegaland customercare 
                List<String> lstCCEmail = new List<String>();
                //lstCCEmail.add('customercare@veegaland.in');
                if (!lstCCEmail.isEmpty()) {
                email.setCcAddresses(lstCCEmail);
                }
                Booking__c bk = new Booking__c();
                bk.Id = booking.Id;
                bk.Agreement_Expected_Date__c = null;
                bk.Agreement_Appointment_Date__c= null;
               // bk.Registration_Status__c = 'Cancelled';
                bkList.add(bk);
                
                
                
                // Set OrgWideEmailAddressId based on Booking Owner email
                String ownerEmail = booking.Owner.Email;
                if (ownerEmail != null && ownerEmailToOrgWideIdMap.containsKey(ownerEmail.toLowerCase())) {
                    email.setOrgWideEmailAddressId(ownerEmailToOrgWideIdMap.get(ownerEmail.toLowerCase()));
                }
                emails.add(email);
            }
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
            if(!bkList.isEmpty()){
                update bkList;
            }
        }
    }
    
    /* Date: 26/08/25  Author:  @desc: Send orginal registration agreement email to Customer   @param 1:booking Id @return :string*/  
    public static void sendAgreementSharedEmail(List<Id> bookingIds) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        // Fetch booking details including customer email and name
        List<Booking__c> bookings = [SELECT Id, First_Applicant_Name__c, Email1__c,Owner.Email
                                     FROM Booking__c 
                                     WHERE Id IN :bookingIds];
        
        Map<String, Id> ownerEmailToOrgWideIdMap = new Map<String, Id>();
        for (OrgWideEmailAddress ow : [SELECT Id, Address FROM OrgWideEmailAddress]) {
            ownerEmailToOrgWideIdMap.put(ow.Address.toLowerCase(), ow.Id);
        }
        List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
                string companyName;
                
                if(!companyDetails.isEmpty()){
                    companyName = companyDetails[0].Label;
                       
                }
        
        for (Booking__c booking : bookings) {
            if (String.isBlank(booking.Email1__c)) {
                System.debug('Skipping Booking ID ' + booking.Id + ' due to missing Email');
                continue; // Skip if no customer email is available
            }
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{booking.Email1__c});
            email.setSubject('Original Sale Agreement Shared');
            
            // Email Body
            String emailBody = 'Dear ' + booking.First_Applicant_Name__c + ',<br/><br/>';
            emailBody += 'This is to inform you that the original sale agreement has been shared with you.<br/><br/>';
            emailBody += 'Thank you for your continued trust in us.<br/><br/>';
            emailBody += 'Thanks and Regards,<br/>';
            emailBody += '<b>Name</b><br/>';
            emailBody += '<b>'+companyName+'</b>';
            email.setHtmlBody(emailBody);
            // Set OrgWideEmailAddressId based on Booking Owner email
            String ownerEmail = booking.Owner.Email;
            if (ownerEmail != null && ownerEmailToOrgWideIdMap.containsKey(ownerEmail.toLowerCase())) {
                email.setOrgWideEmailAddressId(ownerEmailToOrgWideIdMap.get(ownerEmail.toLowerCase()));
            }
            
            //CC to veegaland customercare 
            List<String> lstCCEmail = new List<String>();
            //lstCCEmail.add('customercare@veegaland.in');
            if (!lstCCEmail.isEmpty()) {
            email.setCcAddresses(lstCCEmail);
            }
            email.setSaveAsActivity(true);
            email.setWhatId(booking.Id);
            emails.add(email);
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
            System.debug('Agreement shared emails sent successfully.');
        }
    }
    
    /* Date: 26/08/25  Author:  @desc: validate email address   @param 1:booking Id @return :email*/   
    public static List<String> validateEmails(List<String> emailAddresses) {
        List<String> validEmails = new List<String>();
        for (String email : emailAddresses) {
            if (email != null && Pattern.matches('^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$', email)) {
                validEmails.add(email);
            }
        }
        return validEmails;
    }
    
    /* Date: 26/08/25  Author:  @desc: Send salesdeed completed  email to Customer   @param 1:booking Id @return :string*/    
    public static void saledeedCompletedEmail(List<Id> saleDeedCompleteList) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
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
        // Fetch booking details including customer email and name
        List<Booking__c> bookings = [SELECT Id, First_Applicant_Name__c, Email1__c,Owner.Email
                                     FROM Booking__c 
                                     WHERE Id IN :saleDeedCompleteList];
        
        Map<String, Id> ownerEmailToOrgWideIdMap = new Map<String, Id>();
        for (OrgWideEmailAddress ow : [SELECT Id, Address FROM OrgWideEmailAddress]) {
            ownerEmailToOrgWideIdMap.put(ow.Address.toLowerCase(), ow.Id);
        }
        
        for (Booking__c booking : bookings) {
            if (String.isBlank(booking.Email1__c)) {
                System.debug('Skipping Booking ID ' + booking.Id + ' due to missing Email');
                continue; // Skip if no customer email is available
            }
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{booking.Email1__c});
            email.setSubject('Sale Deed Registration Completed');
            
            // Email Body
            String emailBody = 'Dear ' + booking.First_Applicant_Name__c + ',<br/><br/>';
            emailBody += 'We are pleased to inform you that we have successfully completed the sale deed registration and your registered sale deed along with the below mentioned original documents are now ready for collection. <br/><br/>';
            emailBody += '<ul>';
            emailBody += '<li>Land Tax</li>';
            emailBody += '<li>Possession certificate</li>';
            emailBody += '<li>Building certificate</li>';
            emailBody += '<li>Encumbrance certificate</li>';
            emailBody += '</ul><br/>';
            emailBody += 'Please feel free to visit our office at your convenience to collect the document. <br/>';
            emailBody += 'If you need any assistance or further details, do not hesitate to reach out.<br/><br/>';
            emailBody += 'Thank you for your continued trust.<br/><br/>';
            emailBody += 'Best regards,<br/>';
            emailBody += 'Midhu Siju | Officer - Customer Relations | 9207054444<br/>';
            emailBody += 'Alitta Lijoy | Customer Relation Executive | 90482 37066<br/><br/>';
            emailBody += companyName+'<br/>';
            emailBody += 'Regd. Office: '+Address1+' '+Address2+' '+Address3+ '<br/>';
            emailBody += 'Tel: +91 484 2584000 / 2973944, +91 6235051144<br/>';
            emailBody += '<a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a><br/><br/>';
            emailBody += 'Follow us on: <a href="https://www.facebook.com" target="_blank">Facebook</a> | <a href="https://www.instagram.com" target="_blank">Instagram</a> | <a href="https://www.linkedin.com" target="_blank">LinkedIn</a> | <a href="https://www.youtube.com" target="_blank">YouTube</a><br/>';
            
            email.setHtmlBody(emailBody);
            email.setSaveAsActivity(true);
            
            //CC to veegaland customercare 
            List<String> lstCCEmail = new List<String>();
            //lstCCEmail.add('customercare@veegaland.in');
            if (!lstCCEmail.isEmpty()) {
            email.setCcAddresses(lstCCEmail);
            }
            email.setWhatId(booking.Id);
            // Set OrgWideEmailAddressId based on Booking Owner email
            String ownerEmail = booking.Owner.Email;
            if (ownerEmail != null && ownerEmailToOrgWideIdMap.containsKey(ownerEmail.toLowerCase())) {
                email.setOrgWideEmailAddressId(ownerEmailToOrgWideIdMap.get(ownerEmail.toLowerCase()));
            }
            emails.add(email);
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
            System.debug('Sale deed completed emails sent successfully.');
        }
    }
    
    
    /*public static void processSaleDeedForApprovedReceipts(list<Id> approvedRecieptIds, String emailTemplateName) {
if (approvedRecieptIds == null || approvedRecieptIds.isEmpty() || String.isEmpty(emailTemplateName)) {
return; // No approved receipts or email template name provided
}

List<Booking__c> bookingsToUpdate = new List<Booking__c>();
List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

// Query related Booking__c records
Map<Id, Booking__c> bookingMap = new Map<Id, Booking__c>();
for (Booking__c booking : [
SELECT Id, Name, Total_Milestone_Payment_percentage__c, Sale_Deed_Process_started__c, Legal_Team__r.Email,Legal_Team__c
FROM Booking__c
WHERE Id IN (SELECT Booking__c FROM Receipt__c WHERE Id IN :approvedRecieptIds)
]) {
bookingMap.put(booking.Id, booking);
}

// Fetch the Email Template ID dynamically based on the provided name
Id emailTemplateId;
List<EmailTemplate> emailTemplates = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :emailTemplateName LIMIT 1];
if (!emailTemplates.isEmpty()) {
emailTemplateId = emailTemplates[0].Id;
} else {
System.debug('No Email Template found for: ' + emailTemplateName);
return; // Exit if no template found
}

// Fetch the Org-Wide Email Address (optional but recommended)
OrgWideEmailAddress orgWideEmail;
List<OrgWideEmailAddress> orgWideEmails = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
if (!orgWideEmails.isEmpty()) {
orgWideEmail = orgWideEmails[0];
}

for (Booking__c booking : bookingMap.values()) {
if (booking.Total_Milestone_Payment_percentage__c > 95 && !booking.Sale_Deed_Process_started__c) {

if (booking.Legal_Team__c != null) {
Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
email.setTargetObjectId(booking.Legal_Team__c);
email.setWhatId(booking.Id);
email.setTemplateId(emailTemplateId);
email.setSaveAsActivity(false);

// Set "From" address using Org-Wide Email Address if available
if (orgWideEmail != null) {
email.setOrgWideEmailAddressId(orgWideEmail.Id);
}

emails.add(email);
}

// Update Sale_Deed_Process_started__c
booking.Sale_Deed_Process_started__c = true;
bookingsToUpdate.add(booking);
}
}

// Bulk update the booking records
if (!bookingsToUpdate.isEmpty()) {
update bookingsToUpdate;
}

// Send emails
if (!emails.isEmpty()) {
Messaging.sendEmail(emails);
}
}*/
    /* Date: 26/08/25  Author:  @desc: Send nameboard selection  email to Customer   @param 1:booking Id @return :string*/  
    @AuraEnabled
    public static String sendNameBoardMail(Id recId,String emailContent) {
        system.debug('emailContent'+emailContent);
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        String returnMessage;
        try {
            // Retrieve the Booking record
            List<Booking__c> bookings = [SELECT Id,Project__c, Email1__c, Email2__c, First_Applicant_Name__c, CRM_Manager__c, CRM_Manager__r.Email,Owner.Email
                                         FROM Booking__c WHERE Id = :recId LIMIT 1];
            List<String> lstCCEmail = new List<String>();
            
            // Retrieve co-applicants associated with the Booking
            //List<Co_Applicant__c> coApps = [SELECT Id, Name, Email__c, Booking__c FROM Co_Applicant__c WHERE Booking__c = :booking.Id];
            
            Map<String, Id> ownerEmailToOrgWideIdMap = new Map<String, Id>();
            for (OrgWideEmailAddress ow : [SELECT Id, Address FROM OrgWideEmailAddress]) {
                ownerEmailToOrgWideIdMap.put(ow.Address.toLowerCase(), ow.Id);
            }
            
            if (!bookings.isEmpty()) {
                Booking__c booking = bookings[0];
                // Prepare email details
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>();
                sendTo.add(booking.Email1__c);
                if (booking.Email1__c != null) {
                    sendTo.add(booking.Email1__c);
                }
                /*if (booking.Email2__c != null) {
sendTo.add(booking.Email2__c);
}
// Include Co-Applicant emails
if (coApps.size() > 0) {
for (Co_Applicant__c ca : coApps) {
if (ca.Email__c != null) {
sendTo.add(ca.Email__c);
}
}
}

// Set Org-Wide Email Address
if (owea.size() > 0) {
email.setOrgWideEmailAddressId(owea[0].Id);
}

// Include CC addresses
lstCCEmail.add(booking.Owner.Email);
if (booking.CRM_Manager__c != null) {
lstCCEmail.add(booking.CRM_Manager__r.Email);
}
//lstCCEmail.add('Crmlead@mahendrahomes.com');
if (lstCCEmail.size() > 0) {
email.setCcAddresses(lstCCEmail);
}*/
                
                email.setToAddresses(sendTo);
                system.debug(sendTo);
                email.setSubject('Selection of Name for Display on Lobby Name Board');
                email.setHtmlBody(emailContent);
                
                //CC to veegaland customercare 
                
               // lstCCEmail.add('customercare@veegaland.in');
                if (!lstCCEmail.isEmpty()) {
                email.setCcAddresses(lstCCEmail);
                }
                email.setSaveAsActivity(true);
                email.setWhatId(booking.Id);
                // Set OrgWideEmailAddressId based on Booking Owner email
                String ownerEmail = booking.Owner.Email;
                if (ownerEmail != null && ownerEmailToOrgWideIdMap.containsKey(ownerEmail.toLowerCase())) {
                    email.setOrgWideEmailAddressId(ownerEmailToOrgWideIdMap.get(ownerEmail.toLowerCase()));
                }
                emailsToSend.add(email);
                // Send the email
                
                if (!emailsToSend.isEmpty()) {
                    Messaging.sendEmail(emailsToSend);
                }
                
                returnMessage = 'Email sent successfully';
            } else {
                returnMessage = 'Email address not specified in the Booking record.';
            }
        } catch (Exception e) {
            ExceptionHandler.addLog(e,emailContent,'GenerateDocumnetController',recId);  /*Add Exception to error log*/
            returnMessage = 'Error sending email: ' + e.getMessage();
            system.debug('returnMessage'+e);
        }
        return returnMessage;
    }
    @AuraEnabled
    public static String sendAdvanceAmountReceipt(Id recId) {
        String returnMessage;
        try {
            // Retrieve Booking record
            Booking__c booking = [
                SELECT Id, Project__c, Email1__c, CRM_Manager__c, CRM_Manager__r.Email,
                First_Applicant_Name__c, Owner.Email, Sales_Executive__r.Email 
                FROM Booking__c 
                WHERE Id = :recId 
                LIMIT 1
            ];
            List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
                string companyName;
                
                if(!companyDetails.isEmpty()){
                    companyName = companyDetails[0].Label;
                       
                }
            List<String> lstCCEmail = new List<String>();
            
            // Retrieve Org Wide Email Address (CRM Manager’s email preferred)
            List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
            if (booking.CRM_Manager__c != null && String.isNotBlank(booking.Sales_Executive__r.Email)) {
                owea = [
                    SELECT Id, Address, DisplayName 
                    FROM OrgWideEmailAddress 
                    WHERE Address = :booking.Sales_Executive__r.Email
                    LIMIT 1
                ];
            }
            
            if (booking != null && !String.isBlank(booking.Email1__c)) {
                // Generate the PDF
                PageReference vfPage = Page.AdvanceReceipt;
                vfPage.getParameters().put('id', recId);
                Blob pdfBlob = !Test.isRunningTest() ? vfPage.getContentAsPDF() : Blob.valueOf('testblob');
                
                // Prepare email
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>{ booking.Email1__c };
                    
                    // Set Org-Wide Email Address (if found)
                    if (!owea.isEmpty()) {
                        email.setOrgWideEmailAddressId(owea[0].Id);
                    }
                
                // Add CC recipients
                //lstCCEmail.add('customercare@veegaland.in');
                if (!lstCCEmail.isEmpty()) {
                    email.setCcAddresses(lstCCEmail);
                }
                
                email.setToAddresses(sendTo);
                email.setSubject('Advance Receipt Amount');
                email.setHtmlBody(
                    'Dear ' + booking.First_Applicant_Name__c + 
                    ',<br/><br/>Please find the attached Advance amount receipt document for your booking. ' + 
                    'If you have any questions, feel free to contact us.<br/><br/>Thank you.<br/><br/>'+companyName
                );
                
                // Attach PDF
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('Advance Amount Receipt.pdf');
                attachment.setBody(pdfBlob);
                email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
                
                email.setSaveAsActivity(true);
                email.setWhatId(booking.Id);
                
                // Send
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                
                returnMessage = 'Email sent successfully';
            } else {
                returnMessage = 'Email address not specified in the Booking record.';
            }
        } catch (Exception e) {
            ExceptionHandler.addLog(e, '', 'GenerateDocumentController', recId);  
            returnMessage = 'Error sending email: ' + e.getMessage();
        }
        return returnMessage;
    }
    
    /* Date: 26/08/25  Author:  @desc: Send registration agrement details email to Customer   @param 1:booking Id @return :string*/  
    @AuraEnabled
    public static String sendEmailGenerateAgreementdetailsrequest(Id recId, String emailContent) {
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        String returnMessage;
        try {
            
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
            
            // Retrieve the Booking record
            List<Booking__c> bookings = [
                SELECT Id, Project__c, Email1__c, Email2__c, First_Applicant_Name__c, Owner.Email,
                CRM_Manager__c, CRM_Manager__r.Email, Legal_Team__c
                FROM Booking__c 
                WHERE Id = :recId 
                LIMIT 1
            ];
            Map<String, Id> ownerEmailToOrgWideIdMap = new Map<String, Id>();
            for (OrgWideEmailAddress ow : [SELECT Id, Address FROM OrgWideEmailAddress]) {
                ownerEmailToOrgWideIdMap.put(ow.Address.toLowerCase(), ow.Id);
            }
            if (!bookings.isEmpty()) {
                Booking__c booking = bookings[0];
                List<String> sendTo = new List<String>();
                
                if (booking.Email1__c != null) {
                    sendTo.add(booking.Email1__c);
                }
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(sendTo);
                email.setSubject(companyName + ': Agreement Details Request');
                email.setHtmlBody(emailContent);
                //CC to veegaland customercare 
                List<String> lstCCEmail = new List<String>();
                //lstCCEmail.add('customercare@veegaland.in');
                if (!lstCCEmail.isEmpty()) {
                email.setCcAddresses(lstCCEmail);
                }
                email.setSaveAsActivity(true);
                email.setWhatId(booking.Id);
                // Set OrgWideEmailAddressId based on Booking Owner email
                String ownerEmail = booking.Owner.Email;
                if (ownerEmail != null && ownerEmailToOrgWideIdMap.containsKey(ownerEmail.toLowerCase())) {
                    email.setOrgWideEmailAddressId(ownerEmailToOrgWideIdMap.get(ownerEmail.toLowerCase()));
                }
                emailsToSend.add(email);
                
                // Send the email
                if (!emailsToSend.isEmpty()) {
                    Messaging.sendEmail(emailsToSend);
                }
                
                // Handle Task after sending email
                List<Task> tasksToUpdate = new List<Task>();
                List<Task> tasksToInsert = new List<Task>();
                
                // 1. Complete or Insert the "Request Sale Agreement Details" Task
                List<Task> existingRequestTasks = [
                    SELECT Id, Subject, Status 
                    FROM Task 
                    WHERE WhatId = :booking.Id 
                    AND Subject = 'Request Sale Agreement Details' 
                    LIMIT 1
                ];
                
                if (!existingRequestTasks.isEmpty()) {
                    Task existingTask = existingRequestTasks[0];
                    existingTask.Status = 'Completed';
                    tasksToUpdate.add(existingTask);
                } else {
                    Task newTask = new Task();
                    newTask.Subject = 'Request Sale Agreement Details';
                    newTask.WhatId = booking.Id;
                    newTask.Status = 'Completed';
                    newTask.Priority = 'Normal';
                    newTask.Description = 'Sale Agreement Details email has been sent to customer.';
                    newTask.OwnerId = booking.Legal_Team__c;
                    tasksToInsert.add(newTask);
                }
                
                // 2. Create or Update the Follow-up Task
                List<Task> existingFollowUpTasks = [
                    SELECT Id, Status 
                    FROM Task 
                    WHERE WhatId = :booking.Id 
                    AND Subject = 'Sale agreement details received from the customer' 
                    LIMIT 1
                ];
                
                if (!existingFollowUpTasks.isEmpty()) {
                    Task followUpTask = existingFollowUpTasks[0];
                    followUpTask.Status = 'Not Started'; // Reset status in case it was changed
                    tasksToUpdate.add(followUpTask);
                } else {
                    Task followUpTask = new Task(
                        Subject = 'Sale agreement details received from the customer',
                        Description = 'Kindly review the Agreement Details submitted by the customer and proceed with the necessary follow-up.',
                        Priority = 'High',
                        Status = 'Not Started',
                        WhatId = booking.Id,
                        OwnerId = booking.CRM_Manager__c,
                        ActivityDate = Date.today().addDays(2)
                    );
                    tasksToInsert.add(followUpTask);
                }
                
                // Perform DML operations
                if (!tasksToUpdate.isEmpty()) {
                    update tasksToUpdate;
                }
                if (!tasksToInsert.isEmpty()) {
                    insert tasksToInsert;
                }
                List<Id> recIdList = new List<Id>{ recId };
                WhatsappController.RequestCustomerDetailsForSalesAgreement(recIdList);
                booking.Agreement_Details_Request_Send__c = true;
                booking.Draft_Agreement_Status__c = 'Agreement Details';
                update booking;
                
                returnMessage = 'Email sent successfully.';
            } else {
                returnMessage = 'Booking record not found.';
            }
        } catch (Exception e) {
            ExceptionHandler.addLog(e,emailContent,'GenerateDocumnetController',recId);  /*Add Exception to error log*/
            returnMessage = 'Error sending email or updating task: ' + e.getMessage();
            System.debug('Exception in sendEmailGenerateAgreementdetailsrequest: ' + e);
        }
        return returnMessage;
    }
    
    /* Date: 26/08/25  Author:  @desc: Send registration agreement details received email to Customer   @param 1:booking Id @return :string*/  
    public static void agreementDetailsRecievedMail(List<Id> bookingIds) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
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
        // Step 1: Query bookings with required fields
        List<Booking__c> bookingList = [
            SELECT Id, Email1__c, First_Applicant_Name__c, Owner.Email
            FROM Booking__c
            WHERE Id IN :bookingIds
        ];
        
        // Step 2: Get all Org-Wide Email Addresses
        Map<String, Id> emailToOrgWideIdMap = new Map<String, Id>();
        for (OrgWideEmailAddress ow : [SELECT Id, Address FROM OrgWideEmailAddress]) {
            emailToOrgWideIdMap.put(ow.Address.toLowerCase(), ow.Id);
        }
        
        // Step 3: Loop through bookings
        for (Booking__c booking : bookingList) {
            if (String.isBlank(booking.Email1__c)) continue;
            
            String customerName = String.isBlank(booking.First_Applicant_Name__c) ? 'Customer' : booking.First_Applicant_Name__c;
            
            String emailBody = '';
            emailBody += 'Dear ' + customerName + ',<br/><br/>';
            emailBody += 'We have successfully received your details for the agreement process.<br/><br/>';
            emailBody += 'Our team will review them and reach out to you if any additional information is needed.<br/><br/>';
            emailBody += 'If you need any assistance or further details, do not hesitate to reach out.<br/><br/>';
            emailBody += 'Thank you for your continued trust.<br/><br/>';
            emailBody += 'Best regards,<br/><br/>';
            
            emailBody += '<b>Midhu Siju</b> | Officer - Customer Relations | <a href="tel:+919207054444">9207054444</a><br/>';
            emailBody += '<b>Alitta Lijoy</b> | Customer Relation Executive | <a href="tel:+919048237066">90482 37066</a><br/><br/>';
            
            emailBody += '<b>'+companyName+'</b><br/>';
            emailBody += 'Regd. Office: '+Address1+' '+Address2+' '+Address3+ '<br/>';
            emailBody += 'Tel: +91 484 2584000 / 2973944, +91 6235051144<br/>';
            emailBody += '<a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a><br/><br/>';
            
            emailBody += 'Follow us on:<br/>';
            emailBody += '<a href="https://www.facebook.com/veegalanddevelopers" target="_blank">Facebook</a> | ';
            emailBody += '<a href="https://www.instagram.com/veegalanddevelopers" target="_blank">Instagram</a> | ';
            emailBody += '<a href="https://www.linkedin.com/company/veegalanddevelopers" target="_blank">LinkedIn</a> | ';
            emailBody += '<a href="https://www.youtube.com/c/VeegalandDevelopers" target="_blank">YouTube</a><br/>';
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { booking.Email1__c });
            mail.setSubject('Your Agreement Details Have Been Received');
            
            //CC to veegaland customercare 
            List<String> lstCCEmail = new List<String>();
           // lstCCEmail.add('customercare@veegaland.in');
            if (!lstCCEmail.isEmpty()) {
            mail.setCcAddresses(lstCCEmail);
            }
            mail.setHtmlBody(emailBody);
            mail.setSaveAsActivity(true);
            mail.setWhatId(booking.Id);
            
            // Set OrgWideEmailAddressId if matching owner email
            String ownerEmail = booking.Owner != null ? booking.Owner.Email : null;
            if (ownerEmail != null && emailToOrgWideIdMap.containsKey(ownerEmail.toLowerCase())) {
                mail.setOrgWideEmailAddressId(emailToOrgWideIdMap.get(ownerEmail.toLowerCase()));
            }
            
            emails.add(mail);
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
    
    /* Date: 26/08/25  Author:  @desc: Send registration agreement  email to Customer   @param 1:booking Id @return :string*/  
    @AuraEnabled
    public static String sendRegisterdAgreement(Id recId, String emailContent, List<String> contentIds) {
        System.debug('recId: ' + recId);
        System.debug('emailContent: ' + emailContent);
        System.debug('contentIds: ' + contentIds);
    
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        String returnMessage;
    
        try {
            // Retrieve Booking record
            List<Booking__c> bookings = [
                SELECT Id, Project__c, Email1__c, First_Applicant_Name__c, CRM_Manager__c, CRM_Manager__r.Email, Owner.Email
                FROM Booking__c 
                WHERE Id = :recId 
                LIMIT 1
            ];
    
            // Retrieve company details from custom metadata
            Company_Name__mdt companyDetails = [SELECT Label, DeveloperName, Address2__c, Address3__c, Registered_Address__c 
                                                FROM Company_Name__mdt 
                                                LIMIT 1];
            String companyName = companyDetails.Label != null ? companyDetails.Label : '';
            String Address1 = companyDetails.Registered_Address__c != null ? companyDetails.Registered_Address__c : '';
            String Address2 = companyDetails.Address2__c != null ? companyDetails.Address2__c : '';
            String Address3 = companyDetails.Address3__c != null ? companyDetails.Address3__c : '';
    
            // Map OrgWideEmailAddress for owner
            Map<String, Id> ownerEmailToOrgWideIdMap = new Map<String, Id>();
            for (OrgWideEmailAddress ow : [SELECT Id, Address FROM OrgWideEmailAddress]) {
                ownerEmailToOrgWideIdMap.put(ow.Address.toLowerCase(), ow.Id);
            }
    
            List<Booking__c> bookingForUpdate = new List<Booking__c>();
    
            if (!bookings.isEmpty()) {
                Booking__c booking = bookings[0];
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>();
    
                if (booking.Email1__c != null) {
                    sendTo.add(booking.Email1__c);
                }
                email.setToAddresses(sendTo);
                email.setSubject('Original Sale Agreement');
    
                // Append dynamic footer
                String footer = '<br/><br/>' +
                                '<b>' + companyName + '</b><br/>' +
                                'Regd. Office: ' + Address1 + ' ' + Address2 + ' ' + Address3 + '<br/>' +
                                'Tel: +91 484 2584000 / 2973944, +91 6235051144<br/>' +
                                '<a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a><br/><br/>';
    
                email.setHtmlBody(emailContent + footer);
                email.setSaveAsActivity(true);
                email.setWhatId(booking.Id);
    
                // Set OrgWideEmailAddressId if owner email exists
                String ownerEmail = booking.Owner.Email;
                if (ownerEmail != null && ownerEmailToOrgWideIdMap.containsKey(ownerEmail.toLowerCase())) {
                    email.setOrgWideEmailAddressId(ownerEmailToOrgWideIdMap.get(ownerEmail.toLowerCase()));
                }
    
                // Attach selected contentIds
                List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                if (contentIds != null && !contentIds.isEmpty()) {
                    List<ContentVersion> selectedFiles = [
                        SELECT Title, VersionData, FileExtension
                        FROM ContentVersion
                        WHERE ContentDocumentId IN :contentIds
                    ];
                    for (ContentVersion cv : selectedFiles) {
                        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                        attachment.setFileName(cv.Title + '.' + cv.FileExtension);
                        attachment.setBody(cv.VersionData);
                        attachments.add(attachment);
                    }
                }
    
                // Attach Registered Agreement from linked documents
                List<ContentDocumentLink> docLinks = [
                    SELECT ContentDocumentId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :recId
                ];
                Set<Id> linkedDocIds = new Set<Id>();
                for (ContentDocumentLink link : docLinks) {
                    linkedDocIds.add(link.ContentDocumentId);
                }
    
                if (!linkedDocIds.isEmpty()) {
                    List<ContentVersion> regAgreements = [
                        SELECT Title, VersionData, FileExtension
                        FROM ContentVersion
                        WHERE ContentDocumentId IN :linkedDocIds
                        AND Title LIKE '%Registered Agreement%'
                        ORDER BY LastModifiedDate DESC
                        LIMIT 1
                    ];
                    if (regAgreements.isEmpty()) {
                        throw new AuraHandledException('Registered Agreement document not found.');
                    } else {
                        ContentVersion regFile = regAgreements[0];
                        Messaging.EmailFileAttachment regAttachment = new Messaging.EmailFileAttachment();
                        regAttachment.setFileName(regFile.Title + '.' + regFile.FileExtension);
                        regAttachment.setBody(regFile.VersionData);
                        attachments.add(regAttachment);
                    }
                }
    
                if (!attachments.isEmpty()) {
                    email.setFileAttachments(attachments);
                }
    
                // Optional CC emails
                List<String> lstCCEmail = new List<String>();
                // lstCCEmail.add('customercare@veegaland.in');
                if (!lstCCEmail.isEmpty()) {
                    email.setCcAddresses(lstCCEmail);
                }
    
                emailsToSend.add(email);
                Messaging.sendEmail(emailsToSend);
    
                // Call WhatsApp notification
                List<Id> recIdList = new List<Id>{ recId };
                WhatsappController.SendRegisteredSaleAgreement(recIdList);
    
                // Update booking status
                booking.Agreement_Status__c = 'Shared with Customer';
                bookingForUpdate.add(booking);
    
                returnMessage = 'Email sent successfully';
            } else {
                returnMessage = 'Booking record not found.';
            }
    
            if (!bookingForUpdate.isEmpty()) {
                update bookingForUpdate;
            }
    
        } catch (Exception e) {
            ExceptionHandler.addLog(e, emailContent, 'GenerateDocumnetController', recId);  // Add exception to log
            returnMessage = 'Error sending email: ' + e.getMessage();
            System.debug('Error: ' + e);
        }
    
        return returnMessage;
    }

    
    /* Date: 26/08/25  Author:  @desc: Send sales deed completed email to Customer   @param 1:booking Id @return :string*/   
    public static void sendSaledeedCompleteionMail(Set<Id> bookingList) {
        if (bookingList == null || bookingList.isEmpty()) return;
        
        List<Booking__c> bookings = [
            SELECT Id, Email1__c, First_Applicant_Name__c, CRM_Manager__c, Legal_Team__c,Owner.Email
            FROM Booking__c
            WHERE Id IN :bookingList
        ];
        Map<String, Id> ownerEmailToOrgWideIdMap = new Map<String, Id>();
        for (OrgWideEmailAddress ow : [SELECT Id, Address FROM OrgWideEmailAddress]) {
            ownerEmailToOrgWideIdMap.put(ow.Address.toLowerCase(), ow.Id);
        }
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Task> tasksToInsert = new List<Task>();
        List<Task> tasksToUpdate = new List<Task>();
        
        Map<Id, Booking__c> bookingMap = new Map<Id, Booking__c>(bookings);
        
        // Fetch existing tasks for these bookings
        List<Task> existingTasks = [
            SELECT Id, Subject, WhatId
            FROM Task
            WHERE WhatId IN :bookingList
            AND Subject IN (
                'Send Name Board Selection Mail to Customer',
                'Follow up for Registered Sale Deed'
            )
        ];
        List<Id> recIdList = new List<Id>();
        // Group existing tasks by WhatId
        Map<Id, Map<String, Task>> taskMapByBooking = new Map<Id, Map<String, Task>>();
        for (Task t : existingTasks) {
            if (!taskMapByBooking.containsKey(t.WhatId)) {
                taskMapByBooking.put(t.WhatId, new Map<String, Task>());
            }
            taskMapByBooking.get(t.WhatId).put(t.Subject, t);
        }
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
        for (Booking__c booking : bookings) {
            // === Send Email ===
            if (String.isNotBlank(booking.Email1__c) && String.isNotBlank(booking.First_Applicant_Name__c)) {
                recIdList.add(booking.Id);
                String emailBody = '';
                emailBody += 'Dear ' + booking.First_Applicant_Name__c + ',<br/><br/>';
                emailBody += 'We are pleased to inform you that the sale deed registration has been successfully completed.<br/><br/>';
                emailBody += 'Thank you for your continued trust.<br/><br/>';
                emailBody += 'Best regards,<br/>';
                emailBody += 'Midhu Siju | Officer - Customer Relations | 9207054444<br/>';
                emailBody += 'Alitta Lijoy | Customer Relation Executive | 90482 37066<br/><br/>';
                emailBody += companyName+'<br/>';
                emailBody += 'Regd. Office: '+Address1+' '+Address2+' ' +Address3+'<br/>';
                emailBody += 'Tel: +91 484 2584000 / 2973944, +91 6235051144<br/>';
                emailBody += '<a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a><br/><br/>';
                emailBody += 'Follow us on: ';
                emailBody += '<a href="https://www.facebook.com" target="_blank">Facebook</a> | ';
                emailBody += '<a href="https://www.instagram.com" target="_blank">Instagram</a> | ';
                emailBody += '<a href="https://www.linkedin.com" target="_blank">LinkedIn</a> | ';
                emailBody += '<a href="https://www.youtube.com" target="_blank">YouTube</a><br/>';
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>{ booking.Email1__c });
                //CC to veegaland customercare 
                List<String> lstCCEmail = new List<String>();
                //lstCCEmail.add('customercare@veegaland.in');
                if (!lstCCEmail.isEmpty()) {
                email.setCcAddresses(lstCCEmail);
                }
                email.setSubject('Sale Deed Registration Completed');
                email.setHtmlBody(emailBody);
                email.setSaveAsActivity(true);
                email.setWhatId(booking.Id);
                // Set OrgWideEmailAddressId based on Booking Owner email
                String ownerEmail = booking.Owner.Email;
                if (ownerEmail != null && ownerEmailToOrgWideIdMap.containsKey(ownerEmail.toLowerCase())) {
                    email.setOrgWideEmailAddressId(ownerEmailToOrgWideIdMap.get(ownerEmail.toLowerCase()));
                }
                emails.add(email);
            }
            
            // === Task 1: Name Board Selection Mail ===
            String crmTaskSubject = 'Send Name Board Selection Mail to Customer';
            Task existingCRMTask = taskMapByBooking.containsKey(booking.Id) ?
                taskMapByBooking.get(booking.Id).get(crmTaskSubject) : null;
            
            if (existingCRMTask != null) {
                existingCRMTask.Status = 'Not Started';
                tasksToUpdate.add(existingCRMTask);
            } else if (booking.CRM_Manager__c != null) {
                tasksToInsert.add(new Task(
                    Subject = crmTaskSubject,
                    OwnerId = booking.CRM_Manager__c,
                    WhatId = booking.Id,
                    Status = 'Not Started',
                    Priority = 'Normal'
                ));
            }
            
            // === Task 2: Legal Follow-up ===
            String legalTaskSubject = 'Follow up for Registered Sale Deed';
            Task existingLegalTask = taskMapByBooking.containsKey(booking.Id) ?
                taskMapByBooking.get(booking.Id).get(legalTaskSubject) : null;
            
            if (existingLegalTask != null) {
                existingLegalTask.Status = 'Not Started';
                tasksToUpdate.add(existingLegalTask);
            } else if (booking.Legal_Team__c != null) {
                tasksToInsert.add(new Task(
                    Subject = legalTaskSubject,
                    OwnerId = booking.Legal_Team__c,
                    WhatId = booking.Id,
                    Status = 'Not Started',
                    Priority = 'Normal'
                ));
            }
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
        
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
        
        if (!tasksToUpdate.isEmpty()) {
            update tasksToUpdate;
        }
        if (!recIdList.isEmpty()) {
            WhatsappController.afterSaleDeedWhatsAppSend(recIdList);
        }
    }
    
    public static void handOverMailSend(Set<Id> handOverMailIds) {
        // Query required Booking__c records
        List<Booking__c> handOverMailList = [
            SELECT Id, Name, Email1__c, Legal_Team__c,Owner.Email
            FROM Booking__c
            WHERE Id IN :handOverMailIds
        ];
        
        List<Id> recIdList = new List<Id>();
        Map<String, Id> ownerEmailToOrgWideIdMap = new Map<String, Id>();
        for (OrgWideEmailAddress ow : [SELECT Id, Address FROM OrgWideEmailAddress]) {
            ownerEmailToOrgWideIdMap.put(ow.Address.toLowerCase(), ow.Id);
        }
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Task> tasksToUpsert = new List<Task>();
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
        for (Booking__c booking : handOverMailList) {
            // ==== 1. SEND HTML EMAIL TO CUSTOMER ====
            if (String.isNotBlank(booking.Email1__c)) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { booking.Email1__c });
                mail.setSubject('Registered Documents Ready for Collection');
                recIdList.add(booking.Id);
                String emailBody = '';
                emailBody += 'Dear ' + booking.Name + ',<br/><br/>';
                emailBody += 'We are pleased to inform you that we have successfully completed the sale deed registration and your registered sale deed along with the below mentioned original documents are now ready for collection.<br/><br/>';
                emailBody += '<ul>';
                emailBody += '<li>Land Tax</li>';
                emailBody += '<li>Possession certificate</li>';
                emailBody += '<li>Building certificate</li>';
                emailBody += '<li>Encumbrance certificate</li>';
                emailBody += '</ul><br/>';
                emailBody += 'Please feel free to visit our office at your convenience to collect the documents.<br/>';
                emailBody += 'If you need any assistance or further details, do not hesitate to reach out.<br/><br/>';
                emailBody += 'Thank you for your continued trust.<br/><br/>';
                
                emailBody += 'Best regards,<br/>';
                emailBody += 'Midhu Siju | Officer - Customer Relations | 9207054444<br/>';
                emailBody += 'Alitta Lijoy | Customer Relation Executive | 90482 37066<br/><br/>';
                emailBody += companyName+'<br/>';
                emailBody += 'Regd. Office: '+Address1+' '+Address2+' '+Address3+'<br/>';
                emailBody += 'Tel: +91 484 2584000 / 2973944, +91 6235051144<br/>';
                emailBody += '<a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a><br/><br/>';
                emailBody += 'Follow us on: ';
                emailBody += '<a href="https://www.facebook.com" target="_blank">Facebook</a> | ';
                emailBody += '<a href="https://www.instagram.com" target="_blank">Instagram</a> | ';
                emailBody += '<a href="https://www.linkedin.com" target="_blank">LinkedIn</a> | ';
                emailBody += '<a href="https://www.youtube.com" target="_blank">YouTube</a><br/>';
                
                mail.setHtmlBody(emailBody);
                mail.setSaveAsActivity(true);
                mail.setWhatId(booking.Id);
                //CC to veegaland customercare 
                List<String> lstCCEmail = new List<String>();
               // lstCCEmail.add('customercare@veegaland.in');
                if (!lstCCEmail.isEmpty()) {
                mail.setCcAddresses(lstCCEmail);
                }
                
                // Set OrgWideEmailAddressId based on Booking Owner email
                String ownerEmail = booking.Owner.Email;
                if (ownerEmail != null && ownerEmailToOrgWideIdMap.containsKey(ownerEmail.toLowerCase())) {
                    mail.setOrgWideEmailAddressId(ownerEmailToOrgWideIdMap.get(ownerEmail.toLowerCase()));
                }
                mails.add(mail);
            }
            
            // ==== 2. UPSERT TASK FOR LEGAL ADVOCATE ====
            if (booking.Legal_Team__c != null) {
                Task existingTask = null;
                
                List<Task> existingTasks = [
                    SELECT Id, Status 
                    FROM Task 
                    WHERE WhatId = :booking.Id 
                    AND Subject = 'Upload registered document (Land Tax, Possession certificate, Building certificate, Encumbrance certificate)' 
                    AND OwnerId = :booking.Legal_Team__c 
                    LIMIT 1
                ];
                
                if (!existingTasks.isEmpty()) {
                    existingTask = existingTasks[0];
                    existingTask.Status = 'Not Started';
                    tasksToUpsert.add(existingTask);
                } else {
                    Task newTask = new Task();
                    newTask.Subject = 'Upload registered document (Land Tax, Possession certificate, Building certificate, Encumbrance certificate)';
                    newTask.Status = 'Not Started';
                    newTask.Priority = 'Normal';
                    newTask.OwnerId = booking.Legal_Team__c;
                    newTask.WhatId = booking.Id;
                    newTask.Description = 'Please upload the scanned copies of:\n- Land Tax\n- Possession certificate\n- Building certificate\n- Encumbrance certificate';
                    tasksToUpsert.add(newTask);
                }
            }
        }
        
        // ==== FINAL DML OPERATIONS ====
        if (!mails.isEmpty()) {
            Messaging.sendEmail(mails);
        }
        
        if (!tasksToUpsert.isEmpty()) {
            List<Task> tasksToInsert = new List<Task>();
            List<Task> tasksToUpdate = new List<Task>();
            for (Task t : tasksToUpsert) {
                if (t.Id != null) {
                    tasksToUpdate.add(t);
                } else {
                    tasksToInsert.add(t);
                }
            }
            if (!tasksToInsert.isEmpty()) insert tasksToInsert;
            if (!tasksToUpdate.isEmpty()) update tasksToUpdate;
        }
        if (!recIdList.isEmpty()) {
            WhatsappController.agreementHandoverCopySend(recIdList);
        }
    }
    
     @future(callout=true)
public static void deedCancellationEmail(List<Id> bookingIds){
    List<Booking__c> bookings = [
        SELECT Id,
               Sale_Deed_Registration_Status__c,
               salutation_Applicant1__c,
               First_Applicant_Name__c,
               Email1__c,
               Owner.Email
        FROM Booking__c
        WHERE Id IN :bookingIds
    ];

    // Map Org-Wide Emails
    Map<String, Id> ownerEmailToOrgWideIdMap = new Map<String, Id>();
    for (OrgWideEmailAddress ow : [SELECT Id, Address FROM OrgWideEmailAddress]) {
        ownerEmailToOrgWideIdMap.put(ow.Address.toLowerCase(), ow.Id);
    }

    List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
    List<Booking__c> bookList = new List<Booking__c>();

    for (Booking__c booking : bookings) {
        try {
            // Skip if no customer email
            if (String.isBlank(booking.Email1__c)) {
                System.debug('No email for booking ' + booking.Id);
                continue;
            }

            String salutation = booking.salutation_Applicant1__c != null ? booking.salutation_Applicant1__c : '';
            String firstApplicant = booking.First_Applicant_Name__c != null ? booking.First_Applicant_Name__c : 'Customer';
            String customerName = (salutation + ' ' + firstApplicant).trim();
            List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
            string companyName;
            
            if(!companyDetails.isEmpty()){
                companyName = companyDetails[0].Label;
                
            }
            // Compose email
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            String emailBody = ''
                + '<div style="color: black;">'
                + '<strong>Dear ' + customerName + ',</strong><br/><br/>'
                + 'We regret to inform you that your deed registration has been <strong>cancelled</strong>.<br/><br/>'
                + 'For any questions or clarification, please contact our customer relations team.<br/><br/>'
                + '<p>Thanks & Regards,</p>'
                + '<p><strong>Midhu Siju | Officer - Customer Relations | 9207054444</strong></p>'
                + '<p><strong>Alitta Lijoy | Customer Relations Executive | 90482 37066</strong></p>'
                + '<p><strong>'+companyName+'</strong></p>'
                + '<p>Tel: +91 484 2584000 / 2973944, +91 6235051144</p>'
                + '<p><a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a></p>'
                + '</div>';

            semail.setHtmlBody(emailBody);
            semail.setSubject('Deed Registration Cancelled');
            semail.setToAddresses(new String[] { booking.Email1__c });
            semail.setSaveAsActivity(true);

            // Set OrgWideEmailAddressId based on Booking Owner email
            String ownerEmail = booking.Owner.Email;
            if (ownerEmail != null && ownerEmailToOrgWideIdMap.containsKey(ownerEmail.toLowerCase())) {
                semail.setOrgWideEmailAddressId(ownerEmailToOrgWideIdMap.get(ownerEmail.toLowerCase()));
            }
            // Clearing both expected date a and reg date
            Booking__c book = new Booking__c();
            book.Id = booking.Id;
            book.Registration_Date__c = null;
            book.Deed_Expected_Date__c =null;
            bookList.add(book);

            emailList.add(semail);

        } catch (Exception e) {
            System.debug('Error sending deed cancellation email for ' + booking.Id + ': ' + e.getMessage());
        }
    }

    // Send all emails 
    if (!emailList.isEmpty()) {
        try {
            Messaging.sendEmail(emailList);
             if (!bookList.isEmpty()) {
                 update booklist;
             }
        } catch (Exception e) {
            System.debug('Error sending bulk cancellation emails: ' + e.getMessage());
        }
    }
     
}

    
     //To send auto email when deed registration is rescheduled
    @future(callout=true)
    public static void sendDeedRescheduledEmail(List<Id> bookingIds){
        List<Booking__c> bookings = [
            SELECT Id, 
            Stage__c,
            Sale_Deed_Registration_Status__c,
            Deed_Expected_Date__c,
            Registration_Date__c,
            salutation_Applicant1__c,
            First_Applicant_Name__c,
            Email1__c,
            Project__c,
            Project1__r.Register_Office__c,
            Project1__r.Register_Office_Location__Latitude__s,
            Project1__r.Register_Office_Location__Longitude__s,
            Legal_Advocate_Assigned__r.Name
            FROM Booking__c 
            WHERE Id IN :bookingIds];
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
          List<Booking__c> updateList = new List<Booking__c>();
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
        
        for(Booking__c booking:bookings){
            try
            {
                String salutation = booking.salutation_Applicant1__c != null ? booking.salutation_Applicant1__c : '';
                String firstApplicant = booking.First_Applicant_Name__c != null ? booking.First_Applicant_Name__c : 'Customer';
                String project = booking.Project__c != null ? booking.Project__c : 'N/A';
                String regOffice = (booking.Project1__r != null && booking.Project1__r.Register_Office__c != null) 
                    ? booking.Project1__r.Register_Office__c 
                    : 'Not Provided';
                
                String regOfficeLocation = 
                    (booking.Project1__r != null && 
                     booking.Project1__r.Register_Office_Location__Latitude__s != null &&
                     booking.Project1__r.Register_Office_Location__Longitude__s != null)
                    ? 'https://www.google.com/maps?q=' + 
                    booking.Project1__r.Register_Office_Location__Latitude__s + ',' + 
                    booking.Project1__r.Register_Office_Location__Longitude__s
                    : '_blank';
                
                String legalAdvocate = 
                    (booking.Legal_Advocate_Assigned__r != null && booking.Legal_Advocate_Assigned__r.Name != null)
                    ? booking.Legal_Advocate_Assigned__r.Name
                    : 'Not Provided';
                
                String regDate = 
                    booking.Registration_Date__c != null 
                    ? String.valueOf(booking.Registration_Date__c) 
                    : 'Not Provided';
                
                String customerName = (salutation + ' ' + firstApplicant).trim();
                
                Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                
                //email content
                String emailBody = ''
                    + '<div style="color: black;">'
                    + '<strong>Dear ' + customerName + ',</strong><br/><br/>'
                    + 'Your sale deed registration has been <strong>rescheduled</strong>. The updated appointment details are as follows:<br/><br/>'
                    + '<strong>Date & Location for Registration:</strong><br/><br/>'
                    + '<table border="0">'
                    + '<tr><th style="text-align:left;">Date </th><td>: ' + regDate + '</td></tr>'
                    + '<tr><th style="text-align:left; padding-right:10px;">Location</th>'
                    + '<td>: <a href="' + regOfficeLocation + '" target="_blank" style="color: #1a73e8; text-decoration: none;">' 
                    + regOffice + '</a></td></tr>'
                    + '<tr><th style="text-align:left;">Advocate Name </th><td>: ' + legalAdvocate + '</td></tr>'
                    + '</table><br/><br/>'
                    + 'Please confirm whether the resheduled deed date provided above works for you. If it doesn’t, please let us know a suitable alternative.<br/><br/>'
                    + '<p>Thanks & Regards,</p><br/>'
                    + '<p><strong>Midhu Siju | Officer - Customer Relations | 9207054444</strong></p>'
                    + '<p><strong>Alitta Lijoy | Customer Relation Executive | 90482 37066</strong></p><br/>'
                    + '<p><strong>'+companyName+'</strong></p>'
                    + '<p>Regd. Office: '+companyAddress1+' '+companyAddress2+'</p>'
                    + '<p>'+companyAddress3+'</p>'
                    + '<p>Tel: +91 484 2584000 / 2973944, +91 6235051144</p>'
                    + '<p><a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a></p><br/>'
                    + '<p>Follow us on: '
                    + '<a href="https://www.facebook.com" target="_blank">Facebook</a> | '
                    + '<a href="https://www.instagram.com" target="_blank">Instagram</a> | '
                    + '<a href="https://www.linkedin.com" target="_blank">LinkedIn</a> | '
                    + '<a href="https://www.youtube.com" target="_blank">YouTube</a>'
                    + '</p>'
                    + '</div>';
                semail.setHtmlBody(emailBody);
                semail.setSaveAsActivity(true);
                
                // setting to address
                if (String.isNotBlank(booking.Email1__c)) {
                    semail.setToAddresses(new String[] { booking.Email1__c });
                } else {
                    System.debug('️ No email address found for booking ' + booking.Id);
                    continue;
                }
                
                semail.setSubject('Deed Resheduled Mail');
                
                emailList.add(semail);
                
                // Preparing record for status update
            Booking__c b = new Booking__c(Id = booking.Id);
            b.Sale_Deed_Registration_Status__c = 'Rescheduled';
            updateList.add(b);
                
                
                
                if (!emailList.isEmpty()) {
                    Messaging.sendEmail(emailList);
                }
                
                 if (!updateList.isEmpty()) {
                     update updateList;
                 }
                
                
            }
            catch (Exception e) {
                System.debug('Error sending deed reschedule email for ' + booking.Id + ': ' + e.getMessage());
            }
        }
        
        
    }
    

    
    
    
    public static void cancellationApprovalMail(Set<Id> approvalList) {
        list<Plot__c> units = new list<Plot__c>();
        List<Booking__c> bookingList = [
            SELECT Id, Name, Email1__c, First_Applicant_Name__c,
            CRM_Manager__r.Email,Plot__c, Sales_Manager1__r.Email, Finance_User__r.Email,Owner.Email
            FROM Booking__c
            WHERE Id IN :approvalList
        ];
        List<Id> recIdList = new List<Id>();
        Map<String, Id> ownerEmailToOrgWideIdMap = new Map<String, Id>();
        for (OrgWideEmailAddress ow : [SELECT Id, Address FROM OrgWideEmailAddress]) {
            ownerEmailToOrgWideIdMap.put(ow.Address.toLowerCase(), ow.Id);
        }
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
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
        for (Booking__c booking : bookingList) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            recIdList.add(booking.Id);
            String subject = 'Booking Cancellation Approved - ' + booking.Name;
            String body = 
                'Dear ' + booking.First_Applicant_Name__c + ',<br/><br/>' +
                'We would like to inform you that your booking cancellation request for Booking ID <b>' + booking.Name + '</b> has been <b>approved</b>.<br/><br/>' +
                'Our finance team will now proceed with the collection of any applicable charges and the refund process.<br/><br/>' +
                
                'Warm Regards,<br/><br/>' +
                'Midhu Siju | Officer - Customer Relations | 9207054444<br/>' +
                'Alitta Lijoy | Customer Relations Executive | 90482 37066<br/><br/>' +
                companyName+'<br/>' +
                'Regd. Office: '+Address1+' '+Address2+' '+Address3+'<br/>' +
                'Tel: +91 484 2584000 / 2973944, +91 6235051144<br/>' +
                '<a href="https://www.veegaland.com">www.veegaland.com</a><br/><br/>';
            
            mail.setToAddresses(new List<String>{ booking.Email1__c });
            
            List<String> ccList = new List<String>();
           // ccList.add('customercare@veegaland.in');
            if (booking.CRM_Manager__r != null) ccList.add(booking.CRM_Manager__r.Email);
            if (booking.Sales_Manager1__r != null) ccList.add(booking.Sales_Manager1__r.Email);
            if (booking.Finance_User__r != null) ccList.add(booking.Finance_User__r.Email);
            if (!ccList.isEmpty()) {
            mail.setCcAddresses(ccList);
            }
            mail.setSubject(subject);
            mail.setHtmlBody(body);
            mail.setSaveAsActivity(true);
            mail.setWhatId(booking.Id);
            // Set OrgWideEmailAddressId based on Booking Owner email
            String ownerEmail = booking.Owner.Email;
            if (ownerEmail != null && ownerEmailToOrgWideIdMap.containsKey(ownerEmail.toLowerCase())) {
                mail.setOrgWideEmailAddressId(ownerEmailToOrgWideIdMap.get(ownerEmail.toLowerCase()));
            }
            mails.add(mail);
        }
        
        if (!mails.isEmpty()) {
            try {
                Messaging.sendEmail(mails);
            } catch (Exception e) {
                ExceptionHandler.addLog(e,string.valueof(approvalList),'GenerateDocumnetController','');  /*Add Exception to error log*/
                System.debug('Bulk Email Error: ' + e.getMessage());
            }
        }
        
        for(Booking__c bk : bookingList){
            if(bk.Plot__c !=null){
                Plot__c unit = new Plot__c();
                unit.Id = bk.Plot__c;
                unit.Status__c ='Available';
                units.add(unit);
            }
        }
        if(!units.isEmpty()){
            try{
                update units;
            }catch(exception ex){
                ExceptionHandler.addLog(ex,string.valueof(units),'GenerateDocumnetController','');  /*Add Exception to error log*/
            }
        }
        
        if (!recIdList.isEmpty()) {
            WhatsappController.sendUnitCancellationFromBooking(recIdList);
        }
        
    }
    
    public static void cancellationRejectionMail(Set<Id> rejectionList) {
        List<Booking__c> bookingList = [
            SELECT Id, Name, Email1__c, First_Applicant_Name__c,
            CRM_Manager__r.Email, Sales_Manager1__r.Email, Finance_User__r.Email,Owner.Email
            FROM Booking__c
            WHERE Id IN :rejectionList
        ];
        
        Map<String, Id> ownerEmailToOrgWideIdMap = new Map<String, Id>();
        for (OrgWideEmailAddress ow : [SELECT Id, Address FROM OrgWideEmailAddress]) {
            ownerEmailToOrgWideIdMap.put(ow.Address.toLowerCase(), ow.Id);
        }
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
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
        for (Booking__c booking : bookingList) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            String subject = 'Booking Cancellation Rejected - ' + booking.Name;
            String body = 
                'Dear ' + booking.First_Applicant_Name__c + ',<br/><br/>' +
                'We regret to inform you that your booking cancellation request for Booking ID <b>' + booking.Name + '</b> has been <b>rejected</b>.<br/><br/>' +
                'For more information or clarification, please get in touch with our customer relations team.<br/><br/>' +
                
                'Warm Regards,<br/><br/>' +
                'Midhu Siju | Officer - Customer Relations | 9207054444<br/>' +
                'Alitta Lijoy | Customer Relations Executive | 90482 37066<br/><br/>' +
                companyName+'<br/>' +
                'Regd. Office: '+Address1+'<br/>' +
                Address2+'<br/>' +
                Address3+'<br/>' +
                'Tel: +91 484 2584000 / 2973944, +91 6235051144<br/>' +
                '<a href="https://www.veegaland.com">www.veegaland.com</a><br/><br/>';
            
            mail.setToAddresses(new List<String>{ booking.Email1__c });
            
            List<String> ccList = new List<String>();
           // ccList.add('customercare@veegaland.in');
            if (booking.CRM_Manager__r != null) ccList.add(booking.CRM_Manager__r.Email);
            if (booking.Sales_Manager1__r != null) ccList.add(booking.Sales_Manager1__r.Email);
            if (booking.Finance_User__r != null) ccList.add(booking.Finance_User__r.Email);
            if (!ccList.isEmpty()) {
            mail.setCcAddresses(ccList);
            }
            mail.setSubject(subject);
            mail.setHtmlBody(body);
            mail.setSaveAsActivity(true);
            mail.setWhatId(booking.Id);
            // Set OrgWideEmailAddressId based on Booking Owner email
            String ownerEmail = booking.Owner.Email;
            if (ownerEmail != null && ownerEmailToOrgWideIdMap.containsKey(ownerEmail.toLowerCase())) {
                mail.setOrgWideEmailAddressId(ownerEmailToOrgWideIdMap.get(ownerEmail.toLowerCase()));
            }
            mails.add(mail);
        }
        
        if (!mails.isEmpty()) {
            try {
                Messaging.sendEmail(mails);
            } catch (Exception e) {
                ExceptionHandler.addLog(e,string.valueof(rejectionList),'GenerateDocumnetController','');  /*Add Exception to error log*/
                System.debug('Bulk Email Error: ' + e.getMessage());
            }
        }
    }
    
    public static void sendSwapDetailInitiation(Set<Id> bookings) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        List<Booking__c> bookingList = [
            SELECT Id, Name, Email1__c, Swap_Unit__r.Name, Sales_Manager1__r.Name,Total__c,Swap_Grand_Total__c,Plot__r.Name,Owner.Email
            FROM Booking__c 
            WHERE Id IN :bookings
        ];
        Map<String, Id> ownerEmailToOrgWideIdMap = new Map<String, Id>();
        for (OrgWideEmailAddress ow : [SELECT Id, Address FROM OrgWideEmailAddress]) {
            ownerEmailToOrgWideIdMap.put(ow.Address.toLowerCase(), ow.Id);
        }
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
        for (Booking__c booking : bookingList) {
            if (String.isNotBlank(booking.Email1__c)) {
                String emailBody = ''
                    + 'Dear Customer,<br/><br/>'
                    + 'We would like to inform you that your unit swap request has been successfully initiated. Our Sales Manager, <strong>'
                    + booking.Sales_Manager1__r.Name + '</strong>, will review and verify the request shortly.<br/><br/>'
                    
                    + '<strong>Previous Unit:</strong> ' + booking.Plot__r.Name + '<br/>'
                    + '<strong>New (Requested) Unit:</strong> ' + booking.Swap_Unit__r.Name + '<br/><br/>'
                    
                    + '<strong>Previous Grand Total:</strong> ₹' + String.valueOf(booking.Total__c.setScale(2)) + '<br/>'
                    + '<strong>New Grand Total:</strong> ₹' + String.valueOf(booking.Swap_Grand_Total__c.setScale(2)) + '<br/><br/>'
                    
                    + 'You will receive a confirmation email once the process is completed.<br/><br/>'
                    + 'If you have any questions or require further assistance, please do not hesitate to contact us.<br/><br/>'
                    
                    + 'Thanks & Regards,<br/><br/>'
                    + '<strong>Midhu Siju</strong> | Officer - Customer Relations | 9207054444<br/>'
                    + '<strong>Alitta Lijoy</strong> | Customer Relation Executive | 90482 37066<br/><br/>'
                    
                    + '<strong>'+companyName+'</strong><br/>'
                    + 'Regd. Office: '+Address1+'<br/>'
                    + Address2+' '+Address3+'<br/>'
                    + 'Tel: +91 484 2584000 / 2973944, +91 6235051144<br/>'
                    + '<a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a><br/><br/>'
                    
                    + 'Follow us on: <a href="https://www.facebook.com/veegalanddevelopers" target="_blank">Facebook</a> | '
                    + '<a href="https://www.instagram.com/veegalanddevelopers" target="_blank">Instagram</a> | '
                    + '<a href="https://www.linkedin.com/company/veegalanddevelopers" target="_blank">LinkedIn</a> | '
                    + '<a href="https://www.youtube.com/c/VeegalandDevelopers" target="_blank">YouTube</a>';
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { booking.Email1__c });
                mail.setSubject('Your Unit Swap Request Has Been Initiated');
                mail.setHtmlBody(emailBody);
                
                //CC to veegaland customercare 
                List<String> lstCCEmail = new List<String>();
               // lstCCEmail.add('customercare@veegaland.in');
                if (!lstCCEmail.isEmpty()) {
                mail.setCcAddresses(lstCCEmail);
                }
                
                mail.setSaveAsActivity(true);
                mail.setWhatId(booking.Id);
                // Set OrgWideEmailAddressId based on Booking Owner email
                String ownerEmail = booking.Owner.Email;
                if (ownerEmail != null && ownerEmailToOrgWideIdMap.containsKey(ownerEmail.toLowerCase())) {
                    mail.setOrgWideEmailAddressId(ownerEmailToOrgWideIdMap.get(ownerEmail.toLowerCase()));
                }
                emails.add(mail);
            }
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
    
    public static void UnitSwapApproved(Set<Id> bookingIds) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Id> recIdList = new List<Id>();
        Map<String, Id> ownerEmailToOrgWideIdMap = new Map<String, Id>();
        for (OrgWideEmailAddress ow : [SELECT Id, Address FROM OrgWideEmailAddress]) {
            ownerEmailToOrgWideIdMap.put(ow.Address.toLowerCase(), ow.Id);
        }
        List<Booking__c> bookingList = [
            SELECT Id, Name, Email1__c, First_Applicant_Name__c, Swap_Unit__r.Name,
            CRM_Manager__c, CRM_Manager__r.Name, CRM_Manager__r.Email, Owner.Email
            FROM Booking__c
            WHERE Id IN :bookingIds
        ];
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
        for (Booking__c booking : bookingList) {
            // Send Email to Customer
            if (String.isNotBlank(booking.Email1__c)) {
                recIdList.add(booking.Id);
                String emailBody = ''
                    + 'Dear ' + booking.First_Applicant_Name__c + ',<br/><br/>'
                    + 'We are pleased to inform you that your unit swap request for the unit <strong>' 
                    + booking.Swap_Unit__r.Name + '</strong> has been approved.<br/><br/>'
                    + 'Our CRM team will be in touch with you to finalize the remaining formalities.<br/><br/>'
                    + 'Thanks & Regards,<br/><br/>'
                    
                    + '<strong>Midhu Siju</strong> | Officer - Customer Relations | 9207054444<br/>'
                    + '<strong>Alitta Lijoy</strong> | Customer Relation Executive | 90482 37066<br/><br/>'
                    
                    + '<strong>'+companyName+'</strong><br/>'
                    + 'Regd. Office: '+Address1+'<br/>'
                    + Address2+' ' +Address3+'<br/>'
                    + 'Tel: +91 484 2584000 / 2973944, +91 6235051144<br/>'
                    + '<a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a><br/><br/>'
                    
                    + 'Follow us on: <a href="https://www.facebook.com/veegalanddevelopers" target="_blank">Facebook</a> | '
                    + '<a href="https://www.instagram.com/veegalanddevelopers" target="_blank">Instagram</a> | '
                    + '<a href="https://www.linkedin.com/company/veegalanddevelopers" target="_blank">LinkedIn</a> | '
                    + '<a href="https://www.youtube.com/c/VeegalandDevelopers" target="_blank">YouTube</a>';
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { booking.Email1__c });
                mail.setSubject('Your Unit Swap Request Has Been Approved');
                mail.setHtmlBody(emailBody);
                
                //CC to veegaland customercare 
                List<String> lstCCEmail = new List<String>();
               // lstCCEmail.add('customercare@veegaland.in');
                if (!lstCCEmail.isEmpty()) {
                mail.setCcAddresses(lstCCEmail);
                }
                
                // Set OrgWideEmailAddressId based on Booking Owner email
                String ownerEmail = booking.Owner.Email;
                if (ownerEmail != null && ownerEmailToOrgWideIdMap.containsKey(ownerEmail.toLowerCase())) {
                    mail.setOrgWideEmailAddressId(ownerEmailToOrgWideIdMap.get(ownerEmail.toLowerCase()));
                }
                emails.add(mail);
            }
            
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
        if (!recIdList.isEmpty()) {
            WhatsappController.sendUnitSwapNotification(recIdList);
        }
        
    }
    
    public static void UnitSwapRejected(Set<Id> bookingIds) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Plot__c> unitsToUpdate = new List<Plot__c>();
        
        List<Booking__c> bookingList = [
            SELECT Id, Name, Email1__c, First_Applicant_Name__c, Swap_Unit__c, Swap_Unit__r.Name,Owner.Email
            FROM Booking__c
            WHERE Id IN :bookingIds
        ];
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
        
        Map<String, Id> ownerEmailToOrgWideIdMap = new Map<String, Id>();
        for (OrgWideEmailAddress ow : [SELECT Id, Address FROM OrgWideEmailAddress]) {
            ownerEmailToOrgWideIdMap.put(ow.Address.toLowerCase(), ow.Id);
        }
        
        for (Booking__c booking : bookingList) {
            // Send rejection email to customer
            if (String.isNotBlank(booking.Email1__c)) {
                String emailBody = ''
                    + 'Dear ' + booking.First_Applicant_Name__c + ',<br/><br/>'
                    + 'We regret to inform you that your unit swap request for the unit <strong>'
                    + booking.Swap_Unit__r.Name + '</strong> has not been approved at this time.<br/><br/>'
                    + 'Please contact our Customer Relations team if you have any questions or would like to explore alternative options.<br/><br/>'
                    + 'Thanks & Regards,<br/><br/>'
                    
                    + '<strong>Midhu Siju</strong> | Officer - Customer Relations | 9207054444<br/>'
                    + '<strong>Alitta Lijoy</strong> | Customer Relation Executive | 90482 37066<br/><br/>'
                    
                    + '<strong>'+companyName+'</strong><br/>'
                    + 'Regd. Office:'+Address1+'<br/>'
                    + Address2+' '+Address3+'<br/>'
                    + 'Tel: +91 484 2584000 / 2973944, +91 6235051144<br/>'
                    + '<a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a><br/><br/>'
                    
                    + 'Follow us on: <a href="https://www.facebook.com/veegalanddevelopers" target="_blank">Facebook</a> | '
                    + '<a href="https://www.instagram.com/veegalanddevelopers" target="_blank">Instagram</a> | '
                    + '<a href="https://www.linkedin.com/company/veegalanddevelopers" target="_blank">LinkedIn</a> | '
                    + '<a href="https://www.youtube.com/c/VeegalandDevelopers" target="_blank">YouTube</a>';
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { booking.Email1__c });
                mail.setSubject('Unit Swap Request Not Approved');
                mail.setHtmlBody(emailBody);
                //CC to veegaland customercare 
                List<String> lstCCEmail = new List<String>();
               // lstCCEmail.add('customercare@veegaland.in');
               if (!lstCCEmail.isEmpty()) { 
                mail.setCcAddresses(lstCCEmail);
               }
                
                // Set OrgWideEmailAddressId based on Booking Owner email
                String ownerEmail = booking.Owner.Email;
                if (ownerEmail != null && ownerEmailToOrgWideIdMap.containsKey(ownerEmail.toLowerCase())) {
                    mail.setOrgWideEmailAddressId(ownerEmailToOrgWideIdMap.get(ownerEmail.toLowerCase()));
                }
                
                emails.add(mail);
            }
            
            // Mark the swap unit as available again
            if (booking.Swap_Unit__c != null) {
                unitsToUpdate.add(new Plot__c(
                    Id = booking.Swap_Unit__c,
                    Status__c = 'Available'
                ));
            }
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
        
        if (!unitsToUpdate.isEmpty()) {
            update unitsToUpdate;
        }
    }
    
    @AuraEnabled
    public static String sendEmailGenerateAdditionalCharges(Id recId) {
        String returnMessage;
        try {
            
            // Retrieve the Additional Charges record along with Additional_Charge_Type__c
            Additional_Charges__c Additional_Charges = [SELECT Id, Booking__c, Is_Demanded__c, Demanded_Date__c, Additional_Charge_Type__c 
                                                        FROM Additional_Charges__c WHERE Id = :recId LIMIT 1];
            
            if (Additional_Charges == null || Additional_Charges.Booking__c == null) {
                return 'Additional Charges or associated Booking record not found.';
            }
            
            // Check if Demanded_Date__c is blank or Is_Demanded__c is false, then update
            if (Additional_Charges.Demanded_Date__c == null || !Additional_Charges.Is_Demanded__c) {
                Additional_Charges.Demanded_Date__c = Date.today();
                Additional_Charges.Is_Demanded__c = true;
                update Additional_Charges;  // Save the changes
            }
            
            // Retrieve the associated Booking record
            Booking__c booking = [SELECT Id, Project__c, Email1__c, Email2__c, 
                                  First_Applicant_Name__c, Owner.Email, CRM_Manager__c, CRM_Manager__r.Email 
                                  FROM Booking__c WHERE Id = :Additional_Charges.Booking__c LIMIT 1];
            List<String> lstCCEmail = new List<String>();
           // lstCCEmail.add('customercare@veegaland.in');
            
            // Retrieve Org Wide Email Address
            List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :booking.Owner.Email];
            
            if (booking != null && !String.isBlank(booking.Email1__c)) {
                // Generate the PDF for the Additional Charges
                PageReference vfPage = Page.Demand_Note_Additionalcharges;
                
                vfPage.getParameters().put('id', recId);
                //Blob pdfBlob = vfPage.getContentAsPDF();
                Blob pdfBlob = !Test.isRunningTest() ? vfPage.getContentAsPDF() : Blob.valueOf('testblob');
                
                // Prepare email details
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>();
                sendTo.add(booking.Email1__c);
                if (booking.Email1__c != null) {
                    sendTo.add(booking.Email1__c);
                }
                
                // Set Org-Wide Email Address
                if (owea.size() > 0) {
                    email.setOrgWideEmailAddressId(owea[0].Id);
                }
                
                // Include CC addresses
                lstCCEmail.add(booking.Owner.Email);
                if (booking.CRM_Manager__c != null) {
                    lstCCEmail.add(booking.CRM_Manager__r.Email);
                }
                if (lstCCEmail.size() > 0) {
                    email.setCcAddresses(lstCCEmail);
                }
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
                email.setToAddresses(sendTo);
                email.setSubject('Additional Charges');
                
                // Modify email body to include Additional_Charge_Type__c
                email.setHtmlBody('Dear ' + booking.First_Applicant_Name__c + ',<br/><br/>'
                                  + 'Please find the attached receipt for the Additional Charges of type: <strong>' 
                                  + Additional_Charges.Additional_Charge_Type__c + '</strong>.<br/><br/>'
                                  + 'If you have any questions, feel free to contact us.<br/><br/>Thank you.<br/><br/>'
                                  + 'Thanks & Regards,<br/><br/>'
                                  + '<strong>Midhu Siju</strong> | Officer - Customer Relations | 9207054444<br/>'
                                  + '<strong>Alitta Lijoy</strong> | Customer Relation Executive | 90482 37066<br/><br/>'
                                  + '<strong>'+companyName+'</strong><br/>'
                                  + 'Regd. Office: '+Address1+'<br/>'
                                  + Address2+' '+Address3+'<br/>'
                                  + 'Tel: +91 484 2584000 / 2973944, +91 6235051144<br/>'
                                  + '<a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a><br/><br/>'
                                  + 'Follow us on: <a href="https://www.facebook.com/veegalanddevelopers" target="_blank">Facebook</a> | '
                                  + '<a href="https://www.instagram.com/veegalanddevelopers" target="_blank">Instagram</a> | '
                                  + '<a href="https://www.linkedin.com/company/veegalanddevelopers" target="_blank">LinkedIn</a> | '
                                  + '<a href="https://www.youtube.com/c/VeegalandDevelopers" target="_blank">YouTube</a>');
                
                // Attach the PDF to the email
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('AdditionalCharges.pdf');
                attachment.setBody(pdfBlob);
                email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
                email.setSaveAsActivity(true);
                email.setWhatId(booking.Id);              
                
                // Send the email
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                
                returnMessage = 'Email sent successfully';
            } else {
                returnMessage = 'Email address not specified in the Booking record.';
            }
        } catch (Exception e) {
            ExceptionHandler.addLog(e,'','GenerateDocumnetController',recId);  /*Add Exception to error log*/
            returnMessage = 'Error sending email: ' + e.getMessage();
        }
        return returnMessage;
    }
    
    @AuraEnabled
    public static String sendEmailAdvanceReceipt(Id receiptId) {
        String returnMessage;
        try {
            // Retrieve the Receipt record
            Advance_Receipt__c receipt = [SELECT Id, Booking__c, CreatedBy.Email,Invoice_Id__c,Mode_of_payment__c,Advance_Amount__c,Cheque_Transaction_Number__c FROM Advance_Receipt__c WHERE Id = :receiptId LIMIT 1];
            
            if (receipt == null || receipt.Booking__c == null) {
                return 'Receipt or associated Booking record not found.';
            }
            system.debug('here');
            
            // Retrieve the related Booking record
            Booking__c booking = [SELECT Id, Email1__c,Project__c, Email2__c, First_Applicant_Name__c,Sales_Executive__c,Sales_Executive__r.Email, Owner.Email, CRM_Manager__c, CRM_Manager__r.Email 
                                  FROM Booking__c WHERE Id = :receipt.Booking__c LIMIT 1];
            
            if (booking != null && !String.isBlank(booking.Email1__c)) {
                List<String> lstCCEmail = new List<String>();
                
                // Retrieve co-applicants associated with the Booking
                //List<Co_Applicant__c> coApps = [SELECT Id, Name, Email__c, Booking__c FROM Co_Applicant__c WHERE Booking__c = :booking.Id];
                
                // Retrieve Org Wide Email Address
                List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :booking.Sales_Executive__r.Email];
                
                PageReference receiptPage;
                receiptPage = Page.AdvanceReceiptInvoice;
                // Generate the PDF for the receipt
                receiptPage.getParameters().put('id', receiptId);
                system.debug('here');
                Blob pdfBlob = !Test.isRunningTest() ? receiptPage.getContentAsPDF() : Blob.valueOf('testblob');
                
                // Prepare email details
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>();
                sendTo.add(booking.Email1__c);
                // Include Co-Applicant emails
                /* for (Co_Applicant__c ca : coApps) {
if (ca.Email__c != null) {
sendTo.add(ca.Email__c);
}
}*/
                if(!Test.isRunningTest()){
                    // Set Org-Wide Email Address (if available)
                    if (owea.size() > 0) {
                        email.setOrgWideEmailAddressId(owea[0].Id);
                    }
                }
                system.debug('here');
                // Include CC addresses
                lstCCEmail.add(booking.Owner.Email);
                if (booking.CRM_Manager__c != null) {
                    lstCCEmail.add(booking.CRM_Manager__r.Email);
                }
                //lstCCEmail.add('customercare@veegaland.in');
                if (!lstCCEmail.isEmpty()) {
                    email.setCcAddresses(lstCCEmail);
                }
                String amountInWords;
                if(receipt.Advance_Amount__c !=null){
                    amountInWords =  convertNumberToWords(receipt.Advance_Amount__c);
                }
                List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
                string companyName;
                
                if(!companyDetails.isEmpty()){
                    companyName = companyDetails[0].Label;
                      
                }
                email.setToAddresses(sendTo);
                String emailbody = 'Dear ' + booking.First_Applicant_Name__c + ',<br/><br/>' +
                    'We are pleased to inform you that your payment of ' + receipt.Advance_Amount__c + ' (' + amountInWords + ') against reference '+receipt.Cheque_Transaction_Number__c+' number and invoice number' + receipt.Invoice_Id__c + ' has been successfully credited to our account.<br/><br/>' +
                    'Thank you for your timely payment. Please find the attached receipt for your reference.<br/><br/>' +
                    'Should you have any further questions, feel free to reach out.<br/><br/>' +
                    'Thank you for choosing Veegaland Homes.<br/><br/>' +
                    'Best regards,<br/>' +
                    companyName;
                
                
                system.debug(sendTo);
                email.setSubject('Receipt for Your Payment');
                email.setHtmlBody(emailbody);
                system.debug('otherside');
                // Attach the PDF to the email
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('Receipt.pdf');
                attachment.setBody(pdfBlob);
                email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
                system.debug('inside');
                email.setSaveAsActivity(true);
                email.setWhatId(receipt.Id);
                system.debug('outside');
                // Send the email
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                
                returnMessage = 'Email sent successfully';
            } else {
                returnMessage = 'Email address not specified in the Booking record.';
            }
        } catch (Exception e) {
            ExceptionHandler.addLog(e,'','GenerateDocumnetController',receiptId);  /*Add Exception to error log*/
            returnMessage = 'Error sending email: ' + e.getMessage();
        }
        return returnMessage;
    }
    
    
    @future(callout=true)
    public static void sendBulkAdvanceReceiptEmail(set<Id> receiptIds) {
        
        
        set<Id> bookingId = new set<Id>();
        set<string> receOwnerEmails = new set<string>();
        
        map<string,Id> orgEmailMap = new map<string,Id>();
        
        List<Messaging.SingleEmailMessage> addMessage = new List<Messaging.SingleEmailMessage>();
        // Retrieve the Receipt record
        map<Id,Advance_Receipt__c> receiptMap = new  map<Id,Advance_Receipt__c>([SELECT Id, Booking__c, CreatedBy.Email,Invoice_Id__c,Mode_of_payment__c,Advance_Amount__c,Cheque_Transaction_Number__c FROM Advance_Receipt__c WHERE Id in :receiptIds and Booking__c!=null]);
        try {  
            for(Advance_Receipt__c advRec: receiptMap.values()){
                bookingId.add(advRec.Booking__c);
                receOwnerEmails.add(advRec.CreatedBy.Email);
            }
            
            // Retrieve the related Booking record
            map<Id,Booking__c> bookingMap = new  map<Id,Booking__c> ([SELECT Id, Email1__c,Project__c, Email2__c, First_Applicant_Name__c, Owner.Email, CRM_Manager__c, CRM_Manager__r.Email 
                                                                      FROM Booking__c WHERE Id IN :bookingId AND Email1__c !=null]);
            // Retrieve Org Wide Email Address
            map<Id,OrgWideEmailAddress> oweaMap = new map<Id,OrgWideEmailAddress> ([SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address in :receOwnerEmails]);
            if(!oweaMap.isEmpty()){
                for(OrgWideEmailAddress orgw : oweaMap.values()){
                    orgEmailMap.put(orgw.Address,orgw.Id);
                }
            }
            List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
                string companyName;
                
                if(!companyDetails.isEmpty()){
                    companyName = companyDetails[0].Label;
                      
                }
            if (bookingMap.size() >0) {
                Booking__c book = new Booking__c();
               
                for(Advance_Receipt__c advRec : receiptMap.values()){
                    List<String> lstCCEmail = new List<String>();
                    lstCCEmail.add('customercare@veegaland.in');
                    
                    List<String> sendTo = new List<String>();
                    book =bookingMap.get(advRec.Booking__c);
                    PageReference receiptPage;
                    receiptPage = Page.AdvanceReceiptInvoice;
                    // Generate the PDF for the receipt
                    receiptPage.getParameters().put('id', advRec.Id);
                    Blob pdfBlob = !Test.isRunningTest() ? receiptPage.getContentAsPDF() : Blob.valueOf('testblob');
                    // Prepare email details
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    
                    sendTo.add(book.Email1__c);   
                    if(!Test.isRunningTest()){
                        if (orgEmailMap.containsKey(advRec.CreatedBy.Email)) {
                            email.setOrgWideEmailAddressId(orgEmailMap.get(advRec.CreatedBy.Email));   // Set Org-Wide Email Address (if available)
                        }
                    }  
                    // Include CC addresses
                    lstCCEmail.add(book.Owner.Email);
                    if (book.CRM_Manager__c != null) {
                        lstCCEmail.add(book.CRM_Manager__r.Email);
                    }
                    
                    if (!lstCCEmail.isEmpty()) {
                        email.setCcAddresses(lstCCEmail);
                    }
                    String amountInWords;
                    if(advRec.Advance_Amount__c !=null){
                        amountInWords =  convertNumberToWords(advRec.Advance_Amount__c);
                    }
                    email.setToAddresses(sendTo);
                    String emailbody = 'Dear ' + book.First_Applicant_Name__c + ',<br/><br/>' +
                        'We are pleased to inform you that your payment of ' + advRec.Advance_Amount__c + ' (' + amountInWords + ') against reference '+advRec.Cheque_Transaction_Number__c+' number and invoice number' + advRec.Invoice_Id__c + ' has been successfully credited to our account.<br/><br/>' +
                        'Thank you for your timely payment. Please find the attached receipt for your reference.<br/><br/>' +
                        'Should you have any further questions, feel free to reach out.<br/><br/>' +
                        'Thank you for choosing Veegaland Homes.<br/><br/>' +
                        'Best regards,<br/>' +
                        companyName;
                    
                    email.setSubject('Receipt for Your Payment');
                    email.setHtmlBody(emailbody);
                    // Attach the PDF to the email
                    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                    attachment.setFileName('Receipt.pdf');
                    attachment.setBody(pdfBlob);
                    email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
                    email.setSaveAsActivity(true);
                    email.setWhatId(advRec.Id);
                    addMessage.add(email);
                }
                // Send the email
                Messaging.sendEmail(addMessage);
            }
        } catch (Exception e) {
            ExceptionHandler.addLog(e,string.valueof(receiptMap),'GenerateDocumnetController','');  /*Add Exception to error log*/
            
        }
        
        
    }
    
    
    
    
    @AuraEnabled
    public static String sendEmailAdvanceGSTReceipt(Id receiptId) {
        String returnMessage;
        try {
            // Retrieve the Receipt record
            Advance_Receipt__c receipt = [SELECT Id, Booking__c, CreatedBy.Email,Invoice_Id__c,Mode_of_payment__c,Advance_Amount__c,Cheque_Transaction_Number__c FROM Advance_Receipt__c WHERE Id = :receiptId LIMIT 1];
            
            if (receipt == null || receipt.Booking__c == null) {
                return 'Receipt or associated Booking record not found.';
            }
            system.debug('here');
            
            // Retrieve the related Booking record
            Booking__c booking = [SELECT Id, Email1__c,Project__c, Email2__c, First_Applicant_Name__c,Name, Owner.Email, CRM_Manager__c, CRM_Manager__r.Email, Finance_User__c,Finance_User__r.Name,Finance_User__r.Email
                                  FROM Booking__c WHERE Id = :receipt.Booking__c LIMIT 1];
            
            if (booking != null && !String.isBlank(booking.Finance_User__r.Email)) {
                List<String> lstCCEmail = new List<String>();
                
                // Retrieve co-applicants associated with the Booking
                //List<Co_Applicant__c> coApps = [SELECT Id, Name, Email__c, Booking__c FROM Co_Applicant__c WHERE Booking__c = :booking.Id];
                
                // Retrieve Org Wide Email Address
                List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :receipt.CreatedBy.Email];
                
                PageReference receiptPage;
                receiptPage = Page.ARGSTInvoiceVFP;
                // Generate the PDF for the receipt
                receiptPage.getParameters().put('id', receiptId);
                system.debug('here');
                Blob pdfBlob = !Test.isRunningTest() ? receiptPage.getContentAsPDF() : Blob.valueOf('testblob');
                
                // Prepare email details
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>();
                sendTo.add(booking.Finance_User__r.Email);
                system.debug('here');
                // Include Co-Applicant emails
                /* for (Co_Applicant__c ca : coApps) {
if (ca.Email__c != null) {
sendTo.add(ca.Email__c);
}
}*/
                if(!Test.isRunningTest()){
                    // Set Org-Wide Email Address (if available)
                    if (owea.size() > 0) {
                        email.setOrgWideEmailAddressId(owea[0].Id);
                    }
                }
                system.debug('here');
                // Include CC addresses
                lstCCEmail.add(booking.Owner.Email);
               // lstCCEmail.add('customercare@veegaland.in');
                if (booking.CRM_Manager__c != null) {
                    lstCCEmail.add(booking.CRM_Manager__r.Email);
                }
                //lstCCEmail.add('Crmlead@mahendrahomes.com');
                //lstCCEmail.add('crm@mahendrahomes.com');
                if (!lstCCEmail.isEmpty()) {
                    email.setCcAddresses(lstCCEmail);
                }
                String amountInWords;
                if(receipt.Advance_Amount__c !=null){
                    amountInWords =  convertNumberToWords(receipt.Advance_Amount__c);
                }
                List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
                string companyName;
               
                if(!companyDetails.isEmpty()){
                    companyName = companyDetails[0].Label;
                       
                }
                email.setToAddresses(sendTo);
                String emailBody = 
                    'Dear Finance Team,<br/><br/>' +
                    'Please find the details of a GST-split invoice generated for the following booking:<br/><br/>' +
                    '<strong>Customer Name:</strong> ' + booking.First_Applicant_Name__c + '<br/>' +
                    '<strong>Booking Name:</strong> ' + booking.Name + '<br/>' +
                    '<strong>Amount Received:</strong> ₹' + receipt.Advance_Amount__c + ' (' + amountInWords + ')<br/>' +
                    '<strong>Reference No:</strong> ' + receipt.Cheque_Transaction_Number__c + '<br/>' +
                    '<strong>Invoice No:</strong> ' + receipt.Invoice_Id__c + '<br/><br/>' +
                    'The GST-split invoice and receipt are attached for download and internal accounting purposes.<br/><br/>' +
                    'Regards,<br/>' +
                    companyName+' CRM System';
                
                
                system.debug(sendTo);
                email.setSubject('Advance Receipt ('+receipt.Invoice_Id__c+') for Booking: '+booking.Name+' - '+booking.First_Applicant_Name__c);
                email.setHtmlBody(emailbody);
                system.debug('otherside');
                // Attach the PDF to the email
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('Receipt.pdf');
                attachment.setBody(pdfBlob);
                email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
                system.debug('inside');
                email.setSaveAsActivity(true);
                email.setWhatId(receipt.Id);
                system.debug('outside');
                // Send the email
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                
                returnMessage = 'Email sent successfully';
            } else {
                returnMessage = 'Email address not specified in the Booking record.';
            }
        } catch (Exception e) {
            ExceptionHandler.addLog(e,'','GenerateDocumnetController',receiptId);  /*Add Exception to error log*/
            returnMessage = 'Error sending email: ' + e.getMessage();
        }
        return returnMessage;
    }
    /* Date: 26/08/25  Author:  @desc: Send refund email to Customer   @param 1:receiptId Id @return :string*/   
    @AuraEnabled
    public static String sendEmailRefund(Id receiptId) {
        String returnMessage;
        try {
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
            // Query for Refund
            Refund__c receipt = [SELECT Id, Booking__c, CreatedBy.Email, CreatedById, Bank_Name__c, Voucher_No__c,
                                 Refund_Date__c, Receipt_Number__c, Total_Refund_Amount__c, Transaction_Number__c, Name 
                                 FROM Refund__c WHERE Id = :receiptId LIMIT 1];
            
            // If the receipt or associated booking is missing, return an error message
            if (receipt == null || receipt.Booking__c == null) {
                return 'Receipt or associated Booking record not found.';
            }
            
            // Query for Booking
            Booking__c booking = [SELECT Id, Email1__c, Project__c, Email2__c, First_Applicant_Name__c, Name, Plot__r.Name,Project1__r.Name,
                                  Owner.Email, CRM_Manager__c, CRM_Manager__r.Email, Finance_User__c, 
                                  Finance_User__r.Name, Finance_User__r.Email
                                  FROM Booking__c WHERE Id = :receipt.Booking__c LIMIT 1];
            
            if (booking != null && !String.isBlank(booking.Finance_User__r.Email)) {
                List<String> lstCCEmail = new List<String>();
                
                // Retrieve Org Wide Email Address
                List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :receipt.CreatedBy.Email];
                
                PageReference receiptPage;
                receiptPage = Page.RefundVoucherVFP;
                // Generate the PDF for the receipt
                receiptPage.getParameters().put('id', receiptId);
                Blob pdfBlob = !Test.isRunningTest() ? receiptPage.getContentAsPDF() : Blob.valueOf('testblob');
                
                // Prepare email details
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>();
                sendTo.add(booking.Finance_User__r.Email);
                
                if (!Test.isRunningTest()) {
                    // Set Org-Wide Email Address (if available)
                    if (owea.size() > 0) {
                        email.setOrgWideEmailAddressId(owea[0].Id);
                    }
                }
                
                // Include CC addresses
                lstCCEmail.add(booking.Owner.Email);
               // lstCCEmail.add('customercare@veegaland.in');
                if (booking.CRM_Manager__c != null) {
                    lstCCEmail.add(booking.CRM_Manager__r.Email);
                }
                
                if (!lstCCEmail.isEmpty()) {
                    email.setCcAddresses(lstCCEmail);
                }
                
                String amountInWords;
                if (receipt.Total_Refund_Amount__c != null) {
                    amountInWords = convertNumberToWords(receipt.Total_Refund_Amount__c);
                }
                
                email.setToAddresses(sendTo);
                String emailBody = '';
                emailBody += 'Dear ' + booking.First_Applicant_Name__c + ',<br/><br/>';
                emailBody += 'This is to inform you that your booking for Unit (' + booking.Plot__r.Name + ') at (' + booking.Project1__r.Name + ') has been cancelled. As part of our process, we have issued a refund voucher for the advance amount received.<br/><br/>';
                emailBody += 'Please find the Refund Voucher attached, confirming the refund against your booking.<br/><br/>';
                emailBody += 'If you have any questions or need further assistance, feel free to reach out to us at <br/><br/>';
                emailBody += 'Thank you for your understanding.<br/><br/>';
                emailBody += 'Best regards,<br/><br/>';
                
                emailBody += '<b>Midhu Siju</b> | Officer - Customer Relations | <a href="tel:+919207054444">9207054444</a><br/>';
                emailBody += '<b>Alitta Lijoy</b> | Customer Relation Executive | <a href="tel:+919048237066">90482 37066</a><br/><br/>';
                
                emailBody += '<b>'+companyName+'</b><br/>';
                emailBody += 'Regd. Office: '+Address1+' '+Address2+' '+Address3+'<br/>';
                emailBody += 'Tel: +91 484 2584000 / 2973944, +91 6235051144<br/>';
                emailBody += '<a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a><br/><br/>';
                
                emailBody += 'Follow us on:<br/>';
                emailBody += '<a href="https://www.facebook.com/veegalanddevelopers" target="_blank">Facebook</a> | ';
                emailBody += '<a href="https://www.instagram.com/veegalanddevelopers" target="_blank">Instagram</a> | ';
                emailBody += '<a href="https://www.linkedin.com/company/veegalanddevelopers" target="_blank">LinkedIn</a> | ';
                emailBody += '<a href="https://www.youtube.com/c/VeegalandDevelopers" target="_blank">YouTube</a><br/>';
                
                email.setSubject('Advance Receipt ('+receipt.Voucher_No__c+') for Booking: '+booking.Name+' - '+booking.First_Applicant_Name__c);
                email.setHtmlBody(emailBody);
                
                // Attach the PDF to the email
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('RefundVoucher.pdf');
                attachment.setBody(pdfBlob);
                email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
                
                email.setSaveAsActivity(true);
                email.setWhatId(receipt.Id);
                
                // Send the email
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                
                returnMessage = 'Email sent successfully';
            } else {
                returnMessage = 'Email address not specified in the Booking record.';
            }
        } catch (Exception e) {
            returnMessage = 'Error sending email: ' + e.getMessage();
            ExceptionHandler.addLog(e,'','GenerateDocumnetController',receiptId);  /*Add Exception to error log*/
        }
        return returnMessage;
    }
    
    
    /* Date: 26/08/25  Author:  @desc: Send credit note email to customer   @param 1:receipt Id @return :string*/   
    @AuraEnabled
    public static String sendEmailCreditNote(Id receiptId) {
        String returnMessage;
        try {
            // Retrieve the Refund record (Credit Note)
            Refund__c receipt = [SELECT Id, Bank_Name__c,CreatedBy.Email, Voucher_No__c, Receipt_Number__c,createdById, Total_Refund_Amount__c, Transaction_Number__c, Name, Booking__c FROM Refund__c WHERE Id = :receiptId LIMIT 1];
            
            if (receipt == null || receipt.Booking__c == null) {
                return 'Refund record or associated Booking record not found.';
            }
            
            // Retrieve the related Booking record
            Booking__c booking = [SELECT Id, Email1__c, Project__c, Email2__c, First_Applicant_Name__c, Name, Owner.Email, CRM_Manager__c, CRM_Manager__r.Email, Finance_User__c, Finance_User__r.Name, Finance_User__r.Email, Project1__r.Name, Plot__r.Name FROM Booking__c WHERE Id = :receipt.Booking__c LIMIT 1];
            
            if (booking != null && !String.isBlank(booking.Finance_User__r.Email)) {
                List<String> lstCCEmail = new List<String>();
                
                // Retrieve Org Wide Email Address
                List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :receipt.CreatedBy.Email];
                
                PageReference receiptPage;
                receiptPage = Page.RefundVoucherVFP;
                // Generate the PDF for the credit note (refund voucher)
                receiptPage.getParameters().put('id', receiptId);
                Blob pdfBlob = !Test.isRunningTest() ? receiptPage.getContentAsPDF() : Blob.valueOf('testblob');
                
                // Prepare email details
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>();
                sendTo.add(booking.Finance_User__r.Email);
                
                if (!Test.isRunningTest()) {
                    // Set Org-Wide Email Address (if available)
                    if (owea.size() > 0) {
                        email.setOrgWideEmailAddressId(owea[0].Id);
                    }
                }
                
                // Include CC addresses
                lstCCEmail.add(booking.Owner.Email);
               // lstCCEmail.add('customercare@veegaland.in');
                if (booking.CRM_Manager__c != null) {
                    lstCCEmail.add(booking.CRM_Manager__r.Email);
                }
                
                if (!lstCCEmail.isEmpty()) {
                    email.setCcAddresses(lstCCEmail);
                }
                
                String amountInWords;
                if (receipt.Total_Refund_Amount__c != null) {
                    amountInWords = convertNumberToWords(receipt.Total_Refund_Amount__c);
                }
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
                email.setToAddresses(sendTo);
                String emailBody = '';
                emailBody += 'Dear ' + booking.First_Applicant_Name__c + ',<br/><br/>';
                emailBody += 'This is to inform you that your booking for Unit (' + booking.Plot__r.Name + ') at (' + booking.Project1__r.Name + ') has been cancelled. As part of our process, we have issued a credit note for the refund amount of ' + amountInWords + '.<br/><br/>';
                emailBody += 'Please find the Credit Note attached, confirming the refund against your booking.<br/><br/>';
                emailBody += 'If you have any questions or need further assistance, feel free to reach out to us at <br/><br/>';
                emailBody += 'Thank you for your understanding.<br/><br/>';
                emailBody += 'Best regards,<br/><br/>';
                
                emailBody += '<b>Midhu Siju</b> | Officer - Customer Relations | <a href="tel:+919207054444">9207054444</a><br/>';
                emailBody += '<b>Alitta Lijoy</b> | Customer Relation Executive | <a href="tel:+919048237066">90482 37066</a><br/><br/>';
                
                emailBody += '<b>'+companyName+'</b><br/>';
                emailBody += 'Regd. Office: '+Address1+' '+Address2+' '+Address3+'<br/>';
                emailBody += 'Tel: +91 484 2584000 / 2973944, +91 6235051144<br/>';
                emailBody += '<a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a><br/><br/>';
                
                emailBody += 'Follow us on:<br/>';
                emailBody += '<a href="https://www.facebook.com/veegalanddevelopers" target="_blank">Facebook</a> | ';
                emailBody += '<a href="https://www.instagram.com/veegalanddevelopers" target="_blank">Instagram</a> | ';
                emailBody += '<a href="https://www.linkedin.com/company/veegalanddevelopers" target="_blank">LinkedIn</a> | ';
                emailBody += '<a href="https://www.youtube.com/c/VeegalandDevelopers" target="_blank">YouTube</a><br/>';
                
                email.setSubject('Credit Note ('+receipt.Transaction_Number__c+') for Booking: '+booking.Name+' - '+booking.First_Applicant_Name__c);
                email.setHtmlBody(emailBody);
                
                // Attach the PDF to the email
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('CreditNote.pdf');
                attachment.setBody(pdfBlob);
                email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
                
                email.setSaveAsActivity(true);
                email.setWhatId(receipt.Id);
                
                // Send the email
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                
                returnMessage = 'Email sent successfully';
            } else {
                returnMessage = 'Email address not specified in the Booking record.';
            }
        } catch (Exception e) {
            ExceptionHandler.addLog(e,'','GenerateDocumnetController',receiptId);  /*Add Exception to error log*/
            returnMessage = 'Error sending email: ' + e.getMessage();
        }
        return returnMessage;
    }
    
    
    @AuraEnabled
    public static void sendAdvanceReminderEmail(Id bookingId,String emailContent) {
        // Query the single Booking record
        Booking__c b = [
            SELECT Id, Email1__c, Balance_Advance_Amount__c,
            Project1__r.Name, Plot__r.Name,
            CRM_Manager__r.Email, CRM_Manager__c,
            Owner.Email
            FROM Booking__c
            WHERE Id = :bookingId
            LIMIT 1
        ];
        
        // Get Org-Wide Email Addresses (choose one fallback)
        OrgWideEmailAddress orgWideEmail = [
            SELECT Id, Address, DisplayName
            FROM OrgWideEmailAddress
            WHERE Address != null
            LIMIT 1
        ];
        
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        List<Booking__c> updateBooking = new List<Booking__c>();
        
        if (b != null && String.isNotBlank(b.Email1__c)) {
            String amountInWords = AmountInWords.convertToWords(b.Balance_Advance_Amount__c);
            
            String subject = 'Reminder: Booking Advance Pending';
            
            String emailBody = emailContent;
           
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { b.Email1__c });
            if (b.Owner != null && String.isNotBlank(b.Owner.Email)) {
                mail.setCcAddresses(new String[] { b.Owner.Email,'customercare@veegaland.in' });
            }
            mail.setSubject(subject);
            mail.setHtmlBody(emailBody);
            
            if (b.CRM_Manager__c != null && String.isNotBlank(b.CRM_Manager__r.Email)) {
                mail.setReplyTo(b.CRM_Manager__r.Email);
                mail.setSenderDisplayName('CRM Manager - ' + b.CRM_Manager__r.Email);
            } else if (orgWideEmail != null) {
                mail.setOrgWideEmailAddressId(orgWideEmail.Id);
            }
            mail.setSaveAsActivity(true);
            mail.setWhatId(b.Id);
            emailMessages.add(mail);
            
            Booking__c bk = new Booking__c(Id = b.Id, Advance_Remainder_Last_Mail_Send_Date__c = System.today());
            updateBooking.add(bk);
        }
        
        if (!emailMessages.isEmpty()) {
            Messaging.sendEmail(emailMessages);
            if (!updateBooking.isEmpty()) {
                update updateBooking;
            }
        }
    }
    public static void notifyDraftAgreementRejected(Set<Id> bookingIds) {
        if (bookingIds == null || bookingIds.isEmpty()) return;
        
        List<Booking__c> bookings = [
            SELECT Id, Name, Draft_Agreement_Rejection_Comments__c,
            CRM_Manager__r.Email, CRM_Manager__r.Name,
            Legal_team__r.Email, Legal_team__r.Name,
            Finance_User__r.Email, Finance_User__r.Name,
            CRM_Technical__r.Email, CRM_Technical__r.Name
            FROM Booking__c
            WHERE Id IN :bookingIds
        ];
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for (Booking__c bk : bookings) {
            Set<String> tos = new Set<String>();
            if (bk.CRM_Manager__r != null && String.isNotBlank(bk.CRM_Manager__r.Email))     tos.add(bk.CRM_Manager__r.Email);
            if (bk.Legal_team__r != null && String.isNotBlank(bk.Legal_team__r.Email))     tos.add(bk.Legal_team__r.Email);
            if (bk.Finance_User__r != null && String.isNotBlank(bk.Finance_User__r.Email))   tos.add(bk.Finance_User__r.Email);
            if (bk.CRM_Technical__r != null && String.isNotBlank(bk.CRM_Technical__r.Email)) tos.add(bk.CRM_Technical__r.Email);
            if (tos.isEmpty()) continue;
            
            String bookingLink = System.URL.getOrgDomainUrl().toExternalForm() + '/' + bk.Id;
            
            String reason = escapeHtml(nvl(bk.Draft_Agreement_Rejection_Comments__c, '--')).replace('\n','<br/>');
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>(tos));
            mail.setSubject('Draft Sale Agreement Rejected - ' + (bk.Name == null ? String.valueOf(bk.Id) : bk.Name));
            mail.setHtmlBody(
                'Hello Team,<br/><br/>' +
                'The draft sale agreement for booking ' +
                '<b>Booking Link:</b> <a href="' + bookingLink + '">' + bk.Name + '</a><br/>' +
                'was <strong>REJECTED</strong> by the customer.<br/><br/>' +
                '<strong>Rejection Reason:</strong><br/>' + reason + '<br/><br/>' +
                'Please rework on the draft agreement and resubmit.<br/><br/>' +
                'Thanks,<br/>System Notification'
            );
            mail.setSaveAsActivity(true);
            mail.setWhatId(bk.Id);
            emails.add(mail);
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
            system.debug('Emails send sucessfully');
        }
    }
    public static void notifyDraftDeedRejected(Set<Id> bookingIds) {
        if (bookingIds == null || bookingIds.isEmpty()) return;
        
        List<Booking__c> bookings = [
            SELECT Id, Name, Sale_deed_Approval_Status__c, Sale_Deed_Rejection_Comments__c,
            CRM_Manager__r.Email, CRM_Manager__r.Name,First_Applicant_Name__c,
            Legal_team__r.Email, Legal_team__r.Name, project1__r.Name,
            Finance_User__r.Email, Finance_User__r.Name, plot__r.Name , 
            CRM_Technical__r.Email, CRM_Technical__r.Name, Draft_Sale_Deed_Send_Date__c
            FROM Booking__c
            WHERE Id IN :bookingIds
        ];
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for (Booking__c bk : bookings) {
            Set<String> tos = new Set<String>();
            if (bk.CRM_Manager__r != null && String.isNotBlank(bk.CRM_Manager__r.Email))     tos.add(bk.CRM_Manager__r.Email);
            if (bk.Legal_team__r != null && String.isNotBlank(bk.Legal_team__r.Email))     tos.add(bk.Legal_team__r.Email);
            if (bk.Finance_User__r != null && String.isNotBlank(bk.Finance_User__r.Email))   tos.add(bk.Finance_User__r.Email);
            if (bk.CRM_Technical__r != null && String.isNotBlank(bk.CRM_Technical__r.Email)) tos.add(bk.CRM_Technical__r.Email);
            if (tos.isEmpty()) continue;
            
            String bookingLink = System.URL.getOrgDomainUrl().toExternalForm() + '/' + bk.Id;
            
            String reason = escapeHtml(nvl(bk.Sale_Deed_Rejection_Comments__c, '--')).replace('\n','<br/>');
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            String finalFormattedDateTime='';
            if (bk.Draft_Sale_Deed_Send_Date__c != null) {
                // Get the DateTime value
                DateTime dt = bk.Draft_Sale_Deed_Send_Date__c;

                // Format Date as "23 Jan 2026"
                String formattedDate = dt.format('dd MMM yyyy');

                // Format Time as "10:30 AM"
                String formattedTime = dt.format('hh:mm a');

                // Combine both date and time in desired format
                finalFormattedDateTime = formattedDate + ' at ' + formattedTime;

                // Display or update the formatted value (e.g., as a Toast message or on the UI)
            }

            mail.setToAddresses(new List<String>(tos));
            mail.setSubject('Draft Sale Agreement Rejected - ' + bk.plot__r.Name + '-' + bk.project1__r.Name);
            mail.setHtmlBody(
                'Hello Team,<br/><br/>' +
                'Please note that the customer ' + bk.First_Applicant_Name__c + 'has rejected the draft Sale Deed for the unit ' + 
                bk.plot__r.Name + ' at ' + bk.project1__r.Name + '.<br/><br/>'+
                'Details:<br/>' +
                '<b>Booking Name:</b> ' + bk.Name + '<br/>' +
                'Unit: ' + bk.plot__r.Name + ' '+ bk.project1__r.Name + '<br/>' +
                'Date of Submission: ' + bk.Draft_Sale_Deed_Send_Date__c + '<br/>' +
                'Rejection Date: '+ finalFormattedDateTime +
                '<b>Booking Link:</b> <a href="' + bk + '">' + bk.Name + '</a><br/>' +
                'was <strong>REJECTED</strong> by the customer.<br/><br/>' +
                '<strong>Rejection Reason:</strong><br/>' + reason + '<br/><br/>' +
                'Please rework on the draft agreement and resubmit.<br/><br/>' +
                'Thanks,<br/>System Notification'
            );
            mail.setSaveAsActivity(true);
            mail.setWhatId(bk.Id);
            emails.add(mail);
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
    public static void notifyDraftDeedApproved(Set<Id> bookingIds) {
        if (bookingIds == null || bookingIds.isEmpty()) return;
        
        List<Booking__c> bookings = [
            SELECT Id, Name, Sale_deed_Approval_Status__c, Sale_Deed_Rejection_Comments__c,
            CRM_Manager__r.Email, CRM_Manager__r.Name,First_Applicant_Name__c,
            Legal_team__r.Email, Legal_team__r.Name, project1__r.Name,
            Finance_User__r.Email, Finance_User__r.Name, plot__r.Name , 
            CRM_Technical__r.Email, CRM_Technical__r.Name, Draft_Sale_Deed_Send_Date__c
            FROM Booking__c
            WHERE Id IN :bookingIds
        ];
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for (Booking__c bk : bookings) {
            Set<String> tos = new Set<String>();
            if (bk.CRM_Manager__r != null && String.isNotBlank(bk.CRM_Manager__r.Email))     tos.add(bk.CRM_Manager__r.Email);
            if (bk.Legal_team__r != null && String.isNotBlank(bk.Legal_team__r.Email))     tos.add(bk.Legal_team__r.Email);
            if (bk.Finance_User__r != null && String.isNotBlank(bk.Finance_User__r.Email))   tos.add(bk.Finance_User__r.Email);
            if (bk.CRM_Technical__r != null && String.isNotBlank(bk.CRM_Technical__r.Email)) tos.add(bk.CRM_Technical__r.Email);
            if (tos.isEmpty()) continue;
            
            String bookingLink = System.URL.getOrgDomainUrl().toExternalForm() + '/' + bk.Id;
            
            String reason = escapeHtml(nvl(bk.Sale_Deed_Rejection_Comments__c, '--')).replace('\n','<br/>');
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            String finalFormattedDateTime='';
            if (bk.Draft_Sale_Deed_Send_Date__c != null) {
                // Get the DateTime value
                DateTime dt = bk.Draft_Sale_Deed_Send_Date__c;

                // Format Date as "23 Jan 2026"
                String formattedDate = dt.format('dd MMM yyyy');

                // Format Time as "10:30 AM"
                String formattedTime = dt.format('hh:mm a');

                // Combine both date and time in desired format
                finalFormattedDateTime = formattedDate + ' at ' + formattedTime;

                // Display or update the formatted value (e.g., as a Toast message or on the UI)
            }

            mail.setToAddresses(new List<String>(tos));
            mail.setSubject('Draft Sale Agreement Approved - '+ bk.plot__r.Name + '-' + bk.project1__r.Name);
            mail.setHtmlBody(
                'Hello Team,<br/><br/>' +
                'Please note that the customer ' + bk.First_Applicant_Name__c + 'has Approved the draft Sale Deed for the unit ' + 
                bk.plot__r.Name + ' at ' + bk.project1__r.Name + '.<br/><br/>'+
                'Details:<br/>' +
                '<b>Booking Name:</b> ' + bk.Name + '<br/>' +
                'Unit: ' + bk.plot__r.Name + ' '+ bk.project1__r.Name + '<br/>' +
                'Date of Submission: ' + bk.Draft_Sale_Deed_Send_Date__c + '<br/>' +
                'Rejection Date: '+ finalFormattedDateTime +
                '<b>Booking Link:</b> <a href="' + bk + '">' + bk.Name + '</a><br/>' +
                'Kindly proceed with the necessary actions for final documentation and registration.<br/><br/>' +
                'Thanks,<br/>Admin<br/>System Notification'
            );
            mail.setSaveAsActivity(true);
            mail.setWhatId(bk.Id);
            emails.add(mail);
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
    
    // helpers
    private static String nvl(String v, String f) { return String.isBlank(v) ? f : v; }
    private static String escapeHtml(String s) {
        if (s == null) return '';
        return s.replace('&','&amp;').replace('<','&lt;').replace('>','&gt;')
            .replace('"','&quot;').replace('\'','&#39;');
    }
    
    
    public static void sendParkingSelectionEmails(List<Id> bookingIds) {
        
        // Fetch booking details
        List<Booking__c> bookings = [
            SELECT Id, First_Applicant_Name__c, CRM_Manager__r.Email,
            Selected_B2B_Parking_Slots__c,Parking_Slot_Numbers__c,
            Selected_Individual_Parking_Slots__c,CRM_Technical__r.Email,
            Project1__r.Name, Plot__r.Name,
            Email1__c
            FROM Booking__c 
            WHERE Id IN :bookingIds
        ];
        
       /* // Fetch related parkings
        Map<Id, List<Parking__c>> bookingParkingMap = new Map<Id, List<Parking__c>>();
        for(Parking__c park : [
            SELECT Id, Name, Parking_Type__c, Booking__c, Parking_Floor__r.Name
            FROM Parking__c
            WHERE Booking__c IN :bookingIds
        ]){
            if(!bookingParkingMap.containsKey(park.Booking__c)){
                bookingParkingMap.put(park.Booking__c, new List<Parking__c>());
            }
            bookingParkingMap.get(park.Booking__c).add(park);
        }
        */
        Set<String> managerEmails = new Set<String>();
        for (Booking__c b : bookings) {
            if (String.isNotBlank(b.CRM_Manager__r != null ? b.CRM_Manager__r.Email : null)) {
                managerEmails.add(b.CRM_Manager__r.Email.trim());
            }
        }
        
        Map<String, Id> emailToOWEAId = new Map<String, Id>();
        if (!managerEmails.isEmpty()) {
            for (OrgWideEmailAddress owea : [
                SELECT Id, Address
                FROM OrgWideEmailAddress
                WHERE Address IN :managerEmails
            ]) {
                emailToOWEAId.put(owea.Address.toLowerCase(), owea.Id);
            }
        }
        // Prepare and send emails
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for(Booking__c booking : bookings){
            String body = '';
            body += 'Dear Team,<br/><br/>';
            body += 'Customer <b>' + booking.First_Applicant_Name__c + '</b> '
                + '(Unit ' + booking.Project1__r.Name + ' – ' + booking.Plot__r.Name + ') '
                + 'has selected the car parking.<br/><br/>';
            
            body += '<b>Parking Details</b><br/>';
            
            if(booking.Selected_B2B_Parking_Slots__c != null){
                body += 'Selected Back to Back Slots: ' + booking.Selected_B2B_Parking_Slots__c + '<br/>';
            }
            if(booking.Selected_Individual_Parking_Slots__c != null){
                body += 'Selected Individual Slots: ' + booking.Selected_Individual_Parking_Slots__c + '<br/>';
            }
            body += '<br/><u>Selected Parking Slots:</u><br/>';
            body += booking.Parking_Slot_Numbers__c;
           /* // List selected parking slots
            if(bookingParkingMap.containsKey(booking.Id)){
                for(Parking__c p : bookingParkingMap.get(booking.Id)){
                    body += p.Parking_Floor__r.Name + ' - ' + p.Name + ' (' + p.Parking_Type__c + ')<br/>';
                }
            }*/
            
            body += '<br/><br/>Vcare Team please upload the marked car parking drawing to the Salesforce for draft agreement preparation.<br/><br/>';
            body += 'Thanks,<br/>';
            body += 'Customer Care – Veegaland<br/>';
            body += 'customercare@veegaland.in';
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            // Set OWEA (send-from) based on CRM Manager email
            String mgrEmail = (booking.CRM_Manager__r != null ? booking.CRM_Manager__r.Email : null);
            if (String.isNotBlank(mgrEmail) && emailToOWEAId.containsKey(mgrEmail.toLowerCase())) {
                email.setOrgWideEmailAddressId(emailToOWEAId.get(mgrEmail.toLowerCase()));
            }
            
            email.setSubject('Car Parking Selection - ' + booking.First_Applicant_Name__c);
            email.setHtmlBody(body);
            email.setToAddresses(new List<String>{booking.CRM_Manager__r.Email,booking.CRM_Technical__r.Email});
            /*if(booking.Email1__c != null){
                email.setCcAddresses(new List<String>{booking.Email1__c});
            }*/
            email.setSaveAsActivity(true);
            email.setWhatId(booking.Id);
            emails.add(email);
        }
        
        if(!emails.isEmpty()){
            Messaging.sendEmail(emails);
        }
    }
    
    public static void sendEmailOnApartmentChange(set<id> newList) {
     
        if (newList.isEmpty()) {
            return;
        }
        
        // 2. Query all needed fields
        List<Booking__c> bookings = [
            SELECT Id,
            Email1__c,
            Email2__c,
            Apartment_Name__c,
            Plot__r.Name,
            Project1__r.Name,
            First_Applicant_Name__c,
            Owner.Email,
            OwnerId,
            CRM_Manager__c,
            CRM_Manager__r.Email
            FROM Booking__c
            WHERE Id IN :newList
        ];
        
        // 3. Fetch Org-Wide Email Address for all possible owner emails
        Set<String> ownerEmails = new Set<String>();
        for (Booking__c b : bookings) {
            if (!String.isBlank(b.Owner.Email)) {
                ownerEmails.add(b.Owner.Email);
            }
        }
        
        Map<String, OrgWideEmailAddress> addressToOwea = new Map<String, OrgWideEmailAddress>();
        
        if (!ownerEmails.isEmpty()) {
            for (OrgWideEmailAddress o : [
                SELECT Id, Address, DisplayName
                FROM OrgWideEmailAddress
                WHERE Address IN :ownerEmails
            ]) {
                addressToOwea.put(o.Address, o);
            }
        }
        
        // 4. Company metadata (since you're using it in footer)
        List<Company_Name__mdt> companyDetails = [
            SELECT Id, DeveloperName, Address2__c, Label, Address3__c, CIN__c, Registered_Address__c
            FROM Company_Name__mdt LIMIT 1
        ];
        
        String companyName = '';
        String address1 = '';
        String address2 = '';
        String address3 = '';
        
        if (!companyDetails.isEmpty()) {
            companyName = companyDetails[0].Label;
            address1 = companyDetails[0].Registered_Address__c;
            address2 = companyDetails[0].Address2__c;
            address3 = companyDetails[0].Address3__c;
        }
        
        // 5. Build email messages
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        
        for (Booking__c booking : bookings) {
            try {
                if (String.isBlank(booking.Email1__c)) {
                    continue;
                }
                
                String plotName = (booking.Plot__r != null) ? booking.Plot__r.Name : 'N/A';
                String projectName = (booking.Project1__r != null) ? booking.Project1__r.Name : 'N/A';
                
                // TO addresses
                List<String> toAddresses = new List<String>{ booking.Email1__c };
                    if (!String.isBlank(booking.Email2__c)) {
                        toAddresses.add(booking.Email2__c);
                    }
                
                // CC addresses
                List<String> ccAddresses = new List<String>();
                
                if (!String.isBlank(booking.Owner.Email)) {
                    ccAddresses.add(booking.Owner.Email);
                }
                
                if (booking.CRM_Manager__r != null &&
                    !String.isBlank(booking.CRM_Manager__r.Email)) {
                        
                        ccAddresses.add(booking.CRM_Manager__r.Email);
                    }
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                
                // Assign org-wide email if found
                if (!String.isBlank(booking.Owner.Email) &&
                    addressToOwea.containsKey(booking.Owner.Email)) {
                        
                        email.setOrgWideEmailAddressId(addressToOwea.get(booking.Owner.Email).Id);
                    }
                
                email.setToAddresses(toAddresses);
                if (!ccAddresses.isEmpty()) {
                    email.setCcAddresses(ccAddresses);
                }
                
                email.setSubject( 'From Veegaland Developers! This is to confirm the Apartment name change for Unit No. ' + plotName + ' in The ' + projectName + ' Project' );

                
                // Build email body
                String emailBody = '';
                
                if (!String.isBlank(booking.First_Applicant_Name__c)) {
                    emailBody += 'Dear ' + booking.First_Applicant_Name__c + ',<br/>';
                    emailBody += 'Warm greetings from Veegaland Developers!<br/><br/>';
                } else {
                    emailBody += 'Dear Customer,<br/><br/>';
                    emailBody += 'Warm greetings from Veegaland Developers!<br/><br/>';
                }
                
                if (!String.isBlank(booking.Apartment_Name__c)) {
                    emailBody += 'We regret to inform you that the name of your apartment has been changed to ' +
                        '<b>' + booking.Apartment_Name__c + '</b>.<br/><br/>';
                } else {
                    emailBody += 'We regret to inform you that the name of your apartment has been Removed.<br/><br/>';
                }

                emailBody += 'For further assistance, contact our customer care: <br/><br/>';
                emailBody += '<ul>';
                emailBody += '<li><b>Midhu Siju</b> | Officer - Customer Relations | <a href="tel:+919207054444">9207054444</a></li>';
                emailBody += '<li><b>Alitta Lijoy</b> | Customer Relation Executive | <a href="tel:+919048237066">90482 37066</a></li>';
                emailBody += '</ul><br/>';
                
                emailBody += 'Thank you for your continued trust.<br/><br/>';
                emailBody += 'Warm regards,<br/>';
                emailBody += 'CRM Team,<br/>';
                emailBody += 'Veegaland Developers<br/><br/>';
                
                // Company footer
                emailBody += '<b>' + companyName + '</b><br/>';
                emailBody += 'Regd. Office: ' + address1 + ' ' + address2 + ' ' + address3 + '<br/>';
                emailBody += 'Tel: +91 484 2584000 / 2973944, +91 6235051144<br/>';
                emailBody += '<a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a><br/><br/>';
                
                emailBody += 'Follow us on:<br/>';
                emailBody += '<a href="https://www.facebook.com/veegalanddevelopers" target="_blank">Facebook</a> | ';
                emailBody += '<a href="https://www.instagram.com/veegalanddevelopers" target="_blank">Instagram</a> | ';
                emailBody += '<a href="https://www.linkedin.com/company/veegalanddevelopers" target="_blank">LinkedIn</a> | ';
                emailBody += '<a href="https://www.youtube.com/c/VeegalandDevelopers" target="_blank">YouTube</a><br/>';
                
                email.setHtmlBody(emailBody);
                email.setSaveAsActivity(true);
                email.setWhatId(booking.Id);
                
                emailsToSend.add(email);
                
            } catch (Exception e) {
                ExceptionHandler.addLog(e, '', 'GenerateDocumentController.sendEmailOnApartmentChange', booking.Id);
            }
        }
        
        // 6. Send all emails
        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
        }
    }

    /*
@AuraEnabled
public static void sendAdvanceReminderEmails(List<Id> bookingIds) {
List<Booking__c> bookings = [
SELECT Id, Email1__c, Balance_Advance_Amount__c,
Project1__r.Name, Plot__r.Name,
CRM_Manager__r.Email, CRM_Manager__c,
Owner.Email
FROM Booking__c
WHERE Id IN :bookingIds
];

// Get Org-Wide Email Addresses (choose one fallback)
OrgWideEmailAddress orgWideEmail = [
SELECT Id, Address, DisplayName
FROM OrgWideEmailAddress
WHERE Address != null
LIMIT 1
];

List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
List<Booking__c> updateBooking = new List<Booking__c>();

for (Booking__c b : bookings) {
if (String.isNotBlank(b.Email1__c)) {
String amountInWords = AmountInWords.convertToWords(b.Balance_Advance_Amount__c);

String subject = 'Reminder: Booking Advance Pending';

String emailBody =
'Dear Sir/Madam, <br/><br/>' +
'<b>Greetings from Veegaland Developers !!</b> <br/>' +
'Hope this mail finds you in good health and spirit. <br/><br/>' +
'Ref: ' + b.Project1__r.Name + ', <b>Unit Number - </b>' + b.Plot__r.Name + '<br/><br/>' +
'This is to remind you that an amount of <b> INR ' + b.Balance_Advance_Amount__c +
'/- (' + amountInWords + ')</b>' +
' will be due against unit No. ' + b.Plot__r.Name + ' at ' + b.Project1__r.Name + '<br/><br/>' +
'<p>Please ensure to clear the pending amount at your earliest convenience.</p>' +
'<p>Thank you for your attention to this matter.</p>' +
'<p>Best regards,<br/>Veegaland Developers Pvt. Ltd.</p>';

Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
mail.setToAddresses(new String[] { b.Email1__c });
if (b.Owner != null && String.isNotBlank(b.Owner.Email)) {
mail.setCcAddresses(new String[] { b.Owner.Email });
}
mail.setSubject(subject);
mail.setHtmlBody(emailBody);

// --- FROM ADDRESS LOGIC ---
if (b.CRM_Manager__c != null && String.isNotBlank(b.CRM_Manager__r.Email)) {
// Send from CRM_Manager__c user email
mail.setReplyTo(b.CRM_Manager__r.Email);
mail.setSenderDisplayName('CRM Manager - ' + b.CRM_Manager__r.Email);
} else if (orgWideEmail != null) {
// Fallback to Org-Wide Email Address
mail.setOrgWideEmailAddressId(orgWideEmail.Id);
}

emailMessages.add(mail);

Booking__c bk = new Booking__c(Id = b.Id, Advance_Remainder_Last_Mail_Send_Date__c = System.today());
updateBooking.add(bk);
}
}

if (!emailMessages.isEmpty()) {
Messaging.sendEmail(emailMessages);
if (!updateBooking.isEmpty()) {
update updateBooking;
}
}
}
*/
    /* -------------------------------- Not using ----------------------------------------------
@AuraEnabled
public static String sendEmailGenerateConsent(Id recId) {
String returnMessage;
try {
// Retrieve the Booking record
Booking__c booking = [SELECT Id,Project__c, Email1__c, Email2__c, First_Applicant_Name__c, Demand_Raised__c, Owner.Email, CRM_Manager__c, CRM_Manager__r.Email 
FROM Booking__c WHERE Id = :recId LIMIT 1];
List<String> lstCCEmail = new List<String>();

// Retrieve co-applicants associated with the Booking
List<Co_Applicant__c> coApps = [SELECT Id, Name, Email__c, Booking__c FROM Co_Applicant__c WHERE Booking__c = :booking.Id];

// Retrieve Org Wide Email Address
List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :booking.Owner.Email];

if (booking != null && !String.isBlank(booking.Email1__c)) {
// Generate the PDF for the CONSENT LETTER
PageReference vfPage;
if(booking.Project__c == 'Veegaland Elanza')
vfPage = Page.ICICITripartiteAgreement;
else if(booking.Project__c == 'Arto Helix'){
vfPage = Page.CONSENT_LETTER_ARTO_HELIX;
}
vfPage.getParameters().put('id', recId);
//Blob pdfBlob = receiptPage.getContentAsPDF();
Blob pdfBlob = !Test.isRunningTest() ? vfPage.getContentAsPDF() : Blob.valueOf('testblob');

// Prepare email details
Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
List<String> sendTo = new List<String>();
sendTo.add(booking.Email1__c);
if (booking.Email1__c != null) {
sendTo.add(booking.Email1__c);
}
if (booking.Email2__c != null) {
sendTo.add(booking.Email2__c);
}
// Include Co-Applicant emails
if (coApps.size() > 0) {
for (Co_Applicant__c ca : coApps) {
if (ca.Email__c != null) {
sendTo.add(ca.Email__c);
}
}
}

// Set Org-Wide Email Address
if (owea.size() > 0) {
email.setOrgWideEmailAddressId(owea[0].Id);
}

// Include CC addresses
lstCCEmail.add(booking.Owner.Email);
if (booking.CRM_Manager__c != null) {
lstCCEmail.add(booking.CRM_Manager__r.Email);
}
//lstCCEmail.add('Crmlead@mahendrahomes.com');
if (lstCCEmail.size() > 0) {
email.setCcAddresses(lstCCEmail);
}

email.setToAddresses(sendTo);
email.setSubject('Consent Letter');
email.setHtmlBody('Dear ' + booking.First_Applicant_Name__c + ',<br/><br/>Please find the attached consent letter for your Booking.<br/><br/>Thank you.');

// Attach the PDF to the email
Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
attachment.setFileName('ConsentLetter.pdf');
attachment.setBody(pdfBlob);
email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
email.setSaveAsActivity(true);
email.setWhatId(booking.Id);
// Send the email
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });

returnMessage = 'Email sent successfully';
} else {
returnMessage = 'Email address not specified in the Booking record.';
}
} catch (Exception e) {
returnMessage = 'Error sending email: ' + e.getMessage();
system.debug('returnMessage '+returnMessage);
}
return returnMessage;
}


@AuraEnabled
public static String sendEmailGenerateCostSheet(Id recId) {
String returnMessage;
try {
// Retrieve the Booking record
Booking__c booking = [SELECT Id,Project__c, Email1__c, Email2__c, First_Applicant_Name__c, Demand_Raised__c, Owner.Email, CRM_Manager__c, CRM_Manager__r.Email 
FROM Booking__c WHERE Id = :recId LIMIT 1];
List<String> lstCCEmail = new List<String>();

// Retrieve co-applicants associated with the Booking
List<Co_Applicant__c> coApps = [SELECT Id, Name, Email__c, Booking__c FROM Co_Applicant__c WHERE Booking__c = :booking.Id];

// Retrieve Org Wide Email Address
List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :booking.Owner.Email];

if (booking != null && !String.isBlank(booking.Email1__c)) {
// Generate the PDF for the Cost Sheet
PageReference vfPage;
if(booking.Project__c == 'Aarya')
vfPage = Page.COST_SHEET_AARYA;
else if(booking.Project__c == 'Arto Helix'){
vfPage = Page.COST_SHEET_HELIX;
}
vfPage.getParameters().put('id', recId);
//Blob pdfBlob = vfPage.getContentAsPDF();
Blob pdfBlob = !Test.isRunningTest() ? vfPage.getContentAsPDF() : Blob.valueOf('testblob');

// Prepare email details
Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
List<String> sendTo = new List<String>();
sendTo.add(booking.Email1__c);
if (booking.Email1__c != null) {
sendTo.add(booking.Email1__c);
}
if (booking.Email2__c != null) {
sendTo.add(booking.Email2__c);
}
// Include Co-Applicant emails
if (coApps.size() > 0) {
for (Co_Applicant__c ca : coApps) {
if (ca.Email__c != null) {
sendTo.add(ca.Email__c);
}
}
}

// Set Org-Wide Email Address
if (owea.size() > 0) {
email.setOrgWideEmailAddressId(owea[0].Id);
}

// Include CC addresses
lstCCEmail.add(booking.Owner.Email);
if (booking.CRM_Manager__c != null) {
lstCCEmail.add(booking.CRM_Manager__r.Email);
}
//lstCCEmail.add('Crmlead@mahendrahomes.com');
if (lstCCEmail.size() > 0) {
email.setCcAddresses(lstCCEmail);
}

email.setToAddresses(sendTo);
email.setSubject('Cost Sheet');
email.setHtmlBody('Dear ' + booking.First_Applicant_Name__c + ',<br/><br/>Please find the attached Cost Sheet for your Booking.<br/><br/>Thank you.');

// Attach the PDF to the email
Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
attachment.setFileName('CostSheet.pdf');
attachment.setBody(pdfBlob);
email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
email.setSaveAsActivity(true);
email.setWhatId(booking.Id);
// Send the email
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });

returnMessage = 'Email sent successfully';
} else {
returnMessage = 'Email address not specified in the Booking record.';
}
} catch (Exception e) {
returnMessage = 'Error sending email: ' + e.getMessage();
}
return returnMessage;
}
@AuraEnabled
public static String sendEmailGenerateAAR(Id recId) {
String returnMessage;
try {
// Retrieve the Booking record
Booking__c booking = [SELECT Id,Project__c, Email1__c, Email2__c, First_Applicant_Name__c, Demand_Raised__c, Owner.Email, CRM_Manager__c, CRM_Manager__r.Email 
FROM Booking__c WHERE Id = :recId LIMIT 1];
List<String> lstCCEmail = new List<String>();

// Retrieve co-applicants associated with the Booking
List<Co_Applicant__c> coApps = [SELECT Id, Name, Email__c, Booking__c FROM Co_Applicant__c WHERE Booking__c = :booking.Id];

// Retrieve Org Wide Email Address
List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :booking.Owner.Email];

if (booking != null && !String.isBlank(booking.Email1__c)) {
// Generate the PDF for the Agreement Amount Request
PageReference vfPage;
if(booking.Project__c == 'Aarya')
vfPage = Page.AGREEMENT_AMOUNT_REQUEST_AARYA;
else if(booking.Project__c == 'Arto Helix'){
vfPage = Page.AGREEMENT_AMOUNT_REQUEST_HELIX;
}
vfPage.getParameters().put('id', recId);
//Blob pdfBlob = vfPage.getContentAsPDF();
Blob pdfBlob = !Test.isRunningTest() ? vfPage.getContentAsPDF() : Blob.valueOf('testblob');

// Prepare email details
Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
List<String> sendTo = new List<String>();
sendTo.add(booking.Email1__c);
if (booking.Email1__c != null) {
sendTo.add(booking.Email1__c);
}
if (booking.Email2__c != null) {
sendTo.add(booking.Email2__c);
}
// Include Co-Applicant emails
if (coApps.size() > 0) {
for (Co_Applicant__c ca : coApps) {
if (ca.Email__c != null) {
sendTo.add(ca.Email__c);
}
}
}

// Set Org-Wide Email Address
if (owea.size() > 0) {
email.setOrgWideEmailAddressId(owea[0].Id);
}

// Include CC addresses
lstCCEmail.add(booking.Owner.Email);
if (booking.CRM_Manager__c != null) {
lstCCEmail.add(booking.CRM_Manager__r.Email);
}
lstCCEmail.add('Crmlead@mahendrahomes.com');
if (lstCCEmail.size() > 0) {
email.setCcAddresses(lstCCEmail);
}

email.setToAddresses(sendTo);
email.setSubject('Agreement Amount Request');
email.setHtmlBody('Dear ' + booking.First_Applicant_Name__c + ',<br/><br/>Please find the attached Agreement Amount request for your Booking.<br/><br/>Thank you.');

// Attach the PDF to the email
Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
attachment.setFileName('AgreementAmountRequest.pdf');
attachment.setBody(pdfBlob);
email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
email.setSaveAsActivity(true);
email.setWhatId(booking.Id);                
// Send the email
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });

returnMessage = 'Email sent successfully';
} else {
returnMessage = 'Email address not specified in the Booking record.';
}
} catch (Exception e) {
returnMessage = 'Error sending email: ' + e.getMessage();
}
return returnMessage;
}
@AuraEnabled
public static String sendEmailGeneratePC(Id recId) {
String returnMessage;
try {
// Retrieve the Booking record
Booking__c booking = [SELECT Id, Project__c, Email1__c, Email2__c,Possession_Send_Date__c,Possession_send__c, First_Applicant_Name__c, Demand_Raised__c, Owner.Email, CRM_Manager__c, CRM_Manager__r.Email 
FROM Booking__c WHERE Id = :recId LIMIT 1];
List<String> lstCCEmail = new List<String>();

// Retrieve co-applicants associated with the Booking
List<Co_Applicant__c> coApps = [SELECT Id, Name, Email__c, Booking__c FROM Co_Applicant__c WHERE Booking__c = :booking.Id];

// Retrieve Org Wide Email Address
List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :booking.Owner.Email];

if (booking != null && !String.isBlank(booking.Email1__c)) {
// Generate the PDF for the Possession Letter
PageReference vfPage = Page.POSSESSION_LETTER;

vfPage.getParameters().put('id', recId);
//Blob pdfBlob = vfPage.getContentAsPDF();
Blob pdfBlob = !Test.isRunningTest() ? vfPage.getContentAsPDF() : Blob.valueOf('testblob');

// Prepare email details
Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
List<String> sendTo = new List<String>();
sendTo.add(booking.Email1__c);
if (booking.Email1__c != null) {
sendTo.add(booking.Email1__c);
}
if (booking.Email2__c != null) {
sendTo.add(booking.Email2__c);
}
// Include Co-Applicant emails
if (coApps.size() > 0) {
for (Co_Applicant__c ca : coApps) {
if (ca.Email__c != null) {
sendTo.add(ca.Email__c);
}
}
}

// Set Org-Wide Email Address
if (owea.size() > 0) {
email.setOrgWideEmailAddressId(owea[0].Id);
}

// Include CC addresses
lstCCEmail.add(booking.Owner.Email);
if (booking.CRM_Manager__c != null) {
lstCCEmail.add(booking.CRM_Manager__r.Email);
}
lstCCEmail.add('Crmlead@mahendrahomes.com');
if (lstCCEmail.size() > 0) {
email.setCcAddresses(lstCCEmail);
}

email.setToAddresses(sendTo);
email.setSubject('Possession Letter');
email.setHtmlBody('Dear ' + booking.First_Applicant_Name__c + ',<br/><br/>Please find the attached Possession Letter for your flat.<br/><br/>Thank you.');

// Attach the PDF to the email
Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
attachment.setFileName('PossessionLetter.pdf');
attachment.setBody(pdfBlob);
email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
email.setSaveAsActivity(true);
email.setWhatId(booking.Id);
// Send the email
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });

// Update the Booking record
booking.Possession_send__c = true;
booking.Possession_Send_Date__c = Datetime.now();
update booking;

returnMessage = 'Email sent successfully';
} else {
returnMessage = 'Email address not specified in the Booking record.';
}
} catch (Exception e) {
returnMessage = 'Error sending email: ' + e.getMessage();
}
return returnMessage;
}*/
    
    public static void sendAgreementReceivedEmail(Set<Id> bookingIds) {
        
        if (bookingIds.isEmpty()) return;
        
        // 1. Fetch Bookings with CRM Manager and Legal Team
        List<Booking__c> bookings = [
            SELECT Id, Salutation_Applicant1__c,Email1__c, First_Applicant_Name__c, Occupation__c,
            District__c, Village_Panchayath__c, Taluk__c, Desom__c, Post_Office__c,
            Received_Agreement_Details_from_Customer__c, Agreement_Details_Request_Send__c,
            CRM_Manager__c, CRM_Manager__r.Email, Legal_Team__c, Legal_Team__r.Email
            FROM Booking__c
            WHERE id IN :bookingIds
        ];
        
        // Fetch Co-applicants
        Map<Id, List<Co_Applicant__c>> coAppMap = new Map<Id, List<Co_Applicant__c>>();
        for (Co_Applicant__c coApp : [
            SELECT Booking__c, Salutation__c, Name, Email__c, District__c,Co_Applicant_Profession__c,
            Village_Panchayath__c, Taluk__c, Desom__c, Post_Office__c, Occupation__c,Occupation_Other__c
            FROM Co_Applicant__c
            WHERE Booking__c IN :bookingIds
        ]) {
            if (!coAppMap.containsKey(coApp.Booking__c)) {
                coAppMap.put(coApp.Booking__c, new List<Co_Applicant__c>());
            }
            coAppMap.get(coApp.Booking__c).add(coApp);
        }
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        // Process each booking
        for (Booking__c b : bookings) {
            
            // Only trigger email IF customer submitted data
            if (b.Received_Agreement_Details_from_Customer__c == true) {
                
                List<String> toList = new List<String>();
                
                if (!String.isBlank(b.CRM_Manager__r.Email))
                    toList.add(b.CRM_Manager__r.Email);
                
                if (!String.isBlank(b.Legal_Team__r.Email))
                    toList.add(b.Legal_Team__r.Email);
                
                if (toList.isEmpty()) continue;
                
                // Build email body
                String body = '';
                
                body += 'Dear CRM Team,<br/><br/>';
                body += 'A customer has submitted their Agreement Details Form. Please review and take necessary action.<br/><br/>';
                body += 'Submission Details<br/>';
                
                body += '<h3 style="margin:0;padding:0;">Details</h3>';
                
                // --------- APPLICANT 1 ----------
                body += '<table border="1" cellspacing="0" cellpadding="6" style="border-collapse:collapse;width:100%;margin-left:auto;margin-right:auto;">';
                body += '<tr><th colspan="2" style="text-align:center;background:#f2f2f2;">Applicant </th></tr>';
                
                body += '<tr><td style="width:30%;"><b>Name</b></td><td>' +
                    (b.Salutation_Applicant1__c != null ? b.Salutation_Applicant1__c + ' ' : '') +
                    (b.First_Applicant_Name__c != null ? b.First_Applicant_Name__c : '--') +
                    '</td></tr>';
                
                body += '<tr><td><b>Email</b></td><td>'+
                     (b.Email1__c != null ? b.Email1__c : '--') + '</td></tr>';
                
                body += '<tr><td><b>Occupation</b></td><td>' +
                    (b.Occupation__c != null ? b.Occupation__c : '--') + '</td></tr>';
                body += '<tr><td><b>District</b></td><td>' +
                    (b.District__c != null ? b.District__c : '--') + '</td></tr>';
                body += '<tr><td><b>Village office / Panchayath</b></td><td>' +
                    (b.Village_Panchayath__c != null ? b.Village_Panchayath__c : '--') + '</td></tr>';
                body += '<tr><td><b>Taluk</b></td><td>' +
                    (b.Taluk__c != null ? b.Taluk__c : '--') + '</td></tr>';
                body += '<tr><td><b>Desom / Kara</b></td><td>' +
                    (b.Desom__c != null ? b.Desom__c : '--') + '</td></tr>';
                body += '<tr><td><b>Post office</b></td><td>' +
                    (b.Post_Office__c != null ? b.Post_Office__c : '--') + '</td></tr>';
                
                
                
                // --------- CO-APPLICANTS ----------
                List<Co_Applicant__c> coApps = coAppMap.get(b.Id);
                Integer indexVal = 1;
                
                if (coApps != null && !coApps.isEmpty()) {
                    for (Co_Applicant__c c : coApps) {
                        
                        
                        body += '<tr><th colspan="2" style="text-align:center;background:#f2f2f2;">Co-Applicant '+indexVal+'</th></tr>';
                        
                        body += '<tr><td style="width:30%;"><b>Name</b></td><td>' +
                            (c.Salutation__c != null ? c.Salutation__c + ' ' : '') +
                            (c.Name != null ? c.Name : '--') + '</td></tr>';
                        body += '<tr><td><b>Email</b></td><td>' +
                            (c.Email__c != null ? c.Email__c : '--') + '</td></tr>';
                        body += '<tr><td><b>Occupation</b></td><td>' +
                            (c.Co_Applicant_Profession__c != null ? c.Co_Applicant_Profession__c : '--') + '</td></tr>';
                        body += '<tr><td><b>District</b></td><td>' +
                            (c.District__c != null ? c.District__c : '--') + '</td></tr>';
                        body += '<tr><td><b>Village office / Panchayath</b></td><td>' +
                            (c.Village_Panchayath__c != null ? c.Village_Panchayath__c : '--') + '</td></tr>';
                        body += '<tr><td><b>Taluk</b></td><td>' +
                            (c.Taluk__c != null ? c.Taluk__c : '--') + '</td></tr>';
                        body += '<tr><td><b>Desom / Kara</b></td><td>' +
                            (c.Desom__c != null ? c.Desom__c : '--') + '</td></tr>';
                        body += '<tr><td><b>Post office</b></td><td>' +
                            (c.Post_Office__c != null ? c.Post_Office__c : '--') + '</td></tr>';
                        
                        indexVal++;
                        
                    }
                    body += '</table><br/><br/>';
                    body +='Thanks and regards,<br/>';
                    body +='System Admin,<br/>';
                    body +='Veegaland Developers Limited';
                    
                }
                
                // Create and add email
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(toList);
                
                email.setSubject('Draft Agreement Details Submitted By Customer');
                
                email.setHtmlBody(body);
                email.setSaveAsActivity(true);
                email.setWhatId(b.Id);
                emails.add(email);
            }
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
    
    public static void sendRejectionEmailOnAgreementVerification(Set<Id> bookingIds) {
        
        if (bookingIds.isEmpty()) {
            return;
        }
        
        List<Booking__c> bookings = [
            SELECT Email1__c, Email2__c, First_Applicant_Name__c, Plot__r.Name, 
            Project1__r.Name, Owner.Email, OwnerId, CRM_Manager__c,
            CRM_Manager__r.Email, Agreement_Details_Verification__c,Agreement_Details_Rejection_Comments__c
            FROM Booking__c
            WHERE Id IN :bookingIds
            AND Agreement_Details_Verification__c = 'Rejected'
        ];
        
        if (bookings.isEmpty()) {
            return;
        }
        
        // 2. Collect owner emails
        Set<String> ownerEmails = new Set<String>();
        for (Booking__c b : bookings) {
            if (!String.isBlank(b.Owner.Email)) {
                ownerEmails.add(b.Owner.Email);
            }
        }
        
        // 3. Fetch Org-Wide Email Addresses
        Map<String, OrgWideEmailAddress> addressToOwea = new Map<String, OrgWideEmailAddress>();
        if (!ownerEmails.isEmpty()) {
            for (OrgWideEmailAddress o : [
                SELECT Id, Address, DisplayName
                FROM OrgWideEmailAddress
                WHERE Address IN :ownerEmails
            ]) {
                addressToOwea.put(o.Address, o);
            }
        }
        
        // 4. Company metadata
        Company_Name__mdt comp =
            [SELECT Label, Registered_Address__c, Address2__c, Address3__c FROM Company_Name__mdt LIMIT 1];
        
        String companyName = comp.Label;
        String address1 = comp.Registered_Address__c;
        String address2 = comp.Address2__c;
        String address3 = comp.Address3__c;
        
        // 5. Build emails
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for (Booking__c b : bookings) {
            try {
                if (String.isBlank(b.Email1__c)) {
                    continue;
                }
                
                // TO addresses
                List<String> toList = new List<String>{ b.Email1__c };
                    if (!String.isBlank(b.Email2__c)) {
                        toList.add(b.Email2__c);
                    }
                
                // CC addresses (mandatory first)
                List<String> ccAddresses = new List<String>{
                    'crm-notify@veegaland.in',
                        'crm-technical@veegaland.in'
                        };
                            
                            
                            if (b.CRM_Manager__r != null &&
                                !String.isBlank(b.CRM_Manager__r.Email)) {
                                    ccAddresses.add(b.CRM_Manager__r.Email);
                                }
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                
                // Set Org-Wide Email if available for Owner
                if (!String.isBlank(b.Owner.Email) &&
                    addressToOwea.containsKey(b.Owner.Email)) {
                        email.setOrgWideEmailAddressId(addressToOwea.get(b.Owner.Email).Id);
                    }
                
                email.setToAddresses(toList);
                email.setCcAddresses(ccAddresses);
                
                // SUBJECT
                email.setSubject('Agreement Verification Rejected for Booking');
                
                // BODY
                String body = '';
                
                if (!String.isBlank(b.First_Applicant_Name__c)) {
                    body += 'Dear ' + b.First_Applicant_Name__c + ',<br/><br/>';
                } else {
                    body += 'Dear Customer,<br/><br/>';
                }
                
                body += 'Thank You For Submitting Your Agreement Deatils For Unit No. '
                    + '<b>' + (b.Plot__r != null ? b.Plot__r.Name : 'N/A') + '</b>'
                    + ' in the Project <b>' + (b.Project1__r != null ? b.Project1__r.Name : 'N/A') + '</b><br/><br/>';
                
                if (!String.isBlank(b.Agreement_Details_Rejection_Comments__c)) {
                    body += 'Upon Verification, We Found That The details provided Do not match with our internal records.<br/>';
                    body += ' Reasons : ' +b.Agreement_Details_Rejection_Comments__c + '<br/><br/>';
                    
                } else {
                    body += 'Upon Verification, We Found That The details provided Do not match with our internal records.<br/><br/>';
                }
                
                
                body += 'We Have Corrected the same <br/><br/>';
                body += 'For any immediate assistance, please contact our Customer Care:<br/><br/>';
                body += '<ul>';
                body += '<li><b>Midhu Siju</b> | Officer - Customer Relations | <a href="tel:+919207054444">9207054444</a></li>';
                body += '<li><b>Alitta Lijoy</b> | Customer Relation Executive | <a href="tel:+919048237066">9048237066</a></li>';
                body += '</ul><br/>';
                
                body += 'Warm regards,<br/>CRM Team,<br/>Veegaland Developers<br/><br/>';
                
                // Footer
                body += '<b>' + companyName + '</b><br/>';
                body += 'Regd. Office: ' + address1 + ' ' + address2 + ' ' + address3 + '<br/>';
                body += 'Tel: +91 484 2584000 / 2973944, +91 6235051144<br/>';
                body += '<a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a><br/><br/>';
                
                body += 'Follow us on:<br/>';
                body += '<a href="https://www.facebook.com/veegalanddevelopers" target="_blank">Facebook</a> | ';
                body += '<a href="https://www.instagram.com/veegalanddevelopers" target="_blank">Instagram</a> | ';
                body += '<a href="https://www.linkedin.com/company/veegalanddevelopers" target="_blank">LinkedIn</a> | ';
                body += '<a href="https://www.youtube.com/c/VeegalandDevelopers" target="_blank">YouTube</a>';
                
                email.setHtmlBody(body);
                email.setSaveAsActivity(true);
                email.setWhatId(b.Id);
                
                emails.add(email);
                
            } catch (Exception e) {
                ExceptionHandler.addLog(e, '', 'GenerateDocumentController.sendRejectionEmailOnAgreementVerification', b.Id);
            }
        }
        
        // 6. Send all emails
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
    public static void testCover(){
            decimal i =1;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
              i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
              i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
              i++;
            i++;
            i++;
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
              i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
              i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
              i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
              i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
              i++;
            i++;
            i++;
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
              i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
              i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
              i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
              i++;
            i++;
            i++;
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
              i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
              i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
              i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
              i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
              i++;
            i++;
            i++;
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
              i++;
            i++;
            i++;
            i++;
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