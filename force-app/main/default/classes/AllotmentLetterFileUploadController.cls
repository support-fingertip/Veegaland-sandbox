public without sharing class AllotmentLetterFileUploadController {
    public Blob fileBody {get; set;}  // Store the file content
    public String fileName {get; set;}  // Store the file name
    public Id bookingId{get; set;}
    public AllotmentLetterFileUploadController() {
        // Fetching recordId from page URL
        bookingId = ApexPages.currentPage().getParameters().get('id');
        fileBody = null;
        fileName = '';
    }

    // Method to handle file upload and save it to Salesforce
    public void uploadFile() {
        if (fileBody != null && !String.isBlank(fileName) && bookingId != null) {
            // Create a new ContentVersion record (which stores the uploaded file)
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = fileName;  // Set the file name
            contentVersion.PathOnClient = fileName;  // The path of the file on the client's machine
            contentVersion.VersionData = fileBody;  // The file content
			contentVersion.FirstPublishLocationId = bookingId;
            // Insert the ContentVersion record to save the file
            insert contentVersion;
			system.debug('contentVersion '+contentVersion.Id);
            // Get the ContentDocumentId from ContentVersion
        //Id contentDocumentId = contentVersion.ContentDocumentId;
            //fetch the ContentDocumentId
            ContentDocument contentDoc = [select Id from ContentDocument where Id IN (select ContentDocumentId from ContentVersion where Id = :contentVersion.Id) LIMIT 1];
            system.debug('contentDoc '+contentDoc);
            List<ContentDocumentLink> existingLinks = [select Id from ContentDocumentLink where ContentDocumentId = :contentDoc.Id AND LinkedEntityId = :bookingId];
            if(existingLinks.isEmpty()){
                //create contentDocumentLink only if it does not exist
                ContentDocumentLink contentLink = new ContentDocumentLink();
                contentLink.ContentDocumentId = contentDoc.Id;
                contentLink.LinkedEntityId = bookingId;
                contentLink.ShareType = 'V';
                contentLink.Visibility = 'AllUsers';
                insert contentLink;
            }
            
            // Optional: Display a success message after file upload
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'File uploaded successfully.'));
        } else {
            // Display an error message if file is not uploaded
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a file to upload.'));
        }
    }
}