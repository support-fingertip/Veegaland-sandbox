public class VeegalandReceiptController {
    public Receipt__c receipt {get; set;}
    public Id receiptId {get; set;}
    public list<Co_Applicant__c> coApplicants {get; set;}
    public String amountInWords {get; set;}
    public String formattedAmount {get; set;}
    public string formattedReceiptdate {get; set;}
    
    public VeegalandReceiptController(ApexPages.StandardController stdController) {
        receiptId = (Id)stdController.getId();
        
        receipt = [Select Id, Name, Receipt_date__c, Booking__r.salutation_Applicant1__c, Booking__r.First_Applicant_Name__c,Booking__r.Permanent_House_No_Name__c, Instrument_N__c,Mode_of_payment__c,Payment_Received_Bank__c,
                   Booking__r.Permanent_Street_Location__c, Booking__r.Permanent_Post_Office__c, Booking__r.Permanent_City__c,Booking__r.Plot__r.Unit_Number__c,Booking__r.Permanent_State__c,Branch__c,Booking__r.Plot__r.Apartment_area__c,
                   Booking__r.Plot__r.Floor__c,Booking__r.Plot__r.Carpet_Area__c, Total_Received_Amount__c, Project_Name__c, Booking__r.Plot__r.Unit_Common_Type__c, Booking__r.Plot__r.Name, Booking__r.PAN_Number1__c
                   FROM Receipt__c
                   WHERE Id=:receiptId];
        
        list<Co_Applicant__c> coApplicants = [SELECT Id, Name, PAN_Number__c 
                                              FROM Co_Applicant__c 
                                              WHERE Booking__c = :receipt.Booking__r.Id ];
        
        
        formattedAmount = receipt.Total_Received_Amount__c.format();
        amountInWords = (receipt.Total_Received_Amount__c!=Null)?convertNumberToWords(receipt.Total_Received_Amount__c)+' only': 'Zero';
        
        if (receipt.Receipt_date__c != null) {
            Date receiptdate = receipt.Receipt_date__c;
            // Convert Date to Datetime
            Datetime receiptDatetime = Datetime.newInstance(receiptdate.year(), receiptdate.month(), receiptdate.day());
            // Format it properly
            formattedReceiptdate = receiptDatetime.format('MMM dd, yyyy');
        }
    }
    
    
    public static String convertNumberToWords(Decimal numb) {
        if (numb == null) return 'Zero';
        
        Long num = numb.longValue();
        if (num == 0) return 'Zero';
        
        return convert(num);
    }
    
    private static String convert(Long num) {
        List<String> ONES = new List<String>{
            '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten',
                'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'
                };
                    
                    List<String> TENS = new List<String>{
                        '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
                            };
                                
                                if (num < 20) {
                                    return ONES[num.intValue()];
                                } else if (num < 100) {
                                    Integer tensPlace = num.intValue() / 10;
                                    Integer onesPlace = Math.mod(num.intValue(), 10);
                                    return TENS[tensPlace] + (onesPlace != 0 ? ' ' + ONES[onesPlace] : '');
                                } else if (num < 1000) {
                                    return ONES[num.intValue() / 100] + ' Hundred' + (Math.mod(num, 100) != 0 ? ' ' + convert(Math.mod(num, 100)) : '');
                                } else if (num < 100000) {
                                    return convert(num / 1000) + ' Thousand' + (Math.mod(num, 1000) != 0 ? ' ' + convert(Math.mod(num, 1000)) : '');
                                } else if (num < 10000000) {
                                    return convert(num / 100000) + ' Lakh' + (Math.mod(num, 100000) != 0 ? ' ' + convert(Math.mod(num, 100000)) : '');
                                } else {
                                    return convert(num / 10000000) + ' Crore' + (Math.mod(num, 10000000) != 0 ? ' ' + convert(Math.mod(num, 10000000)) : '');
                                }
        
    }
    
    
    
}