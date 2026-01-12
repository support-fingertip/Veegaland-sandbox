({
    doInit : function(component,event,helper)
    {
        var id=component.get('v.recordId');
        //alert('called');
        var advanceAmountQuery = "Booking__c ='"+component.get('v.recordId')+"'";
        component.set('v.advanceAmountQuery',advanceAmountQuery);
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.receiptDate',today);
        var rcpt = component.get("v.rcpt");
        rcpt.Receipt_date__c = today;
        component.set("v.rcpt", rcpt);
        var recpName = component.get('v.receiptName');
        rcpt.Receipt_Name__c = recpName;
        if(recpName = 'Booking Amount Receipt'){
            component.set("v.isDisabled", true);
        }
        helper.addProductRecord(component, event,id);
        //helper.addOppProductRecord(component, event,id);
        var action=component.get("c.getpaymentsc");
        action.setParams({'recid':  component.get('v.recordId') })
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){ 
                var datas=response.getReturnValue();
                //alert(JSON.stringify(datas.pysch))
                component.set('v.paymentschdl',  datas.pysch);
            }
        });
        
        $A.enqueueAction(action); 
        var action1 = component.get("c.getPaymentTypePicklistValues");
        action1.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var paymentTypePicklist = response.getReturnValue();
                component.set("v.paymentTypePicklist", paymentTypePicklist);
                // alert(JSON.stringify(component.get("v.paymentTypePicklist")))
            }
        });
        $A.enqueueAction(action1);
        
        var action2 = component.get("c.getBookingDetails");
        action2.setParams({'recid':  component.get('v.recordId') })
        action2.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var db = response.getReturnValue();
                console.log('db '+ JSON.stringify(db));
                component.set("v.projectName", db.Project__c);
                component.set("v.flatNumber", db.Unit_NumberFor__c);
                component.set("v.pendingAmount", db.Pending_Amount__c);
                var formattedFlatCost = new Intl.NumberFormat('en-IN', {
                    style: 'currency',
                    currency: 'INR'
                }).format(db.Total__c || 0);
                
                
                component.set("v.FlatCost",formattedFlatCost);
                
                var formattedPending = new Intl.NumberFormat('en-IN', {
                    style: 'currency',
                    currency: 'INR'
                }).format(db.Pending_Amount__c || 0);
                
                component.set("v.bookingPendingAmount",formattedPending);
                
            }
        });
        $A.enqueueAction(action2);
        
        var action3 = component.get("c.getInterestAmount");
        action3.setParams({ 'recId' : component.get('v.recordId')})
        action3.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue();
                component.set('v.interestAmount',result);
                component.set("v.interestPending",result);

            }
        })
        
        var action4 = component.get("c.getPaymentSchedules");
        action4.setParams({
            bookingId: component.get('v.recordId')
        });
        
        // Handle the response from the Apex method
        action4.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state'+state);
            if (state === "SUCCESS") {
                console.log('schedules'+JSON.stringify(response.getReturnValue()));
                var schedules = response.getReturnValue();
                component.set("v.paymentScheduleOptions", schedules);
                
            } else {
                console.log('Error:', response.getError());
            }
        });
        
        $A.enqueueAction(action4);
        
        var action5 = component.get("c.getAdvanceReceipts");
        action5.setParams({
            bookingId: component.get('v.recordId')
        });
        
        // Handle response from Apex method
        action5.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var receipts = response.getReturnValue();
                
                // Format the AdvanceAmount and calculate usedAmount
                var formattedReceipts = receipts.map(function(receipt) {
                    receipt.AdvanceAmountString = new Intl.NumberFormat('en-IN', {
                        style: 'currency',
                        currency: 'INR'
                    }).format(receipt.AdvanceAmount || 0); // Format Advance Amount
                    
                    // Initialize usedAmount if not already available, else use it
                    receipt.usedAmount = 0;
                    receipt.used = false;
                    return receipt;
                });
                
                // Set the formatted receipts with AdvanceAmount and usedAmount to component
                component.set("v.advanceReceiptOptions", formattedReceipts);
                console.log('formattedReceipts '+JSON.stringify(formattedReceipts));
            } else {
                console.log('Error:', response.getError());
            }
        });
        
        $A.enqueueAction(action5);
    },
    searchText : function(component, event, helper) {
        var pymntsc= component.get('v.paymentschdl');
        var searchText= component.get('v.searchText');
        
        var matchprds=[];
        if(searchText !=''){
            for(var i=0;i<pymntsc.length; i++){ 
                if(pymntsc[i].Name.toLowerCase().indexOf(searchText.toLowerCase())  != -1  ){
                    matchprds.push( pymntsc[i] );
                } 
            } 
            if(matchprds.length >0){
                component.set('v.matchpaymentschdl',matchprds);
            }
        }else{
            component.set('v.matchpaymentschdl',[]);
        }
        
    },
    update : function(component, event, helper) {
        component.set("v.savebuttonhide",true);
        component.set('v.spinner', true);
        
        var index = event.currentTarget.dataset.record;
        var pid =event.currentTarget.dataset.id;
        var prds= component.get('v.matchpaymentschdl');
        var oitems= component.get('v.recptItemList');
        //  alert(index+'--'+pid+'---'+prds+'----'+oitems)
        for(var i=0;i<prds.length; i++){ 
            if(prds[i].Id === pid ){
                oitems[index].Payment_schedule__c = prds[i].Id;
                oitems[index].Name = prds[i].Name;
                oitems[index].Amount__c = prds[i].Pending_Amount__c;
                
                component.set('v.searchText', '');
                break;
            }
            
        } 
        component.set('v.recptItemList',oitems);
        component.set('v.matchpaymentschdl',[]);
        component.set('v.spinner', false);
        
    },
    
    
    ChangeName : function(component, event, helper)
    {
        component.set("v.savebuttonhide",true);
    },
    addRow: function(component, event, helper) {
        component.set("v.savebuttonhide",true);
        helper.addProductRecord(component, event);
    },
    removeRow: function(component, event, helper) {
        component.set("v.savebuttonhide",false);
        
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        
        var oitems= component.get('v.recptItemList');
        if(oitems[index].Id !='undefined' && oitems[index].Id !=''){
            var action=component.get("c.deleteProduct");
            action.setParams({'prId':  oitems[index].Id  })
            action.setCallback(this,function(response){
                
                if(response.getState() == "SUCCESS"){ 
                    
                    oitems.splice(index, 1);
                    component.set("v.recptItemList", oitems);
                    
                    if(oitems.length < 1){
                        helper.addProductRecord(component, event);
                    }
                }
            });
            $A.enqueueAction(action);
        }
        
        
    },
    saveReceipt: function(component, event, helper) {
        try{
        let totalReceivedAmount = component.get("v.totalReceivedAmount");
        let pendingAmount = component.get("v.pendingAmount");
        let interestPending = component.get("v.interestPending");
        console.log('totalReceivedAmount '+totalReceivedAmount);
        if (totalReceivedAmount > (pendingAmount + interestPending)) {
            $A.get("e.force:showToast").setParams({
                "title": "Error",
                "message": "Total Received Amount cannot be greater than milestone pending amount",
                "type": "error"
            }).fire();
            return;
        }
        
        let isBankValid = true;
        let recptList = component.get("v.recptItemList");
        if (recptList && recptList.length > 0 && !recptList[0].Bank_Name__c) {
            var cmpA = component.find("pickVal");
            if(cmpA) {
                isBankValid = cmpA.handleCheckRequired();
            }
        }
        
        let isAllValid = component.find('field').reduce(function(isValidSoFar, inputCmp){
            inputCmp.showHelpMessageIfInvalid();
            return isValidSoFar && inputCmp.checkValidity();
        },true);
        
        if(isAllValid == true && isBankValid == true){
            // Collecting all the required field values from the component
            var recordId = component.get("v.recordId");
            var receiptDate = component.get("v.receiptDate");
            var remarks = component.get("v.Remarks");
            var paymentFrom = component.get("v.Payment_From");
            var modeofPayment = component.get("v.modeOfPayment");
            var bankName = component.get("v.bankName");
            var branch = component.get("v.Branch");
            var receiptType = component.get("v.receiptType");
            var paymentType = component.get("v.paymentType");
            var selectedScheduleId = component.get("v.selectedScheduleId");
            var receivedAmount = component.get("v.totalReceivedAmount") ;
            var advanceReceiptRow = component.get("v.advanceReceiptRow");
            var advanceReceiptRowJSON = JSON.stringify(advanceReceiptRow);
            console.log('advanceReceiptRowJSON'+advanceReceiptRowJSON);
            var transactionNumber = component.get("v.transactionNumber");
            var AmountFromCustomers = component.get("v.receivedAmount");
            var interestAmount = component.get("v.receivedInterestAmount") || 0;
            // Create a data object to pass
            var receiptData = {
                recordId: recordId,
                receiptDate: receiptDate,
                remarks: remarks,
                paymentFrom: paymentFrom,
                modeofPayment: modeofPayment,
                bankName: bankName,
                branch: branch,
                receiptType: receiptType,
                paymentType: paymentType,
                selectedScheduleId: selectedScheduleId,
                receivedAmount: receivedAmount,
                advanceReceiptRow: advanceReceiptRowJSON,
                transactionNumber:transactionNumber,
                amountFromCustomer:AmountFromCustomers,
                receivedInterestAmount: interestAmount
            };
            
            // Serialize the data to JSON
            var receiptDataJSON = JSON.stringify(receiptData);
           
            // Call the Apex method to save the receipt and perform other operations
            var action = component.get("c.saveManualReceipt");
            action.setParams({
                receiptData: receiptDataJSON  // Passing the serialized JSON string
            });
            
            // Handle response from Apex
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    //alert('h');
                    var result = response.getReturnValue();
                    // Handle success response here (e.g., show toast message)
                    $A.get("e.force:showToast").setParams({
                        "title": "Success",
                        "message": "Receipt saved successfully",
                        "type": "success"
                    }).fire();
                    
                    var navigateToRecordEvent = $A.get("e.force:navigateToSObject");
                    navigateToRecordEvent.setParams({
                        "recordId": result,
                        "slideDevName": "detail"
                    });
                    navigateToRecordEvent.fire(); 
                    
                } else {
                    alert(response.getError());
                    // Handle error response here (e.g., show error toast message)
                    console.error("Error in saving receipt", response.getError());
                    $A.get("e.force:showToast").setParams({
                        "title": "Error",
                        "message": "Failed to save receipt",
                        "type": "error"
                    }).fire();
                }
            });
            
            // Send request to the Apex controller
            $A.enqueueAction(action);
        }
            }catch(e){
            console.error(e.message());
        }
    },
    quoteSave: function(component,event,helper) {
        
        let isBankValid = true;
        let recptList = component.get("v.recptItemList");
        if (recptList && recptList.length > 0 && !recptList[0].Bank_Name__c) {
            var cmpA = component.find("pickVal");
            if(cmpA) {
                isBankValid = cmpA.handleCheckRequired();
            }
        }
        
        let isAllValid = component.find('field').reduce(function(isValidSoFar, inputCmp){
            inputCmp.showHelpMessageIfInvalid();
            return isValidSoFar && inputCmp.checkValidity();
        },true);
        
        
        console.log('isBankValid '+isBankValid+' isAllValid'+isAllValid);
        if(isAllValid == true && isBankValid == true){
            component.set("v.savebuttonhide",true);
            var ponum=component.get("v.rcpt.Receipt_Name__c"); 
            var reark = component.get("v.rcpt.Remarks__c"); 
            var oit= component.get('v.recptItemList');
            //alert('Inside Save Method');
            var tarik=component.get("v.rcpt.Receipt_date__c");
            var action = component.get("c.insertReceiptLineItems");
            //   alert('Hello');
            action.setParams({
                'polist' : component.get('v.recptItemList'),
                'pon' : ponum,
                'remark':reark,
                'poc' : tarik,
                'PaymentFrom': component.get('v.Payment_From'),
                'recid':  component.get('v.recordId'),
                'paidAmount' : component.get('v.receivedAmount'),
                'interestAmount' : component.get('v.receivedInterestAmount'),
                
                'branch' : component.get('v.Branch')
            });
            action.setCallback(this, function(response) {
                var state = response.getState();      
                //alert(state);
                console.log('state'+state);
                if (state === "SUCCESS") {
                    
                    var ttu=response.getReturnValue();
                    helper.showToast("Success","Receipt has been created succesfully","Success");
                    $A.get('e.force:refreshView').fire();
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/"+ttu
                    });
                    urlEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }
                else{
                    var errors = response.getError();
                    console.log('state'+ JSON.stringify(errors));
                    helper.showToast( errors[0].message, "Error");
                }
            });
            $A.enqueueAction(action);
        }
        else{
            helper.showToast("Please fill all mandatory fields","Error");
        }
        
        
        // $A.get('e.force:refreshView').fire();
    },
    quoteCancel:function(component, event, helper) {
        component.set("v.savebuttonhide",false);
        component.set("v.recptItemList", []);
        
        component.set("v.matchpaymentschdl", []);
        component.set("v.paymentschdl", []);
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get('v.recordId'),
            "slideDevName": "detail"
        });
        navEvt.fire();
        
    },
    
    getGrandTotal : function(component, event, helper) {
        component.set("v.savebuttonhide",true);
        var index = event.currentTarget.dataset.record;
        var oitems= component.get('v.recptItemList');
        var paymententered = component.get('v.receivedAmount');
        var bookPendingAmount = component.get('v.bookingPendingAmount');
        /*if (parseFloat(paymententered) > parseFloat(bookPendingAmount)) {
                helper.showToast("Received Amount cannot exceed the Maximum Pending Amount", "error");
            	component.set('v.receivedAmount',bookPendingAmount);
            }*/
        component.set('v.newPendingAmount',(parseFloat(bookPendingAmount) - parseFloat(component.get('v.receivedAmount'))));            
        component.set('v.recptItemList',oitems);
        
        var grandtotal = 0;
        var pendingtotal = 0;
        var oit= component.get('v.recptItemList');
        for(var i=0;i<oit.length; i++){ 
            grandtotal = (parseFloat(grandtotal)+parseFloat(oit[i].Received_Amount__c));
        }
        for(var i=0;i<oit.length; i++){ 
            pendingtotal = (parseFloat(pendingtotal)+parseFloat(oit[i].Pending_Amount__c));
        }
        
        
        component.set('v.totalrcvdAmount',component.get('v.receivedAmount'));
        component.set('v.totalPending',component.get('v.newPendingAmount'));
        
    },
    
    onChangeReceiptType: function (component, event, helper){
        var type = component.get('v.receiptType');
        console.log('type '+type);
    },
    handleScheduleChange: function(component, event, helper) {
        //var selectedScheduleId = event.getSource().get("v.value");
        //component.set("v.selectedScheduleId", selectedScheduleId);
        
        // Find the selected payment schedule and update the pending amount
        //var schedules = component.get("v.paymentScheduleOptions");
       /* var selectedSchedule = schedules.find(function(schedule) {
            return schedule.Id === selectedScheduleId;
        });
        
        if (selectedSchedule) {
            component.set("v.interestPending", selectedSchedule.InterestPending);
            component.set("v.pendingAmount", selectedSchedule.PendingAmount);
            
        }*/
        helper.updateInputDisabledState(component);
        helper.calculateTotalHelper(component);
    },
    addRow: function(component, event, helper) {
        // Get the advanceReceiptOptions
        let receipts = component.get("v.advanceReceiptOptions");
        
        // Find the first unused receipt
        let unusedReceipt = receipts.find(function(receipt) {
            return !receipt.used; // Find the first unused receipt
        });
        
        // If no unused receipt is available, show error
        if (!unusedReceipt) {
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error",
                "message": "No more Advance Amount left",
                "type": "error"
            });
            toastEvent.fire();
            return; // Exit the function if no unused receipts are left
        }
        
        unusedReceipt.used = true;
        let newRow = {
            ReceiptId: unusedReceipt.Id,
            PreviousId:unusedReceipt.Id,
            AdvanceAmount: unusedReceipt.AdvanceAmountString,
            AdvanceAmountN:unusedReceipt.AdvanceAmount,
            balanceAmount:unusedReceipt.AdvanceAmount,
            Amount: 0
        };
        let rows = component.get("v.advanceReceiptRow");
        rows.push(newRow);
        component.set("v.advanceReceiptRow", rows);
    },
      handleReceiptChange: function(component, event, helper) {
          
        let selectedReceiptId = event.getSource().get("v.value");
        let selectedOldId = event.getSource().get("v.name");
          
        console.log('selectedReceiptId '+selectedReceiptId);
        console.log('selectedOldId '+selectedOldId);
          
        let receipts = component.get("v.advanceReceiptOptions");
          
        let selectedReceipt = receipts.find(function(receipt) {
            return receipt.Id === selectedReceiptId;
        });
        
        let removedReceipt = receipts.find(function(receipt) {
            return receipt.Id === selectedOldId;
        });
        
        if (selectedReceipt) {
            selectedReceipt.used = true;
        }
        
        if (removedReceipt) {
            removedReceipt.used = false;
        }
        
        let rows = component.get("v.advanceReceiptRow");
        
        let existingIndex = rows.findIndex(function(row) {
            return row.ReceiptId === selectedReceiptId;
        });
          
          console.log('existingIndex '+existingIndex);
          if (existingIndex !== -1) {
              rows.splice(existingIndex, 1);
          }
          
          let oldIndex = rows.findIndex(function(row) {
              return row.ReceiptId === selectedOldId;
          });
           console.log('oldIndex '+oldIndex);
          if (oldIndex !== -1) {
              rows.splice(oldIndex, 1);
          }
          
        let newRow = {
            ReceiptId: selectedReceipt.Id,
            PreviousId:selectedReceipt.Id,
            AdvanceAmount: selectedReceipt.AdvanceAmountString,
            AdvanceAmountN: selectedReceipt.AdvanceAmount,
            balanceAmount: selectedReceipt.AdvanceAmount,
            Amount: 0
        };
        
        rows.push(newRow);
          component.set("v.advanceReceiptRow", rows);
    },
    removeRowItem: function(component, event, helper) {
         console.log('selectedId ');
        let selectedId = event.currentTarget.name;
        console.log('selectedId '+selectedId);
        let receipts = component.get("v.advanceReceiptOptions");
          
        let removedReceipt = receipts.find(function(receipt) {
            return receipt.Id === selectedId;
        });
        if (removedReceipt) {
            removedReceipt.used = false;
        }
        let rows = component.get("v.advanceReceiptRow");
        
        let existingIndex = rows.findIndex(function(row) {
            return row.ReceiptId === selectedId;
        });
        
        if (existingIndex !== -1) {
            rows.splice(existingIndex, 1);
        }
        
        component.set("v.advanceReceiptRow", rows);
        helper.calculateTotalHelper(component);
    },

   handleAmountChange: function(component, event, helper) {
        // Calculate the total after the change
    helper.calculateTotalHelper(component,event,helper);
 /*   // Get the amount value and row index from the event source
    const amountValue = event.getSource().get("v.value");
    const rowIndex = event.getSource().get("v.name");

    // Retrieve rows and current row based on index
    const rows = component.get("v.advanceReceiptRow");
    const currentRow = rows[rowIndex];

    // Update current row with new values
    currentRow.Amount = amountValue;
    currentRow.balanceAmount = currentRow.AdvanceAmountN - amountValue;

    // Set the updated values to ensure the component is aware of the changes
    component.set("v.advanceReceiptRow", rows);

    // Extract the used amount from current row
    const usedAmount = currentRow.Amount;

    // Retrieve advance receipt options
    const receiptOptions = component.get("v.advanceReceiptOptions");
    
    // Find the selected receipt based on current row's ReceiptId
    const selectedReceipt = receiptOptions.find(receipt => receipt.Id === currentRow.ReceiptId);
    if (selectedReceipt) {
        selectedReceipt.usedAmount = usedAmount;
    }

    // Set the updated receipt options to ensure the component is aware of the changes
    component.set("v.advanceReceiptOptions", receiptOptions);
*/
   
},
    
  
    
    handleTotalAmount: function(component, event, helper) {
        helper.calculateTotalHelper(component);
    },
    changePaymentFrom: function(component, event, helper) {
       var paymentFrom = component.get('v.Payment_From'); 
        if(paymentFrom =='Advance Receipt'){
            component.set('v.receiptType','From Advance Receipt');
         component.set('v.disableReceiptType',true);
        }else{
            component.set('v.receiptType',''); 
             component.set('v.disableReceiptType',false);
        }
    },
 
})