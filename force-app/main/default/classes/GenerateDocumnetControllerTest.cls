@isTest
public class GenerateDocumnetControllerTest {
    
    
    @testSetup
    static void setupTestData() {
        
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
        
        Lead ld1 = new Lead();
        ld1.LastName = 'test';
        ld1.Company = 'testCompanyxx';
        ld1.phone ='9876543457';
        ld1.LeadSource = '99 acres';
        ld1.Project_City__c = 'Ernakulam';
        ld1.Email ='test1234@gmail.com';
        ld1.Secondary_Email__c ='test2343@gmail.com';
        ld1.OwnerId=owner.Id;
        
        insert ld1; 
        
        Payment_Plan__c payplan = new Payment_Plan__c();
        payplan.Active__c = true;
        payplan.Project__c = project.id;
        insert payplan;
        
        Master_payment_schedule__c mpy = new Master_payment_schedule__c ();
        mpy.S_No__c = 1;
        mpy.Status__c = 'Completed';
        mpy.Project__c = project.id;
        mpy.Payment_Plan__c = payplan.Id;
        mpy.Payment_Percent__c = 50;
        insert mpy;
        
        Master_payment_schedule__c mpy1 = new Master_payment_schedule__c ();
        mpy1.S_No__c = 2;
        mpy1.Payment_Percent__c = 50;
        mpy1.Status__c = 'Completed';
        mpy1.Project__c = project.id;
        mpy1.Payment_Plan__c = payplan.Id;
        insert mpy1;
        
        Block__c block = new Block__c();
        block.Name='A';
        block.Project__c=project.id;
        insert block;
        
        
        Plot__c unit1 = new Plot__c();
        unit1.Name = '105';
        unit1.Status__c = 'Available';
        unit1.Project__c = project.Id;
        unit1.Block__c = 'A4';
        unit1.Plot_Type__c = 'Residential';
        unit1.Block1__c = block.Id;
        unit1.Carpet_Area__c = 850;
        unit1.Balcony_Sq_mts__c = 20;
        unit1.Balcony_Area__c = 100;
        unit1.BHK_Type__c = '1 BHK';
        unit1.Premium_Status__c = 'Premium';
        unit1.Floor__c = '1';
        unit1.Share__c = 'MHPL';
        unit1.Facing__c = 'EAST';
        unit1.Carpet_Sq_mts__c = 80;
        unit1.CA__c = 75;
        unit1.Built_up_area__c = 1200;
        unit1.UDS__c = 300;
        unit1.UDS_Sq_mts__c = 50;
        unit1.Super_built_up_area__c = 1500;
        unit1.Price_Per_Sq_Ft__c = 5000;
        unit1.Floor_Rise__c = 200;
        unit1.Covered_Park_Parking__c = 50000;
        unit1.Other_Charges__c = 20000;
        unit1.Solar_Charges__c = 15000;
        unit1.GST1__c = 18;
        unit1.Floor__c = '3';
        insert unit1;
        
        Quote__c Qt1 = new Quote__c(
            Discount_In_Rupees__c = 100,
            Leads__c = ld.id,
            Project__c = 'Veegaland Green Heights',
            Unit__c =unit1.Id,
            Car_Parking_Charge__c = 70,
            Extra_car_parking_charges__c = 10,
            Floor_Rise_Charges__c = 10,
            Built_up_area__c = 2000
        );
        
        insert Qt1;
        
        
      
        
        
        Parking_Floor__c floor =  new Parking_Floor__c(
            Name = 'Ground Floor',
            Project__c = project.Id
            
           
            
        );
        insert floor;
        
          //parking
        Parking__c parking = new Parking__c(
        Name = '6',
        Parking_Floor__c =  floor.Id,
            Status__c = 'Available'
     
        );
        insert parking;
        
        
        //Creating content version
        ContentVersion cv = new ContentVersion(
            Title = 'Parking Layout',
            PathOnClient = 'Parking Layout.pdf',
            VersionData = Blob.valueOf('Parking Layout'),
            ExternalDocumentInfo1 = floor.Id, 
            ExternalDocumentInfo2 = 'FromApp'
            
            
        );
        insert cv;
        
        // Step 3: Retrieve ContentDocumentId
        ContentVersion insertedCv = [SELECT Id, ContentDocumentId,IsLatest FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        
        // Step 4: Link ContentDocument to Parking_Floor__c
        List<ContentDocumentLink> existingLinks = [
            SELECT Id 
            FROM ContentDocumentLink 
            WHERE ContentDocumentId = :insertedCv.ContentDocumentId 
            AND LinkedEntityId = :floor.Id
        ];
        if (existingLinks.isEmpty()) {
            ContentDocumentLink newLink = new ContentDocumentLink(
                ContentDocumentId = insertedCv.ContentDocumentId,
                LinkedEntityId = floor.Id,
                ShareType = 'V'
            );
            insert newLink;
        }
        
        
        
        
        
        
        
        Booking__c book1 = new Booking__c();
        book1.SLead__c = ld1.Id;
        book1.Payment_Plan__c = payplan.Id;
        book1.Followup_Date__c = system.today();
        book1.Followup_Subject__c = 'test22';
        book1.Last_Comment__c = 'test22';
        book1.Project1__c = project.Id;
        book1.Payment_Type__c = 'Custom';
        book1.Sale_Agreement_Completed__c = false;
        book1.Agreement_Amount_Cleared__c ='Received Partial Amount';
        book1.Stage__c = 'Draft Agreement Preparation';
        book1.Demand_Number__c = '12345'; 
        book1.Date_of_Booking__c = System.today(); 
        book1.Mode_Of_Payment__c = 'Credit Card';
        book1.Funding_Type__c = 'Loan';
        book1.Plot__c = unit1.Id;
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
        book1.Authorized_Signatory__c = true;
        book1.Email2__c = 'testing@gmail.com';
        book1.Agreement_Approval_Status__c = 'Approved';
        insert book1;
        
        // Creating tasks
        Task task =  new Task(
            Status = 'In Progress',
            WhatId = book1.Id,
            Subject = 'Send Agreement Cost Mail to Customer' 
            
        );
        insert task;
        
        list<Payment_schedule__c> pylist = new list<Payment_schedule__c>();
        
        Payment_schedule__c pay = new Payment_schedule__c();
        pay.Booking__c = book1.id;
        pay.Payment_percent__c = 0;
        pay.Master_Payment_Schedule__c = mpy.Id;
        pay.S_No__c = 1;
        pay.name = 'On Regestration';
        pay.status__c = 'Completed';
        pylist.add(pay);
        
        Payment_schedule__c pay1 = new Payment_schedule__c();
        pay1.Booking__c = book1.id;
        pay1.Payment_percent__c = 10;
        pay1.Master_Payment_Schedule__c = mpy.Id;
        pay1.S_No__c = 2;
        pay1.name = 'On Agreement';
        pylist.add(pay1);
        
        Payment_schedule__c pay3 = new Payment_schedule__c();
        pay3.Booking__c = book1.id;
        pay3.Payment_percent__c = 10;
        pay3.Master_Payment_Schedule__c = mpy.Id;
        pay3.S_No__c = 3;
        pay3.name = 'On Completion of basement';
        pylist.add(pay3);
        
        insert pylist;
        
        List<Id> idList = new List<Id>();
        // create demand raise
        Demand_Raised__c demand = new Demand_Raised__c(
            Booking__c = book1.Id,
             
            Payment_Schedule__c = pay.Id,
            Demanded_Date__c = Date.Today(),
            Demand_Email_Content__c = 'Test'
            
        );
        insert demand;
        idList.add(demand.Id);
        
        //Creating content version
        ContentVersion cv1 = new ContentVersion(
            Title = 'Demand Note',
            PathOnClient = 'Demand_Note.pdf',
            VersionData = Blob.valueOf('Demand Note'),
            ExternalDocumentInfo1 = demand.Id, 
            ExternalDocumentInfo2 = 'FromApp'
            
            
        );
        insert cv1;
        
        // Step 3: Retrieve ContentDocumentId
        ContentVersion insertedCv1 = [SELECT Id, ContentDocumentId,IsLatest FROM ContentVersion WHERE Id = :cv1.Id LIMIT 1];
        
        // Step 4: Link ContentDocument to Parking_Floor__c
        List<ContentDocumentLink> existingLinks1 = [
            SELECT Id 
            FROM ContentDocumentLink 
            WHERE ContentDocumentId = :insertedCv1.ContentDocumentId 
            AND LinkedEntityId = :demand.Id
        ];
        if (existingLinks1.isEmpty()) {
            ContentDocumentLink newLink1 = new ContentDocumentLink(
                ContentDocumentId = insertedCv1.ContentDocumentId,
                LinkedEntityId = demand.Id,
                ShareType = 'V'
            );
            insert newLink1;
        }
        demand.Demand_Content_Ids__c = cv1.Id;
        update demand;
        
        
        // Create a dummy ContentVersion that would match the method's query
ContentVersion saContent = new ContentVersion(
    Title = 'Floor Plan - Tower A',
    PathOnClient = 'FloorPlan.pdf',
    VersionData = Blob.valueOf('PDF Data')
    
);
insert saContent;

// Get its related ContentDocumentId
Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :saContent.Id].ContentDocumentId;

// Link this file to the booking record
ContentDocumentLink link = new ContentDocumentLink(
    ContentDocumentId = docId,
    LinkedEntityId = book1.Id,  // Important: matches booking.Id in your query
    ShareType = 'V'
);
insert link;
        
        
        Receipt__c receipt = new Receipt__c(Booking__c = book1.Id,	Finance_User__c=owner.Id, Approval_status__c = 'Approved by Finance Team');
        insert receipt;
        
        Receipt_Line_Item__c receiptLineItem = new Receipt_Line_Item__c(
            Name = 'Receipt Line Item 1',
            Receipt__c = receipt.Id,
            Booking__c = book1.Id,
            Amount__c = 10000,
            Payment_schedule__c = pay.Id
        );
        
        insert receiptLineItem;
        Set<Id> bookingSet = new Set<Id>();
        bookingSet.add(book1.Id);
        List<Id> bookingList = new List<Id>();
        bookingList.add(book1.Id);
        List<Id> recList = new List<Id>();
        recList.add(receipt.Id);
        
        // SaleAgreementCoApp
        // convertNumberToWords
    }
    
    
    @isTest
    static void getBookingRecord() {
        Booking__c book1 = [SELECT Id FROM Booking__c LIMIT 1];
        Test.startTest();
        GenerateDocumnetController.getBookingRecord(book1.Id);
        GenerateDocumnetController.sendEmailGenerateReceipt(book1.Id);
        GenerateDocumnetController.getSaleAgreement(book1.Id);
        GenerateDocumnetController.sendEmailPrintAllReceipt(book1.Id);
        GenerateDocumnetController.sendEmailGenerateSA(book1.Id, 'test');
        GenerateDocumnetController.sendEmailGenerateCarParking(book1.Id, 'test');
        GenerateDocumnetController.sendEmailGenerateNOC(book1.Id);
        GenerateDocumnetController.sendEmailGenerateTPA(book1.Id);
        GenerateDocumnetController.sendAgreementCostMail(book1.Id, 'Nothing');
        GenerateDocumnetController.sendExtraCostDemandMail(book1.Id, 'Nothing');
        GenerateDocumnetController.sendAdvanceReminderEmail(book1.Id, 'Nothing');
        GenerateDocumnetController.sendFInalAppoinmentMail(book1.Id, 'Nothing');
        GenerateDocumnetController.sendAdvanceAmountReceipt(book1.Id);
        GenerateDocumnetController.sendEmailGenerateAgreementdetailsrequest(book1.Id, 'Nothing');
        GenerateDocumnetController.sendDeviationEmail(book1.Id,'', 'Nothing');
        
        
        
        Test.stopTest();
    }
    
