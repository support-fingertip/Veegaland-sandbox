@isTest
public class CallPopupApexClassTest {
    public static testMethod void callPopup(){
        Lead ld2 = new Lead();
        ld2.LastName = 'test';
        ld2.Company = 'testCompany';
        ld2.Phone = '9876543457';    
        ld2.LeadSource = 'Website';
        
        ld2.Lead_status__c ='Working';
        ld2.Project_City__c = 'Thrissur';
        ld2.Allocated_Project__c = 'Veegaland Elanza';
        
        ld2.CallUUID__c = '45656';
        insert ld2;
        Call_Detail__c call = new Call_Detail__c();
        call.CallUUID__c = '45656';
        insert call;
        test.startTest();
        CallPopupApexClass.LeadRecordDetails();
        test.stopTest();
    }
}