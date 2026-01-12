trigger RoundRobinTrigger on Round_Robin__c (before insert) {
      Set<String> picklistValues = new Set<String>();
    
    
    for(Round_Robin__c rr :trigger.new){
        picklistValues.add(rr.Project_Assigned_City__c);
    }
		
    if(picklistValues.size()>0){
        List<Round_Robin__c> rrlist = [select id, Project_Assigned__c,Project_Assigned_City__c from Round_Robin__c where Project_Assigned_City__c in:picklistValues ];
        
        Map<string, Round_Robin__c> mapproject = new Map<string, Round_Robin__c>();
        for(Round_Robin__c rr:rrlist){
            mapproject.put(rr.Project_Assigned_City__c ,rr);
        }
        
        for(Round_Robin__c rr: trigger.new){
            system.debug('in');
            If(mapproject.containsKey(rr.Project_Assigned_City__c)){
                system.debug('innn');
                rr.addError('Project city already Exit');
            }
        }
        
    }
}