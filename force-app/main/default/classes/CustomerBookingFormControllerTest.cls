@isTest
public class CustomerBookingFormControllerTest {
    @isTest
    
    public static void customerBooking(){
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
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
        
        Payment_Plan__c payplan = new Payment_Plan__c();
        payplan.Active__c = true;
        payplan.Project__c = project.id;
        insert payplan;
        
        
        List<Id> bookIds = new  List<Id>();
        //create booking
        List<Booking__c> bookList = new List<Booking__c>();
        Booking__c book = new Booking__c();
        book.SLead__c = ld.Id;
        book.Quote__c = Qt.Id;
        book.Project1__c = project.Id;
        book.Payment_Plan__c = payplan.Id;
        book.Followup_Date__c = system.today();
        book.Followup_Subject__c = 'test22';
        book.Last_Comment__c = 'test22';
        book.Project__c = 'Veegaland Green Heights';
        book.Payment_Type__c = 'Custom';
        book.Sale_Agreement_Completed__c = false;
        book.Agreement_Amount_Cleared__c ='Received Partial Amount';
        book.Stage__c ='Token Amount Collection';
        book.Demand_Number__c = '12345'; 
        book.Date_of_Booking__c = System.today(); 
        book.Mode_Of_Payment__c = 'Credit Card';
        book.Funding_Type__c = 'Loan';
        book.Plot__c = unit.Id;
        book.Loan_Sanction_Confirmed__c = true;
        book.Loan_Sanctioned_Amount__c = 10000;
        book.Finance_User__c = owner.Id;
        book.Sales_Manager1__c = owner.Id;
        book.Sales_Executive__c =owner.Id;
        book.Legal_Team__c = owner.Id;
        book.CRM_Manager__c=owner.Id;
        book.First_Applicant_Name__c = 'Akhil';
        book.Legal_Advocate_Assigned__c = owner.Id;
        book.Email1__c = 'Test@gamil.com';
        insert book;
        bookIds.add(book.Id);
        
        
        
        bookList.add(book);
        
        // create quote record
        
        Quote__c Qt1 = new Quote__c(
            Discount_In_Rupees__c = 100,
            // Leads__c = ld.id,
            Project__c = 'Veegaland Green Heights',
            Unit__c =unit.Id,
            Car_Parking_Charge__c = 70,
            Extra_car_parking_charges__c = 10,
            Floor_Rise_Charges__c = 10,
            Built_up_area__c = 2000
        );
        
        insert Qt1;
        
        // Iinsert co applicant record
        Co_Applicant__c coapp = new Co_Applicant__c(
            Booking__c = book.Id,
            Name = 'test',
            Quote__c = Qt1.Id
        ); 
        insert coapp;
        
        //Creating content version
        ContentVersion cv = new ContentVersion(
            Title = 'Applicant Aadhar Card Front',
            PathOnClient = 'Applicant Aadhar Card Front.pdf',
            VersionData = Blob.valueOf('Applicant Aadhar Card Front'),
            ExternalDocumentInfo1 = Qt1.Id, 
            ExternalDocumentInfo2 = 'FromApp'
            
        );
        
        insert cv;
        
        //Creating content version
        ContentVersion cv1 = new ContentVersion(
            Title = 'Applicant PAN Card',
            PathOnClient = 'PAN Card.pdf',
            VersionData = Blob.valueOf('Applicant PAN Card'),
            ExternalDocumentInfo1 = Qt1.Id, 
            ExternalDocumentInfo2 = 'FromApp'
            
        );
        
        insert cv1;
        
        //Creating content version
        ContentVersion cv2 = new ContentVersion(
            Title = 'Applicant Passport Size Photo',
            PathOnClient = 'Passport Size Photo.pdf',
            VersionData = Blob.valueOf('Applicant Passport Size Photo'),
            ExternalDocumentInfo1 = Qt1.Id, 
            ExternalDocumentInfo2 = 'FromApp'
            
        );
        
        insert cv2;
        
        
        ContentVersion insertedCv1 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv1.Id LIMIT 1];
        
