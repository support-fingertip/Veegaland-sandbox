({
    doInit: function(component, event, helper) {
        // Project Value
        var proj=component.get("c.getPicklistValues");
        proj.setParams({'objectName':  'Lead' ,
                        'fieldName': 'Allocated_Project__c'});
        proj.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){ 
                var prval = response.getReturnValue();
                component.set("v.projectlist",prval);
            }
        });
        $A.enqueueAction(proj);
        
        
        
        // helper.getPlots(component, event, helper);
        //  alert(component.get('v.projectlist'))
        
        // Unit type value
        var Val=component.get("c.getPicklistValues");
        Val.setParams({'objectName':  'Plot__c' ,
                       'fieldName': 'BHK_Type__c'});
        Val.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){ 
                var BHKval = response.getReturnValue();
                component.set("v.BHKList",BHKval);
            }
        });
        $A.enqueueAction(Val);
        // Unit facing value
        var Vals=component.get("c.getPicklistValues");
        Vals.setParams({'objectName':  'Plot__c' ,
                        'fieldName': 'Unit_Facing_Direction__c'});
        Vals.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){ 
                var UFval = response.getReturnValue();
                component.set("v.UFList",UFval);
            }
        });
        $A.enqueueAction(Vals);
        // Building value
        var BuilVals=component.get("c.getPicklistValues");
        BuilVals.setParams({'objectName':  'Plot__c' ,
                            'fieldName': 'Building__c'});
        BuilVals.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){ 
                var UFval = response.getReturnValue();
                component.set("v.BuildingList",UFval);
            }
        });
        $A.enqueueAction(BuilVals);
        // Block value
        var BlVals=component.get("c.getPicklistValues");
        BlVals.setParams({'objectName':  'Plot__c' ,
                          'fieldName': 'Block__c'});
        BlVals.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){ 
                var UFval = response.getReturnValue();
                component.set("v.BlockList",UFval);
            }
        });
        $A.enqueueAction(BlVals);
        // floor value
        var flrval=component.get("c.getPicklistValues");
        flrval.setParams({'objectName':  'Plot__c' ,
                          'fieldName': 'Floor__c'});
        flrval.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){
                
                var UFval = response.getReturnValue();
                
                component.set("v.floorList",UFval);
                
            }
        });
        $A.enqueueAction(flrval);
        // Property Type value
        var prtyp =component.get("c.getPicklistValues");
        prtyp.setParams({'objectName':  'Plot__c' ,
                         'fieldName': 'Property_Type__c'});
        prtyp.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){
                
                var UFval = response.getReturnValue();
                
                component.set("v.propertytype",UFval);
                
            }
        });
        $A.enqueueAction(prtyp);
        
        
        // Payment type value
        var action1 = component.get("c.getPaymentTypePicklistValues");
        action1.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var paymentTypePicklist = response.getReturnValue();
                component.set("v.paymentTypePicklist", paymentTypePicklist);
            }
        });
        $A.enqueueAction(action1);
        
        
        component.set('v.mycolumns3', [
            {label: 'Sl No.', fieldName: 'S_No__c', type: 'text',initialWidth: 10},
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Payment Percent', fieldName: 'Payment_percent__c' , type: 'Percent',initialWidth: 15},
            {label: 'Completed Date', fieldName: 'Completed_Date__c', type: 'date',typeAttributes: {
                day: 'numeric',
                month: 'short',
                year: 'numeric',
                
            },initialWidth: 115},
            //{ type: 'action', typeAttributes: { rowActions: actions3 } }
            
        ]);
            
            
            },
            searchText1 : function(component, event, helper) {
            var plot= component.get('v.plots');
            
            var searchText1= component.get('v.searchText1');
            console.log(searchText1.length)
            //var open = component.find("open");
            if(searchText1.length < 1){
            console.log(searchText1)
            //$A.util.toggleClass(open, 'slds-is-open');
            }
            var matchplots=[];
                      if(searchText1 !=''){
            for(var i=0;i<plot.length; i++){ 
                // console.log(plot[i].Name)
                if(plot[i].Name.toLowerCase().indexOf(searchText1.toLowerCase())  != -1  ){
                    
                    if(matchplots.length <50){
                        matchplots.push( plot[i] );
                    }
                    else{
                        break;
                    }
                } 
            } 
            // alert(matchplots)
            if(matchplots.length >0){
                component.set('v.matchplots',matchplots);
                // component.set('v.showqute',true);
            }
        }
        else{
            component.set('v.matchplots',[]);
            component.set('v.showqute',false);
        }
    },
    
    searchText2 : function(component, event, helper) {
        var pymntp= component.get('v.paymentplan');
        
        var searchText= component.get('v.searchText2');
        console.log(searchText.length)
        
        if(searchText.length < 1){
            console.log(searchText)
            //$A.util.toggleClass(open, 'slds-is-open');
        }
        var matchpaymentplan=[];
        if(searchText !=''){
            for(var i=0;i<pymntp.length; i++){ 
                if(pymntp[i].Name.toLowerCase().indexOf(searchText.toLowerCase())  != -1  ){
                    
                    if(matchpaymentplan.length <50){
                        matchpaymentplan.push( pymntp[i] );
                    }
                    else{
                        break;
                    }
                } 
            } 
            // alert(matchpaymentplan)
            if(matchpaymentplan.length >0){
                component.set('v.matchpaymentplan',matchpaymentplan);
                // component.set('v.showqute',true);
            }
        }
        else{
            component.set('v.matchpaymentplan',[]);
            component.set('v.showqute',true);
            
            var selectedValue = component.find("projectSelect").get("v.value");
            // alert(selectedValue);
            
            // getting Payment Plan
            
            var action4=component.get("c.getPyamentPlan");  
            
            action4.setParams({'project':selectedValue});
            action4.setCallback(this,function(response){
                
                if(response.getState()=="SUCCESS"){ 
                    var pymnpln = response.getReturnValue();
                    
                    component.set("v.paymentplan",pymnpln);
                }
            });
            $A.enqueueAction(action4);
            
            
        }
    },
    
    update1: function(component, event, helper) {
        // component.set('v.prjId', event.currentTarget.dataset.id);
        //alert('Update 1'); 
        var edi =  event.currentTarget.dataset.id;
        var plt= component.get('v.matchplots');
        var selPlot= component.get('v.plot');
        var oppPlot = component.get('v.oppPlot');
        //alert(component.get('v.oppPlot'));
        var opp = component.get("v.OppRecord");
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        
        for(var i=0;i<plt.length; i++){  
            
            if(plt[i].Id ===  edi ){
                
                //alert('Update 2 ');
                component.set('v.searchText1', plt[i].Name);
                selPlot = plt[i];
                component.set('v.showqute',true);
                oppPlot.Leads__c=component.get('v.recordId');
                oppPlot.Unit__c = plt[i].Id;
                oppPlot.Project__c = plt[i].Project__r.Project__c;
                
                oppPlot.Quote_date__c =today;
                oppPlot.Projects__c = plt[i].Project__c;
                // oppPlot.Property_Type1__c = plt[i].Project__r.Property_Type__c;
                oppPlot.Plot_Number__c = plt[i].Plot_Number__c;
                oppPlot.Plot_Size__c = plt[i].Plot_Size__c;
                oppPlot.Unit_Facing_Direction1__c = plt[i].Unit_Facing_Direction__c;
                oppPlot.BHK_Type__c = plt[i].BHK_Type__c;
                oppPlot.Basic_Price__c = plt[i].Basic_Price__c;
                oppPlot.Projects__c =  plt[i].Project__c;
                oppPlot.Corner_Facing__c = plt[i].Corner_Facing__c;
                oppPlot.East_Facing__c = plt[i].East_Facing__c;
                oppPlot.Sale_Area__c = plt[i].Sale_Area__c;
                oppPlot.Club_House__c = plt[i].Club_House__c;
                oppPlot.Car_Parking_Charge__c = plt[i].Car_Parking_Charge__c;
                oppPlot.Infrastructure_Charges_per_sqft__c = plt[i].Infrastructure_Charges_per_sqft__c;
                oppPlot.Built_up_area__c = plt[i].Super_built_up_area__c;
                oppPlot.Carpet_Area__c = plt[i].Carpet_Area__c;
                oppPlot.Balcony_Area__c = plt[i].Terrace_Area__c;
                oppPlot.GST__c = plt[i].GST1__c;
                oppPlot.Block__c = plt[i].Block__c;
                oppPlot.Building__c = plt[i].Building__c;
                oppPlot.Floor_Rise_Charges__c = plt[i].Floor_Rise__c;
                oppPlot.Landscape_Charge__c = plt[i].Landscape_Charge__c;
                oppPlot.Floor__c = plt[i].Floor__c;
                oppPlot.Terrace_Area_SqFt__c = plt[i].Terrace_Area_SqFt__c;
                oppPlot.Garden_Area_SqFt__c = plt[i].Garden_Area_SqFt__c;
                oppPlot.Land_Plot_Area_SqFt__c = plt[i].Land_Plot_Area_SqFt__c;
                oppPlot.Common_Area_SqFt__c = plt[i].Common_Area_SqFt__c;
                oppPlot.RERA_Area_SqFt__c = plt[i].RERA_Area_SqFt__c;
                oppPlot.Open_Terrace_Area_Charges__c = plt[i].Open_Terrace_Area_Charges__c;
                oppPlot.Property_Type__c = plt[i].Property_Type__c;
                oppPlot.No_of_Back_to_Back_Car_Parking__c = plt[i].No_of_Back_to_Back_Car_Parking__c;
                oppPlot.No_of_Individual_Car_Parking__c = plt[i].No_of_Indivisual_Car_Parking__c;
                oppPlot.No_of_Extra_Back_to_Back_Car_Parking__c = 0;
                oppPlot.No_of_Extra_Individual_Car_Parking__c = 0;
                oppPlot.Extra_car_parking_charges__c = 0;
                oppPlot.Discount_In_Rupees__c = 0;
                oppPlot.Special_Launch__c = false;
                
                var totalBasicPrice = (oppPlot.Floor_Rise_Charges__c + oppPlot.Basic_Price__c) * oppPlot.Built_up_area__c;
                component.set('v.totalBasicPrice', totalBasicPrice);
                // Calculate the GST amount
                var parkingCharge = oppPlot.Car_Parking_Charge__c || 0;
                var landScapeCharges = oppPlot.Landscape_Charge__c || 0;
                var openTAC = oppPlot.Open_Terrace_Area_Charges__c || 0 ;
                var subTotal = totalBasicPrice + oppPlot.Extra_car_parking_charges__c + parkingCharge + landScapeCharges + openTAC;
                var gstAmount = subTotal * (oppPlot.GST__c / 100);
                component.set('v.gstAmount',gstAmount);
                // Set the total flat cost (Basic Price + GST)
                component.set('v.totalFlatCost', subTotal + gstAmount);
                
                component.set('v.today', today);
                component.set('v.RecTypeId',plt[i].Name);
                
                break;
            } 
        } 
        component.set('v.plot', selPlot);
        component.set('v.oppPlot',oppPlot);
        
        component.set('v.matchplots',[]);
        
    },
    update2 : function(component, event, helper) {
        
        var edi =  event.currentTarget.dataset.id;
        var plt= component.get('v.matchpaymentplan');
        var selPlot= component.get('v.paymentplan');
        var oppPlot = component.get('v.oppPlot');
        //  alert(component.get('v.oppPlot')+'--'+edi);
        var opp = component.get("v.OppRecord");
        
        for(var i=0;i<plt.length; i++){  
            
            if(plt[i].Id ===  edi ){
                component.set('v.searchText2', plt[i].Name);
                selPlot = plt[i];
                //  alert(JSON.stringify(plt[i])+'---'+edi)
                oppPlot.Payment_Plan__c = plt[i].Id;
                break;
            }
        }
        component.set('v.paymentplan', selPlot);
        component.set('v.oppPlot',oppPlot);
        //alert(JSON.stringify(component.get('v.oppPlot')))
        component.set('v.matchpaymentplan',[]);
    },
    doSave: function(component,event,helper) {
        component.set('v.showSave',false);
        // debugger;
        helper.save(component,event,helper);
        
    },
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        //  component.set("v.isModalOpen", false);
        // history.back();
        $A.get("e.force:closeQuickAction").fire();   
    },
    handleCheckboxChange : function(component, event, helper) {
        var checkboxValue = component.find("checkbox").get("v.checked");
        component. set("v.isCheckboxChecked",checkboxValue);
        //  alert(checkboxValue);
        
    },
    handleSpecialLaunchChange : function(component, event, helper) {
        var checkboxValue = component.find("checkbox1").get("v.checked");
        component.set("v.isSpecialLaunch", checkboxValue);
        
    },
    navigateToPaymentSchedule: function (component, event, helper) {
        if (helper.validate(component, event)) {
            component.set("v.showNextCmp", true);
            
            helper.getFilteredLead(component,event,helper);
        }
        // helper.addOppProductRecord(component, event,helper);
    },
    navigateToCreateQuote: function (component, event, helper) {
        component.set("v.showNextCmp", false);
        
    },
    
    handleProjectChange: function(component, event, helper) {
        
        var selectedValue = component.find("projectSelect").get("v.value");
        //alert(selectedValue)
        var action=component.get("c.getPlots");  
        
        action.setParams({'project':selectedValue});
        action.setCallback(this,function(response){
            
            if(response.getState()=="SUCCESS"){ 
                var plots = response.getReturnValue();
                
                console.log('plots:'+plots);
                component.set("v.plots",plots);
                
                // getting Payment Plan
                
                var action4=component.get("c.getPyamentPlan");  
                
                action4.setParams({'project':selectedValue});
                action4.setCallback(this,function(response){
                    
                    if(response.getState()=="SUCCESS"){ 
                        var pymnpln = response.getReturnValue();
                        
                        component.set("v.paymentplan",pymnpln);
                    }
                });
                $A.enqueueAction(action4);
                
            }
        });
        $A.enqueueAction(action);
    },
    
    handleChangeValues: function(component, event, helper) {
        var oppPlot = component.get('v.oppPlot');
        
        // Ensure all fields are treated as numbers (use `parseFloat()` to handle decimals)
        var floorRise = parseFloat(oppPlot.Floor_Rise_Charges__c) || 0;
        var basePrice = parseFloat(oppPlot.Basic_Price__c) || 0;
        var builtUpArea = parseFloat(oppPlot.Built_up_area__c) || 0;
        var carParkingCharge = parseFloat(oppPlot.Car_Parking_Charge__c) || 0;
        var extraCarParkingCharge = parseFloat(oppPlot.Extra_car_parking_charges__c) || 0;
        var landscapeCharges = parseFloat(oppPlot.Landscape_Charge__c) || 0;
        var openTAC = parseFloat(oppPlot.Open_Terrace_Area_Charges__c) || 0;
        var gstPercentage = parseFloat(oppPlot.GST__c) || 0;
        var discount = parseFloat(oppPlot.Discount_In_Rupees__c) || 0;
        
        if( discount > 0){
            basePrice -= discount;
        }
        // Calculate the base value (sum of floor rise and base price)
        var base = floorRise + basePrice;
        console.log('Base (Floor Rise + Base Price): ' + base);
        
        // Calculate the total basic price
        var totalBasicPrice = base * builtUpArea;
        console.log('Total Basic Price: ' + totalBasicPrice);
        component.set('v.totalBasicPrice', totalBasicPrice);
        
        // Calculate the subtotal (including extra charges)
        var subTotal = totalBasicPrice + extraCarParkingCharge + carParkingCharge + landscapeCharges + openTAC;
        console.log('Subtotal: ' + subTotal);
        
        // Calculate the GST amount
        var gstAmount = subTotal * (gstPercentage / 100);
        console.log('GST Amount: ' + gstAmount);
        component.set('v.gstAmount', gstAmount);
        
        // Set the total flat cost (Basic Price + GST)
        var totalFlatCost = subTotal + gstAmount;
        console.log('Total Flat Cost: ' + totalFlatCost);
        component.set('v.totalFlatCost', totalFlatCost);
    }
    
    
})