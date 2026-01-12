({
    doInit : function(component, event, helper) {
       // alert('hiii doInit')
        helper.getPickListValue(component,event, helper);
        
    },
    handleError: function (cmp, event, helper) {
        var error = event.getParams();
        //alert("Error : " + JSON.stringify(error));
        console.log(JSON.stringify(error));
        // Get the error message
        var errorMessage = event.getParam("message");
        var errorMessages = event.getParam("output");
        //alert(errorMessage);
        console.log('errorMessage'+JSON.stringify(errorMessages));
       if(errorMessage.includes('The requested resource does not exist')){
            cmp.set('v.spinner',true);
            helper.toastMsg('error','Duplicate','Lead already exist in the system');
            var homeEvt = $A.get("e.force:navigateToObjectHome");
            homeEvt.setParams({
                "scope": "Lead"
            });
            homeEvt.fire();
        }
        /*else if(errorMessages.includes('Invalid Postal Code format. Please enter a 6-digit numeric code.')){
            alert('hi');
             cmp.set('v.spinner',true);
             helper.toastMsg('error','Validation Error','Invalid Postal Code format. Please enter a 6-digit numeric code');
        }*/
        else{
            cmp.set('v.spinner',false);
            helper.toastMsg('error','Error',errorMessage);
        }
        
        //history.back();
        /*var homeEvt = $A.get("e.force:navigateToObjectHome");
        homeEvt.setParams({
            "scope": "Lead"
        });
        homeEvt.fire();*/    
    },
    handleSubmit : function(component, event, helper) {
        component.set('v.spinner',true);
        //alert('hi');
        //var isVaild = true;
        var projectName = component.get('v.allocatedProject');
        var mobileNumber = component.get("v.record.Mobile_Number__c");
        event.preventDefault(); // stop form submission
        var eventFields = event.getParam("fields");
       // eventFields["Allocated_Project__c"] = projectName;
        
        /*var projecn = component.get('v.leadSource');
        if(projecn=='Channel partner'){
            var isValid = helper.validateForm(component,event, helper); // Assuming you have a helper method to perform validation
        }
        else{
            isVaild=true;
        }*/
        
       // var isValid = helper.validateForm(component,event, helper);
        //alert(isValid);
        //alert(isValid)
        /*alert(component.get("v.pincode"));
        if(component.get("v.pincode") != null)
        {
            var numberRegex = /^[0-9]*$/;
            var num = numberRegex.test(component.get("v.pincode"));
            var stringLength  = component.get("v.pincode").length;
            if(num == false || stringLength != 6)
            {
                helper.toastMsg('error','Validation Error','PIN code must consist of six digits only, and special characters and charcter are not allowed.');
                var pin = component.find("pin");
                if (pin) {
                    pin.focus();
                }
                isVaild = false;
            }
            
        }
        alert(isValid);
        if (isValid == true) {*/
            //component.set('v.spinner',true);
            component.find('myform').submit(eventFields);
        //}
        //component.find('myform').submit(eventFields);
        
    },
    handleSuccess : function(component, event, helper) {
        //alert('success');
        var record = event.getParam("response");
        //alert(record);
        var apiName = record.apiName;
        //component.set('record.Allocated_Project__c',component.get('v.allocatedProject'))
        var myRecordId = record.id; // ID of updated or created record
 		console.log('MyRecordId'+myRecordId);
        component.set('v.LeId',myRecordId)
        //console.log('LeId');
        //alert(myRecordId);
        //component.set('v.spinner',false);
        helper.toastMsg('Success','Success','Lead created successfully'); 
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": myRecordId,
            "slideDevName": "detail"
        });
        navEvt.fire();
        
       
        
      //  helper.sendemailcustomer(component,event, helper);
        //helper.sendemailpresale(component,event, helper);
        //helper.sendNotificationToOwner(component,event, helper);
        
       
        
        
        
    },
    leadsamp: function(component, event, helper) {
        var samp=component.get('v.leadSource');
        //alert(samp);
        if(samp=='Channel partner')
        {
            component.set("v.disableCP", false);
        }
        else
        {
            component.set("v.disableCP", true);
            component.set("v.CPName", '');
        }
},
    
    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
    },
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
      $A.get("e.force:closeQuickAction").fire();
       // alert('hi')
       history.back();
    },
    searchText : function(component, event, helper) {
        var accounts= component.get('v.accounts');
        var searchText= component.get('v.searchText');
        
        var matchaccounts=[];
        if(searchText !=''){
           
            for(var i=0;i<accounts.length; i++){ 
                if(accounts[i].toLowerCase().indexOf(searchText.toLowerCase())  != -1  ){
                    
                    if(matchaccounts.length <50){
                        matchaccounts.push( accounts[i] );
                    }else{
                        break;
                    }
                    
                } 
            } 
            if(matchaccounts.length >0){
                component.set('v.matchaccounts',matchaccounts);
            }
        }else{
            component.set('v.matchaccounts',[]);
            component.set('v.allocatedProject','');
        }
    },
    update: function(component, event, helper) {
        
        component.set('v.allocatedProject', event.currentTarget.dataset.id);
        
        var edi = component.get('v.allocatedProject');
        //alert(JSON.stringify(edi))
        var accounts= component.get('v.matchaccounts');
        //alert(accounts)
        for(var i=0;i<accounts.length; i++){ 
            if(accounts[i] ===  edi ){
                component.set('v.searchText', accounts[i]);
                component.set('v.allocatedProject', accounts[i]);
                
                break;
            } 
        } 
        
        component.set('v.matchaccounts',[]);
        
    },
    /*onPhoneValidation: function(component, event, helper) {
        component.set('v.phones',event.getParam('value'));
    },
    onMoboileValidation: function(component, event, helper) {
        component.set('v.mobiles',event.getParam('value'));
    },
    onPincode: function(component, event, helper){
        component.set('v.pincode',event.getParam('value'));
        var numberRegex = /^[0-9]*$/;
        var num = numberRegex.test(event.getParam('value'));
        var stringLength  = event.getParam('value').length;
        if(num == false || stringLength > 6)
        {
            helper.toastMsg('error','Validation Error','PIN code must consist of six digits only, and special characters and charcter are not allowed.');
            var pin = component.find("pin");
            if (pin) {
                pin.focus();
            }
        }
    }*/
})