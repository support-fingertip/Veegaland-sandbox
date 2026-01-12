public without sharing class SaleDeedApprovalController {
      public String recordId { get; set; } 
    public Boolean alreadyDone { get; set; }
    public String draftSaleDeedDownloadLink { get; set; }
    
    public SaleDeedApprovalController() {
        recordId = ApexPages.currentPage().getParameters().get('id');
        system.debug('recordId '+recordId);
        getSaledeed(recordId);
    }
    @TestVisible
    private void getSaledeed(Id recordId) {
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c = 'Draft Sale Deed'; 
        log.Request__c = 'Record ID: ' + recordId; 
        
        try {
            if (recordId != null) {        
                // Fetch the Booking record
                Booking__c booking = [
                    SELECT id, Name,Draft_Sale_Deed_URL__c, First_Applicant_Name__c, Email1__c, Sale_deed_Approval_Status__c
                    FROM Booking__c
                    WHERE id = :recordId
                    LIMIT 1
                ];
                
                system.debug('booking '+booking);
                // Check if the agreement has been approved
                alreadyDone = 
                    booking.Sale_deed_Approval_Status__c == 'Approved' || 
                    booking.Sale_deed_Approval_Status__c == 'Rejected';
                
                // Set the download URL if available
                draftSaleDeedDownloadLink = booking.Draft_Sale_Deed_URL__c;
                // Log success response
                log.response__c = 'Draft Sale Deed download URL retrieved successfully.';
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
        
        //insert log;
    }
    
    // Helper method to send error response
     @TestVisible
    private void sendErrorResponse(String errorMessage) {
        System.debug('Error: ' + errorMessage);
    }
}