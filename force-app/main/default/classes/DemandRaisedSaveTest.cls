@isTest
public class DemandRaisedSaveTest {
    @isTest
    public static void demandRaised(){
        
        
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
        unit.BHK_Type__c = '3 BHK';
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
        book.Funding_Type__c = 'Own Funds';
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
        bookIds.add(book.Id);
        
        // Prepare a ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'Demand Note-',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Test file content'),
            // ExternalDocumentInfo1 = acc.Id, 
            ExternalDocumentInfo2 = 'FromApp' 
        );
        
        insert cv;
        
        Id cvId = [SELECT Id FROM ContentVersion WHERE Id = :cv.Id].Id;
        
        
        //creating master payment schedule
        Master_payment_schedule__c mpy = new Master_payment_schedule__c ();
        mpy.S_No__c = 1;
        mpy.Status__c = 'Completed';
        mpy.Project__c = project.id;
        mpy.Payment_Plan__c = payplan.Id;
        mpy.Payment_Percent__c = 25;
        //mpy.Amount__c =15000;
        insert mpy;
        
        
        
        // creating payment schedule
        Payment_schedule__c pys = new Payment_schedule__c();
        pys.Payment_Percent__c=10;
        pys.S_No__c = 1;
        pys.Payment_Due_Date__c = system.today()+3;
        pys.Booking__c = book.id;
        pys.Master_Payment_Schedule__c = mpy .Id;
        pys.name ='on booking';
        pys.Interest_Percent__c=25;
        pys.status__c = 'Completed';
        //mpy.Amount__c =1000;
       
        insert pys;
        
         Master_payment_schedule__c mpy1 = new Master_payment_schedule__c ();
        mpy1.S_No__c = 2;
        mpy1.Status__c = 'Completed';
        mpy1.Project__c = project.id;
        mpy1.Payment_Plan__c = payplan.Id;
        mpy1.Payment_Percent__c = 25;
        //mpy.Amount__c =15000;
        insert mpy1;
        
         Payment_schedule__c pys1 = new Payment_schedule__c();
        pys1.Payment_Percent__c=10;
        pys1.S_No__c = 2;
        pys1.Payment_Due_Date__c = system.today()+3;
        pys1.Booking__c = book.id;
        pys1.Master_Payment_Schedule__c = mpy1.Id;
        pys1.name ='on booking';
        pys1.Interest_Percent__c=25;
        //pys1.Amount__c =5000;
         pys1.status__c = 'Completed';
        
        insert pys1;
        
        
        
        List<Id> idList = new List<Id>();
        List<Id> idList2 = new List<Id>();
        // create demand raise
        Demand_Raised__c demand = new Demand_Raised__c(
            Booking__c = book.Id,
            Demand_Content_Ids__c = cvId,
            Payment_Schedule__c = pys.Id,
            Demanded_Date__c = Date.Today(),
            Demand_Email_Content__c = 'Test'
            
        );
        insert demand;
        idList.add(demand.Id);
        
        Map<Id, String> bookMap = new Map<Id, String> ();
        bookMap.put(book.Id, 'test content');
        
        List<String> strList = new List<String>();
        strList.add(cv.Id);
        
        map<Id,List<String>> conIdMap = new map<Id,List<String>>();
        conIdMap.put(book.Id, strList);
           
                    
                  
                        
                        
 /*       // Add required Maps and values
Map<Id, Decimal> bookingToReceivedAmountMap = new Map<Id, Decimal>{ book.Id => 500000 };
Map<Id, Decimal> debitAmountMap = new Map<Id, Decimal>{ book.Id => 50000 };
Map<Id, Decimal> bookingToThisMSAmountMap = new Map<Id, Decimal>{ book.Id => 100000 };
Map<Id, Decimal> WaveOffMap = new Map<Id, Decimal>{ book.Id => 10000 };

Map<Id, String> emailContents = new Map<Id, String>{ book.Id => 'Demand Email Body' };
//Map<Id, List<String>> contentIds = new Map<Id, List<String>>{ book.Id => new List<String>{'069xxxxxxxxxxxx'} };
Map<Id, Id> bookingtopayment = new Map<Id, Id>{ book.Id => 'a07xxxxxxxxxxxx' }; */

// Mock AggregateResult
/*AggregateResult ag = (AggregateResult) new AggregateResultMock(new Map<String, Object>{
    'totalPendingAmount' => 50000,
    'totalInterestAmount' => 5000,
    'totalPayableAmount' => 600000,
    'totalInterestUplodate' => 10000,
    'totalInterestPaid' => 3000,
    'paymentPercentageTill' => 20
});   
*/
                        
                        
       DemandRaisedSave.getDemandRaised(demand.Id);
       DemandRaisedSave.ResendRaiseDemand(idList);
       
     // DemandRaisedSave.bulkScheduleCalculations(bookList, bookMap, conIdMap);
       DemandRaisedSave.RaiseDemand(bookIds, bookMap, conIdMap);
       
       
        DemandRaisedSave.getBookingRecord(book.Id);
      
	DemandRaisedSave.getMilestoneLabel(1);
        
        
        
       // DemandRaisedSave.bulkApartmentScheduleCalculations(bookList, bookMap, contentIds);
       
    }
    
}