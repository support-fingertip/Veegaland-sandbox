public class CoApplicantController {
    public List<CoApplicant> coApplicants { get; set; }
    
    public CoApplicantController() {
        if (coApplicants == null) {
            coApplicants = new List<CoApplicant>();
            coApplicants.add(new CoApplicant());
        }
    }
    
    public void addCoApplicant() {
        coApplicants.add(new CoApplicant());
    }
    
    public void submit() {
        // Handle form submission logic here
    }
    
    public void cancel() {
        // Handle form cancellation logic here
    }
    
    public class CoApplicant {
        public String name { get; set; }
        public String phone { get; set; }
        public String email { get; set; }
        public String occupation { get; set; }
        public String aadharNo { get; set; }
        public String panNo { get; set; }
        public Blob aadharFile { get; set; }
        public String aadharFileName { get; set; }
        public Blob panFile { get; set; }
        public String panFileName { get; set; }
        public Blob photoFile { get; set; }
        public String photoFileName { get; set; }
    }
    @AuraEnabled
    public static List<Co_Applicant__c> getCoApplicants(Id bookingId) {
        return [SELECT Id,Salutation__c,Name,Date_of_Birth__c,Co_Applicant_NRI_RI__c,
                Co_Applicant_Profession__c,Co_Applicant_Father_Husband_s_Name__c,
                PAN_Number__c,Aadhar_Number__c,Passport_No__c,
                Co_Applicant_Driving_License_No__c,Email__c,Phone__c,
                Mobile__c,International_Phone__c,Permanent_House_No_Name__c,
                Permanent_Street_Location__c,Permanent_Post_Office__c,
                Permanent_City__c,Permanent_State__c,Permanent_Postal_Code__c,
                Permanent_Country__c,
                Correspondence_House_No_Name__c,Correspondence_Street_Location__c,
                Correspondence_Post_Office__c,Correspondence_City__c,
                Correspondence_State__c,Correspondence_Postal_Code__c,
                Correspondence_Country__c, Active__c
                FROM Co_Applicant__c 
                WHERE Booking__c = :bookingId AND Active__c = true];
    }
    
    @AuraEnabled
    public static void saveCoApplicants(List<Co_Applicant__c> coApplicants/*,List<Map<String, String>> fileDataList*/) {
        /* if(fileDataList.size() > 0){
saveFiles(fileDataList);
}*/
        upsert coApplicants;
    }
    
    @AuraEnabled
    public static List<Co_Applicant__c> addCoApplicants(String bookingId, List<Co_Applicant__c> coApplicants) {
        
            
       
        
        // Get the Quote__c from the Booking__c
        Booking__c booking = [SELECT Id, Quote__c FROM Booking__c WHERE Id = :bookingId LIMIT 1];
        Co_Applicant__c newco = new Co_Applicant__c ();
        newco.Name = 'Co-Applicant Name';
        newco.Correspondence_Country__c = 'India';
        newco.Permanent_Country__c = 'India';
        coApplicants.add(newco);
        if (!String.isEmpty(bookingId) || coApplicants != null || !coApplicants.isEmpty()) {
            for (Co_Applicant__c coApplicant : coApplicants) {
                if (coApplicant.Id == null) { // New Co-Applicant
                    coApplicant.Booking__c = bookingId;
                    coApplicant.Quote__c = booking.Quote__c; // Assign Quote__c
                }
            }
        }
        // Upsert the Co-Applicants
        upsert coApplicants;
        
        // Return all Co-Applicants related to the Booking
        return [SELECT Id, Name, Date_of_Birth__c, Booking__c, Quote__c 
                FROM Co_Applicant__c 
                WHERE Booking__c = :bookingId];
    }
    
    @AuraEnabled
    public static Map<String, List<String>> getPicklistValues() {
        Map<String, List<String>> picklists = new Map<String, List<String>>();
        List<String> PermanentCountryValues = new List<String>();
        Schema.DescribeFieldResult PermanentCountryResult = Co_Applicant__c.Permanent_Country__c.getDescribe();
        for (Schema.PicklistEntry entry : PermanentCountryResult.getPicklistValues()) {
            PermanentCountryValues.add(entry.getLabel());
        }
        picklists.put('PermanentCountry', PermanentCountryValues);
        
        List<String> PermanentStateValues = new List<String>();
        Schema.DescribeFieldResult PermanentStateResult = Co_Applicant__c.Permanent_State__c.getDescribe();
        for (Schema.PicklistEntry entry : PermanentStateResult.getPicklistValues()) {
            PermanentStateValues.add(entry.getLabel());
        }
        picklists.put('PermanentState',PermanentStateValues);
        
        List<String> CorrespondenceStateValues = new List<String>();
        Schema.DescribeFieldResult CorrespondenceStateResult = Co_Applicant__c.Correspondence_State__c.getDescribe();
        for (Schema.PicklistEntry entry : CorrespondenceStateResult.getPicklistValues()) {
            CorrespondenceStateValues.add(entry.getLabel());
        }
        picklists.put('CorrespondenceState', CorrespondenceStateValues);
        
        List<String> CorrespondenceCountryValues = new List<String>();
        Schema.DescribeFieldResult CorrespondenceCountryResult = Co_Applicant__c.Correspondence_Country__c.getDescribe();
        for (Schema.PicklistEntry entry : CorrespondenceCountryResult.getPicklistValues()) {
            CorrespondenceCountryValues.add(entry.getLabel());
        }
        picklists.put('CorrespondenceCountry', CorrespondenceCountryValues);
        
        List<String> SalutationValues = new List<String>();
        Schema.DescribeFieldResult SalutationResult = Co_Applicant__c.Salutation__c.getDescribe();
        for (Schema.PicklistEntry entry : SalutationResult.getPicklistValues()) {
            SalutationValues.add(entry.getLabel());
        }
        picklists.put('SalutationValues', SalutationValues);
        
        List<String> ProfessionValues = new List<String>();
        Schema.DescribeFieldResult ProfessionResult = Co_Applicant__c.Co_Applicant_Profession__c.getDescribe();
        for (Schema.PicklistEntry entry : ProfessionResult.getPicklistValues()) {
            ProfessionValues.add(entry.getLabel());
        }
        picklists.put('ProfessionValues', ProfessionValues);
        
        List<String> NRIRIValues = new List<String>();
        Schema.DescribeFieldResult NRIRIResult = Co_Applicant__c.Co_Applicant_NRI_RI__c.getDescribe();
        for (Schema.PicklistEntry entry : NRIRIResult.getPicklistValues()) {
            NRIRIValues.add(entry.getLabel());
        }
        picklists.put('NRIRIValues', NRIRIValues);
        
        return picklists;
    }
    @AuraEnabled
    public static void saveFiles(List<Map<String, String>> fileDataList) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        
        for (Map<String, String> fileData : fileDataList) {
            String coApplicantId = fileData.get('coApplicantId');
            
            ContentVersion cv = new ContentVersion();
            cv.Title = fileData.get('fileName'); // Set predefined name
            cv.PathOnClient = fileData.get('fileName');
            cv.VersionData = EncodingUtil.base64Decode(fileData.get('fileContent'));
            cv.FirstPublishLocationId = coApplicantId; // Link to Co-Applicant
            contentVersions.add(cv);
        }
        
        if (!contentVersions.isEmpty()) {
            insert contentVersions;
        }
    }
    @AuraEnabled
    public static String saveFile(String fileName, String fileRename, String base64Data, String coApplicantId) {
        
        system.debug('fileRename' +fileRename);
        try {
            Blob fileBody = EncodingUtil.base64Decode(base64Data);
            Id contentDocumentId = null;
            
            // Step 1: Get all ContentDocument IDs linked to this Co-Applicant
            List<ContentDocumentLink> linkedDocs = [
                SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :coApplicantId
            ];
            
            if (!linkedDocs.isEmpty()) {
                Set<Id> contentDocIds = new Set<Id>();
                for (ContentDocumentLink link : linkedDocs) {
                    contentDocIds.add(link.ContentDocumentId);
                }
                
                // Step 2: Check if a document with the same fileRename exists in the linked docs
                List<ContentDocument> existingDocs = [
                    SELECT Id FROM ContentDocument 
                    WHERE Id IN :contentDocIds AND Title = :fileRename
                    LIMIT 1
                ];
                
                if (!existingDocs.isEmpty()) {
                    contentDocumentId = existingDocs[0].Id; // Found existing document
                }
            }
            
            // Step 3: Upload a new version if file exists, else create a new file
            ContentVersion cv = new ContentVersion();
            cv.Title = fileRename;
            cv.PathOnClient = fileName;
            cv.VersionData = fileBody;
            
            if (contentDocumentId != null) {
                cv.ContentDocumentId = contentDocumentId; // Add a new version
            }
            
            insert cv;
            
            // Step 4: If it's a new file, link it to Co_Applicant__c
            if (contentDocumentId == null) {
                contentDocumentId = [
                    SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1
                ].ContentDocumentId;
                
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = contentDocumentId;
                cdl.LinkedEntityId = coApplicantId;
                cdl.ShareType = 'V'; 
                insert cdl;
            }
            
            return 'File uploaded successfully';
        } catch (Exception e) {
            throw new AuraHandledException('Error uploading file: ' + e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<Co_Applicant__c> getCoApplicantsWithFiles(List<Id> coAppIds) {
        if (coAppIds == null || coAppIds.isEmpty()) {
            return new List<Co_Applicant__c>();
        }
        
        // Fetch all linked ContentDocumentLinks for given Co_Applicants
        List<ContentDocumentLink> docLinks = [
            SELECT LinkedEntityId, ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :coAppIds
        ];
        
        // Extract ContentDocument IDs
        Set<Id> contentDocIds = new Set<Id>();
        for (ContentDocumentLink docLink : docLinks) {
            contentDocIds.add(docLink.ContentDocumentId);
        }
        
        // Fetch ContentDocument details
        Map<Id, ContentDocument> docMap = new Map<Id, ContentDocument>();
        if (!contentDocIds.isEmpty()) {
            for (ContentDocument doc : [
                SELECT Id, Title, LatestPublishedVersionId 
                FROM ContentDocument 
                WHERE Id IN :contentDocIds
            ]) {
                docMap.put(doc.Id, doc);
            }
        }
        
        // Fetch and update Co_Applicants
        Map<Id, Co_Applicant__c> coAppMap = new Map<Id, Co_Applicant__c>();
        for (Co_Applicant__c coApp : [
            SELECT Id, Name, Aadhar_Document_Title__c, PAN_Document_Title__c, Photo_Document_Title__c 
            FROM Co_Applicant__c 
            WHERE Id IN :coAppIds
        ]) {
            coAppMap.put(coApp.Id, coApp);
        }
        
        // Assign document URLs to Co_Applicant__c records
        for (ContentDocumentLink docLink : docLinks) {
            if (docMap.containsKey(docLink.ContentDocumentId)) {
                ContentDocument doc = docMap.get(docLink.ContentDocumentId);
                String fileUrl = '/sfc/servlet.shepherd/version/download/' + doc.LatestPublishedVersionId;
                
                if (coAppMap.containsKey(docLink.LinkedEntityId)) {
                    Co_Applicant__c coApp = coAppMap.get(docLink.LinkedEntityId);
                    if (doc.Title.contains('Aadhar Card')) {
                        coApp.Aadhar_Document_Title__c = fileUrl;
                    } else if (doc.Title.contains('PAN Card')) {
                        coApp.PAN_Document_Title__c = fileUrl;
                    } else if (doc.Title.contains('Passport Size Photo')) {
                        coApp.Photo_Document_Title__c = fileUrl;
                    }
                }
            }
        }
        
        return new List<Co_Applicant__c>(coAppMap.values());
    }
    @AuraEnabled
    public static List<Co_Applicant__c> updateCoApplicantStatus(Id coApplicantId, Id bookingId) {
        try {
            // Deactivate the co-applicant
            Co_Applicant__c coApplicant = [SELECT Id, Active__c FROM Co_Applicant__c WHERE Id = :coApplicantId LIMIT 1];
            coApplicant.Active__c = false;
            update coApplicant;
            
            // Fetch updated co-applicant list for the given booking
            return [SELECT Id, Name, Active__c FROM Co_Applicant__c WHERE Booking__c = :bookingId AND Active__c = true];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}