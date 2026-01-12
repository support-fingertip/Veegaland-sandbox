public class ReceiptDateComparator implements Comparator<Receipt__c> {
    public Integer compare(Receipt__c a, Receipt__c b) {
        if (a.receipt_date__c == b.receipt_date__c) {
            return 0;
        }
        return a.receipt_date__c < b.receipt_date__c ? -1 : 1;
    }
}