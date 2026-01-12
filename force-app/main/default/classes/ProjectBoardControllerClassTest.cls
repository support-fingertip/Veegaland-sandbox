@isTest
public class ProjectBoardControllerClassTest {
    public static testMethod void ProjectBoardtest(){
        test.startTest();
        ProjectBoardControllerClass.getProjects();
        ProjectBoardControllerClass.getPlots('test');
         test.stoptest();
    }
}