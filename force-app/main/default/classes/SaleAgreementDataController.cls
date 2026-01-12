public without sharing class SaleAgreementDataController {

    public class dataWrapper {
        @AuraEnabled public List<ApplicantWrapper> applicants { get; set; }
        @AuraEnabled public List<Map<String, String>> districtOptions { get; set; }
        @AuraEnabled public Boolean isSubmitted { get; set; }
        @AuraEnabled public Map<String, List<String>> districtTalukMap { get; set; }
        @AuraEnabled public List<Map<String, String>> occupationList { get; set; }

        public dataWrapper(List<ApplicantWrapper> apps, List<Map<String, String>> districtOptions, Boolean isSubmitted, Map<String, List<String>> districtTalukMap, List<Map<String, String>> occupationList) {
            this.applicants = apps;
            this.districtOptions = districtOptions;
            this.isSubmitted = isSubmitted;
            this.districtTalukMap = districtTalukMap;
            this.occupationList = occupationList;
        }
    }

   public class ApplicantWrapper {
    @AuraEnabled public String name { get; set; }
    @AuraEnabled public String type { get; set; }
    @AuraEnabled public String occupation { get; set; }
    @AuraEnabled public String district { get; set; }
    @AuraEnabled public String village { get; set; }
    //@AuraEnabled public String sro { get; set; }
    @AuraEnabled public String desom { get; set; }
    @AuraEnabled public String postOffice { get; set; }
    @AuraEnabled public String taluk { get; set; }
    @AuraEnabled public Id recordId { get; set; }

    @AuraEnabled public List<String> talukOptions { get; set; }
    @AuraEnabled public List<String> villageOptions { get; set; }
    @AuraEnabled public List<String> postOfficeOptions { get; set; }
    @AuraEnabled public Boolean isOccupationOthers { get; set; }
    @AuraEnabled public String occupationOthers { get; set; }


    public ApplicantWrapper(
        String name,
        String type,
        String occ,
        String dist,
        String village,
        String desom,
       String po,
        String taluk,
        Id recId,
        List<String> talukOptions,
        List<String> villageOptions,
        List<String> postOfficeOptions,
        Boolean isOccupationOthers,
        String occupationOthers
    ) {
        this.name = name;
        this.type = type;
        this.occupation = occ;
        this.district = dist;
        this.village = village;
        this.desom = desom;
       this.postOffice = po;
        this.taluk = taluk;
        this.recordId = recId;

        this.talukOptions = talukOptions;
        this.villageOptions = villageOptions;
        this.postOfficeOptions = postOfficeOptions;
        this.isOccupationOthers = isOccupationOthers;
        this.occupationOthers = occupationOthers;
    }
}


 @AuraEnabled(cacheable=true)
    public static dataWrapper getBookingApplicants(Id bookingId) {
        if (bookingId == null) {
            throw new VisualforceException('Booking Id cannot be null.');
        }

        try {
            System.debug('Booking Id: ' + bookingId);
            // Prepare return variables
            List<ApplicantWrapper> applicantList = new List<ApplicantWrapper>();
            Map<String, List<String>> dTMap = buildDistrictTalukMap();
            List<Map<String, String>> districtOptions = new List<Map<String, String>>();
            List<Map<String, String>> occupationOptions = new List<Map<String, String>>();
            List <String> occuList = getPicklistValues('Booking__c', 'Occupation__c');

            for(String occupation : occuList){
                occupationOptions.add(new Map<String, String>{
                    'label' => occupation,
                    'value' => occupation
                });
            }

            for (String district : dTMap.keySet()) {
            districtOptions.add(new Map<String, String>{
                'label' => district,
                'value' => district
            });
            }
            Boolean alreadyFilled = false;

            // --- Fetch Booking Record ---
            Booking__c booking = [
                SELECT Id, First_Applicant_Name__c, District__c, Occupation__c, Occupation_Other__c,
                       Received_Agreement_Details_from_Customer__c,Village_Panchayath__c,Desom__c,
                       Post_Office__c, Taluk__c
                FROM Booking__c
                WHERE Id = :bookingId
                LIMIT 1
            ];

            alreadyFilled = booking.Received_Agreement_Details_from_Customer__c;
            Boolean isOccupationOthers = false;
            String occupationOthers = '';
            if(booking.Occupation__c == 'Others'){
                isOccupationOthers = true;
                occupationOthers = booking.Occupation_Other__c;
            }
            
            
        List<String> talukOptions = new List<String>();
        List<String> villageOptions = new List<String>();
        List<String> postOfficeOptions = new List<String>();
            // --- Add Primary Applicant ---
            if (!String.isBlank(booking.First_Applicant_Name__c)) {
                applicantList.add(new ApplicantWrapper(
                    booking.First_Applicant_Name__c,
                    'Primary Applicant',
                    booking.Occupation__c,
                    booking.District__c,
                   booking.Village_Panchayath__c,
                    booking.Desom__c,
                   booking.Post_Office__c,
                   booking.Taluk__c,
                    booking.Id,
                    talukOptions,
                    villageOptions,
                    postOfficeOptions,
                    isOccupationOthers,
                    occupationOthers
                ));
            }

            // --- Fetch Co-Applicants ---
            for (Co_Applicant__c co : [
                SELECT Id, Name, Co_Applicant_Profession__c, Village_Panchayath__c,
                      /* SRO__c,*/ Desom__c, Post_Office__c, District__c, Taluk__c,Occupation_Other__c
                FROM Co_Applicant__c
                WHERE Booking__c = :bookingId
            ]) {

            Boolean isCoOccupationOthers = false;
            String cooccupationOthers = '';
            if(co.Co_Applicant_Profession__c == 'Others'){
                isOccupationOthers = true;
                cooccupationOthers = co.Occupation_Other__c;
            }

                applicantList.add(new ApplicantWrapper(
                    co.Name,
                    'Co-Applicant',
                    co.Co_Applicant_Profession__c,
                    co.District__c,
                    co.Village_Panchayath__c,
                    co.Desom__c,
                    co.Post_Office__c,
                   co.Taluk__c,
                    co.Id,
                    talukOptions,
                    villageOptions,
                    postOfficeOptions,
                    isCoOccupationOthers,
                    cooccupationOthers
                ));
            }

            // --- Return Final Wrapper ---
            return new dataWrapper(applicantList, districtOptions, alreadyFilled, dTMap, occupationOptions);

        } catch (Exception e) {
            System.debug('Error fetching applicants: ' + e);
            throw new VisualforceException('Error fetching applicants: ' + e.getMessage());
        }
    }

    public static map < String, List < String >>  buildDistrictTalukMap() {
        map < String, List < String >> districtTalukMap = new map < String, List < String >> ();

        // Get District picklist values
        List < String > districts = new List < String > ();
        for (
            Schema.PicklistEntry d: Village_List__c.District__c.getDescribe().getPicklistValues()
        ) {
            if (d.isActive())
                districts.add(d.getValue());
        }

        // Get Taluk picklist values
        List < String > taluks = new List < String > ();
        for (
            Schema.PicklistEntry t: Village_List__c.Taluk__c.getDescribe().getPicklistValues()
       ) {
            if (t.isActive())
                taluks.add(t.getValue());
        }

        // Build Map: District → Taluks
        for (String district: districts) {
            List < String > relatedTaluks = new List < String > ();
            for (String taluk: taluks) {
                if (taluk.startsWith(district + '-')) {
                    relatedTaluks.add(taluk.replace(district + '-', ''));
                }
            }
            districtTalukMap.put(district, relatedTaluks);
        }

        return districtTalukMap;
    }
  @AuraEnabled(cacheable=true)
    public static List<Post_Office_List__c> getPostOfficesByDistrict(String district) {
        System.debug('districtId: ' + district );
        if (String.isBlank(district)) {
            return new List<Post_Office_List__c>();
        }

        return [
            SELECT Id, Name, Pincode__c, District__c
            FROM Post_Office_List__c
            WHERE District__c = :district
            ORDER BY Name
        ];
    }

     @AuraEnabled(cacheable=true)
    public static List<Village_List__c> getVillagesByDistrictAndTaluk(String district, String taluk) {
        if (String.isBlank(district) || String.isBlank(taluk)) {
            return new List<Village_List__c>();
        }
        String talukClub = district + '-' + taluk;
        return [
            SELECT Id, Name, District__c , Taluk__c
            FROM Village_List__c
            WHERE District__c = :district
            AND Taluk__c = :talukClub
            ORDER BY Name
        ];
    }


    // Helper method to get picklist values for a field
    public Static List< String > getPicklistValues(String objectName, String fieldName) {
        List < String > values = new List < String > ();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
        for (Schema.PicklistEntry entry: fieldResult.getPicklistValues()) {
            values.add(entry.getLabel());
        }
        return values;
    }

    @AuraEnabled
      public static String saveApplicantDetails(String applicantJson) {
        System.debug('--- Start saveApplicantDetails ---'+ applicantJson);
        
       List<ApplicantWrapper> applicants = (List<ApplicantWrapper>) JSON.deserialize(applicantJson, List<ApplicantWrapper>.class);
       //List<ApplicantWrapper> applicants

        Apex_Log__c logEntry = new Apex_Log__c();
        logEntry.Request_Type__c = 'Save Applicant Details';
        logEntry.Request__c = 'Total Applicants Received: ' + (applicants != null ? applicants.size() : 0);
        
            List<Booking__c> bookingUpdates = new List<Booking__c>();
            List<Co_Applicant__c> coApplicantUpdates = new List<Co_Applicant__c>();
            
            for (ApplicantWrapper app : applicants) {
                System.debug('Processing Applicant: ' + app);
                
                if (app.type == 'Primary Applicant') {
                    Booking__c booking = new Booking__c(
                        Id = app.recordId, 
                        First_Applicant_Name__c = app.name,
                        Occupation__c = app.occupation, 
                       Village_Panchayath__c = app.village,
                        Desom__c = app.desom, 
                       Post_Office__c = app.postOffice,
                        District__c = app.district,
                       Taluk__c = app.taluk,
                        Received_Agreement_Details_from_Customer__c = true,
                        Occupation_Other__c = app.occupationOthers
                    );
                    bookingUpdates.add(booking);
                    System.debug('Added to Booking Updates: ' + booking);
                } else {
                    Co_Applicant__c coApp = new Co_Applicant__c(
                        Id = app.recordId, 
                        Name = app.name,
                        Co_Applicant_Profession__c = app.occupation, 
                        Village_Panchayath__c = app.village,
                        Desom__c = app.desom, 
                       Post_Office__c = app.postOffice,
                        District__c = app.district,
                        Taluk__c = app.taluk,
                        Occupation_Other__c = app.occupationOthers
                    );
                    coApplicantUpdates.add(coApp);
                    System.debug('Added to Co-Applicant Updates: ' + coApp);
                }
            }
            
            if (!bookingUpdates.isEmpty()) {
                update bookingUpdates;
                System.debug('Updated Booking Records: ' + bookingUpdates);
            } else {
                System.debug('No Booking Records to Update.');
            }
            
            if (!coApplicantUpdates.isEmpty()) {
                update coApplicantUpdates;
                System.debug('Updated Co-Applicant Records: ' + coApplicantUpdates);
            } else {
                System.debug('No Co-Applicant Records to Update.');
            }
            
            // Log success
            logEntry.Status__c = 'Success';
            logEntry.Request__c += ', Booking Count: ' + bookingUpdates.size() + ', Co-Applicant Count: ' + coApplicantUpdates.size();
            logEntry.Error_Message__c = null; // No errors
            
            System.debug('--- End saveApplicantDetails ---');
            return 'Success';
            
       /* } catch (Exception e) {
            System.debug('Error occurred: ' + e.getMessage());
            
            // Log error details
            logEntry.Status__c = 'Error';
            logEntry.Error_Message__c = e.getMessage();
            logEntry.Request__c += ', Error Occurred';
            
            return 'Error: ' + e.getMessage();
        } finally {
            insert logEntry;
        }*/
    }

}


   /* @AuraEnabled
    public static String saveApplicantDetails(List < ApplicantWrapper > applicants) {
        System.debug('--- Start saveApplicantDetails ---');

        // Create a log entry
        Apex_Log__c logEntry = new Apex_Log__c();
        logEntry.Request_Type__c = 'Save Applicant Details';
        logEntry.Request__c = 'Total Applicants Received: ' + (
            applicants != null ?
            applicants.size() :
            0
        );

        try {
            List < Booking__c > bookingUpdates = new List < Booking__c > ();
            List < Co_Applicant__c > coApplicantUpdates = new List < Co_Applicant__c > ();

            for (ApplicantWrapper app: applicants) {
                System.debug('Processing Applicant: ' + app);

                if (app.type == 'Primary Applicant') {
                    Booking__c booking = new Booking__c(
                        Id = app.recordId,
                        First_Applicant_Name__c = app.name,
                        Occupation__c = app.occupation,
                        Village_Panchayath__c = app.villagePanchayath,
                        SRO__c = app.sro,
                        Desom__c = app.desom,
                        Post_Office__c = app.postOffice,
                        District__c = app.district,
                        Taluk__c = app.Taluk,
                        Received_Agreement_Details_from_Customer__c = true
                    );
                    bookingUpdates.add(booking);
                    System.debug('Added to Booking Updates: ' + booking);
                } else {
                    Co_Applicant__c coApp = new Co_Applicant__c(
                        Id = app.recordId,
                        Name = app.name,
                        Co_Applicant_Profession__c = app.occupation,
                        Village_Panchayath__c = app.villagePanchayath,
                        SRO__c = app.sro,
                        Desom__c = app.desom,
                        Post_Office__c = app.postOffice,
                        District__c = app.district,
                        Taluk__c = app.Taluk
                    );
                    coApplicantUpdates.add(coApp);
                    System.debug('Added to Co-Applicant Updates: ' + coApp);
                }
            }

            if (!bookingUpdates.isEmpty()) {
                update bookingUpdates;
                System.debug('Updated Booking Records: ' + bookingUpdates);
            } else {
                System.debug('No Booking Records to Update.');
            }

            if (!coApplicantUpdates.isEmpty()) {
                update coApplicantUpdates;
                System.debug(
                    'Updated Co-Applicant Records: ' + coApplicantUpdates
                );
            } else {
                System.debug('No Co-Applicant Records to Update.');
            }

            // Log success
            logEntry.Status__c = 'Success';
            logEntry.Request__c += ', Booking Count: ' + bookingUpdates.size() + ', Co-Applicant Count: ' +
                coApplicantUpdates.size();
            logEntry.Error_Message__c = null; // No errors

            System.debug('--- End saveApplicantDetails ---');
            return 'Success';

        } catch (Exception e) {
            System.debug('Error occurred: ' + e.getMessage());

            // Log error details
            logEntry.Status__c = 'Error';
            logEntry.Error_Message__c = e.getMessage();
            logEntry.Request__c += ', Error Occurred';

            return 'Error: ' + e.getMessage();
        } finally {
            insert logEntry;
        }
    }*/