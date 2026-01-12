({
    renameFiles: function(component, files) {
        var action = component.get("c.renameFileApex");
        action.setParams({
            fileIds: files.map(file => file.documentId)
        });
        
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                this.getUploadedFiles(component);
            }
        });
        $A.enqueueAction(action);
    },
    
    deleteFile: function(component, fileId) {
        var action = component.get("c.deleteFileApex");
        action.setParams({ fileId: fileId });
        
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                
                // this.getUploadedFiles(component);
            }
        });
        $A.enqueueAction(action);
        
    },
    getUploadedFiles: function(component) {
        var action = component.get("c.getFiles");
        action.setParams({ recordId: component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                let files = response.getReturnValue();
                
                files.forEach(file => {
                    file.iconName = this.getFileIcon(file.FileExtension);
                });
                    
                    component.set("v.uploadedFiles", files);
                    
                    // Instead of refreshing the entire page, we update the view manually
                    $A.get('e.force:refreshView').fire();
                }
                });
                    
                    $A.enqueueAction(action);
                }
                    ,
                    getFileIcon: function(fileExtension) {
                        var fileIcons = {
                            'pdf': 'doctype:pdf',
                            'doc': 'doctype:word',
                            'docx': 'doctype:word',
                            'xls': 'doctype:excel',
                            'xlsx': 'doctype:excel',
                            'ppt': 'doctype:ppt',
                            'pptx': 'doctype:ppt',
                            'txt': 'doctype:txt',
                            'jpg': 'doctype:image',
                            'jpeg': 'doctype:image',
                            'png': 'doctype:image',
                            'zip': 'doctype:zip',
                            'mp4': 'doctype:video',
                            'mp3': 'doctype:audio'
                        };
                        return fileIcons[fileExtension] || 'doctype:unknown';
                    }
                });