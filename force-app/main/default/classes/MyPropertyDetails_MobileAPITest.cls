@isTest
public class MyPropertyDetails_MobileAPITest {
    
   @testSetup
    Static void setUpTestData(){
        
       
        
        
        //Creating Customer
        Customer_Master__c cus = new Customer_Master__c(
            
            First_Name__c = 'test',
            Last_Name__c = 'test Lastname',
            Email__c = 'test@gmail.com',
            Phone__c = '9786904320' ,
            isActive__c = true
            
        );
        insert cus;
        
        // Create test project
        Project__c project = new Project__c(
            Name = 'Test Project',
           
            Project__c = 'Veegaland Elanza',
            Pincode__c = 123456
        );
        insert project;
        
        
         //  ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'Project detail page image',
            PathOnClient = 'ProjectDetailPageImage.pdf',
            VersionData = Blob.valueOf('Test content')
        );
        insert cv;

        
        ContentVersion insertedCV = [
            SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id
        ];

        // Link ContentDocument to Project
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = insertedCV.ContentDocumentId,
            LinkedEntityId = project.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;

      
        List<ContentDistribution> existingDists = [
            SELECT Id FROM ContentDistribution WHERE ContentVersionId = :insertedCV.Id
        ];

        if (existingDists.isEmpty()) {
            
            ContentDistribution dist = new ContentDistribution(
                Name = 'Test Dist',
                ContentVersionId = insertedCV.Id
            );
            insert dist;
        }

        Plot__c unit = new Plot__c(
        Name = '101',
        Status__c = 'Available',
        Project__c = project.Id
    // Booking__c = book.Id
        );
        insert unit;
        
        
        // Create Booking
        Booking__c book = new Booking__c(
            Customer_Master__c = cus.Id,
            Project1__c = project.Id,
            Project__c = project.Project__c,
            Plot__c = unit.Id
           
        );
        insert book;
        
        
 
        
       
        
        
        Payment_Plan__c payplan = new Payment_Plan__c();
        payplan.Active__c = true;
        payplan.Project__c = project.id;
        insert payplan;
        
        Master_payment_schedule__c mpy = new Master_payment_schedule__c ();
        mpy.S_No__c = 1;
        mpy.Status__c = 'Completed';
        mpy.Project__c = project.id;
        mpy.Payment_Plan__c = payplan.Id;
        mpy.Payment_Percent__c = 50;
        insert mpy;
        
        
        Payment_schedule__c pys = new Payment_schedule__c();
        pys.Payment_Percent__c=10;
        pys.Payment_Due_Date__c = system.today()+3;
        pys.Booking__c = book.id;
        pys.Master_Payment_Schedule__c = mpy.Id;
        // pys.name ='on booking';
        pys.Interest_Percent__c=25;
        pys.Demand_Date__c = Date.Today();
        
        insert pys;
        
      
        Receipt__c rc = new Receipt__c(
            
            Receipt_date__c = Date.Today(),
            Instrument_N__c = 'sdfsdfsd',
            Booking__c = book.Id,
            Approval_status__c =  'Approved by Finance Team',
            Payment_From__c = 'Bank'
            
        );
        insert rc;
        
        
         //  ContentVersion
        ContentVersion cv1 = new ContentVersion(
            Title = 'Receipt',
            PathOnClient = 'Receipt.pdf',
            VersionData = Blob.valueOf('Test content')
        );
        insert cv1;

        
        ContentVersion insertedCV1 = [
            SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv1.Id
        ];

        // Link ContentDocument to Project
        ContentDocumentLink cdl1 = new ContentDocumentLink(
            ContentDocumentId = insertedCV1.ContentDocumentId,
            LinkedEntityId = rc.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl1;

      
        List<ContentDistribution> existingDists1 = [
            SELECT Id FROM ContentDistribution WHERE ContentVersionId = :insertedCV1.Id
        ];

        if (existingDists1.isEmpty()) {
            
            ContentDistribution dist1 = new ContentDistribution(
                Name = 'Test Dist',
                ContentVersionId = insertedCV1.Id
            );
        
            insert dist1;
            }
            
        
        Amenity__c amenity = new Amenity__c(
        Name = 'test',
            project__c = project.Id
        
        );
        insert amenity;
        
      Demand_Raised__c re = new Demand_Raised__c();
        
        re.Total_Amount_till_Current_Milestone__c = 50000;
        re.Total_Paid_Till__c = 20000;
        re.Previous_pendings__c = 15000;
        re.Interest_Delay_Till_Previous_Milestone__c = 0;
        re.Total_Interest_Paid__c = 1000;
        re.Current_Demand_amount__c = 100000;
        re.Intrest_Amount__c = 500;
        re.Grand_Total__c = 60000;
        re.Grand_Total_In_Words__c = 'Sixty Thousand';
        re.Current_Milestone__c = 'On Regestration';
        re.Milestone_Completed_Date__c = Date.newInstance(2022, 12, 31);
        re.Milestone_Number__c = '2';
        re.Due_Date__c = System.now().addDays(7);
        re.Current_Milestone_Percentage__c = 50;
        re.Total_Percentage_till_Current_Milestone__c = 60;
        re.TDS_Amount__c = 500;
        re.Booking__c = book.id;
        re.Total_Flat_Cost__c = 55000;
        //re.Finance_User__c = Owner.Id;
       // re.Demand_Email_Content__c = 'This is a static email content for the demand.';
       // re.Demand_Content_Ids__c = '';
        re.Demanded_Date__c = System.now();
        re.Payment_schedule__c = pys.Id;
        
        insert re;
        
        
    }
    @isTest
    public static void mypptyDetails(){
        
       Customer_Master__c customer = [SELECT Id,Name FROM Customer_Master__c LIMIT 1];
        Project__c pro = [SELECT Project_Id__c FROM Project__c LIMIT 1];
        Plot__c plot = [SELECT Name FROM Plot__c LIMIT 1];
        //Receipt__c receipt = [SELECT Id,Name FROM Receipt__c LIMIT 1];
        //Payment_Schedule__c ps = [SELECT Id,Name FROM Payment_Schedule__c LIMIT 1];
        
        // creating requested body
        
        MyPropertyDetails_MobileAPI.MyPropertiesDetailWrapper wrapper = new MyPropertyDetails_MobileAPI.MyPropertiesDetailWrapper();
        wrapper.userId = customer.Name;
        wrapper.projectId = pro.Project_Id__c;
        wrapper.unitNumber = plot.Name;
        String jsonBody = JSON.serialize(wrapper);
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/MyPropertiesDetailsAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        MyPropertyDetails_MobileAPI.getMyPropertiesDetail();
        MyPropertyDetails_MobileAPI.sendErrorResponse('test');
       
        Test.stopTest();
        
    }
    
}