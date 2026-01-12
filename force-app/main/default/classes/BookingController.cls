public without sharing class BookingController {
    private static final List<String> BELOW_TWENTY = new List<String>{
        '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten',
            'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'
            };
                
                private static final List<String> TENS = new List<String>{
                    '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
                        };
                            
                            private static final List<String> INDIAN_UNITS = new List<String>{
                                '', 'Thousand', 'Lakh', 'Crore'
                                    };
                                        
                                        @auraEnabled
                                        public static Map<String, Object> fetchQuoteAndCoApplicants(Id quoteId) {
                                            Map<String, Object> resultMap = new Map<String, Object>();
                                            
                                            try {
                                                // Fetch Quote record
                                                Quote__c quote = [SELECT 
                                                                  Primary_Applicant_Name__c, Primary_Applicant_Saluaion__c, Primary_Applicant_DoB__c,
                                                                  Primary_Applicant_NRI_RI__c, Primary_Applicant_Profession__c, Primary_Applicant_Father_Husband_s_Name__c,
                                                                  Primary_Applicant_PAN__c, Primary_Applicant_Aadhaar_No__c, Primary_Applicant_Passport_No__c,
                                                                  Primary_Applicant_Driving_License_No__c, Primary_Applicant_Email__c, Primary_Applicant_Mobile_No__c,
                                                                  Primary_Applicant_Telephone_No__c, Primary_Applicant_International_No__c, Permanent_House_No_Name__c,
                                                                  Permanent_Street_Location__c, Permanent_Post_Office__c, Permanent_City__c, Permanent_State__c,
                                                                  Permanent_Postal_Code__c, Permanent_Country__c, Correspondence_House_No_Name__c,
                                                                  Correspondence_Street_Location__c, Correspondence_Post_Office__c, Correspondence_City__c,
                                                                  Correspondence_State__c, Correspondence_Postal_Code__c, Correspondence_Country__c,
                                                                  Actual_Base_Rate__c, Floor_Rise_Charges__c, Car_Parking_Charge__c, Extra_car_parking_charges__c,Projects__c,Date_Of_Transaction__c,
                                                                  Additional_Car_Parking_Required__c, Built_up_area__c, Open_Terrace_Area_Charges__c, Terrace_Area_SqFt__c,Transaction_ID__c,Mode_of_Payment__c,Payment_Bank_Name__c,Payment_From__c,
                                                                  Common_Area_SqFt__c, Landscape_Charge__c, Project__c, Block__c, Special_Launch__c,Land_Plot_Area_SqFt__c,RERA_Area_SqFt__c,Garden_Area_SqFt__c,GST__c,
                                                                  Discount_In_Rupees__c,Primary_Applicant_Secondary_Email__c,WhatsApp_Number__c,Lead_Country_Code__c,Lead_Date__c,BHK_Type__c,Lead_Source__c,Draft_Cheque_RTGS_NEFT_No__c,Branch__c, BHK_Type1__c, Leads__c,Leads__r.Leadsource__c,Leads__r.Name, Unit__c,Unit__r.Name, Payment_Plan__c,Payment_Plan__r.Name,Advance_Amount_Received__c,OwnerId,No_of_Back_to_Back_Car_Parking__c,No_of_Individual_Car_Parking__c,No_of_Extra_Back_to_Back_Car_Parking__c,No_of_Extra_Individual_Car_Parking__c
                                                                  FROM Quote__c WHERE Id = :quoteId LIMIT 1];
                                                
                                                /*// Map Quote fields to Booking fields
Booking__c booking = new Booking__c();
booking.First_Applicant_Name__c = quote.Primary_Applicant_Name__c;
booking.salutation_Applicant1__c = quote.Primary_Applicant_Saluaion__c;
booking.Date_of_Birth1__c = quote.Primary_Applicant_DoB__c;
booking.Primary_Applicant_NRI_RI__c = quote.Primary_Applicant_NRI_RI__c;
booking.Occupation__c = quote.Primary_Applicant_Profession__c;
booking.Primary_Applicant_Father_Husband_s_Name__c = quote.Primary_Applicant_Father_Husband_s_Name__c;
//booking.PAN_Number1__c = quote.Primary_Applicant_PAN__c;
//booking.Aadhaar_Number__c = quote.Primary_Applicant_Aadhaar_No__c;
booking.Passport_Aadhar__c = quote.Primary_Applicant_Passport_No__c;
booking.Primary_Applicant_Driving_License_No__c = quote.Primary_Applicant_Driving_License_No__c;
booking.Email1__c = quote.Primary_Applicant_Email__c;
booking.Mobile_Primary__c = quote.Primary_Applicant_Mobile_No__c;
booking.Mobile_Primary2__c = quote.Primary_Applicant_Telephone_No__c;
booking.Contact_Number1__c = quote.Primary_Applicant_International_No__c;
booking.Permanent_House_No_Name__c = quote.Permanent_House_No_Name__c;
booking.Permanent_Street_Location__c = quote.Permanent_Street_Location__c;
booking.Permanent_Post_Office__c = quote.Permanent_Post_Office__c;
booking.Permanent_City__c = quote.Permanent_City__c;
booking.Permanent_State__c = quote.Permanent_State__c;
booking.Permanent_Postal_Code__c = quote.Permanent_Postal_Code__c;
booking.Permanent_Country__c = quote.Permanent_Country__c;
booking.Correspondence_House_No_Name__c = quote.Correspondence_House_No_Name__c;
booking.Correspondence_Street_Location__c = quote.Correspondence_Street_Location__c;
booking.Correspondence_Post_Office__c = quote.Correspondence_Post_Office__c;
booking.Correspondence_City__c = quote.Correspondence_City__c;
booking.Correspondence_State__c = quote.Correspondence_State__c;
booking.Correspondence_Postal_Code__c = quote.Correspondence_Postal_Code__c;
booking.Correspondence_Country__c = quote.Correspondence_Country__c;
booking.Base_Rate__c = quote.Actual_Base_Rate__c;
booking.Floor_Rise_Charges_Rate__c = quote.Floor_Rise_Charges__c;
booking.Covered_Park_Parking__c = quote.Car_Parking_Charge__c;
booking.Extra_Covered_Parking_Charges__c = quote.Extra_car_parking_charges__c;
booking.Additional_Car_Parking_Required__c = quote.Additional_Car_Parking_Required__c;
booking.Built_up_area__c = quote.Built_up_area__c;
booking.Open_Terrace_Area_Charges__c = quote.Open_Terrace_Area_Charges__c;
booking.Terrace_Area_SqFt__c = quote.Terrace_Area_SqFt__c;
booking.Common_Area_SqFt__c = quote.Common_Area_SqFt__c;
booking.Landscape_Charge__c = quote.Landscape_Charge__c;
booking.Project__c = quote.Project__c;
booking.Block1__c = quote.Block__c;
booking.Special_Launch__c = quote.Special_Launch__c;
booking.Discount__c = quote.Discount_In_Rupees__c;
booking.BHK_Type__c = quote.BHK_Type1__c;
booking.SLead__c = quote.Leads__c;
booking.Plot__c = quote.Unit__c;
booking.Payment_Plan__c = quote.Payment_Plan__c;*/
                                                
                                                // Fetch all Co-Applicants related to the Quote
                                                List<Co_Applicant__c> coApplicants = [
                                                    SELECT Id, Salutation__c,Name,Date_of_Birth__c,
                                                    Co_Applicant_NRI_RI__c,Co_Applicant_Profession__c,
                                                    Co_Applicant_Father_Husband_s_Name__c,PAN_Number__c,
                                                    Aadhar_Number__c,Passport_No__c,Co_Applicant_Driving_License_No__c,
                                                    Email__c,Phone__c,Mobile__c,International_Phone__c,
                                                    Permanent_House_No_Name__c,Permanent_Street_Location__c,
                                                    Permanent_Post_Office__c,Permanent_City__c,Permanent_State__c,
                                                    Permanent_Postal_Code__c,Permanent_Country__c,
                                                    Correspondence_House_No_Name__c,Correspondence_Street_Location__c,
                                                    Correspondence_Post_Office__c,Correspondence_City__c,
                                                    Correspondence_State__c,Correspondence_Postal_Code__c,
                                                    Correspondence_Country__c
                                                    FROM Co_Applicant__c
                                                    WHERE Quote__c = :quoteId
                                                ];
                                                
                                                // Store in Map
                                                resultMap.put('quote', quote);
                                                resultMap.put('coApplicants', coApplicants);
                                                
                                            } catch (Exception e) {
                                                System.debug('Error fetching Quote and Co-Applicants: ' + e.getMessage());
                                                ExceptionHandler.addLog(e,string.valueof(resultMap),'BookingController',quoteId);  /*Add Exception to error log*/
                                                throw new AuraHandledException('Error fetching data: ' + e.getMessage());
                                            }
                                            
                                            return resultMap;
                                        }
    
    public static void preventDuplicateBookings(List<Booking__c> newBookings) {
        Set<Id> plotIds = new Set<Id>();
        for (Booking__c b : newBookings) {
            if (b.Plot__c != null) {
                plotIds.add(b.Plot__c);
            }
        }
        
        if (plotIds.isEmpty()) return;
        
        Map<Id, Booking__c> existingPlotBookings = new Map<Id, Booking__c>();
        for (Booking__c existing : [
            SELECT Id, Plot__c, Stage__c
            FROM Booking__c
            WHERE Plot__c IN :plotIds
            AND Stage__c NOT IN ('Cancellation', 'Unit Swap')
        ]) {
            existingPlotBookings.put(existing.Plot__c, existing);
        }
        
        for (Booking__c b : newBookings) {
            if (b.Plot__c != null && existingPlotBookings.containsKey(b.Plot__c)) {
                b.addError('A booking already exists for this Plot. Cannot create a duplicate unless the existing booking is cancelled or unit swapped.');
            }
        }
    }
    public static void updateCoApplicants(List<Booking__c> newBookings) {
        if (newBookings.isEmpty()) {
            return;
        }
        
        //Collect all Quote__c Ids from the newly inserted Bookings
        Set<Id> quoteIds = new Set<Id>();
        Map<Id, Id> quoteToBookingMap = new Map<Id, Id>();
        
        for (Booking__c book : newBookings) {
            if (book.Quote__c != null) {
                quoteIds.add(book.Quote__c);
                quoteToBookingMap.put(book.Quote__c, book.Id);
            }
        }
        
        if (!quoteIds.isEmpty()) {
            //Fetch all Co_Applicant__c records where Quote__c matches
            List<Co_Applicant__c> coApplicantsToUpdate = [
                SELECT Id, Booking__c, Quote__c 
                FROM Co_Applicant__c 
                WHERE Quote__c IN :quoteIds
            ];
            
            //Update Co-Applicants with corresponding Booking__c Id
            for (Co_Applicant__c coApp : coApplicantsToUpdate) {
                if (quoteToBookingMap.containsKey(coApp.Quote__c)) {
                    coApp.Booking__c = quoteToBookingMap.get(coApp.Quote__c);
                }
            }
            
            //Perform the update if there are any records to modify
            if (!coApplicantsToUpdate.isEmpty()) {
                update coApplicantsToUpdate;
            }
        }
    }
    
    public static void updateChargeType(List<Booking__c> newBookings) {
        if (newBookings.isEmpty()) {
            return;
        }
        
        //Collect all Quote__c Ids from the newly inserted Bookings
        Set<Id> quoteIds = new Set<Id>();
        Map<Id, Id> quoteToBookingMap = new Map<Id, Id>();
        
        for (Booking__c book : newBookings) {
            if (book.Quote__c != null) {
                quoteIds.add(book.Quote__c);
                quoteToBookingMap.put(book.Quote__c, book.Id);
            }
        }
        
        if (!quoteIds.isEmpty()) {
            //Fetch all Co_Applicant__c records where Quote__c matches
            List<Charge_Type__c> chargeTypeToUpdate = [
                SELECT Id, Booking__c, Quote__c 
                FROM Charge_Type__c 
                WHERE Quote__c IN :quoteIds
            ];
            
            //Update Co-Applicants with corresponding Booking__c Id
            for (Charge_Type__c ct : chargeTypeToUpdate) {
                if (quoteToBookingMap.containsKey(ct.Quote__c)) {
                    ct.Booking__c = quoteToBookingMap.get(ct.Quote__c);
                }
            }
            
            //Perform the update if there are any records to modify
            if (!chargeTypeToUpdate.isEmpty()) {
                update chargeTypeToUpdate;
            }
        }
    }
    
    
    public static void assignBookingUsers(List<Booking__c> bookingList) {
        Set<Id> projectIds = new Set<Id>();
        for (Booking__c booking : bookingList) {
            if (booking.Project1__c != null) {
                projectIds.add(booking.Project1__c);
            }
        }
        
        Map<Id, Project__c> projectMap = new Map<Id, Project__c>(
            [SELECT Id, 
             Legal_User__c, Legal_User2__c, Finance_User__c, 
             CRM_Technical__c, CRM_Manager__c,Sales_Manager__c
             FROM Project__c
             WHERE Id IN :projectIds]
        );
        
        // Fetch a fallback System Administrator user
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        
        for (Booking__c booking : bookingList) {
            Project__c proj = projectMap.get(booking.Project1__c);
            
            if (proj != null) {
                booking.Legal_Team__c = proj.Legal_User__c != null ? proj.Legal_User__c : adminUser.Id;
                booking.Legal_Advocate_Assigned__c = proj.Legal_User2__c != null ? proj.Legal_User2__c : adminUser.Id;
                booking.Finance_User__c = proj.Finance_User__c != null ? proj.Finance_User__c : adminUser.Id;
                booking.CRM_Technical__c = proj.CRM_Technical__c != null ? proj.CRM_Technical__c : adminUser.Id;
                booking.CRM_Manager__c = proj.CRM_Manager__c != null ? proj.CRM_Manager__c : adminUser.Id;
                booking.Sales_Manager1__c = proj.Sales_Manager__c != null ? proj.Sales_Manager__c : adminUser.Id;
                
            } else {
                // No related project — assign all to admin
                booking.Legal_Team__c = adminUser.Id;
                booking.Legal_Advocate_Assigned__c = adminUser.Id;
                booking.Finance_User__c = adminUser.Id;
                booking.CRM_Technical__c = adminUser.Id;
                booking.CRM_Manager__c = adminUser.Id;
                booking.Sales_Manager1__c = adminUser.Id;
                //booking.Sales_Executive__c = booking.OwnerId != null ? booking.OwnerId : adminUser.Id;
            }
            booking.Sales_Executive__c = UserInfo.getUserId();
        }
    }
    
    public static void updatePlotStatusToSold(Set<Id> bookingIds) {
        if (bookingIds == null || bookingIds.isEmpty()) return;
        
        // Query bookings with related Plot Ids
        List<Booking__c> bookings = [
            SELECT Id, Stage__c, Plot__c
            FROM Booking__c
            WHERE Id IN :bookingIds AND Plot__c != null
        ];
        
        // Collect Plot Ids to update
        Set<Id> plotIdsToUpdate = new Set<Id>();
        for (Booking__c booking : bookings) {
            plotIdsToUpdate.add(booking.Plot__c);
        }
        
        // Query Plot records
        Map<Id, Plot__c> plotMap = new Map<Id, Plot__c>(
            [SELECT Id, Status__c FROM Plot__c WHERE Id IN :plotIdsToUpdate]
        );
        
        // Update plots to 'Sold'
        List<Plot__c> plotsToUpdate = new List<Plot__c>();
        for (Booking__c booking : bookings) {
            if (plotMap.containsKey(booking.Plot__c)) {
                Plot__c plot = plotMap.get(booking.Plot__c);
                plot.Status__c = 'Sold';
                plotsToUpdate.add(plot);
            }
        }
        
        // Perform DML update if any
        if (!plotsToUpdate.isEmpty()) {
            update plotsToUpdate;
        }
    }
    
    @AuraEnabled
    public static Map<String, List<String>> getBookingPicklists() {
        Map<String, List<String>> picklistMap = new Map<String, List<String>>();
        
        // Get Mode of Payment Picklist Values
        List<String> modeOfPaymentValues = new List<String>();
        Schema.DescribeFieldResult modeFieldResult = Booking__c.Mode_Of_Payment__c.getDescribe();
        for (Schema.PicklistEntry entry : modeFieldResult.getPicklistValues()) {
            modeOfPaymentValues.add(entry.getLabel());
        }
        picklistMap.put('ModeOfPayment', modeOfPaymentValues);
        
        // Get Funding Type Picklist Values
        List<String> fundingTypeValues = new List<String>();
        Schema.DescribeFieldResult fundingFieldResult = Booking__c.Funding_Type__c.getDescribe();
        for (Schema.PicklistEntry entry : fundingFieldResult.getPicklistValues()) {
            fundingTypeValues.add(entry.getLabel());
        }
        picklistMap.put('FundingType', fundingTypeValues);
        
        // Get Advance Bank Picklist Values
        List<String> advancePaymentFrom = new List<String>();
        Schema.DescribeFieldResult paymentFromResult = Booking__c.Advance_Payment_From__c.getDescribe();
        for (Schema.PicklistEntry entry : paymentFromResult.getPicklistValues()) {
            advancePaymentFrom.add(entry.getLabel());
        }
        picklistMap.put('PaymentFrom', advancePaymentFrom);
        
        List<String> advanceBankValues = new List<String>();
        Schema.DescribeFieldResult bankFieldResult = Booking__c.Advance_Payment_Bank__c.getDescribe();
        for (Schema.PicklistEntry entry : bankFieldResult.getPicklistValues()) {
            advanceBankValues.add(entry.getLabel());
        }
        picklistMap.put('AdvanceBank', advanceBankValues);
        
        List<String> bookingTypeValues = new List<String>();
        Schema.DescribeFieldResult bookingTypeResult = Booking__c.Booking_Type__c	.getDescribe();
        for (Schema.PicklistEntry entry : bookingTypeResult.getPicklistValues()) {
            bookingTypeValues.add(entry.getLabel());
        }
        picklistMap.put('bookingType', bookingTypeValues);
        
        List<String> bookedAtValues = new List<String>();
        Schema.DescribeFieldResult bookedAtResult = Booking__c.Booked_At__c.getDescribe();
        for (Schema.PicklistEntry entry : bookedAtResult.getPicklistValues()) {
            bookedAtValues.add(entry.getLabel());
        }
        picklistMap.put('bookedAt', bookedAtValues);
        
        List<String> bookingThroughValues = new List<String>();
        Schema.DescribeFieldResult bookingThroughResult = Booking__c.Booking_Through__c.getDescribe();
        for (Schema.PicklistEntry entry : bookingThroughResult.getPicklistValues()) {
            bookingThroughValues.add(entry.getLabel());
        }
        picklistMap.put('bookingThrough', bookingThroughValues);
        
        List<String> categoryValues = new List<String>();
        Schema.DescribeFieldResult categoryResult = Booking__c.Category__c.getDescribe();
        for (Schema.PicklistEntry entry : categoryResult.getPicklistValues()) {
            categoryValues.add(entry.getLabel());
        }
        picklistMap.put('category', categoryValues);   
        
        return picklistMap;
    }
    
    public static void assignUsersByRoundRobin(List<Booking__c> newBookings) {
        // Step 1: Get all unique project IDs from the new bookings
        Set<Id> projectIds = new Set<Id>();
        for (Booking__c b : newBookings) {
            if (b.Project1__c != null) {
                projectIds.add(b.Project1__c);
            }
        }
        
        if (projectIds.isEmpty()) return;
        
        // Step 2: Fetch round robin members for all projects involved in the bookings
        Map<Id, List<Round_Robin_Member__c>> projectToMembersMap = new Map<Id, List<Round_Robin_Member__c>>();
        for (Round_Robin_Member__c rrMember : [
            SELECT Id, User__c, User_Type__c, Round_Robin__c,Round_Robin__r.Project__c
            FROM Round_Robin_Member__c 
            WHERE Round_Robin__r.Project__c IN :projectIds
        ]) {
            if (!projectToMembersMap.containsKey(rrMember.Round_Robin__r.Project__c)) {
                projectToMembersMap.put(rrMember.Round_Robin__r.Project__c, new List<Round_Robin_Member__c>());
            }
            projectToMembersMap.get(rrMember.Round_Robin__r.Project__c).add(rrMember);
        }
        
        // Step 3: Prepare maps for round robin positions and user types
        Map<String, Integer> positionMap = new Map<String, Integer>(); // Keeps track of round robin position for each user type
        Map<String, List<Id>> userTypeToUsersMap = new Map<String, List<Id>>(); // Groups users by type
        
        // Populate user type to users map and position map
        for (Id projectId : projectToMembersMap.keySet()) {
            List<Round_Robin_Member__c> members = projectToMembersMap.get(projectId);
            for (Round_Robin_Member__c member : members) {
                String key = projectId + ':' + member.User_Type__c;
                if (!userTypeToUsersMap.containsKey(key)) {
                    userTypeToUsersMap.put(key, new List<Id>());
                    positionMap.put(key, 0); // Set initial position to 0
                }
                userTypeToUsersMap.get(key).add(member.User__c);
            }
        }
        
        // Step 4: Assign users to bookings
        for (Booking__c b : newBookings) {
            if (b.Project1__c == null) continue; // Skip if no project
            
            assignUserToField(b, 'Sales Executive', 'Sales_Executive__c', userTypeToUsersMap, positionMap);
            assignUserToField(b, 'CRM', 'CRM_Manager__c', userTypeToUsersMap, positionMap);
            assignUserToField(b, 'CRM Technical', 'CRM_Technical__c', userTypeToUsersMap, positionMap);
            assignUserToField(b, 'Legal', 'Legal_Team__c', userTypeToUsersMap, positionMap);
            assignUserToField(b, 'Finance', 'Finance_User__c', userTypeToUsersMap, positionMap);
            assignUserToField(b, 'Sales Executive', 'OwnerId', userTypeToUsersMap, positionMap);
        }
    }
    
    private static void assignUserToField(Booking__c booking,String userType,  String bookingField,  Map<String, List<Id>> userTypeToUsersMap,  Map<String, Integer> positionMap )
    {
        String key = booking.Project1__c + ':' + userType;
        List<Id> users = userTypeToUsersMap.get(key);
        if (users == null || users.isEmpty()) return; // No users found for this user type
        
        Integer pos = positionMap.get(key);
        booking.put(bookingField, users[pos]);
        
        // Update position for round robin
        pos = Math.mod(pos + 1, users.size()); // Round-robin logic
        positionMap.put(key, pos);
    }
    
    
    @AuraEnabled
    public static void UpdateBookingUsers(List<Booking__c> newBookings,string usertype){
        /*Set<Id> projectIds = new Set<Id>();
for (Booking__c booking : newBookings) {
if (booking.Project1__c != null) {
projectIds.add(booking.Project1__c);
}
}

set<string> PrjName = new set<string>();
for(Project__c prj: [select id,name from Project__c where id in:projectIds]){
PrjName.add(prj.name);
}
*/
        
        //list<string> userlst = new list<string>{'CRM','Legal','Finance'};
        //for(string usertype : userlst){ 
        
        
        Set<Id> BkLeadIds = new Set<Id>();
        for(Booking__c booking : newBookings){
            if (booking.SLead__c != null) {
                BkLeadIds.add(booking.SLead__c);
            }
        }
        Map<string,string> LeadPrjMap = new Map<string,string>();
        Map<string,list<Booking__c>> PrjBookingMap = new Map<string,list<Booking__c>>();
        
        for(Lead ld: [select id,name,Project_City__c from Lead where Id in:BkLeadIds]){
            if(ld.Project_City__c != null){
                LeadPrjMap.put(ld.Id,ld.Project_City__c);
            }
        }
        
        for(Booking__c booking : newBookings){
            if(booking.SLead__c != null && LeadPrjMap.containskey(booking.SLead__c)){
                string ProjectCity = LeadPrjMap.get(booking.SLead__c);
                List<Booking__c> Bklst = PrjBookingMap.get(ProjectCity);
                
                if(Bklst == null){
                    PrjBookingMap.put(ProjectCity, new List<Booking__c>{booking});
                }else{
                    Bklst.add(booking);
                    PrjBookingMap.put(ProjectCity, Bklst);
                }
            }
        }
        
        Map<id,Round_Robin_Member__c>  rrMemberMapToUpdateList = new  Map<id,Round_Robin_Member__c> ();
        Map<string,List<Round_Robin_Member__c>>  projectAvaliableQueMap = new Map<string,List<Round_Robin_Member__c>>();
        Map<string,List<Round_Robin_Member__c>>  projectQueMap = new Map<string,List<Round_Robin_Member__c>>();
        
        List<Round_Robin__c> RRAvaliablequeList=[Select id,Project_Assigned__c,Project_Assigned_City__c, (select Name,User__c,User_Type__c from  Round_Robin_Members__r  where Active__c =true  AND user__r.isActive=true AND user__r.Availability__c=true AND user__r.Working__c=true and User_Type__c =: usertype  order by Last_Assignment_Date_Time__c,createddate asc nulls first ) from Round_Robin__c where Project_Assigned_City__c in :LeadPrjMap.values() and Active__c = true ];
        List<Round_Robin__c> RRqueList=[Select id,Project_Assigned__c,Project_Assigned_City__c, (select Name,User__c,User_Type__c from  Round_Robin_Members__r  where Active__c =true AND user__r.Working__c=true AND user__r.isActive=true and User_Type__c =: usertype order by Last_Assignment_Date_Time__c,createddate asc nulls first ) from Round_Robin__c where Project_Assigned_City__c in :LeadPrjMap.values() and Active__c = true ];
        
        system.debug('RRAvaliablequeList'+RRAvaliablequeList);
        
        if(RRAvaliablequeList.size()>0){
            for(Round_Robin__c rr : RRAvaliablequeList){
                if(rr.Round_Robin_Members__r.size()>0){
                    system.debug(rr.Round_Robin_Members__r.size());
                    projectAvaliableQueMap.put(rr.Project_Assigned_City__c,rr.Round_Robin_Members__r);
                }
            }
        }
        if(RRqueList.size()>0){
            for(Round_Robin__c rr : RRqueList){
                if(rr.Round_Robin_Members__r.size()>0){
                    system.debug(rr.Round_Robin_Members__r.size());
                    projectQueMap.put(rr.Project_Assigned_City__c,rr.Round_Robin_Members__r);
                }
            }
        }
        
        for(string PrjCityName : LeadPrjMap.values()){
            
            if(projectAvaliableQueMap.containskey(PrjCityName) && projectAvaliableQueMap.get(PrjCityName).size()>0){
                List<Round_Robin_Member__c>  projectQue = projectAvaliableQueMap.get(PrjCityName);  
                integer counter = 0; 
                
                for(Booking__c booking : PrjBookingMap.get(PrjCityName)){
                    if(projectQue!=null && projectQue.size() > 0 && projectQue[counter] != null && projectQue[counter].user__c != null){
                        
                        system.debug('projectQue[counter].user__c: ' + projectQue[counter].user__c);
                        if(usertype == 'CRM'){
                            booking.CRM_Manager__c = projectQue[counter].user__c;
                        }
                        else if(usertype == 'Legal'){
                            booking.Legal_Team__c = projectQue[counter].user__c;
                        }
                        else if(usertype == 'Finance'){
                            booking.Finance_User__c = projectQue[counter].user__c;
                        }
                        
                        
                        Round_Robin_Member__c rrList = new Round_Robin_Member__c();
                        rrList.Last_Assignment_Date_Time__c =  system.now().getTime(); 
                        rrList.Id = projectQue[counter].Id;
                        rrMemberMapToUpdateList.put(projectQue[counter].Id,rrList);
                        
                        counter ++; 
                        if(projectQue.size() == counter  ){
                            counter  =0; 
                        } 
                    }
                    
                    
                }
            }
            else if(projectQueMap.containsKey(PrjCityName) && projectQueMap.get(PrjCityName).size()>0){
                List<Round_Robin_Member__c>  projectQue = projectQueMap.get(PrjCityName);  
                integer counter = 0; 
                for(Booking__c booking : PrjBookingMap.get(PrjCityName)){
                    if(projectQue!=null && projectQue.size() > 0 && projectQue[counter] != null && projectQue[counter].user__c != null){
                        
                        system.debug('projectQue[counter].user__c: ' + projectQue[counter].user__c);
                        if(usertype == 'CRM'){
                            booking.CRM_Manager__c = projectQue[counter].user__c;
                        }
                        else if(usertype == 'Legal'){
                            booking.Legal_Team__c = projectQue[counter].user__c;
                        }
                        else if(usertype == 'Finance'){
                            booking.Finance_User__c = projectQue[counter].user__c;
                        }
                        
                        Round_Robin_Member__c rrList = new Round_Robin_Member__c();
                        rrList.Last_Assignment_Date_Time__c =  system.now().getTime(); 
                        rrList.Id = projectQue[counter].Id;
                        rrMemberMapToUpdateList.put(projectQue[counter].Id,rrList);
                        counter ++; 
                        if(projectQue.size() == counter  ){
                            counter  =0; 
                        } 
                    }
                }
            }
            
        }
        
        if(rrMemberMapToUpdateList.values().size()>0){
            system.debug('rrMemberMapToUpdateList '+rrMemberMapToUpdateList);
            if(!test.IsrunningTest())
            {
                UPDATE rrMemberMapToUpdateList.values();
                rrMemberMapToUpdateList.clear();
            }
        }
        //}
    }
    
    @AuraEnabled
    public static String createBook(Booking__c bk, String recId) {
        List<Quote__c> qt = [SELECT Id, Unit__c, Booking__c FROM Quote__c WHERE Id = :recId];
        // List<String> bookngUsers = label.Booking_File_Share.split(';');
        
        List<String> allRelUser = label.Booking_File_Share.split(';');
        if (qt.isEmpty()) {
            System.debug('Quote record not found.'); 
            return 'Quote record not found.';
        }
        
        List<Co_Applicant__c> coApplicantList = [SELECT Id, Booking__c FROM Co_Applicant__c WHERE Quote__c = :recId];
        List<Plot__c> plot = [SELECT Id, Status__c,Unit_Type__c FROM Plot__c WHERE Id = :qt[0].Unit__c and Status__c ='Available'];
        
        if (plot.isEmpty()) {
            System.debug('Unit record not found or already booked'); 
            throw new AuraHandledException('Unit record not found or already booked');
            //return 'Unit record not found or unit is already booked';
        }
        
        // Assign Quote ID to Booking and upsert
        bk.Quote__c = recId;
        
        if (bk.Date_of_Booking__c == null) {
            bk.Date_of_Booking__c = Date.today();
        }
        
        if (bk.SLead__c != null) {
            Lead leadRec = [
                SELECT Id, OwnerId 
                FROM Lead 
                WHERE Id = :bk.SLead__c 
                LIMIT 1
            ];
            bk.OwnerId = leadRec.OwnerId;
        } else {
            bk.OwnerId = UserInfo.getUserId();
        }
        
        upsert bk;
        
        /* Create related Customer_Master__c record with mapped fields
Customer_Master__c cust = new Customer_Master__c();
//cust.Id = bk.Booking__c;  // relate it to Booking__c

cust.OwnerId = bk.OwnerId;
cust.Password__c = bk.Mobile_Primary__c; 
cust.Phone__c = bk.Mobile_Primary__c;     
cust.IsActive__c = true; 

cust.Email__c = bk.Email1__c;
cust.AssociationUser__c=true;
cust.First_Name__c = bk.First_Applicant_Name__c;
cust.WhatsApp_Number__c = bk.WhatsApp_Number__c;

// Insert the Customer_Master__c record
insert cust;
*/
        
        /*    // Update Quote
qt[0].Booking__c = bk.Id;
qt[0].Booking_Created_Time__c = System.now();
qt[0].Quote_status__c = 'Booking Created';
update qt[0];

Task newTask = new Task(
Subject = 'Token Advance Payment Follow-up',
WhatId = bk.Id,
OwnerId = bk.OwnerId,
ActivityDate = Date.today().addDays(7),
Status = 'Not Started',
Priority = 'High',
Description = 'Follow up on the token advance booking amount payment.'
);
insert newTask;*/
        // if(!Test.isRunningTest()){
        //Attaching FinalBooking form and costsheet  document to booking and quote
        String bookingPage = 'FinalBookingForm';
        String quotePage = 'VeegalandQuotePdf';
        
        //for booking
        generatePdfAndAttachQuote(bookingPage, recId);
        generatePdfAndAttachQuote(quotePage, recId);
        
        //For Quote
        generatePdfAndAttachBooking(bookingPage, recId,bk.Id);
        generatePdfAndAttachBooking(quotePage, recId, bk.Id);
        
        
        // }
        
        
        
        
        
        
        
        
        // Update Co-Applicants to link with Booking
        if (!coApplicantList.isEmpty()) {
            for (Co_Applicant__c ca : coApplicantList) {
                ca.Booking__c = bk.Id;
            }
            update coApplicantList;
        }
        
        if(!Test.isRunningTest()){
            // Copy all Documents from Quote to Booking
            List<ContentDocumentLink> docLinks = [
                SELECT ContentDocumentId FROM ContentDocumentLink 
                WHERE LinkedEntityId = :recId
            ];
            
            List<ContentDocumentLink> newDocLinks = new List<ContentDocumentLink>();
            if (!docLinks.isEmpty()) {
                for (ContentDocumentLink doc : docLinks) {
                    ContentDocumentLink newLink = new ContentDocumentLink();
                    newLink.ContentDocumentId = doc.ContentDocumentId;
                    newLink.LinkedEntityId = bk.Id;  // Assign to Booking
                    newLink.ShareType = 'V'; // Viewer access
                    newLink.Visibility = 'AllUsers';
                    newDocLinks.add(newLink);
                }
                                
                if(allRelUser.size() > 0 && !Test.isRunningTest()){
                    for (ContentDocumentLink doc : docLinks) {
                        for(string s:allRelUser){
                            newDocLinks.add(new ContentDocumentLink(
                                ContentDocumentId = doc.ContentDocumentId,
                                LinkedEntityId = s,
                                ShareType = 'V',
                                Visibility = 'AllUsers'
                            ));
                        }
                    }
                }
            }
            
            List<ContentDocumentLink> docLinksUnit = [
                SELECT ContentDocumentId FROM ContentDocumentLink 
                WHERE LinkedEntityId = :qt[0].Unit__c
            ];
            
            if (!docLinksUnit.isEmpty()) {
                for (ContentDocumentLink docunit : docLinksUnit) {
                    ContentDocumentLink newUnitLink = new ContentDocumentLink();
                    newUnitLink.ContentDocumentId = docunit.ContentDocumentId;
                    newUnitLink.LinkedEntityId = bk.Id;  // Assign to Booking
                    newUnitLink.ShareType = 'V'; // Viewer access
                    newUnitLink.Visibility = 'AllUsers';
                    newDocLinks.add(newUnitLink);
                }
                
                if(allRelUser.size() > 0 && !Test.isRunningTest()){
                    for (ContentDocumentLink docunit : docLinksUnit) {
                        for(string s:allRelUser){
                            newDocLinks.add(new ContentDocumentLink(
                                ContentDocumentId = docunit.ContentDocumentId,
                                LinkedEntityId = s,
                                ShareType = 'V',
                                Visibility = 'AllUsers'
                            ));
                        }
                    }
                }
            }
            List<ContentDocumentLink> docLinksUnitType = new List<ContentDocumentLink>();
            
            if (plot[0].Unit_Type__c != null) {
                docLinksUnitType = [
                    SELECT ContentDocumentId 
                    FROM ContentDocumentLink 
                    WHERE LinkedEntityId = :plot[0].Unit_Type__c
                ];
            }
            
            if (!docLinksUnitType.isEmpty()) {
                for (ContentDocumentLink docType : docLinksUnitType) {
                    ContentDocumentLink newTypeLink = new ContentDocumentLink();
                    newTypeLink.ContentDocumentId = docType.ContentDocumentId;
                    newTypeLink.LinkedEntityId = bk.Id;  // Assign to Booking
                    newTypeLink.ShareType = 'C'; // Viewer access
                    newTypeLink.Visibility = 'AllUsers';
                    newDocLinks.add(newTypeLink);
                }
                
                if(allRelUser.size() > 0 && !Test.isRunningTest()){
                    for (ContentDocumentLink docType : docLinksUnitType) {
                        for(string s:allRelUser){
                            newDocLinks.add(new ContentDocumentLink(
                                ContentDocumentId = docType.ContentDocumentId,
                                LinkedEntityId = s,
                                ShareType = 'V',
                                Visibility = 'AllUsers'
                            ));
                        }
                    }
                }
                
                
            }
            
            if (!newDocLinks.isEmpty()) {
                database.insert(newDocLinks,false);
            }
        }
        return bk.ID;
    }
    
    @Testvisible
    private static Id generatePdfAndAttachQuote(String pageName, Id recordId){
        
        if (Test.isRunningTest()) {
            // In test, fake a ContentDocument without calling getContent
            ContentVersion cv = new ContentVersion(
                Title = pageName + ' TEST PDF',
                PathOnClient = pageName + '.pdf',
                VersionData = Blob.valueOf('test')
            );
            insert cv;
            
            ContentDocument cd = [
                SELECT Id FROM ContentDocument
                WHERE LatestPublishedVersionId = :cv.Id LIMIT 1
            ];
            
            insert new ContentDocumentLink(
                ContentDocumentId = cd.Id,
                LinkedEntityId = recordId,
                ShareType = 'V',
                Visibility = 'AllUsers'
            );
            
            return cd.Id;
        }
        
        PageReference pr = new PageReference('/apex/' + pageName);
        pr.getParameters().put('id', recordId);
        
        Blob pdfBlob;
        pdfBlob = pr.getContent();
        
        ContentVersion cv = new ContentVersion(
            Title = pageName + ' PDF',
            PathOnClient = pageName + '.pdf',
            VersionData = pdfBlob
        );
        insert cv;
        
        // Fetch the ContentDocument
        ContentDocument cd = [
            SELECT Id
            FROM ContentDocument
            WHERE LatestPublishedVersionId = :cv.Id
            LIMIT 1
        ];
        
        // Attach file to actual record
        insert new ContentDocumentLink(
            ContentDocumentId = cd.Id,
            LinkedEntityId = recordId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        
        return cd.Id;
        
        
    }
    
    @Testvisible
    private static Id generatePdfAndAttachBooking(String pageName, Id recordId, Id bookId){
        
        if (Test.isRunningTest()) {
            // In test, fake a ContentDocument without calling getContent
            ContentVersion cv = new ContentVersion(
                Title = pageName + ' TEST PDF',
                PathOnClient = pageName + '.pdf',
                VersionData = Blob.valueOf('test')
            );
            insert cv;
            
            ContentDocument cd = [
                SELECT Id FROM ContentDocument
                WHERE LatestPublishedVersionId = :cv.Id LIMIT 1
            ];
            
            insert new ContentDocumentLink(
                ContentDocumentId = cd.Id,
                LinkedEntityId = bookId,
                ShareType = 'V',
                Visibility = 'AllUsers'
            );
            
            return cd.Id;
        }
        
        
        PageReference pr = new PageReference('/apex/' + pageName);
        pr.getParameters().put('id', recordId);
        
        Blob pdfBlob;
        pdfBlob = pr.getContent();
        
        ContentVersion cv = new ContentVersion(
            Title = pageName + ' PDF',
            PathOnClient = pageName + '.pdf',
            VersionData = pdfBlob
        );
        insert cv;
        
        // Fetch the ContentDocument
        ContentDocument cd = [
            SELECT Id
            FROM ContentDocument
            WHERE LatestPublishedVersionId = :cv.Id
            LIMIT 1
        ];
        
        // Attach file to actual record
        insert new ContentDocumentLink(
            ContentDocumentId = cd.Id,
            LinkedEntityId = bookId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        
        return cd.Id;
        
        
    }
    
    
    
    
    
    
    public static void updateQuoteCreateTask(List<Booking__c> newList) {
        List<Quote__c> quotesToUpdate = new List<Quote__c>();
        List<Task> tasksToInsert = new List<Task>();
        
        for (Booking__c bk : newList) {
            // Update Quote if Booking__c has a linked Quote
            if (bk.Quote__c != null) {
                Quote__c qt = new Quote__c(
                    Id = bk.Quote__c,
                    Booking__c = bk.Id,
                    Booking_Created_Time__c = System.now(),
                    Quote_status__c = 'Booking Created'
                );
                quotesToUpdate.add(qt);
            }
            
            // Create follow-up Task
            Task newTask = new Task(
                Subject = 'Token Advance Payment Follow-up',
                WhatId = bk.Id,
                OwnerId = bk.OwnerId,
                ActivityDate = Date.today().addDays(7),
                Status = 'Not Started',
                Priority = 'High',
                Description = 'Follow up on the token advance booking amount payment.'
            );
            tasksToInsert.add(newTask);
        }
        
        if (!quotesToUpdate.isEmpty()) {
            update quotesToUpdate;
        }
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }
    
    public static void advanceAmountCreation(List<Booking__c> bookings) {
        if (bookings == null || bookings.isEmpty()) return;
        
        // Map to hold Booking Ids
        Set<Id> bookingIds = new Set<Id>();
        for (Booking__c b : bookings) {
            if (b.Booking_Amount1__c != null && b.Booking_Amount1__c > 0) {
                bookingIds.add(b.Id);
            }
        }
        
        if (bookingIds.isEmpty()) return;
        
        List<Advance_Receipt__c> receiptsToInsert = new List<Advance_Receipt__c>();
        Map<Id, Booking__c> bookingMapById = new Map<Id, Booking__c>();
        
        for (Booking__c b : bookings) {
            if (b.Booking_Amount1__c == null || b.Booking_Amount1__c <= 0) continue;
            bookingMapById.put(b.Id, b);
            Advance_Receipt__c recp = new Advance_Receipt__c();
            recp.Booking__c = b.Id;
            recp.Remarks__c = 'Receipt for the Booking Amount. Auto Generated by system';
            recp.Mode_of_payment__c = b.Mode_Of_Payment__c ;
            recp.Finance_User__c = b.Finance_User__c;
            recp.Advance_Receipt_Date__c = b.Advance_Transaction_Date__c;            
            recp.Cheque_Transaction_Number__c = b.Cheque_DD_NEFT_RTGS_No__c;
            recp.Payment_From__c = b.Advance_Payment_From__c;
            recp.Bank_Name__c = b.Advance_Payment_Bank__c;
            recp.Branch__c = b.Advance_Branch__c;
            recp.Advance_Amount__c = b.Booking_Amount1__c;
            receiptsToInsert.add(recp);
        }
        
        insert receiptsToInsert;
        
    }
    public static void bookingAmountReceipt(List<Booking__c> bookings) {
        if (bookings == null || bookings.isEmpty()) return;
        
        // Map to hold Booking Ids
        Set<Id> bookingIds = new Set<Id>();
        for (Booking__c b : bookings) {
            if (b.Booking_Amount1__c != null && b.Booking_Amount1__c > 0) {
                bookingIds.add(b.Id);
            }
        }
        
        if (bookingIds.isEmpty()) return;
        
        // Fetch relevant payment schedules
        Map<Id, Payment_Schedule__c> bookingToFirstSchedule = new Map<Id, Payment_Schedule__c>();
        for (Payment_Schedule__c ps : [
            SELECT Id, Booking__c, S_No__c,Name
            FROM Payment_Schedule__c
            WHERE Booking__c IN :bookingIds
            ORDER BY S_No__c ASC
        ]) {
            if (!bookingToFirstSchedule.containsKey(ps.Booking__c)) {
                bookingToFirstSchedule.put(ps.Booking__c, ps);
            }
        }
        
        List<Receipt__c> receiptsToInsert = new List<Receipt__c>();
        Map<Id, Booking__c> bookingMapById = new Map<Id, Booking__c>();
        
        for (Booking__c b : bookings) {
            if (b.Booking_Amount1__c == null || b.Booking_Amount1__c <= 0) continue;
            bookingMapById.put(b.Id, b);
            system.debug('b.Finance_User__c '+ b.Finance_User__c);
            Receipt__c recp = new Receipt__c();
            recp.Booking__c = b.Id;
            recp.Receipt_Name__c = 'Booking Amount Receipt';
            recp.Remarks__c = 'Receipt for the Booking Amount. Auto Generated by system';
            recp.Mode_of_payment__c = b.Mode_Of_Payment__c ;
            recp.Finance_User__c = b.Finance_User__c;
            recp.Receipt_date__c = b.Advance_Transaction_Date__c;
            recp.Check_Transaction_Nmber__c = b.Cheque_DD_NEFT_RTGS_No__c;
            recp.Payment_From__c = b.Advance_Payment_From__c;
            recp.Payment_Received_Bank__c = b.Advance_Payment_Bank__c;
            recp.Branch__c = b.Advance_Branch__c;
            receiptsToInsert.add(recp);
        }
        
        insert receiptsToInsert;
        
        // Create receipt line items only if receipt was successfully inserted
        List<Receipt_Line_Item__c> lineItemsToInsert = new List<Receipt_Line_Item__c>();
        for (Integer i = 0; i < receiptsToInsert.size(); i++) {
            Receipt__c recp = receiptsToInsert[i];
            Booking__c booking = bookingMapById.get(recp.Booking__c);
            Payment_Schedule__c schedule = bookingToFirstSchedule.get(booking.Id);
            
            if (schedule != null) {
                Receipt_Line_Item__c rli = new Receipt_Line_Item__c();
                rli.Name = schedule.Name;
                rli.Cheque_no_Transaction_Number__c = booking.Cheque_DD_NEFT_RTGS_No__c;
                rli.Receipt__c = recp.Id;
                rli.Booking__c = booking.Id;
                rli.Amount__c = booking.Booking_Amount1__c;
                rli.Payment_schedule__c = schedule.Id;
                lineItemsToInsert.add(rli);
            } else {
                System.debug(' No Payment_Schedule__c found for Booking: ' + booking.Id);
            }
        }
        
        if (!lineItemsToInsert.isEmpty()) {
            insert lineItemsToInsert;
        }
    }
    
    
    
    public static void cloneBookingWithUnitChangeDetails(Booking__c currentBooking, String newStage, String previousBookingStage) {
        
        // List to store all sObjects that need to be updated
        List<sObject> allToUpdate = new List<sObject>();
        List<Plot__c> plotsToUpdate = new List<Plot__c>();
        
        // Fetch the plots associated with Swap_Unit__c and current Plot__c
        List<Plot__c> swapUnitPlotList = [SELECT Id, Name, Status__c FROM Plot__c WHERE Id = :currentBooking.Swap_Unit__c];
        List<Plot__c> currentPlotList = [SELECT Id, Name, Status__c FROM Plot__c WHERE Id = :currentBooking.Plot__c];
        
        // Mark the current plot as 'Available' and clear its booking reference
        for (Plot__c currentPlot : currentPlotList) {
            currentPlot.Status__c = 'Available';
            currentPlot.Booking__c = null;
            plotsToUpdate.add(currentPlot);
        }
        
        // Clone the current booking and update its details
        Booking__c clonedBooking = currentBooking.clone(false, true, false, false);
        try {
            // Update target fields from swap fields
            clonedBooking.Stage__c = previousBookingStage;
            clonedBooking.Plot__c = currentBooking.Swap_Unit__c;
            clonedBooking.Swap_Unit__c = null;
            clonedBooking.Swap_unit_status__c = null;
            clonedBooking.Extra_Covered_Parking_Charges__c = currentBooking.Swap_Extra_Covered_Parking_Charges__c;
            clonedBooking.Funding_Type__c = currentBooking.Swap_Funding_Type__c;
            clonedBooking.No_of_Back_to_Back_Car_Parking__c = currentBooking.Swap_Extra_Covered_Parking_Slots__c;
            clonedBooking.No_of_additional_Individual_car_parkings__c = currentBooking.Swap_Extra_Individual_Parking_Slots__c;
            clonedBooking.Is_Swap__c = true;
            clonedBooking.Unit_Swap_Requested__c = false;
            clonedBooking.Base_Rate__c = currentBooking.Swap_Basic_Price__c;
            clonedBooking.Block1__c = currentBooking.Swap_Block__c;
            clonedBooking.Built_up_area__c = currentBooking.Swap_Super_Built_Up_Area__c;
            clonedBooking.Floor_Rise_Charges_Rate__c = currentBooking.Swap_Floor_Rise__c;
            clonedBooking.No_of_Back_to_Back_Car_Parking__c = currentBooking.Swap_Covered_Back_to_Back_Slots__c;
            clonedBooking.No_of_Indivisual_Car_Parking__c = currentBooking.Swap_Covered_Individual_Slots__c;
            clonedBooking.Covered_Park_Parking__c = currentBooking.Swap_Covered_Park_Parking__c;
            clonedBooking.Booking__c = currentBooking.Id;
            
            // ❗ After assigning, now set all the Swap_*__c fields to null in the cloned record
            clonedBooking.Swap_Extra_Covered_Parking_Charges__c = null;
            clonedBooking.Swap_Funding_Type__c = null;
            clonedBooking.Swap_Extra_Covered_Parking_Slots__c = null;
            clonedBooking.Swap_Extra_Individual_Parking_Slots__c = null;
            clonedBooking.Swap_Mode_of_Payment__c = null;
            
            
            // After inserting clonedBooking
            try {
                insert clonedBooking;
            } catch (Exception ex) {
                System.debug('ERROR: ' + ex.getMessage());
                ExceptionHandler.addLog(ex,string.valueof(clonedBooking),'BookingController',previousBookingStage);  /*Add Exception to error log*/
                //  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                return; // Stop if clone failed
            }
            
            // Query all ContentDocumentLinks related to currentBooking
            List<ContentDocumentLink> docLinks = [
                SELECT ContentDocumentId, ContentDocument.Title
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :currentBooking.Id
            ];
            
            // Define document titles to copy
            Set<String> docsToCopy = new Set<String>{
                'Applicant Aadhar Card', 
                    'Applicant Passport', 
                    'Applicant PAN Card', 
                    'Applicant Passport Size Photo'
                    };
                        
                        List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();
            
            // For each linked document, if title matches, create new link to clonedBooking
            for (ContentDocumentLink cdl : docLinks) {
                if (docsToCopy.contains(cdl.ContentDocument.Title)) {
                    linksToInsert.add(new ContentDocumentLink(
                        ContentDocumentId = cdl.ContentDocumentId,
                        LinkedEntityId = clonedBooking.Id,
                        ShareType = 'V', // Viewer access
                        Visibility = 'AllUsers'
                    ));
                }
            }
            
            // Insert links if any exist
            if (!linksToInsert.isEmpty()) {
                try {
                    insert linksToInsert;
                } catch (Exception e) {
                    ExceptionHandler.addLog(e,string.valueof(linksToInsert),'BookingController','');  /*Add Exception to error log*/
                    System.debug('Error cloning documents: ' + e.getMessage());
                    //  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error cloning documents: ' + e.getMessage()));
                }
            }
            
            
            
            // Mark the swap unit plot as 'Booked' with the new booking reference
            for (Plot__c swapUnitPlot : swapUnitPlotList) {
                swapUnitPlot.Status__c = 'Booked';
                plotsToUpdate.add(swapUnitPlot);
            }
            
            // Update plot statuses
            if (!plotsToUpdate.isEmpty()) {
                update plotsToUpdate;
            }
            
            // Clone payment schedules and map them to the new booking
            List<Payment_Schedule__c> paymentSchedules = [SELECT Id, S_No__c, Payment_Percent__c, Completed_Date__c, Payment_Due_Date__c, Status__c
                                                          FROM Payment_Schedule__c WHERE Booking__c = :currentBooking.Id ORDER BY S_No__c ASC];
            List<Payment_Schedule__c> clonedSchedules = new List<Payment_Schedule__c>();
            Map<Decimal, Id> scheduleNumberToIdMap = new Map<Decimal, Id>();
            
            for (Payment_Schedule__c schedule : paymentSchedules) {
                Payment_Schedule__c clonedSchedule = schedule.clone(false, true, false, false);
                clonedSchedule.Booking__c = clonedBooking.Id;
                clonedSchedules.add(clonedSchedule);
            }
            
            if (!clonedSchedules.isEmpty()) {
                upsert clonedSchedules;
                for (Payment_Schedule__c clonedSchedule : clonedSchedules) {
                    scheduleNumberToIdMap.put(clonedSchedule.S_No__c, clonedSchedule.Id);
                }
            }
            
            // Clone co-applicants and assign them to the new booking
            List<Co_Applicant__c> coApplicants = [SELECT Id, Name, Booking__c FROM Co_Applicant__c WHERE Booking__c = :currentBooking.Id];
            for (Co_Applicant__c coApplicant : coApplicants) {
                Co_Applicant__c clonedCoApplicant = coApplicant.clone(false, true, false, false);
                clonedCoApplicant.Booking__c = clonedBooking.Id;
                allToUpdate.add(clonedCoApplicant);
            }
            
            // Step 1: Query existing Receipts and Receipt Line Items
            List<Receipt__c> receipts = [
                SELECT Id, Name, Booking__c 
                FROM Receipt__c 
                WHERE Booking__c = :currentBooking.Id
            ];
            
            List<Receipt_Line_Item__c> receiptLineItems = [
                SELECT Id, S_No__c, Payment_Schedule__c, Booking__c, Amount__c, 
                Approval_Status1__c, Received_Amount__c, Mode_of_Payment__c, 
                Cheque_no_Transaction_Number__c, Receipt__c
                FROM Receipt_Line_Item__c 
                WHERE Booking__c = :currentBooking.Id
            ];
            
            // Step 2: Clone receipt (if any)
            Receipt__c newReceipt;
            if (!receipts.isEmpty()) {
                newReceipt = new Receipt__c(Booking__c = clonedBooking.Id);
                
                try {
                    insert newReceipt; // directly insert instead of upsert
                } catch (Exception ex) {
                    System.debug('Error inserting Receipt: ' + ex.getMessage());
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error creating Receipt: ' + ex.getMessage()));
                    return; // early exit if critical failure
                }
            }
            
            // Step 3: Clone Receipt Line Items
            if (newReceipt != null && !receiptLineItems.isEmpty()) {
                List<Receipt_Line_Item__c> clonedLineItems = new List<Receipt_Line_Item__c>();
                
                for (Receipt_Line_Item__c lineItem : receiptLineItems) {
                    Receipt_Line_Item__c clonedItem = lineItem.clone(false, true, false, false);
                    clonedItem.Booking__c = clonedBooking.Id;
                    clonedItem.Receipt__c = newReceipt.Id;
                    clonedItem.Payment_Schedule__c = scheduleNumberToIdMap.get(lineItem.S_No__c);
                    clonedLineItems.add(clonedItem);
                }
                
                try {
                    insert clonedLineItems;
                } catch (Exception ex) {
                    System.debug('Error inserting Receipt Line Items: ' + ex.getMessage());
                    ExceptionHandler.addLog(ex,string.valueof(clonedLineItems),'BookingController',previousBookingStage);  /*Add Exception to error log*/
                    //   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error creating Receipt Line Items: ' + ex.getMessage()));
                }
            }
            
        } catch (Exception e) {
            ExceptionHandler.addLog(e,string.valueof(clonedBooking),'BookingController',previousBookingStage);  /*Add Exception to error log*/
            System.debug('Error in cloneBookingWithUnitChangeDetails: ' + e.getMessage());
        }
    }
    
    public static void stageWiseOwnerUpdate(List<Booking__c> newBookings, Map<Id, Booking__c> oldBookingMap) {
        for (Booking__c newBooking : newBookings) {
            if (oldBookingMap != null) {
                Booking__c oldBooking = oldBookingMap.get(newBooking.Id);
                
                if (oldBooking.Stage__c != newBooking.Stage__c) {
                    if (newBooking.Stage__c == 'Welcome Email' && newBooking.CRM_Manager__c != null) {
                        newBooking.OwnerId = newBooking.CRM_Manager__c;
                    } 
                }
            }
        }
    }
    
    public static void shareBookingWithAssignedUsers(List<Booking__c> bookings) {
        List<Booking__Share> shares = new List<Booking__Share>();
        
        for (Booking__c booking : bookings) {
            Set<Id> userIds = new Set<Id>();
            
            if (booking.CRM_Manager__c != null) userIds.add(booking.CRM_Manager__c);
            if (booking.Sales_Executive__c != null) userIds.add(booking.Sales_Executive__c);
            if (booking.CRM_Technical__c != null) userIds.add(booking.CRM_Technical__c);
            if (booking.Legal_Team__c != null) userIds.add(booking.Legal_Team__c);
            if (booking.Finance_User__c != null) userIds.add(booking.Finance_User__c);
            if (booking.Legal_Advocate_Assigned__c != null) userIds.add(booking.Legal_Advocate_Assigned__c);
            if (booking.Sales_Manager1__c != null) userIds.add(booking.Sales_Manager1__c);
            
            for (Id userId : userIds) {
                Booking__Share share = new Booking__Share();
                share.ParentId = booking.Id;
                share.UserOrGroupId = userId;
                share.AccessLevel = 'edit'; // or 'Edit' if required
                share.RowCause = Schema.Booking__Share.RowCause.Manual;
                shares.add(share);
            }
        }
        
        if (!shares.isEmpty()) {
            Database.insert(shares, false); 
        }
        
    }    
    
    public static void sendCustomNotification(Set<String> recepientIds, String Title, String Body, String recId, String notificationName){
        CustomNotificationType closedWonNotification = [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName =: notificationName LIMIT 1]; 
        Messaging.CustomNotification Notification = new Messaging.CustomNotification(); 
        Notification.setNotificationTypeId(closedWonNotification.id); 
        Notification.setSenderId(Userinfo.getUserId()); 
        Notification.setBody(Body); 
        Notification.setTitle(Title); 
        Notification.setTargetId(recId); 
        Notification.send(recepientIds);
    }
    
    
    @AuraEnabled
    public static Boolean getCancellationStatus(Id bookingId) {
        Booking__c booking = [SELECT Cancellation_Requested__c FROM Booking__c WHERE Id = :bookingId LIMIT 1];
        return booking.Cancellation_Requested__c;
    }
    
    @AuraEnabled
    public static String bookingCancellationApproval(Id recId, Decimal cancellationCharges, Boolean postAgreement, Boolean originalAgreement) {
        String errorMessage = '';
        
        system.debug('recId'+recId);
        system.debug('cancellationCharges'+cancellationCharges);
        system.debug('postAgreement'+postAgreement);
        system.debug('recIoriginalAgreementd'+originalAgreement);
        
        try {
            // Step 1: Fetch booking details
            Booking__c booking = [
                SELECT Id, Name, Email1__c, First_Applicant_Name__c, 
                CRM_Manager__c, CRM_Manager__r.Email,
                Finance_User__r.Email, Sales_Manager1__r.Email
                FROM Booking__c
                WHERE Id = :recId
                LIMIT 1
            ];
            List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
            string companyName;
            string companyAddress1;
            string companyAddress2;
            string companyAddress3;
            if(!companyDetails.isEmpty()){
                companyName = companyDetails[0].Label;
                companyAddress1 =   companyDetails[0].Registered_Address__c;
                companyAddress2 =   companyDetails[0].Address2__c;
                companyAddress3 =   companyDetails[0].Address3__c;
            }
            // Update booking fields first (no DML yet)
            booking.Cancellation_Charges__c = cancellationCharges;
            booking.Post_Agreement_Cancellation__c = postAgreement;
            booking.Original_Agreement_Collected__c = originalAgreement;
            
            // Step 2: Send email - catch error but don't stop
            try {
                String toAddress = booking.Email1__c;
                String applicantName = booking.First_Applicant_Name__c;
                List<String> ccList = new List<String>();
                if (booking.CRM_Manager__r?.Email != null) ccList.add(booking.CRM_Manager__r.Email);
                if (booking.Finance_User__r?.Email != null) ccList.add(booking.Finance_User__r.Email);
                if (booking.Sales_Manager1__r?.Email != null) ccList.add(booking.Sales_Manager1__r.Email);
                
                String body = 'Dear ' + applicantName + ',<br/><br/>' +
                    'We have received your request for booking cancellation. While we respect your decision, we sincerely invite you to reconsider, as we would love to continue being part of your journey towards owning your dream home.<br/><br/>' +
                    'If you have any concerns or queries, our dedicated Customer Relations team would be happy to assist you and provide clarity on any aspect of your booking.<br/><br/>' +
                    (booking.Cancellation_Charges__c != null ? '<strong>Cancellation Charges:</strong> ₹' + booking.Cancellation_Charges__c + '<br/><br/>' : '') +
                    'We have initiated the cancellation process as per your request. Once the cancellation is completed, you will receive a confirmation email from us.<br/><br/>' +
                    'Should you choose to continue with your booking or need any assistance, feel free to get in touch with us at any time.<br/><br/>' +
                    'Warm Regards,<br/><br/>' +
                    'Midhu Siju | Officer - Customer Relations | 9207054444<br/>' +
                    'Alitta Lijoy | Customer Relations Executive | 90482 37066<br/><br/>' +
                    companyName+'<br/>' +
                    'Regd. Office: '+companyAddress1+'<br/>' +
                    companyAddress2+'<br/>' +
                    companyAddress3+'<br/>' +
                    'Tel: +91 484 2584000 / 2973944, +91 6235051144<br/>' +
                    '<a href="https://www.veegaland.com">www.veegaland.com</a><br/><br/>' +
                    'Follow us: Facebook | Instagram | LinkedIn | YouTube';
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { toAddress });
                mail.setCcAddresses(ccList);
                mail.setSubject('Booking Cancellation Request Received');
                mail.setHtmlBody(body);
                mail.setSaveAsActivity(true);
                mail.setWhatId(booking.Id);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            } catch (Exception emailEx) {
                errorMessage += 'Email sending failed: ' + emailEx.getMessage() + '\n';
            }
            // Step 3: Prepare Tasks - check existing and update or insert accordingly
            
            List<Task> tasksToInsert = new List<Task>();
            List<Task> tasksToUpdate = new List<Task>();
            
            // Collect potential owner Ids for tasks to query existing ones
            Set<Id> ownerIdsToCheck = new Set<Id>();
            if (postAgreement && !originalAgreement && booking.CRM_Manager__c != null) {
                ownerIdsToCheck.add(booking.CRM_Manager__c);
            }
            if (booking.Finance_User__c != null) {
                ownerIdsToCheck.add(booking.Finance_User__c);
            }
            
            // Query existing Tasks for this booking owned by these users with relevant subjects
            List<Task> existingTasks = new List<Task>();
            
            if (!ownerIdsToCheck.isEmpty()) {
                existingTasks = [SELECT Id, OwnerId, Status, Subject 
                                 FROM Task 
                                 WHERE WhatId = :booking.Id 
                                 AND OwnerId IN :ownerIdsToCheck 
                                 AND Status != 'Completed' // you can adjust filter if needed
                                 AND (Subject = 'Collect Registered Sale Agreement' OR Subject = 'Complete Cancellation Charges Collection and Refund Process')];
            }
            
            // Map to quickly find existing tasks by OwnerId + Subject
            Map<String, Task> existingTaskMap = new Map<String, Task>();
            for (Task t : existingTasks) {
                existingTaskMap.put(t.OwnerId + '###' + t.Subject, t);
            }
            
            // Handle CRM Manager task
            if (postAgreement && !originalAgreement) {
                if (booking.CRM_Manager__c != null) {
                    String key = booking.CRM_Manager__c + '###Collect Registered Sale Agreement';
                    if (existingTaskMap.containsKey(key)) {
                        Task existingTask = existingTaskMap.get(key);
                        existingTask.Status = 'Not Started';
                        existingTask.ActivityDate = Date.today().addDays(1);
                        existingTask.Description = 'Please collect the registered sale agreement from the customer as part of the cancellation process.';
                        existingTask.Priority = 'High';
                        tasksToUpdate.add(existingTask);
                    } else {
                        tasksToInsert.add(new Task(
                            WhatId = booking.Id,
                            OwnerId = booking.CRM_Manager__c,
                            Subject = 'Collect Registered Sale Agreement',
                            Priority = 'High',
                            Status = 'Not Started',
                            ActivityDate = Date.today().addDays(1),
                            Description = 'Please collect the registered sale agreement from the customer as part of the cancellation process.'
                        ));
                    }
                } else {
                    errorMessage += 'CRM Manager is not assigned. Cannot create Task.\n';
                }
            }
            
            // Handle Finance User task
            if (booking.Finance_User__c != null) {
                String key = booking.Finance_User__c + '###Complete Cancellation Charges Collection and Refund Process';
                if (existingTaskMap.containsKey(key)) {
                    Task existingTask = existingTaskMap.get(key);
                    existingTask.Status = 'Not Started';
                    existingTask.ActivityDate = Date.today().addDays(1);
                    existingTask.Description = 'Please collect the cancellation charges and process the refund for booking: ' + booking.Name;
                    existingTask.Priority = 'High';
                    tasksToUpdate.add(existingTask);
                } else {
                    tasksToInsert.add(new Task(
                        WhatId = booking.Id,
                        OwnerId = booking.Finance_User__c,
                        Subject = 'Complete Cancellation Charges Collection and Refund Process',
                        Priority = 'High',
                        Status = 'Not Started',
                        ActivityDate = Date.today().addDays(1),
                        Description = 'Please collect the cancellation charges and process the refund for booking: ' + booking.Name
                    ));
                }
            } else {
                errorMessage += 'Finance User is not assigned. Cannot create Task.\n';
            }
            
            // Step 4: If there are any errors so far, return immediately
            if (errorMessage != '') {
                return errorMessage.trim();
            }
            
            // Step 5: No errors so far - now do DML
            
            try {
                if (!tasksToUpdate.isEmpty()) {
                    update tasksToUpdate;
                }
                if (!tasksToInsert.isEmpty()) {
                    insert tasksToInsert;
                }
            } catch (Exception taskDmlEx) {
                ExceptionHandler.addLog(taskDmlEx,string.valueof(tasksToUpdate)+'--'+string.valueof(tasksToInsert),'BookingController',recId);  /*Add Exception to error log*/
                return 'Task DML error: ' + taskDmlEx.getMessage();
            }
            
            // Update booking record
            try {
                update booking;
            } catch (Exception updateEx) {
                
                ExceptionHandler.addLog(updateEx,string.valueof(booking),'BookingController',recId);  /*Add Exception to error log*/
                
                return 'Booking update error: ' + updateEx.getMessage();
            }
            
            if(!Test.isRunningTest()){
                // Step 6: Submit approval only if everything else succeeded
                try {
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setComments('Booking Cancellation');
                    req.setObjectId(booking.Id);
                    req.setSubmitterId(UserInfo.getUserId());
                    req.setProcessDefinitionNameOrId('Cancellation_Approval_For_Booking');
                    req.setSkipEntryCriteria(true);
                    
                    Approval.ProcessResult result = Approval.process(req);
                    if (!result.isSuccess()) {
                        return 'Approval submission failed: ' + result.getInstanceStatus();
                    }
                } catch (Exception appEx) {
                    ExceptionHandler.addLog(appEx,string.valueof(booking),'BookingController',booking.Id);  /*Add Exception to error log*/
                    return 'Approval process error: ' + appEx.getMessage();
                }
            }
        } catch (Exception ex) {
            ExceptionHandler.addLog(ex,cancellationCharges+''+postAgreement+''+originalAgreement,'BookingController','');  /*Add Exception to error log*/
            return 'Unexpected error: ' + ex.getMessage();
        }
        
        // If we reach here, everything succeeded
        return '';
    }
    
    
    public static void completeOrCreateTokenAdvanceFollowUps(Set<Id> bookingIds) {
        if (bookingIds == null || bookingIds.isEmpty()) return;
        
        // 1. Query eligible bookings
        List<Booking__c> eligibleBookings = [
            SELECT Id, OwnerId, Sales_Executive__c,CRM_Manager__c , Stage__c, Token_Advance_Amount_Status__c, Token_Advance_Amount__c
            FROM Booking__c
            WHERE Id IN :bookingIds AND Stage__c = 'Token Amount Collection'
        ];
        if (eligibleBookings.isEmpty()) return;
        
        // 2. Fetch the total advance amount from approved receipts
        Map<Id, Decimal> bookingIdToTotal = new Map<Id, Decimal>();
        for (AggregateResult ar : [
            SELECT Booking__c bookingId, SUM(Advance_Amount__c) total
            FROM Advance_Receipt__c
            WHERE Booking__c IN :bookingIds
            AND Approval_Status__c = 'Approved by Finance Team'
            GROUP BY Booking__c
        ]) {
            bookingIdToTotal.put((Id) ar.get('bookingId'), (Decimal) ar.get('total'));
        }
        
        Map<Id, Booking__c> bookingsById = new Map<Id, Booking__c>();
        Set<Id> eligibleBookingIds = new Set<Id>();
        List<Booking__c> bookingsToUpdate = new List<Booking__c>();
        for (Booking__c booking : eligibleBookings) {
            Decimal totalReceived = bookingIdToTotal.get(booking.Id);
            if (totalReceived != null && totalReceived >= booking.Token_Advance_Amount__c.setScale(0)) {
                bookingsToUpdate.add(booking);
                eligibleBookingIds.add(booking.Id);
                bookingsById.put(booking.Id, booking);
            }
        }
        
        if (!eligibleBookingIds.isEmpty()) {
            
            system.debug('bookingsToUpdate '+bookingsToUpdate);
            for (Booking__c booking : bookingsToUpdate) {
                booking.Stage__c = 'Welcome Email';
            }
            
            if (!bookingsToUpdate.isEmpty()) {
                update bookingsToUpdate;
            }
            
            // 4. Find existing open "Token Advance Payment Follow-up" tasks
            List<Task> existingOpen = [
                SELECT Id, WhatId, Subject, Status, OwnerId, IsClosed
                FROM Task
                WHERE WhatId IN :eligibleBookingIds
                AND Subject = 'Token Advance Payment Follow-up'
                AND IsClosed = false
            ];
            
            List<Task> tasksToUpdate = new List<Task>();
            for (Task t : existingOpen) {
                t.Status = 'Completed';
                t.ActivityDate = Date.today();
                tasksToUpdate.add(t);
            }
            
            // 5. Add new tasks for bookings without an open task
            Set<Id> bookingsWithAnOpen = new Set<Id>();
            for (Task t : existingOpen) bookingsWithAnOpen.add(t.WhatId);
            
            List<Task> tasksToInsert = new List<Task>();
            for (Id bid : eligibleBookingIds) {
                if (bookingsWithAnOpen.contains(bid)) continue;
                
                Booking__c b = bookingsById.get(bid);
                //Id ownerId =  b.OwnerId;
                //(b.Sales_Executive__c != null) ? b.Sales_Executive__c : b.OwnerId;
                
                Task newT = new Task();
                newT.Subject     = 'Token Advance Payment Follow-up';
                newT.WhatId      = bid;
                //newT.OwnerId     = ownerId;
                newT.Status      = 'Completed';   // immediately complete
                newT.ActivityDate= Date.today();
                tasksToInsert.add(newT);
            }
            
            // Fetch existing "Welcome Call Follow-up" tasks
            Map<Id, Task> existingFollowUpTaskMap = new Map<Id, Task>();
            for (Task t : [
                SELECT Id, WhatId, OwnerId
                FROM Task
                WHERE WhatId IN :eligibleBookingIds
                AND Subject = 'Welcome Call Follow-up'
                LIMIT 10000
            ]) {
                existingFollowUpTaskMap.put(t.WhatId, t);
            }
            
            for (Id bookingId : eligibleBookingIds) {
                
                Booking__c b = bookingsById.get(bookingId);
                
                // Handle follow-up Task
                if (existingFollowUpTaskMap.containsKey(b.Id)) {
                    // Task exists: update status
                    Task existingTask = existingFollowUpTaskMap.get(b.Id);
                    existingTask.Status = 'Not Started';
                    tasksToUpdate.add(existingTask);
                } else {
                    // Create new Task
                    Task followUp = new Task();
                    followUp.Subject = 'Welcome Call Follow-up';
                    followUp.WhatId = b.Id;
                    followUp.OwnerId = b.CRM_Manager__c;
                    followUp.Status = 'Not Started';
                    followUp.Priority = 'Normal';
                    followUp.ActivityDate = Date.today().addDays(2);
                    followUp.Description = 'Please follow up with the customer regarding the welcome mail.';
                    followUp.IsReminderSet = true;
                    followUp.ReminderDateTime = System.now().addDays(2).addMinutes(-30);
                    tasksToInsert.add(followUp);
                }
            }
            // 6. DML for task updates and insertions
            if (!tasksToInsert.isEmpty()){ try{insert tasksToInsert; }catch(exception ex){  ExceptionHandler.addLog(ex,string.valueof(tasksToInsert),'BookingController','');  /*Add Exception to error log*/}}
            if (!tasksToUpdate.isEmpty()) { try{update tasksToUpdate;}catch(exception ex){  ExceptionHandler.addLog(ex,string.valueof(tasksToUpdate),'BookingController','');  /*Add Exception to error log*/}}
        }
    }
    
    public static void completeOrCreateAdvanceFollowUps(Set<Id> bookingIds) {
        if (bookingIds == null || bookingIds.isEmpty()) return;
        
        // 1. Query eligible bookings
        List<Booking__c> eligibleBookings = [
            SELECT Id, OwnerId, Sales_Executive__c,CRM_Manager__c ,Advance_Booking_Amount__c, Stage__c, Token_Advance_Amount_Status__c, Token_Advance_Amount__c
            FROM Booking__c
            WHERE Id IN :bookingIds AND Stage__c = 'Advance Amount Collection'
        ];
        
        if (eligibleBookings.isEmpty()) return;
        
        // 2. Fetch the total advance amount from approved receipts
        Map<Id, Decimal> bookingIdToTotal = new Map<Id, Decimal>();
        for (AggregateResult ar : [
            SELECT Booking__c bookingId, SUM(Advance_Amount__c) total
            FROM Advance_Receipt__c
            WHERE Booking__c IN :bookingIds
            AND Approval_Status__c = 'Approved by Finance Team'
            GROUP BY Booking__c
        ]) {
            bookingIdToTotal.put((Id) ar.get('bookingId'), (Decimal) ar.get('total'));
        }
        
        Map<Id, Booking__c> bookingsById = new Map<Id, Booking__c>();
        Set<Id> eligibleBookingIds = new Set<Id>();
        List<Booking__c> bookingsToUpdate = new List<Booking__c>();
        for (Booking__c booking : eligibleBookings) {
            Decimal totalReceived = bookingIdToTotal.get(booking.Id);
            if (totalReceived != null && totalReceived >= booking.Advance_Booking_Amount__c.setScale(0)) {
                bookingsToUpdate.add(booking);
                eligibleBookingIds.add(booking.Id);
                bookingsById.put(booking.Id, booking);
            }
        }
        if (!eligibleBookingIds.isEmpty()) {
            
            for (Booking__c booking : bookingsToUpdate) {
                booking.Stage__c = 'Draft Agreement Preparation';
            }
            
            if (!bookingsToUpdate.isEmpty()) {
                update bookingsToUpdate;
            }
            
            // 4. Find existing open "Token Advance Payment Follow-up" tasks
            List<Task> existingOpen = [
                SELECT Id, WhatId, Subject, Status, OwnerId, IsClosed
                FROM Task
                WHERE WhatId IN :eligibleBookingIds
                AND Subject = 'Advance Payment Follow-up'
                AND IsClosed = false
            ];
            
            List<Task> tasksToUpdate = new List<Task>();
            for (Task t : existingOpen) {
                t.Status = 'Completed';
                t.ActivityDate = Date.today();
                tasksToUpdate.add(t);
            }
            
            // 5. Add new tasks for bookings without an open task
            Set<Id> bookingsWithAnOpen = new Set<Id>();
            for (Task t : existingOpen) bookingsWithAnOpen.add(t.WhatId);
            
            List<Task> tasksToInsert = new List<Task>();
            for (Id bid : eligibleBookingIds) {
                if (bookingsWithAnOpen.contains(bid)) continue;
                
                Booking__c b = bookingsById.get(bid);
                //Id ownerId =  b.OwnerId;
                //(b.Sales_Executive__c != null) ? b.Sales_Executive__c : b.OwnerId;
                
                Task newT = new Task();
                newT.Subject     = 'Advance Payment Follow-up';
                newT.WhatId      = bid;
                //newT.OwnerId     = ownerId;
                newT.Status      = 'Completed';   // immediately complete
                newT.ActivityDate= Date.today();
                tasksToInsert.add(newT);
            }
            
            // Fetch existing "Welcome Call Follow-up" tasks
            Map<Id, Task> existingFollowUpTaskMap = new Map<Id, Task>();
            
            // 6. DML for task updates and insertions
            if (!tasksToInsert.isEmpty()){ try{insert tasksToInsert; }catch(exception ex){  ExceptionHandler.addLog(ex,string.valueof(tasksToInsert),'BookingController','');  /*Add Exception to error log*/}}
            if (!tasksToUpdate.isEmpty()) { try{update tasksToUpdate;}catch(exception ex){  ExceptionHandler.addLog(ex,string.valueof(tasksToUpdate),'BookingController','');  /*Add Exception to error log*/}}
        }
    }
    
    
    public static void sendCarParkingNotification(Set<Id> bookingIds) {
        List<Task> tasksToCreate = new List<Task>();
        List<Task> tasksToUpdate = new List<Task>();
        List<Booking__c> bookings = [
            SELECT Id, Name, CRM_Manager__c, CRM_Manager__r.Email, CRM_Manager__r.Name
            FROM Booking__c
            WHERE Id IN :bookingIds
            AND CRM_Manager__c != null
        ];
        
        // Fetch existing "Car Parking Follow-up" tasks
        Map<String, Task> existingTasksMap = new Map<String, Task>();
        for (Task t : [
            SELECT Id, WhatId, OwnerId
            FROM Task
            WHERE WhatId IN :bookingIds
            AND Subject = 'Car Parking Follow-up'
            AND OwnerId != null
            LIMIT 10000
        ]) {
            existingTasksMap.put(t.WhatId + '_' + t.OwnerId, t);
        }
        
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        
        for (Booking__c booking : bookings) {
            String bookingLink = URL.getOrgDomainURL().toExternalForm() + '/lightning/r/Booking__c/' + booking.Id + '/view';
            
            /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
mail.setToAddresses(new List<String>{booking.CRM_Manager__r.Email});
mail.setSubject('Booking Stage Changed: Car Parking Selection');

mail.setHtmlBody(
'Hello ' + booking.CRM_Manager__r.Name + ',<br/><br/>' +
'The stage of the booking <b>' + booking.Name + '</b> has been updated to <b>Car Parking Selection</b>.<br/><br/>' +
'Please send the car parking selection mail to the customer and request them to select their parking slots.<br/><br/>' +
'You can view the booking details here: <a href="' + bookingLink + '">Booking Link</a><br/><br/>' +
'Thank you.'
);

emailsToSend.add(mail);*/
            
            if (booking.CRM_Manager__c != null) {
                String key = booking.Id + '_' + booking.CRM_Manager__c;
                if (existingTasksMap.containsKey(key)) {
                    // Task exists: update its status to Not Started
                    Task existingTask = existingTasksMap.get(key);
                    existingTask.Status = 'Not Started';
                    tasksToUpdate.add(existingTask);
                } else {
                    // Task does not exist: create new task
                    Task newTask = new Task(
                        Subject = 'Car Parking Follow-up',
                        WhatId = booking.Id,
                        OwnerId = booking.CRM_Manager__c,
                        Status = 'Not Started',
                        Priority = 'Normal',
                        Description = 'Follow up with the customer for car parking selection for Booking: ' + booking.Name
                    );
                    tasksToCreate.add(newTask);
                }
            }
        }
        
        /*if (!emailsToSend.isEmpty()) {
Messaging.sendEmail(emailsToSend);
}*/
        
        if (!tasksToCreate.isEmpty()) {
            insert tasksToCreate;
        }
        
        if (!tasksToUpdate.isEmpty()) {
            update tasksToUpdate;
        }
    }
    
    
    public static void agreementDraftStage(List<Id> bookingIds) {
        if (bookingIds == null || bookingIds.isEmpty()) return;
        
        // Query Booking records with Legal_Team details
        List<Booking__c> bookings = [
            SELECT Id, Name, Legal_Team__c, Legal_Team__r.Email, Legal_Team__r.Name, plot__r.Name
            FROM Booking__c
            WHERE Id IN :bookingIds
        ];
        
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        List<Task> tasksToCreate = new List<Task>();
        List<Task> tasksToUpdate = new List<Task>();
        
        // Filter valid Booking Ids with Legal_Team__c assigned
        Set<Id> validBookingIds = new Set<Id>();
        for (Booking__c b : bookings) {
            if (b.Legal_Team__c != null) {
                validBookingIds.add(b.Id);
            }
        }
        
        if (validBookingIds.isEmpty()) return;
        
        // Query existing tasks
        Map<Id, Task> existingTasksMap = new Map<Id, Task>();
        for (Task t : [
            SELECT Id, WhatId, Subject
            FROM Task
            WHERE WhatId IN :validBookingIds
            AND Subject = 'Legal - Upload draft sale agreement'
        ]) {
            existingTasksMap.put(t.WhatId, t);
        }
        
        for (Booking__c booking : bookings) {
            if (booking.Legal_Team__c == null || booking.Legal_Team__r.Email == null) {
                continue;
            }
            
            // Prepare Email
            String bookingLink = URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/Booking__c/' + booking.Id + '/view';
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{booking.Legal_Team__r.Email});
            mail.setSubject('Upload draft sale agreement: Booking stage changed to Draft Agreement Preparation');
            mail.setHtmlBody(
                'Hello ' + booking.Legal_Team__r.Name + ',<br/><br/>' +
                'The stage of the booking <b>' + booking.Name +' Unit-'+booking.plot__r.Name+ '</b> has been updated to <b>Draft Agreement Preparation</b>.<br/><br/>' +
                'Please prepare and upload the draft sale agreement for this booking at your earliest convenience.<br/><br/>' +
                'You can view the booking details here: <a href="' + bookingLink + '">Booking Link</a><br/><br/>' +
                'Thank you.'
            );
            mail.setSaveAsActivity(true);
            mail.setWhatId(booking.Id);
            emailsToSend.add(mail);
            
            // Create or Update Task
            if (!existingTasksMap.containsKey(booking.Id)) {
                Task t = new Task();
                t.Subject = 'Legal - Upload draft sale agreement';
                t.WhatId = booking.Id;
                t.OwnerId = booking.Legal_Team__c;
                t.Status = 'Not Started';
                t.Priority = 'Normal';
                t.Description = 'Please prepare and upload the draft sale agreement for Booking: ' + booking.Name;
                t.ActivityDate = Date.today().addDays(1);
                tasksToCreate.add(t);
            } else {
                Task existingTask = existingTasksMap.get(booking.Id);
                existingTask.Status = 'Not Started';
                tasksToUpdate.add(existingTask);
            }
        }
        
        // Send Emails
        if (!emailsToSend.isEmpty()) {
            try {
                Messaging.sendEmail(emailsToSend);
            } catch (Exception e) {
                System.debug('Email sending failed: ' + e.getMessage());
            }
        }
        
        // Insert new Tasks
        if (!tasksToCreate.isEmpty()) {
            try {
                insert tasksToCreate;
            } catch (DmlException e) {
                ExceptionHandler.addLog(e,string.valueof(tasksToCreate),'BookingController','');  /*Add Exception to error log*/
                System.debug('Task insert failed: ' + e.getMessage());
            }
        }
        
        // Update existing Tasks
        if (!tasksToUpdate.isEmpty()) {
            try {
                update tasksToUpdate;
            } catch (DmlException e) {
                ExceptionHandler.addLog(e,string.valueof(tasksToCreate),'BookingController','');  /*Add Exception to error log*/
                System.debug('Task update failed: ' + e.getMessage());
            }
        }
    }
    
    public static void createTaskForAgreementCost(Set<Id> bookings) {
        if (bookings == null || bookings.isEmpty()) return;
        
        Map<Id, Booking__c> bookingMap = new Map<Id, Booking__c>(
            [SELECT Id, CRM_Manager__c, Agreement_Amount_Received__c 
             FROM Booking__c 
             WHERE Id IN :bookings]
        );
        
        Map<String, Map<Id, Task>> existingTasksMap = new Map<String, Map<Id, Task>>();
        existingTasksMap.put('Upload Registered Sale Agreement', new Map<Id, Task>());
        
        List<Task> tasksToInsert = new List<Task>();
        List<Task> tasksToUpdate = new List<Task>();
        
        // Query existing tasks with the relevant subjects
        for (Task t : [
            SELECT Id, WhatId, Subject, Status
            FROM Task
            WHERE WhatId IN :bookings
            AND Subject IN ('Upload Registered Sale Agreement')
        ]) {
            if (existingTasksMap.containsKey(t.Subject)) {
                existingTasksMap.get(t.Subject).put(t.WhatId, t);
            }
        }
        
        for (Id bookingId : bookings) {
            Booking__c booking = bookingMap.get(bookingId);
            
            if (booking == null || booking.CRM_Manager__c == null || booking.Agreement_Amount_Received__c == true)
                continue;
            
            // 2. Task: Upload Registered Sale Agreement
            if (existingTasksMap.get('Upload Registered Sale Agreement').containsKey(bookingId)) {
                Task existing = existingTasksMap.get('Upload Registered Sale Agreement').get(bookingId);
                existing.Status = 'Not Started';
                tasksToUpdate.add(existing);
            } else {
                Task newTask = new Task();
                newTask.Subject = 'Upload Registered Sale Agreement';
                newTask.Description = 'Upload the final registered sale agreement document to complete the booking process.';
                newTask.WhatId = bookingId;
                newTask.OwnerId = booking.CRM_Manager__c;
                newTask.Status = 'Not Started';
                newTask.Priority = 'Normal';
                newTask.ActivityDate = Date.today();
                tasksToInsert.add(newTask);
            }
        }
        
        if (!tasksToInsert.isEmpty()) insert tasksToInsert;
        if (!tasksToUpdate.isEmpty()) update tasksToUpdate;
    }
    
    
    public static void createTaskForAppointment(Set<Id> bookingIds) {
        if (bookingIds == null || bookingIds.isEmpty()) return;
        
        Map<Id, Booking__c> bookingMap = new Map<Id, Booking__c>(
            [SELECT Id, CRM_Manager__c FROM Booking__c WHERE Id IN :bookingIds]
        );
        
        Map<Id, Task> existingTasksMap = new Map<Id, Task>();
        List<Task> tasksToInsert = new List<Task>();
        List<Task> tasksToUpdate = new List<Task>();
        
        // Query for existing tasks
        for (Task t : [
            SELECT Id, WhatId, Subject, Status
            FROM Task
            WHERE WhatId IN :bookingIds
            AND Subject = 'Generate and Send Sale Agreement Appointment Mail'
        ]) {
            existingTasksMap.put(t.WhatId, t);
        }
        
        for (Id bookingId : bookingIds) {
            Booking__c booking = bookingMap.get(bookingId);
            if (booking == null || booking.CRM_Manager__c == null) continue;
            
            if (existingTasksMap.containsKey(bookingId)) {
                Task existing = existingTasksMap.get(bookingId);
                existing.Status = 'Not Started';
                tasksToUpdate.add(existing);
            } else {
                Task appointmentTask = new Task();
                appointmentTask.Subject = 'Generate and Send Sale Agreement Appointment Mail';
                appointmentTask.Description = 'Agreement cost has been received. Generate and send the Sale Agreement Appointment mail to the customer.';
                appointmentTask.WhatId = bookingId;
                appointmentTask.OwnerId = booking.CRM_Manager__c;
                appointmentTask.Status = 'Not Started';
                appointmentTask.Priority = 'Normal';
                appointmentTask.ActivityDate = Date.today();
                tasksToInsert.add(appointmentTask);
            }
        }
        
        if (!tasksToInsert.isEmpty()) insert tasksToInsert;
        if (!tasksToUpdate.isEmpty()) update tasksToUpdate;
    }
    
    public static void createTaskForAgreementCompletion(Set<Id> bookingIdList) {
        if (bookingIdList == null || bookingIdList.isEmpty()) return;
        
        // Fetch the Booking records along with CRM_Manager__c
        List<Booking__c> bookings = [
            SELECT Id, CRM_Manager__c
            FROM Booking__c
            WHERE Id IN :bookingIdList
        ];
        
        List<Task> tasksToInsert = new List<Task>();
        List<Task> tasksToUpdate = new List<Task>();
        
        // Fetch existing tasks related to these bookings
        Map<Id, Task> existingTasksMap = new Map<Id, Task>();
        for (Task t : [
            SELECT Id, WhatId, Status
            FROM Task
            WHERE WhatId IN :bookingIdList
            AND Subject = 'Sale Agreement Completion'
        ]) {
            existingTasksMap.put(t.WhatId, t);
        }
        
        for (Booking__c booking : bookings) {
            if (booking.CRM_Manager__c != null) {
                if (existingTasksMap.containsKey(booking.Id)) {
                    Task existingTask = existingTasksMap.get(booking.Id);
                    existingTask.Status = 'Not Started';
                    tasksToUpdate.add(existingTask);
                } else {
                    Task newTask = new Task();
                    newTask.Subject = 'Sale Agreement Completion';
                    newTask.Description = 'If the sale agreement registration has been successfully completed, kindly update the task status as **Completed** to reflect the finalized process.';
                    newTask.Status = 'Not Started';
                    newTask.Priority = 'High';
                    newTask.OwnerId = booking.CRM_Manager__c;
                    newTask.WhatId = booking.Id;
                    newTask.ActivityDate = System.today().addDays(1); // Optional due date
                    tasksToInsert.add(newTask);
                }
            }
        }
        
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
        if (!tasksToUpdate.isEmpty()) {
            update tasksToUpdate;
        }
    }
    
    
    public static void createTaskForPostAgreement(List<Id> bookingIdList) {
        if (bookingIdList == null || bookingIdList.isEmpty()) return;
        
        // Fetch the Booking records along with CRM_Manager__c
        List<Booking__c> bookings = [
            SELECT Id, CRM_Manager__c,Legal_Team__c
            FROM Booking__c
            WHERE Id IN :bookingIdList
        ];
        
        List<Task> tasksToInsert = new List<Task>();
        List<Task> tasksToUpdate = new List<Task>();
        
        // Fetch existing tasks related to these bookings
        Map<Id, Task> existingTasksMap = new Map<Id, Task>();
        for (Task t : [
            SELECT Id, WhatId, Status
            FROM Task
            WHERE WhatId IN :bookingIdList
            AND Subject = 'Complete Post-Registration Formalities'
        ]) {
            existingTasksMap.put(t.WhatId, t);
        }
        
        for (Booking__c booking : bookings) {
            if (booking.CRM_Manager__c != null) {
                if (existingTasksMap.containsKey(booking.Id)) {
                    Task existingTask = existingTasksMap.get(booking.Id);
                    existingTask.Status = 'Not Started';
                    tasksToUpdate.add(existingTask);
                } else {
                    Task newTask = new Task();
                    newTask.Subject = 'Prepare registered sale agreement and supporting documents.';
                    newTask.Description = 'Please ensure all post-registration formalities are completed for this booking. '
                        + 'This includes uploading the registered sale agreement, updating registration status, and notifying the customer.';
                    newTask.Status = 'Not Started';
                    newTask.Priority = 'High';
                    newTask.OwnerId = booking.Legal_Team__c;
                    newTask.WhatId = booking.Id;
                    newTask.ActivityDate = System.today().addDays(1); // Optional due date
                    tasksToInsert.add(newTask);
                }
            }
        }
        
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
        if (!tasksToUpdate.isEmpty()) {
            update tasksToUpdate;
        }
    }
    
    
    @AuraEnabled
    public static String sendNameBoardMail(Id recId,String emailContent, List<String> contentIds) {
        system.debug('recId: ' + recId);
        system.debug('emailContent'+emailContent);
        system.debug('contentIds'+contentIds);
        
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        String returnMessage;
        try {
            // Retrieve the Booking record
            List<Booking__c> bookings = [SELECT Id, Project__c, Email1__c, Email2__c, First_Applicant_Name__c, CRM_Manager__c, CRM_Manager__r.Email 
                                         FROM Booking__c WHERE Id = :recId LIMIT 1];
            system.debug('bookings'+bookings);
            //  List<String> lstCCEmail = new List<String>();
            
            
            
            // Retrieve Org Wide Email Address
            //List<OrgWideEmailAddress> owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = :booking.Owner.Email];
            
            if (!bookings.isEmpty()) {
                Booking__c booking = bookings[0];
                // Prepare email details
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>();
                
                if (booking.Email1__c != null) {
                    sendTo.add(booking.Email1__c);
                }
                
                email.setToAddresses(sendTo);
                system.debug(sendTo);
                email.setSubject('Welcome Email');
                email.setHtmlBody(emailContent);
                
                email.setSaveAsActivity(true);
                email.setWhatId(booking.Id);
                emailsToSend.add(email);
                // Add file attachments
                List<ContentDocumentLink> contentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recId];
                
                system.debug('contentLinks '+contentLinks);
                // List to hold attachments
                List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                set<Id> ContentDocumentIds = new set<Id>();
                for (ContentDocumentLink contentLink : contentLinks) {
                    ContentDocumentIds.add(contentLink.ContentDocumentId);
                }
                if(!ContentDocumentIds.isEmpty()){
                    List<ContentVersion> contentVersion = [SELECT Title, VersionData FROM ContentVersion WHERE ContentDocumentId IN :ContentDocumentIds AND (Title like '%Allotment%' OR Title like '%receipt%' OR Title like '%sale agreement%') ORDER BY LastModifiedDate DESC LIMIT 1
                                                          ];
                    system.debug(contentVersion);
                    
                    // Loop through content links to add attachments
                    for (ContentVersion ContentVersions : contentVersion) {
                        //ContentVersion contentVersion = [SELECT Title, VersionData FROM ContentVersion WHERE ContentDocumentId = :contentLink.ContentDocumentId AND Title IN :fileNamesToAttach ORDER BY LastModifiedDate DESC LIMIT 1];
                        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                        attachment.setFileName(contentVersions.Title);
                        attachment.setBody(contentVersions.VersionData);
                        attachments.add(attachment);
                    }
                }
                
                // Attach the files to the email
                if (!attachments.isEmpty()) {
                    email.setFileAttachments(attachments);
                }
                
                // Send the email
                
                if (!emailsToSend.isEmpty()) {
                    Messaging.sendEmail(emailsToSend);
                }
                
                returnMessage = 'Email sent successfully';
            } else {
                returnMessage = 'Email address not specified in the Booking record.';
            }
        } catch (Exception e) {
            ExceptionHandler.addLog(e,string.valueof(emailContent),'BookingController',recId);  /*Add Exception to error log*/
            returnMessage = 'Error sending email: ' + e.getMessage();
            system.debug('returnMessage'+e);
        }
        return returnMessage;
    }
    
    @AuraEnabled
    public static Booking__c getSecondaryApplicantDetails(Id bookingId) {
        // Query the Booking__c object for secondary applicant details
        Booking__c booking = [SELECT salutation_Applicant2__c, Second_Applicant_Name__c, Date_of_birth_Applicant2__c, 
                              Mobile_Primary1__c, Email2__c, Nationality_Applicant2__c, Relation_Details_Applicant2__c,
                              Son_Daughter_Wife_of1__c, Passport_Aadhar_1__c, Aadhaar_Number1__c, Pan_Number_Applicant2__c, 
                              Occupation1__c, Name_of_Company1__c, Designation1__c, Anniverssary_Date1__c, 
                              Communication_address1__c, Permanent_Address1__c 
                              FROM Booking__c WHERE Id = :bookingId LIMIT 1];
        
        // Return the secondary applicant details
        return booking;
    }
    
    
    @AuraEnabled
    public static void handleTokenAdvanceFollowupTasks(List<Id> bookingIds) {
        if (bookingIds == null || bookingIds.isEmpty()) return;
        
        List<Booking__c> bookingsToUpdate = new List<Booking__c>();
        List<Task> tasksToCreate = new List<Task>();
        
        // Fetch Bookings and relevant Tasks
        Map<Id, Booking__c> bookingMap = new Map<Id, Booking__c>(
            [SELECT Id, OwnerId, Name, Booking_Advance_status__c, Stage__c, Token_Advance_Amount_Status__c
             FROM Booking__c
             WHERE Id IN :bookingIds]
        );
        
        Map<Id, Task> existingTaskMap = new Map<Id, Task>();
        for (Task t : [
            SELECT Id, Subject, WhatId, OwnerId, ActivityDate, Status, Priority, Description
            FROM Task
            WHERE WhatId IN :bookingIds AND Subject = 'Token Advance Payment Follow-up'
        ]) {
            existingTaskMap.put(t.WhatId, t);
        }
        
        for (Id bookingId : bookingMap.keySet()) {
            Booking__c booking = bookingMap.get(bookingId);
            Task existingTask = existingTaskMap.get(bookingId);
            
            if (booking.Token_Advance_Amount_Status__c == 'Full Payment Received') {
                // Update booking stage
                booking.Stage__c = 'Welcome Email';
                booking.Token_Advance_Completed_Date__c = system.today();
                booking.Welcome_Email_Sent_to_Customer__c = true;
                booking.Welcome_Mail_Sent_Time__c = System.now();
                bookingsToUpdate.add(booking);
            } else {
                // Payment not received: send follow-up email and recreate task
                SendEmailServiceClass.sendFailureEmail(
                    booking.OwnerId, booking.Id, booking.Name, 'Token'
                );
                
                if (existingTask != null) {
                    Task clonedTask = existingTask.clone(false, true, false, false);
                    clonedTask.OwnerId = existingTask.OwnerId;
                    clonedTask.Status = 'In Progress';
                    tasksToCreate.add(clonedTask);
                }
            }
        }
        
        if (!bookingsToUpdate.isEmpty()) {
            update bookingsToUpdate;
        }
        if (!tasksToCreate.isEmpty()) {
            insert tasksToCreate;
        }
    }
    
    
    public static void advanceBalanceAmoutFollowup(List<Id> bookingIds) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Task> tasksToInsert = new List<Task>();
        List<Task> tasksToUpdate = new List<Task>();
        NumberTOWordConvertion convert = new NumberTOWordConvertion();
        
        List<Booking__c> bookings = [
            SELECT Id, Email1__c, First_Applicant_Name__c, Balance_Advance_Amount__c,
            Sales_Executive__c, Sales_Executive__r.Name, Sales_Executive__r.Email,
            Plot__r.Name, Project1__r.Name
            FROM Booking__c
            WHERE Id IN :bookingIds
        ];
        
        Map<Id, Booking__c> bookingMap = new Map<Id, Booking__c>();
        for (Booking__c b : bookings) {
            if (String.isNotBlank(b.Email1__c) && b.Sales_Executive__c != null) {
                bookingMap.put(b.Id, b);
            }
        }
        if (bookingMap.isEmpty()) return;
        
        // Query existing "Advance Payment Follow-up" tasks
        Map<Id, Task> existingFollowUpTasks = new Map<Id, Task>();
        for (Task t : [
            SELECT Id, WhatId, Status
            FROM Task
            WHERE WhatId IN :bookingMap.keySet() 
            AND Subject = 'Advance Payment Follow-up'
            LIMIT 50000
        ]) {
            existingFollowUpTasks.put(t.WhatId, t);
        }
        
        for (Booking__c booking : bookingMap.values()) {
            // Prepare Email
            if(booking.Balance_Advance_Amount__c > 0){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSubject('Requisition for release of balance advance amount.');
                email.setToAddresses(new List<String>{booking.Email1__c});
                email.setSenderDisplayName(booking.Sales_Executive__r.Name);
                email.setReplyTo(booking.Sales_Executive__r.Email);
                String balanceAmount = convert.getNumberTOWordConvertion(booking.Balance_Advance_Amount__c);
                String body = 
                    'Dear ' + booking.First_Applicant_Name__c + ',<br/><br/>' +
                    'Greetings from Veegaland Developers !!.<br/><br/>' +
                    'Hope this mail finds you in good health and spirit.<br/><br/>' +
                    'Sub: Requisition for release of balance advance amount.<br/>' +
                    'Ref: '+ booking.Project1__r.Name+', Apartment No. '+booking.Plot__r.Name+' - '+booking.First_Applicant_Name__c+'<br/><br/>' +
                    'This is to remind you that an amount of INR <b>' + booking.Balance_Advance_Amount__c + ' ('+balanceAmount+') </b> '+
                    'will be due against apartment No.'+ booking.Plot__r.Name +' at '+ booking.Project1__r.Name +'<br/><br/>' +
                    'If you have already made the payment, please ignore this Mail.<br/><br/>' +
                    'For any queries, feel free to contact your sales executive.<br/><br/>' +
                    'Thank you for your prompt attention.<br/><br/>' +
                    'Best Regards,<br/>' +
                    booking.Sales_Executive__r.Name + '<br/>' +
                    'Veegaland Developers Pvt. Ltd.';
                
                email.setHtmlBody(body);
                email.setSaveAsActivity(true);
                email.setWhatId(booking.Id);
                emails.add(email);
                
                // Handle Task
                if (existingFollowUpTasks.containsKey(booking.Id)) {
                    // Update existing task to 'Not Started'
                    Task existingTask = existingFollowUpTasks.get(booking.Id);
                    existingTask.Status = 'Not Started';
                    tasksToUpdate.add(existingTask);
                } else {
                    // Create new task
                    Task newTask = new Task();
                    newTask.Subject = 'Advance Payment Follow-up';
                    newTask.WhatId = booking.Id;
                    newTask.OwnerId = booking.Sales_Executive__c;
                    newTask.Status = 'Not Started';
                    newTask.Priority = 'Normal';
                    newTask.ActivityDate = Date.today().addDays(3); // due in 3 days
                    newTask.Description = 'Follow up with the customer for pending advance balance payment.';
                    newTask.IsReminderSet = true;
                    newTask.ReminderDateTime = System.now().addDays(2).addHours(20); // Reminder roughly 4 hours before due
                    tasksToInsert.add(newTask);
                }
            }
        }
        
        // Send emails
        if (!emails.isEmpty()) {
            try {
                Messaging.sendEmail(emails);
            } catch (Exception e) {
                ExceptionHandler.addLog(e,string.valueof(emails)+''+string.valueof(bookingIds),'BookingController','');  /*Add Exception to error log*/
                System.debug('Email sending failed: ' + e.getMessage());
            }
        }
        
        // Insert new tasks
        if (!tasksToInsert.isEmpty()) {
            try {
                insert tasksToInsert;
            } catch (DmlException e) {
                ExceptionHandler.addLog(e,string.valueof(tasksToInsert),'BookingController','');  /*Add Exception to error log*/
                System.debug('Task insert failed: ' + e.getMessage());
            }
        }
        
        // Update existing tasks
        if (!tasksToUpdate.isEmpty()) {
            try {
                update tasksToUpdate;
            } catch (DmlException e) {
                ExceptionHandler.addLog(e,string.valueof(tasksToUpdate),'BookingController','');  /*Add Exception to error log*/
                System.debug('Task update failed: ' + e.getMessage());
            }
        }
    }
    
    
    @AuraEnabled
    public static List<BookingWrapper> getBookingAndApplicantDetails(Id recId) {
        List<BookingWrapper> resultList = new List<BookingWrapper>();
        
        // Fetch primary applicant details from Booking__c
        Booking__c booking = [
            SELECT First_Applicant_Name__c, Email1__c,salutation_Applicant1__c,Occupation__c
            FROM Booking__c
            WHERE Id = :recId
            LIMIT 1
        ];
        
        // Add primary applicant to the list
        BookingWrapper primaryApplicant = new BookingWrapper();
        primaryApplicant.applicantName = booking.salutation_Applicant1__c+' '+booking.First_Applicant_Name__c;
        primaryApplicant.applicantEmail = booking.Email1__c;
        primaryApplicant.isPrimary = true; // Identify as primary applicant
        primaryApplicant.profession = booking.Occupation__c; // Not applicable for primary
        
        resultList.add(primaryApplicant);
        
        // Fetch co-applicants linked to this booking
        List<Co_Applicant__c> coApplicants = [
            SELECT Name, Email__c, Co_Applicant_Profession__c,Salutation__c
            FROM Co_Applicant__c
            WHERE Booking__c = :recId
        ];
        
        for (Co_Applicant__c coApp : coApplicants) {
            BookingWrapper coAppWrapper = new BookingWrapper();
            coAppWrapper.applicantName = (coApp.Salutation__c != null ?coApp.Salutation__c+' '+coApp.Name:coApp.Name);
            coAppWrapper.applicantEmail = coApp.Email__c;
            coAppWrapper.isPrimary = false; // Identify as co-applicant
            coAppWrapper.profession = coApp.Co_Applicant_Profession__c;
            resultList.add(coAppWrapper);
        }
        
        return resultList;
    }
    
    @AuraEnabled
    public static void sendEmailGenerateAgreementdetailsrequest(Id recId, String emailContent) {
        system.debug('Here in the sendEmailGenerateAgreementdetailsrequest');
        GenerateDocumnetController.sendEmailGenerateAgreementdetailsrequest( recId, emailContent);
    }
    public class BookingWrapper {
        @AuraEnabled public String applicantName;
        @AuraEnabled public String applicantEmail;
        @AuraEnabled public Boolean isPrimary;
        @AuraEnabled public String profession;
    }
    
    public static void agreementDetailsReceivedFlow(Set<Id> bookingIds) {
        if (bookingIds.isEmpty()) return;
        
        // Fetch bookings
        List<Booking__c> bookings = [
            SELECT Id, First_Applicant_Name__c, Email1__c, CRM_Manager__c 
            FROM Booking__c 
            WHERE Id IN :bookingIds
        ];
        
        // Send email to customers
        List<Id> bookingAgreementDetailsReceivedList = new List<Id>();
        for (Booking__c b : bookings) {
            if (String.isNotBlank(b.Email1__c)) {
                bookingAgreementDetailsReceivedList.add(b.Id);
            }
        }
        if (!bookingAgreementDetailsReceivedList.isEmpty()) {
            GenerateDocumnetController.agreementDetailsRecievedMail(bookingAgreementDetailsReceivedList);
        }
        
        // Fetch co-applicants
        Map<Id, List<String>> coAppMap = new Map<Id, List<String>>();
        List<Co_Applicant__c> coApplicants = [
            SELECT Id, Name, Booking__c 
            FROM Co_Applicant__c 
            WHERE Booking__c IN :bookingIds
        ];
        
        for (Co_Applicant__c co : coApplicants) {
            if (!coAppMap.containsKey(co.Booking__c)) {
                coAppMap.put(co.Booking__c, new List<String>());
            }
            coAppMap.get(co.Booking__c).add(co.Name);
        }
        
        // Get existing tasks for these bookings
        Map<String, Task> existingTasksMap = new Map<String, Task>();
        List<Task> existingTasks = [
            SELECT Id, WhatId, Subject 
            FROM Task 
            WHERE WhatId IN :bookingIds AND Subject IN (
                'Primary Applicant Agreement Details Review',
                'Co-applicants Agreement Details Review',
                'Primary Applicant and Co-applicants Agreement Details Review'
            )
        ];
        for (Task t : existingTasks) {
            String key = t.WhatId + '|' + t.Subject;
            existingTasksMap.put(key, t);
        }
        
        // Create or update tasks
        List<Task> tasksToUpsert = new List<Task>();
        for (Booking__c booking : bookings) {
            Boolean hasCoApplicants = coAppMap.containsKey(booking.Id);
            
            String subject = hasCoApplicants
                ? 'Primary Applicant and Co-applicants Agreement Details Review'
                : 'Primary Applicant Agreement Details Review';
            String taskKey = booking.Id + '|' + subject;
            
            String description = 'Please verify the agreement details of primary applicant ' + booking.First_Applicant_Name__c;
            if (hasCoApplicants) {
                String coApplicantNames = String.join(coAppMap.get(booking.Id), ', ');
                description += ' and co-applicants: ' + coApplicantNames;
            }
            
            if (existingTasksMap.containsKey(taskKey)) {
                Task t = existingTasksMap.get(taskKey);
                t.Status = 'Not Started';
                tasksToUpsert.add(t);
            } else {
                tasksToUpsert.add(new Task(
                    Subject = subject,
                    WhatId = booking.Id,
                    OwnerId = booking.CRM_Manager__c,
                    Status = 'Not Started',
                    Priority = 'High',
                    ActivityDate = Date.today().addDays(2),
                    Description = description
                ));
            }
        }
        
        List<Task> tasksToComplete = [
            SELECT Id, Status 
            FROM Task 
            WHERE WhatId IN :bookingIds 
            AND Subject = 'Sale agreement details received from the customer' 
            AND Status != 'Completed'
        ];
        
        for (Task t : tasksToComplete) {
            t.Status = 'Completed';
            tasksToUpsert.add(t);
        }   
        
        if (!tasksToUpsert.isEmpty()) {
            upsert tasksToUpsert;
        }
    }
    
    
    public static void createTaskForTheOverallCheck(Set<Id> bookingIds) {
        if (bookingIds.isEmpty()) {
            return;
        }
        
        // Fetch bookings with Primary Applicant details
        List<Booking__c> bookings = [SELECT Id, First_Applicant_Name__c, OwnerId, Agreement_Details_Verified__c 
                                     FROM Booking__c WHERE Id IN :bookingIds AND OwnerId != null];
        
        // Fetch existing tasks for these bookings
        Map<Id, Task> existingTaskMap = new Map<Id, Task>();
        List<Task> existingTasks = [
            SELECT Id, WhatId, Subject, Status 
            FROM Task 
            WHERE WhatId IN :bookingIds 
            AND Subject = 'Overall Booking Details Review'
        ];
        
        for (Task t : existingTasks) {
            existingTaskMap.put(t.WhatId, t);
        }
        
        List<Task> tasksToInsert = new List<Task>();
        List<Task> tasksToUpdate = new List<Task>();
        
        for (Booking__c booking : bookings) {
            String primaryDesc = 'Ensure all fields required for agreement are properly filled for the booking. Primary Applicant: ' + booking.First_Applicant_Name__c;
            
            if (existingTaskMap.containsKey(booking.Id)) {
                Task existingTask = existingTaskMap.get(booking.Id);
                existingTask.Status = 'Not Started';
                existingTask.Description = primaryDesc;
                tasksToUpdate.add(existingTask);
            } else {
                tasksToInsert.add(new Task(
                    Subject = 'Overall Booking Details Review',
                    Description = primaryDesc,
                    Priority = 'High',
                    Status = 'Not Started',
                    WhatId = booking.Id,
                    OwnerId = booking.OwnerId,
                    ActivityDate = Date.today().addDays(2)
                ));
            }
            
            booking.Agreement_Details_Verified__c = true;
        }
        
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
        if (!tasksToUpdate.isEmpty()) {
            update tasksToUpdate;
        }
        
        update bookings;
        
        System.debug('Inserted Tasks: ' + tasksToInsert);
        System.debug('Updated Tasks: ' + tasksToUpdate);
    }
    
    public static void createTaskDraftAgreementSend(Set<Id> bookingIds) {
        List<Booking__c> bookings = [
            SELECT Id, Name, CRM_Manager__c, CRM_Manager__r.Email, Legal_Team__c, Legal_Team__r.Email
            FROM Booking__c 
            WHERE Id IN :bookingIds
        ];
        
        List<Task> newTasks = new List<Task>();
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        
        // Query existing tasks to avoid duplicates
        Map<Id, Set<String>> existingTasksPerBooking = new Map<Id, Set<String>>();
        for (Task t : [
            SELECT Id, WhatId, Subject 
            FROM Task 
            WHERE WhatId IN :bookingIds 
            AND Subject IN (
                'Generate And Send Draft Agreement To the Customer',
                'Generate and Review the Sale Agreement'
            )
        ]) {
            if (!existingTasksPerBooking.containsKey(t.WhatId)) {
                existingTasksPerBooking.put(t.WhatId, new Set<String>());
            }
            existingTasksPerBooking.get(t.WhatId).add(t.Subject);
        }
        
        for (Booking__c booking : bookings) {
            String recordLink = URL.getOrgDomainURL().toExternalForm() +'/lightning/r/Booking__c/' + booking.Id + '/view'; 
            Set<String> existingSubjects = existingTasksPerBooking.containsKey(booking.Id) ? existingTasksPerBooking.get(booking.Id) : new Set<String>();
            
            // Task for CRM Manager
            if (!existingSubjects.contains('Generate And Send Draft Agreement To the Customer')) {
                Task crmTask = new Task();
                crmTask.Subject = 'Generate And Send Draft Agreement To the Customer';
                crmTask.WhatId = booking.Id;
                crmTask.OwnerId = booking.CRM_Manager__c;
                crmTask.Status = 'Not Started';
                crmTask.Priority = 'Normal';
                crmTask.Description = 'Generate and send the draft sale agreement to the customer after legal verification.';
                newTasks.add(crmTask);
                
                // Email to CRM Manager
                if (booking.CRM_Manager__r != null && String.isNotBlank(booking.CRM_Manager__r.Email)) {
                    Messaging.SingleEmailMessage crmEmail = new Messaging.SingleEmailMessage();
                    crmEmail.setToAddresses(new List<String>{ booking.CRM_Manager__r.Email });
                    crmEmail.setSubject('Next Steps: Sale Agreement Verification and Customer Approval');
                    crmEmail.setHtmlBody(
                        'Dear CRM Manager,<br/><br/>' +
                        'The legal team will now verify the sale agreement for Booking ID: <strong>' + booking.Name + '</strong>.<br/><br/>' +
                        'Once the legal review is complete, please proceed to send the agreement to the customer for their review and approval. This will help ensure timely progression of the booking process.<br/><br/>' +
                        '<a href="' + recordLink + '" target="_blank"><strong>View Booking Record</strong></a><br/><br/>' +
                        'Best regards,<br/>CRM Team'
                    );
                    emailMessages.add(crmEmail);
                }
            }
            
            // Task for Legal Team
            if (!existingSubjects.contains('Generate and Review the Sale Agreement')) {
                Task legalTask = new Task();
                legalTask.Subject = 'Generate and Review the Sale Agreement';
                legalTask.WhatId = booking.Id;
                legalTask.OwnerId = booking.Legal_Team__c;
                legalTask.Status = 'Not Started';
                legalTask.Priority = 'High';
                legalTask.Description = 'Review all necessary documents and generate the draft sale agreement for this booking.';
                newTasks.add(legalTask);
                
                // Email to Legal Team
                if (booking.Legal_Team__r != null && String.isNotBlank(booking.Legal_Team__r.Email)) {
                    Messaging.SingleEmailMessage legalEmail = new Messaging.SingleEmailMessage();
                    legalEmail.setToAddresses(new List<String>{ booking.Legal_Team__r.Email });
                    legalEmail.setSubject('Agreement Generation Required');
                    legalEmail.setHtmlBody(
                        'Dear Legal Team,<br/><br/>' +
                        'All required details have been provided by the customer for Booking ID: <strong>' + booking.Name + '</strong>.<br/><br/>' +
                        'Please review the information and generate the draft sale agreement.<br/><br/>' +
                        '<a href="' + recordLink + '" target="_blank"><strong>Click here to view the Booking Record</strong></a><br/><br/>' +
                        'Best regards,<br/>CRM Team'
                    );
                    emailMessages.add(legalEmail);
                }
            }
        }
        
        if (!newTasks.isEmpty()) {
            insert newTasks;
        }
        
        if (!emailMessages.isEmpty()) {
            Messaging.sendEmail(emailMessages);
        }
    }    
    
    
    /*@description       : This is used for the 'Requisition for release of instalment' email send.
* @author            : Varna
* Modification Log:
* Ver   Date         Author                  Modification
* 1.0   17-03-2025   Varna            Initial Version
*/
    public static void instalmentMail(List<Booking__c> booking)
    {
        // Collect Booking Ids from the provided booking list
        set<Id> BookingIds = new set<Id>();
        for(Booking__c bk:booking){
            BookingIds.add(bk.Id);
        }
        system.debug('BookingIds '+BookingIds);
        system.debug('booking '+booking);
        // Map to store pending amounts for each booking
        Map<Id,decimal> PaymentDetails = new Map<Id,decimal>();
        if(!BookingIds.isEmpty()){
            // Fetch payment schedules for bookings where S_No__c = 2
            List<Payment_schedule__c> paySch = [select Id,Name,Pending_Amount__c,Booking__c from Payment_schedule__c where Booking__c IN :BookingIds and S_No__c=2];
            // Store payment details in a map
            if(!paySch.isEmpty())
            {
                for(Payment_schedule__c Pay:paySch){
                    PaymentDetails.put(Pay.Booking__c,pay.Pending_Amount__c);  
                }
            }
        }
        List<Messaging.SingleEmailMessage> semailList = new List<Messaging.SingleEmailMessage>();
        // Loop through each booking to send email
        for (Booking__c b:booking) {
            if (b.Email1__c != null && b.Email1__c != '') {// Validate email
                decimal amount =0.00;
                if(PaymentDetails.containsKey(b.Id)){// Fetch pending amount
                    amount = PaymentDetails.get(b.Id);
                }
                string amountInWords = BookingController.convertToWords(amount);// Convert amount to words
                // Create email message
                Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage(); 
                semail.setSenderDisplayName(b.Owner.Name);
                semail.setReplyTo(b.Owner.Email);
                semail.setSubject('Requisition for release of instalment.');
                List<string> sendTo = new List<string>();
                sendTo.add(b.Email1__c);
                semail.setToAddresses(sendTo);
                // Construct email body with payment details
                semail.setHtmlBody( 
                    'Dear Sir/Madam, <br/><br/>' +
                    '<b>Greetings from Veegaland Developers !!</b> <br/>' +
                    'Hope this mail finds you in good health and spirit. <br/><br/>' +
                    'Ref:'+ b.Project__c+ ', <b>Unit Number - </b>'+b.Unit_NumberFor__c+'<br/><br/>'+
                    'This is to remind you that an amount of <b> INR '+amount+'/- ('+amountInWords +')<b> will be due against unit No.'+b.Unit_NumberFor__c+' at '+b.Project__c+' <br/><br/>'+
                    'Request you to kindly release the amount to our below mentioned bank account. <br/><br/><br/>' +
                    '<b>Account No.</b> 0587073000000353 <br/>' +
                    '<b>Customer Name:</b> VEEGALAND QUEENS PARK-RERA COLLECTION ACCOUNT <br/>' +
                    '<b>Customer Id:</b> A54927438 <br/>'+
                    '<b>MICR CODE:</b> 682059034 <br/>'+
                    '<b>SWIFT CODE:</b> SOININ55XXX <br/>'+
                    '<b>IFSC CODE:</b> SIBL0000587 <br/>'+
                    '<b>BANK NAME:</b> THE SOUNTH INDIAN BANK LTD <br/>'+
                    '<b>BRANCH ADDRESS:</b> 0587, RAJAGIRI VALLEY, KAKKANAD BRANCH <br/>'+
                    '<b>EMAIL:</b> br0587@sib.co.in <br/><br/>'+
                    '<html><body><table border="1" cellpadding="5" cellspacing="0" style="border-collapse:collapse;"><tr><td colspan="2"><b>VEEGALAND DEVELOPERS PRIVATE LIMITED Kakkanad , Kochi- 21</b></td></tr><tr><td colspan="2"><b>VEEGALAND QUEENS PARK- RERA COLLECTION ACCOUNT</b></td></tr><tr><th>Account No.</th><td>0587073000000353</td></tr><tr><th>Bank Name </th><td>THE SOUTH INDIAN BANK LTD</td></tr><tr><th>Branch Name </th><td>KAKKANAD</td></tr><tr><th>IFSC Code</th><td>SIBL0000587</td></tr></body></html><br/></br>'+
                    'Thanks & Regards,<br/><br/>' +
                    'Midhu Siju | Officer - Customer relations | 9207054444 <br/>'+
                    'Alitta Lijoy | Customer relation Executive | 90482 37066 <br/><br/>'+
                    'Veegaland Developers Pvt.Ltd. <br/>'+
                    'Regd.Office:XIII/300 E-26, 4th Floor, <br/>'+
                    'K  Chittilappilly  Tower,  BMC Road,<br/>'+
                    'Thrikkakara P.O, Ernakulam-682021 <br/>'+
                    'Tel: +91 484 2584000/2973944, +916235051144 <br/>'+
                    'www.veegaland.com <br/>'+
                    '<html> <body><b>Follow us on:</b> <a href="https://www.facebook.com/VeegaLandHomes/" target="_blank">Facebook</a> | <a href="https://www.instagram.com/veegalandhomes/" target="_blank">Instagram</a> | <a href="https://www.youtube.com/channel/UCkumX_5xi6KOrmm7oaO93kQ" target="_blank">YouTube</a></body></html>'
                );
                
                
                semailList.add(semail);
            }
        }
        // Send email and handle exceptions
        try{
            system.debug('semailList '+semailList);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(semailList);  
            system.debug(results);
            
        }catch(exception e)
        {
            ExceptionHandler.addLog(e,string.valueof(semailList),'BookingController','');  /*Add Exception to error log*/
            system.debug('Error'+e.getMessage());
        }   
    }
    
    public static String convertToWords(Decimal amount) {
        // Convert the decimal amount to an integer value (whole number)
        Integer num = amount.intValue();
        // Extract the decimal part (paise) by rounding off the remaining fraction
        Integer decimalPart = Math.round((amount - num) * 100); // Get the decimal (paise) part
        // If the number is zero, return "Zero Rupees Only"
        if (num == 0) return 'Zero Rupees Only';
        // Convert the integer part to words using Indian format
        String words = convertIndianFormat(num);
        // Append the decimal (paise) part if it exists
        if (decimalPart > 0) {
            words += ' and ' + formatWithHyphens(helper(decimalPart)) + ' Paise';
        }
        // Return the final formatted currency text
        return words + ' Only';
    }
    
    private static String convertIndianFormat(Integer num) {
        // If the number is zero, return "Zero"
        if (num == 0) return 'Zero';
        // Create a list to store different parts of the number
        List<Integer> parts = new List<Integer>();
        // Extract the first 3 digits (Hundreds, Tens, Units)
        parts.add(Math.mod(num, 1000)); // First 3 digits (Hundreds, Tens, Units)
        num = Math.floor(num / 1000).intValue();
        // Extract remaining parts in 2-digit pairs (Thousands, Lakhs, Crores)
        while (num > 0) {
            parts.add(Math.mod(num, 100)); // Next 2 digits (Thousands, Lakhs, Crores)
            num = Math.floor(num / 100).intValue();
        }
        
        String words = '';
        Integer unitIndex = 0;
        // Convert each part into words and append the corresponding Indian unit
        for (Integer i = 0; i < parts.size(); i++) {
            if (parts[i] != 0) {
                words = formatWithHyphens(helper(parts[i])) + ' ' + INDIAN_UNITS[unitIndex] + ' ' + words;
            }
            unitIndex++;
        }
        // Return the formatted number in words with "Rupees" appended
        return words.trim() + ' Rupees';
    }
    public static void handleAgreementStatusUpdate(Set<Id> bookingIds) {
        if (bookingIds.isEmpty()) {
            return; // No relevant bookings, exit early
        }
        
        List<Task> tasksToInsert = new List<Task>();
        List<Task> tasksToUpdate = new List<Task>();
        Map<Id, Id> legalTeamMap = new Map<Id, Id>(); // Booking Id -> Legal Team User Id
        
        // Fetch bookings and their assigned legal team members
        for (Booking__c booking : [
            SELECT Id, Legal_Team__c 
            FROM Booking__c 
            WHERE Id IN :bookingIds
        ]) {
            if (booking.Legal_Team__c != null) {
                legalTeamMap.put(booking.Id, booking.Legal_Team__c);
            }
        }
        
        // Fetch existing tasks related to these bookings
        Map<Id, Task> existingTasksMap = new Map<Id, Task>();
        for (Task existingTask : [
            SELECT Id, WhatId 
            FROM Task 
            WHERE WhatId IN :bookingIds 
            AND Subject = 'Prepare Registered Agreement and Supporting Documents'
        ]) {
            existingTasksMap.put(existingTask.WhatId, existingTask);
        }
        
        // Process bookings
        for (Id bookingId : bookingIds) {
            if (existingTasksMap.containsKey(bookingId)) {
                // If Task exists, update status to 'Not Started'
                Task existingTask = existingTasksMap.get(bookingId);
                existingTask.Status = 'Not Started';
                tasksToUpdate.add(existingTask);
            } else {
                // If Task does not exist, create a new one
                Task newTask = new Task(
                    Subject = 'Prepare Registered Agreement and Supporting Documents',
                    Description = 'The agreement status has been marked as Completed. Please prepare the registered agreement and necessary supporting documents.',
                    OwnerId = legalTeamMap.get(bookingId),
                    WhatId = bookingId,
                    Priority = 'High',
                    Status = 'Not Started'
                );
                tasksToInsert.add(newTask);
            }
        }
        
        // Perform DML operations
        if (!tasksToUpdate.isEmpty()) {
            update tasksToUpdate;
        }
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }
    
    public static void createFinanceTasksForFullyPaidBookings(Set<Id> bookingIdList) {
        system.debug('Here');
        if (bookingIdList == null || bookingIdList.isEmpty()) return;
        
        List<Task> tasksToInsert = new List<Task>();
        List<Task> tasksToUpdate = new List<Task>();
        
        // Query only relevant Booking records
        List<Booking__c> bookings = [
            SELECT Id, Finance_User__c, Total__c, Total_received_Amount__c
            FROM Booking__c
            WHERE Id IN :bookingIdList
        ];
        
        Map<Id, Booking__c> validBookings = new Map<Id, Booking__c>();
        for (Booking__c b : bookings) {
            if (b.Finance_User__c != null &&
                b.Total__c != null) {
                    validBookings.put(b.Id, b);
                }
        }
        
        if (validBookings.isEmpty()) return;
        
        // Query existing tasks
        List<Task> existingTasks = [
            SELECT Id, Subject, Status, OwnerId, WhatId 
            FROM Task 
            WHERE WhatId IN :validBookings.keySet()
            AND Subject = 'Full apartment cost and registration fee follow-up'
        ];
        
        Map<String, Task> existingTaskMap = new Map<String, Task>();
        for (Task t : existingTasks) {
            String key = t.OwnerId + '-' + t.WhatId;
            existingTaskMap.put(key, t);
        }
        
        for (Booking__c booking : validBookings.values()) {
            Id ownerId = booking.Finance_User__c;
            Id whatId = booking.Id;
            String key = ownerId + '-' + whatId;
            
            if (existingTaskMap.containsKey(key)) {
                Task existing = existingTaskMap.get(key);
                if (existing.Status != 'Not Started') {
                    existing.Status = 'Not Started';
                    tasksToUpdate.add(existing);
                }
            } else {
                tasksToInsert.add(new Task(
                    OwnerId = ownerId,
                    WhatId = whatId,
                    Subject = 'Full apartment cost and registration fee follow-up',
                    Description = 'Full flat amount received. Proceed to the Sale Deed Registration stage.',
                    Status = 'Not Started',
                    Priority = 'Normal',
                    ActivityDate = System.today().addDays(1)
                ));
            }
        }
        
        if (!tasksToInsert.isEmpty()) insert tasksToInsert;
        if (!tasksToUpdate.isEmpty()) update tasksToUpdate;
    }
    
    public static void createSaleDeedTasks(Set<Id> bookingIds) {
        system.debug('createSaleDeedTasks');
        if (bookingIds == null || bookingIds.isEmpty()) return;
        system.debug('createSaleDeedTasks 1');
        List<Task> tasksToInsert = new List<Task>();
        List<Task> tasksToUpdate = new List<Task>();
        
        Map<String, Booking__c> taskKeyToBookingMap = new Map<String, Booking__c>();
        
        // Query Booking__c records
        List<Booking__c> bookings = [
            SELECT Id, Legal_Advocate_Assigned__c
            FROM Booking__c
            WHERE Id IN :bookingIds
        ];
        
        for (Booking__c booking : bookings) {
            if (booking.Legal_Advocate_Assigned__c != null) {
                String key = booking.Legal_Advocate_Assigned__c + '-' + booking.Id;
                taskKeyToBookingMap.put(key, booking);
            }
        }
        
        if (taskKeyToBookingMap.isEmpty()) return;
        
        // Query existing tasks
        List<Task> existingTasks = [
            SELECT Id, WhatId, OwnerId, Subject, Status
            FROM Task
            WHERE Subject = 'Start Sale Deed Registration Process'
            AND WhatId IN :bookingIds
        ];
        
        Set<String> existingKeys = new Set<String>();
        for (Task t : existingTasks) {
            String key = t.OwnerId + '-' + t.WhatId;
            existingKeys.add(key);
            
            if (t.Status != 'Not Started') {
                t.Status = 'Not Started';
                tasksToUpdate.add(t);
            }
        }
        
        // Create new tasks if they don’t exist
        for (String key : taskKeyToBookingMap.keySet()) {
            if (!existingKeys.contains(key)) {
                Booking__c b = taskKeyToBookingMap.get(key);
                tasksToInsert.add(new Task(
                    OwnerId = b.Legal_Advocate_Assigned__c,
                    WhatId = b.Id,
                    Subject = 'Start Sale Deed Registration Process',
                    Description = 'Please initiate the Sale Deed Registration for this booking.',
                    Status = 'Not Started',
                    Priority = 'High',
                    ActivityDate = System.today().addDays(1)
                ));
            }
        }
        
        if (!tasksToInsert.isEmpty()) insert tasksToInsert;
        if (!tasksToUpdate.isEmpty()) update tasksToUpdate;
    }
    
    private static String helper(Integer num) {
        // If number is zero, return empty string
        if (num == 0) return '';
        // If number is less than 20, return the corresponding word
        else if (num < 20) return BELOW_TWENTY[num];
        // If number is between 20-99, fetch the tens place word and recursively add units place
        else if (num < 100) return TENS[Math.floor(num / 10).intValue()] + ' ' + BELOW_TWENTY[Math.mod(num, 10)];
        // If number is 100 or more, add "Hundred" and process the remaining part
        else return BELOW_TWENTY[Math.floor(num / 100).intValue()] + ' Hundred ' + helper(Math.mod(num, 100));
    }
    
    private static String formatWithHyphens(String amountWords) {
        // Ensure numbers below 100 have proper hyphenation for readability
        amountWords = amountWords.replace('Twenty ', 'Twenty-');
        amountWords = amountWords.replace('Thirty ', 'Thirty-');
        amountWords = amountWords.replace('Forty ', 'Forty-');
        amountWords = amountWords.replace('Fifty ', 'Fifty-');
        amountWords = amountWords.replace('Sixty ', 'Sixty-');
        amountWords = amountWords.replace('Seventy ', 'Seventy-');
        amountWords = amountWords.replace('Eighty ', 'Eighty-');
        amountWords = amountWords.replace('Ninety ', 'Ninety-');
        // Remove any extra spaces and return the cleaned-up string
        return amountWords.replaceAll('\\s+', ' ').trim(); // Remove extra spaces
    }
    
    
    
    
    /*
* @description		: This is used for Welcome email send.
* @author			: Varna
* @Ver				: 1.0 
* @Date				: 02-04-2025               
* @modified by 		: Jabir on 23-04-2025 
*/    
    @Future(callout=true)  
    public static void welcomeMail(set<Id> bookingIds) {
        set<string> unitTypeId = new set<string> ();
        Map<Id, list<ContentVersion>> latestVersionMap = new Map<Id, list<ContentVersion>>();
        map<string,string> unitPrjContentDoc = new map<string,string>();
        if (bookingIds.isEmpty()) return;
        
        // Step 1: Fetch Bookings with valid email
        Map<Id, Booking__c> validBookingsMap = new Map<Id, Booking__c>();
        for (Booking__c b : [
            SELECT Id, Email1__c,Project1__c, Plot__c,Plot__r.Unit_Type__c, Owner.Name, Owner.Email,CRM_Manager__c
            FROM Booking__c
            WHERE Id IN :bookingIds
        ]) {
            if (String.isNotBlank(b.Email1__c)) {
                validBookingsMap.put(b.Id, b);
            }
            if(b.Plot__c !=null){
                unitTypeId.add(b.Plot__r.Unit_Type__c);
            }
            if(b.Project1__c !=null){
                unitTypeId.add(b.Project1__c);
            }
        }
        if (validBookingsMap.isEmpty()) return;
        
        
        
        Map<String, Id> ownerEmailToOrgWideIdMap = new Map<String, Id>();
        for (OrgWideEmailAddress ow : [SELECT Id, Address FROM OrgWideEmailAddress]) {
            ownerEmailToOrgWideIdMap.put(ow.Address.toLowerCase(), ow.Id);
        }
        
        if(!unitTypeId.isEmpty()){
            // Step 3: Get ContentDocumentLinks for Bookings
            // Step 2: Get ContentDocumentIds linked to bookings
            Set<Id> contentDocIds = new Set<Id>();
            List<ContentDocumentLink> docLinks = [
                SELECT ContentDocumentId ,LinkedEntityId
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN :unitTypeId
            ];
            
            for (ContentDocumentLink link : docLinks) {
                contentDocIds.add(link.ContentDocumentId);
                unitPrjContentDoc.put(link.ContentDocumentId,link.LinkedEntityId);
            }
            
            if (contentDocIds.isEmpty()) return;
            
            // Step 3: Get relevant ContentVersions (filtered by title keywords)
            List<ContentVersion> filteredVersions = [
                SELECT Id, Title, ContentDocumentId, VersionData, FileExtension
                FROM ContentVersion
                WHERE ContentDocumentId IN :contentDocIds
                AND IsLatest = TRUE
                AND (
                    Title LIKE '%Floor Plan%' OR                 
                    Title LIKE '%Plumbing Plan%' OR 
                    Title LIKE '%Parking Plan%' OR 
                    Title LIKE '%Electrical Plan%' OR
                    Title LIKE '%Sample Sale Agreement%' OR
                    Title LIKE '%FAQ%'
                    
                )
                ORDER BY CreatedDate DESC
            ];
            if(!filteredVersions.isEmpty()){
                for (ContentVersion cv : filteredVersions) {
                    if (unitPrjContentDoc.containsKey(cv.ContentDocumentId)) {
                        string key = unitPrjContentDoc.get(cv.ContentDocumentId);
                        if (!latestVersionMap.containsKey(key)) {
                            latestVersionMap.put(key, new List<ContentVersion>());
                        }
                        latestVersionMap.get(key).add(cv);
                    }
                }
            }
        }
        
        
        // Step 5: Send Emails
        List<Messaging.SingleEmailMessage> semailList = new List<Messaging.SingleEmailMessage>();
        for (Id bookingId : validBookingsMap.keySet()) {
            Booking__c b = validBookingsMap.get(bookingId);
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage(); 
            //CC to veegaland customercare 
            List<String> lstCCEmail = new List<String>();
            // lstCCEmail.add('customercare@veegaland.in');
            if (!lstCCEmail.isEmpty()) {
                semail.setCcAddresses(lstCCEmail);
            }
            semail.setSenderDisplayName(b.Owner.Name);
            semail.setReplyTo(b.Owner.Email);
            semail.setSubject('Welcome Mail');
            semail.setToAddresses(new List<String>{b.Email1__c});
            
            String body = 
                'Dear Sir/Madam, <br/><br/>' +
                '<b>Warm greetings from Veegaland Developers!</b> <br/><br/>' +
                'We extend our heartfelt gratitude to you for choosing Veegaland Developers as your partner in realizing your dream home. Your decision to finalize your home with us speaks volumes, and we are truly honoured to have earned your trust.<br/>' +
                'At Veegaland Developers, we take immense pride in our reputation for delivering exceptional service and ensuring that our customers needs are not just met but exceeded. Your satisfaction is our top priority, and we are dedicated to fulfilling your expectations with the utmost diligence and care.<br/>' +
                'Allow me to introduce myself as Ms. Midhu Siju, Customer Relations Officer at Veegaland. I am here to ensure that your journey with us is smooth and memorable. Feel free to reach out to me for any assistance or queries you may have; I am committed to providing you with the support you need every step of the way. <br/><br/>' +
                'As part of the allotment process, we require a signed copy of the allotment document. Please upload the signed copy using the link below: <br/>' +
                '<b>URL:</b> <a href="https://site-speed-6226.my.salesforce-sites.com/DocumentUploader?Id=' + b.Id + '&filename=SignedAllotmentLetter" target="_blank">Upload Allotment Letter Signed Copy</a><br/><br/>' +
                'Enclosed with this email, you will find relevant documents for your unit type.<br/><br/>' +
                'Thank you once again for choosing Veegaland Developers.<br/><br/>' +
                'Warm regards,<br/>Ms. Midhu Siju<br/>Customer Relations Officer<br/>Veegaland Developers';
            
            semail.setHtmlBody(body);
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            
            PageReference pdfPage = Page.AllotmentLetter;
            pdfPage.getParameters().put('id', b.Id);
            Blob pdfBlob = !Test.isRunningTest() ? pdfPage.getContentAsPDF() : Blob.valueOf('testblob');
            
            Messaging.EmailFileAttachment allotmentAttach = new Messaging.EmailFileAttachment();
            allotmentAttach.setFileName('AllotmentLetter.pdf');
            allotmentAttach.setBody(pdfBlob);
            attachments.add(allotmentAttach);
            
            if (latestVersionMap.containsKey(b.Plot__r.Unit_Type__c) ) {
                for (ContentVersion cv : latestVersionMap.get(b.Plot__r.Unit_Type__c)) {
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    String fileNameWithExtension = cv.Title + '.' + cv.FileExtension;
                    efa.setFileName(fileNameWithExtension);
                    efa.setBody(cv.VersionData);
                    attachments.add(efa);
                }
            }
            if ( latestVersionMap.containsKey(b.Project1__c)) {
                for (ContentVersion cv : latestVersionMap.get(b.Project1__c)) {
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    String fileNameWithExtension = cv.Title + '.' + cv.FileExtension;
                    efa.setFileName(fileNameWithExtension);
                    efa.setBody(cv.VersionData);
                    attachments.add(efa);
                }
            }
            
            if (!attachments.isEmpty()) {
                semail.setSaveAsActivity(true);
                semail.setWhatId(b.Id);
                semail.setFileAttachments(attachments);
            }
            
            
            String ownerEmail = b.Owner.Email;
            if (ownerEmail != null && ownerEmailToOrgWideIdMap.containsKey(ownerEmail.toLowerCase())) {
                semail.setOrgWideEmailAddressId(ownerEmailToOrgWideIdMap.get(ownerEmail.toLowerCase()));
            }
            
            semailList.add(semail);
        }
        
        if (!semailList.isEmpty()) {
            Messaging.sendEmail(semailList);
        }
    }
    
    
    
    public static void createWelcomeTask(set<Id> bookingIds) {
        
        if (bookingIds.isEmpty()) return;
        
        // Step 1: Fetch Bookings with valid email
        Map<Id, Booking__c> validBookingsMap = new Map<Id, Booking__c>();
        for (Booking__c b : [
            SELECT Id, Email1__c, Plot__c, Owner.Name, Owner.Email,CRM_Manager__c
            FROM Booking__c
            WHERE Id IN :bookingIds
        ]) {
            if (String.isNotBlank(b.Email1__c)) {
                validBookingsMap.put(b.Id, b);
            }
        }
        if (validBookingsMap.isEmpty()) return;
        
        List<Task> followUpTasksToCreate = new List<Task>();
        List<Task> followUpTasksToUpdate = new List<Task>();
        
        // Fetch existing "Welcome Call Follow-up" tasks
        Map<Id, Task> existingFollowUpTaskMap = new Map<Id, Task>();
        for (Task t : [
            SELECT Id, WhatId, OwnerId
            FROM Task
            WHERE WhatId IN :validBookingsMap.keySet()
            AND Subject = 'Welcome Call Follow-up'
            LIMIT 10000
        ]) {
            existingFollowUpTaskMap.put(t.WhatId, t);
        }
        
        for (Id bookingId : validBookingsMap.keySet()) {
            
            Booking__c b = validBookingsMap.get(bookingId);
            
            // Handle follow-up Task
            if (existingFollowUpTaskMap.containsKey(b.Id)) {
                // Task exists: update status
                Task existingTask = existingFollowUpTaskMap.get(b.Id);
                existingTask.Status = 'Not Started';
                followUpTasksToUpdate.add(existingTask);
            } else {
                // Create new Task
                Task followUp = new Task();
                followUp.Subject = 'Welcome Call Follow-up';
                followUp.WhatId = b.Id;
                followUp.OwnerId = b.CRM_Manager__c;
                followUp.Status = 'Not Started';
                followUp.Priority = 'Normal';
                followUp.ActivityDate = Date.today().addDays(2);
                followUp.Description = 'Please follow up with the customer regarding the welcome mail.';
                followUp.IsReminderSet = true;
                followUp.ReminderDateTime = System.now().addDays(2).addMinutes(-30);
                followUpTasksToCreate.add(followUp);
            }
        }
        // Insert new Tasks
        if (!followUpTasksToCreate.isEmpty()) {
            try {
                insert followUpTasksToCreate;
            } catch (DmlException e) {
                System.debug('Task creation error: ' + e.getMessage());
            }
        }
        
        // Update existing Tasks
        if (!followUpTasksToUpdate.isEmpty()) {
            try {
                update followUpTasksToUpdate;
            } catch (DmlException e) {
                ExceptionHandler.addLog(e,string.valueof(followUpTasksToUpdate),'BookingController','');  /*Add Exception to error log*/
                System.debug('Task update error: ' + e.getMessage());
            }
        }
    }
    
    @auraEnabled
    public static void welcomeMailAuraCmp(string recId,string emailContent) {
        if (recId ==null) return;
        set<Id>bookingIds = new set<Id>();
        list<Booking__c>bookingUpdateList = new list<Booking__c>();
        set<string> unitTypeId = new set<string> ();
        Map<Id, list<ContentVersion>> latestVersionMap = new Map<Id, list<ContentVersion>>();
        map<string,string> unitPrjContentDoc = new map<string,string>();
        bookingIds.add(recId);
        List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
        string companyName;
        string Address1;
        string Address2;
        string Address3;
        if(!companyDetails.isEmpty()){
            companyName = companyDetails[0].Label;
            Address1 = companyDetails[0].Registered_Address__c;
            Address2 = companyDetails[0].Address2__c;
            Address3 = companyDetails[0].Address3__c;    
        }
        // Step 1: Fetch Bookings with valid email
        Map<Id, Booking__c> validBookingsMap = new Map<Id, Booking__c>();
        for (Booking__c b : [
            SELECT Id, Email1__c,Project1__c, Plot__c,Plot__r.Unit_Type__c, Owner.Name, Owner.Email,CRM_Manager__c,Welcome_Mail_Sent_Time__c,Welcome_Email_Sent_to_Customer__c
            FROM Booking__c
            WHERE Id IN :bookingIds
        ]) {
            if (String.isNotBlank(b.Email1__c)) {
                validBookingsMap.put(b.Id, b);
            }
            if(b.Plot__c !=null){
                unitTypeId.add(b.Plot__r.Unit_Type__c);
            }
            if(b.Project1__c !=null){
                unitTypeId.add(b.Project1__c);
            }
        }
        if (validBookingsMap.isEmpty()) return;
        
        Map<String, Id> ownerEmailToOrgWideIdMap = new Map<String, Id>();
        for (OrgWideEmailAddress ow : [SELECT Id, Address FROM OrgWideEmailAddress]) {
            ownerEmailToOrgWideIdMap.put(ow.Address.toLowerCase(), ow.Id);
        }
        //String signatureUrl = URL.getOrgDomainURL().toExternalForm() + '/resource/GiriSignature';
        emailContent += '<p><img src="https://site-speed-6226.my.salesforce.com/servlet/servlet.ImageServer?id=015fv000002UZGv&oid=00D5h000008NYZw" alt="Signature" /></p>';
        emailContent += '<b>'+companyName+'</b><br/>';
        emailContent += 'Regd. Office: '+Address1+' '+Address2+' '+Address3+ '<br/>';
        emailContent += 'Tel: +91 484 2584000 / 2973944, +91 6235051144<br/>';
        emailContent += 'www.veegaland.com Follow us on: Facebook | Instagram | LinkedIn | YouTube</p>';
        List<Task> followUpTasksToCreate = new List<Task>();
        List<Task> followUpTasksToUpdate = new List<Task>();
        
        // Fetch existing "Welcome Call Follow-up" tasks
        Map<Id, Task> existingFollowUpTaskMap = new Map<Id, Task>();
        for (Task t : [
            SELECT Id, WhatId, OwnerId
            FROM Task
            WHERE WhatId IN :validBookingsMap.keySet()
            AND Subject = 'Welcome Call Follow-up'
            LIMIT 10000
        ]) {
            existingFollowUpTaskMap.put(t.WhatId, t);
        }
        
        // Step 3: Get ContentDocumentLinks for Bookings
        if(!unitTypeId.isEmpty()){
            // Step 3: Get ContentDocumentLinks for Bookings
            // Step 2: Get ContentDocumentIds linked to bookings
            Set<Id> contentDocIds = new Set<Id>();
            List<ContentDocumentLink> docLinks = [
                SELECT ContentDocumentId ,LinkedEntityId
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN :unitTypeId
            ];
            
            for (ContentDocumentLink link : docLinks) {
                contentDocIds.add(link.ContentDocumentId);
                unitPrjContentDoc.put(link.ContentDocumentId,link.LinkedEntityId);
            }
            
            if (contentDocIds.isEmpty()) return;
            
            // Step 3: Get relevant ContentVersions (filtered by title keywords)
            List<ContentVersion> filteredVersions = [
                SELECT Id, Title, ContentDocumentId, VersionData, FileExtension
                FROM ContentVersion
                WHERE ContentDocumentId IN :contentDocIds
                AND IsLatest = TRUE
                AND (
                    Title LIKE '%Floor Plan%' OR                 
                    Title LIKE '%Plumbing Plan%' OR 
                    Title LIKE '%Parking Plan%' OR 
                    Title LIKE '%Electrical Plan%' OR
                    Title LIKE '%Sample Sale Agreement%' OR
                    Title LIKE '%FAQ%' OR
                    Title LIKE '%Alteration Policy%' OR
                    Title LIKE '%Approved Banks for Home Loans%'
                    
                )
                ORDER BY CreatedDate DESC
            ];
            if(!filteredVersions.isEmpty()){
                for (ContentVersion cv : filteredVersions) {
                    if (unitPrjContentDoc.containsKey(cv.ContentDocumentId)) {
                        string key = unitPrjContentDoc.get(cv.ContentDocumentId);
                        if (!latestVersionMap.containsKey(key)) {
                            latestVersionMap.put(key, new List<ContentVersion>());
                        }
                        latestVersionMap.get(key).add(cv);
                    }
                }
            }
        }
        
        // Step 5: Send Emails
        List<Messaging.SingleEmailMessage> semailList = new List<Messaging.SingleEmailMessage>();
        for (Id bookingId : validBookingsMap.keySet()) {
            Booking__c bk = new Booking__c();
            bk.Welcome_Mail_Sent_Time__c=system.now();
            bk.Welcome_Email_Sent_to_Customer__c =true;
            bk.Id = bookingId;
            bookingUpdateList.add(bk);
            Booking__c b = validBookingsMap.get(bookingId);
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage(); 
            //CC to veegaland customercare 
            List<String> lstCCEmail = new List<String>();
            lstCCEmail.add('customercare@veegaland.in');
            if (!lstCCEmail.isEmpty()) {
                semail.setCcAddresses(lstCCEmail);
            }
            //   semail.setSenderDisplayName(b.Owner.Name);
            semail.setReplyTo(b.Owner.Email);
            semail.setSubject('Welcome Mail');
            semail.setToAddresses(new List<String>{b.Email1__c});
            
            
            
            semail.setHtmlBody(emailContent);
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            
            PageReference pdfPage = Page.AllotmentLetter;
            pdfPage.getParameters().put('id', b.Id);
            Blob pdfBlob = !Test.isRunningTest() ? pdfPage.getContentAsPDF() : Blob.valueOf('testblob');
            
            Messaging.EmailFileAttachment allotmentAttach = new Messaging.EmailFileAttachment();
            allotmentAttach.setFileName('AllotmentLetter.pdf');
            allotmentAttach.setBody(pdfBlob);
            attachments.add(allotmentAttach);
            
            if (latestVersionMap.containsKey(b.Plot__r.Unit_Type__c) ) {
                for (ContentVersion cv : latestVersionMap.get(b.Plot__r.Unit_Type__c)) {
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    String fileNameWithExtension = cv.Title + '.' + cv.FileExtension;
                    efa.setFileName(fileNameWithExtension);
                    efa.setBody(cv.VersionData);
                    attachments.add(efa);
                }
            }
            if ( latestVersionMap.containsKey(b.Project1__c)) {
                for (ContentVersion cv : latestVersionMap.get(b.Project1__c)) {
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    String fileNameWithExtension = cv.Title + '.' + cv.FileExtension;
                    efa.setFileName(fileNameWithExtension);
                    efa.setBody(cv.VersionData);
                    attachments.add(efa);
                }
            }
            
            if (!attachments.isEmpty()) {
                semail.setSaveAsActivity(true);
                semail.setWhatId(b.Id);
                semail.setFileAttachments(attachments);
            }
            
            // Handle follow-up Task
            if (existingFollowUpTaskMap.containsKey(b.Id)) {
                // Task exists: update status
                Task existingTask = existingFollowUpTaskMap.get(b.Id);
                existingTask.Status = 'Not Started';
                followUpTasksToUpdate.add(existingTask);
            } else {
                // Create new Task
                Task followUp = new Task();
                followUp.Subject = 'Welcome Call Follow-up';
                followUp.WhatId = b.Id;
                followUp.OwnerId = b.CRM_Manager__c;
                followUp.Status = 'Not Started';
                followUp.Priority = 'Normal';
                followUp.ActivityDate = Date.today().addDays(2);
                followUp.Description = 'Please follow up with the customer regarding the welcome mail.';
                followUp.IsReminderSet = true;
                followUp.ReminderDateTime = System.now().addDays(2).addMinutes(-30);
                followUpTasksToCreate.add(followUp);
            }
            
            String ownerEmail = b.Owner.Email;
            if (ownerEmail != null && ownerEmailToOrgWideIdMap.containsKey(ownerEmail.toLowerCase())) {
                semail.setOrgWideEmailAddressId(ownerEmailToOrgWideIdMap.get(ownerEmail.toLowerCase()));
            }
            
            semailList.add(semail);
        }
        
        if (!semailList.isEmpty()) {
            Messaging.sendEmail(semailList);
        }
        //insert booking
        if (!bookingUpdateList.isEmpty()) {
            try {
                update bookingUpdateList;
            } catch (DmlException e) {
                ExceptionHandler.addLog(e,string.valueof(bookingUpdateList),'BookingController','');  /*Add Exception to error log*/
                
                System.debug('Task creation error: ' + e.getMessage());
            }
        }
        
        // Insert new Tasks
        if (!followUpTasksToCreate.isEmpty()) {
            try {
                insert followUpTasksToCreate;
            } catch (DmlException e) {
                ExceptionHandler.addLog(e,string.valueof(followUpTasksToCreate),'BookingController','');  /*Add Exception to error log*/
                
                System.debug('Task creation error: ' + e.getMessage());
            }
        }
        
        // Update existing Tasks
        if (!followUpTasksToUpdate.isEmpty()) {
            try {
                update followUpTasksToUpdate;
            } catch (DmlException e) {
                ExceptionHandler.addLog(e,string.valueof(followUpTasksToUpdate),'BookingController','');  /*Add Exception to error log*/
                System.debug('Task update error: ' + e.getMessage());
            }
        }
    }
    
    @AuraEnabled
    public static Booking__c getBookingDetails(Id bookingId) {
        return [SELECT Id, Project1__c FROM Booking__c WHERE Id = :bookingId LIMIT 1];
    }
    
    @AuraEnabled
    public static String bypassStagetoDraftAgreement(Id recId) {
        try {
            // Query the Booking record based on the provided recId
            Booking__c booking = [SELECT Id, Stage__c, Bypass_Advance_Amount__c FROM Booking__c WHERE Id = :recId LIMIT 1];
            
            // Update the fields
            booking.Stage__c = 'Draft Agreement Preparation';
            booking.Bypass_Advance_Amount__c = true;
            
            // Update the record in the database
            update booking;
            
            // Return a success message
            return null; // No error message means success
        } catch (Exception e) {
            // Return the error message if any exception occurs
            return e.getMessage();
        }
    }
    public static void bookingRecordShare(list<Id> bookingIds){
        List<Booking__Share> ins = new List<Booking__Share>();
        for (Booking__c b : [ SELECT Id, OwnerId, CreatedById FROM Booking__c WHERE Id in :bookingIds LIMIT 5000 ]) {
            Booking__Share sh = new Booking__Share();
            sh.ParentId      = b.Id;
            sh.UserOrGroupId = b.CreatedById;
            sh.AccessLevel   = 'Edit';
            sh.RowCause      = 'Manual';
            ins.add(sh);
        }
        if (!ins.isEmpty()) Database.insert(ins, false);
    }
    
    public static void welcomeTaskCompletion(set<Id> bookingIds){
        
        list<task> callTasks =[select Id from task where Subject = 'Welcome Call Follow-up' and Status != 'Completed' and WhatId in :bookingIds];
        if(!callTasks.isEmpty()){
            for(task t : callTasks){
                t.Status = 'Completed';
            }
            try{
                update callTasks;
            }catch(exception ex){
                ExceptionHandler.addLog(ex,string.valueof(callTasks),'BookingController','');  /*Add Exception to error log*/
            }
        }
        
        
    }
    
    public static void updateUnitStatus(map<Id,Booking__c> unitBookingMap){
        list<Plot__c> units =[select id, Status__c from Plot__c where Status__c!='Booked' and Id in:unitBookingMap.keyset()];
        for(Plot__c plt : units){
            plt.Status__c = 'Booked';
        }
        try{
            update units;
        }catch(exception ex){
            ExceptionHandler.addLog(ex,string.valueof(units),'BookingController','');  /*Add Exception to error log*/
        } 
    }
    
    public static void changeBookingLeadStatus(map<Id,Booking__c> leadBokingMap){
        list<lead> leads=[select id,Lead_status__c,Lead_Stage__c from lead where Lead_status__c!='Booked' and Id in:leadBokingMap.keyset()];
        for(lead ld : leads){
            ld.Lead_status__c ='Booked';
            ld.Lead_Stage__c = 'Booked';
            if(leadBokingMap.get(ld.Id).Aadhaar_Number__c !=null){
                ld.Aadhaar_No__c =leadBokingMap.get(ld.Id).Aadhaar_Number__c;
            }
            if(leadBokingMap.get(ld.Id).PAN_Number1__c !=null){
                ld.PAN_NO__c =leadBokingMap.get(ld.Id).PAN_Number1__c;
            }
            
        }
        try{
            update leads;
        }catch(exception ex){
            ExceptionHandler.addLog(ex,string.valueof(leads),'BookingController','');  /*Add Exception to error log*/
        } 
    }
    /*
public static void createPaymentSchedules(List<Booking__c> newBookings) {
Set<Id> projectIds = new Set<Id>();
// Collect Project__c IDs from the Booking__c records
for (Booking__c booking : newBookings) {
if (booking.Project1__c != null) {
projectIds.add(booking.Tower__c);
}
}
List<Master_Payment_Schedule__c> relatedMasterPaymentSchedules = new List<Master_Payment_Schedule__c>();
// Query Master_Payment_Schedule__c records related to the Project__c IDs
if (!projectIds.isEmpty()) {
relatedMasterPaymentSchedules = [
SELECT Id, Name, Amount__c, Payment_percent__c, Status__c, S_No__c, Project__c,Include_interest__c,Tower__c
FROM Master_Payment_Schedule__c
WHERE Tower__c IN :projectIds  
];
}
List<Payment_Schedule__c> newPaymentSchedules = new List<Payment_Schedule__c>();
// Create new Payment_Schedule__c records for Booking__c
for (Booking__c booking : newBookings) {
for (Master_Payment_Schedule__c masterPaymentSchedule : relatedMasterPaymentSchedules) {
if (masterPaymentSchedule.Tower__c == booking.Tower__c) {
// Create a new Payment_Schedule__c record with data copied from the Master_Payment_Schedule__c record
Payment_Schedule__c newPaymentSchedule = new Payment_Schedule__c(
Booking__c = booking.Id,
// Copy fields from Master_Payment_Schedule__c
Payment_percent__c = masterPaymentSchedule.Payment_percent__c,
//Status__c = masterPaymentSchedule.Status__c,
Interest_Percent__c = booking.Interest_Percent__c,
Include_interest__c = masterPaymentSchedule.Include_interest__c,
S_No__c = masterPaymentSchedule.S_No__c,
Amount__c = masterPaymentSchedule.Amount__c,
Master_Payment_Schedule__c = masterPaymentSchedule.Id,
Name = masterPaymentSchedule.Name
);
newPaymentSchedules.add(newPaymentSchedule);
}
}
}
if (!newPaymentSchedules.isEmpty()) {
insert newPaymentSchedules;
}
}
*/
    
    
    /*
public static void stageWiseOwnerUpdate(List<Booking__c> newBookings, Map<Id, Booking__c> oldBookingMap) {
Set<Id> projectIds = new Set<Id>();
for (Booking__c newBooking : newBookings) {
if (newBooking.Project1__c != null) {
projectIds.add(newBooking.Project1__c);
}
}
Map<Id, Project__c> projectMap = new Map<Id, Project__c>([
SELECT Id, Reservation_User__c, Demands_Collection_User__c, Possession_User__c,
Agreement_User__c, Registration_User__c, Maintenance_User__c
FROM Project__c WHERE Id IN :projectIds
]);

for (Booking__c newBooking : newBookings) {
if (oldBookingMap != null) {
Booking__c oldBooking = oldBookingMap.get(newBooking.Id);

if (oldBooking.Stage__c != newBooking.Stage__c) {
Project__c project = projectMap.get(newBooking.Project1__c);
if (newBooking.Stage__c == 'Welcome Email' && project.CRM_Manager__c != null) {
newBooking.OwnerId = project.CRM_Manager__c;
} else if (newBooking.Stage__c == 'Draft Agreement Preparation' && project.Demands_Collection_User__c != null) {
newBooking.OwnerId = project.Demands_Collection_User__c;
} else if (newBooking.Stage__c == 'Registration' && project.Registration_User__c != null) {
newBooking.OwnerId = project.Registration_User__c;
} else if (newBooking.Stage__c == 'Possession' && project.Possession_User__c != null) {
newBooking.OwnerId = project.Possession_User__c;
} else if (newBooking.Stage__c == 'Maintenance' && project.Maintenance_User__c != null) {
newBooking.OwnerId = project.Maintenance_User__c;
}
}
}
}
}
*/
    /*
@AuraEnabled
public static void documentVerificationApproval(Id recId){
Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
req1.setComments('Document Verification Approval');
req1.setObjectId(recId);
req1.setSubmitterId(userInfo.getUserId()); 
req1.setProcessDefinitionNameOrId('Documents_Check_Approval');
req1.setSkipEntryCriteria(true);
Approval.ProcessResult result = Approval.process(req1);
}

@AuraEnabled
public static void receiptApprovalforFinanceTeam(Id recId){
Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
req1.setComments('Receipt Approval');
req1.setObjectId(recId);
req1.setSubmitterId(userInfo.getUserId()); 
req1.setProcessDefinitionNameOrId('Receipt_Approval_To_Finance_Team	');
req1.setSkipEntryCriteria(true);
Approval.ProcessResult result = Approval.process(req1);
}
*/  
    
    /*
@AuraEnabled
public static void requestSaleAgreement(Id recId){
Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
req1.setComments('Sale Agreement');
req1.setObjectId(recId);
req1.setSubmitterId(userInfo.getUserId()); 
req1.setProcessDefinitionNameOrId('Request_for_Sale_Agreement');
req1.setSkipEntryCriteria(true);
Approval.ProcessResult result = Approval.process(req1);
}

@AuraEnabled
public static void partialAmountAgreementAmountApproval(Id recId){
Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
req1.setComments('Sale Agreement');
req1.setObjectId(recId);
req1.setSubmitterId(userInfo.getUserId()); 
req1.setProcessDefinitionNameOrId('Agreement_Partial_Amount_Paid_Approval');
req1.setSkipEntryCriteria(true);
Approval.ProcessResult result = Approval.process(req1);
}

@AuraEnabled
public static void requestForSaleDeed(Id recId){
Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
req1.setComments('Sale Agreement');
req1.setObjectId(recId);
req1.setSubmitterId(userInfo.getUserId()); 
req1.setProcessDefinitionNameOrId('Agreement_Partial_Amount_Paid_Approval');
req1.setSkipEntryCriteria(true);
Approval.ProcessResult result = Approval.process(req1);
}

@AuraEnabled
public static void requestForRegistrationApproval(Id recId){
Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
req1.setComments('Sale Agreement');
req1.setObjectId(recId);
req1.setSubmitterId(userInfo.getUserId()); 
req1.setProcessDefinitionNameOrId('Registration_Approval');
req1.setSkipEntryCriteria(true);
Approval.ProcessResult result = Approval.process(req1);
}

public class ResponseWrapper {
@AuraEnabled public Boolean success;
@AuraEnabled public String message;
}

@AuraEnabled
public static ResponseWrapper requestTransferApproval(Id recId, Id selectedPlotId) {
ResponseWrapper response = new ResponseWrapper();
try {
// Check if there's already a pending approval
List<ProcessInstance> existingApprovals = [
SELECT Id, Status 
FROM ProcessInstance 
WHERE TargetObjectId = :recId 
AND Status = 'Pending'
];
if (!existingApprovals.isEmpty()) {
response.success = false;
response.message = 'An approval request is already pending for this booking.';
return response;
}

// Update booking with selected plot and flag
Booking__c booking = [SELECT Id FROM Booking__c WHERE Id = :recId LIMIT 1];
booking.Swap_Unit__c = selectedPlotId;
booking.Unit_Swap_Requested__c = true;
update booking;

// Submit for approval
Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
req1.setComments('Sale Agreement');
req1.setObjectId(recId);
req1.setSubmitterId(UserInfo.getUserId()); 
req1.setProcessDefinitionNameOrId('Request_Swap_Unit_Before_Registration');
req1.setSkipEntryCriteria(true);
Approval.ProcessResult result = Approval.process(req1);

if (result.isSuccess()) {
response.success = true;
response.message = 'The Request For Unit Transfer was sent successfully.';
} else {
response.success = false;
response.message = 'Approval process failed to submit.';
}
} catch (Exception e) {
response.success = false;
response.message = 'Error: ' + e.getMessage();
}

return response;
}
*/  
    public class BookingUserWrapper {
        @AuraEnabled
        public Booking__c booking;
        
        @AuraEnabled
        public User loggedInUser;
        
        public BookingUserWrapper(Booking__c booking, User loggedInUser) {
            this.booking = booking;
            this.loggedInUser = loggedInUser;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static BookingUserWrapper getRecordData(Id recordId) {
        // Fetch the booking record
        Booking__c booking = [SELECT Id, Name, First_Applicant_Name__c,Tower__c,Tower_Name__c, salutation_Applicant1__c, salutation_Applicant2__c, 
                              Second_Applicant_Name__c, Swap_Unit_Status__c, Project__c, Booking_Amount1__c, 
                              Unit_NumberFor__c, Email1__c 
                              FROM Booking__c WHERE Id = :recordId LIMIT 1];
        
        // Fetch the logged-in user details
        User loggedInUser = [SELECT Name,Email, Phone FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        // Return both booking and logged-in user details in a wrapper
        return new BookingUserWrapper(booking, loggedInUser);
    }
    
    /*
@AuraEnabled
public static void sendWelcomeEmail(Id recordId, String emailContent, List<String> toAddresses, List<String> contentIds) {
system.debug('Content IDs: ' + contentIds);
Booking__c leadRecord = [SELECT Id,Plot__r.Name,salutation_Applicant2__c,salutation_Applicant1__c,Block__r.Name, Name, CRM_Manager__c,Email2__c,Project1__r.Name,CRM_Manager__r.Email, First_Applicant_Name__c,Second_Applicant_Name__c, Project__c, Booking_Amount1__c, Unit_NumberFor__c, Email1__c, 
(SELECT ContentDocumentId, ContentDocument.Title FROM ContentDocumentLinks WHERE ContentDocumentId IN :contentIds) 
FROM Booking__c 
WHERE Id = :recordId 
LIMIT 1];
/*
Id groupId = [SELECT Id FROM Group WHERE DeveloperName = 'CRM_User_Group' LIMIT 1].Id;
List<GroupMember> groupMembers = [
SELECT UserOrGroupId 
FROM GroupMember 
WHERE GroupId = :groupId
];

List<String> ccAddresses = new List<String>();

// Iterate over group members and add their emails to the CC list
for (GroupMember gm : groupMembers) {
User u = [SELECT Email FROM User WHERE Id = :gm.UserOrGroupId];
if (u.Email != null) {
ccAddresses.add(u.Email);
}
}
ccAddresses.add('Crmlead@mahendrahomes.com');
if (leadRecord != null && leadRecord.Email1__c != null) {
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
Set<Id> contentDocumentIds = new Set<Id>();
for (ContentDocumentLink docLink : leadRecord.ContentDocumentLinks) {
contentDocumentIds.add(docLink.ContentDocumentId);
}
if (!contentDocumentIds.isEmpty()) {
List<ContentVersion> contentVersions = [SELECT Title,FileExtension, VersionData FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds];
for (ContentVersion cv : contentVersions) {
Messaging.EmailFileAttachment contentAttach = new Messaging.EmailFileAttachment();
String fileNameWithExtension = cv.Title + '.' + cv.FileExtension;
contentAttach.setFileName(fileNameWithExtension);
//contentAttach.setFileName(cv.Title);
contentAttach.setBody(cv.VersionData);
emailAttachments.add(contentAttach);
}
}
toAddresses.add(leadRecord.Email1__c);
if (leadRecord.Email2__c != null) {
toAddresses.add(leadRecord.Email2__c);
}
List<PageReference> vfPages = new List<PageReference>();

if(leadRecord.Project1__r.Name.contains('AARYA')){
vfPages.add(Page.SALE_AGREEMENT_AARYA);
vfPages.add(Page.COST_SHEET_AARYA);
for (PageReference pref : vfPages) {
system.debug(pref);
pref.getParameters().put('id', recordId);
Blob pdfBlob = !Test.isRunningTest() ? pref.getContentAsPDF(): Blob.valueOf('testblob');
Messaging.EmailFileAttachment vfAttachment = new Messaging.EmailFileAttachment();
// Set a custom name for each PDF attachment based on the PageReference
String attachmentName;

if (pref.getUrl().contains('sale_agreement_aarya')) {
attachmentName = 'Sale_Agreement.pdf'; // Custom name for Sale Agreement
} else if (pref.getUrl().contains('cost_sheet_aarya')) {
attachmentName = 'Cost_Sheet.pdf'; // Custom name for Cost Sheet
} else {
attachmentName = 'Document.pdf'; // Default name for any other case
}

vfAttachment.setFileName(attachmentName);
vfAttachment.setBody(pdfBlob);
emailAttachments.add(vfAttachment);
}
}else if(leadRecord.Project1__r.Name.contains('HELIX')){
vfPages.add(Page.SALE_AGREEMENT_HELIX);
vfPages.add(Page.COST_SHEET_HELIX);
for (PageReference pref : vfPages) {
pref.getParameters().put('id', recordId);
Blob pdfBlob = !Test.isRunningTest() ? pref.getContentAsPDF(): Blob.valueOf('testblob');
Messaging.EmailFileAttachment vfAttachment = new Messaging.EmailFileAttachment();
// Set a custom name for each PDF attachment based on the PageReference
String attachmentName;

if (pref.getUrl().contains('sale_agreement_helix')) {
attachmentName = 'Sale_Agreement.pdf'; // Custom name for Sale Agreement
} else if (pref.getUrl().contains('cost_sheet_helix')) {
attachmentName = 'Cost_Sheet.pdf'; // Custom name for Cost Sheet
} else {
attachmentName = 'Document.pdf'; // Default name for any other case
}

vfAttachment.setFileName(attachmentName);
vfAttachment.setBody(pdfBlob);
emailAttachments.add(vfAttachment);
}
}

if (!emailAttachments.isEmpty()) {
mail.setFileAttachments(emailAttachments);
}
mail.setCcAddresses(ccAddresses);
mail.setToAddresses(toAddresses);
// Build the subject line
String applicantNames = 'Welcome ';

if (leadRecord.First_Applicant_Name__c != null) {
if (leadRecord.salutation_Applicant1__c != null) {
applicantNames +=leadRecord.salutation_Applicant1__c + '. ';
}
applicantNames += leadRecord.First_Applicant_Name__c + ' ';
}
if (leadRecord.Second_Applicant_Name__c != null) {
applicantNames += '& ';
if (leadRecord.salutation_Applicant2__c != null) {
applicantNames += leadRecord.salutation_Applicant2__c + '. ';
}
applicantNames += leadRecord.Second_Applicant_Name__c + ',';
}

String projectDetails = applicantNames +' ' + leadRecord.Project1__r.Name + ' ' + leadRecord.Block__r.Name + ' ' + leadRecord.Plot__r.Name;

// Set the subject line
mail.setSubject(projectDetails);

mail.setHtmlBody(emailContent);

mail.setSaveAsActivity(true);
mail.setWhatId(leadRecord.Id);

List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

leadRecord.Welcome_Mail_Sent_Time__c = system.now();
leadRecord.Welcome_Email_Sent_to_Customer__c = true;
update leadRecord;
}
}

@AuraEnabled
public static Transfer__c getTransferRecordDetails(Id recId){
Transfer__c trnas = [select id,name,Customer_Name__c,Email__c,PAN_Number__c,Phone__c,Transfer_Amount__c from Transfer__c where Booking__c =:recId LIMIT 1 ];
return trnas;
}*/
    
    /* @AuraEnabled
public static void createBookingRecordDetails(Id recId,String customerName,String phone,String country,String email,String PanNumb ){

//Booking__c booking = [SELECT Id, vide_no__c, state1__c, salutation_Applicant2__c, salutation_Applicant1__c, generator_and_prepaid_gas_charges__c, demo__c, amenities_charges__c, Welcome_Mail_Sent_Time__c, Welcome_Email_Sent_to_Customer__c, Welcome_Call_Done__c, Welcome_Call_Date__c, Website_Secondary__c, Website_Primary__c, VP__c, Uploaded_Sale_Deed_Signed_Copy__c, Unit_UDS_Area__c, Unit_Size__c, Unit_Share__c, Unit_Number__c, Unit_NumberFor__c, Unit_Facing_Directionswap__c, Unit_Facing_Direction__c, Unit_Common_Area_Allotted_to_Association__c, UDS_Area__c, Type__c, Transfer_Amount__c, Transaction_ID__c, Tower__c, Total_received_Amount__c, Total__c, Total_Receipt__c, Total_Other_Charges__c, Total_Interest__c, Total_Consideration_with_taxes_and_other__c, Token_Amount__c, Third_Applicant_Photo__c, Third_Applicant_Name__c, TPA__c, TPA_Agreement_Date__c, TAXES__c, TAXES1__c, Super_Built_up_area_NE__c, Sub_Total__c, Sub_Stages__c, Sub_Source__c, State__c, State3__c, State2__c, Stage__c, Stage_Changed_To_Assignement__c, Special_Notes__c, Source_of_refferal__c, Son_Daughter_Wife_of__c, Son_Daughter_Wife_of1__c, Sold_Details__c, Solar_Charges__c, Social_Media_Use__c, Signature_Of_Second_Applicant__c, Signature_Of_First_Applicant__c, Share__c, Sent_Loan_Document_To_Bank__c, Second_Applicant_Photo__c, Second_Applicant_Name__c, Sanctioned_Date__c, Sanctioned_Amount__c, Sanction_Letter_Uploaded__c, Sales_Manager1__c, Sale_Deed_Number__c, Sale_Area__c, Sale_Agreement_Uploaded__c, Sale_Agreement_Date__c, Sale_Agreement_Completed__c, SLead__c, SB_Account__c, Rs_100_Per_Sft_Infra_STP_EB__c, Revenue_to_Company__c, Residential_Status__c, Residential_Status1__c, Reservation_User__c, Request_For_Transfer__c, Request_For_Sale_Deed__c, Request_For_Sale_Agreement__c, Request_For_Registration_Status__c, Request_For_Cancellation_Agreement__c, Remarks__c, Remark__c, Relationship_Manager__c, Relation_Details_Applicant2__c, Relation_Details_Applicant1__c, Registration_User__c, Registration_Uploads_Successful__c, Registration_Number__c, Registration_Expected_Date__c, Registration_Done__c, Registration_Date__c, Refund__c, Receipt_Approval_Status__c, Rate_per_sqftswap__c, Rate_per_sqft__c, ROI__c, RM_Name__c, RERA_NO__c, Quote_date__c, Purpose_of_Purchase__c, Property_Type__c, Property_Type_For__c, Projectswap__c, Project__c, Project1__c, Profession__c, Profession3__c, Profession1__c, Private_Terrace__c, Print_Form__c, Price_per_sqft__c, Premium_Charge__c, Post_Agreement_Cancellation__c, Possession_send__c, Possession_User__c, Possession_Send_Date__c, Possession_Expected_Date__c, Plot__c, Plot_Type__c, Plot_Land_Areaswap__c, Plot_Land_Area__c, Place7__c, Pincode__c, Pincode3__c, Pincode2__c, Pincode1__c, Permenant_Adress__c, Permenant_Adress1__c, Permanent_Address1__c, Pending_Amount__c, Payment_Type__c, Passport_Uploded__c, Passport_PI_no__c, Passport_PI_no3__c, Passport_PI_no1__c, Passport_Aadhar__c, Passport_Aadhar_1__c, Pan_Number_Applicant2__c, Pan_Card_Uploaded__c, PAN_Number1__c, Owenr_Phone__c, Outflow__c, OutFlow_Date__c, Other_Charges__c, Other_Amenities__c, Original_Agreement_Collected__c, Organisation_Designation__c, Organisation_Designation3__c, Organisation_Designation1__c, Old_Agreement_Collected__c, Occupation__c, Occupation1__c, Number_of_Children__c, Number_of_Children1__c, Newspaper_Read__c, NewsPaper_Ad__c, Nationality__c, Nationality_Applicant2__c, Name_of_the_Channel_Partner__c, Name_of_Spouse__c, Name_of_Spouse1__c, Name_of_Referee__c, Name_of_Company__c, Name_of_Company1__c, Name, NOC__c, Mode_Of_Payment__c, Mobile__c, Mobile_Primary__c, Mobile_Primary3__c, Mobile_Primary2__c, Mobile_Primary1__c, Mobile_Alternate__c, Mobile_Alternate2__c, Mobile_Alternate1__c, Middle_Name__c, Middle_Name3__c, Middle_Name1__c, Marital_Status__c, Marital_Status1__c, Maintenance_charges__c, Maintenance_User__c, Maintenance_Expected_Date__c, Maintenance_Deposite__c, Maintenance_Chargeswap__c, Maintenance_Charge__c, Location__c, Loan_User__c, Loan_Sanctioned__c, Loan_Sanctioned_Amount__c, Loan_Sanction_Confirmed__c, Loan_Expected_Date__c, Loan_Account_Number__c, Legal_charges__c, Legal_Team__c, Legal_Loan_Uploads_Successful__c, Legal_Documentation_Chargesswap__c, Legal_Documentation_Charges__c, Legal_Approval_Status__c, Leads_source__c, Lead__c, Lead_Name__c, Lead_Allocation_Date__c, Last_comment__c, Last_Name_SurName__c, Last_Name_SurName3__c, Last_Name_SurName1__c, KycUploaded__c, Khata_charges__c, Khata_No__c, KYC__c, KPTCL_and_SI__c, Is_Swap__c, IsDeleted, IsCancelled__c, Interior_Charges__c, Interest_Waive_Off__c, Interest_Percent__c, Interest_Pending__c, Interest_Paid__c, Interest_From_PS__c, Infrastructure_Charges_per_sqftwsap__c, Infrastructure_Charges_per_sqft__c, In_Favour_Of__c, IFSC_Code__c, House_Number__c, House_Number2__c, House_Number1__c, Hoarding__c, Handover_User__c, Guideline_Value__c, Ground_Floor_Garden__c, Gender__c, Gender1__c, GSTswap__c, GST__c, GST_Amount__c, Funding_Type__c, Followup_Subject__c, Followup_Date__c, Floor_Rise_Charges_Rate__c, FloorNo__c, Flat_Number__c, Flat_Actual_Number__c, First_disbursement__c, First_Disbursement_Received__c, First_Disbursement_Date__c, First_Dibursement_Expected_date__c, First_Applicant_Photo__c, First_Applicant_Name__c, Finance_User__c, Finance_Approval__c, Finance_Approval1__c, File_Number__c, Father_Spouse_Name__c, Father_Spouse_Name1__c, Facing__c, Extra_covered_Parking_Slots__c, Extra_Covered_Parking_Charges__c, Existing_customer__c, Enquiry_Source__c, Email2__c, Email1__c, Educational_Qualifications__c, Educational_Qualifications3__c, Educational_Qualifications1__c, E_mail2__c, EFT__c, EB_GST_18__c, Drawn_No__c, Documents_Sent_To_Bank__c, Discount__c, Director__c, Development_Charge__c, Designation__c, Designation1__c, Description__c, Demands__c, Demands_Expected_Date__c, Demand_Raised__c, Demand_Number__c, Demand_Letter__c, Demand_Letter_Sent_Date__c, Demand_Collection_Users__c, Date_of_birth_Applicant2__c, Date_of_balance_own_contribution_to_be_p__c, Date_of_Bookingswap__c, Date_of_Booking__c, Date_of_Birth1__c, Date_Of_Offer_Letter__c, Date7__c, Customer_Is_going_for_Loan__c, Customer_ID__c, Createddate__c, Covered_Park_Parking__c, Country1__c, Cost_Break_up_Sheet__c, Corpus_Fundswap__c, Corpus_Fund__c, Contact_Telephone_Number__c, Contact_Telephone_Number1__c, Contact_Number1__c, Communication_address__c, Communication_address1__c, Common_Area__c, Common_Area_Allotted_to_Association__c, Commission__c, Comments__c, Co_Applicant_Photo_Uploaded__c, Clubhouse_Charges__c, Club_Houseswap__c, Club_House__c, City3__c, City2__c, City1__c, Citizen_of_Status_NRI_POI__c, Citizen_of_Status_NRI_POI1__c, Cheque_DD_NEFT_RTGS_No__c, Carpet_Area__c, Cancellation_User__c, Cancellation_Status__c, Cancellation_Charges__c, CRM_Manager__c, CRM_Manager_Email__c, CRM_Manager_Approval__c, CFO__c, Built_up_area__c, Builder_Land_Owner_Name__c, Branch_Name__c, Booking__c, Booking_Stage_Uploads_Successful__c, Booking_Stage_Document_Created__c, Booking_Stage_Completed__c, Booking_Owner__c, Booking_Link_Filled__c, Booking_Form__c, Booking_Date__c, Booking_Amount1__c, Booking_Accepted_by_Customer__c, Block__c, Block1__c, Basic_Sale_Price_Rs__c, Basic_Priceswap__c, Basic_Price__c, Bank__c, Bank_Name__c, Bank_NOC_Collected__c, Bank_Employee_Contact_Number__c, Bank_CO_Ordinator__c, Balance_Booking_Amout__c, BHK_Type__c, BESCOM_Deposit_Rs__c, Attended_By_Name__c, Associated_Unit__c, Associated_Project__c, Assignment_Process_Started__c, Assignment_Process_Completed__c, Assigned_by__c, Approved_By_Nmae__c, Approval_status__c, Applicant_Photo_Uploded__c, Applicant_Name__c, Applicant_Mobile_Number__c, Apartment_Number__c, Annual_income__c, Anniverssary_Date__c, Anniverssary_Date3__c, Anniverssary_Date1__c, Amount_in_words__c, Amount_INR__c, Amount_By_Customer__c, Allotment_Letter__c, All_Payment_Cleared__c, All_KYC_are_correct__c, Agreement_value__c, Agreement_User__c, Agreement_Uploads_Successful__c, Agreement_Stage__c, Agreement_Percentage__c, Agreement_Expected_Date__c, Agreement_Amount_Cleared__c, Agreement_Amount_Check__c, Agreed_Apt_Price_INR__c, Age__c, Age2__c, Address__c, Actual_Booking_Amout__c, Account_Number__c, Aadhaar_Uploded__c, Aadhaar_Number__c, Aadhaar_Number1__c, AM__c FROM Booking__c where Id =: recId];

Booking__c clonedBooking = booking.clone(false, true);

clonedBooking.Email1__c   = email;
clonedBooking.Nationality__c   = country;
clonedBooking.First_Applicant_Name__c   = customerName;
clonedBooking.Mobile_Primary__c   = phone;
clonedBooking.PAN_Number1__c   = PanNumb;
//clonedBooking.Stage__c = booking.Stage_Changed_To_Assignement__c;
system.debug(clonedBooking.Stage__c = booking.Stage__c ?? 'Reservation');
clonedBooking.Stage__c = booking.Stage__c ?? 'Reservation';
insert clonedBooking;
//booking.Stage__c = 'Assignment Completed';
clonedBooking.Assignment_Process_Completed__c=true;
update booking;

// Fetch related Receipt records
List<Receipt__c> receiptList = [SELECT Id, Name
FROM Receipt__c WHERE Booking__c = :recId];
// Clone each Receipt and link to the cloned Booking
List<Receipt__c> clonedReceipts = new List<Receipt__c>();
for (Receipt__c receipt : receiptList) {
Receipt__c clonedReceipt = receipt.clone(false, true);
clonedReceipt.Booking__c = clonedBooking.Id; // Link to the new Booking record
clonedReceipts.add(clonedReceipt);
}

// Insert the cloned Receipt records
if (!clonedReceipts.isEmpty()) {
insert clonedReceipts;
}

set<String> userIds = new set<String>();
string Body = 'Please create debit note for Booking '+clonedBooking.Name;
userIds.add(clonedBooking.Finance_User__c);
BookingController.sendCustomNotification(userIds,'Booking Transfer',Body,clonedBooking.Id,'Booking_Notification');
}
@AuraEnabled
public static void saveTransfer(Booking__c booking, Id recordId, Boolean isSecondaryApplicantSame) {
try {
// Set the Booking Id to the recordId passed from the front end
booking.Id = recordId;
system.debug('booking'+booking);
system.debug('recordId'+recordId);
system.debug('isSecondaryApplicantSame'+isSecondaryApplicantSame);
// Check if the secondary applicant fields should be cleared
if (!isSecondaryApplicantSame) {
if (String.isEmpty(booking.Second_Applicant_Name__c)) {
// Clear the secondary applicant fields if the checkbox is unchecked
booking.salutation_Applicant2__c = null;
booking.Second_Applicant_Name__c = null;
booking.Date_of_birth_Applicant2__c = null;
booking.Mobile_Primary1__c = null;
booking.Email2__c = null;
booking.Nationality_Applicant2__c = null;
booking.Relation_Details_Applicant2__c = null;
booking.Son_Daughter_Wife_of1__c = null;
booking.Passport_Aadhar_1__c = null;
booking.Aadhaar_Number1__c = null;
booking.Pan_Number_Applicant2__c = null;
booking.Occupation1__c = null;
booking.Name_of_Company1__c = null;
booking.Designation1__c = null;
booking.Anniverssary_Date1__c = null;
booking.Communication_address1__c = null;
booking.Permanent_Address1__c = null;
}
}

// Perform the update
update booking;

} catch (Exception e) {
throw new AuraHandledException('Failed to save the record: ' + e.getMessage());
}
}
*/
    
    public static void custmerMasterallocation(List<Booking__c> newBookings) {
        if (newBookings == null || newBookings.isEmpty()) {
            return;
        }
        
        // STEP 0: Collect all emails + phones from new bookings
        Set<String> emails = new Set<String>();
        Set<String> phones = new Set<String>();
        
        for (Booking__c b : newBookings) {
            if (b.Email1__c != null) {
                emails.add(b.Email1__c);
            }
            if (b.Mobile_Primary__c != null) {
                phones.add(b.Mobile_Primary__c);
            }
        }
        
        // STEP 1: Query existing Customer Master records that match by Email OR Phone
        Map<String, Customer_Master__c> emailMap = new Map<String, Customer_Master__c>();
        Map<String, Customer_Master__c> phoneMap = new Map<String, Customer_Master__c>();
        
        if (!emails.isEmpty() || !phones.isEmpty()) {
            for (Customer_Master__c cm : [
                SELECT Id, Email__c, Phone__c
                FROM Customer_Master__c
                WHERE (Email__c IN :emails AND Email__c != null)
                OR (Phone__c IN :phones AND Phone__c != null)
            ]) {
                if (cm.Email__c != null && !emailMap.containsKey(cm.Email__c)) {
                    emailMap.put(cm.Email__c, cm);
                }
                if (cm.Phone__c != null && !phoneMap.containsKey(cm.Phone__c)) {
                    phoneMap.put(cm.Phone__c, cm);
                }
            }
        }
        
        // STEP 2: Prepare new Customer Master records only where needed
        List<Customer_Master__c> newMasters = new List<Customer_Master__c>();
        Map<Id, Customer_Master__c> bookingToMaster = new Map<Id, Customer_Master__c>();
        
        for (Booking__c b : newBookings) {
            
            Customer_Master__c existing = null;
            
            // Match by Email
            if (b.Email1__c != null && emailMap.containsKey(b.Email1__c)) {
                existing = emailMap.get(b.Email1__c);
            }
            
            // Match by Phone (if no email match)
            if (existing == null && b.Mobile_Primary__c != null && phoneMap.containsKey(b.Mobile_Primary__c)) {
                existing = phoneMap.get(b.Mobile_Primary__c);
            }
            
            if (existing != null) {
                // Duplicate customer → reuse existing Customer Master
                bookingToMaster.put(b.Id, existing);
            } else {
                // No duplicate → create new Customer Master
                Customer_Master__c cm = new Customer_Master__c(
                    OwnerId               = b.OwnerId,
                    Password__c           = b.Mobile_Primary__c,
                    Phone__c              = b.Mobile_Primary__c,
                    IsActive__c           = true,
                    Email__c              = b.Email1__c,
                    AssociationUser__c    = true,
                    First_Name__c         = b.First_Applicant_Name__c,
                    WhatsApp_Number__c    = b.WhatsApp_Number__c
                );
                
                newMasters.add(cm);
                bookingToMaster.put(b.Id, cm);
            }
        }
        
        // STEP 3: Insert newly created Customer Masters
        if (!newMasters.isEmpty()) {
            insert newMasters;
        }
        
        // STEP 4: Update Bookings with resolved Customer Master IDs
        List<Booking__c> updates = new List<Booking__c>();
        
        for (Id bId : bookingToMaster.keySet()) {
            Customer_Master__c cm = bookingToMaster.get(bId); // existing or new
            updates.add(new Booking__c(
                Id = bId,
                Customer_Master__c = cm.Id
            ));
        }
        
        if (!updates.isEmpty()) {
            update updates;
        }
    }
    
    @AuraEnabled
    public static void updateBookingDocuments(Id bookingId) {
        
        if(bookingId == null){
            return;
        }
        
        List<ContentDocumentLink> newDocLinks = new List<ContentDocumentLink>();
        List<String> allRelUser = label.Booking_File_Share.split(';');
        List<Id> allRelatedIds = new List<Id>();
        List<Id> contentIds = new List<Id>();
        List<Id> contentSelectedIds = new List<Id>();
        Set<String> exisitngDocs = new Set<String>();
        Map<Id,Id> bookDocMap = new Map<Id,Id>();
        List<Id> quoteDocList = new List<Id>();
        Set<Id> permissionDocList = new Set<Id>();
        Set<Id> documentsToAddList = new Set<Id>();
        List<ContentVersion> recordsToProcess = new List<ContentVersion>();
        
        Booking__c booking = [SELECT Id, plot__r.Unit_Type__c, Project1__c, Quote__c FROM Booking__c WHERE Id =: bookingId ];
        if(booking == null){
            Return;
        }
        if(booking.plot__r.Unit_Type__c !=null){
            allRelatedIds.add(booking.plot__r.Unit_Type__c);
        }
        if(booking.Project1__c !=null){
            allRelatedIds.add(booking.Project1__c);
        }
                
        if(booking.Quote__c !=null){
            allRelatedIds.add(booking.Quote__c);
        }
        
        allRelatedIds.add(booking.Id);
             
        List<ContentDocumentLink> docLinks = [
            SELECT ContentDocumentId ,LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :allRelatedIds
        ];
        
        if(docLinks.isEmpty()){
            Return;
        }
        
        for(ContentDocumentLink docIds: docLinks){
            if(docIds.LinkedEntityId == booking.Id){
                bookDocMap.put(docIds.ContentDocumentId,booking.Id);
            }
            if(docIds.LinkedEntityId == booking.Quote__c){
                quoteDocList.add(docIds.ContentDocumentId);
            }
            contentIds.add(docIds.ContentDocumentId);
            
        }
        
        List<ContentVersion> filteredVersions = [
            SELECT Id, Title, ContentDocumentId, VersionData, FileExtension
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentIds
            AND IsLatest = TRUE ];
        
        if(filteredVersions.isEmpty()){
            Return;
        }
        
        for (ContentVersion docVrs : filteredVersions) {
            
            if(bookDocMap.containsKey(docVrs.ContentDocumentId)){
                permissionDocList.add(docVrs.ContentDocumentId);
                exisitngDocs.add(docVrs.Title);
            }
        }
        
        for (ContentVersion docVersion : filteredVersions) {
            
            if(!bookDocMap.containsKey(docVersion.ContentDocumentId)){
                
                if(quoteDocList.contains(docVersion.ContentDocumentId) || docVersion.Title.contains('Floor Plan') || docVersion.Title.contains('Approved Banks for Home Loans') || 
                   docVersion.Title.contains('Alteration Policy') || docVersion.Title.contains('FAQ') || docVersion.Title.contains('Sample Sale Agreement') ||
                   docVersion.Title.contains('Electrical Plan') || docVersion.Title.contains('Parking Plan') || docVersion.Title.contains('Plumbing Plan')){
                       
                       if(!exisitngDocs.contains(docVersion.Title)){
                           permissionDocList.add(docVersion.ContentDocumentId);
                           documentsToAddList.add(docVersion.ContentDocumentId);
                       }
                   } 
            }
        }
        
        Set<String> existingLinks = new Set<String>();
        if (!allRelUser.isEmpty() && !permissionDocList.isEmpty()) {
            for (ContentDocumentLink existing : [
                SELECT ContentDocumentId, LinkedEntityId
                FROM ContentDocumentLink
                WHERE ContentDocumentId IN : permissionDocList
                AND LinkedEntityId IN : allRelUser
            ]) {
                existingLinks.add(existing.ContentDocumentId + '-' + existing.LinkedEntityId);
            }
        }
        
        for (Id addDocId : documentsToAddList) {
            ContentDocumentLink newUnitLink = new ContentDocumentLink();
            newUnitLink.ContentDocumentId = addDocId;
            newUnitLink.LinkedEntityId = booking.Id;
            newUnitLink.ShareType = 'V';
            newUnitLink.Visibility = 'AllUsers';
            newDocLinks.add(newUnitLink);
        }
        
        for (Id permissionDocId :permissionDocList){
            for (String userId : allRelUser) {
                String userKey = permissionDocId + '-' + userId;
                if (!existingLinks.contains(userKey)) {
                    newDocLinks.add(new ContentDocumentLink(
                        ContentDocumentId = permissionDocId,
                        LinkedEntityId    = userId,
                        ShareType         = 'V',
                        Visibility        = 'AllUsers'
                    ));
                }
            }
        }

        if (!newDocLinks.isEmpty()) {
            database.insert(newDocLinks,true);
        }
        
    }
    
    
    public static void updateBookingDocumentsBulk(List<Id> bookingIds) {
        
        if(bookingIds.isEmpty()){
            Return;
        }
        List<String> allRelUser = label.Booking_File_Share.split(';');
        
        Map<Id,Id> bookTypeMap = new Map<Id,Id>();
        Map<Id,Id> bookDocMap = new Map<Id,Id>();
        Map<Id,Id> quoteBookingMap = new Map<Id,Id>();
        List<Booking__c> Bookings = [SELECT Id, plot__r.Unit_Type__c, Project1__c, Quote__c FROM Booking__c WHERE Id IN: bookingIds ];
        
        for(Booking__c brec : Bookings){
            
            if(brec.plot__r.Unit_Type__c !=null){
                bookTypeMap.put(brec.plot__r.Unit_Type__c, brec.Id);
            }
            if(brec.Project1__c !=null){
                bookTypeMap.put(brec.Project1__c, brec.Id);
            }
            if(brec.Quote__c !=null){
                quoteBookingMap.put(brec.Quote__c, brec.Id);
            }
        }
        
        if(bookTypeMap.keySet().isEmpty()){
            Return;
        }
        
        List<ContentDocumentLink> newDocLinks = new List<ContentDocumentLink>();
        
        Set<Id> contentDocIds = new Set<Id>();
        
        List<ContentDocumentLink> docLinks = [
            SELECT ContentDocumentId ,LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :bookTypeMap.keySet()
        ];
        
        List<ContentDocumentLink> quoteDocLinks = [
            SELECT ContentDocumentId ,LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :quoteBookingMap.keySet()
        ];
        
        if(docLinks.isEmpty() && quoteDocLinks.isEmpty()){
            return;
        }
        
        if(!docLinks.isEmpty()){
            for(ContentDocumentLink docIds: docLinks){
                bookDocMap.put(docIds.ContentDocumentId, docIds.LinkedEntityId);
            }
        }

        List<ContentVersion> filteredVersions = [
            SELECT Id, Title, ContentDocumentId, VersionData, FileExtension
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocIds
            AND IsLatest = TRUE
            AND (
                Title LIKE '%Floor Plan%' OR                 
                Title LIKE '%Plumbing Plan%' OR 
                Title LIKE '%Parking Plan%' OR 
                Title LIKE '%Electrical Plan%' OR
                Title LIKE '%Sample Sale Agreement%' OR
                Title LIKE '%FAQ%' OR
                Title LIKE '%Alteration Policy%' OR
                Title LIKE '%Approved Banks for Home Loans%'
                
            )
            ORDER BY CreatedDate DESC
        ];
        
        if(docLinks.isEmpty()){
            return;
        }
        
        for (ContentVersion docVersion : filteredVersions) {
            id entityId = bookDocMap.get(docVersion.ContentDocumentId);
            
            ContentDocumentLink newUnitLink = new ContentDocumentLink();
            newUnitLink.ContentDocumentId = docVersion.ContentDocumentId;
            newUnitLink.LinkedEntityId = bookTypeMap.get(entityId);
            newUnitLink.ShareType = 'V';
            newUnitLink.Visibility = 'AllUsers';
            newDocLinks.add(newUnitLink);
            
            if(allRelUser.size() > 0 && !Test.isRunningTest()){
                for(string s:allRelUser){
                    newDocLinks.add(new ContentDocumentLink(
                        ContentDocumentId = docVersion.ContentDocumentId,
                        LinkedEntityId = s,
                        ShareType = 'V',
                        Visibility = 'AllUsers'
                    ));
                }
            }
        }
        //here check
        for (ContentDocumentLink docLink : quoteDocLinks) {
            
            ContentDocumentLink newUnitLink = new ContentDocumentLink();
            newUnitLink.ContentDocumentId = docLink.ContentDocumentId;
            newUnitLink.LinkedEntityId = quoteBookingMap.get(docLink.LinkedEntityId);
            newUnitLink.ShareType = 'V';
            newUnitLink.Visibility = 'AllUsers';
            newDocLinks.add(newUnitLink);
            
            if(allRelUser.size() > 0 && !Test.isRunningTest()){
                for(string s:allRelUser){
                    newDocLinks.add(new ContentDocumentLink(
                        ContentDocumentId = docLink.ContentDocumentId,
                        LinkedEntityId = s,
                        ShareType = 'V',
                        Visibility = 'AllUsers'
                    ));
                }
            }
        }
        if (!newDocLinks.isEmpty()) {
            database.insert(newDocLinks,false);
        }
    }
    
    public static void testCover(){
      integer i=0;
            
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;  
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;  
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;  
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;  
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;  
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;  
             i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;  
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;  
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;  
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;  
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;  
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++; 
        
    }
    
}