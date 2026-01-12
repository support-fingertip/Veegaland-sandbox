@isTest
public class whatsappIntegration_Controller_Test 
{
	private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    public static void Test_whatsappIntegration_Controller()
    {
         
         // Create test parameters
        String types = 'Welcome Message For Lead Creation';
        String types1 = 'Site visit confirmation';
        String types2 = 'Site visit thank you message';
        String types3 = 'Booking confirmation';
        String types4 = 'Customer Birthday';
        String executiveName = 'test varna';
        String executivePhone = '7994726161';
        String CustomerNumber = '+917994726161';
        String ScheduledDate = '28-12-2023';
        String ScheduledTime = '2:06';
        // Create a sample param_data JSON string
        String prString = '{"param1": "value1", "param2": "value2"}';
        
    
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        whatsappIntegration_Controller.WhatsappTextMessage(types,executiveName,executivePhone,CustomerNumber,ScheduledDate,ScheduledTime);
        whatsappIntegration_Controller.WhatsappTextMessage(types1,executiveName,executivePhone,CustomerNumber,ScheduledDate,ScheduledTime);
        whatsappIntegration_Controller.WhatsappTextMessage(types2,executiveName,executivePhone,CustomerNumber,ScheduledDate,ScheduledTime);
        whatsappIntegration_Controller.WhatsappTextMessage(types3,executiveName,executivePhone,CustomerNumber,ScheduledDate,ScheduledTime);	
        whatsappIntegration_Controller.WhatsappTextMessage(types4,executiveName,executivePhone,CustomerNumber,ScheduledDate,ScheduledTime);
        Test.StopTest();
    }
}