public class RefundVFPController {
   public Refund__c receipt { get; set; }
    public Id receiptId { get; set; }

    // From VeegalandReceiptController
    public List<Co_Applicant__c> coApplicants { get; set; }
    public String amountInWords { get; set; }
    public String formattedAmount { get; set; }
    public String formattedReceiptdate { get; set; }

    // From ReceiptVFPController
    public Decimal amountofAdvanceReceived { get; set; }
    public Decimal landCost { get; set; }
    public Decimal taxableValue { get; set; } 
    public Decimal sgst { get; set; } 
    public Decimal cgst { get; set; } 
    public String getFormattedAmountOfAdvanceReceived { get; set; }
    public String formattedLandCost { get; set; }
    public String formattedTaxableValue { get; set; }
    public String formattedSgst { get; set; }
    public String formattedCgst { get; set; }
    public String formattedTotal { get; set; } 
    public String formattedAmountofAdvanceReceived { get; set; }
    public String formattedPostalCode { get; set; }
    public String totalAmountInWords { get; set; }

    public RefundVFPController (ApexPages.StandardController stdController) {
        receiptId = stdController.getId();

        receipt = [
            SELECT Id, Bank_Name__c,Total_GST_Amount__c,Total_Base_Value__c,Receipt_Number__c,Total_Refund_Amount__c,Transaction_Number__c,Name,Refund_Date__c,Voucher_No__c,
                Booking__r.Permanent_State__c, Booking__r.Permanent_City__c, Booking__r.Permanent_Post_Office__c, Booking__r.Permanent_Street_Location__c,
                Booking__r.Permanent_House_No_Name__c, Booking__r.First_Applicant_Name__c, Booking__r.PAN_Number1__c, Booking__r.salutation_Applicant1__c,
                Booking__r.Plot__r.Name, Booking__r.Plot__r.Unit_Number__c, Booking__r.Plot__r.Apartment_area__c, Booking__r.Plot__r.Floor__c, Booking__r.Plot__r.Carpet_Area__c,
                Booking__r.Plot__r.Unit_Common_Type__c, Booking__r.Project__c, Booking__r.GSTIN__c, Booking__r.Permanent_Postal_Code__c
            FROM Refund__c 
            WHERE Id = :receiptId
        ];

        // Get Co-applicants (VeegalandReceiptController)
        coApplicants = [
            SELECT Id, Name, PAN_Number__c
            FROM Co_Applicant__c
            WHERE Booking__c = :receipt.Booking__r.Id
        ];

        // Formatting
        formattedAmount = receipt.Total_Refund_Amount__c != null ? receipt.Total_Refund_Amount__c.format() : '';
        amountInWords = receipt.Total_Refund_Amount__c != null ? convertNumberToWords(receipt.Total_Refund_Amount__c) + ' only' : 'Zero';

        if (receipt.Refund_Date__c != null) {
            Date receiptdate = receipt.Refund_Date__c;
            Datetime receiptDatetime = Datetime.newInstance(receiptdate.year(), receiptdate.month(), receiptdate.day());
            formattedReceiptdate = receiptDatetime.format('MMM dd, yyyy');
        }

        // Calculations (ReceiptVFPController)
        if (receipt.Total_Refund_Amount__c != null) {
            amountofAdvanceReceived = (receipt.Total_Refund_Amount__c) / 1.05;
            formattedAmountofAdvanceReceived = receipt.Total_Refund_Amount__c.setScale(0, RoundingMode.HALF_UP).format();
       
            landCost = amountofAdvanceReceived / 3;
            taxableValue = 2 * landCost;
            sgst = ((2 * amountofAdvanceReceived) / 3) * 0.0375;
            cgst = ((2 * amountofAdvanceReceived) / 3) * 0.0375;

            getFormattedAmountOfAdvanceReceived = amountofAdvanceReceived.setScale(2, RoundingMode.HALF_UP).format();
            formattedLandCost = landCost.setScale(2, RoundingMode.HALF_UP).format();
            formattedTaxableValue = taxableValue.setScale(2, RoundingMode.HALF_UP).format();
            formattedSgst = sgst.setScale(2, RoundingMode.HALF_UP).format();
            formattedCgst = cgst.setScale(2, RoundingMode.HALF_UP).format();

            Decimal total = landCost + taxableValue + sgst + cgst;
            formattedTotal = total.setScale(0, RoundingMode.HALF_UP).format();

            totalAmountInWords = convertNumberToWords(receipt.Total_Refund_Amount__c) + ' Only';
        }

        if (receipt.Booking__r.Permanent_Postal_Code__c != null) {
            formattedPostalCode = String.valueOf(receipt.Booking__r.Permanent_Postal_Code__c.intValue());
        }
    }

    // Common number-to-words converter method (shared logic)
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