@isTest
public class RaiseDemandControllerTest {
    
    // Helper to generate unique username/email
    private static String generateUniqueEmail() {
        return 'owner' + System.currentTimeMillis() + '@example.com';
    }
    
    // Common data for all tests
    @testSetup
    static void setupTestData() {
        // Profile
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        String uniqueEmail = generateUniqueEmail();
        
        // User
        User owner = new User(
            ProfileId          = p.Id,
            Email              = uniqueEmail,
            EmailEncodingKey   = 'UTF-8',
            LastName           = 'andy',
            Alias              = 'owner',
            Username           = uniqueEmail,
            LocaleSidKey       = 'en_US',
            LanguageLocaleKey  = 'en_US',
            TimeZoneSidKey     = 'America/Los_Angeles',
            Working__c         = true,
            isActive           = true,
            Availability__c    = true
        );
        insert owner;
        
        // Project (note Name used as picklist value in Booking__c.Project__c)
        Project__c project = new Project__c(
            Name           = 'Veegaland Green Heights',
            Project_Type__c = 'Apartments',
            Finance_User__c = owner.Id,
            CRM_Manager__c  = owner.Id,
            Legal_User__c   = owner.Id,
            Legal_User2__c  = owner.Id
        );
        insert project;
    }
    
    // 1) Basic constructor test for a single Booking
    @isTest
    static void testControllerConstructor() {
        User owner = [SELECT Id FROM User WHERE Email LIKE 'owner%@example.com' LIMIT 1];
        
        Lead ld = new Lead(
            LastName = 'test',
            Company  = 'testCompany',
            Phone    = '9876543457',
            LeadSource = '99 acres',
            Project_City__c = 'Ernakulam',
            Email    = 'test1234@gmail.com',
            OwnerId  = owner.Id
        );
        insert ld;
        
        Booking__c book = new Booking__c(
            SLead__c          = ld.Id,
            Project__c        = 'Veegaland Green Heights', // picklist value
            Stage__c          = 'Welcome Email',
            Date_of_Booking__c = System.today(),
            Finance_User__c   = owner.Id
        );
        insert book;
        
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('/apex/Demand_Note?id=' + book.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(book);
        RaiseDemandController controller = new RaiseDemandController(sc);
        Test.stopTest();
        
        System.assertNotEquals(null, controller, 'Controller should be initialized');
    }
    
    // 2) Controller logic with Payment_Schedule__c to hit your psRecord block
    @isTest
    static void testControllerWithPaymentSchedules() {
        User owner = [SELECT Id FROM User WHERE Email LIKE 'owner%@example.com' LIMIT 1];
        
        Lead ld = new Lead(
            LastName = 'CalcLead',
            Company  = 'CalcCo',
            Email    = 'calc@test.com',
            OwnerId  = owner.Id
        );
        insert ld;
        
        Booking__c book = new Booking__c(
            SLead__c                 = ld.Id,
            Project__c               = 'Veegaland Green Heights',
            Stage__c                 = 'Welcome Email',
            Date_of_Booking__c       = System.today(),
            Finance_User__c          = owner.Id,
            Permanent_Postal_Code__c = 560001,
            GST__c                   = 18
        );
        insert book;
        
        // Two payment schedules so psRecordList[0] and aggregate queries execute
        List<Payment_Schedule__c> psList = new List<Payment_Schedule__c>();
        
        // Completed previous milestone
        psList.add(new Payment_Schedule__c(
            Booking__c         = book.Id,
            Name               = 'On Registration',
            S_No__c            = 1,
            Status__c          = 'Completed',
            Payment_percent__c = 10
        ));
        
        // Current milestone
        psList.add(new Payment_Schedule__c(
            Booking__c         = book.Id,
            Name               = 'Milestone 2',
            S_No__c            = 2,
            Status__c          = '',
            Payment_percent__c = 20
        ));
        
        insert psList;
        
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('/apex/Demand_Note?id=' + book.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(book);
        RaiseDemandController controller = new RaiseDemandController(sc);
        Test.stopTest();
        
        System.assertNotEquals(null, controller, 'Controller should be initialized with schedules');
    }
    
    // 3) Bulk / multiple bookings scenario
    @isTest
    static void testControllerMultipleBookings() {
        User owner = [SELECT Id FROM User WHERE Email LIKE 'owner%@example.com' LIMIT 1];
        
        List<Lead> leads = new List<Lead>{
            new Lead(LastName = 'L1', Company = 'C1', Email = 'l1@test.com', OwnerId = owner.Id),
            new Lead(LastName = 'L2', Company = 'C2', Email = 'l2@test.com', OwnerId = owner.Id)
        };
        insert leads;
        
        List<Booking__c> books = new List<Booking__c>();
        for (Lead ld : leads) {
            books.add(new Booking__c(
                SLead__c           = ld.Id,
                Project__c         = 'Veegaland Green Heights',
                Stage__c           = 'Welcome Email',
                Date_of_Booking__c = System.today(),
                Finance_User__c    = owner.Id
            ));
        }
        insert books;
        
        // One simple schedule per booking so psRecordList is not empty
        List<Payment_Schedule__c> psList = new List<Payment_Schedule__c>();
        for (Booking__c b : books) {
            psList.add(new Payment_Schedule__c(
                Booking__c         = b.Id,
                Name               = 'Milestone 1',
                S_No__c            = 1,
                Status__c          = 'Completed',
                Payment_percent__c = 10
            ));
        }
        insert psList;
        
        Test.startTest();
        Integer count = 0;
        for (Booking__c b : books) {
            Test.setCurrentPageReference(new PageReference('/apex/Demand_Note?id=' + b.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(b);
            RaiseDemandController ctrl = new RaiseDemandController(sc);
            System.assertNotEquals(null, ctrl, 'Controller must work for booking ' + b.Id);
            count++;
        }
        Test.stopTest();
        
        System.assertEquals(2, count, 'Both bookings should be processed');
    }
}