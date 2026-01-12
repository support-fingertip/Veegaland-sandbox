import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FILE_PREFIX from "@salesforce/schema/ContentVersion.Prefix_fileupload__c";
import getRelatedFilesByRecordId from '@salesforce/apex/FileUploadController.getRelatedFilesByRecordId';
import { NavigationMixin } from 'lightning/navigation'
import { RefreshEvent } from 'lightning/refresh';
export default class FileUploadLWCComponent extends NavigationMixin(LightningElement) {
    @api recordId;
    @api picklistString = '';
    @api picklistValues;
    picklistList;
    @api hideUnwanted = false;
    @track selectedDocumentName = '';
    filesList = [];
    @track refreshTrigger = 0;

    fileFieldName = FILE_PREFIX.fieldApiName;
    fileNamePrefix = '';
    // Acceptable file formats for upload
    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.doc', '.docx', '.xls', '.xlsx', '.csv'];
    }

    connectedCallback() {
        if (this.picklistString && typeof this.picklistString === 'string') {
            this.picklistList = this.picklistString.split(',').map(item => ({
                label: item.trim(),
                value: item.trim()
            }));
        } else {
            this.picklistList = [];
            console.warn('picklistString is not properly initialized or is empty.');
        }

        this.picklistList.unshift({
            label: "All",
            value: "",
            selected: true
        });
        this.fetchFiles();
    }

    fetchFiles() {
        if (!this.recordId) {
            console.error('Record ID is not set.');
            return;
        }
        console.log('selected docuemnt ' + this.selectedDocumentName);
        var documenString = this.hideUnwanted ? this.picklistString : '';
        getRelatedFilesByRecordId({
            recordId: this.recordId,
            fileName: this.selectedDocumentName,
            documentList: documenString
        })
            .then(result => {
                console.log(result);
                this.filesList = Object.keys(result).map(item => ({
                    "label": result[item],
                    "value": item,
                    "url": `/sfc/servlet.shepherd/document/download/${item}`
                }));
                console.log(this.filesList);
            })
            .catch(error => {
                console.error(error);
            });
    }

    previewHandler(event) {
        console.log(event.target.dataset.id)
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: event.target.dataset.id
            }
        })
    }
    get UploadLabel() {
        return 'Upload ' + this.selectedDocumentName;
    }

    handleFileChange(event) {
        console.log('File change event fired ' + event.target.value);

        this.selectedDocumentName = event.target.value;
        this.fileNamePrefix = this.selectedDocumentName;
        this.fetchFiles();
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        const fileNames = uploadedFiles.map(file => file.name).join(', ');
        let tempFiles = [];
        uploadedFiles.forEach(file => {
            const documentId = file.documentId || file.contentDocumentId; // Use documentId or contentDocumentId

            if (documentId) {
                // Push the file data to the temporary array
                tempFiles.push({
                    label: this.selectedDocumentName,
                    value: documentId,
                    url: `/sfc/servlet.shepherd/document/download/${documentId}`,
                });
            }
        });
        this.filesList = [...this.filesList, ...tempFiles];
        console.log(this.filesList);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: `${uploadedFiles.length} file(s) uploaded successfully: ${fileNames}`,
                variant: 'success',
            })
        );

    }
    renderedCallback() {
        //code
    }
    handleRefresh() {
        console.log('Refreshing files list...');
        this.fetchFiles();
        this.dispatchEvent(new RefreshEvent());
    }
}