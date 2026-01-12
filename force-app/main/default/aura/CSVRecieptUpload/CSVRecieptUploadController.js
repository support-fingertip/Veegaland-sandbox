({
    doInit : function(component, event, helper) {
        // Datatable uses your field API names (matches helper.parseCsvFile output)
        component.set("v.columns", [
            { label: 'Booking Id/Name',   fieldName: 'BookingName__c',            type: 'text' },
            { label: 'Total Amount',      fieldName: 'Amount_received__c',        type: 'number', cellAttributes: { alignment: 'left' } },
            { label: 'Bank Name',         fieldName: 'Payment_Received_Bank__c',  type: 'text' },
            { label: 'Branch',            fieldName: 'Branch__c',                 type: 'text' },
            { label: 'Transaction Number',fieldName: 'Check_Transaction_Nmber__c',type: 'text' },
            { label: 'Mode Of Payment',   fieldName: 'Mode_of_payment__c',        type: 'text' },
            { label: 'Payment From',      fieldName: 'Payment_From__c',           type: 'text' },
            { label: 'Receipt Date',      fieldName: 'Receipt_date__c',           type: 'date',
             typeAttributes: { year: 'numeric', month: '2-digit', day: '2-digit' } },
            { label: 'Instrument Date',      fieldName: 'Instrument_Date__c',     type: 'date',
             typeAttributes: { year: 'numeric', month: '2-digit', day: '2-digit' } },
            { label: 'Approval Status',   fieldName: 'Approval_status__c',        type: 'text' },
            { label: 'Skip Approval', fieldName: 'Skip_Approval__c', type: 'boolean' }
        ]);
    },
    
    handleFileChange : function(component, event, helper) {
        var files = event.getSource().get("v.files");
        if (!files || !files.length) {
            component.set("v.fileName", "");
            component.set("v.data", []);
            component.set("v.rowCount", 0);
            return;
        }
        
        var file = files[0];
        component.set("v.fileName", (file && file.name) ? file.name : "");
        
        // Strict CSV-by-extension check
        if (!file || !file.name || file.name.toLowerCase().slice(-4) !== '.csv') {
            helper.toast('Invalid file', 'Please select a .csv file.', 'error');
            component.set("v.data", []);
            component.set("v.rowCount", 0);
            return;
        }
        
        // Helper will return rows shaped with the API names above
        helper.parseCsvFile(file, function(err, rows){
            if (err) {
                helper.toast('Parsing error', err, 'error');
                component.set("v.data", []);
                component.set("v.rowCount", 0);
                return;
            }
            component.set("v.data", rows);
            component.set("v.rowCount", rows.length);
            helper.toast('Success', 'Parsed ' + rows.length + ' row(s).', 'success');
        });
    },
    
    downloadTemplate : function(component, event, helper) {
        // Visualforce page that streams an .xls template
        window.open('/apex/ReceiptUploadTemplate?rows=100', '_blank');
    },
    saveData : function(component, event, helper) {
        var rows = component.get("v.data");
        if (!rows || !rows.length) {
            helper.toast('No data', 'Upload & parse a CSV first.', 'warning');
            return;
        }
        component.set("v.isLoading", true);
        helper.saveRows(component, rows, function(err, jobId){
            component.set("v.isLoading", false);
            if (err) helper.toast('Upload failed', err, 'error');
            else helper.toast('Started', 'Batch queued. Job Id: ' + jobId, 'success');
        });
    }
})