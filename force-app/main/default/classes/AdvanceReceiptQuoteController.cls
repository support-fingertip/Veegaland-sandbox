public class AdvanceReceiptQuoteController {
    public Quote__c quote {get; set;}
    public String amountInWords {get; set;}
    
    public AdvanceReceiptQuoteController(ApexPages.StandardController stdcontroller){
     Id   quoteId = stdcontroller.getId();
        quote = [Select Id, Advance_Amount_Received__c From Quote__c Where Id =: quoteId];
        
        NumberTOWordConvertion N = new NumberTOWordConvertion();
        if(quote.Advance_Amount_Received__c != null){
            
            amountInWords = N.getNumberTOWordConvertion(quote.Advance_Amount_Received__c);
            
        }
    }

}