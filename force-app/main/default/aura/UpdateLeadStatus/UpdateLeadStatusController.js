({
    doInit : function(component, event, helper) {
        component.set('v.spinner',true);
         var action1 = component.get("c.getFollowUps"); // Ensure you're calling the method correctly
        action1.setParams({
            RecordId: component.get("v.recordId") // Set the RecordId parameter from the component's attribute
        });
        
        // Set the callback for handling the response
        action1.setCallback(this, function(response) {
            var state = response.getState(); // Get the state of the response
            if (state === 'SUCCESS') {
                 var returnValue = response.getReturnValue();
                // Display the returned value in an alert
                if (returnValue == null || (Array.isArray(returnValue) && returnValue.length === 0)) {
                    console.log("The returned value is null or an empty array.");
                   // alert("No follow-up records found.");
                } else {
                    //alert('Please mark the follow-up as completed.');
                    // Process the array if it's not null or empty
                    console.log("Returned value:", JSON.stringify(returnValue)); // Log the response
                    // component.set("v.projectList", returnValue); // Uncomment this line to use the data
                     component.set("v.LastFollowupScheduledDate",returnValue[0].Scheduled_Date__c);
                     component.set("v.LastFollowupDescription",returnValue[0].Description__c);
                    //helper.Toast('warning', 'warning', 'Please mark the follow-up as completed.');
                    component.set("v.completedSec",true);
                }
                // Uncomment the line below to set the projectList attribute with the returned value
                // component.set("v.projectList", response.getReturnValue());  
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors && errors.length > 0) {
                    console.error("Error message: " + errors[0].message); // Log the error message
                } else {
                    console.error("Unknown error"); // Handle unknown errors
                }
            }
        });
        
        // Enqueue the action to send the request to the server
        $A.enqueueAction(action1);
        
        var action = component.get("c.getProject");
        action.setParams({
            RecordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                component.set("v.projectList",response.getReturnValue());  
            }
        });
        $A.enqueueAction(action);
        var action = component.get("c.getAllocatedProject");
        action.setParams({
            RecordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                //alert(JSON.stringify(response.getReturnValue()));
                component.set("v.AllocatedprojectList",response.getReturnValue());  
            }
        });
        $A.enqueueAction(action);
        /*var action = component.get("c.getStatus");
        action.setParams({
            RecordId : component.get("v.recordId")
        });
         action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
     			//Handle success.
     			if(response.getReturnValue() == 'Site Visit'){
            		component.set('v.showFields',true);
                }else{
                    component.set('v.showFields',false);
                }
                if(response.getReturnValue() == 'SV Completed'){
            		component.set('v.showFields1',true);
                }else{
                    component.set('v.showFields1',false);
                }
            }
        });
        $A.enqueueAction(action); */
    },
    doInit1 : function(component, event, helper) {
        var proj = component.get("v.leadsRecord.Allocated_Project__c");
        //alert('Hello '+component.get("v.project"));
        //alert(component.get("v.project1"));
        if(proj != undefined && component.get("v.project") == undefined){
            component.set("v.project",proj);
        }
    },
    handleError: function (cmp, event, helper) {
        //alert('handle Error');
        var error = event.getParams();
        // Get the error message
        let errorMessage = event.getParam("message");
        let errorMessages = event.getParam("detail");
        //alert(errorMessages);
        if(errorMessage.includes('resource does not exist') || errorMessage.includes('do not have the level of access') || errorMessage.includes('insufficient access')){
            cmp.set('v.spinner',false);
            var homeEvt = $A.get("e.force:navigateToObjectHome");
            homeEvt.setParams({
                "scope": "Lead"
            });
            homeEvt.fire(); 
        }
        else if(errorMessages.includes('Please change Scheduled SiteVist status as Completed or Cancelled for Previous SV'))
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please change Scheduled SiteVist status as Completed or Cancelled for Previous SV",
                "type":"Error"
            });
            toastEvent.fire();
        }
            else if(errorMessages.includes('Choose Future Date and Time'))
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Choose Future Date and Time",
                    "type":"Error"
                });
                toastEvent.fire(); 
            }else if(errorMessages.includes('Please create followup record before changing stage to analysis.'))
            { 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please create followup record before changing stage to analysis.",
                    "type":"Error"
                });
                toastEvent.fire(); 
                cmp.set('v.spinner',false);
                
                
            }
                else if(errorMessages.includes('Please enter the correct name.'))
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Please enter the correct name.",
                        "type":"Error"
                    });
                    toastEvent.fire();
                    cmp.set('v.spinner',false);
                    
                    
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": errorMessages,
                        "type":"Error"
                    });
                    toastEvent.fire();
                }
    },
    handleLoad: function(component, event, helper) {
        var status = component.find('leadStatus').get('v.value');
        component.set('v.leadStatus',status);
        component.set('v.spinner',false);
    },
    handleOnSubmit : function(component, event, helper) {
        
        
        /*var proj = component.get("v.leadsRecord.Allocated_Project__c");
        event.preventDefault();   
        var eventFields = event.getParam("fields");
        if(proj != null)
        {
            eventFields["Allocated_Project__c"] = proj;
        }
        component.find('myform').submit(eventFields);*/
    },
    handleSuccess : function(component,event,helper) {
        //$A.get("e.force:closeQuickAction").fire();
        //alert(component.get("v.recordId"))
        var recId = component.get("v.recordId");
        var ButtonValue = component.get("v.ButtonValue");
        var leadStatus = component.get("v.leadStatus") || component.get("v.leadsRecord.Lead_Stage__c");
        
        // Function to handle the follow-up updates
        function handleFollowUpUpdate(responseMessage) {
            if (!responseMessage) {
                helper.Toast('SUCCESS', 'Success', 'Record Updated');
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            } else if (responseMessage.includes('Choose Future Date and Time')) {
                helper.Toast('ERROR', 'Error', 'Choose Future Date and Time');
            } else {
                helper.Toast('ERROR', 'Error', responseMessage);
                $A.get("e.force:closeQuickAction").fire();
            }
        }
        
        // Handle different lead statuses
        if (['Qualification', 'Analysis', 'Proposal', 'Negotiation', 'Closed Lost'].includes(leadStatus)) {
            var UpdateLeadStatus = true;
            var action1 = component.get("c.UpdateFollowUps");
            action1.setParams({
                recId: recId,
                ButtonValue: ButtonValue,
                UpdateLeadStatus: UpdateLeadStatus
            });
            action1.setCallback(this, function (response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    handleFollowUpUpdate(response.getReturnValue());
                } else {
                    helper.Toast('ERROR', 'Error', 'Something went wrong');
                    $A.get("e.force:closeQuickAction").fire();
                }
            });
            $A.enqueueAction(action1);
        } else if (['SV Schedule', 'SV Completed'].includes(leadStatus)) {
            var action = component.get("c.createALog");
            action.setParams({
                RecordId: recId,
                Project: component.get("v.project"),
                status: leadStatus
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                //alert(state);
                if (state === 'SUCCESS') {
                    //alert('hi');
                    var responseMessage = response.getReturnValue();
                    if (responseMessage === 'success') {
                        //alert('hello');
                        var UpdateLeadStatus = true;
                        console.log(response.getReturnValue());
                       /* helper.Toast('SUCCESS','Success','Record Updated');
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get('e.force:refreshView').fire();*/
                        var action2 = component.get("c.UpdateFollowUps");
                        action2.setParams({
                            recId: recId,
                            ButtonValue: ButtonValue,
                            UpdateLeadStatus: UpdateLeadStatus
                        });
                        action2.setCallback(this, function (response) {
                            var state = response.getState();
                            if (state === 'SUCCESS') {
                                //handleFollowUpUpdate(null);
                                console.log('Followup');
                                console.log(response.getReturnValue());
                                handleFollowUpUpdate(response.getReturnValue());
                            } else {
                                helper.Toast('ERROR', 'Error', 'Something went wrong');
                                $A.get("e.force:closeQuickAction").fire();
                            }
                        });
                        $A.enqueueAction(action2);
                        
                    } else {
                        if (responseMessage.includes('Choose Future Date and Time') || responseMessage.includes('Please enter future Date')) {
                            helper.Toast('ERROR', 'Error', 'Choose Future Date and Time');
                        }
                    }
                } else if (state === 'ERROR') {
                    helper.Toast('ERROR', 'Error', 'Something went wrong');
                    $A.get("e.force:closeQuickAction").fire();
                }
            });
            $A.enqueueAction(action);
        }else{
            helper.Toast('SUCCESS','Success','Record Updated');
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        }
        component.set('v.spinner',false);
    },
    doCancel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    },
    onLeadChange : function(component, event, helper){
        component.set('v.spinner',true);
        component.set('v.leadlost','');
        //alert('Status'+event.getParam('value'));
        component.set('v.leadStatus',event.getParam('value'));
         var ldstatus = component.get("v.leadStatus");
     /*  if(ldstatus=='Analysis'){
              var recId = component.get("v.recordId");
             var action = component.get("c.checkfollowUp");
            action.setParams({ RecordId: recId  });
           action.setCallback(this, function (response) {
                var state = response.getState();
               
               if(state == 'SUCCESS') {
                   if(response.getReturnValue() == 'Yes'){
                       
                        component.set('v.analysissec',false);
                   }
                   else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Please create followup record before changing stage to analysis.",
                            "type":"Error"
                        });
                        toastEvent.fire(); 
                        component.set('v.spinner',false);
                        component.set('v.analysissec',true);
                       
                   }
               }
           });
            $A.enqueueAction(action);
          
        }
       */
        
        var leadStatus1 = event.getParam('value');
        if(leadStatus1 == 'Invalid' || leadStatus1 =='Site Visit' || leadStatus1 == 'Lost'){
            component.set('v.showFields2',false);
        }
        else{
            component.set('v.showFields2',true); 
        }
        component.set('v.spinner',false);
    },
    onLeadlost : function(component, event, helper){
        component.set('v.spinner',true); 
        component.set('v.leadlost',event.getParam('value'));
        //var leadlost1 = event.getParam('value');
        component.set('v.spinner',false);
    },
    onProjectChange: function(component, event, helper){
        //alert('change'+event.getSource().get("v.value"));
        component.set('v.spinner',true); 
        component.set('v.project',event.getSource().get("v.value"));
        //component.set('v.project1',event.getSource().get("v.value"));
        component.set('v.spinner',false);
    },
    handleUploadAdhar: function (cmp, event) {
        var uploadedFiles = event.getParam("files");
        var recordId = cmp.get("v.recordId");
        for (var i = 0; i < uploadedFiles.length; i++) {
            var uploadedFile = uploadedFiles[i];
            
            var fileName = 'Aadhar_' + uploadedFile.name; // Use a unique identifier, for example, index + 1
            
            // Call the server-side controller method to update the file name
            var action = cmp.get("c.updateFileName");
            action.setParams({
                fileId: uploadedFile.documentId,
                newFileName: fileName
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('File name updated successfully: ' + fileName);
                } else {
                    console.error('Error updating file name: ' + response.getError()[0].message);
                }
            });
            
            $A.enqueueAction(action);
        }
        
        
        // Get the file name
        uploadedFiles.forEach(file => console.log(file.name));
    },
    handleUploadPAN: function (cmp, event) {
        var uploadedFiles = event.getParam("files");
        
        var recordId = cmp.get("v.recordId");
        for (var i = 0; i < uploadedFiles.length; i++) {
            var uploadedFile = uploadedFiles[i];
            
            var fileName = 'PAN_' + uploadedFile.name; // Use a unique identifier, for example, index + 1
            
            var action = cmp.get("c.updateFileName");
            action.setParams({
                fileId: uploadedFile.documentId,
                newFileName: fileName
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('File name updated successfully: ' + fileName);
                } else {
                    console.error('Error updating file name: ' + response.getError()[0].message);
                }
            });
            
            $A.enqueueAction(action);
        }
        
        
        // Get the file name
        uploadedFiles.forEach(file => console.log(file.name));
    },
    NewhandleClick: function(component,event,helper){
        //alert('new');
        component.set("v.ActiveDiv",false);
       // component.set("v.Status",'Scheduled');
        component.set('v.VarientValue',"brand");
        component.set('v.VarientValues',"neutral");
        component.set('v.ButtonValue',"New Follow Up");
        //alert(component.get("v.Status"));
    },
    UpdatehandleClick: function(component,event,helper){
        //alert('Update');
        component.set("v.ActiveDiv",true);
      //  component.set("v.Status",'Completed'); 
        component.set('v.VarientValue',"neutral");
        component.set('v.VarientValues',"brand");
        component.set('v.ButtonValue',"Update Follow Up");
        //alert(component.get("v.Status"));
    },
    /*validateDateTime: function (component, event, helper) {
        var selectedDate = component.get("v.selectedDate");
        var selectedTime = component.get("v.selectedTime");

        // Validate if both date and time are selected
        if (selectedDate && selectedTime) {
            var currentDate = new Date();
            var selectedDateTimeString = selectedDate + 'T' + selectedTime;
            var selectedDateTime = new Date(selectedDateTimeString);

            if (selectedDateTime > currentDate) {
                // The selected datetime is in the future
                console.log("Selected datetime is in the future.");
                // You can perform additional actions or show a success message here
            } else {
                // The selected datetime is not in the future
                console.error("Selected datetime must be in the future.");
                // You can display an error message to the user
            }
        } else {
            // Handle the case where either date or time is not selected
            console.error("Please select both date and time.");
            // You can display an error message to the user
        }
    }*/
})