@isTest
public class ContentServiceControllerTest {
    
    public static testMethod void contentService(){
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
        
        Parking_Floor__c pf = new Parking_Floor__c(
            name = 'First floor',
            Project__c = project.Id
        );
        insert pf;
        
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf('Sample parking'));
        List<id> contentDistributions = new List<id>();
        Test.startTest();
        FileUploadController.multifileUpload(pf.Id, 'Sample Signature.jpg', 'jpg', base64Data, 'Test', true);
        List<ContentDistribution> contentDistributionLinks = [
            SELECT Id, ContentVersionId, ContentDownloadUrl 
            FROM ContentDistribution 
        ];
        for(ContentDistribution cont : contentDistributionLinks){
            contentDistributions.add(cont.Id);
        }
        ContentServiceController.updateParkingFloorWithDownloadUrl(contentDistributions);
        Test.stopTest();
    }
    
}