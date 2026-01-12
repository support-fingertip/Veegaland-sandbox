@isTest
public class PDFViewerControllerTest {
    @isTest
    public static void pdfViewer(){
        
        // creating booking
        Booking__c book = new Booking__c();
            insert book;
        
         // Step 2: Insert a PDF ContentVersion
        ContentVersion pdf = new ContentVersion(
            Title = 'Test PDF File',
            PathOnClient = 'TestPDF.pdf',
            VersionData = Blob.valueOf('Fake PDF content'),
            IsMajorVersion = true
        );
        insert pdf;

        // Step 3: Get the ContentDocumentId from inserted ContentVersion
        pdf = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :pdf.Id];

        // Step 4: Link the PDF to the Booking record
        ContentDocumentLink link = new ContentDocumentLink(
            ContentDocumentId = pdf.ContentDocumentId,
            LinkedEntityId = book.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert link;
        
        PDFViewerController.getRelatedFilesByRecordId(book.Id);
        
        
    }

}