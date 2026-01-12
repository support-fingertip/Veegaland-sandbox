({
	doInit : function(component, event, helper) {
        helper.getFollowUpDetails(component, event);
        helper.getSiteVisitDetails(component, event);
        helper.getPendingFollowUpDetails(component, event);
        helper.getPendingSiteVisitDetails(component, event);
       	helper.getMissedTaskDetails(component, event);
        helper.renderEveryMin(component, event, helper);
        
        
	},
    onCallHandler:function(component, event, helper) {
        var leadRecordID=event.getSource().get("v.name");
        //alert(leadRecordID);
         component.set("v.leadRecID",leadRecordID);
         component.set("v.isCall",true);
        
	},
    onsvHandler:function(component, event, helper) {
         var svleadRecordID=event.getSource().get("v.name");
         component.set("v.SvleadRecID",svleadRecordID);
         component.set("v.isSv",true);   
	},
     onChange:function(component,event,helper){
         component.set("v.isCancelled",false);
         component.set("v.isConducted",false);
         component.set("v.isReschedule",false);
          component.set("v.updateValue","");
         
        var StatusValue=component.find('StatusID').get('v.value');
        if(StatusValue=='Cancelled')
            	component.set("v.isCancelled",true);
        else if(StatusValue=='Completed')
            component.set("v.isConducted",true);
        else if(StatusValue=='Rescheduled')
             component.set("v.isReschedule",true);
    },
    UpdateSvStatus:function(component,event,helper){
        var StatusValue=component.find('StatusID').get('v.value');
        var UpdatedValue=component.get("v.updateValue");
        if(StatusValue=='Rescheduled' && UpdatedValue !='')
            UpdatedValue= new Date(UpdatedValue).toLocaleString('en-GB');
        if(StatusValue!='' && UpdatedValue !='')
        {
         helper.updateSvDetails(component, event,StatusValue,UpdatedValue,helper);
         var closeMethod = component.get('c.closeModel');
          
        	$A.enqueueAction(closeMethod);
            
        }
    },
    closeModel: function(component, event, helper) {
       component.set("v.isCall",false);
       component.set("v.isSv",false);
         component.set("v.isCancelled",false);
         component.set("v.isConducted",false);
         component.set("v.isReschedule",false);
         component.set("v.updateValue","");
         component.set("v.SvleadRecID","");
          component.set("v.leadRecID","");
	},
   /* Rendering:function(component, event, helper)
    {
        
        helper.doneRendering(component, event);
    }*/
 
})