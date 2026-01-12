@isTest
public class ContentDistributionTrigger_Test {
    @isTest
    public static void ContentDis(){
        
        //creating and inserting content version
        ContentVersion cv = new ContentVersion(
        Title = 'test file',
            VersionData = Blob.valueOf('a dummy file'),
            PathOnClient = 'TestFile.pdf'
        );
        insert cv;
        
        
        
    }

}