@isTest
public class AdvanceReceiptQuoteControllerTest {
    @isTest
    public static void quote(){

       Project__c pjt = new Project__c();
        pjt.Name = 'Veegaland Elanza';
        pjt.Active__c = true;
        insert pjt; 
       
       Plot__c ut = new Plot__c();
        ut.Name='New';
        ut.Project__c=pjt.id;
        ut.Status__c='Available';
        insert ut;
       
       
       
       Payment_Plan__c pp = new Payment_Plan__c();
       pp.Name = 'test';
       pp.Project__c = pjt.id;
       insert pp;
       
       Master_Payment_Schedule__c mv = new Master_Payment_Schedule__c();
       mv.Name = 'test';
       mv.Payment_Plan__c= pp.id;
       mv.Payment_Percent__c = 0.1;
       mv.Completed_Date__c = system.today();
       mv.Completed__c = true;
       insert mv;
           
       Quote__c Qt = new Quote__c();
        Qt.Approval_status__c = 'Approved';
        Qt.Discount_In_Rupees__c = 100;
        Qt.Quote_status__c = 'Available';
       Qt.Payment_Plan__c = pp.id;
        Qt.Unit__c = ut.id;
       QT.Floor_Rise_Charges__c=9889;
       Qt.Built_up_area__c=111;
       Qt.Car_Parking_Charge__c=79889;
       Qt.Extra_car_parking_charges__c=09888;
       Qt.Project__c = 'Veegaland Elanza';
       QT.Landscape_Charge__c =989;
       QT.Open_Terrace_Area_Charges__c=444;
        Qt.Advance_Amount_Received__c = 5000;
     //  QT.Apartment_Cost_Including_Car_Parking__c =9889;
        insert Qt;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(Qt);
        AdvanceReceiptQuoteController con = new AdvanceReceiptQuoteController(stdController);
       
    }

}