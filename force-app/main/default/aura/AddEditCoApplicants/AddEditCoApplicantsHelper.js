({
    fetchCoApplicants: function(component,helper) {
        let action = component.get("c.getCoApplicants");
        action.setParams({ bookingId: component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.coApplicants", response.getReturnValue());
                helper.fetchCoApplicantsWithFiles(component);
            } else {
                console.error("Error fetching co-applicants: " + JSON.stringify(response.getError()));
            }
        });
        
        $A.enqueueAction(action);
    },
    
    saveCoApplicants: function(component, event, helper) {
        //console.log("Already here saveCoApplicants");
        
        // Prevent multiple executions by adding a lock
        //if (component.get("v.isSaving")) {
        //    console.warn("Save already in progress... Exiting");
        //     return;
        //}
        //component.set("v.isSaving", true); // Lock function execution
        
        //let files = component.get("v.files") || [];
        
        let action = component.get("c.saveCoApplicants");
        action.setParams({ 
            coApplicants: component.get("v.coApplicants"),
            //fileDataList: files 
        });
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log("Co-Applicants saved successfully");
                
                // Clear files safely after successful response
                //setTimeout(() => {
                //    component.set("v.files", []); // Delayed clear to avoid instant re-render
                //}, 500); 
                
                // Show success message
                $A.get("e.force:showToast").setParams({
                    "title": "Success!",
                    "message": "Co-Applicants saved successfully.",
                    "type": "success"
                }).fire();
                
                // Instead of full refresh, manually update records if needed
                //$A.get("e.force:refreshView").fire(); // <-- Commented out to prevent loop
            } else {
                console.error("Error saving co-applicants:", JSON.stringify(response.getError()));
            }
            
            //component.set("v.isSaving", false); // Unlock function execution
        });
        
        $A.enqueueAction(action);
    },
    
    addFileToList: function(component, fileData, inputElement) {
        console.log('Alreday here addFileToList');
        let files = component.get("v.files") || [];
        files.push(fileData);
        component.set("v.files", files);
        
        // Display Thumbnail
        let previewContainer = inputElement.nextElementSibling;
        previewContainer.innerHTML = `<img src="data:image/png;base64,${fileData.fileContent}" style="width: 50px; height: 50px;"/> ${fileData.fileName}`;
    },
    /*uploadFilesToSalesforce: function(component) {
        
        let files = component.get("v.files");

        if (!files.length) {
            alert("No files to upload!");
            return;
        }

        let action = component.get("c.saveFiles");
        action.setParams({ fileDataList: files });

        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                alert("Files uploaded successfully!");
                component.set("v.files", []);
            } else {
                alert("Error uploading files.");
            }
        });

        $A.enqueueAction(action);
    },*/
    uploadFile: function(component, fileData,helper) {
        let action = component.get("c.saveFile"); // Call Apex method
        console.log('fileRename'+fileData.fileReName);
        action.setParams({
            fileName: fileData.fileName,
            fileRename:fileData.fileReName,
            base64Data: fileData.fileContent,
            coApplicantId: fileData.coApplicantId
        });
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log("File uploaded successfully!");
                $A.get("e.force:showToast").setParams({
                    "title": "Success!",
                    "message": "File uploaded successfully!",
                    "type": "success"
                }).fire();
                helper.fetchCoApplicantsWithFiles(component);
            } else {
                console.error("File upload failed: ", response.getError());
            }
        });
        
        $A.enqueueAction(action);
    },
    getPicklistValues: function(component) {
        let action = component.get("c.getPicklistValues");
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.picklistValues", response.getReturnValue());
            } else {
                console.error("Error fetching picklist values: " + JSON.stringify(response.getError()));
            }
        });
        
        $A.enqueueAction(action);
    },
    createCoApplicant: function(component) {
        let action = component.get("c.addCoApplicants");
        action.setParams({ 
            bookingId: component.get("v.recordId"),
            coApplicants: component.get("v.coApplicants") 
        });
        
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                let newCoApplicant = response.getReturnValue();
                component.set("v.coApplicants", newCoApplicant);
            } else {
                console.error("Error creating co-applicant: " + JSON.stringify(response.getError()));
            }
        });
        
        $A.enqueueAction(action);
    },
    fetchCoApplicantsWithFiles: function (component) {
        let action = component.get("c.getCoApplicantsWithFiles");
        let coApplicants = component.get("v.coApplicants");
        let coAppIds = coApplicants.map(coApp => coApp.Id);
        action.setParams({ coAppIds: coAppIds });
        
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                let updatedCoApps = response.getReturnValue();
                let existingCoApps = component.get("v.coApplicants");
                // Merge the existing coApplicants with the fetched file details
                let coAppMap = new Map();
                existingCoApps.forEach(coApp => coAppMap.set(coApp.Id, coApp));
                
                updatedCoApps.forEach(updatedCoApp => {
                    if (coAppMap.has(updatedCoApp.Id)) {
                    let existing = coAppMap.get(updatedCoApp.Id);
                    existing.Aadhar_Document_Title__c = updatedCoApp.Aadhar_Document_Title__c;
                    existing.PAN_Document_Title__c = updatedCoApp.PAN_Document_Title__c;
                    existing.Photo_Document_Title__c = updatedCoApp.Photo_Document_Title__c;
                }
              });
                // Set the updated list back to the component
                component.set("v.coApplicants", Array.from(coAppMap.values()));
            } else {
                console.error("Error fetching co-applicants with files:", response.getError());
            }
        });
        
        $A.enqueueAction(action);
    },
    cancelPopup: function(component) {
        component.set('v.showPopup',false);
    },
    deactivateCoApplicant: function(component, coApplicantId) {
        let action = component.get("c.updateCoApplicantStatus"); // Apex method
        action.setParams({
            coApplicantId: coApplicantId,
            bookingId: component.get("v.recordId") // Assuming you store Booking ID in the component
        });
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let updatedCoApplicants = response.getReturnValue();
                component.set("v.coApplicants", updatedCoApplicants); // Refresh UI with updated list
            } else {
                console.error("Error in deactivating co-applicant:", response.getError());
            }
        });
        
        $A.enqueueAction(action);
    }
    
    
});