@isTest
private class SupportList_MobileAPITest {
    @testSetup
    static void setup() {
        Customer_Master__c cm = new Customer_Master__c(isActive__c = true);
        insert cm;
           Project__c project = new Project__c(
            Name = 'Test Project',
            Project__c = 'Veegaland Elanza',
            Active__c = true,
            Display_in_Home__c = true
        );
        insert project;
        
        Support_Request__c sr = new Support_Request__c(
            Customer_Master__c = cm.Id,
            Concern_Sub_Type__c = 'Electrical issue',
            Status__c = 'High',
            Support_Type__c = 'Projects',
            Priority_List__c = 'High',
            ConcernList__c = 'Electrical',
            Nature_Of_Concern__c = 'Not working',
            Description__c = 'System not responding properly.'
        );
        insert sr;
         // 2) Create Amenity
    Amenity__c amenity = new Amenity__c(Name = 'Gym');
    insert amenity;
        amenity.Project__c = project.Id;
        update amenity;
        
        // 4) Create two ContentVersions (project-detail and sub-image)
        ContentVersion cv1 = new ContentVersion(
            Title         = 'Project detail page image',
            PathOnClient  = 'proj1.jpg',
            VersionData   = Blob.valueOf('x'),
            IsMajorVersion= true
        );
        ContentVersion cv2 = new ContentVersion(
            Title         = 'Sub image',
            PathOnClient  = 'sub1.jpg',
            VersionData   = Blob.valueOf('x'),
            IsMajorVersion= true
        );
        insert new List<ContentVersion>{ cv1, cv2 };
            
            // 5) Link both to the project
            List<ContentVersion> cvs = [
                SELECT Id, ContentDocumentId FROM ContentVersion
                WHERE Id IN :new List<Id>{cv1.Id, cv2.Id}
            ];
        for (ContentVersion cv : cvs) {
            insert new ContentDocumentLink(
                LinkedEntityId    = sr.Id,
                ContentDocumentId = cv.ContentDocumentId,
                ShareType         = 'V',
                Visibility        = 'AllUsers'
            );
        }
        
        // 6) Link only the first amenity to the first doc
        insert new ContentDocumentLink(
            LinkedEntityId    = amenity.Id,
            ContentDocumentId = cvs[0].ContentDocumentId,
            ShareType         = 'V',
            Visibility        = 'AllUsers'
        );
    }
    @isTest
    static void testSuccessWithDocument() {
        Customer_Master__c cust = [SELECT Name FROM Customer_Master__c LIMIT 1];
        
        String body = JSON.serialize(new Map<String, Object>{
            'userid' => cust.Name,
                'pageSize' => 0
                });
        
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/SupportListAPI/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(body);
        RestContext.response = new RestResponse();
        
        Test.startTest();
        SupportList_MobileAPI.getMyPropertiesDetail();
        Test.stopTest();
        
        System.assertEquals(200, RestContext.response.statusCode);
    }
    
     @isTest
    static void testerrorWithDocument() {
        Customer_Master__c cust = [SELECT Name FROM Customer_Master__c LIMIT 1];
        
        String body = JSON.serialize(new Map<String, Object>{
            'userid' => '',
                'pageSize' => 0
                });
        
        RestContext.request = new RestRequest();
        RestContext.request.requestUri = '/services/apexrest/SupportListAPI/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(body);
        RestContext.response = new RestResponse();
        
        Test.startTest();
        SupportList_MobileAPI.getMyPropertiesDetail();
        Test.stopTest();
        
      
    }
    
}