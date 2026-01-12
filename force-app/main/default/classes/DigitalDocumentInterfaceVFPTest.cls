@isTest
public class DigitalDocumentInterfaceVFPTest {
    @isTest
    public static void digitalDocument(){
        Booking__c book = new Booking__c();
        insert book;
        
        PageReference pageref = Page.DigitalDocumentInterfaceVFP;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', book.Id);
        DigitalDocumentInterfaceVFPController dc = new DigitalDocumentInterfaceVFPController();
        
    }

}