     @isTest
    static void getBookingRecord1() {
     List<Id> bkId = new List<Id>();
     Booking__c book1 = [SELECT Id FROM Booking__c LIMIT 1];
       bkId.add(book1.Id);
        Test.startTest();
        GenerateDocumnetController.sendDeedRescheduledEmail(bkId);
         Test.stopTest();
    }
    
      @isTest
    static void getBookingRecord2() {
         List<Id> bkId = new List<Id>();
    
     Booking__c book1 = [SELECT Id FROM Booking__c LIMIT 1];
         bkId.add(book1.Id);
        Test.startTest();
        GenerateDocumnetController.deedCancellationEmail(bkId);
         Test.stopTest();
    }
        
    
    
    @isTest
    static void testSendEmailGenerateReceipt() {
        Receipt__c receipt = [SELECT Id FROM Receipt__c LIMIT 1];
        Test.startTest();
        GenerateDocumnetController.sendEmailGenerateReceipt(receipt.Id);
        GenerateDocumnetController.getBookingRecordViaReciept(receipt.Id);
        GenerateDocumnetController.getreceiptRecord(receipt.Id);
        GenerateDocumnetController.sendEmailVeegalandReceipt(receipt.Id);
        Test.stopTest();
    }
    
    @isTest
    static void sendEmailGenerateDemand() {
        Test.startTest();
        List<Id> demandIds = new List<Id>();
        Demand_Raised__c demand = [SELECT Id FROM Demand_Raised__c LIMIT 1];
        demandIds.add(demand.Id);
        
        GenerateDocumnetController.sendEmailGenerateDemand(demandIds);
        Test.stopTest();
    }
    
