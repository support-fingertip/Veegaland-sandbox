public without sharing class SaleAgreementApprovalController {
    public String recordId { get; set; } 
    public Boolean alreadyDone { get; set; }
    public String draftSaleAgreementDownloadLink { get; set; }  // To store the download link of the Draft Sale Agreement
    
    public SaleAgreementApprovalController() {
        recordId = ApexPages.currentPage().getParameters().get('id');
        getSaleAgreement(recordId);
    }
    
    @TestVisible
    private void getSaleAgreement(Id recordId) {
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c = 'Draft Sale agreement';  // Log the request type
        log.Request__c = 'Record ID: ' + recordId; // Log the request details
        
        try {
            if (recordId != null) {        
                // Fetch the Booking record
                Booking__c booking = [
                    SELECT Id, Name, Authorized_Signatory__c,Draft_Agreement_URL__c, First_Applicant_Name__c, Email1__c, Agreement_Approval_Status__c
                    FROM Booking__c
                    WHERE Id = :recordId
                    LIMIT 1
                ];
                
                // Check if the agreement has been approved
                alreadyDone = 
                    booking.Agreement_Approval_Status__c == 'Approved' || 
                    booking.Agreement_Approval_Status__c == 'Rejected';
                
                // Set the download URL if available
                draftSaleAgreementDownloadLink = booking.Draft_Agreement_URL__c;
                // Log success response
                log.response__c = 'Draft Sale Agreement download URL retrieved successfully.';
                log.Status__c = 'SUCCESS';
            }
        } catch (Exception e) {
            // Log error details
            log.response__c = e.getStackTraceString();
            log.Status__c = 'FAIL';
            log.Error_Message__c = e.getMessage();
            //insert log;
            sendErrorResponse('Error: ' + e.getMessage());
        }
        
        // Insert log into the Apex_Log__c object
        //insert log;
    }
    
    // Helper method to send error response
    @testvisible
    private void sendErrorResponse(String errorMessage) {
        // Implement your error response logic here (e.g., sending an email, returning a response to the user, etc.)
        System.debug('Error: ' + errorMessage);
    }
}