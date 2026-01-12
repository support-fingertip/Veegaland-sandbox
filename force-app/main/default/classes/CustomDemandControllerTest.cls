@isTest
public class CustomDemandControllerTest {
    @isTest
    
    public static void customDemand(){
        
        // creating Booking
        Booking__c bk =  new Booking__c();
        insert bk;
        
        //Creating project
         Project__c project = new  Project__c();
        project.Name = 'Veegaland Green Heights';
        project.Project_Type__c='Apartments';
       // project.Finance_User__c = owner.Id;
        //project.CRM_Manager__c =  owner.Id;
       // project.Legal_User__c = owner.Id;
       // project.Legal_User2__c = owner.Id;
        insert project;
        
        //Creating master payment schedule
         Master_payment_schedule__c mpy = new Master_payment_schedule__c ();
        mpy.S_No__c = 2;
        mpy.Payment_Percent__c = 50;
        mpy.Status__c = 'Completed';
        mpy.Project__c = project.id;
        //mpy.Payment_Plan__c = payplan.Id;
        insert mpy;
        
        
        //Creating payment schedule record
        Payment_schedule__c pys = new Payment_schedule__c();
        pys.Payment_Percent__c=10;
        pys.Payment_Due_Date__c = system.today()+3;
        pys.Booking__c = bk.id;
        pys.Master_Payment_Schedule__c = mpy .Id;
        pys.name ='on booking';
        pys.Interest_Percent__c=25;
        insert pys;
        
        //Creating documents
        List<Id> idList = new List<Id>();
         ContentVersion cv = new ContentVersion(
            Title = 'TestFile',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Test file content')
           // ExternalDocumentInfo1 = acc.Id, 
            //ExternalDocumentInfo2 = 'FromApp' 
        );
        
        insert cv;
        idList.add(cv.Id);
        
        
        
        CustomDemandController.getPaymentSchedules(bk.Id);
        CustomDemandController.raiseDemand(pys.Id, idList);
        CustomDemandController.villaScheduleCalculations(pys.Id, bk, 'Test Content', idList);
        
    }

}