public class Demand_Note_SendController {
    
    public String  formattedCurrentDate {get; set;}
    public Demand_Raised__c demand {get; set;}
    public String formattedPin {Get; set;}
    public Decimal valueOfSupply { get; set; }
    public Decimal landCost { get; set; }
    public Decimal taxableValue { get; set; }
    public Decimal cgst { get; set; }
    public Decimal sgst { get; set; }
    //public Decimal total { get; set; }
    
    public Demand_Note_SendController(ApexPages.StandardController stdcontroller){
        
        
        valueOfSupply = 0;
        landCost = 0;
        taxableValue = 0;
        cgst = 0;
        sgst = 0;
        Id demandNoteId = ApexPages.currentPage().getParameters().get('Id');
        
        DateTime dt = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        formattedCurrentDate = dt.format('MMM dd, yyyy');
        
        demand = [Select Id, Booking__r.Permanent_Postal_Code__c,Current_Demand_Amount_In_Words__c, Current_Demand_amount__c, Total_Amount_Without_Interest__c,Intrest_Amount__c From Demand_Raised__c Where Id =: demandNoteId];
        
        //Formatting postal code
        if(demand.Booking__r.Permanent_Postal_Code__c !=null)
        {
            formattedPin = String.valueOf((Integer)demand.Booking__r.Permanent_Postal_Code__c);
        }
        
        Decimal totalAmountWithoutInterest = demand.Current_Demand_amount__c;
        if (totalAmountWithoutInterest != null && totalAmountWithoutInterest > 0) {
            valueOfSupply = (totalAmountWithoutInterest / 1.05).setScale(1); // Value before tax
            landCost = (valueOfSupply / 3).setScale(1);
            taxableValue = (valueOfSupply * 2 / 3).setScale(1);
            cgst = (taxableValue * 0.0375).setScale(1);
            sgst = (taxableValue * 0.0375).setScale(1);
        }
        
        
        
    }
    
}