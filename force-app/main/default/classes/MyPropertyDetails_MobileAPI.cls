@RestResource(urlMapping='/MyPropertiesDetailsAPI/*')
global without sharing class MyPropertyDetails_MobileAPI {
    
    @HttpPost
    global static void getMyPropertiesDetail() {
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString(); // Get the JSON body
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='MyPropertyDetails_MobileAPI';
        log.Request__c =requestBody;
        
        try{
            MyPropertiesDetailWrapper proj = (MyPropertiesDetailWrapper) JSON.deserialize(requestBody, MyPropertiesDetailWrapper.class);
            String userId = proj.userId;
            String projectId = proj.projectId;
            String unitNUmber = proj.unitNumber;
            system.debug('userId'+userId);
            system.debug('projectId'+projectId);
            system.debug('unitNUmber'+unitNUmber);
            
            if (String.isBlank(userId) || String.isBlank(projectId) ) {
                log.response__c = 'UserId or projectId Should not be blank.';
                log.Status__c ='SUCCESS';
                insert log;
                
                sendErrorResponse('Please Send correct Data');
                return;
            }
            List<Customer_Master__c> cmList = [ SELECT Id, Email__c, Password__c, First_Name__c, Last_Name__c, Phone__c,Name  FROM Customer_Master__c  WHERE Name = :userId AND isActive__c = TRUE LIMIT 1 ];
           // system.debug('cmList'+ cmList);
            if (cmList.isEmpty()) {
                log.response__c = 'Customer Not Found';
                log.Status__c ='SUCCESS';
                insert log;
                
                sendErrorResponse('User Not Found in System');
                return;
            }
            Project__c project = [ SELECT Id, Name,Area_Measure_In__c,Project_Status__c, Project__c, Display_in_Home__c,Display_in_Banner__c,projectSubImage__c,ProjectImage__c,BannerImage__c,BHK_Type__c,Plot_No__c,City__c,Pincode__c,
                                  Area_Name__c,StartingPrice__c,Locality_Name__c ,WorkProgress__c,Project_description__c,
                                  (SELECT Id, Name, AmenityImage__c FROM Amenities__r) FROM Project__c WHERE Project_Id__c = :projectId LIMIT 1  ];
            
            if (project == null) {
                log.response__c = 'Project Not Found';
                log.Status__c = 'SUCCESS';
                insert log;
                sendErrorResponse('Project Not Found');
                return;
            }
            
            String projectImageUrl = '';
            List<ContentDocumentLink> projLinks = new List<ContentDocumentLink>();
            if (project != null && project.Id != null) {
                projLinks = [  SELECT ContentDocumentId FROM ContentDocumentLink  WHERE LinkedEntityId = :project.Id ];
            } 
            Set<Id> docIds = new Set<Id>();
            for (ContentDocumentLink link : projLinks) {
                docIds.add(link.ContentDocumentId);
            }
            Map<Id, String> docIdToTitl = new Map<Id, String>();
            List<ContentVersion> versions = [ SELECT Id, Title, FileExtension, ContentDocumentId  FROM ContentVersion  WHERE IsLatest = true AND ContentDocumentId IN :docIds];
            Set<id> cdid = new Set<id>();
            
            for (ContentVersion cv : versions) {
                cdid.add(cv.id);
                docIdToTitl.put(cv.id, cv.Title);
            }
            for (ContentDistribution cd : [SELECT ContentDocumentId, DistributionPublicUrl,ContentVersion.Title,ContentVersionId,ContentDownloadUrl FROM ContentDistribution WHERE ContentVersionId IN :docIdToTitl.keySet()  ]) {
                //  String title = docIdToTitl.get(cd.ContentVersionId).toLowerCase();
                
                if (cd.ContentVersion.Title.contains('Project detail page image')) {
                    
                    String picUrl = '';
                    picUrl =  cd.ContentDownloadUrl.replace('download/?' , 'renditionDownload?rendition=ORIGINAL_Jpg&');
                    picUrl = picUrl.replace('&ids' , '&versionId');
                    
                    
                    projectImageUrl = picUrl;
                }
            }
            
            List<Booking__c> bookingList = new List<Booking__c>();
            if(!cmList.isEmpty() && project.Project__c != null){
                List<Plot__c> unit = [select id,BHK_Type__c,No_of_Indivisual_Car_Parking__c,Built_up_area__c from Plot__c where Name =: unitNUmber AND Project__c=:project.Id  limit 1 ];
                if (unit.isEmpty()) {
                    log.response__c = 'No Unit Found in System';
                    log.Status__c ='SUCCESS';
                    insert log;
                    
                    sendErrorResponse('No Unit Found in System');
                    return;
                }
                
                
                system.debug(cmList[0].id);
                bookingList = [select id,Project__c,Plot__c,No_of_Indivisual_Car_Parking__c,Total__c,Token_Advance_Completed_Date__c,Agreement_Registration_Completed_Date__c,Draft_Agreement_Completed_Date__c,
                               Parking_Selection_Completed_Date__c, Advance_Amount_Completed_Date__c, Welcome_Completed_Date__c, Demand_Collection_Completed_Date__c, Handing_over__c, Sale_Deed_Completed_Date__c from Booking__c where Customer_Master__c =: cmList[0].id AND Project__c =: project.Project__c AND Plot__c=:unit[0].Id limit 1];
                if (bookingList.isEmpty()) {
                    log.response__c = 'No Booking Found in System';
                    log.Status__c ='SUCCESS';
                    insert log;
                    
                    sendErrorResponse('No Booking Found in System');
                    return;
                }
                // Plot__c unit = [select id,BHK_Type__c,No_of_Indivisual_Car_Parking__c,Built_up_area__c from Plot__c where Id =: bookingList[0].Plot__c];
                
                List<Payment_Schedule__c> pymentslst =[SELECT id, Name, Status__c, Pending_Amount__c, Payment_Due_Date__c,AmountB__c FROM Payment_Schedule__c WHERE Booking__c =:bookingList[0].id /*AND Status__c = 'Completed'*/ ORDER BY S_No__c ASC];
                
                List<Receipt__c> lstRect = [select id,Total_Received_Amount__c,Approval_status__c,Mode_of_payment__c,Receipt_date__c from Receipt__c where Booking__c =: bookingList[0].id AND Approval_status__c='Approved by Finance Team'];
                // Demand_Raised__c dr =[select id,Previous_pendings__c,Current_Demand_amount__c from Demand_Raised__c where Booking__c =:bookingList[0].id limit 1 ];
                
                List<AggregateResult> aggregateResults = [SELECT Booking__c, SUM(Pending_Amount__c) totalPendingAmount, SUM(Interest_Amount__c) totalInterestAmount,
                                                          //                                           SUM(AmountB__c) totalPayableAmount, SUM(Interest_Up_to_Date__c) totalInterestUplodate,
                                                          SUM(Interest_Paid__c) totalInterestPaid, SUM(Payment_percent__c) paymentPercentageTill
                                                          FROM Payment_Schedule__c
                                                          WHERE Booking__c =: bookingList[0].id  Group By Booking__c];
                
                
                List<Demand_Raised__c> latestdemand = [select id,Current_Demand_amount__c,Previous_pendings__c,Due_Date__c from Demand_Raised__c WHERE Booking__c=: bookingList[0].id order by CreatedDate DESC limit 1]  ;  
                
                
                
                Set<Id> rcid = new Set<Id>();
                for (Receipt__c pr : lstRect) {
                    rcid.add(pr.Id);
                }
                
                
                Map<Id, Id> projectToDocMap = new Map<Id, Id>();
                Map<Id, String> docToDistUrl = new Map<Id, String>();
                
                Map<Id, String> docTofileName = new Map<Id, String>();
                
                if (!rcid.isEmpty()) {
                List<ContentDocumentLink> docLinks = [ SELECT ContentDocumentId, LinkedEntityId   FROM ContentDocumentLink WHERE LinkedEntityId IN :rcid];
                Set<Id> contentDocIds = new Set<Id>();
                for (ContentDocumentLink link : docLinks) {
                    contentDocIds.add(link.ContentDocumentId);
                }
                Map<Id, String> docIdToTitle = new Map<Id, String>();
                for (ContentVersion cv : [SELECT ContentDocumentId, Title,FileExtension FROM ContentVersion    WHERE ContentDocumentId IN :contentDocIds AND Title LIKE '%Receipt%' ]) {
                    docIdToTitle.put(cv.ContentDocumentId, cv.Title);
                    docTofileName.put(cv.ContentDocumentId, cv.Title + '.' + cv.FileExtension); // ✅ This will be your filename with extension
                    
                }
                
                for (ContentDistribution dist : [ SELECT ContentDocumentId, DistributionPublicUrl,ContentDownloadUrl FROM ContentDistribution WHERE ContentDocumentId IN :docIdToTitle.keySet() ]) {
                    String picUrl = '';
                    picUrl =  dist.ContentDownloadUrl.replace('download/?' , 'renditionDownload?rendition=ORIGINAL_Jpg&');
                    picUrl = picUrl.replace('&ids' , '&versionId');
                    
                    
                    docToDistUrl.put(dist.ContentDocumentId, picUrl);
                }
                for (ContentDocumentLink link : docLinks) {
                    Id docId = link.ContentDocumentId;
                    Id projId = link.LinkedEntityId;
                    if (docToDistUrl.containsKey(docId)) {
                        projectToDocMap.put(projId, docId);
                    }
                }
                
                }
                // Build the response data object
                MyPropertyResponse response = new MyPropertyResponse();
                response.success = true;
                response.message = '';
                response.data = new PropertyData();
                
                // Map project fields
                response.data.projectImage =projectImageUrl;
                response.data.beda = unit[0].BHK_Type__c;
                //  (bookingList[0].Beds__c == null) ? 'N/A' : String.valueOf(bookingList[0].Beds__c);
                response.data.parking = (bookingList[0].No_of_Indivisual_Car_Parking__c == null) ? 'N/A' : String.valueOf(bookingList[0].No_of_Indivisual_Car_Parking__c);
                response.data.area = String.ValueOf(unit[0].Built_up_area__c);
                // (bookingList[0].Area__c == null) ? 'N/A' : String.valueOf(bookingList[0].Area__c);
               response.data.startingPrice = (project.StartingPrice__c != null) ? String.valueOf(project.StartingPrice__c) : 'N/A';
                response.data.location = project.Locality_Name__c;
                
                if(project.Project_Status__c=='Complete'){
                     response.data.workProgress = 'Completed';
               
                }else{
                    
                response.data.workProgress = project.WorkProgress__c;
                }
                response.data.projectName = project.Name;
                
                response.data.areaUnit = project.Area_Measure_In__c;
                response.data.appartmentAddress = project.Plot_No__c+', '+ project.Area_Name__c+', '+ project.Locality_Name__c+', ' + project.City__c+', ' + project.Pincode__c;
                //  ( bookingList[0].Appartment_Address__c == null) ? '' : bookingList[0].Appartment_Address__c;
                response.data.totalApartmentCost =  ( bookingList[0].Total__c == null) ? '0' : String.valueOf(bookingList[0].Total__c);
                response.data.currentDueAmount =  ( pymentslst[0].AmountB__c == null) ? '0' : String.valueOf(pymentslst[0].AmountB__c);
                
                //Date paymentDueDate = pymentslst[0].Payment_Due_Date__c;

                
                response.data.interestAmount ='Value will reflect soon';// interest Amount Calculation pending
                
              if(!latestdemand.IsEmpty()){
                    response.data.dueDate = ( latestdemand[0].Due_Date__c == null) ? null : latestdemand[0].Due_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                    
                    
                }
                else{
                    Date paymentDueDate = pymentslst[0].Payment_Due_Date__c;
                    
                   
if (paymentDueDate != null) {
    DateTime dt = DateTime.newInstance(paymentDueDate, Time.newInstance(0, 0, 0, 0));
    String isoString = dt.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    response.data.dueDate = isoString;
} else {
    // Optionally set a default or leave it null
    response.data.dueDate = null;
    // OR: response.data.dueDate = 'N/A';
}
 
                }
                // 
                // response.data.previousDueAmount =( latestdemand[0].Previous_pendings__c == null) ? '0' : String.valueOf(latestdemand[0].Previous_pendings__c);
                
                response.data.previousDueAmount = MobileIntegrationService.previousPending(bookingList[0].Id);
                String dueacmount = MobileIntegrationService.previousPending(bookingList[0].Id);
                Decimal price;
                try {
                    price = Decimal.valueOf(dueacmount);
                } catch (Exception e) {
                    System.debug('Invalid decimal string: ' + dueacmount);
                    price = 0; // or any fallback
                }
                Decimal totaldue = price+ pymentslst[0].AmountB__c;
                
                //  Decimal totaldueAmt =  latestdemand[0].Current_Demand_amount__c +  latestdemand[0].Previous_pendings__c;
                response.data.totalDueAmount =String.ValueOf(totaldue);
                //  ( bookingList[0].Total_Due_Amount__c == null) ? '0' : String.valueOf(bookingList[0].Total_Due_Amount__c);
                List<Milestone> lstmilstone = new List<Milestone>();
                
                for(Payment_Schedule__c ps : pymentslst){
                    Milestone ms = new Milestone(
                        ps.Name,ps.Payment_Due_Date__c,ps.status__c
                    );
                    lstmilstone.add(ms);
                }
                response.data.milestons = lstmilstone;
                
                // Sample milestones data (replace with actual query if needed)
                
                
                String handoverDate = (bookingList[0].Handing_over__c != null) ? bookingList[0].Handing_over__c.format('dd-MM-yyyy') : '';
                
                
                // Sample bookingStatus data (replace with actual query if needed)
                response.data.bookingStatus = new List<BookingStatus>{
                    new BookingStatus('Token Amount Collection', (bookingList[0].Token_Advance_Completed_Date__c != null) ? bookingList[0].Token_Advance_Completed_Date__c.format() : ''),
                        new BookingStatus('Welcome Email',(bookingList[0].Welcome_Completed_Date__c != null) ? bookingList[0].Welcome_Completed_Date__c.format() : ''),
                        new BookingStatus('Car Parking Selection',(bookingList[0].Parking_Selection_Completed_Date__c != null) ? bookingList[0].Parking_Selection_Completed_Date__c.format() : ''),
                        new BookingStatus('Advance Amount Collection',(bookingList[0].Advance_Amount_Completed_Date__c != null) ? bookingList[0].Advance_Amount_Completed_Date__c.format() : ''),
                        new BookingStatus('Draft Agreement Preparation',(bookingList[0].Draft_Agreement_Completed_Date__c != null) ? bookingList[0].Draft_Agreement_Completed_Date__c.format() : '' ),
                        new BookingStatus('Sale Agreement Registration',(bookingList[0].Agreement_Registration_Completed_Date__c != null) ? bookingList[0].Agreement_Registration_Completed_Date__c.format() : '' ),
                        new BookingStatus('Demands & Collection',(bookingList[0].Demand_Collection_Completed_Date__c != null) ? bookingList[0].Demand_Collection_Completed_Date__c.format() : '' ),
                        new BookingStatus('Sale Deed Registration',(bookingList[0].Sale_Deed_Completed_Date__c != null) ? bookingList[0].Sale_Deed_Completed_Date__c.format() : ''),
                        new BookingStatus('Handover', handoverDate)
                        };
                            
                            List<PaymentDetail> paymentdetail = new List<PaymentDetail>();
                
                for(Receipt__c ps : lstRect){
                    
                    if (projectToDocMap.containsKey(ps.Id)) {
                        Id docId = projectToDocMap.get(ps.Id);
                        PaymentDetail ms = new PaymentDetail(
                            String.ValueOf(ps.Total_Received_Amount__c),String.ValueOf(ps.Receipt_date__c),ps.Mode_of_payment__c,ps.Approval_status__c,docToDistUrl.get(docId),docTofileName.get(docId)
                        );
                        paymentdetail.add(ms);
                    }
                    else {
                        PaymentDetail ms = new PaymentDetail(
                            String.ValueOf(ps.Total_Received_Amount__c),String.ValueOf(ps.Receipt_date__c),ps.Mode_of_payment__c,ps.Approval_status__c,'',''
                        );
                        paymentdetail.add(ms);
                    }
                    
                }
                
                response.data.paymentDetails = paymentdetail;
                log.response__c =response.toString();
                log.Status__c = 'SUCCESS';
                insert log;
                sendResponse(response);
                
            }
        }
        Catch (Exception e){
            log.response__c = e.getStackTraceString();
            log.Status__c ='FAIL';
            log.Error_Message__c = e.getMessage();
            insert log;
            sendErrorResponse('Error: ' + e.getMessage());
            
        }
        
    }
    public class MyPropertiesDetailWrapper {
        public String userId;
        public String projectId;
        public String unitNumber;
        
    }
    @testVisible
    private static void sendErrorResponse(String message) {
        RestContext.response.statusCode = 400;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'status' => false,
                'message' => message
                }));
    }
    
    // Response wrappers
    public class MyPropertyResponse {
        public Boolean success;
        public String message;
        public PropertyData data;
    }
    public class PropertyData {
        public String projectImage;
        public String beda; // beds, you can rename to beds
        public String parking;
        public String area;
        public String startingPrice;
        public String location;
        public String workProgress;
        public String areaUnit;
        public String projectName;
        public String appartmentAddress;
        public String totalApartmentCost;
        public String currentDueAmount;
        
        public String interestAmount;//added on 22/09/2025 
        public String dueDate;
        public String previousDueAmount;
        public String totalDueAmount;
        public List<Milestone> milestons;
        public List<BookingStatus> bookingStatus;
        public List<PaymentDetail> paymentDetails;
    }
    public class Milestone {
        public String title;
        public Date pmdate;
        public String status;
        public Milestone(String title, Date pmdate, String status) {
            this.title = title;
            this.pmdate = pmdate;
            this.status = status;
        }
    }
    public class BookingStatus {
        public String title;
        public String bsdate;
        public BookingStatus(String title, String bsdate) {
            this.title = title;
            this.bsdate = bsdate;
        }
    }
    
    public class PaymentDetail {
        public String amount;
        public String pdate;
        public String mode;
        public String status;
        public String pdfFileUrl;
        
        public String pdfName;
        public PaymentDetail(String amount, String pdate, String mode, String status, String pdfFileUrl,String pdfName) {
            this.amount = amount;
            this.pdate = pdate;
            this.mode = mode;
            this.status = status;
            this.pdfFileUrl = pdfFileUrl;
            this.pdfName = pdfName;
        }
    }
    private static void sendResponse(MyPropertyResponse response) {
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }
    
    
}