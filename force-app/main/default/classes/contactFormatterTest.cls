@isTest
public class contactFormatterTest {
     public static testmethod void SimplyfyFilestest()
     {
         test.startTest();
         contactFormatter.getformated('23456787801');
         contactFormatter.getformated(null);
        // contactFormatter.geAllPhoneNumbers('23456787801');
         test.stoptest();
     }
}