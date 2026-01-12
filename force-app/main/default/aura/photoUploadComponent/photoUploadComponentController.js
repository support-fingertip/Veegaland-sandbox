({
    doInit : function(component, event, helper){  
       helper.getUploadedFiles(component, event);
    },      
    
    previewFile : function(component, event, helper){  
        $A.get('e.lightning:openFiles').fire({ 
            recordIds: [event.currentTarget.id]
        });  
    },  
    
   uploadFinished : function(component, event, helper) {
    var uploadedFiles = event.getParam("files");
    var allFiles = component.get("v.files") || [];

    // Map uploaded files to expected structure
    uploadedFiles.forEach(function(file) {
        allFiles.push({
            Id: file.documentId,
            Title: file.name
        });
    });

    component.set("v.files", allFiles);

    // Extract document IDs
    var contentDocumentIds = allFiles.map(file => file.Id);
    component.set("v.filesIds", contentDocumentIds); // Set file IDs list if needed


    // Fire fileUploadEvent for parent component
    var fileUploadEvent = component.getEvent("fileUploadEvent");
    fileUploadEvent.setParams({ "files": contentDocumentIds });
    fileUploadEvent.fire();

    // Show toast
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "message": "Files have been uploaded successfully!",
        "type": "success",
        "duration" : 2000
    });
    toastEvent.fire();
}
, 
    
    deleteSelectedFile : function(component, event, helper){
        if( confirm("Confirm deleting this file?")){
            component.set("v.showSpinner", true); 
            helper.deleteUploadedFile(component, event);                
        }
    }
 })