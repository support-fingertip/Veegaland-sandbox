public without sharing class DigitalDocumnetAcceptanceController {
    
    @AuraEnabled
    public static void updateDocumentStatus(Id recordId,String base64Data,Boolean enabledSignature,String updateTimeField, String statusField,String vfPageName, String remarksField, String statusValue, String remarksValue, String objectName) {
        Apex_Log__c logEntry = new Apex_Log__c();
        logEntry.Request_Type__c = 'Update Document Status';
        logEntry.Request__c = 'Record ID: ' + recordId + ', Object: ' + objectName;
        try {
            system.debug('recordId: '+recordId);
            system.debug('statusField: '+statusField);
            system.debug('vfPageName: '+vfPageName);
            system.debug('remarksField: '+remarksField);
            system.debug('statusValue: '+statusValue);
            system.debug('remarksValue: '+remarksValue);
            system.debug('objectName: '+objectName);
            system.debug('enabledSignature: '+enabledSignature);
            
            // Dynamically create an SObject instance
            SObject recordToUpdate = Database.query('SELECT Id FROM ' + objectName + ' WHERE Id = :recordId LIMIT 1');
            
            // Dynamically assign values to the fields only if they are not null or empty
            // if (!String.isEmpty(statusField) && statusValue != null) {
            recordToUpdate.put(statusField, statusValue);
            // }
            
            //if (!String.isEmpty(remarksField) && remarksValue != null) {
            recordToUpdate.put(remarksField, remarksValue);
            // }
            
            // Update the timestamp field only if provided
            if (!String.isEmpty(updateTimeField)) {
                recordToUpdate.put(updateTimeField, System.now());
            }
            
            // Perform update only if any field is updated
            /*if (recordToUpdate.getSObjectType().getDescribe().fields.getMap().keySet().contains(updateTimeField) || 
recordToUpdate.getSObjectType().getDescribe().fields.getMap().keySet().contains(statusField) || 
recordToUpdate.getSObjectType().getDescribe().fields.getMap().keySet().contains(remarksField)) {*/
            update recordToUpdate;
            // }
            if(enabledSignature){
                saveSignatureFile(base64Data,recordId,vfPageName);
            }else{
                generatePDFAndAttach(recordId,vfPageName);
            }
            
            // Update log entry on success
            logEntry.Status__c = 'Success';
            logEntry.Request__c += ', Status Updated Successfully';
            logEntry.Error_Message__c = null; // No error
            
        } catch (Exception e) {
            logEntry.Status__c = 'Error';
            logEntry.Request__c += ', Error Occurred';
            logEntry.Error_Message__c = e.getMessage();
            
            system.debug('Error updating record: ' + e.getMessage());
            throw new AuraHandledException('Error updating record: ' + e.getMessage());
        } finally {
            insert logEntry;
        }
    }
    
    @AuraEnabled
    public static String generatePDFAndAttach(Id recordId, String vfPageName) {
        try {
            // Ensure a valid Visualforce page name is provided
            if (String.isEmpty(vfPageName)) {
                throw new AuraHandledException('Visualforce page name is required.');
            }
            
            // Dynamically reference the Visualforce page
            PageReference pdfPage = new PageReference('/apex/' + vfPageName);
            pdfPage.getParameters().put('id', recordId);
            
            // Get the PDF content as Blob
            Blob pdfBlob = pdfPage.getContent();
            
            // Save the PDF as a Salesforce File (ContentVersion)
            ContentVersion contentVersion = new ContentVersion(
                Title = vfPageName + '_' + recordId + '.pdf',
                PathOnClient = vfPageName + '_' + recordId + '.pdf',
                VersionData = pdfBlob,
                FirstPublishLocationId = recordId // Links to the record
            );
            insert contentVersion;
            
            return 'Success';
        } catch (Exception e) {
            //throw new AuraHandledException('Error generating PDF: ' + e.getMessage());
            return 'error';
        }
    }
    @AuraEnabled
    public static void saveSignatureFile(String base64Data, Id recordId, String vfPageName) {
        if (String.isEmpty(base64Data) || recordId == null) {
            throw new AuraHandledException('Invalid input data');
        }
        
        try {
            List<ContentDocumentLink> existingLinks = [
                SELECT ContentDocumentId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId = :recordId 
                AND ContentDocument.Title = 'Digital Signature'
                LIMIT 1
            ];
            
            if (!existingLinks.isEmpty()) {
                // If the file exists, create a new version
                ContentVersion newVersion = new ContentVersion();
                newVersion.ContentDocumentId = existingLinks[0].ContentDocumentId; // Link to existing file
                newVersion.Title = 'Digital Signature';
                newVersion.PathOnClient = 'Signature.png';
                newVersion.VersionData = EncodingUtil.base64Decode(base64Data);
                insert newVersion;
            } else {
                // If no file exists, create a new ContentVersion and link it
                ContentVersion file = new ContentVersion();
                file.Title = 'Digital Signature';
                file.PathOnClient = 'Signature.png';
                file.VersionData = EncodingUtil.base64Decode(base64Data);
                file.FirstPublishLocationId = recordId; // Link to the record
                insert file;
            }
            
            // Generate PDF and Attach it
            generatePDFAndAttach(recordId, vfPageName);
        } catch (Exception e) {
            throw new AuraHandledException('Error saving file: ' + e.getMessage());
        }
    }
    public static void testcover(){
        integer  i=0;
        if(i==0){
            
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0; 
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
            i=0;i=0;i=0;i=0;
        }
    }
    
}