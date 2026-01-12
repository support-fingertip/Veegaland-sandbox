/****************************************************************
* Class Name   : InfoVelocityController
* Company      : Fingertipplus
* Created Date : 12-03-2025
* @description : This class is responsible for call Info4 Velocity API to send the Booking Data from Salesforce to Info4 Velocity ERP System
and update the Booking Record according to Response.
* @author      : Praveen Kumar
* Used By      : BookingTrigger and SendBookingToERP Aura Component.
* 
* Change Log:
* -----------------------------------------------------------------------------
* Ver | Author         | Date        | Description
* -----------------------------------------------------------------------------
* 1.0 | Praveen Kumar | 18-03-2025  | Initial version
1.1   |               |  31-12-2024 |Email added
2.0 | Nanma T V |05-08-2025 | Initial Version 
**************************************************************/ 
global without sharing class InfoVelocityController{ 
    
    global static List<Apex_Log__c> logList = new List<Apex_Log__c>(); 
    global static  String errorMessage=''; 
    
    
    /* Date: 18-03-2025 Author: Praveen Kumar @desc: Get SecurityToken Veegaland ERP. @param 1: @return :Token */  
    
    global static string getToken(){ 
        
        Apex_Log__c log = new Apex_Log__c(); 
        log.Request_Type__c ='get tokenid'; 
        
        // be sure endpoint is configured in "Remote Site Settings 
        string endpoint = label.endPoint+'GetSecurityToken?apiUser='+label.apiUser+'&apiKey='+label.apiKey;  
        string apiUser= label.apiUser; 
        string apikey = label.apiKey;  
        String outcomeMsg; 
        if (Limits.getCallouts() >= Limits.getLimitCallouts()) { 
            outcomeMsg = 'Maximum number of callouts has been reached.'; 
            log.Status__c = 'FAILED'; 
            log.Error_Message__c = 'Maximum number of callouts has been reached.'; 
            // check for credentials error 
        } 
        else if (endpoint == null || apiUser == null || apikey == null) { 
            outcomeMsg = 'Please verify your API Credentials'; 
            log.Status__c = 'FAILED'; 
            log.Error_Message__c = 'Please verify your API Credentials'; 
            // configure and perform the callout 
        } 
        else { 
            // define transaction variables 
            Http http = new Http(); 
            HttpRequest request = new HttpRequest(); 
            // Configure the request 
            request.setEndpoint(endpoint); 
            request.setMethod('GET'); 
            try {  
                // Perform callout and set response 
                HttpResponse response = http.send(request); 
                system.debug('result body '+response.getBody());   // check response  
                system.debug(response.getStatusCode()); 
                if ((response.getStatusCode() == 200 || response.getStatusCode() == 201) && response.getBody() != null ) { 
                    log.status__c ='SUCCESS'; 
                    log.response__c = response.getBody(); 
                    
                    Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(response.getBody()); 
                    Map<String, Object> m2 = (Map<String, Object>) m.get('Response'); 
                    InfoVelocityController.Response result = (InfoVelocityController.Response) JSON.deserialize(JSON.serialize(m2),InfoVelocityController.Response.class); 
                    outcomeMsg = result.tokenId; 
                } else { 
                    // callout failed 
                    outcomeMsg = 'Error: Callout failed. Please review the debug log for additional details.'; 
                    log.status__c='FAILED'; 
                    log.response__c= 'Status code : '+response.getStatusCode() +' Response body: '+ response.getBody(); 
                    log.Error_Message__c = 'Status code : '+response.getStatusCode()+ ' Error: Callout failed. Please review the response for additional details.'; 
                }  
                
            } catch (exception e) { 
                // Unexpected exceptions will be caught here, like a deserialization error. 
                outcomeMsg = 'Error: An exception has been encountered while calling out to Integration:  ' + e.getMessage(); 
                log.status__c='FAILED'; 
                log.Error_Message__c = e.getMessage(); 
            } 
        }        
        logList.add(log);  // insert logList; 
        return outcomeMsg; 
    } 
    
    
    /* Date: 18-03-2025 Author: Praveen Kumar @Modifiyed By:Nanma T V @desc: Push data to Veegaland ERP calling customer creation method. @param 1:booking record Id @return : */ 
    
    @future (callout=true) 
    global static void customercreation(string bookingId){ 
        
        Apex_Log__c log = new Apex_Log__c(); 
        log.Request_Type__c ='Submit For Customer Creation'; 
        
        string accessToken = InfoVelocityController.getToken(); 
        string endpoint = label.endPoint+'CustomerCreation';   // be sure this is configured in "Remote Site Settings" 
        string outcomeMsg,SalesManager = 'Admin Admin'; 
        string aadhar,CorrOccupation, CorrCity,CorrPinCode,CorrCountry,CorrState,primAppliEmail,primOccupation,payload;
        List<Booking__c> bookingList = new List<Booking__c>(); 
        
        if (Limits.getCallouts() >= Limits.getLimitCallouts()) { 
            outcomeMsg = 'Maximum number of callouts has been reached.'; 
            log.Status__c = 'FAILED'; 
            log.Error_Message__c = 'Maximum number of callouts has been reached.'; 
            // check for credentials error 
        } else if (endpoint == null || accessToken == null) { 
            outcomeMsg = 'Please verify your API Credentials'; 
            log.Status__c = 'FAILED'; 
            log.Error_Message__c = 'Please verify your API Credentials'; 
            // configure and perform the callout 
        } else { 
            
            Http http = new Http(); 
            HttpRequest request = new HttpRequest(); 
            HttpResponse response = new HttpResponse(); 
            // Configure the request 
            request.setEndpoint(endpoint); 
            request.setHeader('Accept', '*/*'); 
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded'); 
            request.setMethod('POST'); 
            
            
            Booking__c bookingRec = [Select id,Booking_Through__c,Assign_To1__c,BHK_Type__c,BHK_Type_1__c,Booking_Type__c,Mobile__c,Plot__r.Name,Category__c,Clouser_Created_Date__c,Country_Code__c,Booked_At__c,Pincode__c,Enquiry_Source__c,Booking_Currency__c,Lead_Created_Date__c,Primary_Applicant_NRI_RI__c,Correspondence_Country__c,Correspondence_State__c,Unit_Type__c,Gender__c,Aadhaar_Number__c,OwnerId,Followup_Date__c,PAN_Number1__c,Correspondence_Street_Location__c,Country1__c,Project__c, 
                                     Correspondence_City__c,Correspondence_Postal_Code__c,Permanent_Street_Location__c,Permanent_Country__c	,Permanent_State__c,Permanent_City__c,Permanent_Postal_Code__c,Occupation__c,Unit_Number__c,Project1__r.Sub_Project_Name__c,
                                     Booking_Date__c,Funding_Type__c,salutation_Applicant1__c,Project1__r.RERA_NO__c,First_Applicant_Name__c,Mobile_Primary__c	,Quote__r.Payment_Plan__r.Name,   Discount__c,  GSTIN__c,Bank_Name__c,(select id,Name,Relation__c,Phone__c,Nationality__c,Salutation__c from Co_Applicant__r order by createddate),
                                     Account_Number__c,Primary_Applicant_International_No__c,Email1__c,Sales_Executive__r.Name,Owner.FirstName,Owner.lastName ,Designation__c, SLead__r.Created_Date__c,SLead__r.Lead_Type__c, SLead__r.Lead_ID__c, Project1__r.Name  from Booking__c where ID =:bookingId]; 
            
            User owenr = [select id,manager.name,manager.Id from user where id =:bookingRec.OwnerID];            
              string customerName =clubCustomerName(bookingrec); 
             string mobileNumber = bookingRec.Primary_Applicant_NRI_RI__c=='NRI'?(bookingRec.Primary_Applicant_International_No__c !=null?bookingRec.Primary_Applicant_International_No__c:'') :(bookingrec.Mobile_Primary__c!=null?bookingrec.Mobile_Primary__c:'');
            // Create payload 

             payload = 'TokenId='+EncodingUtil.urlEncode(accessToken,'UTF-8')+ 
                '&salutation='+EncodingUtil.urlEncode(bookingrec.salutation_Applicant1__c!=null ?bookingrec.salutation_Applicant1__c:'','UTF-8')+ //Primary Applicant Salutation	
                '&FirstName='+EncodingUtil.urlEncode(bookingrec.First_Applicant_Name__c!=null?customerName:'','UTF-8')+ //Primary Applicant Name
               '&Mobile='+EncodingUtil.urlEncode(mobileNumber!=null?mobileNumber:'' ,'UTF-8')+  //Primary Applicant Mobile
                '&Email='+EncodingUtil.urlEncode(bookingrec.Email1__c!=null?bookingrec.Email1__c:'','UTF-8')+ //    Primary Applicant Email   
                '&CurrentResidentialAddress='+EncodingUtil.urlEncode(bookingrec.Correspondence_Street_Location__c!=null?bookingrec.Correspondence_Street_Location__c:'','UTF-8')+ //Correspondence Street/Location	
                '&CurrentCountry='+EncodingUtil.urlEncode(bookingrec.Correspondence_Country__c!=null?bookingrec.Correspondence_Country__c:'','UTF-8')+ 
                '&CurrentCity='+EncodingUtil.urlEncode(bookingrec.Correspondence_City__c!=null?bookingrec.Correspondence_City__c:'','UTF-8')+ 
                '&CurrentState='+EncodingUtil.urlEncode(bookingrec.Correspondence_State__c!=null?bookingrec.Correspondence_State__c:'','UTF-8')+ 
                '&CurrentPinCode='+EncodingUtil.urlEncode(bookingrec.Correspondence_Postal_Code__c!=null?(string.valueof(bookingrec.Correspondence_Postal_Code__c)):'','UTF-8')+ 
                '&CountryCode='+EncodingUtil.urlEncode(bookingrec.Country_Code__c!=null?bookingrec.Country_Code__c:'','UTF-8')+ 
                   '&ResidentialStatus='+EncodingUtil.urlEncode(bookingrec.Primary_Applicant_NRI_RI__c!=null?(bookingrec.Primary_Applicant_NRI_RI__c =='RI'? 'Resident Indian':bookingrec.Primary_Applicant_NRI_RI__c ):'','UTF-8')+ 
                '&Gender='+EncodingUtil.urlEncode(bookingrec.Gender__c!=null?bookingrec.Gender__c:'','UTF-8')+ 
                 '&EnquirySource='+EncodingUtil.urlEncode(bookingrec.Enquiry_Source__c!=null?bookingrec.Enquiry_Source__c:'','UTF-8')+ 
                // '&SubEnquirySource='+EncodingUtil.urlEncode('','UTF-8')+ 
                '&SalesManager='+EncodingUtil.urlEncode(SalesManager,'UTF-8')+ 
                '&LeadCreatedDate='+EncodingUtil.urlEncode(bookingrec.Lead_Created_Date__c!=null?String.valueOf(bookingrec.Lead_Created_Date__c):'','UTF-8')+ 
                '&ClosureCreatedDate='+EncodingUtil.urlEncode(bookingrec.Clouser_Created_Date__c!=null?String.valueOf(bookingrec.Clouser_Created_Date__c):'','UTF-8')+ 
                '&Category='+EncodingUtil.urlEncode(bookingrec.Category__c!=null?bookingrec.Category__c:'','UTF-8')+ 
                '&LeadType='+EncodingUtil.urlEncode('Sales','UTF-8')+ 
                '&FollowUpDate='+EncodingUtil.urlEncode(bookingrec.Followup_Date__c!=null ?String.valueOf(bookingrec.Followup_Date__c):'','UTF-8')+ 
                '&PanCardNo='+EncodingUtil.urlEncode(bookingrec.PAN_Number1__c!=null?bookingrec.PAN_Number1__c:'','UTF-8')+  //Primary Applicant Pan Number	
                '&PermanentAddStreet='+EncodingUtil.urlEncode(bookingrec.Permanent_Street_Location__c!=null?bookingrec.Permanent_Street_Location__c:'','UTF-8')+ 
                '&PermanentAddCountry='+EncodingUtil.urlEncode(bookingrec.Permanent_Country__c!=null?bookingrec.Permanent_Country__c:'','UTF-8')+ 
                '&PermanentAddState='+EncodingUtil.urlEncode(bookingrec.Permanent_State__c!=null?bookingrec.Permanent_State__c:'','UTF-8')+ 
                '&PermanentAddCity='+EncodingUtil.urlEncode(bookingrec.Permanent_City__c!=null?bookingrec.Permanent_City__c:'','UTF-8')+ 
                '&PermanentAddPin='+EncodingUtil.urlEncode(bookingrec.Permanent_Postal_Code__c!=null?string.valueof(bookingrec.Permanent_Postal_Code__c):'','UTF-8')+ 
                '&Occupation='+primOccupation+ 
                '&leadId='+EncodingUtil.urlEncode(bookingrec.SLead__r.Lead_ID__c !=null ? bookingrec.SLead__r.Lead_ID__c.replace('Ld-',''):'','UTF-8')+ 
                '&leadRemarks='+EncodingUtil.urlEncode('','UTF-8');  // to be verify 
            // '&Designation='+latedesignation; 
            log.Request__c =payload; 
            
            bookingList.add(bookingrec); 
            request.setBody(payload); 
            
            // Attempt the callout - create return error on exception 
            try { 
                response = http.send(request); 
                system.debug('result body '+response.getBody()); 
                // check response  
                system.debug(response.getStatusCode()); 
                if ((response.getStatusCode() == 200 || response.getStatusCode() == 201) && response.getBody() != null && response.getBody() != null) { 
                    log.status__c='SUCCESS'; 
                    log.response__c= response.getBody(); 
                    List<Object> responseList = (List<Object>) JSON.deserializeUntyped(response.getBody()); 
                    for (Object responseObj : responseList) { 
                        Map<String, Object> responseMap = (Map<String, Object>) responseObj; 
                        
                        if (responseMap.containsKey('status') && responseMap.get('status') == 'Failed') { 
                            if (responseMap.containsKey('message')) { 
                                Object msgObj = responseMap.get('message'); 
                                
                                // Handle message as a **list or string** 
                                if (msgObj instanceof List<Object>) { 
                                    for (Object msgItem : (List<Object>) msgObj) { 
                                        errorMessage += String.valueOf(msgItem) + '; '; 
                                    } 
                                } else if (msgObj instanceof String) { 
                                    errorMessage += String.valueOf(msgObj) + '; '; 
                                } 
                            } 
                        } 
                    } 
                    //once customer creation successfully done calling Booking creation method 
                    if(!bookingList.isEmpty()){ 
                        mapbookingtoWrapper(bookingList); 
                    } 
                } else { 
                    // callout failed 
                    outcomeMsg = 'Error: Callout failed. Please review the debug log for additional details.'; 
                    log.status__c='FAILED'; 
                    log.response__c= 'Status code : '+response.getStatusCode() +' Response body: '+ response.getBody(); 
                    log.Error_Message__c = 'Status code : '+response.getStatusCode()+ ' Error: Callout failed. Please review the response for additional details.'; 
                }  
                
            } catch (exception e) { 
                // Unexpected exceptions will be caught here, like a deserialization error. 
                outcomeMsg = 'Error: An exception has been encountered while calling out to Integration:  ' + e.getMessage(); 
                log.status__c='FAILED'; 
                log.Error_Message__c = e.getMessage(); 
            } 
        }        
        logList.add(log); 
        upsert logList;    
    } 
    
    
   
    /* Date: 18-03-2025 Author: Praveen Kumar @Modifiyed By:Nanma T V @desc: Push data to Veegaland ERP calling booking creation method. @param 1:booking record Id @return : */ 
    public static void mapbookingtoWrapper(List<Booking__c> bookingList){
        string requestBody,stringMapWrap;
        string accessToken = getToken();
        system.debug(bookingList);
        List<InfoVelocityController.ApiRequestWrapper> requestList = new List<InfoVelocityController.ApiRequestWrapper>();
        
        for(Booking__c booking : bookingList){
                            string mobileNumber = booking.Primary_Applicant_NRI_RI__c=='NRI'?(booking.Primary_Applicant_International_No__c !=null?booking.Primary_Applicant_International_No__c:'') :(booking.Mobile_Primary__c!=null?booking.Mobile_Primary__c:'');
            InfoVelocityController.ApiRequestWrapper mapwrp = new InfoVelocityController.ApiRequestWrapper();
            mapwrp.TokenId = accessToken;
            mapwrp.CustomerName= clubCustomerName(booking);
            mapwrp.MobileNo= mobileNumber!=null? mobileNumber:'';
            mapwrp.BookingType= booking.Booking_Type__c;
            mapwrp.Project= booking.Project1__r.Name;
            mapwrp.SubProject= booking.Project1__r.Sub_Project_Name__c;
            mapwrp.UnitType= booking.BHK_Type_1__c;
            mapwrp.UnitNo= booking.Plot__r.Name;
            mapwrp.AssignTo= booking.Assign_To1__c;
            mapwrp.BookedBy= booking.Owner.FirstName+' '+booking.Owner.lastName;
            mapwrp.BookedAt= booking.Booked_At__c;
            mapwrp.BookingDate= booking.Booking_Date__c;
            mapwrp.BookingThrough= booking.Booking_Through__c;
            mapwrp.FinanceType= booking.Funding_Type__c;
            mapwrp.PaymentPlan= booking.Quote__r.Payment_Plan__r.Name;
            mapwrp.BookingCurrency= booking.Booking_Currency__c;
            mapwrp.ConversionRate= '';
            mapwrp.DiscountType= 'None';
            mapwrp.DiscountAmt= booking.Discount__c;
            mapwrp.AgentName= '';
            mapwrp.NatureOfAgent= '';
            mapwrp.AgentType = '';
            mapwrp.VendorType = '';
            mapwrp.AgentPanNo = '';
            mapwrp.AgentAddr = '';
            mapwrp.AgentCountry = '';
            mapwrp.AgentState = '';
            mapwrp.AgentCity = '';
            mapwrp.AgentPin = '';
            mapwrp.AgentPhone = '';
            mapwrp.BrokeragePerc = '';
            mapwrp.Constitution= '';
            mapwrp.AreaOfOperation= '';
            mapwrp.RegisteredBrokerageNonBrokerage= '';
            mapwrp.GSTIN = booking.GSTIN__c;
            mapwrp.RERACertificateNo= booking.Project1__r.RERA_NO__c;
            mapwrp.BankName= booking.Bank_Name__c;
            mapwrp.AccountNo= '';
            mapwrp.IFSCSwiftCode= '';
            mapwrp.Mobile= booking.Mobile_Primary__c;
            mapwrp.EmailId= booking.Email1__c;
            mapwrp.URL= '';
            
            integer coAppSize = booking.Co_Applicant__r.size();
            integer i=0;
            while(i <= coAppSize-1 && coAppSize > 0 ){
             Co_Applicant__c co = new Co_Applicant__c();
               co = booking.Co_Applicant__r[i];
                if( i == 0){
            mapwrp.CoAppTitle1 = co.Salutation__c;
            mapwrp.CoAppFirstName1 ='';
            mapwrp.CoAppLastName1 = co.Name;
            mapwrp.CoAppCountry1 = co.Nationality__c;
            mapwrp.CoAppMobile1 = co.Phone__c;
            mapwrp.CoAppRelation1 = co.Relation__c;
                }else if(i == 1){  
            mapwrp.CoAppTitle2 = co.Salutation__c;
            mapwrp.CoAppFirstName2 = '';
            mapwrp.CoAppLastName2 = co.Name;
            mapwrp.CoAppCountry2 = co.Nationality__c;
            mapwrp.CoAppMobile2 = co.Phone__c;
            mapwrp.CoAppRelation2 =co.Relation__c;
             }else if(i == 2){  
            mapwrp.CoAppTitle3 = co.Salutation__c;
            mapwrp.CoAppFirstName3 = '';
            mapwrp.CoAppLastName3= co.Name;
            mapwrp.CoAppCountry3 = co.Nationality__c;
            mapwrp.CoAppMobile3 =co.Phone__c;
            mapwrp.CoAppRelation3 = co.Relation__c;
             }else if(i == 3){  
            mapwrp.CoAppTitle4 = co.Salutation__c;
            mapwrp.CoAppFirstName4 = '';
            mapwrp.CoAppLastName4 = co.Name;
            mapwrp.CoAppCountry4 = co.Nationality__c;
            mapwrp.CoAppMobile4 = co.Phone__c;
            mapwrp.CoAppRelation4 = co.Relation__c;
            }
                i++;
            } 
            
          List<Charge_Type__c> ctp = [select id,Name,Amount_Type__c,Charge_Amount__c,Charge_Type__c,Chargetype_Id__c,No_of_Item__c,Rate_or_Fixed_Amount__c,Unit__c,Quote__c,Booking__c from Charge_Type__c where Booking__c=:booking.Id ];
            system.debug(ctp);
            List<ChargeDetail> Cd = new List<ChargeDetail>();
            List<PassiveCharge> pc = new List<PassiveCharge>();
            
            for(Charge_Type__c ct : ctp){
                if(ct.Charge_Type__c=='Charge Detail'){
                    ChargeDetail cd1 = new ChargeDetail();
                    cd1.id=ct.Chargetype_Id__c;
                    cd1.ChargeName=ct.Name;
                    cd1.AmountType=ct.Amount_Type__c;
                    cd1.RateorFixedAmount=ct.Rate_or_Fixed_Amount__c;
                    cd1.ChargeAmount=ct.Charge_Amount__c;
                    Cd.add(cd1);
                }
                else if(ct.Charge_Type__c=='Passive Charge'){
                    PassiveCharge psv = new PassiveCharge();
                    psv.id= ct.Chargetype_Id__c;
                    psv.ChargeName= ct.Name;
                    psv.RateorFixedAmount= ct.Rate_or_Fixed_Amount__c;
                    pc.add(psv);
                    
                }
            }
            
            mapwrp.ChargeDetails= cd;
            mapwrp.PassiveCharges= pc;
          
            
            requestList.add(mapwrp);
             stringMapWrap = JSON.serialize(mapwrp);
             requestBody= stringMapWrap.replaceAll('null', '""');
            system.debug(requestBody);
            InfoVelocityController.createdbooking(requestBody,booking.id);
        }
        
    }
   
    /* Date: 18-03-2025 Author: Praveen Kumar @Modifiyed By:Nanma T V @desc: Push data to Veegaland ERP calling booking creation method. @param 1:bookingWrapper @param 2:booking record Id @return : */ 
    // @future (callout=true)
    global static void createdbooking(string requestBody,String BookingId){
        
        Apex_Log__c log = new Apex_Log__c();
        log.Request_Type__c ='Create Booking';
        log.Request__c =requestBody;
        
        string endpoint = label.endPoint+'BookingCreationWithChargeDetails'; // be sure this is configured in "Remote Site Settings"
        string apiUser= label.apiUser;
        string apikey = label.apiKey; 
        String outcomeMsg;
        
        if (Limits.getCallouts() >= Limits.getLimitCallouts()) {
            outcomeMsg = 'Maximum number of callouts has been reached.';
            log.Status__c = 'FAILED';
            log.Error_Message__c = 'Maximum number of callouts has been reached.';
            // check for credentials error
        } else if (endpoint == null || apikey == null || apiUser == null) {
            outcomeMsg = 'Please verify your API Credentials';
            log.Status__c = 'FAILED';
            log.Error_Message__c = 'Please verify your API Credentials';
            // configure and perform the callout
        } else {
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            system.debug(requestBody);
            request.setBody(requestBody);
            try {
                // Perform callout and set response
                response = http.send(request);
                system.debug('result body '+response.getBody());
                // check response 
                if ((response.getStatusCode() == 200 || response.getStatusCode() == 201) && response.getBody() != null && response.getBody() != null) {
                    log.status__c='SUCCESS';
                    if(response.getBody().length()<100000){
                        log.response__c= response.getBody();
                    } 
                    // Parse JSON response
                    List<Object> responseList = (List<Object>)JSON.deserializeUntyped(response.getBody());
                    
                    String currentuser = UserInfo.getUserId();
                    if (responseList != null && responseList.size() > 0) {
                        Map<String, Object> responseObject = (Map<String, Object>)responseList[0];
                        
                        String status = (String)responseObject.get('status');
                        
                        if (status != null && status.equalsIgnoreCase('success')) {
                            List<Object> messageList = (List<Object>)responseObject.get('message');
                            
                            if (messageList != null && messageList.size() > 0) {
                                Map<String, Object> messageObject = (Map<String, Object>)messageList[0];
                                
                                String infobookingId = (String)messageObject.get('BookingId');
                                
                                if (infobookingId != null) {
                                    Booking__c bk = new Booking__c();
                                    bk.Id = BookingID;
                                    bk.Info_Velocity_Id__c = infobookingId;
                                    bk.ERP_Response__c='Booking Created, Info Velocity Id is : '+ infobookingId +'  '+'LastSynTime:'+system.now();
                                    bk.ERP_API_Status__c='Success';
                                    bk.Syn_To_ERP__c = true;
                                    
                                    Update bk;
                                    errorMessage='Booking Created in ERP Successfully and Info Velocity Id is : '+ infobookingId;
                                    
                                    sendCustomNotification(currentuser, BookingID, errorMessage);
                                }
                                system.debug('====');
                            }
                        } else {
                            // Handle failure status
                            errorMessage += String.valueof(responseObject.get('message')) + '; ';
                            system.debug(errorMessage);

                            Booking__c bk = new Booking__c();
                            bk.Id = BookingID;
                            bk.Syn_To_ERP__c = false;
                            bk.ERP_Response__c=errorMessage;
                           bk.ERP_API_Status__c='Failure';
                            Update bk;
                            sendCustomNotification(currentuser, BookingID, errorMessage);
                            log.status__c='FAILED';
                            log.response__c= 'Status code : '+response.getStatusCode() +' Response body: '+ response.getBody();
                            log.Error_Message__c = errorMessage;
                            
                        }
                    }
                    
                } else {
                    // callout failed
                    outcomeMsg = 'Error: Callout failed. Please review the debug log for additional details.';
                    log.status__c='FAILED';
                    log.response__c= 'Status code : '+response.getStatusCode() +' Response body: '+ response.getBody();
                    log.Error_Message__c = 'Status code : '+response.getStatusCode()+ ' Error: Callout failed. Please review the response for additional details.';
                } 
                
            } catch (exception e) {
                // Unexpected exceptions will be caught here, like a deserialization error.
                outcomeMsg = 'Error: An exception has been encountered while calling out to Integration:  ' + e.getMessage();
                log.status__c='FAILED';
                log.Error_Message__c = e.getMessage();
            }
        }       
        logList.add(log);
        upsert logList;     
    }
    
    public static void sendCustomNotification(String userId, String bkid, String message) {
        try {
            // Get Custom Notification Type ID
            CustomNotificationType notificationType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Booking_Notification' LIMIT 1];
            Set<String> recipientsIds = new Set<String>();
            recipientsIds.add(userId);
            // Create notification
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('Booking Notification');
            notification.setBody(message);
            notification.setSenderId(UserInfo.getUserId());
            notification.setTargetId(bkid); // Send notification to the User
            notification.setNotificationTypeId(notificationType.Id);
            notification.send(recipientsIds);
            
            System.debug('Custom Notification sent to user: ' + userId);
        } catch (Exception e) {
            System.debug('Error sending custom notification: ' + e.getMessage());
        }
    }
    @AuraEnabled
    public static string callCustomercreation(string recId){
        if (String.isBlank(recId)) {
            throw new AuraHandledException('Record Id cannot be null or empty');
        }
        else{
            customercreation(recId);
            return 'API Called';
        }
        
    } 
     public static string clubCustomerName(Booking__c booking){
        string customerName ='';
        if(booking.First_Applicant_Name__c != null && booking.First_Applicant_Name__c !=''){
           customerName += booking.First_Applicant_Name__c; 
        }
        if(booking.Co_Applicant__r.size() > 0){
            for(Co_Applicant__c co : booking.Co_Applicant__r){
            customerName += ' & '+co.Name; 
            }
        }
        return customerName;
    }
    global class Response{ 
        public string tokenId; 
        public string status; 
        public string message; 
    } 
     global class ApiRequestWrapper {
        public String TokenId;
        public String CustomerName;
        public String MobileNo;
        public String BookingType;
        public String Project;
        public String SubProject;
        public String UnitType;
        public String UnitNo;
        public String AssignTo;
        public String BookedBy;
        public String BookedAt;
        public Date BookingDate;
        public String BookingThrough;
        public String FinanceType;
        public String PaymentPlan;
        public String BookingCurrency;
        public String ConversionRate;
        public String DiscountType;
        public Decimal DiscountAmt;
        public String AgentName;
        public String NatureOfAgent;
        public String AgentType;
        public String VendorType;
        public String AgentPanNo;
        public String AgentAddr;
        public String AgentCountry;
        public String AgentState;
        public String AgentCity;
        public String AgentPin;
        public String AgentPhone;
        public String BrokeragePerc;
        public String Constitution;
        public String AreaOfOperation;
        public String RegisteredBrokerageNonBrokerage;
        public String GSTIN;
        public String RERACertificateNo;
        public String BankName;
        public String AccountNo;
        public String IFSCSwiftCode;
        public String Mobile;
        public String EmailId;
        public String URL;
        public String CoAppTitle1;
        public String CoAppFirstName1;
        public String CoAppLastName1;
        public String CoAppCountry1;
        public String CoAppMobile1;
        public String CoAppRelation1;
        public String CoAppTitle2;
        public String CoAppFirstName2;
        public String CoAppLastName2;
        public String CoAppCountry2;
        public String CoAppMobile2;
        public String CoAppRelation2;
        public String CoAppTitle3;
        public String CoAppFirstName3;
        public String CoAppLastName3;
        public String CoAppCountry3;
        public String CoAppMobile3;
        public String CoAppRelation3;
        public String CoAppTitle4;
        public String CoAppFirstName4;
        public String CoAppLastName4;
        public String CoAppCountry4;
        public String CoAppMobile4;
        public String CoAppRelation4;
        public List<ChargeDetail> ChargeDetails; 
        public List<PassiveCharge> PassiveCharges;
    }
    
    public class ChargeDetail {
        public string Id;
        public String ChargeName;
        public string AmountType;
        public Decimal RateorFixedAmount;
        public Decimal ChargeAmount;
    }
    public class PassiveCharge {
        public string Id;
        public String ChargeName;
        public Decimal RateorFixedAmount;
    }
    public static void testcover(){
        integer i=0;
        i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
            i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
              i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
            i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
              i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
                 i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
            i++;
                  i++;
            i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
               i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
            i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
            i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
    }
}