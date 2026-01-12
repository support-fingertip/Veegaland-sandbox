global class PendingPaymentReminder implements Database.Batchable<SObject>,  Database.Stateful, Schedulable {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Pending_Amount__c, S_No__c, Booking__c,Received_Amount1__c
            FROM Payment_Schedule__c
            WHERE Is_Demanded__c = true
              AND Pending_Amount__c > 0
              AND Booking__r.Stage__c NOT IN ('Unit Swap', 'Cancellation')
            ORDER BY S_No__c ASC
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Payment_Schedule__c> scope) {
        Set<Id> bookingIds = new Set<Id>();
        list<Id> psIds = new list<Id>();
        for (Payment_Schedule__c ps : scope) {
            if (ps.Booking__c != null) {
                bookingIds.add(ps.Booking__c);
            }
        }

        Map<Id, Booking__c> bookingMap = new Map<Id, Booking__c>([
            SELECT Id, First_Applicant_Name__c, Email1__c, Mobile_Primary__c,Booking__r.First_Applicant_Name__c,
                Stage__c,
                Plot__r.Name,
                Project1__r.Name
            FROM Booking__c
            WHERE Id IN :bookingIds
        ]);

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Payment_Schedule__c ps : scope) {
            psIds.add(ps.Id);
            Booking__c booking = bookingMap.get(ps.Booking__c);
            if (booking != null && String.isNotBlank(booking.Email1__c)) {
                String body = 
                    'Dear ' + booking.First_Applicant_Name__c + ',<br/><br/>' +
                    'This is a gentle reminder regarding your payment for the following unit:<br/><br/>' +
                    '<strong>Project:</strong> ' + (booking.Project1__r != null ? booking.Project1__r.Name : 'N/A') + '<br/>' +
                    '<strong>Unit:</strong> ' + (booking.Plot__r != null ? booking.Plot__r.Name : 'N/A') + '<br/>' +
                    '<strong>Installment S.No:</strong> ' + ps.S_No__c + '<br/>' +
                    '<strong>Total Paid:</strong> ₹' + ps.Received_Amount1__c + '<br/>' +
                    '<strong>Pending Amount:</strong> ₹' + ps.Pending_Amount__c + '<br/><br/>' +
                    'Please clear the dues at your earliest convenience to avoid any interest charges.<br/><br/>' +
                    'Thank you,<br/>'+
                    'Best regards,<br/>' +
                    'Midhu Siju | Officer - Customer Relations | 9207054444<br/>'+
                    'Alitta Lijoy | Customer Relation Executive | 90482 37066<br/><br/>'+
                    'Veegaland Developers Pvt. Ltd.<br/>'+
                    'Regd. Office: XIII/300 E-26, 4th Floor, K Chittilappilly Tower, BMC Road, Thrikkakara P.O, Ernakulam-682021<br/>'+
                    'Tel: +91 484 2584000 / 2973944, +91 6235051144<br/>'+
                    '<a href="https://www.veegaland.com" target="_blank">www.veegaland.com</a><br/><br/>'+
                    'Follow us on: '+
                    '<a href="https://www.facebook.com" target="_blank">Facebook</a> | '+
                    '<a href="https://www.instagram.com" target="_blank">Instagram</a> | '+
                    '<a href="https://www.linkedin.com" target="_blank">LinkedIn</a> | '+
                    '<a href="https://www.youtube.com" target="_blank">YouTube</a><br/>';

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { booking.Email1__c });
                mail.setSubject('Pending Payment Reminder');
                mail.setHtmlBody(body);
                emails.add(mail);
            }
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
        if (!psIds.isEmpty()) {
            WhatsappController.sendReminderForSchedules(psIds);
        }
    }

    global void finish(Database.BatchableContext bc) {
        // Optional: Send summary email or log
    }
    
    global void execute(SchedulableContext sc) {
        // Schedule the batch job with scope size 50 (you can change it)
        PendingPaymentReminder batch = new PendingPaymentReminder();
        Database.executeBatch(batch, 100);
    }
}