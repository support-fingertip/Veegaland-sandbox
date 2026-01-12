import { api, LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateBookingDocuments from '@salesforce/apex/BookingController.updateBookingDocuments';
export default class UpdateAllBookingDocuments extends LightningElement {
    @api bookingId;
    disableButton = false;

    getAllBookingDocuments() {
        this.disableButton = true;
        updateBookingDocuments({ bookingId: this.bookingId })
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Booking Documents Updated',
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
        this.disableButton = true;
    }
}