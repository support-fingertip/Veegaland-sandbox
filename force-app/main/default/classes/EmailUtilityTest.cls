@isTest
private class EmailUtilityTest {

    @isTest
    static void testSendTestEmail() {
        // Prepare test data
        String testToAddress = 'testuser@example.com';
        String testSubject = 'Test Subject';
        String testBody = 'This is a test email body.';

        // Call the method within Test.startTest and Test.stopTest
        Test.startTest();
        EmailUtility.sendTestEmail(testToAddress, testSubject, testBody);
        Test.stopTest();

       
    }
}