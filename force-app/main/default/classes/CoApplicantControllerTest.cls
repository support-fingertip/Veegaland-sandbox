@isTest
public class CoApplicantControllerTest {
    @isTest
    public static void coApp() {
        
        CoApplicantController con = new CoApplicantController();
        con.addCoApplicant();
        con.addCoApplicant();
        con.cancel();
        con.submit();
        
        // Step 1: Create Project
        Project__c pjt = new Project__c(Name = 'Veegaland Elanza', Active__c = true);
        insert pjt; 
        
        // Step 2: Create Booking
        Booking__c bk = new Booking__c(
            Project1__c = pjt.Id,
            No_of_Back_to_Back_Car_Parking__c = 1,
            No_of_Indivisual_Car_Parking__c = 2,
            Selected_B2B_Parking_Slots__c = 1
        );
        insert bk;

        // Step 3: Create Co-Applicant
        Co_Applicant__c co = new Co_Applicant__c(
            Name = 'Test CoApp',
            Booking__c = bk.Id,
            
            Correspondence_Country__c = 'India'
        );
        insert co;

        List<Id> idList = new List<Id>{ co.Id };
        List<Co_Applicant__c> coList = new List<Co_Applicant__c>();

        // Step 4: Insert dummy ContentVersion (this will auto-create the ContentDocumentLink)
        ContentVersion cv = new ContentVersion(
            Title = 'TestFile.pdf',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Dummy file content'),
            FirstPublishLocationId = co.Id
        );
        insert cv;

        // Step 5: Encode dummy content for saveFile
        String fileContent = EncodingUtil.base64Encode(Blob.valueOf('Dummy file content'));

        // Step 6: Build fileDataList for saveFiles
        List<Map<String, String>> fileDataList = new List<Map<String, String>>();
        Map<String, String> fileMap = new Map<String, String>{
            'coApplicantId' => co.Id,
            'fileName' => 'TestFile.pdf',
            'fileContent' => fileContent
        };
        fileDataList.add(fileMap);

        // Step 7: Call controller methods
        CoApplicantController.getCoApplicants(bk.Id);
        CoApplicantController.addCoApplicants(bk.Id, coList);
        CoApplicantController.getPicklistValues();
        CoApplicantController.getCoApplicantsWithFiles(idList);
        CoApplicantController.updateCoApplicantStatus(co.Id, bk.Id);
        CoApplicantController.saveFile('TestFile.pdf', 'file2', fileContent, co.Id);
        CoApplicantController.saveFiles(fileDataList);
    }
}