@isTest
public class GenericLocationMapControllerTest {

    @isTest
    public static void testGetLocationDetails() {
        // Create a mock Project__c record with necessary fields
        // Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
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

        
        Project__c testProject = new Project__c(
            Name = 'Veegaland Green Heights',
            Project_Type__c='Apartments',
            Register_Office__c = 'Test Location',
            City__c = 'Test City',
            Register_Office_Location__Latitude__s = 37.7749,
            Register_Office_Location__Longitude__s = -122.4194
        );
        insert testProject;

        // Call the method with parameters for the Project__c object
        Test.startTest();
        Map<String, Object> result = GenericLocationMapController.getLocationDetails(
            'Project__c', 
            testProject.Id, 
            'Register_Office__c', 
            'Register_Office_Location__c', 
            'City__c'
        );
        Test.stopTest();

    }

    @isTest
    public static void testInvalidLocationData() {
        // Create a mock Project__c record with invalid location data (no latitude or longitude)
        Project__c testProject = new Project__c(
            Name = 'Veegaland Green Heights',
            Register_Office__c = 'Test Location',
            City__c = 'Test City'
        );
        insert testProject;

        // Call the method with missing geolocation data
        Test.startTest();
        Map<String, Object> result = GenericLocationMapController.getLocationDetails(
            'Project__c', 
            testProject.Id, 
            'Register_Office__c', 
            'Register_Office_Location__c', 
            'City__c'
        );
        Test.stopTest();

    }
}