import { api, LightningElement, track } from 'lwc';
import getAgreementDetails from '@salesforce/apex/DraftAgreementController.getAgreementDetails';
import sendAgreementDetailsRequest from '@salesforce/apex/DraftAgreementController.sendAgreementdetailsrequest';
import submitForApproval from '@salesforce/apex/DraftAgreementController.submitForApproval';
import updateBookingURL from '@salesforce/apex/DraftAgreementController.updateBookingURL';
import saveFileAndSendEmail from '@salesforce/apex/DraftAgreementController.saveFileAndSendEmail';
import saveFinalFileAndSendEmail from '@salesforce/apex/DraftAgreementController.saveFinalFileAndSendEmail';
import updatefinalSaleAgreementUpload from '@salesforce/apex/DraftAgreementController.updatefinalSaleAgreementUpload';
import updateBookingVerificationStatus from '@salesforce/apex/DraftAgreementController.updateBookingVerificationStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class Draft_agreement_flow_component extends LightningElement {
    @api recordId;
    agreementDetails;
    @track agreementStatus;
    @track agreementDetailStatus;
    @track agreementDetailsVerificationStatus;
    draftAgreementCustomerApprovalStatus;
    userProfile;
    draftAgreementUploaded;
    draftAgreementMailSent;
    agreementDetailsRequestSend;
    agreementApprovalStatus;
    finalDraftAgreementUploaded;
    finalDraftAgreementMailSent;
    applicantDetails;
    showRejectionComments = false;
    draftSaleAgreementId;
    @track rejectionComments;
    error;
    finalDraftAgreementId;
    agreementDetailsemailContent;
    @track toggleAgreementDetailsMail = false;
    @track isSendDisabled = false;



    connectedCallback() {
        this.fetchBookingDetails();
    }

    showModalAgreementDetails() {
        this.toggleAgreementDetailsMail = true;
    }
    handleCancelAgreementDetails() {
        this.toggleAgreementDetailsMail = false;
    }

    get requestDetailsPending() {
        return this.agreementStatus === 'Not Started' && !(this.agreementDetailsRequestSend) && (this.userProfile === 'CRM Sales' || this.userProfile === 'System Administrator');
    }
    get requestDetailsNotSend() {
        return this.agreementStatus === 'Not Started' && !(this.userProfile === 'CRM Sales' || this.userProfile === 'System Administrator');
    }
    get agreementDetailsSend() {
        return this.agreementStatus === 'Agreement Details' && this.agreementDetailsRequestSend;
    }
    get agreementDetailRequestApproved() {
        return this.agreementDetailsVerificationStatus === 'Verified';
    }
    get agreementDetailRequestRejected() {
        return this.agreementDetailsVerificationStatus === 'Rejected' && !(this.userProfile === 'CRM Sales' || this.userProfile === 'System Administrator');
    }
    get agreementDetailsRequest() {
        return this.agreementDetailsVerificationStatus === 'Rejected' && (this.userProfile === 'CRM Sales' || this.userProfile === 'System Administrator');
    }
    get agreementDetailRequestNotVerified() {
        return this.agreementDetailsVerificationStatus === 'Pending' && !(this.userProfile === 'Legal User' || this.userProfile === 'System Administrator');
    }
    get agreementDetailRequestStatusPending() {
        return this.agreementDetailsVerificationStatus === 'Pending' && (this.userProfile === 'Legal User' || this.userProfile === 'System Administrator');
    }

    get draftSaleAgreementUploadedPending() {
        return (this.draftAgreementUploaded == false) && (this.userProfile === 'Legal User' || this.userProfile === 'System Administrator');
    }

    get draftSaleAgreementNotUploaded() {
        return !(this.draftAgreementUploaded) && !(this.userProfile === 'Legal User' || this.userProfile === 'System Administrator');
    }

    get draftSaleAgreementUploaded() {
        return this.draftAgreementUploaded;
    }
    get draftSaleAgreementMailSentPending() {
        return !(this.draftAgreementMailSent) && this.draftAgreementUploaded && (this.userProfile === 'Legal User' || this.userProfile === 'System Administrator');
    }

    get draftSaleAgreementMailNotSent() {
        return !(this.draftAgreementMailSent) && this.draftAgreementUploaded && !(this.userProfile === 'Legal User' || this.userProfile === 'System Administrator');
    }

    get draftSaleAgreementMailSent() {
        return this.draftAgreementMailSent;
    }

    get draftCustomerApprovalRejected() {
        return this.agreementApprovalStatus === 'Rejected';
    }

    get draftSaleAgreementReUploadPending() {
        return !(this.draftAgreementUploaded) && this.agreementApprovalStatus === 'Rejected' && !(this.userProfile === 'Legal User' || this.userProfile === 'System Administrator');
    }

    get draftCustomerApprovalReUpload() {
        return !(this.draftAgreementUploaded) && this.agreementApprovalStatus === 'Rejected' && (this.userProfile === 'Legal User' || this.userProfile === 'System Administrator');
    }
    get finalDraftSaleAgreementMailSent() {
        return this.finalDraftAgreementMailSent;
    }

    get finalDraftSaleAgreementUploadPending() {
        return !this.finalDraftAgreementUploaded && (this.userProfile === 'Legal User' || this.userProfile === 'System Administrator');
    }

    get finalDraftSaleAgreementNotUploaded() {
        return !this.finalDraftAgreementUploaded && !(this.userProfile === 'Legal User' || this.userProfile === 'System Administrator');
    }

    get finalDraftSaleAgreementUploaded() {
        return this.finalDraftAgreementUploaded;
    }

    get finalDraftSaleAgreementEmailPending() {
        return !this.finalDraftAgreementMailSent && this.finalDraftAgreementUploaded && (this.userProfile === 'Legal User' || this.userProfile === 'System Administrator');
    }

    get finalDraftSaleAgreementEmailNotSend() {
        return !this.finalDraftAgreementMailSent && this.finalDraftAgreementUploaded && !(this.userProfile === 'Legal User' || this.userProfile === 'System Administrator');
    }

    get finalDraftSaleAgreementEmailSend() {
        return this.finalDraftAgreementMailSent;
    }

    get showDraftAgreement() {
        return this.agreementDetailsVerificationStatus === 'Verified' && this.agreementStatus === 'Draft Agreement';
    }

    get showAgreementDetails() {
        return (this.agreementStatus === 'Not Started' || this.agreementStatus === 'Agreement Details') && this.agreementDetailsVerificationStatus != 'Verified';
    }

    get showCustomerDraftApproval() {
        return this.agreementStatus === 'Customer Approval';
    }

    get showFinalDraftAgreement() {
        return this.agreementStatus === 'Final Draft Agreement' && this.agreementApprovalStatus === 'Approved';
    }

    get finalDraftAgreementClass() {
        return this.agreementStatus === 'Final Draft Agreement' ? 'active' : '';
    }

    get customerApprovalClass() {
        return this.agreementStatus === 'Final Draft Agreement' || this.agreementStatus === 'Customer Approval' ? 'active' : '';
    }
    get drftAgreementClass() {
        return this.agreementStatus === 'Final Draft Agreement' || this.agreementStatus === 'Customer Approval' || this.agreementStatus === 'Draft Agreement' ? 'active' : '';
    }
    get agreementDetailsClass() {
        return this.agreementStatus === 'Final Draft Agreement' || this.agreementStatus === 'Customer Approval' || this.agreementStatus === 'Draft Agreement' || this.agreementStatus === 'Not Started' || this.agreementStatus === 'Agreement Details' ? 'active' : '';

    }



    fetchBookingDetails() {
        getAgreementDetails({ bookingId: this.recordId })
            .then((result) => {
                this.agreementDetails = result;
                this.agreementStatus = this.agreementDetails.Draft_Agreement_Status;
                this.userProfile = this.agreementDetails.UserProfile;
                this.agreementDetailStatus = this.agreementDetails.Received_Agreement_Details_from_Customer;
                this.agreementDetailsVerificationStatus = this.agreementDetails.Agreement_Details_Verification;
                this.draftAgreementCustomerApprovalStatus = this.agreementDetails.Agreement_Approval_Status;
                this.draftAgreementUploaded = this.agreementDetails.Draft_Agreement_Uploaded;
                this.draftAgreementMailSent = this.agreementDetails.Draft_Agreement_Email_Send;
                this.agreementDetailsRequestSend = this.agreementDetails.Agreement_Details_Request_Send;
                this.agreementApprovalStatus = this.agreementDetails.Agreement_Approval_Status;
                this.finalDraftAgreementUploaded = this.agreementDetails.FInal_Draft_Agreement_Uploaded;
                this.finalDraftAgreementMailSent = this.agreementDetails.FInal_Draft_Agreement_Email_Send;
                this.applicantDetails = this.agreementDetails.Email_content;
                this.handleSetAgreementDetails();

            })
            .catch((error) => {
                this.error = error;
                console.error('Error fetching booking details:', this.error);
            });
    }

    handleSetAgreementDetails() {
        console.log('Here handleRequestAgreementDetails 1');
        var applicants = this.applicantDetails;
        console.log('Here handleRequestAgreementDetails 2');

        var customerName = '';
        // Extract and set Primary Applicant Name
        if (applicants.length > 0) {
            customerName = applicants[0].applicantName;
        }
        console.log('Here handleRequestAgreementDetails 3');
        var defaultEmailContent = "<div style='color: black;'>Dear <strong>" + customerName + "</strong>,";

        defaultEmailContent += "<br/><br/><strong>Greetings From Veegaland Developers.</strong><br/><br/>" +
            "<table border='1' style='border-collapse:collapse;width:100%;'>" +
            "<tr><th colspan='2'>Details</th></tr>";
        console.log('Here handleRequestAgreementDetails 4');
        for (var i = 0; i < applicants.length; i++) {
            var app = applicants[i];

            defaultEmailContent += "<tr><th colspan='2' style='background-color:#f2f2f2;'>Applicant " + (i + 1) + "</th></tr>";
            defaultEmailContent += "<tr><th>Name</th><td>" + (app.applicantName || "--") + "</td></tr>";
            defaultEmailContent += "<tr><th>Email</th><td>" + (app.applicantEmail || "--") + "</td></tr>";
            defaultEmailContent += "<tr><th>Occupation</th><td>" + (app.profession || "--") + "</td></tr>";
            defaultEmailContent += "<tr><th>District</th><td> -- </td></tr>";
            defaultEmailContent += "<tr><th>Village office / Panchayath</th><td> -- </td></tr>";
            defaultEmailContent += "<tr><th>Taluk</th><td> -- </td></tr>";
            defaultEmailContent += "<tr><th>Desom / Kara</th><td> -- </td></tr>";
            defaultEmailContent += "<tr><th>Post office</th><td> -- </td></tr>";
        }
        console.log('Here handleRequestAgreementDetails 5');
        defaultEmailContent += "</table><br/><br/>" +
            "Click the secure link to provide the required information and fill in the necessary details for agreement preparation.<br/>" +
            "Link:<a href='https://site-speed-6226.my.salesforce-sites.com/AgreementDetails?id=" + this.recordId + "'>Agreement Details Link</a><br/><br/>" +
            "Your prompt response will help us proceed with agreement execution smoothly.<br/>" +
            "If you have any questions or need assistance, feel free to reach out to our team.<br/>" +
            "Please ensure all required details are provided to avoid any delays.<br/>" +
            "Thanks & Regards,<br/><br/>" +
            "<strong>Midhu Siju | Officer - Customer relations | 9207054444</strong><br/>" +
            "<strong>Alitta Lijoy | Customer relation Executive | 90482 37066</strong><br/><br/>" +
            "<strong>Veegaland Developers Limited</strong><br/>" +
            "Regd. Office: XXXV/564, 4th Floor, K C F Tower, Bharat Matha College Road, Kakkanadu, Thrikkakara, Ernakulam- 682021, Kerala<br/>" +
            "Tel: +91 484 2584000 / 2973944, +91 6235051144<br/>" +
            "<a href='https://www.veegaland.com' target='_blank'>www.veegaland.com</a><br/>" +
            "follow us on: Facebook | Instagram | LinkedIn | Youtube<br/>";

        this.agreementDetailsemailContent = defaultEmailContent;
    }
     handleRequestAgreementDetails() {
        this.isSendDisabled = true;
        sendAgreementDetailsRequest({ recId: this.recordId, emailContent: this.agreementDetailsemailContent })
            .then((result) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Agreement details request send successfully!',
                        variant: 'success'
                    })
                );
                this.toggleAgreementDetailsMail = false;
                this.agreementDetailsRequestSend = true;
                this.isSendDisabled = false;
                console.log('Here handleRequestAgreementDetails 7');
                this.agreementStatus = 'Agreement Details';
                console.log('result ' + JSON.stringify(result));

                //this.fetchBookingDetails();
            })
            .catch((error) => {
                this.error = error;
                console.error('Error sending agreement details request: ', this.error);
            });
    }

    handleRejectAgreementDetails() {
        updateBookingVerificationStatus({ bookingId: this.recordId, status: 'Rejected', rejectionComment: this.rejectionComments })
            .then((result) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Agreement details were rejected and the CRM has been informed.',
                        variant: 'success'
                    })
                );
                this.agreementDetailsVerificationStatus = 'Rejected';
                this.agreementStatus = 'Agreement Details';
                this.showRejectionComments = false;
                //this.fetchBookingDetails();
            })
            .catch((error) => {
                this.error = error;
                console.error('Error rejecting agreement details: ', this.error);
            });
    }

    handleApproveAgreementDetails() {
        console.log('Here handleRequestDetailsApproval 1');
        updateBookingVerificationStatus({ bookingId: this.recordId, status: 'Verified', rejectionComments: '' })
            .then((result) => {
                console.log('Result ' + JSON.stringify(result));

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Agreement details verified successfully!',
                        variant: 'success'
                    })
                );
                this.agreementDetailsVerificationStatus = 'Verified';
                this.agreementStatus = 'Draft Agreement';
                //this.fetchBookingDetails();
            })
            .catch((error) => {
                this.error = error;
                console.error('Error verifying agreement details: ', this.error);
            });
    }

    handleCancelRejectionPopup() {
        this.showRejectionComments = false;
    }
    handleOpenRejectionPopup() {
        this.rejectionComments = '';
        this.showRejectionComments = true;
    }

    handleRejectionComments(e) {
        const comments = e.target.value;
        this.rejectionComments = comments;
    }

    handleRequestDetailsApproval() {
        submitForApproval({ bookingId: this.recordId })
            .then((result) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Agreement approval request send successfully!',
                        variant: 'success'
                    })
                );
                this.agreementDetailsRequestSend = true;
                this.agreementStatus = 'Agreement Details';
                this.agreementDetailsVerificationStatus = 'Pending';
                console.log('result ' + JSON.stringify(result));
                //this.fetchBookingDetails();
            })
            .catch((error) => {
                this.error = error;
                console.error('Error sending agreement details request: ', this.error);
            });
    }

    handleUploadFinished(event) {
        this.draftSaleAgreementId = event.detail.documentid;
        updateBookingURL({ bookingId: this.recordId, documentId: this.draftSaleAgreementId })
            .then((result) => {
                this.draftAgreementUploaded = true;
            })
            .catch((error) => {
                this.error = error;
                console.error('Error uploading draft sale agreement: ', this.error);
            });
    }

    handleSendDraftAgreement() {
        saveFileAndSendEmail({ recordId: this.recordId })
            .then((result) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Draft Sale Agreement sent successfully!',
                        variant: 'success'
                    })
                )
                this.draftAgreementMailSent = true;
                this.agreementStatus = 'Customer Approval';
                this.agreementApprovalStatus === 'Pending';
                //this.fetchBookingDetails();
            })
            .catch((error) => {
                this.error = error;
                console.error('Error sending draft sale agreement: ', this.error);
            });
    }

    handleFinalDraftUploaded(event) {
        this.finalDraftAgreementId = event.detail.documentid;
        updatefinalSaleAgreementUpload({ bookingId: this.recordId, documentId: this.finalDraftAgreementId })
            .then((result) => {
                this.finalDraftAgreementUploaded = true;
            })
            .catch((error) => {
                this.error = error;
                console.error('Error uploading draft sale agreement: ', this.error);
            });
    }

    handleSendFinalDraftAgreement() {
        saveFinalFileAndSendEmail({ recordId: this.recordId })
            .then((result) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Final Draft Sale Agreement sent successfully!',
                        variant: 'success'
                    })
                )
                this.finalDraftAgreementMailSent = true;
                //this.fetchBookingDetails();
            })
            .catch((error) => {
                this.error = error;
                console.error('Error sending draft sale agreement: ', this.error);
            });
    }
}