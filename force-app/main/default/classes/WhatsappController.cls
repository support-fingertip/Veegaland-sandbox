public class WhatsappController {
    
    public static void sendReminderForSchedules(List<Id> paymentScheduleIds) {
        try {
            if (paymentScheduleIds.isEmpty()) return;
            
            List<Payment_Schedule__c> schedules = [
                SELECT Id, S_No__c, Pending_Amount__c, Is_Demanded__c, Payment_Due_Date__c,
                Booking__r.First_Applicant_Name__c,
                Booking__r.Email1__c,
                Booking__r.Mobile_Primary__c,
                Received_Amount1__c,
                Booking__r.Stage__c,
                Booking__r.Plot__r.Name,
                Booking__r.Project1__r.Name,
                Booking__r.Finance_User__r.Name
                FROM Payment_Schedule__c
                WHERE Id IN :paymentScheduleIds
            ];
            
            for (Payment_Schedule__c ps : schedules) {
                try {
                    if (!ps.Is_Demanded__c) continue;
                    if (ps.Pending_Amount__c <= 0) continue;
                    
                    Booking__c booking = ps.Booking__r;
                    if (booking.Stage__c == 'Unit Swap' || booking.Stage__c == 'Cancellation') continue;
                    if (String.isBlank(booking.Email1__c)) continue;
                    if (String.isBlank(booking.Mobile_Primary__c)) continue;
                    if (String.isBlank(booking.Finance_User__r.Name)) continue;
                    
                    String dueDateFormatted = formatDueDate(ps.Payment_Due_Date__c);
                    
                    List<String> vars = new List<String>{
                        booking.First_Applicant_Name__c,                     // var1
                            String.valueOf(ps.Pending_Amount__c),               // var2
                            booking.Plot__r != null ? booking.Plot__r.Name : '',            // var3
                                booking.Project1__r != null ? booking.Project1__r.Name : '',    // var4
                                    booking.Finance_User__r.Name                        // var5
                                    };
                                        
                                        String phone = booking.Mobile_Primary__c;
                    
                    WhatsAppMessageSender.sendWhatsAppMessage(
                        phone,
                        'payment_due_reminder',
                        vars,
                        null
                    );
                    
                } catch (Exception innerEx) {
                    System.debug('Error processing schedule Id ' + ps.Id + ': ' + innerEx.getMessage());
                }
            }
            
        } catch (Exception e) {
            System.debug('Bulk error: ' + e.getMessage());
        }
    }
    
    
    public static void CollectBookingFormDetails(List<Id> quoteIds) {
        List<Quote__c> quotes = [
            SELECT Id, Primary_Applicant_Name__c, Document_Request_Email_Send_Time__c,
            Owner.Name, Owner.Email, Owner.Phone, Lead_Phone__c,Leads__r.Name
            FROM Quote__c
            WHERE Id IN :quoteIds
        ];
        
        for (Quote__c quote : quotes) {
            List<String> vars = new List<String>();
            
            // var1: Primary Applicant Name
            String var1 = quote.Leads__r.Name;
            
            // var2: Deadline (3 days from Document_Request_Email_Send_Time__c or now)
            Datetime baseDate = quote.Document_Request_Email_Send_Time__c != null
                ? quote.Document_Request_Email_Send_Time__c
                : Datetime.now();
            
            Date dueDate = baseDate.addDays(3).date(); // Convert to Date if you want date-only
            String var2 = formatDueDate(dueDate);
            
            // var3: Upload Link
            String quoteLink = 'https://site-speed-6226.my.salesforce-sites.com/BookingForm?id=' + quote.Id;
            // Optionally format as hyperlink text (some templates allow this)
            String var3 = quoteLink;
            //var3 = quoteLink;
            
            // var4: Sales Executive Details
            String var4 = quote.Owner.Name + ' | ' + quote.Owner.Email + ' | ' + quote.Owner.Phone;
            // String var5 = quote.Owner.Email + ' | ' + quote.Owner.Phone;
            
            vars.add(var1);
            vars.add(var2);
            vars.add(var3);
            vars.add(var4);
            // vars.add(var5);
            
            // Send WhatsApp message
            WhatsAppMessageSender.sendWhatsAppMessage(
                quote.Lead_Phone__c, // Assuming this has country code
                'collect_customer_details_4_booking_form',
                vars,
                null
            );
            
        }
    }
    
    public static void SendBookingFormApproval(List<Id> quoteIds) {
        if (quoteIds == null || quoteIds.isEmpty()) return;
        
        List<Quote__c> quotes = [
            SELECT Id, Name, Primary_Applicant_Name__c, Lead_Phone__c,
            Leads__r.Name, Owner.Name, Owner.Email, Owner.Phone
            FROM Quote__c
            WHERE Id IN :quoteIds
        ];
        List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
                string companyName;
                
                if(!companyDetails.isEmpty()){
                    companyName = companyDetails[0].Label;
                       
                }
        for (Quote__c quote : quotes) {
            try {
                List<String> vars = new List<String>();
                
                // var1: Customer Name
                String customerName = String.isNotBlank(quote.Leads__r.Name) ? quote.Leads__r.Name : 'Customer';
                vars.add(customerName);
                
                // var2: Booking Form URL
                String bookingUrl = 'https://site-speed-6226.my.salesforce-sites.com/Booking?id=' + quote.Id;
                vars.add(bookingUrl);
                
                // var3: Owner Email | Phone
                String ownerEmail = String.isNotBlank(quote.Owner.Email) ? quote.Owner.Email : 'systems@veegaland.in';
                String ownerPhone = String.isNotBlank(quote.Owner.Phone) ? quote.Owner.Phone : '';
                String contactDetails = ownerEmail + (String.isNotBlank(ownerPhone) ? ' | ' + ownerPhone : '');
                vars.add(contactDetails);
                
                // var4: Owner Name
                vars.add(quote.Owner.Name != null ? quote.Owner.Name : '');
                
                // var5: Footer
                String footer = 'Email: ' + ownerEmail + companyName;
                vars.add(footer);
                
                // Normalize phone number
                String phone = quote.Lead_Phone__c != null ? quote.Lead_Phone__c.replaceAll('[^0-9]', '') : null;
                
                System.debug('--- WhatsApp SendBookingFormApproval ---');
                System.debug('Quote Id: ' + quote.Id);
                System.debug('Phone: ' + phone);
                System.debug('Template: sending_booking_form');
                System.debug('Vars: ' + vars);
                
                if (String.isNotBlank(phone) && vars.size() == 5) {
                    WhatsAppMessageSender.sendWhatsAppMessage(phone, 'sending_booking_form', vars, null);
                } else {
                    System.debug('Invalid phone number or missing variables.');
                }
            } catch (Exception e) {
                System.debug('Error sending WhatsApp message: ' + e.getMessage());
            }
        }
    }
    
    
    
    public static void SendRegisteredSaleAgreement(List<Id> bookingIds) {
        if (bookingIds == null || bookingIds.isEmpty()) return;
        
        // Fetch bookings and related CRM Manager
        List<Booking__c> bookings = [
            SELECT Id, First_Applicant_Name__c, Mobile_Primary__c,
            CRM_Manager__r.Name
            FROM Booking__c
            WHERE Id IN :bookingIds
        ];
        
        /* // Map of Booking Ids to ContentDocumentLink Ids
Map<Id, List<Id>> bookingToContentDocIds = new Map<Id, List<Id>>();

// Fetch ContentDocumentLinks related to bookings
List<ContentDocumentLink> docLinks = [
SELECT ContentDocumentId, LinkedEntityId
FROM ContentDocumentLink
WHERE LinkedEntityId IN :bookingIds
];

for (ContentDocumentLink link : docLinks) {
if (!bookingToContentDocIds.containsKey(link.LinkedEntityId)) {
bookingToContentDocIds.put(link.LinkedEntityId, new List<Id>());
}
bookingToContentDocIds.get(link.LinkedEntityId).add(link.ContentDocumentId);
}

// Flatten all ContentDocumentIds to query ContentVersions
Set<Id> allDocIds = new Set<Id>();
for (List<Id> docIdList : bookingToContentDocIds.values()) {
allDocIds.addAll(docIdList);
}

// Fetch latest ContentVersions titled 'Registered Agreement'
Map<Id, ContentVersion> docIdToVersion = new Map<Id, ContentVersion>();
List<ContentVersion> versions = [
SELECT Id, Title, ContentDocumentId, CreatedDate
FROM ContentVersion
WHERE ContentDocumentId IN :allDocIds
AND Title = 'Registered Agreement'
ORDER BY CreatedDate DESC
];

// Pick the latest version per ContentDocument
for (ContentVersion cv : versions) {
if (!docIdToVersion.containsKey(cv.ContentDocumentId)) {
docIdToVersion.put(cv.ContentDocumentId, cv);
}
}

// Final mapping: Booking Id → ContentVersion
Map<Id, ContentVersion> bookingToVersion = new Map<Id, ContentVersion>();
for (Id bookingId : bookingToContentDocIds.keySet()) {
for (Id docId : bookingToContentDocIds.get(bookingId)) {
if (docIdToVersion.containsKey(docId)) {
bookingToVersion.put(bookingId, docIdToVersion.get(docId));
break; // Only one needed
}
}
}

// Get base domain URL
//String baseUrl = URL.getOrgDomainUrl().toExternalForm();*/
        
        for (Booking__c booking : bookings) {
            try {
                /*// Prepare message variables
List<String> vars = new List<String>();
vars.add(booking.First_Applicant_Name__c != null ? booking.First_Applicant_Name__c : 'Customer');
vars.add(
(booking.CRM_Manager__r != null && booking.CRM_Manager__r.Name != null)
? booking.CRM_Manager__r.Name : ''
);
vars.add('Thank you');

// Prepare file URL
String fileUrl = null;
if (bookingToVersion.containsKey(booking.Id)) {
ContentVersion cv = bookingToVersion.get(booking.Id);
fileUrl = baseUrl + '/sfc/servlet.shepherd/document/download/' + cv.Id;
}*/
                
                // Send WhatsApp message
                String phone = booking.Mobile_Primary__c;
                String template = 'on_original_sale_agreement_shared';
                List<String> vars = new List<String>();
                vars.add('Thank you');
                vars.add('Thank you');
                WhatsAppMessageSender.sendWhatsAppMessage(booking.Mobile_Primary__c, template, vars, null);
                
            } catch (Exception e) {
                System.debug('Error sending message for Booking ' + booking.Id + ': ' + e.getMessage());
            }
        }
    }
    
    
    public static void SendSaleAgreementforReview(List<Id> bookingIds) {
        
        if (bookingIds == null || bookingIds.isEmpty()) return;
        
        // Fetch bookings and related CRM Manager
        List<Booking__c> bookings = [
            SELECT Id, First_Applicant_Name__c, Mobile_Primary__c,
            CRM_Manager__r.Name
            FROM Booking__c
            WHERE Id IN :bookingIds
        ];
        
        for (Booking__c book : bookings) {
            List<String> vars = new List<String>();
            
            // var1: Customer Name
            String var1 = book.First_Applicant_Name__c != null
                ? book.First_Applicant_Name__c
                : 'Customer';
            vars.add(var1);
            
            // var2: Booking Form URL
            String var2 = 'https://site-speed-6226.my.salesforce-sites.com/AgreementApproval?id=' + book.Id;
            vars.add(var2);
            
            
            // Send WhatsApp message
            WhatsAppMessageSender.sendWhatsAppMessage(
                Book.Mobile_Primary__c,
                'send_draft_agreement_for_review',
                vars,
                null
            );
            
        }
    }
    
    public static void RequestCustomerDetailsForSalesAgreement(List<Id> bookingIds) {
        
        if (bookingIds == null || bookingIds.isEmpty()) return;
        
        // Fetch bookings and related CRM Manager
        List<Booking__c> bookings = [
            SELECT Id, First_Applicant_Name__c, Mobile_Primary__c,
            CRM_Manager__r.Name
            FROM Booking__c
            WHERE Id IN :bookingIds
        ];
        
        for (Booking__c book : bookings) {
            List<String> vars = new List<String>();
            
            // var1: Customer Name
            String var1 = book.First_Applicant_Name__c != null
                ? book.First_Applicant_Name__c
                : 'Customer';
            vars.add(var1);
            
            // var2: Booking Form URL
            String var2 = 'https://site-speed-6226.my.salesforce-sites.com/AgreementDetails?id=' + book.Id;
            vars.add(var2);
            
            vars.add(
                (book.CRM_Manager__r != null && book.CRM_Manager__r.Name != null)
                ? book.CRM_Manager__r.Name : '');
            
            // Send WhatsApp message
            WhatsAppMessageSender.sendWhatsAppMessage(
                Book.Mobile_Primary__c, // Assuming this has the country code
                'request_customer_details_for_sales_agreement',
                vars,
                null
            );
            
        }
    }
    
    private static String formatDueDate(Date dueDate) {
        if (dueDate == null) return '';
        
        Integer day = dueDate.day();
        String suffix;
        
        // Determine suffix for day (st, nd, rd, th)
        if (day >= 11 && day <= 13) {
            suffix = 'th';
        } else {
            Integer lastDigit = Math.mod(day, 10);
            switch on lastDigit {
                when 1 { suffix = 'st'; }
                when 2 { suffix = 'nd'; }
                when 3 { suffix = 'rd'; }
                when else { suffix = 'th'; }
            }
        }
        
        // Use DateTime to get month name
        DateTime dt = DateTime.newInstance(dueDate, Time.newInstance(0, 0, 0, 0));
        String month = dt.format('MMMM'); // e.g., "May"
        
        return day + suffix + ' ' + month; // e.g., "10th May"
    }
    
    public static void OnAdvancePaymentCustomerUpload(List<Id> bookingIds) {
        if (bookingIds == null || bookingIds.isEmpty()) return;
        
        List<Booking__c> bookings = [
            SELECT Id, First_Applicant_Name__c, Mobile_Primary__c,
            Finance_User__r.Name, Finance_User__r.Email, Finance_User__r.Phone
            FROM Booking__c
            WHERE Id IN :bookingIds
        ];
        
        for (Booking__c booking : bookings) {
            try {
                List<String> vars = new List<String>();
                
                // Add variables
                String applicantName = booking.First_Applicant_Name__c != null ? booking.First_Applicant_Name__c : 'Customer';
                vars.add(applicantName); // var1
                vars.add(applicantName); // var2
                
                String financeUserName = booking.Finance_User__r != null ? booking.Finance_User__r.Name : 'Finance Team';
                vars.add(financeUserName); // var3
                
                String financeContact = '';
                if (booking.Finance_User__r != null) {
                    List<String> contactParts = new List<String>();
                    if (String.isNotBlank(booking.Finance_User__r.Email)) {
                        contactParts.add(booking.Finance_User__r.Email);
                    }
                    if (String.isNotBlank(booking.Finance_User__r.Phone)) {
                        contactParts.add(booking.Finance_User__r.Phone);
                    }
                    financeContact = String.join(contactParts, ' | ');
                }
                vars.add(financeContact); // var4
                
                String phone = booking.Mobile_Primary__c;
                String template = 'on_adv_paid_screenshot';
                
                WhatsAppMessageSender.sendWhatsAppMessage(phone, template, vars, null);
                
            } catch (Exception e) {
                System.debug('Error sending advance payment message for Booking ' + booking.Id + ': ' + e.getMessage());
            }
        }
    }
    
    public static void BalanceAmountCustomerSubmission(List<Id> bookingIds) {
        if (bookingIds == null || bookingIds.isEmpty()) return;
        
        List<Booking__c> bookings = [
            SELECT Id, First_Applicant_Name__c, Mobile_Primary__c,
            Finance_User__r.Name, Finance_User__r.Email, Finance_User__r.Phone
            FROM Booking__c
            WHERE Id IN :bookingIds
        ];
        
        for (Booking__c booking : bookings) {
            try {
                List<String> vars = new List<String>();
                
                // var1: Primary Applicant Name
                String applicantName = booking.First_Applicant_Name__c != null
                    ? booking.First_Applicant_Name__c
                    : 'Customer';
                vars.add(applicantName);
                
                // var2: Finance User Name | Email | Phone
                String financeDetails = '';
                if (booking.Finance_User__r != null) {
                    List<String> parts = new List<String>();
                    if (String.isNotBlank(booking.Finance_User__r.Name)) {
                        parts.add(booking.Finance_User__r.Name);
                    }
                    if (String.isNotBlank(booking.Finance_User__r.Email)) {
                        parts.add(booking.Finance_User__r.Email);
                    }
                    if (String.isNotBlank(booking.Finance_User__r.Phone)) {
                        parts.add(booking.Finance_User__r.Phone);
                    }
                    financeDetails = String.join(parts, ' | ');
                }
                vars.add(financeDetails);
                
                String phone = booking.Mobile_Primary__c;
                String template = 'on_submitting_balance_amount_receipt';
                
                WhatsAppMessageSender.sendWhatsAppMessage(phone, template, vars, null);
                
            } catch (Exception e) {
                System.debug('Error sending balance amount message for Booking ' + booking.Id + ': ' + e.getMessage());
            }
        }
    }
    
    public static void BookingAdvanceReminder(List<Id> bookingIds) {
        if (bookingIds == null || bookingIds.isEmpty()) return;
        
        List<Booking__c> bookings = [
            SELECT Id,
            First_Applicant_Name__c,
            Mobile_Primary__c,
            Booking_Advance_Amount_Received__c,
            Balance_Advance_Amount__c,
            Plot__r.Name,
            Project1__r.Name,
            Finance_User__r.Name,
            Finance_User__r.Email,
            Finance_User__r.Phone
            FROM Booking__c
            WHERE Id IN :bookingIds
        ];
        
        for (Booking__c booking : bookings) {
            try {
                List<String> vars = new List<String>();
                
                // var1: Primary Applicant Name
                String applicantName = booking.First_Applicant_Name__c != null
                    ? booking.First_Applicant_Name__c
                    : 'Customer';
                vars.add(applicantName);
                
                // var2: Booking Advance Amount Received
                String advanceReceived = booking.Booking_Advance_Amount_Received__c != null
                    ? String.valueOf(booking.Booking_Advance_Amount_Received__c.setScale(2))
                    : '0.00';
                vars.add(advanceReceived);
                
                // var3: Plot Name
                String plotName = booking.Plot__r != null && String.isNotBlank(booking.Plot__r.Name)
                    ? booking.Plot__r.Name
                    : 'N/A';
                vars.add(plotName);
                
                // var4: Project Name
                String projectName = booking.Project1__r != null && String.isNotBlank(booking.Project1__r.Name)
                    ? booking.Project1__r.Name
                    : 'N/A';
                vars.add(projectName);
                
                // var5: Balance Advance Amount
                String balanceAmount = booking.Balance_Advance_Amount__c != null
                    ? String.valueOf(booking.Balance_Advance_Amount__c.setScale(2))
                    : '0.00';
                vars.add(balanceAmount);
                
                // var6: Finance User Name | Email | Phone
                String financeDetails = '';
                if (booking.Finance_User__r != null) {
                    List<String> financeParts = new List<String>();
                    if (String.isNotBlank(booking.Finance_User__r.Name)) {
                        financeParts.add(booking.Finance_User__r.Name);
                    }
                    if (String.isNotBlank(booking.Finance_User__r.Email)) {
                        financeParts.add(booking.Finance_User__r.Email);
                    }
                    if (String.isNotBlank(booking.Finance_User__r.Phone)) {
                        financeParts.add(booking.Finance_User__r.Phone);
                    }
                    financeDetails = String.join(financeParts, ' | ');
                }
                vars.add(financeDetails);
                
                String phone = booking.Mobile_Primary__c;
                String template = 'reminder_collect_balance_booking_adv';
                
                WhatsAppMessageSender.sendWhatsAppMessage(phone, template, vars, null);
                
            } catch (Exception e) {
                System.debug('Error sending booking advance reminder for Booking ' + booking.Id + ': ' + e.getMessage());
            }
        }
    }
    
    public static void agreementHandoverCopySend(List<Id> bookingIds) {
        if (bookingIds == null || bookingIds.isEmpty()) return;
        
        List<Booking__c> bookings = [
            SELECT Id, Name, First_Applicant_Name__c, Mobile_Primary__c,
            Project1__r.Name,
            Owner.Name, Owner.Phone, Owner.Email,
            (SELECT ContentDocument.LatestPublishedVersionId
             FROM ContentDocumentLinks
             WHERE ContentDocument.Title = 'Signed Handover')
            FROM Booking__c
            WHERE Id IN :bookingIds
        ];
            List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
                string companyName;
              
                if(!companyDetails.isEmpty()){
                    companyName = companyDetails[0].Label;
                      
                }
        for (Booking__c booking : bookings) {
            String phone = booking.Mobile_Primary__c;
            if (String.isBlank(phone)) continue;
            
            // Build var2 as "Owner Name | Phone | Email" (email optional)
            String ownerName = booking.Owner.Name != null ? booking.Owner.Name : '';
            String ownerPhone = booking.Owner.Phone != null ? booking.Owner.Phone : '';
            String ownerEmail = String.isNotBlank(booking.Owner.Email) ? booking.Owner.Email : '';
            String ownerDetails = ownerName + ' | ' + ownerPhone + (String.isNotBlank(ownerEmail) ? ' | ' + ownerEmail : '');
            
            // WhatsApp variable mapping
            List<String> varValues = new List<String>{
                booking.First_Applicant_Name__c,  // {{1}}: Customer Name
                    ownerDetails,                       // {{2}}: Owner Details
                    booking.Project1__r.Name,           // {{3}}: Project Name
                    companyName             // {{4}}: Company Name
                    };
                        
                        // Find file URL
                        String fileUrl;
            if (!booking.ContentDocumentLinks.isEmpty()) {
                Id versionId = booking.ContentDocumentLinks[0].ContentDocument.LatestPublishedVersionId;
                fileUrl = URL.getOrgDomainURL().toExternalForm() + '/sfc/servlet.shepherd/version/download/' + versionId;
            } else {
                fileUrl = null;
            }
            
            WhatsAppMessageSender.sendWhatsAppMessage(phone, 'after_soft_handover', varValues, fileUrl);
        }
    }
    public static void afterSaleDeedWhatsAppSend(List<Id> bookingIds) {
        if (bookingIds == null || bookingIds.isEmpty()) return;
        
        List<Booking__c> bookings = [
            SELECT Id, Name, First_Applicant_Name__c, Mobile_Primary__c,
            Project1__r.Name,
            Owner.Name, Owner.Phone, Owner.Email
            FROM Booking__c
            WHERE Id IN :bookingIds
        ];
        List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
                string companyName;
                
                if(!companyDetails.isEmpty()){
                    companyName = companyDetails[0].Label;
                       
                }
        for (Booking__c booking : bookings) {
            String phone = booking.Mobile_Primary__c;
            if (String.isBlank(phone)) continue;
            
            // Build var2: Owner Name | Phone | Email (email optional)
            String ownerName = booking.Owner.Name != null ? booking.Owner.Name : '';
            String ownerPhone = booking.Owner.Phone != null ? booking.Owner.Phone : '';
            String ownerEmail = String.isNotBlank(booking.Owner.Email) ? booking.Owner.Email : '';
            String ownerDetails = ownerName + ' | ' + ownerPhone + (String.isNotBlank(ownerEmail) ? ' | ' + ownerEmail : '');
            
            // WhatsApp variable mapping
            List<String> varValues = new List<String>{
                booking.First_Applicant_Name__c,  // {{1}}: Customer Name
                    ownerDetails,                     // {{2}}: Owner details
                    booking.Project1__r.Name,         // {{3}}: Project Name
                    companyName          // {{4}}: Company Name
                    };
                        
                        // No file to send in this case
                        WhatsAppMessageSender.sendWhatsAppMessage(phone, 'after_sale_deed_registration', varValues, null);
        }
    }
    public static void sendUnitSwapNotification(List<Id> bookingIds) {
        if (bookingIds == null || bookingIds.isEmpty()) return;
        
        List<Booking__c> bookings = [
            SELECT Id, First_Applicant_Name__c, Mobile_Primary__c,
            Swap_Unit__r.Name,
            Swap_Unit__r.Tower__c,
            Swap_Unit__r.BHK_Type__c,
            Swap_Unit__r.Super_built_up_area__c
            FROM Booking__c
            WHERE Id IN :bookingIds
        ];
        List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
                string companyName;
                
                if(!companyDetails.isEmpty()){
                    companyName = companyDetails[0].Label;
                    
                }
        for (Booking__c booking : bookings) {
            String phone = booking.Mobile_Primary__c;
            if (String.isBlank(phone)) continue;
            
            // Null-safe values
            String applicantName = booking.First_Applicant_Name__c != null ? booking.First_Applicant_Name__c : '';
            String tower = booking.Swap_Unit__r != null && booking.Swap_Unit__r.Tower__c != null ? booking.Swap_Unit__r.Tower__c : '_';
            String unitNo = booking.Swap_Unit__r != null && booking.Swap_Unit__r.Name != null ? booking.Swap_Unit__r.Name : '_';
            String unitType = booking.Swap_Unit__r != null && booking.Swap_Unit__r.BHK_Type__c != null ? booking.Swap_Unit__r.BHK_Type__c : '_';
            String area = booking.Swap_Unit__r != null && booking.Swap_Unit__r.Super_built_up_area__c != null
                ? String.valueOf(booking.Swap_Unit__r.Super_built_up_area__c) : '_';
            String company = companyName;
            
            // WhatsApp variables
            List<String> varValues = new List<String>{
                applicantName,  // {{1}}
                    tower,          // {{2}}
                    unitNo,         // {{3}}
                    unitType,       // {{4}}
                    area,           // {{5}}
                    company         // {{6}}
                    };
                        WhatsAppMessageSender.sendWhatsAppMessage(phone, 'unit_swap', varValues, null);
        }
    }
    public static void sendUnitCancellationFromBooking(List<Id> bookingIds) {
    if (bookingIds == null || bookingIds.isEmpty()) return;

    List<Booking__c> bookings = [
        SELECT Id, First_Applicant_Name__c, Mobile_Primary__c,
               Plot__r.Name, Plot__r.Project__r.Name
        FROM Booking__c
        WHERE Id IN :bookingIds
    ];

    for (Booking__c booking : bookings) {
        String phone = booking.Mobile_Primary__c;
        if (String.isBlank(phone)) continue;

        String name = booking.First_Applicant_Name__c != null ? booking.First_Applicant_Name__c : '_';
        String unitNo = booking.Plot__r != null
            ? (booking.Plot__r.Name != null ? booking.Plot__r.Name : (booking.Plot__r.Name != null ? booking.Plot__r.Name : '_'))
            : '';
        String project = booking.Plot__r != null && booking.Plot__r.Project__r != null && booking.Plot__r.Project__r.Name != null
            ? booking.Plot__r.Project__r.Name
            : '_';

        List<String> varValues = new List<String>{
            name, unitNo, project
        };

        WhatsAppMessageSender.sendWhatsAppMessage(phone, 'unit_cancellation_request', varValues, null);
    }
}

}