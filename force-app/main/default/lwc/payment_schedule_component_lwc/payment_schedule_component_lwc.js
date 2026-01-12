import { api, LightningElement, track, wire } from 'lwc';
import getPaymentSchedules from '@salesforce/apex/PaymentScheduleTabController.getPaymentScheduleList';
import updatePaymentSchedules from '@salesforce/apex/PaymentScheduleTabController.updatepaymentSchedules';
import mergeSchedules from '@salesforce/apex/PaymentScheduleTabController.mergeSchedules';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Type from '@salesforce/schema/Account.Type';

const COLS = [
    { label: 'S No', fieldName: 'S_No__c', editable: true, initialWidth: 40 },
    { label: 'Payment schedule Name', fieldName: 'Name', editable: true, initialWidth: 180 },
    { label: 'Payment Percentage', fieldName: 'Payment_percent__c', type: 'percentage', editable: true },
    { label: 'Value of supply', fieldName: 'Amount__c', editable: true, type: 'currency' },
    { label: 'Milestone Amount', fieldName: 'AmountB__c', editable: false, type: 'currency' },
    { label: 'CGST Amount', fieldName: 'CGST_Amount__c', editable: false, type: 'currency' },
    { label: 'SGST Amount', fieldName: 'SGST_Amount__c', editable: false, type: 'currency' },
    { label: 'Custom Value', fieldName: 'Custom_Value__c', type: 'boolean', editable: true },
    //{ label: 'Is Demanded', fieldName: 'Is_Demanded__c', editable: false, type:'boolean' },
];

export default class Payment_schedule_component_lwc extends LightningElement {
    columns = COLS;
    draftValues = [];
    @api recordId;
    error;
    paymentSchedules;
    @track selectedData = [];
    currentlySelectedData = [];
    selected = [];
    isPressedMergeButton = false;
    @track disabledRows = [];
    @track showPrintScreen = false;
    vfPageUrl;

    get enableMergeButton() {
        if (this.selectedData.length > 1) {
            return false;
        } else {
            return true;
        }
    }

    handleRowSelection(event) {
        var action = event.detail.config.action;

        switch (action) {
            case 'selectAllRows':
                for (let i = 0; i < event.detail.selectedRows.length; i++) {
                    this.selectedData.push(event.detail.selectedRows[i]);
                    this.currentlySelectedData.push(event.detail.selectedRows[i]);
                }
                break;
            case 'deselectAllRows':
                this.currentlySelectedData = [];
                this.selectedData = [];
                break;
            case 'rowSelect':
                this.selectedData.push(event.detail.config.value);
                break;
            case 'rowDeselect':
                var index = this.selectedData.indexOf(event.detail.config.value);
                if (index !== -1) {
                    this.selectedData.splice(index, 1);
                }
                break;
            default:
                break;
        }
    }
    connectedCallback() {
        this.fetchPaymentSchedules();
        this.vfPageUrl = '/apex/PaymentShedulePrintVFP?id=' + this.recordId;
    }

    fetchPaymentSchedules() {
        getPaymentSchedules({ bookingId: this.recordId })
            .then((result) => {
                getPaymentSchedules({ bookingId: this.recordId })
                    .then((result) => {
                        this.paymentSchedules = result;

                        // Build disabledRows array based on Is_Demanded__c
                        this.disabledRows = result
                            .filter(row => row.Is_Demanded__c === true || row.S_No__c === 1)
                            .map(row => row.Id);
                    })
                    .catch((error) => {
                        console.error('error', error);
                        this.error = error;
                    });

            })
            .catch((error) => {
                console.log('error', error);
                this.error = error;
            });
    }

    async handleSave(event) {
        const updatedFields = event.detail.draftValues;

        // Clear all datatable draft values
        this.draftValues = [];

        try {
            // Pass edited fields to the updateContacts Apex controller
            await updatePaymentSchedules({ paymentScheduleForUpdate: updatedFields });

            // Report success with a toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Payment Schedules updated',
                    variant: 'success'
                })
            );

            // Display fresh data in the datatable
            await refreshApex(this.contacts);
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while updating or refreshing records',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
    }
    handleMergeSchedules() {

        console.log('Here');
        this.isPressedMergeButton = true;
        this.selected = this.refs.dt.getSelectedRows();
        console.log('selectedData', JSON.stringify(this.selected));

        // Extract only Ids
        const ids = this.selected.map(row => row.Id);
        console.log('Selected Ids:', ids);

        // Call Apex
        mergeSchedules({ scheduleIds: ids })
            .then(result => {
                var NewPaymentSchedules = result;
                console.log('NewPaymentSchedules', JSON.stringify(NewPaymentSchedules));
                this.paymentSchedules = NewPaymentSchedules;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Payment Schedules merged successfully',
                        variant: 'success'
                    })
                );

            })
            .catch(error => {
                console.error('Error merging schedules:', error);
            });
    }
    handleRefresh() {
        this.isPressedMergeButton = false;
        this.selected = [];
        this.draftValues = [];
        this.fetchPaymentSchedules();
    }

    showPrintSchedule() {
        this.showPrintScreen = true;
    }

    closePrintScreen() {
        this.showPrintScreen = false;
    }

    printPaymentSchedule() {
        // Get the iframe element
        const iframe = this.template.querySelector('iframe');
        if (iframe && iframe.contentWindow) {
            iframe.contentWindow.focus();
            iframe.contentWindow.print();
        } else {
            // fallback: print whole page
            window.print();
        }
    }


}