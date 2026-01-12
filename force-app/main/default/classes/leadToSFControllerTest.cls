@isTest
public class leadToSFControllerTest {
    @isTest
    public static void testmethod1(){
        utility.runLeadTrigger  = true;
        Round_Robin__c rr = new Round_Robin__c();
        rr.Project_Assigned__c='Veegaland Elanza';
        insert rr;
        Round_Robin_Member__c rrm = new Round_Robin_Member__c();
        rrm.User_Type__c='Sales';
        rrm.Round_Robin__c = rr.id;
        rrm.Active__c=true;
        rrm.User__c = userinfo.getUserId();
        rrm.Last_Assigned_Time__c = 1;
        insert rrm;
         Round_Robin_Member__c rrm2 = new Round_Robin_Member__c();
        rrm2.User_Type__c='Sales';
        rrm2.Round_Robin__c = rr.id;
        rrm2.Active__c=true;
        rrm2.User__c = userinfo.getUserId();
        rrm2.Last_Assigned_Time__c = 1;
        insert rrm2;
        Test.startTest();
        leadToSFController b = new leadToSFController();
        //b.captureLead();
        
        PageReference pageRef = Page.leadToSF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('firstName','FIT' );
        ApexPages.currentPage().getParameters().put('lastName', 'Test' );
        ApexPages.currentPage().getParameters().put('mobile', '9922334455' );
        ApexPages.currentPage().getParameters().put('email', 'test@gmail.com' );
        ApexPages.currentPage().getParameters().put('project', 'S and P The Crest' );
         ApexPages.currentPage().getParameters().put('flatPreference', '2 BHK' );
        ApexPages.currentPage().getParameters().put('source', 'Website' );
        ApexPages.currentPage().getParameters().put('subSource', '99acers' );
        ApexPages.currentPage().getParameters().put('campaign', '99acers' );
         ApexPages.currentPage().getParameters().put('description', '99acers' );
        b.captureLead();
        Test.stopTest();
    }
}