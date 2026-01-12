public class NocLetterController {
    public string dates {get; set;}
    public String purchaserName {get; set;}
    public String purchaserDetails {get; set;}
    public String purchaserFatherOrHusName {get; set;}
    public String bankName {get; set;}
    public String directorName {get; set;}
    public String companyName {get; set;}
    public String resolutionDate {get; set;}
    public String address {get; set;}
    public String pincode {get; set;}
    public String registrationDate {get; set;}
    public String flatNo {get; set;}
    public String projectName {get; set;}
    public Integer projectPincode {get; set;}
    public String cityName {get; set;}
    public String areaName {get; set;}
    public String locality {get; set;}
    public String street {get; set;}
    public String plotNumber {get; set;}
    public String transactionAmount {get; set;}
    public String recordId {get; set;}
    public Integer primaryPincode {get; set;}
    

    public NocLetterController(ApexPages.StandardController stdController) {
        // Fetching recordId from page URL
        recordId = ApexPages.currentPage().getParameters().get('id');
        
        // Query booking and project details
        Booking__c booking = [SELECT Id, Name, SLead__r.Name, Aadhaar_Number__c, PAN_Number1__c, Age__c, Designation__c, Occupation__c, 
            Primary_Applicant_Father_Husband_s_Name__c, Address__c, SLead__r.Pin_Code__c, Registration_Date__c, Primary_Applicant_Relationship_Type__c,
            SLead__r.Street__c, SLead__r.City__c, Plot__r.Name,Total__c,Project1__r.Name,Project1__c, Permanent_House_No_Name__c, Desom__c, Permanent_Post_Office__c,/*Village_Panchayath__c, Taluk__c,*/District__c,Permanent_Postal_Code__c
            FROM Booking__c WHERE Id = :recordId];
        
        Project__c project = [SELECT Id, Name, Project_Address__c, Pincode__c, City__c, Area_Name__c, Locality_Name__c, 
            Street__c, Plot_No__c FROM Project__c WHERE Id = :booking.Project1__c];
        
        // Set date
        Date currentDate = system.now().date();
        //dates = String.valueOf(currentDate.day()) + '.' + String.valueOf(currentDate.month()) + '.' + String.valueOf(currentDate.year
        // Set purchaser and address details
       // purchaserName = booking.salutation_Applicant1__c + booking.	First_Applicant_Name__c;
        purchaserDetails = '(Aadhaar No. ' + booking.Aadhaar_Number__c + ' issued by Government of India)and (PAN ' + booking.PAN_Number1__c + 
            '), aged ' + booking.Age__c + '('+convertNumberToWords(booking.Age__c)+') years'  ;
        
       // address = booking.Address__c + ', ' + booking.SLead__r.Street__c + ', ' + booking.SLead__r.City__c;
        pincode = booking.SLead__r.Pin_Code__c;
        
        // Format Registration Date
        Date regDate = booking.Registration_Date__c;
        if (regDate != null) {
            registrationDate = formatDateToString(regDate);
        }
        
        flatNo = booking.Plot__r.Name;
        projectName = project.Name;
        cityName = project.City__c;
        areaName = project.Area_Name__c;
        locality = project.Locality_Name__c;
        street = project.Street__c;
        plotNumber = project.Plot_No__c;
        
        projectPincode = project.Pincode__c != null ? project.Pincode__c.intValue() : null;
        primaryPincode = booking.Permanent_Postal_Code__c != null? booking.Permanent_Postal_Code__c.intValue() :null;
        List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
        //string companyName;
        string companyAddress1;
        string companyAddress2;
        string companyAddress3;
        if(!companyDetails.isEmpty()){
            companyName = companyDetails[0].Label;
            companyAddress1 =   companyDetails[0].Registered_Address__c;
            companyAddress2 =   companyDetails[0].Address2__c;
            companyAddress3 =   companyDetails[0].Address3__c;
        }
        // Transaction amount
        transactionAmount = 'Rs.' + booking.Total__c.format()+ '/- (Rupees  ' + convertNumberToWord(booking.Total__c)+')';
        bankName = 'STATE BANK OF INDIA';
        directorName = 'Kurian Thomas';
        //companyName = 'Veegaland Developers Limited';
        resolutionDate = '30.09.2023';
    }

    // Helper function to format Date to dd.MM.yyyy
    private String formatDateToString(Date dateValue) {
        String day = String.valueOf(dateValue.day());
        String month = String.valueOf(dateValue.month());
        String year = String.valueOf(dateValue.year());
        
        if (day.length() == 1) {
            day = '0' + day;
        }
        if (month.length() == 1) {
            month = '0' + month;
        }
        
        return day + '.' + month + '.' + year;
    }
                                                                                                                     // Helper function to convert Age (Integer) to words
       // Helper function to convert integer number to words
    private String convertNumberToWords(Decimal age) {
        Integer numbers = age.intValue();  // Convert the decimal to an integer
        if (numbers == 0) return 'Zero';
        
        String[] ones = new String[]{'','One','Two','Three','Four','Five','Six','Seven','Eight','Nine','Ten','Eleven','Twelve','Thirteen','Fourteen','Fifteen','Sixteen','Seventeen','Eighteen','Nineteen'};
            String[] tens = new String[]{'','Ten','Twenty','Thirty','Forty','Fifty','Sixty','Seventy','Eighty','Ninety'};
                
                String words = '';
        
        // Handle hundreds
        if (numbers >= 100) {
            words += ones[numbers / 100] + ' Hundred ';
            numbers = numbers - (numbers / 100) * 100;  // Subtract the hundreds part
        }
        
        // Handle tens (20-99)
        if (numbers >= 20) {
            words += tens[numbers / 10] + ' ';
            numbers = numbers - (numbers / 10) * 10;  // Subtract the tens part
        }
        
        // Handle ones (1-9 or special case 10-19)
        if (numbers > 0) {
            words += ones[numbers];
        }
        
        return words.trim();
    }
    
     public static String convertNumberToWord(Decimal numb) {
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