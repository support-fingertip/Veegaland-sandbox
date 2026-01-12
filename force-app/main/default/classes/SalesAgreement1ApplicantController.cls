public without sharing class SalesAgreement1ApplicantController {
    public Booking__c booking { get; set; }
    public List<Co_Applicant__c> coapplicants { get; set; }
    public List<Receipt__c> receipts { get; set; }
    public List<Payment_schedule__c> paymentSchedule { get; set; }
    public String subTotalInWords { get; set; }
    public String gstAmountInWords { get; set; }
    public String totalAmountInWords { get; set; }
    public String carpetAreaSqft { get; set; }
    public String superBuiltUpAreaSqft { get; set; }
    public String ageInWords { get; set; } 
    public String coageInWords { get; set; }
    public String coappAgeInWords { get; set; }
    public String coAge { get; set; }
    public String maintenanceCharge { get; set; }
    public String formattedReceipts { get; set; }
    public String formattedcoapplicants { get; set; }
    public Decimal inclusiveTax { get; set; }
    public Decimal cgstTotal  { get; set; }
    public Decimal sgstTotal  { get; set; }
    public Decimal grandTotal  { get; set; }
    public Decimal exclusiveTax  { get; set; }
    public String secondaryAge { get; set; }
    public Decimal age { get; set; }
    public Decimal ageprimary { get; set; } 
    public Decimal primaryPostalcode { get; set; }
    public Decimal secondaryPostalcode { get; set; }
    public String FloorNumber { get; set; }
    public String getFloorWithSuffix { get; set; }
    public String Date_of_SaleAgreement { get; set; }
    public String coApplicantNamesWithIndex { get; set; }
    public Integer coApplicantCount { get; set; }
    public Decimal totalAmnttInReceipt { get; set; }
    public String totalAmnttInReceiptInWords { get; set; }
    public List<coapplicantsWrapper>  coapplilist { get; set; }
    public List<coapplicantsWrapper>  bookingcoapplilist { get; set; }
    public String handoverformattedDateTime { get; set; }
    public String corpusAmntInWords { get; set; }
    
    public String formattedDueDate { get; set; }
    public String finaladdres { get; set; }
    public String bookingId { get; set; }
    public String resourceName { get; set; }
    
    
    
    public SalesAgreement1ApplicantController() {
        bookingId = ApexPages.currentPage().getParameters().get('id');
        if (String.isNotBlank(bookingId)) {
            fetchBookingDetails();
        }
    }
    
    private void fetchBookingDetails() { 
        booking = [
            SELECT Id,
            First_Applicant_Name__c,
            Aadhaar_Number__c,
            PAN_Number1__c,
            Primary_Applicant_Relationship_Type__c,
            Primary_Applicant_Father_Husband_s_Name__c,
            Permanent_House_No_Name__c,
            Desom__c,
            Permanent_Post_Office__c,
          	Village_Panchayath__c,
           	Taluk__c,
            District__c,
            Permanent_Postal_Code__c,
            Project1__r.Name,
            Sub_Total__c,
            GST_Amount__c,
            Total__c,
            Carpet_Area__c,
            UDS_Percentage__c,
            Total_Corpus_fund__c,
            Covered_parking_slot_number__c,
            Plot__r.Name,
            Plot__r.Apartment_No__c,
            Plot__r.Floor__c,
            Plot__r.BHK_Type__c,
            Plot__r.Undivided_Share_of_Land__c,
            Plot__r.Block__c,
            Plot__r.Super_built_up_area__c,
            Plot__r.UDS_Percentage__c,
            Age__c,
            Maintenance_Deposite__c,
            Association_Deposit__c,
            Second_Applicant_Name__c,
            Age2__c,
            Authorized_Signatory_Father_Husband_Name__c,
            Date_of_birth_Applicant2__c,
            FloorNo__c,
            Sale_Agreement_Date__c,
            Unit_UDS_Area__c,
            Signatory_Permanent_Postal_Code__c,
            Handing_over__c,
            Covered_Park_Parking__c,
            Aadhaar_Number1__c,
            Authorized_Signatory_PAN__c,
            Authorized_Signatory_Profession__c,
            Signatory_Permanent_Post_Office__c,
            Unit_Type__c,Occupation__c,
            Built_up_area__c
            FROM Booking__c
            WHERE Id = :bookingId
        ];
        resourceName = 'schlast';
        
        receipts = [SELECT Amount_received__c, Mode_of_payment__c, Check_Transaction_Nmber__c, Receipt_date__c, Bank_Name__c,Total_Received_Amount__c, Payment_Received_Bank__c
                    FROM Receipt__c 
                    WHERE Booking__c = :bookingId
                    ORDER BY Receipt_Date__c ASC];
        
        formattedReceipts= formatReceipts();
        coapplicants=[SELECT Name,Aadhar_Number__c,PAN_Number__c,Occupation__c,Permanent_House_No_Name__c,Permanent_City__c,Desom__c,Village_Panchayath__c,Taluk__c,District__c,Relation__c,
                      Permanent_Street_Location__c,Permanent_State__c,Permanent_Post_Office__c,Permanent_Postal_Code__c,age__c,Co_Applicant_Profession__c,Co_Applicant_Father_Husband_s_Name__c,Age_in_words__c 
                      FROM Co_Applicant__c WHERE Booking__c = :bookingId  ];
        coApplicantCount = coApplicants.size()+1;
        formattedcoapplicants= formatcoapplicants();
        getFloorWithSuffix=getFloorWithSuffix(booking.Plot__r.Floor__c);
        
        /* List<String> coApplicantNamesWithIndex = new List<String>();
Integer index = 2; // Start from 1
for (Co_Applicant__c applicant : coApplicants) {
coApplicantNamesWithIndex.add(index + '. ' + applicant.Name);

index++;

}
system.debug(coApplicantNamesWithIndex);*/
        
        
        //postal code
        if (booking.Permanent_Postal_Code__c != null) {
            primaryPostalcode = Math.floor(booking.Permanent_Postal_Code__c); 
        }
        if (booking.Signatory_Permanent_Postal_Code__c != null) {
            secondaryPostalcode = Math.floor(booking.Signatory_Permanent_Postal_Code__c); 
        }
        
        //converting age in to integer
        if (booking.Age2__c != null) {
            age = Math.floor(booking.Age2__c); 
        } 
        if (booking.Age__c != null) {
            ageprimary = Math.floor(booking.Age__c); 
        } 
        paymentSchedule = [SELECT S_No__c,Name,Payment_Due_Date__c,Payment_percent__c,AmountB__c,CGST_Amount__c, SGST_Amount__c, Total_Amount__c, Amount_Excluding_Taxes__c FROM Payment_schedule__c WHERE Booking__c = :bookingId order by S_No__c]; 
        AggregateResult agr= [SELECT sum(AmountB__c) inclusiveTax, Sum(CGST_Amount__c) Cgst, sum(SGST_Amount__c) sgst, sum(Total_Amount__c) total , sum(Amount_Excluding_Taxes__c) exclusvTax FROM Payment_schedule__c WHERE Booking__c = :bookingId ];
        inclusiveTax = (Decimal)agr.get('inclusiveTax');
        cgstTotal = (Decimal)agr.get('Cgst');
        sgstTotal = (Decimal)agr.get('sgst');
        grandTotal = (Decimal)agr.get('total');
        exclusiveTax = (Decimal)agr.get('exclusvTax');
        AggregateResult agrr= [SELECT sum(Total_Received_Amount__c) totalAmountReceived FROM Receipt__c WHERE Booking__c = :bookingId ];
        totalAmnttInReceipt= (Decimal)agrr.get('totalAmountReceived');
        
        
        
        system.debug(booking);
        // converting age in to words
        if (booking.Age__c != null) {
            ageInWords = convertNumberToWords(Integer.valueOf(booking.Age__c));
        }
        
        for(Co_Applicant__c co: coapplicants){
            if (co.age__c != null){
                co.Age_in_words__c= convertNumberToWords(Integer.valueOf(co.age__c));
            }
            
        }
        
        //coageInWords = convertNumberToWords(Integer.valueOf(coapplicants.age__c));
        
        if (booking.Age2__c != null) {
            secondaryAge = convertNumberToWords(Integer.valueOf(booking.Age2__c));
        }
        if (booking.Total_Corpus_fund__c != null) {
            String corpusFund = convertNumberToWords(Integer.valueOf(booking.Total_Corpus_fund__c));
        }
        
        
        // Convert Sq. Mtrs to Sqft
        if (booking.Carpet_Area__c != null) {
            Decimal carpetAreaSqftValue = booking.Carpet_Area__c * 10.7639;
            carpetAreaSqft = String.valueOf(carpetAreaSqftValue.round());
        }
        
        if (booking.Plot__r.Super_built_up_area__c != null) {
            Decimal superBuiltUpAreaSqftValue = booking.Plot__r.Super_built_up_area__c * 10.7639;
            superBuiltUpAreaSqft = String.valueOf(superBuiltUpAreaSqftValue.round());
        }
        
        if (booking.Handing_over__c != null) {
            Date  handoverdatetime = ((booking.Handing_over__c)).date();
            system.debug(handoverdatetime);
            string month = integer.valueOf(handoverdatetime.month()) < 10 ? ('0'+handoverdatetime.month()): ''+handoverdatetime.month();
            handoverformattedDateTime = handoverdatetime.day()+'-'+ month +'-'+handoverdatetime.year();
        }
        
        
        
        
        
        if (booking.Sale_Agreement_Date__c != null) {
            Date_of_SaleAgreement = getFormattedDate(booking.Sale_Agreement_Date__c);
        }
        
        //floor number suffix
        if (booking.FloorNo__c != null) {
            if(booking.FloorNo__c.isNumeric()){
                FloorNumber = convertToWords(Integer.valueof(booking.FloorNo__c));
            }else{
                if(booking.FloorNo__c == 'G'){
                    FloorNumber = 'Ground ';
                }else{
                    FloorNumber = booking.FloorNo__c + ' th';
                }
            }
            
        }
        
        
        
        //cgstsgsttaxAmount=(booking.GST_Amount__c)/2;
        
        // Convert amounts to words
        subTotalInWords = (booking.Sub_Total__c != null) ? convertNumberToWords(booking.Sub_Total__c) + ' Only' : 'Zero Only';
        gstAmountInWords = (booking.GST_Amount__c != null) ? convertNumberToWords(booking.GST_Amount__c) + ' Only' : 'Zero Only';
        totalAmountInWords = (booking.Total__c != null) ? convertNumberToWords(booking.Total__c) + ' Only' : 'Zero Only';
        totalAmnttInReceiptInWords=(totalAmnttInReceipt != null) ? convertNumberToWords(totalAmnttInReceipt) + ' Only' : 'Zero Only';
        corpusAmntInWords=(booking.Total_Corpus_fund__c != null) ? convertNumberToWords(booking.Total_Corpus_fund__c) + ' Only' : 'Zero Only';
        
        
        maintenanceCharge = (booking.Maintenance_Deposite__c != null) ? convertNumberToWords(booking.Maintenance_Deposite__c) + ' Only' : 'Zero Only';
        
        
        
    }
    
    
    
    // Method to convert number to words
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
    
    private String formatReceipts( ) {
        List<Receipt__c> listreceipts=receipts;
        if (listreceipts.isEmpty()) return '';
        
        List<String> receiptEntries = new List<String>();
        Integer counter = 97; // ASCII value of 'a' (for 'a', 'b', 'c', etc.)
        
        for (Receipt__c receipt : listreceipts) {
            
            String amount = (receipt.Total_Received_Amount__c != null) ?  'Rs.' + (receipt.Total_Received_Amount__c).format() : 'payment not available';
            String paymentMode = (receipt.Mode_of_payment__c != null) ? receipt.Mode_of_payment__c : 'mode of payment not available';
            String refNo = (receipt.Check_Transaction_Nmber__c != null) ? '[Ref No.' + receipt.Check_Transaction_Nmber__c + ']' : '';
            
            // Handle null Receipt_date__c
            String dat = (receipt.Receipt_date__c != null) ? 'dated ' + receipt.Receipt_date__c.format() : 'Date Not Available';
            
            String bank = (receipt.Payment_Received_Bank__c != null) ? 'through ' + receipt.Payment_Received_Bank__c : 'through Unknown Bank';
            
            String entry = '(' + String.fromCharArray(new List<Integer>{counter}) + ') ' + 
                amount + ' via ' + paymentMode + ' ' + refNo + ' ' + dat + ' ' + bank + '.';
            
            receiptEntries.add(entry);
            counter++;
        }
        
        return String.join(receiptEntries, ' ');
    }
    
    
    private String formatcoapplicants() {
        List<Co_Applicant__c> coapps = coapplicants;
        if (coapps.isEmpty()) return '';
        system.debug('coapplicants Size '+coapplicants.Size());
        system.debug('coapplicants '+coapplicants);
        system.debug('booking '+booking);
        List<String> coappEntries = new List<String>();
        Integer counter = 2; 
        List<coapplicantsWrapper> coapplist=new  List<coapplicantsWrapper>();
        List<coapplicantsWrapper> coapplist1=new  List<coapplicantsWrapper>();
        
        coapplicantsWrapper cowWrapper1= new coapplicantsWrapper();
        cowWrapper1.coapplName= booking.First_Applicant_Name__c;
        coapplist1.add(cowWrapper1);
        for (Co_Applicant__c co : coapps) {
            coapplicantsWrapper cowWrapper= new coapplicantsWrapper();
            cowWrapper.coapplName= co.Name;
            
            //String name = (co.Name != null) ? + '.' +' '+ (co.Name) : 'Null';
            String aadhar = (co.Aadhar_Number__c != null) ? co.Aadhar_Number__c : 'Aadhar no. not available '  ;
            String pan = (co.PAN_Number__c != null) ?   co.PAN_Number__c   : 'Pan not available ';
            coappAgeInWords = convertNumberToWords(Integer.valueOf(co.age__c));
            string age = (co.age__c != null) ?' aged '+ String.valueOf(co.age__c) +' ('+coappAgeInWords+') years, ' : '';
            
            
            String profe = (co.Co_Applicant_Profession__c != null) ?  co.Co_Applicant_Profession__c : 'Profession not available ';
            String son_wife = (co.Co_Applicant_Father_Husband_s_Name__c != null) ?  'Son/Daughter/Wife/Husband of '+co.Co_Applicant_Father_Husband_s_Name__c : '';
            //String address = co.Permanent_Street_Location__c+', '+co.Permanent_State__c+', '+co.Permanent_Post_Office__c+',  Pin Code - '+co.Permanent_Postal_Code__c ;
            
            string houseName= (co.Permanent_House_No_Name__c != null) ?  co.Permanent_House_No_Name__c : '';
            string desom= (co.Desom__c != null) ?  co.Desom__c +' Desom' : '';
            string po = (co.Permanent_Post_Office__c != null) ?  co.Permanent_Post_Office__c +' P. O.' : '';
            string village = /*(co.Village_Panchayath__c != null) ?  co.Village_Panchayath__c +' Village' :*/ '';
          //  string taluk = (co.Taluk__c != null) ?  co.Taluk__c +' Taluk' : '';
            string district = (co.District__c != null) ?  co.District__c +' District' : '';
            string pinCode = (co.Permanent_Postal_Code__c != null) ?  ' Pin Code  - '+String.valueOf(co.Permanent_Postal_Code__c) : '';
            //  string streetLocn=(co.Permanent_Street_Location__c != null) ?  co.Permanent_Street_Location__c : '';
            // string state=(co.Permanent_State__c != null) ?  co.Permanent_State__c : '';
            //string postOffice =(co.Permanent_Post_Office__c != null) ?  co.Permanent_Post_Office__c : '';
            
            string addrs = (houseName +', '+desom +', '+po+', '+village+', '+/*taluk*/ +', '+district+', '+pinCode);
            List<String> addressParts = new List<String>();
            
            if (co.Permanent_House_No_Name__c != null) {
                addressParts.add(co.Permanent_House_No_Name__c);
            }
            if (co.Desom__c != null) {
                addressParts.add(co.Desom__c + ' Desom');
            }
            if (co.Permanent_Post_Office__c != null) {
                addressParts.add(co.Permanent_Post_Office__c + ' P. O.');
            }
           // if (co.Village_Panchayath__c != null) {
           //     addressParts.add(co.Village_Panchayath__c + ' Village');
           // }
           // if (co.Taluk__c != null) {
           //     addressParts.add(co.Taluk__c + ' Taluk');
          //  }

            if (co.District__c != null) {
                addressParts.add(co.District__c + ' District');
            }
            if (co.Permanent_Postal_Code__c != null) {
                addressParts.add('Pin Code - ' + String.valueOf(co.Permanent_Postal_Code__c));
            }
            String finalAddress = String.join(addressParts, ', ');
            
            // Full output (Only show address if it has data)
            //String finalOutput = finalDetails;
            if (!addressParts.isEmpty()) {
                finaladdres =finalAddress;
            }
            
            
            
            String fulladdrs='';
            if(!String.isBlank(houseName) || !String.isBlank(desom)|| !String.isBlank(po)|| !String.isBlank(village) /*|| !String.isBlank(taluk)*/|| !String.isBlank(district)|| !String.isBlank(pinCode)){
                fulladdrs = 'having address at '+addrs+' ';
            }
            /*
if (String.isNotEmpty(co.Permanent_Street_Location__c)) {
address += co.Permanent_Street_Location__c;
}


if (String.isNotEmpty(String.valueOf(co.Permanent_Postal_Code__c))) {
if (address != '') address += ', '; // Adds a comma if address already has content
address +='Pin Code - '+ co.Permanent_Postal_Code__c;
}*/
            
            
            
            
            String entry = ''+'(Aadhaar No. '+aadhar+' issued by Government of India) and (PAN '+pan+'),'+' '+age +' '+profe+', ';
            
            
            //coappEntries.add(entry);
            counter++;
            cowWrapper.coapplidetails=entry;
            coapplist.add(cowWrapper);
            coapplist1.add(cowWrapper);
        }
        
        coapplilist=coapplist;
        bookingcoapplilist = coapplist1;
        return String.join(coappEntries, ' ');
        
    }   
    
    
    
    
    
    private String convertToWords(Integer fNumber) {
        if (fNumber == null) {
            return '';
        }
        
        list<String> units = new List<String>{ '', 'First', 'Second', 'Third', 'Fourth', 'Fifth', 'Sixth', 'Seventh', 'Eighth', 'Ninth' };
            list<String> teens = new List<String>{ 'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen' };
                list<String> tens = new List<String>{ '', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety' };
                    list<String> hundred = new List<String> { '', 'hundred' };
                        
                        String numberStr = String.valueOf(fNumber);
        Integer length = numberStr.length();
        
        String result = '';
        if(length == 2){
            Integer secondPart = Integer.valueOf(numberStr.substring(0, 2));
            if (secondPart >= 10 && secondPart < 20) {
                result += teens[secondPart - 10];            
            }else if (secondPart >= 20){
                Integer secondFirst = Integer.valueOf(numberStr.substring(0, 1));
                Integer secondLast = Integer.valueOf(numberStr.substring(1, 2));
                result += tens[secondFirst];
                if(secondLast > 0){
                    result += units[secondLast];
                }
            }
            result += 'th';
        }else{
            Integer firstPart = Integer.valueOf(numberStr.substring(0, 1));
            if (firstPart > 0) {
                result += units[firstPart];
            } 
        }
        return result.trim().replaceAll(' +', ' ');
    }
    
    public String getFormattedDate(Date conversionDate) {
        String formattedDate = formatDate(conversionDate);
        System.debug(formattedDate);
        return formattedDate;
    }
    
    // Method to format the date (converting day, month, year into words)
    private String formatDate(Date inputDate) {
        String dayInWords = convertDayToWords(inputDate.day());
        String monthInWords = convertMonthToWords(inputDate.month());
        String yearInWords = convertYearToWords(inputDate.year());
        
        String formattedDate = dayInWords + ' day of ' + monthInWords + ' ' + yearInWords;
        String shortDate = '(' + padZero(inputDate.day()) + '-' + padZero(inputDate.month()) + '-' + inputDate.year() + ')';
        
        return formattedDate + ' ' + shortDate;
    }
    
    // Method to convert day to words
    private String convertDayToWords(Integer day) {
        Map<Integer, String> dayMap = new Map<Integer, String>{
            1 => 'First', 2 => 'Second', 3 => 'Third', 4 => 'Fourth', 5 => 'Fifth',
                6 => 'Sixth', 7 => 'Seventh', 8 => 'Eighth', 9 => 'Ninth', 10 => 'Tenth',
                11 => 'Eleventh', 12 => 'Twelfth', 13 => 'Thirteenth', 14 => 'Fourteenth',
                15 => 'Fifteenth', 16 => 'Sixteenth', 17 => 'Seventeenth', 18 => 'Eighteenth',
                19 => 'Nineteenth', 20 => 'Twentieth', 21 => 'Twenty First', 22 => 'Twenty Second',
                23 => 'Twenty Third', 24 => 'Twenty Fourth', 25 => 'Twenty Fifth',
                26 => 'Twenty Sixth', 27 => 'Twenty Seventh', 28 => 'Twenty Eighth',
                29 => 'Twenty Ninth', 30 => 'Thirtieth', 31 => 'Thirty First'
                };
                    
                    return dayMap.containsKey(day) ? dayMap.get(day) : '';
    }
    
    // Method to convert month to words
    private String convertMonthToWords(Integer month) {
        Map<Integer, String> monthMap = new Map<Integer, String>{
            1 => 'January', 2 => 'February', 3 => 'March', 4 => 'April',
                5 => 'May', 6 => 'June', 7 => 'July', 8 => 'August',
                9 => 'September', 10 => 'October', 11 => 'November', 12 => 'December'
                };
                    
                    return monthMap.containsKey(month) ? monthMap.get(month) : '';
    }
    
    // Method to convert year to words (supports any year)
    private String convertYearToWords(Integer year) {
        if (year == null) {
            return '';
        }
        
        List<String> units = new List<String>{ '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine' };
            List<String> teens = new List<String>{ 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen' };
                List<String> tens = new List<String>{ '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety' };
                    
                    // Handling for thousands (assumed up to 9999 for simplicity)
                    List<String> thousands = new List<String>{ '', 'Thousand' };
                        
                        String yearStr = String.valueOf(year);
        Integer length = yearStr.length();
        String result = '';
        
        if (length == 4) {
            Integer firstPart = Integer.valueOf(yearStr.substring(0, 2));
            if (firstPart == 20) {
                result += 'Two ';
            } else if (firstPart == 21) {
                result += 'Twenty ';
            } else {
                result += units[firstPart] + ' ';
            }
            result += thousands[1] + ' ';
            
            String lastPart = yearStr.substring(2, 4);
            Integer lastPartInt = Integer.valueOf(lastPart);
            if (lastPartInt >= 10 && lastPartInt < 20) {
                result += teens[lastPartInt - 10];
            } else {
                Integer lastFIrst = Integer.valueOf(lastPart.substring(0, 1));
                Integer lastLast = Integer.valueOf(lastPart.substring(1, 2));
                result += tens[lastFIrst] + ' ' + units[lastLast];
            }
        }
        return result.trim().replaceAll(' +', ' ');
    }
    
    // Helper function to pad single digit to two digits
    private String padZero(Integer num) {
        return num < 10 ? '0' + String.valueOf(num) : String.valueOf(num);
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
    
    public without sharing class coapplicantsWrapper {
        public string coapplidetails{get;set;}
        public string coapplName{get;set;}
        
        
    }
}