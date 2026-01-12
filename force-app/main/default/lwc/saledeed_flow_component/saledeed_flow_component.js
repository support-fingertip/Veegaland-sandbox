import { api, LightningElement, track } from 'lwc';
import getBookingDetails from '@salesforce/apex/SaleDeedFlowController.getBookingDetails';
import updatefinalSaleDeedStatus from '@salesforce/apex/SaleDeedFlowController.updatefinalSaleDeedStatus';
import updateBookingRecord from '@salesforce/apex/SaleDeedFlowController.updateBookingRecord';
import sendDraftSaleDeedEmail from '@salesforce/apex/SaleDeedFlowController.sendDraftSaleDeedEmail';
import sendFinalSaleDeedEmail from '@salesforce/apex/SaleDeedFlowController.sendFinalSaleDeedEmail';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Saledeed_flow_component extends LightningElement {
    @api recordId;
    draftSaleDeedUploaded = false;
    finalSaleDeedUploaded = false;
    draftSaledeedSend = false;
    showGenerateButton = false;
    finalSaledeedSend = false;
    bookingDetails = {};
    @track saleDeedStatus = '';
    customerApprovalStatus = '';
    customerRejectionComments = '';
    draftDeedDocumentId;
    finalDeedDocumentId;

    error;
    get isDraftSaleDeedSend() {
        return this.draftSaleDeedUploaded && !this.draftSaledeedSend;
    }
    get isFinalSaleDeedSend() {
        return this.finalSaleDeedUploaded && !this.finalSaledeedSend;
    }

    connectedCallback() {
        this.fetchBookingDetails();
    }

    get isDraftSaleDeedStage() {
        return this.saleDeedStatus === 'Draft Sale Deed upload & Send';
    }

    get isFinalSaleDeedStage() {
        return this.saleDeedStatus === 'Final Sale Deed upload & Send';
    }

    get iscustomerApprovalStage() {
        return this.saleDeedStatus === 'Customer Approval';
    }

    get isSaleDeedRejected() {
        return this.customerApprovalStatus === 'Rejected';
    }

    get isSaleDeedPending() {
        return this.customerApprovalStatus === 'Pending';
    }
    get drftSaleDeedClass() {
        if (this.saleDeedStatus === 'Draft Sale Deed upload & Send' || this.saleDeedStatus === 'Customer Approval' || this.saleDeedStatus === 'Final Sale Deed upload & Send') {
            return 'active';
        } else {
            return '';
        }
    }
    get finalSaleDeedClass() {
        if (this.saleDeedStatus === 'Final Sale Deed upload & Send') {
            return 'active';
        } else {
            return '';
        }
    }
    get approvalClass() {
        if (this.saleDeedStatus === 'Final Sale Deed upload & Send' || this.saleDeedStatus === 'Customer Approval' || this.saleDeedStatus === 'Final Sale Deed upload & Send') {
            return 'active';
        } else {
            return '';
        }
    }
    fetchBookingDetails() {
        getBookingDetails({ bookingId: this.recordId })
            .then(result => {
                // Handle the result from Apex
                this.bookingDetails = result;
                this.draftSaleDeedUploaded = this.bookingDetails.Draft_Sale_Deed_Uploaded__c;
                this.finalSaleDeedUploaded = this.bookingDetails.Final_Sale_Deed_Document_Uploaded__c;
                this.draftSaledeedSend = this.bookingDetails.Draft_Sale_Deed_Send__c;
                this.finalSaledeedSend = this.bookingDetails.Final_Sale_Deed_Send_to_Customer__c;
                this.saleDeedStatus = this.bookingDetails.Sale_Deed_Status__c;
                this.customerApprovalStatus = this.bookingDetails.Sale_deed_Approval_Status__c;
                this.customerRejectionComments = this.bookingDetails.Sale_Deed_Rejection_Comments__c;
                console.log('Booking Details:', JSON.stringify(this.bookingDetails));
            })
            .catch(error => {
                this.error = error;
                console.error('Error fetching booking details:', this.error);
            });
    }

    refreshBookingDetails() {
        this.fetchBookingDetails();
    }

    handleUploadFinished(event) {
        console.log('inside handleUploadFinished');
        console.log('event.detail: ' + event.detail);
        if (event.detail) {
            const uploaded = event.detail.uploaded;
            const documentname = event.detail.documentname;
            this.draftDeedDocumentId = event.detail.documentid;
            console.log('label: ' + documentname);
            console.log('uploaded: ' + uploaded);
            console.log('documentId: ' + this.draftDeedDocumentId);




            if (documentname === 'Draft Sale Deed') {
                this.draftSaleDeedUploaded = true;
                this.handleDraftUpdateClick();
            } else if (documentname === 'Final Sale Deed') {
                this.handleuploadFinalDeed();
            }
        }
    }

    handleDraftUpdateClick() {
        updateBookingRecord({ bookingId: this.recordId, documentId: this.draftDeedDocumentId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Booking updated successfully!',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                console.error('Error:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating Booking',
                        message: error.body?.message || 'Unexpected error occurred',
                        variant: 'error'
                    })
                );
            });
    }
    handleSendDraftMail() {
        console.log('inside sendEmailDraftSaleDeed');
        sendDraftSaleDeedEmail({ bookingId: this.recordId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Booking updated successfully!',
                        variant: 'success'
                    })
                );
                this.draftSaleDeedSend = true;
                this.saleDeedStatus = 'Customer Approval';
                this.customerApprovalStatus = 'Pending';
            })
            .catch(error => {
                console.error('Error:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating Booking',
                        message: error.body?.message || 'Unexpected error occurred',
                        variant: 'error'
                    })
                );
            });
    }
    handleSendFinalMail() {
        console.log('inside sendEmailFinalSaleDeed');
        sendFinalSaleDeedEmail({ bookingId: this.recordId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Booking updated successfully!',
                        variant: 'success'
                    })
                );
                this.finalSaleDeedSend = true;
                this.saleDeedStatus = 'Final Sale Deed upload & Send';
            })
            .catch(error => {
                console.error('Error:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating Booking',
                        message: error.body?.message || 'Unexpected error occurred',
                        variant: 'error'
                    })
                );
            });
    }
    handleFinalUploadFinished() {
        updatefinalSaleDeedStatus({ bookingId: this.recordId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Booking updated successfully!',
                        variant: 'success'
                    })
                );
                this.finalSaleDeedUploaded = true;
            })
            .catch(error => {
                console.error('Error:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating Booking',
                        message: error.body?.message || 'Unexpected error occurred',
                        variant: 'error'
                    })
                );
            });
    }

}