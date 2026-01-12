@isTest
public class RoundRobinUsersViewTest {
      public static testMethod void ProjectBoardtest(){
          Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        User u = new User(Alias = 'standt', Email='standarduserHouzbay@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserHouzbay@testorg.com',Availability__c =TRUE,Working__c=TRUE,IsActive=true);
        insert u;
       
       Project__c pjt = new Project__c();
        pjt.Name = 'Veegaland Elanza';
        pjt.Active__c = true;
        insert pjt;
       
       Round_Robin__c rr = new Round_Robin__c();
       rr.Type__c = 'Sales';
       rr.Project__c = pjt.id;
       rr.Project_Assigned__c='Veegaland Elanza';
       rr.Active__c=true;
       insert rr;
      
       Round_Robin_Member__c rb1=new Round_Robin_Member__c();
       //rb1.Name='18';
       rb1.User__c=u.id;
       rb1.User_Type__c='Sales';
       rb1.Round_Robin__c=rr.id;
       rb1.Active__c=true;
       insert rb1;

        test.startTest();
        RoundRobinUsersView.fetchRoundRobinMembers(rr.id);
        RoundRobinUsersView.toggleMemberStatus(rb1.id,rr.id);
         test.stoptest();
    }

}