import { api, LightningElement } from 'lwc';

export default class PdfViewerLWC extends LightningElement {
    @api fileId;
    @api heightInRem;

    get pdfHeight() {
        return this.heightInRem + 'rem';
    }
    get url() {
        console.log('file'+'/sfc/servlet.shepherd/version/download/' + this.fileId);
        //'https://site-speed-6226--postsbox1.sandbox.lightning.force.com/sfc/servlet.shepherd/version/download/' + 
        return this.fileId;
    }
}