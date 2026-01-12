public class AdvanceReceiptController {
    public Booking__c  booking { get; set; }
    //public Decimal amountofAdvanceReceived { get; set; }
   // public Decimal landCost { get; set; }
   // public Decimal taxableValue { get; set; } 
   // public Decimal sgst { get; set; } 
   // public Decimal cgst { get; set; } 
    public List<Receipt_Line_Item__c> receiptLineItem { get; set; }
   // public String getFormattedAmountOfAdvanceReceived {get; set;}
   // public String formattedLandCost {get; set;}
    //public String formattedTaxableValue {get; set;}
   // public String formattedSgst {get; set;}
   // public String formattedCgst {get; set;}
   // public String formattedTotal {get; set;} 
   // public String formattedAmountofAdvanceReceived {get; set;}
    //public String formattedPostalCode {get; set;}
    public String amountInWords {get; set;}
    
    
    
    public AdvanceReceiptController(ApexPages.StandardController stdController) {
        Id bookingId = stdController.getId();
        booking = [SELECT Id, Sub_Total__c, GST_Amount__c, Total__c,Plot__r.Super_built_up_area__c,Plot__r.BHK_Type__c, Desom__c,/*Village_Panchayath__c,*/District__c,/*Taluk__c,*/
                   Plot__r.Floor__c,Booking_Advance_Amount_Received__c,
                   Plot__r.Name,Carpet_Area__c,Age__c,First_Applicant_Name__c,
                   Second_Applicant_Name__c,salutation_Applicant1__c,
                   Permanent_Postal_Code__c,Covered_Park_Parking__c
                   FROM Booking__c 
                   WHERE Id = :bookingId];
        receiptLineItem = [
         SELECT Name, Amount__c,Payment_schedule__c,Cheque_no_Transaction_Number__c,Mode_of_Payment__c,Bank_Name__c,Payment_Type__c,Receipt__r.Name,Receipt__r.Receipt_date__c,Receipt__r.Instrument_N__c,Receipt__r.Mode_of_payment__c,Receipt__r.Payment_Received_Bank__c, Receipt__r.Branch__c
          FROM Receipt_Line_Item__c
         WHERE Booking__c = :bookingId AND S_No__c = 1 AND Receipt__r.Approval_status__c = 'Approved by Finance Team'
        
         ];
        system.debug(receiptLineItem);
        
       /* amountofAdvanceReceived = ((booking.Booking_Advance_Amount_Received__c)/1.05);
        formattedAmountofAdvanceReceived = (booking.Booking_Advance_Amount_Received__c).setScale(0, RoundingMode.HALF_UP).format();
        landCost = amountofAdvanceReceived/3;
        taxableValue = 2*landCost;
        sgst = ((2*amountofAdvanceReceived)/3)*0.0375;
        cgst = ((2*amountofAdvanceReceived)/3)*0.0375;
        system.debug(taxableValue);
        
        getFormattedAmountOfAdvanceReceived = amountofAdvanceReceived.setScale(2, RoundingMode.HALF_UP).format();
        formattedLandCost = landCost.setScale(2, RoundingMode.HALF_UP).format();
        formattedTaxableValue = taxableValue.setScale(2, RoundingMode.HALF_UP).format();
        formattedSgst = sgst.setScale(2, RoundingMode.HALF_UP).format();
        formattedCgst = cgst.setScale(2, RoundingMode.HALF_UP).format();
       
        
        
        
        // Final total (before rounding)
        Decimal total = landCost + taxableValue + sgst + cgst;
        formattedTotal = total.setScale(0, RoundingMode.HALF_UP).format();
        // converting Total Amount Received  into words
        totoalAmountInWords = (booking.Booking_Advance_Amount_Received__c !=null)? convertNumberToWords(booking.Booking_Advance_Amount_Received__c)+' Only':'Zero';*/
        
         NumberTOWordConvertion n = new  NumberTOWordConvertion();
       amountInWords = n.getNumberTOWordConvertion(booking.Booking_Advance_Amount_Received__c);
        
        
        
       // if (booking.Permanent_Postal_Code__c != null) {
          //  formattedPostalCode = String.valueOf(booking.Permanent_Postal_Code__c.intValue());
       // }
        
        
        
        
    }
    
   
    
    
}