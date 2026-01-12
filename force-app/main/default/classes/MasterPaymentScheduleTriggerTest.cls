@isTest
public class MasterPaymentScheduleTriggerTest {
    @isTest
    public static void MasterPaymentSchedule() {
        // Create User (Owner)
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
            Availability__c = true
        );
        insert owner;

        // Create Project
        Project__c project = new Project__c(
            Name = 'Veegaland Green Heights',
            Project_Type__c = 'Apartments',
            Project__c = 'Veegaland Green Heights'
        );
        insert project;

        // Create Booking
        Booking__c book = new Booking__c(
            Followup_Date__c = system.today(),
            Followup_Subject__c = 'test22',
            Last_Comment__c = 'test22',
            Project__c = 'Veegaland Green Heights',
            Payment_Type__c = 'Custom',
            Sale_Agreement_Completed__c = false,
            Agreement_Amount_Cleared__c = 'Received Partial Amount',
            Stage__c = 'Welcome Email',
            Demand_Number__c = '12345',
            Project1__c = project.Id,
            Date_of_Booking__c = System.today(),
            Mode_Of_Payment__c = 'Credit Card',
            Funding_Type__c = 'Own Funds',
            Loan_Sanction_Confirmed__c = true,
            Loan_Sanctioned_Amount__c = 10000,
            Sales_Manager1__c = owner.Id,
            Sales_Executive__c = owner.Id,
            Finance_User__c = owner.Id,
            Email1__c = 'Test@gmail.com',
            OwnerId = owner.Id
        );
        insert book;

        // Create Master Payment Schedule 
        Master_Payment_Schedule__c mps = new Master_Payment_Schedule__c(
            S_No__c = 2,
            Payment_Percent__c = 50,
            Project__c = project.Id,
            Status__c = 'In Progress',
            Due_Date__c = System.today().addDays(3),
            
            Include_Interest__c = false
        );
        insert mps;
       
        


        // Create Payment Schedule 
        Payment_Schedule__c ps = new Payment_Schedule__c(
            Payment_Percent__c = 10,
            Payment_Due_Date__c = System.today().addDays(3),
            Booking__c = book.Id,
            Master_Payment_Schedule__c = mps.Id,
            Name = 'On Booking',
            Interest_Percent__c = 25,
            Is_Demanded__c = true
            
        );
        insert ps;
        
          //Requery to get formula fields populated
mps = [SELECT Id, Project_Name__c, Status__c, Include_Interest__c FROM Master_Payment_Schedule__c WHERE Id = :mps.Id];
        mps.Status__c = 'Completed';
        update mps;
        
        
        // Update Master Payment Schedule to trigger logic
        mps.Status__c = 'Completed'; // change triggers notification logic
        mps.Include_Interest__c = true; // change triggers interest update logic
        update mps;

        // Optional: Assert to confirm trigger behavior (coverage + validation)
        List<Payment_Schedule__c> updatedSchedules = [
            SELECT Id, Status__c, Include_Interest__c
            FROM Payment_Schedule__c
            WHERE Id = :ps.Id
        ];
        
    }
}