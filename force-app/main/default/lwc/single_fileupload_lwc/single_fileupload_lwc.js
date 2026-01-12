import { api, LightningElement } from 'lwc';
import FILE_PREFIX from "@salesforce/schema/ContentVersion.Prefix_fileupload__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Single_fileupload_lwc extends LightningElement {
    fileFieldName = FILE_PREFIX.fieldApiName;
    @api recordId;
    @api label;

    connectedCallback() {
        this.fileNamePrefix = this.label;
    }

    handlefileUploadFinished(event) {
        console.log('inside handlefileUploadFinished');
        
        const uploadedFiles = event.detail.files;
        console.log('uploadedFiles: ' + JSON.stringify(uploadedFiles));
        
        const fileNames = uploadedFiles.map(file => file.name).join(', ');
        var documentId='';
        uploadedFiles.forEach(file => {
            documentId = file.documentId;
        })

        console.log('documentId: ' + documentId);
        
        // Dispatching custom event to notify parent
        const uploadEvent = new CustomEvent('uploadfinished', {
            detail: {
                uploaded: true,
                documentname: this.label,
                documentid: documentId
            }
        });

        this.dispatchEvent(uploadEvent);

        // Display success toast
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: `${uploadedFiles.length} file(s) uploaded successfully: ${fileNames}`,
                variant: 'success',
            })
        );
    }
}