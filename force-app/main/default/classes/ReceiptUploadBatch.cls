public with sharing class ReceiptUploadBatch implements Database.Batchable<Receipt__c>, Database.Stateful {
    private List<Receipt__c> source;

    public ReceiptUploadBatch(List<Receipt__c> csvList) {
        this.source = (csvList == null) ? new List<Receipt__c>() : csvList.deepClone(true);
    }

    public Iterable<Receipt__c> start(Database.BatchableContext bc) {
        return new RowIterable(source);
    }

    public void execute(Database.BatchableContext bc, List<Receipt__c> scope) {
        // Process each chunk (<= 200) with the same logic as sync
        ReceiptCSVUploadController.processChunk(scope);
    }

    public void finish(Database.BatchableContext bc) {
        // Add logging / email if needed
    }

    // ---- Iterable that yields rows; the scope size (200) is controlled by executeBatch's second param ----
    public class RowIterable implements Iterable<Receipt__c> {
        private List<Receipt__c> data;
        public RowIterable(List<Receipt__c> rows) { data = rows; }
        public Iterator<Receipt__c> iterator() { return new RowIterator(data); }
    }
    public class RowIterator implements Iterator<Receipt__c> {
        private List<Receipt__c> data; private Integer idx = 0;
        public RowIterator(List<Receipt__c> rows) { data = rows; }
        public Boolean hasNext() { return idx < data.size(); }
        public Receipt__c next() { return data[idx++]; }
    }
}