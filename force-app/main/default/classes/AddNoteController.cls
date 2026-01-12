public class AddNoteController {

     @AuraEnabled
    public static void updateLastNote(String leadId, String newNote) {
        Lead leadRecord = [SELECT Id, Last_Note__c FROM Lead WHERE Id = :leadId LIMIT 1];
        
        Datetime dt = Datetime.now();
        //Timezone tz = Timezone.getTimeZone('Asia/Kolkata');
        //dt = dt.addSeconds(tz.getOffset(dt)/1000);
        
        String formattedDatetime = dt.format('yyyy-MM-dd hh:mm:ss a', 'Asia/Kolkata');

        
        Integer noteCount = 1;
        if (leadRecord.Last_Note__c == null) {
            leadRecord.Last_Note__c = '';
        } else if (!leadRecord.Last_Note__c.trim().equals('')) {
            List<String> notes = leadRecord.Last_Note__c.split('\n');
            noteCount = notes.size() + 1;
        }
        leadRecord.Last_Note__c += '\nNote ' + noteCount + ': (' + formattedDatetime + ') :' + newNote;
        leadRecord.Last_Note_Date_Time__c=Datetime.now();
        update leadRecord;
    }
    
    
    @AuraEnabled
    public static List<String> fetchLeadLastNotes(String leadId) {
        Lead leadRecord = [SELECT Id, Last_Note__c FROM Lead WHERE Id = :leadId LIMIT 1];
        List<String> lastNotes = new List<String>();
        
        if (leadRecord != null && leadRecord.Last_Note__c != null) {
            lastNotes = leadRecord.Last_Note__c.split('\n');
            
            // Filter out empty strings or null values
            List<String> filteredNotes = new List<String>();
            for (String note : lastNotes) {
                if (note != null && note != '') {
                    filteredNotes.add(note);
                }
            }
            
            lastNotes = filteredNotes;
        }
        
        return lastNotes;
    }
}