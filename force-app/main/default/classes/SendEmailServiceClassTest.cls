@isTest
public class SendEmailServiceClassTest {
    @isTest
    public static void testSendEmail(){
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
        Project__c project = new  Project__c();
        project.Name = 'Veegaland Green Heights';
        project.Project_Type__c='Apartments';
        project.Finance_User__c = owner.Id;
        project.CRM_Manager__c =  owner.Id;
        project.Legal_User__c = owner.Id;
        project.Legal_User2__c = owner.Id;
        insert project;
        
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
        
        
        Plot__c unit = new Plot__c();
        unit.Name = '101';
        unit.Status__c = 'Available';
        unit.Project__c = project.Id;
        unit.Block__c = 'A4';
        unit.Plot_Type__c = 'Residential';
        //unit.Block1__c = block.Id;
        unit.Carpet_Area__c = 850;
        unit.Balcony_Sq_mts__c = 20;
        unit.Balcony_Area__c = 100;
        unit.BHK_Type__c = '2 BHK';
        unit.Premium_Status__c = 'Premium';
        unit.Floor__c = '1';
        unit.Share__c = 'MHPL';
        unit.Facing__c = 'EAST';
        unit.Carpet_Sq_mts__c = 80;
        unit.CA__c = 75;
        unit.Built_up_area__c = 1200;
        unit.UDS__c = 300;
        unit.UDS_Sq_mts__c = 50;
        unit.Super_built_up_area__c = 1500;
        unit.Price_Per_Sq_Ft__c = 5000;
        unit.Floor_Rise__c = 200;
        unit.Premium_Charge__c = 100000;
        unit.Covered_Park_Parking__c = 50000;
        unit.Other_Charges__c = 20000;
        unit.Solar_Charges__c = 15000;
        unit.GST1__c = 18;
        unit.Floor__c = '30';
        insert unit;
        
        
        set<Id> sIds = new  set<Id>();
        Quote__c Qt = new Quote__c(
            Discount_In_Rupees__c = 100,
            Leads__c = ld.id,
            
            Project__c = 'Veegaland Green Heights',
            Unit__c =unit.Id,
            Car_Parking_Charge__c = 70,
            Extra_car_parking_charges__c = 10,
            Floor_Rise_Charges__c = 10,
            Built_up_area__c = 2000,
            Primary_Applicant_Email__c = 'test01@gmail.com'
         
            
        );
        
        insert Qt;
        sIds.add(Qt.Id);
        
        
        
        
        Booking__c book = new Booking__c();
        book.SLead__c = ld.Id;
        book.Quote__c = Qt.Id;
        // book.Payment_Plan__c = payplan.Id;
        book.Followup_Date__c = system.today();
        book.Followup_Subject__c = 'test22';
        book.Last_Comment__c = 'test22';
        book.Project__c = 'Veegaland Green Heights';
        book.Payment_Type__c = 'Custom';
        book.Sale_Agreement_Completed__c = false;
        book.Agreement_Amount_Cleared__c ='Received Partial Amount';
        book.Stage__c ='Welcome Email';
        book.Demand_Number__c = '12345'; 
        book.Project1__c = project.Id; 
        book.Date_of_Booking__c = System.today(); 
        book.Mode_Of_Payment__c = 'Credit Card';
        book.Funding_Type__c = 'Loan';
        book.Plot__c = unit.Id;
        book.Loan_Sanction_Confirmed__c = true;
        book.Loan_Sanctioned_Amount__c = 10000;
        book.Sales_Manager1__c = owner.Id;
        book.Sales_Executive__c = owner.Id;
        book.Finance_User__c = owner.Id;
        book.First_Applicant_Name__c = 'Akhil';
        book.CRM_Manager__c=owner.Id;
        book.Legal_Team__c = owner.Id;
        book.Legal_Advocate_Assigned__c = owner.Id;
        book.Email1__c = 'Test@gamil.com';
        insert book;
        
        // Co applicant
        Co_Applicant__c co = new Co_Applicant__c();
        co.Name = 'Testing';
            co.Booking__c = book.Id;
            
            insert co;
        
        List<string> cvIds = new List<string>();
        // Create a test ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'TestFile',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Test content')
        );
        insert cv;
        
        // Get inserted ContentVersion with ContentDocumentId
        ContentVersion insertedCV = [
            SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id
        ];
        
        // Link ContentDocument to Project
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = insertedCV.ContentDocumentId,
            LinkedEntityId = Qt.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
        cvIds.add(cdl.ContentDocumentId);
        
        // Check if a ContentDistribution already exists
        List<ContentDistribution> existingDists = [
            SELECT Id FROM ContentDistribution WHERE ContentVersionId = :insertedCV.Id
        ];
        
        if (existingDists.isEmpty()) {
            
            ContentDistribution dist = new ContentDistribution(
                Name = 'Test Dist',
                ContentVersionId = insertedCV.Id
            );
            insert dist;
        }
        
        
        
        // cvIds.add(cv.Id);
        sIds.add(cv.Id);
        
        List<Id> recIds = new List<Id>();
        // receipt
        Receipt__c rc = new Receipt__c(
            
            Receipt_date__c = Date.Today(),
            Instrument_N__c = 'sdfsdfsd',
            Booking__c = book.Id,
            Approval_status__c =  'Approved by Finance Team'
            
        );
        insert rc;
        recIds.add(rc.id);
        
        
        SendEmailServiceClass.sendRequestDocumentMail(Qt.Id, 'Test emailContent', cvIds);
        SendEmailServiceClass.sendCostSheettoCustomer(Qt.Id, 'Test emailContent', cvIds);
        SendEmailServiceClass.sendBookingFormtoCustomer(Qt.Id, 'Test emailContent', cvIds);
        SendEmailServiceClass.sendQuoteApprovalEmail(sIds, 'Status');
        SendEmailServiceClass.sendBookingFormUpdatedEmail(sIds);
        SendEmailServiceClass.sendEmailFinalBookingForm(Qt.Id);
        SendEmailServiceClass.sendFailureEmail(owner.Id, book.Id, 'bookingName', 'Car Parking Selection');
        SendEmailServiceClass.sendEmailGenerateReceipts(recIds);
      //  SendEmailServiceClass.testCover();
        
    }
    
}