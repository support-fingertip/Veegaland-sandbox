@isTest
public class CarparkingSelectionControllerTest {
    @isTest
    public static void carParking(){
        
        // creating project record
        Project__c pjt = new Project__c();
        pjt.Name = 'Veegaland Elanza';
        pjt.Active__c = true;
        insert pjt;
        
        // create booking record
        Booking__c bk = new Booking__c(
            Project1__c = pjt.Id,
            No_of_Back_to_Back_Car_Parking__c = 4,
            No_of_Indivisual_Car_Parking__c = 2,
            Selected_B2B_Parking_Slots__c = 1
            
        );
        insert bk;
        
        
        
        // creating record for Parking_Floor__c
        Parking_Floor__c pf = new Parking_Floor__c(
            name = 'test floor',
        Project__c = pjt.Id
        );
        insert pf;
        
        List<Id> plist = new List<Id>();
        //Creating parking record
        Parking__c p = new Parking__c(
        Name = 'test',
            Parking_Floor__c = pf.Id,
            Parking_Type__c = 'Individual',
            Status__c = 'Available'
            
        );
        insert p;
        plist.add(p.Id);
        
         // Set the page parameter for the constructor
        Test.setCurrentPageReference(new PageReference('/apex/DummyPage'));
        ApexPages.currentPage().getParameters().put('Id', bk.Id);
        
       // ApexPages.StandardController controller = new ApexPages.StandardController(bk);
        CarparkingSelectionController c = new CarparkingSelectionController();
        
       CarparkingSelectionController.saveSelectedSlots(bk.Id, '', plist, '', 2, 3);
        
        
        
    }
    
}