@isTest
public class getVoxbayCalldataTest 
{
    @isTest
    static void postCallData() {
        String jsonRequestData = '{"callerNumber": "7591950808", "calledNumber": "0987654321", "CallUUID": "ABC123", "AgentNumber": "7591950808" ,"totalCallDuration" :"120", "callDate": "2023-12-13T12:00:00.000Z", "conversationDuration": "110", "transferredNumber": "9876543210","dtmf":"123"}';
        RestRequest request = new RestRequest();
        request.requestURI = '/callcenterbridging/landedOnServer';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(jsonRequestData);
        
        RestResponse response = new RestResponse();
        
        RestRequest request1 = new RestRequest();
        request1.requestURI = '/callcenterbridging/callRoute';
        request1.httpMethod = 'POST';
        request1.requestBody = Blob.valueOf(jsonRequestData);
        
        
        RestRequest request2 = new RestRequest();
        request2.requestURI = '/callcenterbridging/answeredByAgent';
        request2.httpMethod = 'POST';
        request2.requestBody = Blob.valueOf(jsonRequestData);
        
        
        
        RestRequest request3 = new RestRequest();
        request3.requestURI = '/callcenterbridging/callDisconnected';
        request3.httpMethod = 'POST';
        request3.requestBody = Blob.valueOf(jsonRequestData);
        
        
        
        RestRequest request4 = new RestRequest();
        request4.requestURI = '/callcenterbridging/incomingCallCDR';
        request4.httpMethod = 'POST';
        request4.requestBody = Blob.valueOf(jsonRequestData);
        
        RestRequest request5 = new RestRequest();
        request5.requestURI = '/callcenterbridging/callIntiation';
        request5.httpMethod = 'POST';
        request5.requestBody = Blob.valueOf(jsonRequestData);
        
        RestRequest request6 = new RestRequest();
        request6.requestURI = '/callcenterbridging/outgoingCallCDR';
        request6.httpMethod = 'POST';
        request6.requestBody = Blob.valueOf(jsonRequestData);
        
        Test.startTest();
        RestContext.request = request;
        RestContext.response = response;
        getVoxbayCalldata.postCallData();
        
        RestContext.request = request1;
        RestContext.response = response;
        getVoxbayCalldata.postCallData();
        
        RestContext.request = request2;
        RestContext.response = response;
        getVoxbayCalldata.postCallData();
        
        RestContext.request = request3;
        RestContext.response = response;
        getVoxbayCalldata.postCallData();
        
        RestContext.request = request4;
        RestContext.response = response;
        getVoxbayCalldata.postCallData();
        
        RestContext.request = request5;
        RestContext.response = response;
        getVoxbayCalldata.postCallData();
        
        RestContext.request = request6;
        RestContext.response = response;
        getVoxbayCalldata.postCallData();
        
        getVoxbayCalldata.testcover();
        Test.stopTest();
        
        
    }
  
}