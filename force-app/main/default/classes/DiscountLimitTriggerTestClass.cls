@isTest
public class DiscountLimitTriggerTestClass {
    public static testmethod void testDiscountLimit()
    {
        Project__c project = new  Project__c();
        project.Name = 'Veegaland Green Heights';
        project.Project_Type__c='Apartments';
        insert project;
        
        Discount_Limit__c dis = new Discount_Limit__c();
        dis.Maximum_Discount__c = 200;
        dis.Project__c = 'Veegaland Green Heights';
        insert dis;
    }

}