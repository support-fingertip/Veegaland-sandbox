public class ReceiptCSVUploadController {
    
    private static final String FLD_RC_NAME            = 'Receipt_Name__c';
    private static final String FLD_RC_REMARKS         = 'Remarks__c';
    private static final String FLD_RC_FIN_USER        = 'Finance_User__c';
    private static final String FLD_RC_DATE            = 'Receipt_date__c';
    private static final String FLD_RC_INST_DATE       = 'Instrument_Date__c';
    private static final String FLD_RC_PAYMENT_FROM    = 'Payment_From__c';
    private static final String FLD_RC_TXN             = 'Check_Transaction_Nmber__c'; // your org's API name
    private static final String FLD_RC_AMOUNT          = 'Amount_received__c';
    private static final String FLD_RC_MODE            = 'Mode_of_payment__c';
    private static final String FLD_RC_BANK            = 'Payment_Received_Bank__c';
    private static final String FLD_RC_BOOKING_LOOKUP  = 'Booking__c';
    private static final String FLD_RC_BRANCH          = 'Branch__c';
    private static final String FLD_RC_APPROVAL        = 'Approval_status__c';
    private static final String FLD_RC_SKIP_APPROVAL   = 'Skip_Approval__c';
    
    // Line item fields
    private static final String FLD_RLI_BOOKING        = 'Booking__c';
    private static final String FLD_RLI_BOOKING_NAME   = 'BookingName__c';
    private static final String FLD_RLI_NAME           = 'Name';
    private static final String FLD_RLI_TYPE           = 'Payment_Type__c';
    private static final String FLD_RLI_RECEIPT        = 'Receipt__c';
    private static final String FLD_RLI_PAY_SCH        = 'Payment_Schedule__c';
    private static final String FLD_RLI_RCVD_AMT       = 'Received_Amount__c';
    private static final String FLD_RLI_AMT            = 'Amount__c';
    private static final String FLD_RLI_BANK           = 'Bank_Name__c';
    private static final String FLD_RLI_FROM           = 'Payment_From__c';
    private static final String FLD_RLI_MODE           = 'Mode_of_Payment__c';
    private static final String FLD_RLI_TXN            = 'Cheque_no_Transaction_Number__c';
    private static final String FLD_RLI_APPROVAL       = 'Approval_Status1__c';
    
    // Payment schedule fields
    private static final String FLD_PS_ID              = 'Id';
    private static final String FLD_PS_BOOKING         = 'Booking__c';
    private static final String FLD_PS_SNO             = 'S_No__c';
    private static final String FLD_PS_PENDING         = 'Pending_Amount__c';
    private static final String FLD_PS_INTEREST_PEND   = 'Interest_Pending__c';
    private static final String FLD_PS_LAST_PAY_DATE   = 'Last_Payment_Date__c';
    
    // ==== PUBLIC API ====
    @AuraEnabled
    public static List<Id> insertReceiptLineItems(List<Receipt__c> csvList) {
        if (csvList == null || csvList.isEmpty()) return new List<Id>();
         system.debug(csvList);
        return processChunk(csvList);
    }
    
    @AuraEnabled
    public static Id startBatchInsertReceiptLineItems(List<Receipt__c> csvList) {
        system.debug(csvList);
        ReceiptUploadBatch  b = new ReceiptUploadBatch(csvList);
        return Database.executeBatch(b, 200);
    }
    
    // ==== CORE WORK (shared by sync + batch) ====
    public static List<Id> processChunk(List<Receipt__c> rows) {
        // 1) Collect booking identifiers (Id-like vs Name-like)
        Set<Id> bookingIds = new Set<Id>();
        Set<String> bookingNames = new Set<String>();
        for (Receipt__c r : rows) {
            if (r == null) continue;
            if (isSalesforceId(r.BookingName__c)) {
                bookingIds.add((Id)r.BookingName__c);
            } else if (!String.isBlank(r.BookingName__c)) {
                bookingNames.add(r.BookingName__c.trim());
            }
        }
        
        // 2) Query bookings by Id
        Map<Id, Booking__c> bookingById = new Map<Id, Booking__c>();
        if (!bookingIds.isEmpty()) {
            for (Booking__c b : [
                SELECT Id, Name, Finance_User__c, Project__c
                FROM Booking__c
                WHERE Id IN :bookingIds
            ]) bookingById.put(b.Id, b);
        }
        
        Map<String, Booking__c> bookingByNameLower = new Map<String, Booking__c>();
        if (!bookingNames.isEmpty()) {
            for (Booking__c b : [
                SELECT Id, Name, Finance_User__c, Project__c
                FROM Booking__c
                WHERE Name IN :bookingNames
            ]) bookingByNameLower.put(b.Name != null ? b.Name.trim().toLowerCase() : '', b);
        }
        
        // 4) Preload payment schedules for ALL found bookings (ordered by S_No__c ASC)
        Set<Id> allBookingIds = new Set<Id>();
        allBookingIds.addAll(bookingById.keySet());
        for (Booking__c bNameVal : bookingByNameLower.values()) allBookingIds.add(bNameVal.Id);
        
        Map<Id, List<Payment_Schedule__c>> psByBooking = new Map<Id, List<Payment_Schedule__c>>();
        if (!allBookingIds.isEmpty()) {
            for (Payment_Schedule__c ps : [
                SELECT Id, Booking__c, S_No__c, Pending_Amount__c, Interest_Pending__c, Last_Payment_Date__c
                FROM Payment_Schedule__c
                WHERE Booking__c IN :allBookingIds
                ORDER BY S_No__c ASC
            ]) {
                List<Payment_Schedule__c> listForBk = psByBooking.get(ps.Booking__c);
                if (listForBk == null) { listForBk = new List<Payment_Schedule__c>(); psByBooking.put(ps.Booking__c, listForBk); }
                listForBk.add(ps);
            }
        }
        
        // 5) Build Receipts (one per row)
        List<Receipt__c> receiptsToInsert = new List<Receipt__c>();
        List<Integer> rowIdxToReceiptIdx = new List<Integer>(); // row index -> index in receiptsToInsert
        List<Booking__c> rowIdxToBooking  = new List<Booking__c>(); // row index -> Booking
        for (Integer i = 0; i < rows.size(); i++) {
            Receipt__c r = rows[i];
            if (r == null) { rowIdxToReceiptIdx.add(-1); rowIdxToBooking.add(null); continue; }
            
            Booking__c bk = null;
            if (isSalesforceId(r.BookingName__c)) {
                bk = bookingById.get((Id)r.BookingName__c);
            } else if (!String.isBlank(r.BookingName__c)) {
                bk = bookingByNameLower.get(r.BookingName__c.trim().toLowerCase());
            }
            rowIdxToBooking.add(bk);
            if (bk == null) {
                rowIdxToReceiptIdx.add(-1);
                continue; // skip unknown booking
            }
            
            Receipt__c rc = new Receipt__c();
            rc.put(FLD_RC_NAME,            deriveReceiptName(r));
            rc.put(FLD_RC_REMARKS,         r.Remarks__c);
            rc.put(FLD_RC_FIN_USER,        bk.Finance_User__c);
            rc.put(FLD_RC_DATE,            r.Receipt_date__c);
            rc.put(FLD_RC_INST_DATE,       r.Instrument_Date__c);
            rc.put(FLD_RC_PAYMENT_FROM,    r.Payment_From__c);
            rc.put(FLD_RC_TXN,             r.Check_Transaction_Nmber__c);
            rc.put(FLD_RC_AMOUNT,          r.Amount_received__c);
            rc.put(FLD_RC_MODE,            r.Mode_of_payment__c);
            rc.put(FLD_RC_BANK,            r.Payment_Received_Bank__c);
            rc.put(FLD_RC_BOOKING_LOOKUP,  bk.Id);
            rc.put(FLD_RC_BRANCH,          r.Branch__c);
            rc.put(FLD_RC_APPROVAL,        r.Approval_status__c);
            rc.put(FLD_RC_SKIP_APPROVAL,   r.Skip_Approval__c);
            
            system.debug(rc);
            receiptsToInsert.add(rc);
            rowIdxToReceiptIdx.add(receiptsToInsert.size()-1);
        }
        
        // ---- Database.insert with partial success ----
        List<Id> createdReceiptIds = new List<Id>();
        Map<Integer, Id> receiptIdxToId = new Map<Integer, Id>(); // index in receiptsToInsert -> Id
        if (!receiptsToInsert.isEmpty()) {
            Database.SaveResult[] recSr = Database.insert(receiptsToInsert, /* allOrNone */ false);
            system.debug(receiptsToInsert);
            for (Integer i = 0; i < recSr.size(); i++) {
                if (recSr[i].isSuccess()) {
                    Id rid = recSr[i].getId();
                    createdReceiptIds.add(rid);
                    receiptIdxToId.put(i, rid);
                } else {
                    // Optional: log errors
                    for (Database.Error e : recSr[i].getErrors()) {
                        System.debug('Receipt insert failed: ' + e.getMessage());
                    }
                }
            }
        }
        
        // 6) Distribute amounts across Payment Schedules -> create line items
        List<Receipt_Line_Item__c> rliToInsert = new List<Receipt_Line_Item__c>();
        Set<Id> touchedPS = new Set<Id>();
        Map<Id, Date> latestPayDateByPS = new Map<Id, Date>();
        
        for (Integer i = 0; i < rows.size(); i++) {
            Integer rIdx = rowIdxToReceiptIdx[i];
            if (rIdx == -1) continue; // skipped row (no booking)
            Id rcId = receiptIdxToId.get(rIdx);
            if (rcId == null) continue; // receipt failed to insert; skip line items
            
            Booking__c bk = rowIdxToBooking[i];
            Receipt__c r = rows[i];
            
            Decimal remaining = (r.Amount_received__c == null ? 0 : r.Amount_received__c);
            if (remaining <= 0) continue;
            
            List<Payment_Schedule__c> schedules = psByBooking.get(bk.Id);
            
            if (schedules == null || schedules.isEmpty()) {
                // No schedules: put entire amount "On Account"
                Receipt_Line_Item__c rli = new Receipt_Line_Item__c();
                rli.put(FLD_RLI_BOOKING, bk.Id);
                rli.put(FLD_RLI_NAME, 'Against Payment Schedule');
                rli.put(FLD_RLI_TYPE, 'Payment Schedule');
                rli.put(FLD_RLI_RECEIPT, rcId);
                rli.put(FLD_RLI_RCVD_AMT, remaining);
                rli.put(FLD_RLI_AMT, remaining);
                rli.put(FLD_RLI_BANK, r.Payment_Received_Bank__c);
                rli.put(FLD_RLI_FROM, r.Payment_From__c);
                rli.put(FLD_RLI_MODE, r.Mode_of_payment__c);
                rli.put(FLD_RLI_TXN, r.Check_Transaction_Nmber__c);
                if(r.Approval_status__c == 'Approved by Finance Team'){
                    rli.put(FLD_RLI_APPROVAL, 'Approved');
                }
                rliToInsert.add(rli);
                continue;
            }
            
            // Allocate oldest-first to Pending_Amount__c
            for (Payment_Schedule__c ps : schedules) {
                if (remaining <= 0) break;
                
                Decimal pending = (Decimal)ps.get(FLD_PS_PENDING);
                if (pending == null || pending <= 0) continue;
                
                Decimal take = (remaining <= pending ? remaining : pending);
                remaining -= take;
                
                Receipt_Line_Item__c rli = new Receipt_Line_Item__c();
                rli.put(FLD_RLI_BOOKING, bk.Id);
                rli.put(FLD_RLI_NAME, 'Against Payment Schedule');
                rli.put(FLD_RLI_TYPE, 'Payment Schedule');
                rli.put(FLD_RLI_RECEIPT, rcId);
                rli.put(FLD_RLI_PAY_SCH, ps.Id);
                rli.put(FLD_RLI_RCVD_AMT, take);
                rli.put(FLD_RLI_AMT, take);
                rli.put(FLD_RLI_BANK, r.Payment_Received_Bank__c);
                rli.put(FLD_RLI_FROM, r.Payment_From__c);
                rli.put(FLD_RLI_MODE, r.Mode_of_payment__c);
                rli.put(FLD_RLI_TXN, r.Check_Transaction_Nmber__c);
                if(r.Approval_status__c == 'Approved by Finance Team'){
                    rli.put(FLD_RLI_APPROVAL, 'Approved');
                }
                rliToInsert.add(rli);
                
                touchedPS.add(ps.Id);
                // Use the payment date from the input row
                Date payDt = r.Receipt_date__c;
                Date curr  = latestPayDateByPS.get(ps.Id);
                if (curr == null || (payDt != null && payDt > curr)) latestPayDateByPS.put(ps.Id, payDt);
            }
            
            // Residual -> last schedule
            if (remaining != null && remaining > 0 && !schedules.isEmpty()) {
                Payment_Schedule__c last = schedules[schedules.size()-1];
                Receipt_Line_Item__c rli = new Receipt_Line_Item__c();
                rli.put(FLD_RLI_BOOKING, bk.Id);
                rli.put(FLD_RLI_NAME, 'Against Payment Schedule (Residual)');
                rli.put(FLD_RLI_TYPE, 'Payment Schedule');
                rli.put(FLD_RLI_RECEIPT, rcId);
                rli.put(FLD_RLI_PAY_SCH, last.Id);
                rli.put(FLD_RLI_RCVD_AMT, remaining);
                rli.put(FLD_RLI_AMT, remaining);
                rli.put(FLD_RLI_BANK, r.Payment_Received_Bank__c);
                rli.put(FLD_RLI_FROM, r.Payment_From__c);
                rli.put(FLD_RLI_MODE, r.Mode_of_payment__c);
                rli.put(FLD_RLI_TXN, r.Check_Transaction_Nmber__c);
                rliToInsert.add(rli);
                
                touchedPS.add(last.Id);
                Date payDt = r.Receipt_date__c;
                Date curr  = latestPayDateByPS.get(last.Id);
                if (curr == null || (payDt != null && payDt > curr)) latestPayDateByPS.put(last.Id, payDt);
            }
        }
        
        // ---- Database.insert line items (partial) ----
        if (!rliToInsert.isEmpty()) {
            Database.SaveResult[] rliSr = Database.insert(rliToInsert, false);
            // Optional: log errors
            for (Integer i = 0; i < rliSr.size(); i++) {
                if (!rliSr[i].isSuccess()) {
                    for (Database.Error e : rliSr[i].getErrors()) {
                        System.debug('RLI insert failed: ' + e.getMessage());
                    }
                }
            }
        }
        
        // 7) Update last payment date on touched payment schedules (partial)
        if (!touchedPS.isEmpty()) {
            List<Payment_Schedule__c> upd = new List<Payment_Schedule__c>();
            for (Id psId : touchedPS) {
                Payment_Schedule__c ps = new Payment_Schedule__c(Id = psId);
                ps.put(FLD_PS_LAST_PAY_DATE, latestPayDateByPS.get(psId));
                upd.add(ps);
            }
            if (!upd.isEmpty()) {
                Database.SaveResult[] upSr = Database.update(upd, false);
                for (Integer i = 0; i < upSr.size(); i++) {
                    if (!upSr[i].isSuccess()) {
                        for (Database.Error e : upSr[i].getErrors()) {
                            System.debug('PS update failed: ' + e.getMessage());
                        }
                    }
                }
            }
        }
        
        // Return only the successfully created receipt Ids
        return createdReceiptIds;
    }
    
    // ==== Helpers ====
    private static Boolean isSalesforceId(String s) {
        if (String.isBlank(s)) return false;
        String t = s.trim();
        return (t.length() == 15 || t.length() == 18);
    }
    
    private static String deriveReceiptName(Receipt__c r) {
        if (r != null) {
            if (!String.isBlank(r.Check_Transaction_Nmber__c)) return 'RCPT-' + r.Check_Transaction_Nmber__c;
            if (!String.isBlank(r.BookingName__c))             return 'RCPT-' + r.BookingName__c;
        }
        return 'RCPT';
    } 
}