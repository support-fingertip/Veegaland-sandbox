/*
*********************************************************
Apex Class Name    : FinalBookingFormCtrl
Created Date       : Feb 14, 2025
@description       : This class is used as VF Page(FinalBookingForm.vfp) Controller to fetch the details related to Quote 
@author            : Mayuri Patel
Modification Log:
Ver   Date         Author                  Modification
1.0   14-02-2025   Mayuri Patel            Initial Version
*********************************************************
*/
public class FinalBookingFormCtrl {
    
    public List<Co_Applicant__c> applicants {get; set; }
    public Co_Applicant__c secApplicant {get; set; }
    public List<String> applicantTitles { get; set; }
    public Map<String, String> fileUrls { get; set; }
    public Map<String, String> signatureUrls { get; set; }
    public Quote__c quote {get; set;}
    
    public FinalBookingFormCtrl(ApexPages.StandardController controller) 
    {
        string quoteId = ApexPages.currentPage().getParameters().get('id');
        
        List<Co_Applicant__c> applicants1 = [select id,Name,Salutation__c,Date_of_Birth__c, Co_Applicant_NRI_RI__c, Co_Applicant_Profession__c,  
                                             Co_Applicant_Father_Husband_s_Name__c, PAN_Number__c, Aadhar_Number__c, Co_Applicant_Driving_License_No__c,  
                                             Passport_No__c, Email__c,Mobile__c,  Phone__c, International_Phone__c, Permanent_House_No_Name__c, 
                                             Permanent_Street_Location__c, Permanent_Post_Office__c, Permanent_City__c, Permanent_Postal_Code__c,  
                                             Permanent_State__c, Permanent_Country__c, Correspondence_House_No_Name__c, Correspondence_Street_Location__c, 
                                             Correspondence_Post_Office__c, Correspondence_City__c, Correspondence_Postal_Code__c, Correspondence_State__c,
                                             Correspondence_Country__c  from Co_Applicant__c where Quote__c =:quoteId order by createddate];
        quote = [Select  Id, Projects__r.Locality_Name__c, Projects__r.City__c, Date_Of_Transaction__c From Quote__c where Id= : quoteId  ];
        
        
        applicants = new List<Co_Applicant__c>();
        
        List<String> parentRecordIds = new List<String>();
        parentRecordIds.add(quoteId);
        
        if(applicants1.size() > 0){
            secApplicant = applicants1[0];
            parentRecordIds.add(secApplicant.Id);
            for(Co_Applicant__c app: applicants1){
                if(app.Id != secApplicant.Id){
                    applicants.add(app);
                    parentRecordIds.add(app.Id);
                }
            }
        }
        
        // Generate ordinal titles
        applicantTitles = new List<String>();
        for (Integer i = 0; i < applicants.size(); i++) {
            applicantTitles.add(getOrdinalWord(i + 3)); // Start from "Second"
        }
        
        fetchFilesForParents(parentRecordIds);
        fetchSignatureFiles(parentRecordIds);
    }
    
    public void fetchFilesForParents(List<String> parentRecordIds) {
        fileUrls = new Map<String, String>();
        
        // Example: Replace with dynamic Parent Record IDs
        // List<String> parentRecordIds = new List<String>{'001XXXXXXXXXXXXXXX', '001YYYYYYYYYYYYY'}; 
        
        // Fetch the ContentDocumentLinks that are associated with the Parent Records
        List<ContentDocumentLink> cdlList = [
            SELECT ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :parentRecordIds
            AND ContentDocument.Title LIKE '%Passport Size Photo%' 
        ];
        
        if (!cdlList.isEmpty()) {
            // Create a map to associate ContentDocumentId with Parent record Id
            Map<Id, String> documentToParent = new Map<Id, String>();
            for (ContentDocumentLink cdl : cdlList) {
                documentToParent.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
            }
            
            // Fetch the latest version for each ContentDocumentId
            List<ContentVersion> cvList = [
                SELECT Id, ContentDocumentId, VersionNumber 
                FROM ContentVersion 
                WHERE ContentDocumentId IN :documentToParent.keySet()
                ORDER BY ContentDocumentId, VersionNumber DESC
            ];
            
            // Iterate through ContentVersion records to fetch the latest file URL for each parent
            Map<Id, ContentVersion> latestVersions = new Map<Id, ContentVersion>();
            for (ContentVersion cv : cvList) {
                // If the document doesn't have an entry yet, or the current version is newer, update it
                if (!latestVersions.containsKey(cv.ContentDocumentId)) {
                    latestVersions.put(cv.ContentDocumentId, cv);
                }
            }
            
            // Generate the file URL for each parent record with the latest document version
            for (ContentVersion cv : latestVersions.values()) {
                String fileUrl = '/sfc/servlet.shepherd/version/download/' + cv.Id;
                fileUrls.put(documentToParent.get(cv.ContentDocumentId), fileUrl);
            }
        }
    }
    
    
    public void fetchSignatureFiles(List<String> parentRecordIds) {
        signatureUrls = new Map<String, String>();
        
        // Step 1: Fetch the ContentDocumentLinks for the given parent record IDs
        List<ContentDocumentLink> cdlList = [
            SELECT ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :parentRecordIds
            AND ContentDocument.Title LIKE '%Digital Signature%'
        ];
        
        if (!cdlList.isEmpty()) {
            Map<Id, String> documentToParent = new Map<Id, String>();
            for (ContentDocumentLink cdl : cdlList) {
                documentToParent.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
            }
            
            // Step 2: Fetch only the latest version of each document
            List<ContentVersion> cvList = [
                SELECT Id, ContentDocumentId 
                FROM ContentVersion 
                WHERE ContentDocumentId IN :documentToParent.keySet()
                AND IsLatest = TRUE
            ];
            
            // Step 3: Store the latest version URL in the map
            for (ContentVersion cv : cvList) {
                String fileUrl = '/sfc/servlet.shepherd/version/download/' + cv.Id;
                signatureUrls.put(documentToParent.get(cv.ContentDocumentId), fileUrl);
            }
        }
    }
    
    public class FileWrapper {
        public String parentId { get; set; }
        public String contentVersionId { get; set; }
        public String fileUrl { get; set; }
        
        public FileWrapper(String parentId, String contentVersionId, String fileUrl) {
            this.parentId = parentId;
            this.contentVersionId = contentVersionId;
            this.fileUrl = fileUrl;
        }
    }
    
    // Method to convert numbers to words (1 → First, 2 → Second, etc.)
    public static String getOrdinalWord(Integer order) { 
        Map<Integer, String> ordinals = new Map<Integer, String>{
            1 => 'First', 2 => 'Second', 3 => 'Third', 4 => 'Fourth', 5 => 'Fifth',
                6 => 'Sixth', 7 => 'Seventh', 8 => 'Eighth', 9 => 'Ninth', 10 => 'Tenth'
                };
                    return ordinals.containsKey(order) ? ordinals.get(order) : order + 'th';
    }
    
    /*   public static String getFileUrl(String parentRecordId) {
//String parentRecordId = 'a09In000000jUexIAE'; // Parent Record ID
ContentDocumentLink cdl = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :parentRecordId and ContentDocument.Title LIKE '%Passport Size Photo%' LIMIT 1];
ContentVersion cv; 
if (cdl != null) {
cv = [
SELECT Id, ContentDocumentId 
FROM ContentVersion 
WHERE ContentDocumentId = :cdl.ContentDocumentId 
ORDER BY VersionNumber DESC 
LIMIT 1
];
}

return '/sfc/servlet.shepherd/version/download/' + cv.Id;

}*/
    
}