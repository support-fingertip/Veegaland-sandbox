@isTest
private class SendBrochure_MobileAPITest {
    @testSetup
    static void setup() {
        Customer_Master__c cust = new Customer_Master__c(
             Email__c = 'brochure@example.com',
            Password__c = 'pw',
            First_Name__c = 'Bro',
            Last_Name__c = 'User',
            Phone__c = '9000000000',
            isActive__c = true
        );
        insert cust;
        Project__c proj = new Project__c(Name='BrochureProj',   Project__c='Veegaland Thejus');
        insert proj;
        Attachment att = new Attachment(Name='Brochure.pdf', Body=Blob.valueOf('Test'), ContentType='application/pdf', ParentId=proj.Id);
        insert att;
        ContentVersion cv = new ContentVersion(
            Title = 'TestFile', PathOnClient = 'TestFile.pdf', VersionData = Blob.valueOf('file'), IsMajorVersion = true
        );
        insert cv;
        ContentDocument cd = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :cv.Id LIMIT 1];
        insert new ContentDocumentLink(
            ContentDocumentId = cd.Id,
            LinkedEntityId = proj.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
    }
    @isTest
    static void testSuccess() {
        Customer_Master__c cust = [SELECT Name FROM Customer_Master__c LIMIT 1];
        Project__c proj = [SELECT Project_Id__c FROM Project__c LIMIT 1];
        String body = JSON.serialize(new Map<String,Object>{
            'userid'=>cust.Name, 'projectId'=>proj.Project_Id__c,
            'name'=>'TestUser', 'email'=>'brochure@example.com','phoneNumber'=>'9000000000'
        });
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/SendBrochureAPI/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(body);
        RestContext.response = new RestResponse();
        Test.startTest();
        SendBrochure_MobileAPI.getProjectDetail();
        Test.stopTest();
        
    }
    @isTest
    static void testBlankFields() {
        String body = JSON.serialize(new Map<String,Object>{'userid'=>'','projectId'=>'','name'=>'','email'=>'','phoneNumber'=>''});
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/SendBrochureAPI/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(body);
        RestContext.response = new RestResponse();
        Test.startTest();
        SendBrochure_MobileAPI.getProjectDetail();
        Test.stopTest();
        System.assertEquals(400, RestContext.response.statusCode);
    }
    @isTest
    static void testCustomerNotFound() {
        Project__c proj = [SELECT Project_Id__c FROM Project__c LIMIT 1];
        String body = JSON.serialize(new Map<String,Object>{
            'userid'=>'NotFound','projectId'=>proj.Project_Id__c,
            'name'=>'TestUser','email'=>'brochure@example.com','phoneNumber'=>'9000000000'
        });
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/SendBrochureAPI/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(body);
        RestContext.response = new RestResponse();
        Test.startTest();
        SendBrochure_MobileAPI.getProjectDetail();
        Test.stopTest();
       
    }
    @isTest
    static void testProjectNotFound() {
        Customer_Master__c cust = [SELECT Name FROM Customer_Master__c LIMIT 1];
        String body = JSON.serialize(new Map<String,Object>{
            'userid'=>cust.Name,'projectId'=>'BADID','name'=>'TestUser','email'=>'brochure@example.com','phoneNumber'=>'9000000000'
        });
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/SendBrochureAPI/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(body);
        RestContext.response = new RestResponse();
        Test.startTest();
        SendBrochure_MobileAPI.getProjectDetail();
        Test.stopTest();
        System.assertEquals(400, RestContext.response.statusCode);
    }
    @isTest
    static void testMalformedJson() {
        String badJson = '{ "userid"=> "u1", '; // malformed
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/SendBrochureAPI/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(badJson);
        RestContext.response = new RestResponse();
        Test.startTest();
        SendBrochure_MobileAPI.getProjectDetail();
        Test.stopTest();
        System.assertEquals(400, RestContext.response.statusCode);
    }
@isTest
static void testMimeTypes() {
    List<String> exts = new List<String>{'pdf','jpg','jpeg','png','doc','docx','xls','xlsx','unknown'};
    for (String ext : exts) {
        String result = SendBrochure_MobileAPI.getMimeType(ext);
        System.debug('Extension: ' + ext + ' => MIME: ' + result);
        System.assertNotEquals(null, result, 'MIME type should not be null');
    }
}
}