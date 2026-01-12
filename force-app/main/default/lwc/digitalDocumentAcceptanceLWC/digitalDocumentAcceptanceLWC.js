import {api,LightningElement,track} from 'lwc';
import updateDocumentStatus from '@salesforce/apex/DigitalDocumnetAcceptanceController.updateDocumentStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class DigitalDocumentAcceptanceLWC extends LightningElement {
    @api recordid;
    @api vfpname;
    @api objectname;
    @api responsestatusfield;
    @api responseremarksfield;
    @api siteurl;
    @api acceptancestatus = '';
    @api rejectionstatus = '';
    @api captureactiontimefield = '';
    @api enablesignaturepad = false;
    @api disableApprovalComments = false;
    @api directURL;
    @track isLoading = false;
    @track showSubmitActions = false;
    @track remarks;
    @track isFormsubmitted = false;
    @track disableComments = false;

    approvalStatus = '';
    imgSrc;

    vfPageUrl;
    get showSignaturePad() {
        return this.enablesignaturepad && this.approvalStatus == 'Approved';
    }

    get googleViewerUrl() {
        if (!this.directURL) return '';
        // Google Docs viewer URL format
        return 'https://docs.google.com/gview?url=' + encodeURIComponent(this.directURL) + '&embedded=true';
    }

    connectedCallback() {
        // Check if 'directurlon' is true, and use the @api directURL if so
        // if (this.directurlon == 'true') {
        this.vfPageUrl = this.directURL; // Use the @api directURL
        //} else if (this.siteurl && this.recordid) {
        //     this.vfPageUrl = `${this.siteurl}/${this.vfpname}?id=${this.recordid}`;  // Use the default logic
        // }
    }

    handleRejectClick() {
        this.showSubmitActions = true;
        this.disableComments = false;
        this.approvalStatus = this.rejectionstatus;
    }
    handleApproveClick() {
        this.showSubmitActions = true;
        this.disableComments = this.disableApprovalComments;
        this.approvalStatus = this.acceptancestatus;
    }

async handleSubmit() {
    this.isLoading = true;
    let messageValue = '';

    try {
        if (!this.disableComments) {
            messageValue = this.template.querySelector('textarea').value;
        }

        // 🚨 Validation: remarks required if rejecting
        if (this.approvalStatus === this.rejectionstatus && (!messageValue || messageValue.trim() === '')) {
            alert('Please provide rejection reason.');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please provide rejection reason.',
                    variant: 'error'
                })
            );
            this.isLoading = false;
            return; // ✅ stop here, no submission
        }

        let base64Image = null;
        if (this.enablesignaturepad && !this.imgSrc) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'No signature found!',
                    variant: 'error'
                })
            );
            this.isLoading = false;
            return;
        }
        if (this.enablesignaturepad && this.imgSrc) {
            base64Image = this.imgSrc.split(',')[1];
        }

        // ✅ Proceed only if validation passed
        await updateDocumentStatus({
            recordId: this.recordid,
            objectName: this.objectname,
            vfPageName: this.vfpname,
            base64Data: base64Image,
            enabledSignature: this.enablesignaturepad,
            statusField: this.responsestatusfield,
            remarksField: this.responseremarksfield,
            statusValue: this.approvalStatus,
            updateTimeField: this.captureactiontimefield,
            remarksValue: messageValue
        });

        alert('Submitted successfully');
        this.isFormsubmitted = true;
        this.vfPageUrl = `${this.siteurl}/ThankyouForm`;

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Document saved & PDF attached',
                variant: 'success'
            })
        );

        this.isLoading = false;

    } catch (error) {
        console.error('Error:', error);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Failed to save document',
                variant: 'error'
            })
        );
        this.isLoading = false; // ✅ ensure spinner stops
    }
}

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }

    renderedCallback() {
        document
            .fonts
            .forEach((font) => {
                if (font.family === "Great Vibes" && font.status === "unloaded") {
                    // Ensure that the font is loaded so that signature pad could use it. If you are
                    // using a different font in your project, don't forget to update the
                    // if-condition above to account for it.
                    font.load();
                }
            });
    }

    previewignature() {
        const pad = this
            .template
            .querySelector("c-digital-signature-pad");
        if (pad) {
            const dataURL = pad.getSignature();
            if (dataURL) {
                // At this point you can consume the signature, for example by saving it to disk
                // or uploading it to a Salesforce org/record. Here we just preview it in an
                // image tag.
                this.imgSrc = dataURL;
            }
        }
    }

    clearSignature() {
        const pad = this
            .template
            .querySelector("c-digital-signature-pad");
        if (pad) {
            pad.clearSignature();
        }

        this.imgSrc = null;
    }
}