public class PrintAllReceiptController {
    public Id bookingId {get; set;}
    public Booking__c booking {get; set;}
    public List<Receipt__c> receipt {get; set;}
    public Decimal totalAmount {get; set;}
    public String formattedTotal {get; set;}
    public String AmountInWords {get; set;}
    public PrintAllReceiptController(ApexPages.StandardController stdController){
        bookingId = stdController.getId();
        
        booking = [Select Id,salutation_Applicant1__c,First_Applicant_Name__c,Permanent_House_No_Name__c, Permanent_Street_Location__c, Permanent_Post_Office__c,Permanent_City__c, Permanent_State__c,
                  PAN_Number1__c,Project1__c, Plot__r.Unit_Common_Type__c,Plot__r.Floor__c,Plot__r.Apartment_area__c from Booking__c where id =:bookingId];
        
        receipt = [Select Id, Name,	Receipt_date__c, Instrument_N__c, Mode_of_payment__c, Branch__c, Total_Received_Amount__c, Payment_Received_Bank__c From Receipt__c Where Booking__c =:bookingId AND Approval_status__c = 'Approved by Finance Team'  Order by CreatedDate DESC];
        
        AggregateResult result = [Select SUM(Total_Received_Amount__c) amountTotal From Receipt__c Where Booking__c =:bookingId AND Approval_status__c = 'Approved by Finance Team' ];
        totalAmount = (Decimal) result.get('amountTotal');
         formattedTotal = totalAmount.setScale(0).format();
        if(formattedTotal!=null){
            NumberTOWordConvertion n = new NumberTOWordConvertion();
            
            AmountInWords = n.getNumberTOWordConvertion(totalAmount);
        }
        
        
    }
    
    /* public static String convertNumberToWords(Decimal numb) {
        if (numb == null) return 'Zero';

        Long num = numb.longValue();
        if (num == 0) return 'Zero';

        return convert(num);
    }
@TestVisible
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
        
    }   */

}