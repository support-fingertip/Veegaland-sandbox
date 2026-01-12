({
    addOppProductRecord : function(component, event,id) {
        var action=component.get("c.Rcitemlist");
        // alert(id);
        action.setParams({'recid':  component.get('v.recordId') })
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS" ){ 
                // alert(state)
                var db = response.getReturnValue();
                //alert(JSON.stringify(db.rcList))
                if(db.rcList !=''){
                    component.set('v.recptItemList', db.rcList );
                    
                    // component.set('v.GrandTotal',db.grandTotal)
                }
            }	
        });
        $A.enqueueAction(action); 
    },
    addProductRecord: function(component, event) {
        var productList = component.get("v.recptItemList");
        //alert('Test 1');
        productList.push({
            'sobjectType': 'Receipt_Line_Item__c',
            'Payment_schedule__c': '',
            'Mode_of_Payment__c': '',
            'Name': '',
            'Payment_Type__c':'',
            'Cheque_no_Transaction_Number__c':'',
            'Received_Amount__c': '',
            'Payment_From__c':'',
            'Bank_Name__c':''
            
            
        });
        component.set("v.recptItemList", productList);
    },
    showToastMessage : function(title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type":type,
            "message":  message
        });
        toastEvent.fire();
    },
    updateInputDisabledState: function(component) {
        var pendingAmount = component.get("v.pendingAmount");
        var receiptType = component.get("v.receiptType");
        var paymentType = component.get("v.paymentType");
        
        // Check if the conditions are met to disable the input field
        if (pendingAmount === 0 && receiptType === "Normal Receipt" && paymentType === "Payment Schedules") {
            component.set("v.isAmountDisabled", true);
            component.set("v.receivedAmount",0);
        } else {
            component.set("v.isAmountDisabled", false);
        }
    },
    calculateTotalHelper: function(component,helper) {
        try{
            var type = component.get('v.receiptType');
            var receivedAmount = parseFloat(component.get("v.receivedAmount"));
            var advanceReceiptRows = component.get("v.advanceReceiptRow");    
            var interestAmount = parseFloat(component.get("v.interestPending") || 0);
            var pendingAmount = parseFloat(component.get("v.pendingAmount") || 0);
            var totalAmountFromRows=0;
            var balanceAmount =0;
            var totalReceivedAmount = 0 ; 
            
            if(type == 'Normal Receipt'){  
             totalReceivedAmount = parseFloat(receivedAmount);
                // Calculate the balanceAmount by subtracting totalAmount from pendingAmount
                var balanceAmount = (pendingAmount - totalReceivedAmount )> 0? (pendingAmount - totalReceivedAmount):0;
                
                /*  
            // Check if the total amount exceeds the pendingAmount + interestPending
            if (totalAmount > pendingAmount) {
                var excessAmount = totalAmount - pendingAmount; // Calculate excess amount
                
                // Check if the excess amount is less than or equal to interestPending
                if (excessAmount <= interestAmount) {
                    // Assign the excess amount to receivedInterestAmount
                    component.set("v.receivedInterestAmount", excessAmount);
                } else {
                    // Show error toast if the excess amount exceeds the interestPending
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "Received amount exceeds Pending Amount and Interest Pending limit.",
                        "type": "error"
                    });
                    toastEvent.fire();
                }
                */
            
        }else if(type == 'From Advance Receipt'){

            advanceReceiptRows.forEach(function(record){ 
                if(record.Amount){
                    if(record.Amount > record.AdvanceAmountN){
                        record.Amount = record.AdvanceAmountN;
                    }
                    totalAmountFromRows+=parseFloat(record.Amount);
                    if(totalAmountFromRows > pendingAmount){
                        totalAmountFromRows-=parseFloat(record.Amount);
                        record.Amount =0;
                        this.showToastMessage("Error","Total advance amount should be less than equal to pending amount .","error");
                    }
                    record.balanceAmount = parseFloat(record.AdvanceAmountN) -  parseFloat(record.Amount) ;
                    record.usedAmount = parseFloat(record.Amount);
                }
            });
            totalReceivedAmount = parseFloat(totalAmountFromRows);
            
            
        }else if(type == 'Advance Receipt'){
            pendingAmount =0;
            totalReceivedAmount = parseFloat(receivedAmount);
        }

            component.set('v.advanceReceiptRow',advanceReceiptRows);
            if(type != 'Advance Receipt')
            balanceAmount = parseFloat(pendingAmount) - parseFloat(totalReceivedAmount);
            component.set('v.totalReceivedAmount',totalReceivedAmount); 
            component.set('v.totalBalanceAmount',balanceAmount); 

            // Check if balance amount is greater than zero and update advancedisable flag
            if (balanceAmount <= 0) {
                component.set("v.advancedisable", true);
            } else {
                component.set("v.advancedisable", false);
            }
             if(totalReceivedAmount > 1){
                component.set("v.dsableCreateReceipt", false);
            }else{
                component.set("v.dsableCreateReceipt", true);   
            }
          
              if (totalReceivedAmount > pendingAmount  && type != 'Advance Receipt') {
                this.showToastMessage("Error","Received amount exceeds Pending Amount .","error");
                  component.set("v.dsableCreateReceipt", true);
            }
           
        }catch(e){
            console.error(e.message());
        }
    },
    // Helper function to show toast message
    
})