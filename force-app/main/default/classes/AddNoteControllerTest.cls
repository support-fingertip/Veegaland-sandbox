@isTest
public class AddNoteControllerTest {
    
    @isTest
    public static void notes(){
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Last_Note__c='test';
        ld.Leadsource__c='fb';
        ld.Phone='4456786545';
        ld.Company = 'abc';
        insert ld;
        
        AddNoteController.updateLastNote(ld.Id, 'Test Note'); 
        AddNoteController.fetchLeadLastNotes(ld.Id);
        Lead updatedLead = [SELECT Id, Last_Note__c FROM Lead WHERE Id = :ld.Id LIMIT 1];
        //System.assertNotEquals(null, updatedLead.Last_Note__c);
    }
}