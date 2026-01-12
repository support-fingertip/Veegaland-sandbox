@isTest
public class LightningFileUploadHandlerTest {
    
    @isTest
    public static void fileUploadHandler() {
        // Create test User
        User owner = new User(
            Email = 'owner112@example.com',
            Alias = 'owner',
            LastName = 'andy',
            ProfileId = UserInfo.getProfileId(),
            Username = 'owner43221163@example.com',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Working__c = true,
            isActive = true,
            Availability__c = true
        );
        insert owner;
        
        // Create test Project
        Project__c project = new Project__c(
            Name = 'Veegaland Green Heights',
            Project_Type__c = 'Apartments',
            Finance_User__c = owner.Id,
            CRM_Manager__c = owner.Id,
            Legal_User__c = owner.Id,
            Legal_User2__c = owner.Id
        );
        insert project;
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf('Sample Signature'));
        List<id> contId = new List<id>();
        
        Test.startTest();
        FileUploadController.fileUpload(project.Id, 'Aadhar.jpg', 'jpg', base64Data, 'Aadhar');
         FileUploadController.fileUpload(project.Id, 'Photo.jpg', 'jpg', base64Data, 'Photo');
         FileUploadController.fileUpload(project.Id, 'Passport.jpg', 'jpg', base64Data, 'Passport');
         FileUploadController.fileUpload(project.Id, 'PAN.jpg', 'jpg', base64Data, 'PAN');
        LightningFileUploadHandler.getFiles(project.Id);
        List<ContentDocument> contentdoc =  FileUploadControlller.getFiles(project.Id);
        LightningFileUploadHandler.deleteFile(contentdoc[0].Id);
        Test.stopTest();
    }
}