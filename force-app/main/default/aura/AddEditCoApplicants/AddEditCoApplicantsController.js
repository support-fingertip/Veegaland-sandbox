({
    doInit: function(component, event, helper) {
        helper.fetchCoApplicants(component,helper);
        helper.getPicklistValues(component);
    },

     addCoApplicant: function(component, event, helper) {
        helper.createCoApplicant(component);
     },
    
    removeCoApplicant: function(component, event, helper) {
        let coApplicantId = event.getSource().get("v.name");
        console.log('coApplicantId'+coApplicantId);
        if (coApplicantId) {
            helper.deactivateCoApplicant(component, coApplicantId);
        }
    },

    save: function(component, event, helper) {
        helper.saveCoApplicants(component, event, helper);
    },
    
    /*handleFileChange: function(component, event, helper) {
    let file = event.target.files[0];
    let predefinedFileName = event.target.dataset.name;
    let coApplicantId = event.target.dataset.id; 

    if (file) {
        let reader = new FileReader();
        reader.onload = function(e) {
            let files = [...(component.get("v.files") || [])]; // Get a COPY of files list
            let fileData = {
                fileName: predefinedFileName,
                fileContent: e.target.result.split(',')[1], 
                coApplicantId: coApplicantId
            };

            files.push(fileData);
            component.set("v.files", files); // Set the updated list safely

            // Display Thumbnail Only for Images
            if (file.type.startsWith("image/")) {
                let previewContainer = event.target.nextElementSibling;
                previewContainer.innerHTML = `<img src="data:image/png;base64,${fileData.fileContent}" 
                                              style="width: 50px; height: 50px;"/> 
                                              ${fileData.fileName}`;
            }
        };
        reader.readAsDataURL(file);
    }
},*/
    handleFileChange: function(component, event, helper) {
        let file = event.target.files[0];
        let predefinedFileName = event.target.dataset.name;
        console.log('predefinedFileName'+predefinedFileName);
        let coApplicantId = event.target.dataset.id; 
        
        if (file) {
            let reader = new FileReader();
            reader.onload = function(e) {
                let fileContent = e.target.result.split(',')[1]; // Extract Base64 content
                let fileData = {
                    fileName: file.name,
                    fileReName: predefinedFileName,
                    fileContent: fileContent,
                    coApplicantId: coApplicantId
                };
                
                // Call Apex to upload the file
                helper.uploadFile(component, fileData, helper);
                
                // Display Thumbnail for Images
                if (file.type.startsWith("image/")) {
                    let previewContainer = event.target.nextElementSibling;
                    previewContainer.innerHTML = `<img src="data:image/png;base64,${fileContent}" 
                    style="width: 50px; height: 50px;"/> 
                        ${predefinedFileName}`;
                }
            };
            reader.readAsDataURL(file);
        }
    },
    
    
    uploadFiles: function(component, event, helper) {
        helper.uploadFilesToSalesforce(component);
    },
    cancel: function(component, event, helper) {
        helper.cancelPopup(component);
    }
})