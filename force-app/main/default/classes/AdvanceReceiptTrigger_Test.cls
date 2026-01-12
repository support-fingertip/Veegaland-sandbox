@isTest
public class AdvanceReceiptTrigger_Test {
@isTest
    public static void advRec(){
      User owner = new User(
            Email = 'owner112@example.com',
            Alias = 'owner',
            LastName='andy',
            ProfileId = UserInfo.getProfileId(),
            Username = 'owner43221163@example.com',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Working__c = true,
            isActive = true,
            Availability__c=true
        );
        insert owner;
        
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Company = 'testCompany';
        ld.phone ='9876543459';
        ld.LeadSource = '99 acres';
        ld.Project_City__c = 'Ernakulam';
        ld.Email ='test@gmail.com';
        ld.Secondary_Email__c ='test2@gmail.com';
        ld.OwnerId=owner.Id;
        
        insert ld; 
        
        Project__c project = new  Project__c();
        project.Name = 'Veegaland Green Heights';
        project.Project_Type__c='Apartments';
        project.Finance_User__c = owner.Id;
        project.CRM_Manager__c =  owner.Id;
        project.Legal_User__c = owner.Id;
        project.Legal_User2__c = owner.Id;
       // project.Company__c = '';
        insert project;
        
        
        Booking__c book1 = new Booking__c();
        // book.SLead__c = ld.Id;
        // book.Quote__c = Qt1.Id;
        //  book.Project1__c = project.Id;
        // book1.Payment_Plan__c = payplan.Id;
        book1.Followup_Date__c = system.today();
        book1.Followup_Subject__c = 'test22';
        book1.Last_Comment__c = 'test22';
       // book1.Project__c = 'Veegaland Green Heights';
        book1.Project1__c = project.Id;
        book1.Payment_Type__c = 'Custom';
        book1.Sale_Agreement_Completed__c = false;
        book1.Agreement_Amount_Cleared__c ='Received Partial Amount';
        book1.Stage__c ='Token Amount Collection';
        book1.Demand_Number__c = '12345'; 
        book1.Date_of_Booking__c = System.today(); 
        book1.Mode_Of_Payment__c = 'Credit Card';
        book1.Funding_Type__c = 'Loan';
        // book1.Plot__c = unit1.Id;
        book1.Loan_Sanction_Confirmed__c = true;
        book1.Loan_Sanctioned_Amount__c = 10000;
        book1.Finance_User__c = owner.Id;
        book1.Sales_Manager1__c = owner.Id;
        book1.Sales_Executive__c =owner.Id;
        book1.Legal_Team__c = owner.Id;
        book1.CRM_Manager__c=owner.Id;
        book1.First_Applicant_Name__c = 'Akhil';
        book1.Legal_Advocate_Assigned__c = owner.Id;
        book1.Email1__c = 'Test@gamil.com';
        book1.Email2__c ='test5@gmail.com';
        insert book1;
        
       Advance_Receipt__c ad = new Advance_Receipt__c(
       Booking__c = book1.Id
           
       );
        insert ad;
        ad.Approval_Status__c = 'Approved by Finance Team';
        update ad;
       
       
        
        List<Id> rcList = new  List<Id>();
        List<Receipt__c> recList = new  List<Receipt__c>();
        //Receipt
        Receipt__c rc = new Receipt__c(
            
            Receipt_date__c = Date.Today(),
            Instrument_N__c = 'sdfsdfsd',
            Booking__c = book1.Id,
            Approval_status__c =  'Approved by Finance Team',
            Payment_From__c = 'Bank'
            
        );
        insert rc;
        rcList.add(rc.Id);
        recList.add(rc);
     }    
}