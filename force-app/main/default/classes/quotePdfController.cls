public class quotePdfController {
    
    @auraEnabled
    public static string getPaymentType(string recId){
        Quote__c qt = [SELECT Id FROM Quote__c WHERE Id =:recId LIMIT 1];
        string returnMesg='VeegalandQuotePdf';
        
        
        return returnMesg;
    }
    @AuraEnabled
    public static string sendEmailtoCustomer(String recId){
        Quote__c qt = [SELECT Id,payment_type__c,Approval_status__c, Project__c, Leads__r.Email, Leads__r.Secondary_Email__c,OwnerId,Leads__r.Owner.EMail,Leads__r.Owner.Name,Leads__r.Owner.Phone,Discount_In_Rupees__c FROM Quote__c WHERE Id=:recId];
        system.debug(qt.Approval_status__c +'=='+ qt.Discount_In_Rupees__c );
        if((qt.Approval_status__c != 'Approved' && qt.Approval_status__c != '' && qt.Discount_In_Rupees__c != null && qt.Discount_In_Rupees__c >=500))
        {
            return 'Approval Process Pending'; 
        }
        else{
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            PageReference pref;
            
            pref= page.VeegalandQuotePdf;
            
            
            pref.getParameters().put('id',recId);
            
            pref.setRedirect(true);
            system.debug(pref);
            Blob b;
            if(Test.isRunningTest()){
                b = blob.valueOf('Unit.Test');
            }else{
                b = pref.getContent();
            }
            attach.setFileName('Vegaland_Quotation.pdf');
            attach.setBody(b);
            semail.setSenderDisplayName(qt.Leads__r.Owner.Name);
            semail.setReplyTo(qt.Leads__r.Owner.Email);
            semail.setSubject('Vegaland Quotation');
            
            List<string> sendTo = new List<string>();
            if(qt.Leads__r.Email !=null){
                sendTo.add(qt.Leads__r.Email);
            }
            
            if(qt.Leads__r.Secondary_Email__c !=null){
                sendTo.add(qt.Leads__r.Secondary_Email__c);
            }
            System.debug('===='+sendTo);
            List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
                string companyName;
                
                if(!companyDetails.isEmpty()){
                    companyName = companyDetails[0].Label;
                       
                }
            semail.setToAddresses(sendTo);
            semail.setHtmlBody( 
                'Dear Valued Customer, <br/><br/>' +
                'We appreciate your interest in our project. Attached herewith is the best quote for your reference. Should you have any additional questions, please do not hesitate to contact us. <br/><br/>' +
                'Thank you for considering our services. <br/><br/>'+
                'Should you have any further questions, feel free to reach out. <br/><br/>'+
                'Best regards,<br/><br/>' +
                companyName+'<br/>'+
                qt.Leads__r.Owner.Name + '<br/>' +
                '[' + qt.Leads__r.Owner.Phone + ']'+'<br/>' );
            semail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
            if(sendTo.size()>0){
                // Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
                // system.debug(semail);
                
                Quote__c q = [select Id, Name, Quote_status__c,Unit__r.Status__c from Quote__c where id = :recId limit 1];
                if(q.Unit__r.Status__c=='Available'){
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
                    system.debug(semail);
                    q.Quote_status__c = 'Sent to customer';
                    update q;
                    return 'Quotation sent to customer';
                }
                else{
                    return 'This Unit was already Booked';
                }
            }
            else{
                return 'Please enter email address in lead';
            }
            
        }
        
    } 
}