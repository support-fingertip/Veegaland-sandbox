@isTest
public class UnitPriceChangeControllerTest {

    @isTest
    static void testGetUserDetails() {
        // Setup test data
        User testuser = new User(
            FirstName = 'CRM',
            LastName = 'Manager',
            Alias = 'crmmgr',
            Email = 'crmmanager1@example.com',
            Username = 'crmmanager1' + DateTime.now().getTime() + '@testorg.com',
            CommunityNickname = 'crmmgrnick',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testuser;

        Test.startTest();
        List<User> userDetails = UnitPriceChangeController.getuserdetails();
        Test.stopTest();

    }

    @isTest
    static void testGetCon() {
        // Setup test data
        User testuser = new User(
            FirstName = 'CRM',
            LastName = 'Manager',
            Alias = 'crmmgr',
            Email = 'crmmanager@example.com',
            Username = 'crmmanager' + DateTime.now().getTime() + '@testorg.com',
            CommunityNickname = 'crmmgrnick',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testuser;
        
Project__c project = new  Project__c();
        project.Name = 'Veegaland Green Heights';
        project.Project_Type__c='Apartments';
        project.Finance_User__c = testuser.Id;
        project.CRM_Manager__c =  testuser.Id;
        project.Legal_User__c = testuser.Id;
        project.Legal_User2__c = testuser.Id;
        insert project;
        
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Company = 'testCompany';
        ld.phone ='9876543459';
        ld.LeadSource = '99 acres';
        ld.Project_City__c = 'Ernakulam';
        ld.Email ='test@gmail.com';
        ld.Secondary_Email__c ='test2@gmail.com';
        ld.OwnerId=testuser.Id;
        
        insert ld; 
        
        Lead ld1 = new Lead();
        ld1.LastName = 'test';
        ld1.Company = 'testCompanyxx';
        ld1.phone ='9876543457';
        ld1.LeadSource = '99 acres';
        ld1.Project_City__c = 'Ernakulam';
        ld1.Email ='test1234@gmail.com';
        ld1.Secondary_Email__c ='test2343@gmail.com';
        ld1.OwnerId=testuser.Id;
        
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
        unit1.BHK_Type__c = '3 BHK';
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
        
        Test.startTest();
        List<Plot__c> plotList = UnitPriceChangeController.getcon(
            testUser.Id, 
            'Project1', 
            '2 BHK', 
            'Available', 
            'Block A', 
            'Tower A'
        );
        Test.stopTest();
    }

    @isTest
    static void testGetTowers() {
        // Setup test data
        Block__c testBlock = new Block__c(Name = 'Block A');
        insert testBlock;

        Test.startTest();
        Map<String, String> towersMap = UnitPriceChangeController.getTowers();
        Test.stopTest();

    }

    @isTest
    static void testGetBhkType() {
        // This is dependent on the picklist values in Plot__c.BHK_Type__c field

        Test.startTest();
        Map<String, String> bhkTypeMap = UnitPriceChangeController.getBhkType();
        Test.stopTest();

     
    }

    @isTest
    static void testGetUnitStatus() {
        // This is dependent on the picklist values in Plot__c.Status__c field

        Test.startTest();
        Map<String, String> unitStatusMap = UnitPriceChangeController.getUnitStatus();
        Test.stopTest();

      
    }

    @isTest
    static void testGetBlocks() {
        // This is dependent on the picklist values in Plot__c.Block__c field

        Test.startTest();
        Map<String, String> blocksMap = UnitPriceChangeController.getBlocks();
        Test.stopTest();

     
    }

    @isTest
    static void testUpdateOwner() {
        // Setup test data
        Project__c pr = new  Project__c();
        pr.Name = 'Aarya';
        pr.Project_Type__c='Apartments';
        insert pr;
        
        Block__c blk = new Block__c();
        blk.Name='A';
        blk.Project__c=pr.id;
        insert blk;
        
        Plot__c pl2 = new Plot__c();
        pl2.Name = '202';
        pl2.Status__c = 'Booked';
        pl2.Project__c = pr.Id;
        pl2.Block__c = 'B7';
        pl2.Plot_Type__c = 'Commercial';
        pl2.Block1__c = blk.Id;
        pl2.Carpet_Area__c = 900;
        pl2.Balcony_Sq_mts__c = 25;
        pl2.Balcony_Area__c = 120;
        pl2.BHK_Type__c = '4 BHK';
        pl2.Premium_Status__c = 'Super Premium';
        pl2.Floor__c = '2';
        pl2.Share__c = 'LAND OWNER';
        pl2.Facing__c = 'NORTH';
        pl2.Carpet_Sq_mts__c = 85;
        pl2.CA__c = 70;
        pl2.Built_up_area__c = 1300;
        pl2.UDS__c = 350;
        pl2.UDS_Sq_mts__c = 55;
        pl2.Super_built_up_area__c = 1600;
        pl2.Price_Per_Sq_Ft__c = 5500;
        pl2.Floor_Rise__c = 250;
        pl2.Premium_Charge__c = 120000;
        pl2.Covered_Park_Parking__c = 60000;
        pl2.Other_Charges__c = 25000;
        pl2.Solar_Charges__c = 18000;
        pl2.GST1__c = 18;
        
        insert pl2;
        
        Plot__c pl = new Plot__c();
        pl.Name = '101';
        pl.Status__c = 'Available';
        pl.Project__c = pr.Id;
        pl.Block__c = 'A4';
        pl.Plot_Type__c = 'Residential';
        pl.Block1__c = blk.Id;
        pl.Carpet_Area__c = 850;
        pl.Balcony_Sq_mts__c = 20;
        pl.Balcony_Area__c = 100;
        pl.BHK_Type__c = '3 BHK';
        pl.Premium_Status__c = 'Premium';
        pl.Floor__c = '1';
        pl.Share__c = 'MHPL';
        pl.Facing__c = 'EAST';
        pl.Carpet_Sq_mts__c = 80;
        pl.CA__c = 75;
        pl.Built_up_area__c = 1200;
        pl.UDS__c = 300;
        pl.UDS_Sq_mts__c = 50;
        pl.Super_built_up_area__c = 1500;
        pl.Price_Per_Sq_Ft__c = 5000;
        pl.Floor_Rise__c = 200;
        pl.Premium_Charge__c = 100000;
        pl.Covered_Park_Parking__c = 50000;
        pl.Other_Charges__c = 20000;
        pl.Solar_Charges__c = 15000;
        pl.GST1__c = 18;
        Insert pl;
        
        List<Plot__c> plotsToUpdate = new List<Plot__c>();
        plotsToUpdate.add(pl);

        Test.startTest();
        List<Plot__c> updatedPlots = UnitPriceChangeController.updateOwner(plotsToUpdate, 150000);
        Test.stopTest();

      
    }
}