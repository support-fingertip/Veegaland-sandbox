@IsTest
public class BookingFileUploadControllerTest {

    @TestSetup
    static void setupTestData() {
        User owner = new User(
            Email = 'owner112@example.com',
            Alias = 'owner',
            LastName = 'andy',
            ProfileId = UserInfo.getProfileId(),
            Username = 'owner43221163@example.com',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert owner;
        
        Project__c project = new Project__c();
        project.Name = 'Veegaland Green Heights';
        project.Project_Type__c = 'Apartments';
        project.Finance_User__c = owner.Id;
        project.CRM_Manager__c = owner.Id;
        insert project;
        
        Block__c block = new Block__c();
        block.Name = 'A';
        block.Project__c = project.Id;
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
        unit1.BHK_Type__c = '3 BHK + 2T';
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
        
        Booking__c book = new Booking__c();
        book.Followup_Date__c = system.today();
        book.Followup_Subject__c = 'test22';
        book.Last_Comment__c = 'test22';
        book.Project__c = 'Veegaland Green Heights';
        book.Payment_Type__c = 'Custom';
        book.Sale_Agreement_Completed__c = false;
        book.Agreement_Amount_Cleared__c = 'Received Partial Amount';
        book.Stage__c = 'Welcome Email';
        book.Demand_Number__c = '12345'; 
        book.Project1__c = project.Id; 
        book.Date_of_Booking__c = System.today(); 
        book.Mode_Of_Payment__c = 'Credit Card';
        book.Funding_Type__c = 'Self';
        book.Plot__c = unit1.Id;
        book.Loan_Sanction_Confirmed__c = true;
        book.Loan_Sanctioned_Amount__c = 10000;
        book.Finance_User__c = owner.Id;
        book.First_Applicant_Name__c = 'Akhil';
        book.Email1__c = 'Test@gamil.com';
        insert book;
    }

    @IsTest
    static void testGetFiles() {
        // Retrieve the created booking
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
        List<ContentVersion> cvs = new List<ContentVersion>();
        
        // Floor Plan
        ContentVersion floorPlanCV = new ContentVersion(
            Title = 'Floor Plan',
            PathOnClient = 'FloorPlan.pdf',
            VersionData = Blob.valueOf('This is a test Floor Plan PDF'), 
            FirstPublishLocationId = booking.Id
        );
        cvs.add(floorPlanCV);
        
        // Plumbing Plan
        ContentVersion plumbingPlanCV = new ContentVersion(
            Title = 'Plumbing Plan',
            PathOnClient = 'PlumbingPlan.pdf',
            VersionData = Blob.valueOf('This is a test Plumbing Plan PDF'), 
            FirstPublishLocationId = booking.Id
        );
        cvs.add(plumbingPlanCV);
        
        insert cvs;
        
        // Call the getFiles method
        List<ContentDocument> result = BookingFileUploadController.getFiles(booking.Id, 'Floor Plan');
        
        // Assert that at least one ContentDocument is returned and it has the title 'Floor Plan'
        System.assert(result.size() > 0, 'No files found');
        System.assert(result[0].Title.contains('Floor Plan'), 'Incorrect file returned');
    }
    
    @IsTest
    static void bookingFileUpload() {
        // Retrieve the created booking and content version
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test document data'),
            FirstPublishLocationId = booking.Id
        );
        insert contentVersion;
        
        // Get ContentDocumentId
        ContentDocumentLink link = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :booking.Id LIMIT 1];
        
        // Call the deleteFile method
        Test.startTest();
        BookingFileUploadController.leadststus(booking.Id);
        BookingFileUploadController.accountstatus(booking.Id);
        BookingFileUploadController.deleteFile(link.ContentDocumentId);
        Test.stopTest();

    }
    
     @IsTest
    static void testDeleteFile() {
        // Retrieve the created booking and content version
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test document data'),
            FirstPublishLocationId = booking.Id
        );
        insert contentVersion;
        
        // Get ContentDocumentId
        ContentDocumentLink link = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :booking.Id LIMIT 1];
        
        // Call the deleteFile method
        Test.startTest();
        BookingFileUploadController.deleteFile(link.ContentDocumentId);
        Test.stopTest();

    }
    
    @IsTest
    static void testUpdateDocument() {
        // Create content documents to update
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'Old Title 1',
            PathOnClient = 'File1.pdf',
            VersionData = Blob.valueOf('Test file data 1'),
            FirstPublishLocationId = booking.Id
        );
        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'Old Title 2',
            PathOnClient = 'File2.pdf',
            VersionData = Blob.valueOf('Test file data 2'),
            FirstPublishLocationId = booking.Id
        );
        insert new List<ContentVersion>{ contentVersion1, contentVersion2 };
        
        // Get content document ids
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE Title IN ('Old Title 1', 'Old Title 2')];
        List<String> idList = new List<String>();
        for (ContentDocument doc : contentDocuments) {
            idList.add(doc.Id);
        }
        
        // Call the updateDocument method
        Test.startTest();
        BookingFileUploadController.updateDocument('New Prefix', idList);
        Test.stopTest();
        
        // Verify the documents have been updated
        contentDocuments = [SELECT Title FROM ContentDocument WHERE Id IN :idList];
        System.assert(contentDocuments[0].Title.contains('New Prefix'), 'Document 1 title not updated');
        System.assert(contentDocuments[1].Title.contains('New Prefix'), 'Document 2 title not updated');
    }
    
    @IsTest
    static void testGetFilesAll() {
        // Retrieve the created booking
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
        
        // Create ContentVersions with different titles
        ContentVersion cv1 = new ContentVersion(
            Title = 'Floor Plan - Test',
            PathOnClient = 'FloorPlan.pdf',
            VersionData = Blob.valueOf('Test Floor Plan PDF'),
            FirstPublishLocationId = booking.Id
        );
        ContentVersion cv2 = new ContentVersion(
            Title = 'Plumbing Plan - Test',
            PathOnClient = 'PlumbingPlan.pdf',
            VersionData = Blob.valueOf('Test Plumbing Plan PDF'),
            FirstPublishLocationId = booking.Id
        );
        insert new List<ContentVersion>{ cv1, cv2 };
        
        // Call the getFilesAll method
        List<ContentDocument> result = BookingFileUploadController.getFilesAll(booking.Id, 'Plan');
        
        // Assert that both files are returned
        System.assert(result.size() > 0, 'No files found');
        System.assert(result[0].Title.contains('Plan'), 'Incorrect file returned');
    }
}