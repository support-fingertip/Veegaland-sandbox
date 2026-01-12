@isTest
public class Cost_SheetControllerTest {
    @isTest
    public static void costSheet(){
        
        //Creating project record
        Project__c project = new  Project__c();
        project.Name = 'Veegaland Green Heights';
       
        insert project;
        
        // creating plot record
        Plot__c plot = new Plot__c(
        Floor__c = '2',
        Project__c = project.Id);
         insert plot;
        
        // create booking record
        Booking__c bk = new Booking__c(
            Plot__c = plot.Id,
       // FloorNo__c = 2,
            Other_Charges__c =3000,
            Floor_Rise_Charges_Rate__c =30,
            Premium_Charge__c = 500000,
            Price_per_sqft__c = 3000
        );
            insert bk;
        
        ApexPages.StandardController controller =  new ApexPages.StandardController(bk);
        Cost_SheetController co = new Cost_SheetController(controller);
        co.convertToWords(20);
    }

}