trigger UnitTrigger on Plot__c (before insert, after insert) {
    
    if (Trigger.isAfter && Trigger.isInsert) {
   //     UnitController.copyProjectDocumentsToUnits(Trigger.new);//
    	}
}