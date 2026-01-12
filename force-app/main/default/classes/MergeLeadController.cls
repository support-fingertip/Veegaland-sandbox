public class MergeLeadController {
    @AuraEnabled
    public static List<Lead> getLeads(){
        List<Lead> ldlist = [select id, Name from Lead ];
        return ldlist;
        
    }
    
    
    @AuraEnabled
    public static List<Lead> findLead(String searchKey,List<String> selectedItem) {
        
        String name =  + searchKey + '%';
        system.debug('=='+ name);
        String leadObjectName = 'Lead';
        String[] fieldsToQuery = new String[] {'Name', 'Phone', 'Email', 'Lead_ID__c','Secondary_Phone__c','Secondary_Email__c'};
        String query = 'SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM ' + leadObjectName;
        query += ' WHERE Name LIKE \'%' + searchKey + '%\' OR Phone LIKE \'%' + searchKey + '%\' OR Secondary_Phone__c LIKE \'%' + searchKey + '%\' OR Email LIKE \'%' + searchKey + '%\' OR Secondary_Email__c LIKE \'%' + searchKey + '%\' OR Lead_ID__c LIKE \'%' + searchKey + '%\'';
        query += ' ORDER BY Name ASC';
        query += ' LIMIT 10000';
        system.debug('=='+query);
        return Database.query(query);
        
        
        
    }
    @AuraEnabled
    public static string mergeLead(List<Lead> leads, string recId ){
        List<Lead> ldl = [select id, Name,Is_Merged__c from Lead where id=:recId limit 1];
        set<Id> ids = new set<Id>();
        list<Lead> ldlst = new list<Lead>();
        list<Related_Source__c> rllist = new list<Related_Source__c>();
        for(Lead ld:leads){
            ids.add(ld.id);
            ld.Is_Merged__c=true;
            ld.Main_Lead__c=ldl[0].id;
            ldlst.add(ld);
        }
         list<Related_Source__c> rs = [select id,Lead__c from Related_Source__c where Lead__c=:ids]  ;
        for(Related_Source__c rel :rs){
            rel.Lead__c=ldl[0].id;
            rllist.add(rel);
        }
        update rllist;
        if(!ldl[0].Is_Merged__c){
            ldl[0].Is_Merged__c=true;
        }
            
        update ldl;
        
        delete ldlst;
        
        return 'Lead Merged Successfully';
       
    }
    
    
}