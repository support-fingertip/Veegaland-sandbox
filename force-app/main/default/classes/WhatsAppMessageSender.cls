public class WhatsAppMessageSender {
    
    private static final String apiKey = 'X8WTLLRJgSWhnFwPBGH7pVGmB7gxjkGr';
    private static final String instance = '29613227';
    
    // Define a mapping between template names and their variable names
    private static Map<String, List<String>> getTemplateVariableMap() {
        return new Map<String, List<String>> {
            'payment_due_reminder' => new List<String>{'var1', 'var2','var3','var4','var5'},
                'on_original_sale_agreement_shared' => new List<String>{'var1', 'var2'},
                    'send_draft_agreement_for_review' => new List<String>{'var1', 'var2'},
                        'request_customer_details_for_sales_agreement' => new List<String>{'var1', 'var2','var3'},
                            'on_submitting_balance_amount_receipt' => new List<String>{'var1', 'var2'},
                                'reminder_collect_balance_booking_adv' => new List<String>{'var1','var2', 'var3', 'var4', 'var5','var6'},
                                    'on_adv_paid_screenshot' => new List<String>{'var1', 'var2', 'var3', 'var4'},
                                        'sending_booking_form' => new List<String>{'var1', 'var2', 'var3', 'var4', 'var5'},
                                            'collect_customer_details_4_booking_form' => new List<String>{'var1', 'var2', 'var3','var4'},
                                                'payment_reminder_english' => new List<String>{'var1', 'var2'},
                                                    'after_soft_handover' => new List<String>{'var1','var2','var3','var4'},
                                                        'after_sale_deed_registration' => new List<String>{'var1','var2','var3','var4'},
                                                            'unit_swap' => new List<String>{'var1','var2', 'var3', 'var4', 'var5','var6'},
                                                                'unit_cancellation_request' => new List<String>{'var1', 'var2','var3'}
        };
            }
    
    // Method to send WhatsApp messages
    @Future(callout=true)
    public static void sendWhatsAppMessage(
        String phone,
        String template,
        List<String> varValues,
        String fileUrl
    ) {
        String logMessage = 'Starting WhatsApp message send...';
        
        try {
            Map<String, List<String>> templateMap = getTemplateVariableMap();
            
            if (!templateMap.containsKey(template)) {
                logMessage = 'Template not found: ' + template;
                System.debug(logMessage);
                return;
            }
            
            List<String> varNames = templateMap.get(template);
            
            if (varValues.size() < varNames.size()) {
                logMessage = 'Insufficient variables provided for template: ' + template;
                System.debug(logMessage);
                return;
            }
            
            // Build the API request
            String body = 'api_key=' + EncodingUtil.urlEncode(apiKey, 'UTF-8') +
                '&instance=' + EncodingUtil.urlEncode(instance, 'UTF-8') +
                '&to=' + EncodingUtil.urlEncode(phone, 'UTF-8') +
                '&template=' + EncodingUtil.urlEncode(template, 'UTF-8');
            
            for (Integer i = 0; i < varNames.size(); i++) {
                body += '&' + varNames[i] + '=' + EncodingUtil.urlEncode(varValues[i], 'UTF-8');
            }
            
            if (!String.isBlank(fileUrl)) {
                body += '&file_path=' + EncodingUtil.urlEncode(fileUrl, 'UTF-8');
            }
           
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://chatspaz.com/api/v1/send/waba/message');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setBody(body);
            
            if(label.DisableAllWhatsappMessages != 'TRUE'){  
                Http http = new Http();
                HttpResponse res = http.send(req);
                
                if (res.getStatusCode() == 200) {
                    logMessage = 'WhatsApp message sent successfully.';
                } else {
                    logMessage = 'Failed to send WhatsApp message: ' + res.getBody();
                }
            }
        } catch (Exception e) {
            logMessage = 'Exception while sending WhatsApp message: ' + e.getMessage();
        }
        
        System.debug(logMessage);
    }
    
    
    
}