({
    deleteUploadedFile : function(component, event) {  
        var action = component.get("c.deleteFile");           
        action.setParams({
            "contentDocumentId": event.currentTarget.id            
        });  
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){  
                this.getUploadedFiles(component);
                component.set("v.Spinner", false); 
                // show toast on file deleted successfully
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": "File has been deleted successfully!",
                    "type": "success",
                    "duration" : 2000
                });
                toastEvent.fire();
            }  
        });  
        $A.enqueueAction(action);  
    },  
    UpdateDocument:function(component, event,helper,docIdList,prefix)
    {
       // helper.updateCapa(component, event,helper);
        var action = component.get("c.updateDocument");   
        action.setParams({
            "prefixName":  prefix,
            "idList":docIdList
        }); 
        $A.enqueueAction(action);  
        
    },
    getUploadedFiles : function(component, event,i){
        var action = component.get("c.getFiles"); 
        console.log('==>'+i);
        var FilterName='';
        if(i==0) 
            FilterName='Pan-Card';
        else if(i==1)
            FilterName='Aadar-Card';
         else if(i==2)
            FilterName='Applicant-Photos';
         else if(i==3)
            FilterName='Sale-Agreement';
         else if(i==4)
            FilterName='Loan-Docs';
        else if(i==5)
            FilterName='Passport-Upload';
        else if(i==6)
            FilterName='Booking-Form';
        else if(i==7)
            FilterName='LoI';
         else if(i==8)
            FilterName='Agreement';
         else if(i==9)
            FilterName='Others';
         else if(i==10)
            FilterName='Sale-Deed';
        action.setParams({  
            "recordId": component.get("v.recordId"),
            "filterName":FilterName
        });      
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){ 
                var result = response.getReturnValue(); 
                console.log(result);
                result.forEach(element => console.log(element.SystemModstamp=new Date(element.SystemModstamp).toLocaleDateString('en-GB')));
                if(i==0) 
                    component.set("v.PanCard",result);
                else if(i==1)
                    component.set("v.AadarCard",result); 
                
                else if(i==2)
                    component.set("v.GSTcertificate",result); 
                
                else if(i==3)
                    component.set("v.incorporationcertification",result); 
                else if(i==4)
                    component.set("v.Registrationcertificate",result); 
                else if(i==5)
                    component.set("v.CompanyPAN",result); 
                else if(i==6)
                    component.set("v.DirectorsPAN",result); 
                else if(i==7)
                    component.set("v.LOI",result); 
                 else if(i==8)
                    component.set("v.Agreement",result); 
                 else if(i==9)
                    component.set("v.Others",result); 
                else if(i==10)
                    component.set("v.SaleDeed",result); 
            }
        });  
        
        $A.enqueueAction(action);  
    },
     getstatus:function(component, event,helper)
    {
        var action = component.get("c.leadststus");   
        action.setParams({
            "recordId":  component.get('v.recordId'),
        }); 
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){ 
                 component.set("v.Status",response.getReturnValue()); 
                  }
        });  
       $A.enqueueAction(action);    
    },
})