({
    
    doInit : function(component, event, helper) {
        helper.getUploadedFiles(component);
        
    },
    
    handleUploadFinished: function (component, event, helper) {
        var uploadedFiles = event.getParam("files");
        
        // Refresh file list immediately
        helper.getUploadedFiles(component);
        
        // Then rename files
        helper.renameFiles(component, uploadedFiles);
    },
    handleDeleteFile: function (component, event, helper) {
        var fileId = event.getSource().get("v.value");
        
        // Remove file from UI immediately
        var uploadedFiles = component.get("v.uploadedFiles");
        var updatedFiles = uploadedFiles.filter(file => file.Id !== fileId);
        component.set("v.uploadedFiles", updatedFiles);
        
        // Delete from server
        helper.deleteFile(component, fileId);
    }
    
});