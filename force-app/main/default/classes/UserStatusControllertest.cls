@isTest
public class UserStatusControllertest {
    public static testMethod void userstatustest(){
        test.startTest();
        UserStatusController.getUserRec();
        User u = [SELECT Id,Name,Availability__c FROM User WHERE Id=:userinfo.getuserid()];
        UserStatusController.updateUser(u,'test');
        test.stoptest();
    }
}