    @isTest
    static void sendDraftAgreementEmail() {
        Test.startTest();
        Set<Id> bookingIds = new Set<Id>();
        List<Id> bookinglist = new List<Id>();
        Booking__c book1 = [SELECT Id,agreement_Details_Verification__c FROM Booking__c LIMIT 1];
        bookingIds.add(book1.Id);
        bookinglist.add(book1.Id);
        
        
        GenerateDocumnetController.sendDraftAgreementEmail(bookingIds);
        GenerateDocumnetController.sendRescheduleEmailsAsync(bookingList);
        GenerateDocumnetController.sendCancellationEmails(bookingList);
        GenerateDocumnetController.sendAgreementSharedEmail(bookingList);
        GenerateDocumnetController.saledeedCompletedEmail(bookingList);
        GenerateDocumnetController.sendNameBoardMail(book1.Id, 'Nothing');
        GenerateDocumnetController.agreementDetailsRecievedMail(bookingList);
        GenerateDocumnetController.sendSaledeedCompleteionMail(bookingIds);
        GenerateDocumnetController.handOverMailSend(bookingIds);
        GenerateDocumnetController.cancellationApprovalMail(bookingIds);
        GenerateDocumnetController.cancellationRejectionMail(bookingIds);
        GenerateDocumnetController.sendSwapDetailInitiation(bookingIds);
        GenerateDocumnetController.testCover();
        
        Test.stopTest();
    }
    
