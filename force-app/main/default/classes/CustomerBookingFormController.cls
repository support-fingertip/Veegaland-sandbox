public without sharing class CustomerBookingFormController {
    public String bookingId { get; set; }
    public Quote__c bookingRecord { get; set; }
    public String serializedBooking { get; set; }
    public Blob fileToUpload { get; set; }
    public String fileNameToUpload { get; set; }
    public Boolean alreadyUpdated { get; set; }
    public Map<String, ContentDocumentLink> uploadedFiles { get; set; }
    public String currentDocumentType { get; set; }
    public List<Co_Applicant__c> coApplicants { get; set; }
    
    public Boolean isAadharFrontUploaded { get; set; }
    public Boolean isAadharBackUploaded { get; set; }
    public Boolean isPanUploaded { get; set; }
    public Boolean isPhotoUploaded { get; set; }
    
    public CustomerBookingFormController() {
        bookingId = ApexPages.currentPage().getParameters().get('Id');
        //bookingId = decryptRecordId(passedId);
        if (bookingId != null) {
            // Fetch Booking record and related fields
            bookingRecord = [
                SELECT BHK_Type__c,Primary_Applicant_Saluaion__c,Primary_Applicant_Name__c,
                Primary_Applicant_DoB__c,Primary_Applicant_NRI_RI__c,Primary_Applicant_Profession__c,
                Primary_Applicant_Father_Husband_s_Name__c,Primary_Applicant_PAN__c,
                Primary_Applicant_Aadhaar_No__c,Primary_Applicant_Driving_License_No__c,
                Primary_Applicant_Passport_No__c,Primary_Applicant_Email__c,Primary_Applicant_Mobile_No__c,
                Primary_Applicant_Telephone_No__c,Primary_Applicant_International_No__c,Permanent_House_No_Name__c,
                Permanent_Street_Location__c,Permanent_Post_Office__c,Permanent_City__c,Permanent_State__c,
                Permanent_Postal_Code__c,Permanent_Country__c,Correspondence_House_No_Name__c,
                Correspondence_Street_Location__c,Correspondence_Post_Office__c,Correspondence_City__c,
                Correspondence_State__c,Correspondence_Postal_Code__c,Correspondence_Country__c, Block__c, 
                Floor__c, Unit_Facing_Direction__c, Unit__r.Name, Super_built_up_area__c, Carpet_Area__c,Booking_Form_Updated_By_Customer__c,
                Passport_Document_Title__c,Photo_Document_Title__c,PAN_Document_Title__c,Aadhar_Document_Title__c,Aadhar_Document_Title1__c,Project__c,Unit_Name__c
                FROM Quote__c
                WHERE Id = :bookingId
                LIMIT 1
            ];
            alreadyUpdated = bookingRecord.Booking_Form_Updated_By_Customer__c;
            system.debug('bookingRecord  '+bookingRecord);
            serializedBooking = JSON.serialize(bookingRecord);
            fetchUploadedDocuments();
            
        } else {
            bookingRecord = new Quote__c();
        }
    }
    @RemoteAction
    public static List<Co_Applicant__c> getCoApplicants(String bookingId) {
        // Query existing Co-Applicants for the given booking
        List<Co_Applicant__c> coApplicants = [SELECT Id, Salutation__c,Name,Date_of_Birth__c,Co_Applicant_NRI_RI__c,Co_Applicant_Profession__c,Co_Applicant_Father_Husband_s_Name__c,
                                              PAN_Number__c,Aadhar_Number__c,Passport_No__c,Co_Applicant_Driving_License_No__c,Email__c,
                                              Phone__c,Mobile__c,International_Phone__c,Permanent_House_No_Name__c,Permanent_Street_Location__c,
                                              Permanent_Post_Office__c,Permanent_City__c,Permanent_State__c,Permanent_Postal_Code__c,
                                              Permanent_Country__c,Correspondence_House_No_Name__c,Correspondence_Street_Location__c,Correspondence_Post_Office__c,Correspondence_City__c,
                                              Correspondence_State__c,Correspondence_Postal_Code__c,Correspondence_Country__c, 
                                              Passport_Document_Title__c,Photo_Document_Title__c,PAN_Document_Title__c,Aadhar_Document_Title__c,Aadhar_Document_Title1__c
                                              FROM Co_Applicant__c WHERE Quote__c = :bookingId ORDER BY CreatedDate ASC];
        
        // Fetch associated documents
        Set<Id> coAppIds = new Set<Id>();
        for (Co_Applicant__c coApp : coApplicants) {
            coAppIds.add(coApp.Id);
        }
        if(coAppIds.size() >0){
        List<ContentDocumentLink> docLinks = [SELECT LinkedEntityId, ContentDocumentId,ContentDocument.LatestPublishedVersionId
                                              FROM ContentDocumentLink 
                                              WHERE LinkedEntityId IN :coAppIds];
        
        // Map to store file titles and IDs for each co-applicant
        Map<Id, List<ContentDocument>> coAppFileMap = new Map<Id, List<ContentDocument>>();
        
        for (ContentDocumentLink docLink : docLinks) {
            if (!coAppFileMap.containsKey(docLink.LinkedEntityId)) {
                coAppFileMap.put(docLink.LinkedEntityId, new List<ContentDocument>());
            }
            coAppFileMap.get(docLink.LinkedEntityId).add([SELECT Id, Title,ContentDocument.LatestPublishedVersionId FROM ContentDocument WHERE Id = :docLink.ContentDocumentId]);
        }
        
        // Assign document titles to co-applicants
        for (Co_Applicant__c coApp : coApplicants) {
            List<ContentDocument> files = coAppFileMap.get(coApp.Id);
            if (files != null) {
                for (ContentDocument file : files) {
                    if (file.Title != null) {
                        if (file.Title.contains('Aadhar Card Front')) {
                            coApp.Aadhar_Document_Title__c = '/sfc/servlet.shepherd/version/download/' + file.LatestPublishedVersionId;
                        }else if (file.Title.contains('Aadhar Card Back')) {
                            coApp.Aadhar_Document_Title1__c = '/sfc/servlet.shepherd/version/download/' + file.LatestPublishedVersionId;
                        } else if (file.Title.contains('PAN Card')) {
                            coApp.PAN_Document_Title__c = '/sfc/servlet.shepherd/version/download/' + file.LatestPublishedVersionId;
                        } else if (file.Title.contains('Passport Size Photo')) {
                            coApp.Photo_Document_Title__c = '/sfc/servlet.shepherd/version/download/' + file.LatestPublishedVersionId;
                        }
                    }
                }
            }
        }
        }
        system.debug(coApplicants);
        return coApplicants;
    }
    @RemoteAction
    public static Quote__c getQuoteDocuments(String quoteId) {
        if (String.isEmpty(quoteId)) {
            return null; // Handle empty ID case
        }
        
        // Step 1: Fetch Quote__c Record
        Quote__c quoteRecord = [
            SELECT Id, Passport_Document_Title__c, Photo_Document_Title__c,
            PAN_Document_Title__c, Aadhar_Document_Title__c,Aadhar_Document_Title1__c
            FROM Quote__c 
            WHERE Id = :quoteId
            LIMIT 1
        ];
        
        // Step 2: Fetch Document Files Linked to Quote__c
        List<ContentDocumentLink> docLinks = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :quoteId
        ];
        
        if (docLinks.isEmpty()) {
            return quoteRecord; // No documents linked
        }
        
        // Step 3: Get the Latest Version of Each Document
        List<Id> docIds = new List<Id>();
        for (ContentDocumentLink link : docLinks) {
            docIds.add(link.ContentDocumentId);
        }
        
        Map<String, String> latestFileUrls = new Map<String, String>();
        
        List<ContentVersion> latestVersions = [
            SELECT ContentDocumentId, Title, ContentDocument.LatestPublishedVersionId
            FROM ContentVersion 
            WHERE ContentDocumentId IN :docIds 
            ORDER BY CreatedDate DESC
        ];
        
        for (ContentVersion version : latestVersions) {
            // Corrected file download URL using ContentDocumentId
            String fileUrl = '/sfc/servlet.shepherd/version/download/' + version.Id;
            
            if (version.Title.contains('Applicant Aadhar Card Front')) {
                latestFileUrls.put('Aadhar_Front', fileUrl);
            }else if (version.Title.contains('Applicant Aadhar Card Back')) {
                latestFileUrls.put('Aadhar_Back', fileUrl);
            } else if (version.Title.contains('Applicant PAN Card')) {
                latestFileUrls.put('PAN', fileUrl);
            } else if (version.Title.contains('Applicant Passport Size Photo')) {
                latestFileUrls.put('Photo', fileUrl);
            }
        }
        
        // Step 4: Update the Quote Record with Latest File URLs
        if (latestFileUrls.containsKey('Aadhar_Front')) {
            quoteRecord.Aadhar_Document_Title__c = latestFileUrls.get('Aadhar_Front');
        }
         if (latestFileUrls.containsKey('Aadhar_Back')) {
            quoteRecord.Aadhar_Document_Title1__c = latestFileUrls.get('Aadhar_Back');
        }
        if (latestFileUrls.containsKey('PAN')) {
            quoteRecord.PAN_Document_Title__c = latestFileUrls.get('PAN');
        }
        if (latestFileUrls.containsKey('Photo')) {
            quoteRecord.Photo_Document_Title__c = latestFileUrls.get('Photo');
        }
        
        return quoteRecord;
    }
    
    
    
    // Upload methods for specific document types
    public PageReference uploadAadhar() {
        uploadDocument('Applicant Aadhar Card');
        return null;
    }
    
    public PageReference uploadPan() {
        uploadDocument('Applicant PAN Card');
        return null;
    }
    
    public PageReference uploadPhoto() {
        uploadDocument('Applicant Passport Size Photo');
        return null;
    }
    
    // Common upload logic
        @TestVisible
    private void uploadDocument(String documentType) {
        try {
            if (fileToUpload != null) {
                saveFile(fileToUpload, fileNameToUpload, documentType);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, documentType + ' uploaded successfully.'));
                fetchUploadedDocuments();
            }
        } catch (Exception e) {
              ExceptionHandler.addLog(e,documentType,'CustomerBookingFormController','');  /*Add Exception to error log*/
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error while uploading file: ' + e.getMessage()));
        }
    }
    
    // Save file as ContentDocument
    @TestVisible
    private void saveFile(Blob fileBody, String fileName, String documentType) {
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = documentType;
        contentVersion.PathOnClient = fileName;
        contentVersion.VersionData = fileBody;
        contentVersion.FirstPublishLocationId = bookingRecord.Id;
        insert contentVersion;
        
    }
    
    @RemoteAction
    public static String uploadCoApplicantFile(String quoteString, String coApplicantsJson, String coApplicantId, String fileName, String base64Data, String documentType, String title) {
        try {
            
            system.debug('quoteString  '+quoteString);
            Quote__c quote = (Quote__c) JSON.deserialize(quoteString, Quote__c.class);
            upsert quote;
            
            // Deserialize co-applicants
            List<Co_Applicant__c> coApplicants = 
                (List<Co_Applicant__c>) JSON.deserialize(coApplicantsJson, List<Co_Applicant__c>.class);
            
            // Associate each co-applicant to the booking
            for (Co_Applicant__c coApp : coApplicants) {
                coApp.Quote__c = quote.Id;
            }

            upsert coApplicants;
            
            // Get all linked ContentDocumentIds for the record
            List<Id> contentDocIds = new List<Id>();
            List<ContentDocumentLink> existingLinks = [
                SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :coApplicantId
            ];
            
            for (ContentDocumentLink link : existingLinks) {
                contentDocIds.add(link.ContentDocumentId);
            }
            
            ContentDocument existingDoc = null;
            if (!contentDocIds.isEmpty()) {
                // Query all ContentDocuments at once
                List<ContentDocument> contentDocs = [
                    SELECT Id, Title FROM ContentDocument WHERE Id IN :contentDocIds
                ];
                
                for (ContentDocument doc : contentDocs) {
                    if (doc.Title == title) {
                        existingDoc = doc;
                        break;
                    }
                }
            }
            
            ContentVersion fileVersion = new ContentVersion();
            fileVersion.Title = title;
            fileVersion.PathOnClient = fileName;
            fileVersion.Origin='C';
            fileVersion.VersionData = EncodingUtil.base64Decode(base64Data);
            
            if (existingDoc != null) {
                // Create a new version of the existing document
                fileVersion.ContentDocumentId = existingDoc.Id;
            } else {
                // First-time upload, create a new document
                fileVersion.FirstPublishLocationId = coApplicantId;
            }
            
            insert fileVersion;
            
            if (existingDoc == null) {
                // If it's a new document, link it to the record
                ContentDocument contentDoc = [
                    SELECT Id FROM ContentDocument 
                    WHERE LatestPublishedVersionId = :fileVersion.Id 
                    LIMIT 1
                ];
                
                ContentDocumentLink docLink = new ContentDocumentLink();
                docLink.LinkedEntityId = coApplicantId;
                docLink.ContentDocumentId = contentDoc.Id;
                docLink.Visibility = 'AllUsers';
                docLink.ShareType = 'V'; // Viewer access
                
                insert docLink;
               
            }
            
            return 'File Uploaded Successfully: ' + (existingDoc != null ? existingDoc.Id : fileVersion.Id);
            
        } catch (Exception e) {
              ExceptionHandler.addLog(e,coApplicantsJson,'CustomerBookingFormController',coApplicantId);  /*Add Exception to error log*/
            return 'Error uploading ' + documentType + ': ' + e.getMessage();
          
        }
    }
    
    
    
    // Fetch uploaded documents
    private void fetchUploadedDocuments() {
        uploadedFiles = new Map<String, ContentDocumentLink>();
        List<ContentDocumentLink> documentLinks = [
            SELECT Id, LinkedEntityId, ContentDocument.Title, ContentDocument.FileExtension, ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :bookingId
        ];
        
        // Initialize flags based on the documents present
        isAadharFrontUploaded = false;
        isAadharBackUploaded = false;
        isPanUploaded = false;
        isPhotoUploaded = false;
        
        for (ContentDocumentLink link : documentLinks) {
            uploadedFiles.put(link.ContentDocument.Title, link);
            // Check for specific document types
            if (link.ContentDocument.Title == 'Applicant Aadhar Card Front') {
                isAadharFrontUploaded = true;
            }else if (link.ContentDocument.Title == 'Applicant Aadhar Card Back') {
                isAadharBackUploaded = true;
            } else if (link.ContentDocument.Title == 'Applicant PAN Card') {
                isPanUploaded = true;
            } else if (link.ContentDocument.Title == 'Applicant Passport Size Photo') {
                isPhotoUploaded = true;
            }
        }
        system.debug('uploadedFiles' + uploadedFiles);
    }
    
    @RemoteAction
    public static String saveBookingAndCoApplicants(String bookingJson, String coApplicantsJson) {
        Apex_Log__c logEntry = new Apex_Log__c();
        logEntry.Request_Type__c = 'Save Booking & Co-Applicants';
        
        try {
           
            // Convert JSON string to Quote__c object
            Quote__c quote = (Quote__c) JSON.deserialize(bookingJson, Quote__c.class);
            logEntry.Request__c = 'Booking ID: ' + (quote != null ? quote.Id : 'N/A');
            
            quote.Booking_Form_Updated_By_Customer__c = true;
            quote.Customer_form_updated_date__c = system.now();
            upsert quote;
            System.debug('Booking upserted successfully');
            
            // Deserialize co-applicants
            List<Co_Applicant__c> coApplicants = 
                (List<Co_Applicant__c>) JSON.deserialize(coApplicantsJson, List<Co_Applicant__c>.class);
            
            // Associate each co-applicant to the booking
            for (Co_Applicant__c coApp : coApplicants) {
                coApp.Quote__c = quote.Id;
            }
            
            upsert coApplicants;
            
            logEntry.Status__c = 'Success';
            logEntry.Request__c += ', Co-Applicants Count: ' + (coApplicants != null ? coApplicants.size() : 0);
            logEntry.Error_Message__c = null;
            
            return 'success';
        } catch (Exception e) {
              ExceptionHandler.addLog(e,coApplicantsJson,'CustomerBookingFormController','');  /*Add Exception to error log*/
            String errorMessage = 'Exception: ' + e.getMessage() + '\nStack Trace:\n' + e.getStackTraceString();
            System.debug(errorMessage);
            
            logEntry.Status__c = 'Error';
            logEntry.Error_Message__c = errorMessage;
            logEntry.Request__c += ', Error Occurred';
            
            return 'Error: ' + errorMessage;
        } finally {
            try {
                insert logEntry;
            } catch (Exception logEx) {
                System.debug('Failed to insert log entry: ' + logEx.getMessage());
            }
        }
    }
    
    
    
    @RemoteAction
    public static String getBookingDetails(Id bookingId) {
        try {
            Quote__c booking = [SELECT Id, Primary_Applicant_Name__c,Primary_Applicant_Saluaion__c,
                                Primary_Applicant_DoB__c,Primary_Applicant_NRI_RI__c,
                                Primary_Applicant_Profession__c,Primary_Applicant_Father_Husband_s_Name__c,
                                Primary_Applicant_PAN__c,Primary_Applicant_Aadhaar_No__c,Primary_Applicant_Passport_No__c,
                                Primary_Applicant_Driving_License_No__c,Primary_Applicant_Email__c,
                                Primary_Applicant_Mobile_No__c,Primary_Applicant_Telephone_No__c,
                                Primary_Applicant_International_No__c,Permanent_House_No_Name__c,
                                Permanent_Street_Location__c,Permanent_Post_Office__c,Permanent_City__c,
                                Permanent_State__c,Permanent_Postal_Code__c,Permanent_Country__c,
                                Correspondence_House_No_Name__c,Correspondence_Street_Location__c,
                                Correspondence_Post_Office__c,Correspondence_City__c,Correspondence_State__c,
                                Correspondence_Postal_Code__c,Correspondence_Country__c,Unit_Name__c
                                FROM Quote__c WHERE Id = :bookingId LIMIT 1];
            String serializedBooking = JSON.serialize(booking);
            return serializedBooking;
        } catch (Exception e) {
              ExceptionHandler.addLog(e,'','CustomerBookingFormController',bookingId);  /*Add Exception to error log*/
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }
    @RemoteAction
    public static String deleteCoApplicant(Id coApplicantId) {
        try {
            delete [SELECT Id FROM Co_Applicant__c WHERE Id = :coApplicantId];
            return 'success';
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
    @RemoteAction
    public static Co_Applicant__c createBlankCoApplicant(Id bookingId) {
        try {
            Co_Applicant__c newCoApplicant = new Co_Applicant__c(
                Name = 'New Co-Applicant', 
                Quote__c = bookingId
            );
            insert newCoApplicant;
            return newCoApplicant; // Return the created record with ID
        } catch (Exception e) {
            System.debug('Error creating Co-Applicant: ' + e.getMessage());
            return null;
        }
    }
    @TestVisible
    public static String decryptRecordId(String encryptedRecordId) {
        String keyString = 'fingerti(#p#)rivateLimited#edKey';
        Blob key = Blob.valueOf(keyString);
        Blob encryptedData = EncodingUtil.base64Decode(encryptedRecordId);
        
        Blob decryptedData = Crypto.decryptWithManagedIV('AES256', key, encryptedData);
        return decryptedData.toString();
    }
    
    @RemoteAction
    public static String uploadFile(String fileNaming, String fileName, String fileData, String recordId) {
        try{
            if (String.isEmpty(recordId)) {
                return 'Error: No Record ID Provided!';
            }
            
            // Get all linked ContentDocumentIds for the record
            List<Id> contentDocIds = new List<Id>();
            List<ContentDocumentLink> existingLinks = [
                SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId
            ];
            
            for (ContentDocumentLink link : existingLinks) {
                contentDocIds.add(link.ContentDocumentId);
            }
            
            ContentDocument existingDoc = null;
            if (!contentDocIds.isEmpty()) {
                // Query all ContentDocuments at once
                List<ContentDocument> contentDocs = [
                    SELECT Id, Title FROM ContentDocument WHERE Id IN :contentDocIds
                ];
                
                for (ContentDocument doc : contentDocs) {
                    if (doc.Title == fileNaming) {
                        existingDoc = doc;
                        break;
                    }
                }
            }
            
            ContentVersion fileVersion = new ContentVersion();
            fileVersion.Title = fileNaming;
            fileVersion.PathOnClient = fileName;
            fileVersion.Origin='C';
            fileVersion.VersionData = EncodingUtil.base64Decode(fileData);
            
            if (existingDoc != null) {
                // Create a new version of the existing document
                fileVersion.ContentDocumentId = existingDoc.Id;
            } else {
                // First-time upload, create a new document
                fileVersion.FirstPublishLocationId = recordId;
            }
            
            insert fileVersion;
              Set<Id> contentDocumentIds = new Set<Id>();
            Quote__c quote =[select id,ownerId from Quote__c where Id=:recordId];
        for (ContentDocumentLink cdl : [SELECT Id, ShareType,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId]) { 
            
                contentDocumentIds.add(cdl.ContentDocumentId);
            }
            // Query the ContentDocument record
            LIST<ContentDocument> fileToUpdate = [SELECT Id, OwnerId FROM ContentDocument WHERE Id IN :contentDocumentIds];
            for (ContentDocument cd :fileToUpdate){
                // Assign the new owner ID
                cd.OwnerId = quote.ownerId;
            }
            try{
                // Update the ContentDocument record
                update fileToUpdate;
                
            } catch (DmlException e) {
                ExceptionHandler.addLog(e,string.valueof(fileToUpdate),'CustomerBookingFormController','');  /*Add Exception to error log*/
                System.debug('Error changing file owner: ' + e.getMessage());
            }
            
          
          
            return 'File Uploaded Successfully: ' + (existingDoc != null ? existingDoc.Id : fileVersion.Id);  
        } catch (Exception e) {
            system.debug('Error'+ e.getMessage());
            ExceptionHandler.addLog(e,'','CustomerBookingFormController',recordId);  /*Add Exception to error log*/
            return 'Error: ' + e.getMessage();
        }
        
        
        }
            /*  
if (existingDoc == null) {
ContentVersion insertedCV = [ SELECT Id, ContentDocumentId  FROM ContentVersion  WHERE Id = :fileVersion.Id];
// If it's a new document, link it to the record
ContentDocument contentDoc = [
SELECT Id FROM ContentDocument 
WHERE Id = :insertedCV.ContentDocumentId 
LIMIT 1
];

ContentDocumentLink docLink = new ContentDocumentLink();
docLink.LinkedEntityId = recordId;
docLink.ContentDocumentId = contentDoc.Id;
//docLink.Visibility = 'AllUsers';
//docLink.ShareType = 'V'; // Viewer access

insert docLink;

}
*/            
         
    
    /* @RemoteAction
public static String uploadFile(String fileNaming,String fileName, String fileData, String recordId) {
try {
if (String.isEmpty(recordId)) {
return 'Error: No Record ID Provided!';
}

ContentVersion fileVersion = new ContentVersion();
fileVersion.Title = fileNaming;
fileVersion.PathOnClient = fileName;
fileVersion.VersionData = EncodingUtil.base64Decode(fileData);
fileVersion.FirstPublishLocationId = recordId; // Link to record

insert fileVersion;

ContentDocument contentDoc = [
SELECT Id FROM ContentDocument 
WHERE LatestPublishedVersionId = :fileVersion.Id 
LIMIT 1
];

ContentDocumentLink docLink = new ContentDocumentLink();
docLink.LinkedEntityId = recordId; // Map to actual record
docLink.ContentDocumentId = contentDoc.Id;
docLink.ShareType = 'V'; // Viewer access

insert docLink;
return 'File Uploaded Successfully: ' + contentDoc.Id;
} catch (Exception e) {
return 'Error: ' + e.getMessage();
}
}*/
    
}