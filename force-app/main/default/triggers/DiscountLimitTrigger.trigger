trigger DiscountLimitTrigger on Discount_Limit__c (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        DiscountLimitHelper.MappingLookupProject(Trigger.New);
    }
}