      @isTest
    static void sendDraftAgreementEmail1() {
        Test.startTest();
        Set<Id> bookingIds = new Set<Id>();
        List<Id> bookinglist = new List<Id>();
        Booking__c book1 = [SELECT Id FROM Booking__c LIMIT 1];
        bookingIds.add(book1.Id);
        bookinglist.add(book1.Id);
        
        GenerateDocumnetController.sendParkingSelectionEmails(bookingList);
        
        Test.stopTest();
    }
    
    @isTest
    static void sendRegisterdAgreement() {
        Test.startTest();
        
        Booking__c book1 = [SELECT Id FROM Booking__c LIMIT 1];
        
        
        //Creating content version
        ContentVersion cv2 = new ContentVersion(
            Title = 'Sale Agreement',
            PathOnClient = 'Sale_Agreement.pdf',
            VersionData = Blob.valueOf('Sale Agreement'),
            ExternalDocumentInfo1 = book1.Id, 
            ExternalDocumentInfo2 = 'FromApp'
            
            
        );
        insert cv2;
        
        // Step 3: Retrieve ContentDocumentId
        ContentVersion insertedCv2 = [SELECT Id, ContentDocumentId,IsLatest FROM ContentVersion WHERE Id = :cv2.Id LIMIT 1];
        
        // Step 4: Link ContentDocument to Parking_Floor__c
        List<ContentDocumentLink> existingLinks1 = [
            SELECT Id 
            FROM ContentDocumentLink 
            WHERE ContentDocumentId = :insertedCv2.ContentDocumentId 
            AND LinkedEntityId = :book1.Id
        ];
        if (existingLinks1.isEmpty()) {
            ContentDocumentLink newLink2 = new ContentDocumentLink(
                ContentDocumentId = insertedCv2.ContentDocumentId,
                LinkedEntityId = book1.Id,
                ShareType = 'V'
            );
            insert newLink2;
        }
        List<Id> conIdList =  new List<Id>();
        conIdList.add(insertedCv2.ContentDocumentId);
        GenerateDocumnetController.sendRegisterdAgreement(book1.Id, 'Nothing', conIdList);
        
        Test.stopTest();
    }
    
    
    @isTest
    static void UnitSwapApproved() {
        Test.startTest();
        Set<Id> bookingIds = new Set<Id>();
        
        Booking__c book1 = [SELECT Id FROM Booking__c LIMIT 1];
        bookingIds.add(book1.Id);
        GenerateDocumnetController.UnitSwapApproved(bookingIds);  
        GenerateDocumnetController.UnitSwapRejected(bookingIds);  
        
        Test.stopTest();
    }
    @isTest
    static void sendEmailGenerateAdditionalCharges() {
        Test.startTest();
        
        
        Booking__c book1 = [SELECT Id FROM Booking__c LIMIT 1];
        Additional_Charges__c addcharge = new Additional_Charges__c(
            Booking__c = book1.Id,
            Is_Demanded__c = true,
            Additional_Charge_Type__c = 'Maintenance Charges',
            Demanded_Date__c = Date.today()
            
        );
        
        GenerateDocumnetController.sendEmailGenerateAdditionalCharges(book1.Id);  
        
        Test.stopTest();
    }
    
    
    @isTest
    static void testSendEmailRefund() {
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
        Refund__c refund = new Refund__c(
            Booking__c = booking.Id,
            Bank_Name__c = 'SBI',
            Voucher_No__c = 'VCH-REF123',
            Receipt_Number__c = 'REF-R123',
            Transaction_Number__c = 'REF-TRX-001',
            Refund_Date__c = Date.today()
        );
        insert refund;
        
        Test.startTest();
        String result = GenerateDocumnetController.sendEmailRefund(refund.Id);
        Test.stopTest();
        
        
    }
    @isTest
    static void testSendEmailAdvanceGSTReceipt() {
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
        Advance_Receipt__c ar = new Advance_Receipt__c(
            Booking__c = booking.Id,
            Mode_of_payment__c = 'NEFT',
            Advance_Amount__c = 10000,
            Cheque_Transaction_Number__c = 'TXN123456',
            Invoice_Id__c = 'INV-1001'
        );
        insert ar;
        
        Test.startTest();
        GenerateDocumnetController.sendEmailAdvanceGSTReceipt(ar.Id);
        GenerateDocumnetController.sendEmailAdvanceReceipt(ar.Id);
        Test.stopTest();
        
        
    }
    @isTest
    static void testSendEmailCreditNote() {
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
        Refund__c refund = new Refund__c(
            Booking__c = booking.Id,
            Bank_Name__c = 'HDFC',
            Voucher_No__c = 'VCH-001',
            Receipt_Number__c = 'R-123',
            Transaction_Number__c = 'TRX-001'
        );
        insert refund;
        
        Test.startTest();
        String result = GenerateDocumnetController.sendEmailCreditNote(refund.Id);
        Test.stopTest();
        
        
    }

    
    
    
    
    
    //pending
    // validate email
    // 
    
    
    
