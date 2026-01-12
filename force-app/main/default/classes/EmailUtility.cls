public class EmailUtility {
    public static void sendTestEmail(String toAddress, String subject, String body) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{toAddress});
        mail.setSubject(subject);
        mail.setPlainTextBody(body);

            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            if (results != null && results[0].isSuccess()) {
                System.debug('✅ Email sent successfully to: ' + toAddress);
            } else {
                System.debug('❌ Failed to send email: ' + results[0].getErrors()[0].getMessage());
            }
        
    }
}