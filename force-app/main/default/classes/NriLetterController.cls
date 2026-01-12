public class NriLetterController {
    public String allotteeName {get; set;}
    public String allotteeAddress {get; set;}
    public String projectName {get; set;}
    public String unitNo {get; set;}
    public String floorNo {get; set;}
    public String reasonForNonRegistration {get; set;}
    public String signingLocation {get; set;}
    public String customerName {get; set;}
    public String place {get; set;}
    public String dates {get; set;}
    public String recordId {get; set;}
    public Integer primaryPincode {get; set;}
    public String floorNumberWithSuffix {get; set;}

    public NriLetterController(ApexPages.StandardController stdController) {
        // Sample data initialization (you can fetch this from your Salesforce database or pass as parameters)
        recordId = ApexPages.currentPage().getParameters().get('id');
        Booking__c booking = [SELECT Id, Name, SLead__r.Name, Aadhaar_Number__c, PAN_Number1__c, Age__c, Designation__c, First_Applicant_Name__c,
            Primary_Applicant_Father_Husband_s_Name__c, Address__c, SLead__r.Pin_Code__c, Registration_Date__c, Permanent_Postal_Code__c,
            SLead__r.Street__c, SLead__r.City__c, Plot__r.Name,Total__c,Project1__r.Name,Project1__c,Plot__r.Floor__c,FloorNo__c
            FROM Booking__c WHERE Id = :recordId];
        
        Project__c project = [SELECT Id, Name, Project_Address__c, Pincode__c, City__c, Area_Name__c, Locality_Name__c, 
            Street__c, Plot_No__c FROM Project__c WHERE Id = :booking.Project1__c];
        allotteeName = booking.First_Applicant_Name__c;
       // allotteeAddress = booking.Address__c+', '+booking.SLead__r.Street__c+', '+booking.SLead__r.City__c;
        projectName = project.Name;
        unitNo = booking.Plot__r.Name;
        floorNo = booking.Plot__r.Floor__c;
        reasonForNonRegistration = 'personal reasons';
        signingLocation = 'Kochi';
        customerName = booking.SLead__r.Name;
        place = 'Kochi';
        //dates = '02.12.2024';
        
        //formatting pincode
        if(booking.Permanent_Postal_Code__c != null){
            primaryPincode = booking.Permanent_Postal_Code__c.intValue();
          }
        // adding suffix to the floor number
        if(booking.FloorNo__c !=null){
        floorNumberWithSuffix = getFloorWithSuffix(booking.FloorNo__c);
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
}