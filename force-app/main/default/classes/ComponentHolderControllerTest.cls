@IsTest
public class ComponentHolderControllerTest {
    
    @IsTest
    static void testRecordIdSetFromPageParam() {
        // Step 1: Create a dummy record (any sObject, e.g., Account)
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // Step 2: Create a dummy PageReference
        PageReference pageRef = new PageReference('/apex/DummyPage'); // Dummy URL
        pageRef.getParameters().put('id', acc.Id);
        Test.setCurrentPage(pageRef);
        
        // Step 3: Instantiate the controller
        ComponentHolderController controller = new ComponentHolderController();
        
        // Step 4: Assert that the recordId is set correctly
        System.assertEquals(acc.Id, controller.recordId, 'recordId should match the page parameter');
    }
}