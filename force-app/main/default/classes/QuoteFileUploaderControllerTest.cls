@isTest
public class QuoteFileUploaderControllerTest {
    @isTest
    public static void quoteFIleUploader(){
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
        unit.BHK_Type__c = '3 BHK + 2T';
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
            //Leads__c = ld1.id,
            Project__c = 'Veegaland Green Heights',
            Unit__c =unit.Id,
            Car_Parking_Charge__c = 70,
            Extra_car_parking_charges__c = 10,
            Floor_Rise_Charges__c = 10,
            Built_up_area__c = 2000
        );
        
        insert Qt;
        
         // content documents
         ContentVersion cv = new ContentVersion();
        cv.Title = 'Aadhar';
        cv.PathOnClient = 'AadharCardFile.pdf';
        cv.VersionData = Blob.valueOf('Dummy content');
      
        insert cv;
        
         ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        
        // Create ContentDocumentLink manually
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = Qt.Id;
        cdl.ContentDocumentId = insertedCV.ContentDocumentId;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        
         // content documents for Pan
         ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'PAN';
        cv1.PathOnClient = 'PAN.pdf';
        cv1.VersionData = Blob.valueOf('Dummy content');
      
        insert cv1;
        
         ContentVersion insertedCV1 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv1.Id LIMIT 1];
        
        // Create ContentDocumentLink manually
        ContentDocumentLink cdl1 = new ContentDocumentLink();
        cdl1.LinkedEntityId = Qt.Id;
        cdl1.ContentDocumentId = insertedCV1.ContentDocumentId;
        cdl1.ShareType = 'V';
        cdl1.Visibility = 'AllUsers';
        insert cdl1;
        
        
         // content documents for Passport
         ContentVersion cv2 = new ContentVersion();
        cv2.Title = 'Passport';
        cv2.PathOnClient = 'Passport.pdf';
        cv2.VersionData = Blob.valueOf('Dummy content');
      
        insert cv2;
        
         ContentVersion insertedCV2 = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv2.Id LIMIT 1];
        
        // Create ContentDocumentLink manually
        ContentDocumentLink cdl2 = new ContentDocumentLink();
        cdl2.LinkedEntityId = Qt.Id;
        cdl2.ContentDocumentId = insertedCV2.ContentDocumentId;
        cdl2.ShareType = 'V';
        cdl2.Visibility = 'AllUsers';
        insert cdl2;
        QuoteFileUploaderController.getUploadedFiles(Qt.Id);
        QuoteFileUploaderController.uploadFile(Qt.Id, 'base64Data', 'Aadhar');
        QuoteFileUploaderController.uploadFile(Qt.Id, 'base64Data', 'PAN');
        QuoteFileUploaderController.uploadFile(Qt.Id, 'base64Data', 'Passport');
        
    }

}