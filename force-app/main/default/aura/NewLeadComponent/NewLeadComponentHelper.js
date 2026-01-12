({
    getPickListValue : function(component, event, helper){
        //var recoooordif = component.get("v.recordId");
        //alert('hiii getPickListValue  '+ recoooordif)
        var action = component.get("c.getPickListValues");
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                var ProjectPickList = response.getReturnValue();
                console.log(ProjectPickList);
               component.set('v.accounts',ProjectPickList)
               //alert(component.get('v.accounts'))
            }
        });
        $A.enqueueAction(action);
    },
    
    /*sendemailpresale : function(component, event, helper){
        var mail = component.get("c.LeadAssigned_Emailto_PreSalesUser");
        mail.setParams({ recId : component.get("v.LeId") });
        mail.setCallback(this, function(response){
            var status = response.getState();
            if(status == 'SUCCESS') {
                var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            message: 'Mail Sent to PreSales Executive',
                            type : 'success'
                        });
                        toastEvent.fire();
                        //$A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(mail);
    },
    
    sendNotificationToOwner : function(component, event, helper){
        var noty = component.get("c.sendNotification");
        noty.setParams({ recId : component.get("v.LeId") });
        noty.setCallback(this, function(response){
            var status = response.getState();*/
           /* if(status == 'SUCCESS') {
                var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            message: 'Mail Sent to PreSales Executive',
                            type : 'success'
                        });
                        toastEvent.fire();
                        //$A.get("e.force:closeQuickAction").fire();
            }  */
        /*});
        $A.enqueueAction(noty);
    },
    
    sendemailcustomer : function(component, event, helper){
        var mail = component.get("c.LeadAssigned_Emailto_Customer");
        mail.setParams({ recId : component.get("v.LeId") });
        mail.setCallback(this, function(response){*/
            /*var status = response.getState();
            if(status == 'SUCCESS') {
                var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            message: 'Mail Sent to Customer',
                            type : 'success'
                        });
                        toastEvent.fire();
                        //$A.get("e.force:closeQuickAction").fire();
            }*/
           /* if(response.getState() == 'SUCCESS' ) {
                
                var res_string= response.getReturnValue();
                event.stopPropagation();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                var type;
                if(res_string == 'Mail sent to customer'){
                    type = 'success';
                    var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                  //  "type":type,
                   // "title": type,
                   // "message":res_string,
                    //"duration":10000
                    message: 'Mail Sent to Customer',
                    type : 'success'
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
                }
                
            }
            else{
                (state === 'ERROR')
                {
                    console.log('failed');
                }
            }
            
        });
        $A.enqueueAction(mail);
    },
    
    validateForm: function(component, event, helper) {
        var leadSource = component.get("v.leadSource");
        var ChannelpartnerName = component.get("v.CPName");
        
        // Perform validation checks based on the selected Lead Source
        if (leadSource === 'Channel partner' && (ChannelpartnerName == null || ChannelpartnerName =='')) {
            //component.set('v.CPrequired',true);
            helper.toastMsg("error","Error", "Channel partner Name is required for Channel Partner leads." );
            component.set('v.spinner',false);
            return false; // Prevent further action
        }
        else if(leadSource === 'Channel partner'&& (ChannelpartnerName!= null || ChannelpartnerName!='' || ChannelpartnerName!=' ')){
            return true;
        }
        /*var p1 = component.get("v.phones");
        var p2 = component.get("v.mobiles");
        if(isNaN(p1) || (isNaN(p2) && p2!=null))
        {
            helper.toastMsg("error","Error", "The Primary phone and Secondary phone fields are numeric fields." );
            return false; 
        }
        else if(!isNaN(p1) || (!isNaN(p2) && p2!=null)){
            return true;
        }*/
        
       /* else if(leadSource != 'Channel partner'&& (ChannelpartnerName != null || ChannelpartnerName !='')){
            helper.toastMsg("error","Error", "Since, lead source is not Channel partner, you cannot Enter Channel partner Name." );
            component.set('v.spinner',false);
            return false;
        }
        else if(leadSource != 'Channel partner'&& (ChannelpartnerName == null || ChannelpartnerName =='')){
            return true;
        }*/
        /*else{
            return true;
        }
        
        // If all validations pass, proceed with further actions (e.g., create the Lead)
    },*/
    
	toastMsg : function (type, title, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": msg
        });
        toastEvent.fire();
    }
    
})