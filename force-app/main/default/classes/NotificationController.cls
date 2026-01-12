public class NotificationController {

    @AuraEnabled
    public static void sendNotification(String targetid) {
        
         CustomNotificationType notificationType = [SELECT Id, DeveloperName  FROM CustomNotificationType   WHERE DeveloperName='Task_Notification'];
        Set<String> rec = new Set<String>();
        rec.add(UserInfo.getUserId());
         Messaging.CustomNotification notification = new Messaging.CustomNotification();

        // Set the contents for the notification
        notification.setTitle('Documents uploaded');
        notification.setBody('Customer Uploded documents please verify it.');

        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(targetid);
        
        // Actually send the notification
        try {
            notification.send(rec);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
    @AuraEnabled
    public static void sendtaskNotification(String targetid) {
        
         CustomNotificationType notificationType = [SELECT Id, DeveloperName  FROM CustomNotificationType   WHERE DeveloperName='Task_Notification'];
        Set<String> rec = new Set<String>();
        rec.add(UserInfo.getUserId());
         Messaging.CustomNotification notification = new Messaging.CustomNotification();

        // Set the contents for the notification
        notification.setTitle('Task Subject');
        notification.setBody('Booking advance amount follow-up');

        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(targetid);
        
        // Actually send the notification
        try {
            notification.send(rec);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
/*
    @AuraEnabled
    public static void sendEmail(String subject) {
        try {
            // Define the email details
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] {'rakesh@fingertipplus.com', 'shebin@fingertipplus.com','praveen@fingertipplus.com'});
          email.setSubject(subject);
             email.setHtmlBody( 
                        'Dear Kiran Kumar, <br/><br/>' +
                 		'Thank you for providing the required documents for your booking. Please find your Booking Form attached below or use the secure link to view and download it. <br/><br/>'+
                        'Secure Link: https://fit5-dev-ed.develop.lightning.force.com/lightning/n/Bookingform. <br/><br/>'+
             			'Kindly review the details in the form and let us know your decision by clicking Accept or Reject.<br/><br/>'+
             			'If you have any questions, feel free to reach out to us at shebin@fingertipplus.com.<br/><br/>'+
             			'Best Regards,<br/>'+
             			'Shebin Mathew<br/>'+
             			'Veegaland Developers Pvt Ltd.');
                  
            // Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            System.debug('Email sent successfully with subject: ' + subject);
        } catch (Exception e) {
            throw new AuraHandledException('Error while sending email: ' + e.getMessage());
        }
    }
	 @AuraEnabled
    public static void sendKYCEmail(String subject) {
        try {
            // Define the email details
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] {'rakesh@fingertipplus.com', 'shebin@fingertipplus.com','praveen@fingertipplus.com'});
          email.setSubject(subject);
             email.setHtmlBody( 
                        'Dear Kiran Kumar, <br/><br/>' +
                 		'Thank you for choosing Veegaland Developers Pvt Ltd. To proceed with your booking, we kindly request you to upload the<br/>'+
                        'ollowing documents of yourself and co-applicants if exist:<br/><br/>'+
             			'Required Documents:<br/><br/>'+
             			'Aadhaar Card<br/><br/>'+
                 		'Passport port size photo<br/>'+
                 		'PAN Card<br/><br/>'+
                 		'Instructions:<br/><br/>'+
                 		'Formats Accepted: PDF, JPG, PNG<br/>'+
                 		'Maximum File Size: 10 MB per document<br/>'+
                 		'Deadline: Please upload your documents by 25th Jan 2025.<br/>'+
                 		'Upload Link: https://fit5-dev-ed--c.develop.vf.force.com/apex/BookingFormVeegaland. <br/>'+
                 		'If you have any questions or require assistance, feel free to contact your sales executive at [Sales Executive Contact Details].<br/>'+
                 		'Thank you for your prompt attention.<br/>'+
             			'Best Regards,<br/>'+
             			'Shebin Mathew<br/>'+
             			'Veegaland Developers Pvt Ltd.');
                  
            // Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            System.debug('Email sent successfully with subject: ' + subject);
        } catch (Exception e) {
            throw new AuraHandledException('Error while sending email: ' + e.getMessage());
        }
    }
     @AuraEnabled
    public static void sendReciEmail(String subject) {
        try {
            // Define the email details
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] {'rakesh@fingertipplus.com', 'shebin@fingertipplus.com','praveen@fingertipplus.com'});
          email.setSubject(subject);
             email.setHtmlBody( 
                        'Dear Kiran Kumar, <br/><br/>' +
                 		'I hope you’re doing well.<br/><br/>'+
                 		'We have received your advance payment amount Rs.100000(In words) via [Cheque/NEFT]. Kindly note that it is subject to<br/>'+
                 		'realization and will be processed once cleared.<br/>'+
             			'Thank you for your prompt action. We will keep you informed on the status.<br/><br/>'+
                 		'Thank you for choosing Veegaland Homes.<br/></br>'+
                 		'Best Regards,<br/>'+
             			'Shebin Mathew<br/>'+
             			'Veegaland Homes');
                  
            // Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            System.debug('Email sent successfully with subject: ' + subject);
        } catch (Exception e) {
            throw new AuraHandledException('Error while sending email: ' + e.getMessage());
        }
    }
		
     @AuraEnabled
    public static void sendReciafterEmail(String subject) {
        try {
            // Define the email details
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] {'rakesh@fingertipplus.com', 'shebin@fingertipplus.com','praveen@fingertipplus.com'});
          email.setSubject(subject);
             email.setHtmlBody( 
                        'Dear Kiran Kumar, <br/><br/>' +
                 		'I hope you’re doing well.<br/><br/>'+
                 		'We are pleased to inform you that your payment 100000(in words) against reference Cheque/NEFT number 1234 has been<br/>'+
                 		'successfully credited to our account. Thank you for your timely payment. Please find the attached receipt for you reference.<br/>'+
             			'Should you have any further questions, feel free to reach out.<br/><br/>'+
                 		'Thank you for choosing Veegaland Homes.<br/></br>'+
                 		'Best Regards,<br/>'+
             			'Shebin Mathew<br/>'+
             			'Veegaland Homes');
                  
            // Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            System.debug('Email sent successfully with subject: ' + subject);
        } catch (Exception e) {
            throw new AuraHandledException('Error while sending email: ' + e.getMessage());
        }
    }
    
     @AuraEnabled
    public static void sendParklyouEmail(String subject) {
        try {
            // Define the email details
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] {'rakesh@fingertipplus.com', 'shebin@fingertipplus.com','praveen@fingertipplus.com'});
          email.setSubject(subject);
             email.setHtmlBody( 
                        'Dear Kiran Kumar, <br/><br/>' +
                 		'Greetings From Veegaland Developers<br/><br/>'+
                 		'We would like to inform you that we are giving special privileges to our existing customers to choose their preferred<br/>'+
                 		'parking in our prestigious project Project Name.<br/><br/>'+
                 		'So, we are hereby requesting you to choose your parking slot for your apartment in the project. You may please find <br/>'+
                 		'attached herewith the parking layout both ground & first floor level. You may kindly go through the layout and choose <br/>'+
                 		'your preferred parking and let us know via a reply mail, so that we can verify,block and give you a confirmation on the <br/>'+
                 		'same. Your selected parking number will be also mentioned in your sale agreement<br/>'+
                 		'parking layout :https://fit5-dev-ed--c.develop.vf.force.com/apex/ParkingLayout<br/>'+
                 		'<br/>'+
             			'KINDLY NOTE , PARKING SLOTS WITH  BACK TO BACK PARKING WILL BE ADDITIONAL COST<br/><br/>'+
                 		'Kindly avoid parking slot numbers – 5, 10, 11, 12, 13, 14, 15, 16 , 17, 18, 19, 25, 26, 27,  32, 34, 36, 37 , B2 & B4 <br/><br/>'+
                 		'Note : We kindly request you to finalize your car parking selection within the next 24 hours. If we do not receive your <br/>'+
                 		'confirmation within this time frame, we may need to allocate the parking space to another customer on our waiting<br/><br/>'+
                 		'Thanks & Regards,,<br/>'+
             			'Shebin Mathew<br/>'+
             			'Veegaland Homes');
                  
            // Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            System.debug('Email sent successfully with subject: ' + subject);
        } catch (Exception e) {
            throw new AuraHandledException('Error while sending email: ' + e.getMessage());
        }
    }
	  @AuraEnabled
    public static void sendWelcomEmail(String subject) {
        try {
            // Define the email details
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
             Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            PageReference pref;
            
            //pref= page.AllotmentLetterVeegalandHome;
            
            
       //     pref.getParameters().put('id',recId);
            
            pref.setRedirect(true);
            system.debug(pref);
            Blob b;
            if(Test.isRunningTest()){
                b = blob.valueOf('Unit.Test');
            }else{
                b = pref.getContent();
            }
            attach.setFileName('Vegaland_Allotment_Letter.pdf');
            attach.setBody(b);
           
            email.setToAddresses(new String[] {'rakesh@fingertipplus.com', 'shebin@fingertipplus.com','praveen@fingertipplus.com'});
          email.setSubject(subject);
             email.setHtmlBody( 
                        'Dear Kiran Kumar, <br/><br/>' +
                 		'Warm greetings from Veegaland Developers!<br/><br/>'+
                 		'We extend our heartfelt gratitude to you for choosing Veegaland Developers as your partner in realizing your dream home.<br/>'+
                 		'Your decision to finalize your home with us speaks volumes, and we are truly honoured to have earned your trust.<br/>'+
                 		'At Veegaland Developers, we take immense pride in our reputation for delivering exceptional service and ensuring that our <br/>'+
                 		'customers needs are not just met but exceeded. Your satisfaction is our top priority, and we are dedicated to fulfilling your<br/>'+
                 		'expectations with the utmost diligence and care.<br/>'+
                 		'Allow me to introduce myself as Ms. Shebin Mathew, Customer Relations Officer at Veegaland. I am here to ensure that <br/>'+
                 		'your journey with us is smooth and memorable. Feel free to reach out to me for any assistance or queries you may have; I<br/>'+
                 		'am committed to providing you with the support you need every step of the way.<br/><br/>'+
                 		'Enclosed with this email, you will find the allotment letter detailing your booking with us.<br/><br/>'+
                 		'Once again, thank you for choosing Veegaland Developers as your trusted partner in this journey towards homeownership. <br/><br/>'+
                 		'We look forward to building a strong and enduring relationship with you and assisting you in creating many wonderful<br/><br/><br/>'+
                 		'memories in your new home. <br/?'+
                 		'Best Regards,<br/>'+
             			'Shebin Mathew<br/>'+
             			'Veegaland Homes');
                  
            // Send the email
            
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            System.debug('Email sent successfully with subject: ' + subject);
        } catch (Exception e) {
            throw new AuraHandledException('Error while sending email: ' + e.getMessage());
        }
    }
    
    
     @AuraEnabled
    public static void sendCoapplicantEmail(String subject) {
        try {
            // Define the email details
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] {'rakesh@fingertipplus.com', 'shebin@fingertipplus.com','praveen@fingertipplus.com'});
          email.setSubject(subject);
             email.setHtmlBody( 
                        'Dear Kiran Kumar, <br/><br/>' +
                 		'Kindly fill the co applicant details and send back for sale agreement execution . Please provide the details corresponding to<br/>'+
                 		'the ID proofs given to Veegaland<br/>'+
                 		'Co Applicant details upload link: :https://fit5-dev-ed--c.develop.vf.force.com/apex/CoApplicantDetail<br/><br/>'+
                 		'Thanks & Regards,,<br/>'+
             			'Shebin Mathew<br/>'+
             			'Veegaland Homes');
                  
            // Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            System.debug('Email sent successfully with subject: ' + subject);
        } catch (Exception e) {
            throw new AuraHandledException('Error while sending email: ' + e.getMessage());
        }
    }
     @AuraEnabled
    public static void sendDraftAgreenEmail(String subject) {
        try {
            // Define the email details
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] {'rakesh@fingertipplus.com', 'shebin@fingertipplus.com','praveen@fingertipplus.com'});
          email.setSubject(subject);
             email.setHtmlBody( 
                        'Dear Kiran Kumar, <br/><br/>' +
                 		'Please find the draft agreement in the below link for registration. <br/><br/>'+
                 		'the ID proofs given to Veegaland<br/>'+
                 		'draft agreement link: https://fit5-dev-ed.develop.lightning.force.com/lightning/n/Agreement_Page<br/><br/>'+
                 		'Please update with the available date for the registration<br/><br/>'+
                 		'Location: Tripunithura Sub Registrar office<br/><br/>'+
                 		'Thanks & Regards<br/>'+
             			'Shebin Mathew<br/>'+
             			'Veegaland Homes');
                  
            // Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            System.debug('Email sent successfully with subject: ' + subject);
        } catch (Exception e) {
            throw new AuraHandledException('Error while sending email: ' + e.getMessage());
        }
    }
     @AuraEnabled
    public static void sendBalanceAmountEmail(String subject) {
        try {
            // Define the email details
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] {'rakesh@fingertipplus.com', 'shebin@fingertipplus.com','praveen@fingertipplus.com'});
          email.setSubject(subject);
             email.setHtmlBody( 
                        'This is to remind you that an amount of  INR  13,00,110/- (Rupees Thirteen Lakhs One Hundred and Ten  only) will be due<br/>' +
                 		'against apartment No. 9C at Veegaland Queens park <br/><br/>'+
                 		'Request you to kindly release the amount to our below mentioned bank account<br/><br/>'+
                 		'Account Number: 0587073000000353<br/>'+
                 		'Bank Name: THE SOUTH INDIAN BANK LTD<br/>'+
                 		'Branch Name: KAKKANAD<br/>'+
                 		'IFSC Code: SIBL0000587<br/>'+
                 		'Thanks & Regards<br/>'+
             			'Shebin Mathew<br/>'+
             			'Veegaland Homes');
                  
            // Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            System.debug('Email sent successfully with subject: ' + subject);
        } catch (Exception e) {
            throw new AuraHandledException('Error while sending email: ' + e.getMessage());
        }
    }*/

}