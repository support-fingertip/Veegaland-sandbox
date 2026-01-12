public with sharing class ReceiptUploadRow {
    @AuraEnabled public String  bookingId;         // Booking Id
    @AuraEnabled public Decimal totalAmount;       // Total Amount
    @AuraEnabled public String  bankName;          // Bank Name
    @AuraEnabled public String  branch;            // Branch
    @AuraEnabled public String  transactionNumber; // Transaction Number
    @AuraEnabled public String  modeOfPayment;     // Mode Of Payment
    @AuraEnabled public String  paymentFrom;       // Payment From
    @AuraEnabled public String  remarks;           // Remarks
    @AuraEnabled public Date    paymentDate;       // Payment Date 
    @AuraEnabled public String  approvalStatus;    // Approval Status
    
    public ReceiptUploadRow() {}	
    
    public ReceiptUploadRow(
        String  bookingId,
        Decimal totalAmount,
        String  bankName,
        String  branch,
        String  transactionNumber,
        String  modeOfPayment,
        String  paymentFrom,
        String  remarks,
        Date    paymentDate,
        String  approvalStatus
    ) {
        this.bookingId         = bookingId;
        this.totalAmount       = totalAmount;
        this.bankName          = bankName;
        this.branch            = branch;
        this.transactionNumber = transactionNumber;
        this.modeOfPayment     = modeOfPayment;
        this.paymentFrom       = paymentFrom;
        this.remarks           = remarks;
        this.paymentDate       = paymentDate;
        this.approvalStatus    = approvalStatus;
    }
}