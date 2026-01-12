({
    doInit : function(component, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        $A.get("e.force:closeQuickAction").fire();
        window.open('https://site-speed-6226.my.salesforce-sites.com/pdf/VeegalandQuotePdfMobile?Id='+component.get("v.recordId")+'&userId='+userId+'', '_blank');
        /*setTimeout(function(){
            $A.get("e.force:closeQuickAction").fire();
        }, 500); */
        /*console.log(component.get("v.recordId"));
        var action = component.get("c.getformat");
        action.setParams({
            'InvId': component.get("v.recordId"),
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                var storeResponse = a.getReturnValue();
                if(storeResponse!==null){
                    console.log(component.get("v.POS"));
                    component.set("v.POS",storeResponse);
                    $A.get("e.force:closeQuickAction").fire();
                    if(component.get("v.POS")){
                        window.open('https://sbox1-aloobdryfruitssinsarpvtltd.cs73.force.com/invoice/InvoicePDFVF?Id='+component.get("v.recordId")+'', '_blank');
                    } else {
                        window.open('https://sbox1-aloobdryfruitssinsarpvtltd.cs73.force.com/invoice/InvoicePDFNONPOS?Id='+component.get("v.recordId")+'', '_blank');
                    }
                }
            }
        }); 
        $A.enqueueAction(action);*/
    },
    close : function(component, event, helper) {
        window.history.go(-2)
    },
    printPage : function(component, event, helper){
        window.print();
    }
})