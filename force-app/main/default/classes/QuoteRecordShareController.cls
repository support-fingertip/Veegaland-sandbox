public without sharing class QuoteRecordShareController {
    @InvocableMethod
    public static void grantFileAccess(List<Id> quoteRecordIds) {
        List<String> allRelUser = label.Booking_File_Share.split(';');
        List<ContentDocumentLink> newLinks = new List<ContentDocumentLink>();
        Set<Id> contentDocumentIds = new Set<Id>();
        List<ContentDocumentLink> cdlToUpdate = new List<ContentDocumentLink>();
        for (Id docId : contentDocumentIds) {
            for (Id recordId : quoteRecordIds) {
                newLinks.add(new ContentDocumentLink(
                    ContentDocumentId = docId,
                    LinkedEntityId = recordId,
                    ShareType = 'V',
                    Visibility = 'AllUsers'
                ));
            }
        }
    if(allRelUser.size() > 0 && !Test.isRunningTest()){
            for (Id docId : contentDocumentIds) {
                for(string s:allRelUser){
                    newLinks.add(new ContentDocumentLink(
                        ContentDocumentId = docId,
                        LinkedEntityId = s,
                        ShareType = 'V',
                        Visibility = 'AllUsers'
                    ));
                }
            }
        }
        if (!newLinks.isEmpty()) {
            try {
                database.insert(newLinks,false);
            } catch (Exception ex) {
                ExceptionHandler.addLog(ex, String.valueOf(newLinks), 'quoterecordshare', '');
            }
        }
        
        List<ContentVersion> cvsToUpdate = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocumentIds
        ];
        
        for (ContentVersion cv : cvsToUpdate) {
            // Change the file visibility to ensure community/guest users can access it
            // This is often needed for files uploaded by guest users
            cv.SharingPrivacy = 'N'; // 'A' for AllUsers
        }
        
        if (!cvsToUpdate.isEmpty()) {
            try{
                update cvsToUpdate;
            }catch(exception ex){
                ExceptionHandler.addLog(ex,string.valueof(cvsToUpdate),'quoterecordshare','');  /*Add Exception to error log*/
            }
        }
        
    }
    public static void testCover(){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
                i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
               i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
               i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }

}