@isTest
public class DraftAgreementControllerTest {
    @isTest
    public static void draftAgreement(){
         Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
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
        
        Plot__c unit = new Plot__c();
        unit.Name = '101';
        unit.Status__c = 'Available';
        unit.Project__c = project.Id;
        unit.Block__c = 'A4';
        unit.Plot_Type__c = 'Residential';
        unit.Block1__c = block.Id;
        unit.Carpet_Area__c = 850;
        unit.Balcony_Sq_mts__c = 20;
        unit.Balcony_Area__c = 100;
        unit.BHK_Type__c = '1 BHK';
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
        
        
        Quote__c Qt = new Quote__c(
            Discount_In_Rupees__c = 100,
            Leads__c = ld.id,
            Project__c = 'Veegaland Green Heights',
            Unit__c =unit.Id,
            Car_Parking_Charge__c = 70,
            Extra_car_parking_charges__c = 10,
            Floor_Rise_Charges__c = 10,
            Built_up_area__c = 2000
        );
        
        insert Qt;
        
        Booking__c book = new Booking__c();
        book.SLead__c = ld.Id;
        book.Quote__c = Qt.Id;
        book.Payment_Plan__c = payplan.Id;
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
        
        Set<Id> bkIdList = new Set<Id>();
        bkIdList.add(book.Id);
        
           // Step 4: Prepare test file data (base64-encoded string)
           // // Insert test "Draft Sale Agreement" document
            ContentVersion cvDraft = new ContentVersion(
                Title = 'Draft Sale Agreement',
                PathOnClient = 'Draft.pdf',
                VersionData = Blob.valueOf('PDF TEST CONTENT')
            );
            insert cvDraft;
            
            Id draftDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cvDraft.Id].ContentDocumentId;
            
            insert new ContentDocumentLink(
                ContentDocumentId = draftDocId,
                LinkedEntityId = book.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            );
            
            // Insert test "Final Draft Agreement" document
            ContentVersion cvFinal = new ContentVersion(
                Title = 'Final Draft Agreement Test',
                PathOnClient = 'Final.pdf',
                VersionData = Blob.valueOf('PDF TEST FINAL CONTENT')
            );
            insert cvFinal;
            
            Id finalDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cvFinal.Id].ContentDocumentId;
            
            insert new ContentDocumentLink(
                ContentDocumentId = finalDocId,
                LinkedEntityId = book.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            );
        
        
        DraftAgreementController.getAgreementDetails(book.Id);
        DraftAgreementController.saveFileAndSendEmail(book.Id);
        DraftAgreementController.saveFinalFileAndSendEmail(book.Id);
        DraftAgreementController.sendAgreementdetailsrequest(book.Id, '');
        DraftAgreementController.updateBookingVerificationStatus(book.Id, 'Rejected', 'rejectionComment');
        DraftAgreementController.updateBookingVerificationStatus(book.Id, 'Verified', 'rejectionComment');
        DraftAgreementController.sendRejectionEmail(book.Id, 'rejectionComment');
        DraftAgreementController.submitForApproval(book.Id);
        DraftAgreementController.updateBookingURL(book.Id,draftDocId);
        DraftAgreementController.updatefinalSaleAgreementUpload(book.Id,draftDocId);
        DraftAgreementController.notifyAgreementDetailsApproved(bkIdList);
    }

}