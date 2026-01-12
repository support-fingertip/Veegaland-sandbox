@isTest
public class RoundRobinTriggerTest {
     public static testmethod void testBooking()
   {
       Project__c pjt = new Project__c();
        pjt.Name = 'Veegaland Elanza';
        pjt.Active__c = true;
        insert pjt;
       
       Round_Robin__c RR = new Round_Robin__c();
       RR.Type__c = 'Sales';
       RR.Project__c = pjt.id;
       insert RR;
   }
}