        // Step 3: Link document to Co-Applicant
        ContentDocumentLink link1 = new ContentDocumentLink(
            ContentDocumentId = insertedCv1.ContentDocumentId,
            LinkedEntityId = coapp.Id,
            ShareType = 'V' // View access
        );
        insert link1;
        
        
        
        
        
        
        
        // Get the associated ContentDocumentId
        ContentVersion insertedCv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        
        // Step 3: Link document to Co-Applicant
        ContentDocumentLink link = new ContentDocumentLink(
            ContentDocumentId = insertedCv.ContentDocumentId,
            LinkedEntityId = coapp.Id,
            ShareType = 'V' // View access
        );
        insert link;
        
        
        ContentVersion insertedCv2 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv2.Id LIMIT 1];
        
        ContentDocumentLink link2 = new ContentDocumentLink(
            ContentDocumentId = insertedCv2.ContentDocumentId,
            LinkedEntityId = coapp.Id,
            ShareType = 'V' // View access
        );
        insert link2;
        
        
        // Serialize quote and co-applicant
        String quoteJson = JSON.serialize(Qt1);
        String coApplicantsJson = JSON.serialize(new List<Co_Applicant__c>{ coapp });
        
        // Create base64 content
        String dummyFileContent = 'This is dummy file content';
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf(dummyFileContent));
        
        // Call method with valid inputs
        String result = CustomerBookingFormController.uploadCoApplicantFile(
            quoteJson,
            coApplicantsJson,
            coapp.Id,
            'TestFile.pdf',
            base64Data,
            'Aadhar Card',
            'Applicant Aadhar Card'
        );
        
        
        Blob testBlob = Blob.valueOf('File Content');
        String testFileName = 'TestAadhar.pdf';
        String docType = 'Aadhar Card';
        
        
        
        ApexPages.currentPage().getParameters().put('Id', Qt1.Id);
        
        CustomerBookingFormController c = new  CustomerBookingFormController();
        
        CustomerBookingFormController.getCoApplicants(Qt1.Id);
        CustomerBookingFormController.getBookingDetails(Qt1.Id);
        CustomerBookingFormController.getQuoteDocuments(Qt1.Id);
        CustomerBookingFormController.saveBookingAndCoApplicants('','');
        CustomerBookingFormController.deleteCoApplicant(coapp.Id);
        CustomerBookingFormController.createBlankCoApplicant(Qt1.Id);
        
        // Use the same key as in the decrypt method
        String keyString = 'fingerti(#p#)rivateLimited#edKey';
        Blob key = Blob.valueOf(keyString);

        // Prepare some test data
        String originalText = 'TestRecordId12345';
        Blob plainBlob = Blob.valueOf(originalText);
        
        // Encrypt the text using the same algorithm and key
        Blob encryptedBlob = Crypto.encryptWithManagedIV('AES256', key, plainBlob);
        
        // Convert encrypted data to Base64 string
        String encryptedBase64 = EncodingUtil.base64Encode(encryptedBlob);
        
        // Call the method under test
        String decryptedText = CustomerBookingFormController.decryptRecordId(encryptedBase64);
        
        
    
        c.uploadDocument('Applicant Aadhar Card');
        c.uploadAadhar();
        c.uploadPan();
        c.uploadPhoto();
        c.saveFile(Blob.valueOf('Applicant Aadhar Card'), 'Applicant Aadhar Card','Applicant Aadhar Card');
        // CustomerBookingFormController.decryptRecordId('');
        CustomerBookingFormController.uploadFile('PAN Card', 'test','',coapp.Id);
        // CustomerBookingFormController.uploadCoApplicantFile('','',coapp.Id,'PAN card','base64Data','','test');
        
        
        
        
        
    }
      @isTest
    static void testUploadDocument() {
        // Create and initialize the controller
        CustomerBookingFormController controller = new CustomerBookingFormController();

        // Set up mock file data
        Test.startTest();
        controller.fileToUpload = Blob.valueOf('Test file content');
        controller.fileNameToUpload = 'testfile.pdf';

        // Call the method to test
        controller.uploadDocument('PAN');

        Test.stopTest();

       
    }
    
}