    /* Test.startTest();
// GenerateDocumnetController.getBookingRecord(book1.Id);

// GenerateDocumnetController.SaleAgreementWrapper wrapper = new GenerateDocumnetController.SaleAgreementWrapper(book1, 'Sales_agreement_One_applicant_with_POA');



// GenerateDocumnetController.getSaleAgreement(book1.Id);
//GenerateDocumnetController.getBookingRecordViaReciept(receipt.Id);
// GenerateDocumnetController.getreceiptRecord(receipt.Id);
// GenerateDocumnetController.sendEmailGenerateReceipt(receipt.Id);
// GenerateDocumnetController.sendEmailVeegalandReceipt(receipt.Id);
// GenerateDocumnetController.convert(18);
// GenerateDocumnetController.sendEmailPrintAllReceipt(book1.Id);
GenerateDocumnetController.sendEmailGenerateSA(book1.Id, 'test');





GenerateDocumnetController.sendEmailGenerateNOC(book1.Id);
GenerateDocumnetController.sendEmailGenerateTPA(book1.Id);
//  GenerateDocumnetController.cancellationRejectionMail(bookingSet);
// GenerateDocumnetController.cancellationApprovalMail(bookingSet);
//GenerateDocumnetController.handOverMailSend(bookingSet);
//GenerateDocumnetController.sendSaledeedCompleteionMail(bookingSet);
// GenerateDocumnetController.sendRegisterdAgreement(book1.Id, 'Nothing', null);
// GenerateDocumnetController.agreementDetailsRecievedMail(bookingList);
GenerateDocumnetController.sendEmailGenerateAgreementdetailsrequest(book1.Id, 'Nothing');

GenerateDocumnetController.sendNameBoardMail(book1.Id, 'Nothing');

GenerateDocumnetController.saledeedCompletedEmail(bookingList);
GenerateDocumnetController.sendAgreementSharedEmail(bookingList);
GenerateDocumnetController.sendCancellationEmails(bookingList);
GenerateDocumnetController.sendRescheduleEmailsAsync(bookingList);
GenerateDocumnetController.sendFInalAppoinmentMail(book1.Id, 'Nothing');
List<String> email = new  List<String>();
email.add('test@gmail.com');
GenerateDocumnetController.validateEmails(email);

GenerateDocumnetController.sendExtraCostDemandMail(book1.Id, 'Nothing');
GenerateDocumnetController.sendAgreementCostMail(book1.Id, 'Nothing');


//GenerateDocumnetController.sendEmailGenerateDemand(idList);// throwing error
GenerateDocumnetController.sendEmailGenerateCarParking(book1.Id, 'test');
GenerateDocumnetController.sendDraftAgreementEmail(bookingSet);
// GenerateDocumnetController.processSaleDeedForApprovedReceipts(recList, 'TestTemplate');// doubt regarding which template; not using this one
//   GenerateDocumnetController.sendAdvanceAmountReceipt(book1.Id);// throwing error


// GenerateDocumnetController.sendSwapDetailInitiation(bookingSet);
//GenerateDocumnetController.sendEmailGenerateDemand(idList);
Test.stopTest();*/
    
    
    
    
}