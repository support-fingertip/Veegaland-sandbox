@isTest
public class UnitControllerTest {
    @isTest
    public static void testUnitController(){
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
        
        
        Block__c block = new Block__c();
        block.Name='A';
        block.Project__c=project.id;
        insert block;
        
        List<Plot__c> plotlist = new List<Plot__c>();
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
        unit.Unit_Common_Type__c = 'Type A';
        insert unit;
        plotlist.add(unit);
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Parking Plan A'; // Must match logic in your controller
        contentVersion.PathOnClient = 'ParkingPlanA.pdf';
        contentVersion.VersionData = Blob.valueOf('This is a test Parking Plan A');
        insert contentVersion;
        
        // Get ContentDocumentId
        ContentVersion insertedVersion = [
            SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id
        ];
        
        // Link the document to the Project__c
        ContentDocumentLink docLink = new ContentDocumentLink();
        docLink.ContentDocumentId = insertedVersion.ContentDocumentId;
        docLink.LinkedEntityId = project.Id; 
        docLink.ShareType = 'V';
        docLink.Visibility = 'AllUsers';
        insert docLink;
        
        UnitController.copyProjectDocumentsToUnits(plotlist);
        
        
        
        
        
    }
    
}