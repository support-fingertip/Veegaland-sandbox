public class AllotmentLetterController {
    public Booking__c booking { get; set; }
    public list<Payment_schedule__c> paymentSchedule { get; set; }
    public String getFloorWithSuffix { get; set; }
    public String carpetAreaSqft { get; set; }
    public Decimal totalAmount { get; set; }
    public Decimal totalPercent  { get; set; }
    public String totalAmountInWords { get; set; }	
    public String bookingAdvanceAmountInWords { get; set; }
    public Decimal primaryPostalcode { get; set; }
    public String formattedTotalAmount { get; set; }	
    public String formattedBookingAmount { get; set; }
    public integer NoCarParkingIndividual  { get; set; }
    public integer NoCarParkingBackToBack  { get; set; }
    public String formattedNoofParking { get; set; }
    public String formattedNoofParkingArea { get; set; }
    public String formattedNoofParkingDimension { get; set; }
    public String resourceName { get; set; }
    
    public AllotmentLetterController(ApexPages.StandardController stdController) {
        Id bookingId = stdController.getId();
        booking = [SELECT Id, Sub_Total__c, GST_Amount__c, Total__c,Plot__r.Apartment_No__c, Desom__c,/*Village_Panchayath__c,*/District__c,/*Taluk__c,*/Project1__r.Enable_Allotment_Letter_Due_Date__c,
                   Plot__r.Floor__c, Plot__r.BHK_Type__c, Plot__r.Undivided_Share_of_Land__c, Plot__r.Block__c,Primary_Applicant_Relationship_Type__c,Booking_Advance_Amount_Received__c,No_of_additional_Back_to_back_car_parki__c,Individual_Car_Parking_Area__c,Back_To_Back_Car_Parking_Area__c,
                   Plot__r.Super_built_up_area__c,Permanent_Post_Office__c,Plot__r.Name,Carpet_Area__c,Age__c, Maintenance_Deposite__c,First_Applicant_Name__c,Association_Deposit__c,Plot__r.Carpet_Area__c,No_of_additional_Individual_car_parkings__c,No_of_Indivisual_Car_Parking__c,Individual_Car_Parking_Dimension__c,Back_To_Back_Car_Parking_Dimension__c,
                   Second_Applicant_Name__c,Age2__c,Authorized_Signatory_Father_Husband_Name__c,Date_of_birth_Applicant2__c,salutation_Applicant1__c,Project1__r.RERA_NO__c,Project1__r.Bank_Name__c,Project1__r.Beneficiary_Account_No__c,Project1__r.Branch_Name__c,Project1__r.IFSC_CODE__c,No_of_Back_to_Back_Car_Parking__c,
                   Permanent_Postal_Code__c,FloorNo__c,Sale_Agreement_Date__c,Unit_UDS_Area__c,Plot__r.UDS_Percentage__c,Signatory_Permanent_Postal_Code__c,Handing_over__c,Covered_Park_Parking__c,Total_Corpus_fund__c,Allotment_Date__c,Project1__r.Name,
                   (select Id ,Name,Permanent_House_No_Name__c,Permanent_Street_Location__c,Permanent_City__c,Permanent_Postal_Code__c,Permanent_State__c,Permanent_Post_Office__c,Salutation__c from Co_Applicant__r)
                   FROM Booking__c 
                   WHERE Id = :bookingId];
        resourceName = booking.Project1__r.Name.replaceAll(' ', '_'); 
        paymentSchedule = [SELECT S_No__c,Name,Payment_Due_Date__c,Payment_percent__c,Completed_Date__c,AmountB__c,CGST_Amount__c, SGST_Amount__c, Total_Amount__c, Amount_Excluding_Taxes__c FROM Payment_schedule__c WHERE Booking__c = :bookingId order by S_No__c asc]; 
        AggregateResult agr= [SELECT sum(AmountB__c) inclusiveTax, Sum(Payment_percent__c) percent  FROM Payment_schedule__c WHERE Booking__c = :bookingId ];
        totalAmount = (Decimal)agr.get('inclusiveTax');
        
        formattedTotalAmount = booking.Total__c.format();
        formattedBookingAmount = (paymentSchedule[0].Total_Amount__c !=null ?paymentSchedule[0].Total_Amount__c.setscale(0) :0).format();
        
        totalPercent = (Decimal)agr.get('percent');
        if (booking.Permanent_Postal_Code__c != null) {
            primaryPostalcode = Math.floor(booking.Permanent_Postal_Code__c); 
        }
        if(booking.No_of_Indivisual_Car_Parking__c !=null && booking.No_of_Indivisual_Car_Parking__c !=0){
            NoCarParkingIndividual = integer.valueof(booking.No_of_Indivisual_Car_Parking__c); 
        }
        if(booking.No_of_Back_to_Back_Car_Parking__c !=null && booking.No_of_Back_to_Back_Car_Parking__c !=0){
            NoCarParkingBackToBack = integer.valueof(booking.No_of_Back_to_Back_Car_Parking__c); 
        }
        if(booking.No_of_additional_Individual_car_parkings__c !=null && booking.No_of_additional_Individual_car_parkings__c !=0){
            NoCarParkingIndividual = NoCarParkingIndividual ==null?integer.valueof(booking.No_of_additional_Individual_car_parkings__c) :NoCarParkingIndividual+integer.valueof(booking.No_of_additional_Individual_car_parkings__c) ; 
        }
        if(booking.No_of_additional_Back_to_back_car_parki__c !=null && booking.No_of_additional_Back_to_back_car_parki__c !=0){
            NoCarParkingBackToBack = NoCarParkingBackToBack ==null?integer.valueof(booking.No_of_additional_Back_to_back_car_parki__c) :NoCarParkingBackToBack+integer.valueof(booking.No_of_additional_Back_to_back_car_parki__c) ; 
        }
        if(NoCarParkingIndividual ==null && NoCarParkingBackToBack ==null ){
            NoCarParkingIndividual =1; 
        }
        if(NoCarParkingIndividual !=null ){
            formattedNoofParking = NoCarParkingIndividual+' Nos - Individual' +(NoCarParkingBackToBack !=null? ','+NoCarParkingBackToBack+'Nos - Back To Back':'' );
        }
        if(formattedNoofParking ==null ){
            formattedNoofParking = ''+NoCarParkingBackToBack +' Nos - Back To Back';
        }
        
        if(NoCarParkingIndividual !=null && booking.Individual_Car_Parking_Area__c !=null ){
            string bb =(NoCarParkingBackToBack !=null && booking.Back_To_Back_Car_Parking_Area__c !=null)? ','+booking.Back_To_Back_Car_Parking_Area__c:'' ;
            formattedNoofParkingArea = booking.Individual_Car_Parking_Area__c+' ' +bb;
        }
        if(formattedNoofParkingArea ==null && booking.Back_To_Back_Car_Parking_Area__c !=null){
            formattedNoofParkingArea = ''+booking.Back_To_Back_Car_Parking_Area__c ;
        }
        if(NoCarParkingIndividual !=null && booking.Individual_Car_Parking_Dimension__c !=null ){
            string bb =(NoCarParkingBackToBack !=null && booking.Back_To_Back_Car_Parking_Dimension__c !=null)? (','+booking.Back_To_Back_Car_Parking_Dimension__c):'';
            formattedNoofParkingDimension = booking.Individual_Car_Parking_Dimension__c+' ' + bb;
        }
        if(formattedNoofParkingDimension ==null && booking.Back_To_Back_Car_Parking_Dimension__c !=null){
            formattedNoofParkingDimension = ''+booking.Back_To_Back_Car_Parking_Dimension__c;
        }
        
        
        getFloorWithSuffix=getFloorWithSuffix(booking.Plot__r.Floor__c);
        if (booking.Carpet_Area__c != null) {
            Decimal carpetAreaSqftValue = booking.Carpet_Area__c * 10.76391041671;
            carpetAreaSqft = String.valueOf(carpetAreaSqftValue.setscale(0));
            
            totalAmountInWords = (booking.Total__c != null) ? convertNumberToWords(booking.Total__c) + ' Only' : 'Zero Only';
            bookingAdvanceAmountInWords = (paymentSchedule[0].Total_Amount__c !=null) ? convertNumberToWords(paymentSchedule[0].Total_Amount__c.setscale(0)) + ' Only' : 'Zero Only';
        }
    }
    public static String getFloorWithSuffix(String floorNumber) {
        if (floorNumber == null) {
            return null;
        }
        
        String floorStr = String.valueOf(floorNumber); // Convert the floor number to a string
        String suffix = 'th'; // Default suffix is "th"
        
        // Handle the special case for numbers 11-13 (e.g., 11th, 12th, 13th)
        if (floorStr.endsWith('11') || floorStr.endsWith('12') || floorStr.endsWith('13')) {
            suffix = 'th';
        } else {
            // Get the last character of the string and determine the suffix
            String lastChar = floorStr.substring(floorStr.length() - 1);
            if (lastChar == '1') {
                suffix = 'st';
            } else if (lastChar == '2') {
                suffix = 'nd';
            } else if (lastChar == '3') {
                suffix = 'rd';
            }
        }
        
        return floorNumber + suffix;
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