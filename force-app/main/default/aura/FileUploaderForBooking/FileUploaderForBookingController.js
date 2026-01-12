({
 doInit : function(component, event, helper){ 
      helper.getstatus(component, event,helper);
        for(var i=0;i<10;i++)
       		helper.getUploadedFiles(component, event,i);

    }, 
        selectChange:function(component, event, helper) {
     
        if(!(component.get('v.showFiles')))
            component.set('v.showFiles',true);
        else
            component.set('v.showFiles',false);
          
    },
    
    previewFile : function(component, event, helper){  
        $A.get('e.lightning:openFiles').fire({ 
            recordIds: [event.currentTarget.id]
        });  
    }, 
         // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
     
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    },
     uploadFinished : function(component, event, helper) { 
       var sectionName=event.getSource().get('v.name');
       var filesData=event.getParam("files");
       var fileIdArray=[];
       for(var i=0;i<filesData.length;i++)
       {	
          fileIdArray.push(filesData[i].documentId);
       }
        helper.UpdateDocument(component, event,helper,fileIdArray,sectionName);
         for(var i=0;i<10;i++)
        	helper.getUploadedFiles(component, event,i);    
        var toastEvent = $A.get("e.force:showToast");
        // show toast on file uploaded successfully 
        toastEvent.setParams({
            "message": "Files have been uploaded successfully!",
            "type": "success",
            "duration" : 2000
        });
        toastEvent.fire();
        
         //$A.get('e.force:refreshView').fire();
    },
    
})