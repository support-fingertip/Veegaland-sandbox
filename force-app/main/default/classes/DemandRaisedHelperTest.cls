@isTest
public class DemandRaisedHelperTest {
    @isTest
    
    public static void demandRaise(){
        //create booking
        Booking__c book = new Booking__c(
            Email1__c = 'test@gmail.com'
        );
        insert book;
        
        // Prepare a ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'Demand Note-',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Test file content'),
           // ExternalDocumentInfo1 = acc.Id, 
            ExternalDocumentInfo2 = 'FromApp' 
        );
        
        insert cv;
        
        //creating master payment schedule
         Master_payment_schedule__c mpy = new Master_payment_schedule__c ();
        mpy.S_No__c = 1;
        mpy.Status__c = 'Completed';
        //mpy.Project__c = project.id;
        //mpy.Payment_Plan__c = payplan.Id;
        mpy.Payment_Percent__c = 25;
        insert mpy;
        
        
        // creating payment schedule
        Payment_schedule__c pys = new Payment_schedule__c();
        pys.Payment_Percent__c=10;
        pys.Payment_Due_Date__c = system.today()+3;
        pys.Booking__c = book.id;
        pys.Master_Payment_Schedule__c = mpy .Id;
        pys.name ='on booking';
        pys.Interest_Percent__c=25;
        insert pys;
        
        Id cvId = [SELECT Id FROM ContentVersion WHERE Id = :cv.Id].Id;
        
        List<Id> idList = new List<Id>();
        // create demand raise
        Demand_Raised__c demand = new Demand_Raised__c(
            Booking__c = book.Id,
            Demand_Content_Ids__c = cvId,
            Demand_Email_Content__c='Hello Test',
            Payment_Schedule__c = pys.Id,
            Demanded_Date__c = Date.Today()
            	
        );
        insert demand;
        idList.add(demand.Id);
        
        
        
        
        DemandRaisedHelper.updatePaymentScheduleFields(idList);
        DemandRaisedHelper.sendDemandEmailToCustomer(idList);
    }
    
    
}