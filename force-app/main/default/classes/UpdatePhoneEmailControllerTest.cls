@isTest
public class UpdatePhoneEmailControllerTest {
    
	  public static testmethod void testupdatephoneEmail()
      {
           Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales executive'];
        
        // Create a User object that uses that Profile
        User u = new User();
        u.LastName = 'test';
        u.ProfileId = p.Id;
        u.Alias = 'standt';
        u.Email = 'user@org.com';
        u.Username='user@org.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        insert u;
          
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Company = 'testCompany';
        ld.phone ='9876543459';
          ld.Secondary_Phone__c='6876876767';
        ld.LeadSource = 'Website';
        ld.Email ='test@gmail.com';
        ld.Secondary_Email__c ='test2@gmail.com';
        ld.OwnerId=u.Id;
        
        
        insert ld;
          Lead ld1 = new Lead();
        ld1.LastName = 'test';
        ld1.Company = 'testCompany';
        ld1.phone ='9876543469';
          ld1.Secondary_Phone__c='6876876768';
        ld1.LeadSource = 'Website';
        ld1.Email ='test1@gmail.com';
        ld1.Secondary_Email__c ='test12@gmail.com';
        ld1.OwnerId=u.Id;
        
        
        insert ld1;
       UpdatePhoneEmailController.getcontactdetails(ld.id);
          UpdatePhoneEmailController.savecontactdetails(ld1.Id,ld1.Phone,ld1.Email,ld1.Secondary_Phone__c,ld1.Secondary_Email__c);
        //  updateContactDetails.getcontactdetails(ld.Id);
        UpdatePhoneEmailController.savecontactdetails(ld.Id,'9876598766','testlead3@gmail.com',null,null);
        UpdatePhoneEmailController.savecontactdetails(ld.Id,'+9559876598766','','+9559876598766','');
        //updateContactDetails.savecontactdetails(ld.Id,'','test@gmail.com','','testlead2@gmail.com');
        UpdatePhoneEmailController.savecontactdetails(ld.Id,'+919177350780','test@gmail.com','+919876598767','testlead2@gmail.com');
        UpdatePhoneEmailController.savecontactdetails(ld.Id,'9876598766','test@gmail.com','+9559876598767','testlead2@gmail.com');
        UpdatePhoneEmailController.savecontactdetails(ld.Id,'+9559876598765','test2@gmail.com','+9559876598765','testlead2@gmail.com');
    
      }
}