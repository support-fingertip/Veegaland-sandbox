global class BookingAdvancePendingRemainderBatchClass Implements Schedulable {

    global void execute(SchedulableContext sc) {
        RemainderMail();
    }

    public static void RemainderMail() {
        List<Booking__c> booking = [SELECT Id, Name, Advance_Remainder_Last_Mail_Send_Date__c, CreatedDate, Email1__c, Balance_Advance_Amount__c, Booking_Advance_status__c, Owner.Email, Project__c, Plot__r.Name FROM Booking__c WHERE Balance_Advance_Amount__c != 0.00 AND Booking_Advance_status__c != 'Full Payment Received'];

        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        List<Booking__c> updateBooking = new List<Booking__c>();
        List<id> bookingIdWA = new List<id>();

        if (!booking.isEmpty()) {
            for (Booking__c b : booking) {
                Date nextMailSendDate;
                bookingIdWA.add(b.Id);
                // Calculate the next mail send date
                if (b.Advance_Remainder_Last_Mail_Send_Date__c == null) {
                    nextMailSendDate = b.CreatedDate.date().addDays(2);
                } else {
                    nextMailSendDate = b.Advance_Remainder_Last_Mail_Send_Date__c.addDays(2);
                }

                // Validate that today is the correct day for sending the email
                if (nextMailSendDate == system.today() && String.isNotBlank(b.Email1__c) || Test.isRunningTest()) {
                    string amountInWords = AmountInWords.convertToWords(b.Balance_Advance_Amount__c);// Convert amount to words
                    // Set up email subject
                    String subject = 'Reminder: Booking Advance Pending';

                    // Set up email content (HTML format)
                    String emailBody = 
                        'Dear Sir/Madam, <br/><br/>' +
                        '<b>Greetings from Veegaland Developers !!</b> <br/>' +
                        'Hope this mail finds you in good health and spirit. <br/><br/>' +
                        'Ref:'+ b.Project__c+ ', <b>Unit Number - </b>'+b.Plot__r.Name+'<br/><br/>'+
                        'This is to remind you that an amount of <b> INR '+b.Balance_Advance_Amount__c+'/- ('+amountInWords +')</b> will be due against unit No.'+b.Plot__r.Name+' at '+b.Project__c+' <br/><br/>'+
                        '<p>Please ensure to clear the pending amount at your earliest convenience.</p>' +
                        '<p>Thank you for your attention to this matter.</p>' +
                        '<p>Best regards,<br/>Veegaland Developers Pvt. Ltd.</p>';

                    // Create the email message
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new String[] {b.Email1__c});
                    
                    // Check if Owner exists before accessing Owner.Email
                    if (b.Owner != null && String.isNotBlank(b.Owner.Email)) {
                        mail.setCcAddresses(new String[] {b.Owner.Email});
                    }

                    mail.setSubject(subject);
                    mail.setHtmlBody(emailBody);

                    // Add to email list
                    emailMessages.add(mail);

                    // Prepare for updating the booking record
                    Booking__c bk = new Booking__c();
                    bk.Id = b.Id;
                    bk.Advance_Remainder_Last_Mail_Send_Date__c = system.today();
                    updateBooking.add(bk);
                }
            }

            // Send emails and perform DML update
            if (!emailMessages.isEmpty()) {
                try {
                    Messaging.sendEmail(emailMessages);
                    if (!updateBooking.isEmpty()) {
                        update updateBooking;
                    }
                } catch (DmlException e) {
                      ExceptionHandler.addLog(e,string.valueof(updateBooking),'bookingadvpendingAmountreminder','');  /*Add Exception to error log*/
                    // Log exception with additional details
                    system.debug('Error sending emails or updating records: ' + e.getMessage());
                }
            }
        }
        if (!bookingIdWA.isEmpty()) {
            WhatsappController.BookingAdvanceReminder(bookingIdWA);
        }
    }   
}