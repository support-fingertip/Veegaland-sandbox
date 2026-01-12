({
	doInit : function(component, event, helper) {
        component.set('v.showSpinner',true);
        helper.getProjectPickListValue(component,event, helper);
        helper.getUsers(component,event, helper);
        //helper.getData(component, event, helper);
        helper.getPicklistValues(component, event, helper);
        helper.getProject(component, event, helper);
        //=============Helper for Data Table================
        //helper.columnsandquickactions(component);
        //helper.getOpportunityList(component);
        //helper.totalopportunity(component);  
        
        //==================================================
        //=============Helper for Pagination================
        helper.fetchAccounts(component, helper);  
        
        //==================================================
        const prfName = component.get('v.CurrentUser.Profile.Name');
        if(prfName == 'SALES EXECUTIVE' || prfName == 'System Administrator')
        {
            component.set('v.UserProfile',true);
        }
        
	},
    handleSelectedRow :function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        var NoofRows = selectedRows.length;
        //alert(NoofRows);   
    },
    RowAction: function (component, event, helper) {
        var action = event.getParam('action');
        switch (action.name){ 
            case 'New': alert(action.name)
            break;
            case 'edit':alert(action.name)
            break;
            case 'delete': alert(action.name)
            break;
            case 'view':alert(action.name)
            break; 
            default: alert('Salesforce');
        }
    },
    LoadMore:function (component, event, helper) {
        event.getSource().set("v.isLoading", true);
        var recordLimit = component.get("v.initRows");
        var action = component.get("c.getLead");
        action.setParams({
            "Limits": recordLimit,
        });
        action.setCallback(this, function(response) {          
            var state = response.getState();     
            if (state === "SUCCESS" ) {
                var Opplist = response.getReturnValue();
                component.set("v.initRows",component.get("v.initRows")+10);
                event.getSource().set("v.isLoading", false);
                component.set('v.Opplist', Opplist);  
                component.set("v.locallimit",Opplist.length)
            }
        });
        if(component.get('v.totalResult') ==component.get('v.locallimit')){
            event.getSource().set("v.isLoading", false);
        }
        else{
            $A.enqueueAction(action);
        }
    },
    
    
    addCustomerEvent: function(component, event, helper) {
    component.set('v.isModalOpen',true);
    component.set('v.isShowCustomerModal',true);
},
    filterList: function(component, event, helper) {
        component.set('v.isShowfilter',true);
    },
    closemodal: function(component, event, helper) {
        component.set('v.isShowfilter',false);
    },
    
    refreshList : function(component, event, helper) {
        //get method paramaters
        var valueFromChild = event.getParam("newRecordId");
        if(valueFromChild){
            component.set('v.selectedRecordId',valueFromChild);
            component.set('v.isShowCustomerMaster',true);
            component.set('v.isShowCustomerModal',false);
            component.set('v.isShowListView',false);
        }else{
            helper.getFilteredData(component, event, helper);
            component.set('v.isShowCustomerModal',false);
            component.set('v.isShowCustomerMaster',false);
            component.set('v.isShowListView',true);
        }
    },
    searchRecordsCall1 : function(component, event, helper) {
        component.set('v.applyFilter',true);
        component.set("v.currentPageNumber",1)
        component.set("v.disableNext",false);
        component.set('v.isShowfilter',false);
        //alert("searchRecordsCall1")
    	helper.setPaginateData(component);
	},
    clearFilter: function(component, event, helper) {
        component.set('v.sortOrder','');
        component.set('v.selectedArea','');
        component.set('v.customerName','');
        component.set('v.selectedStatus','');
        component.set('v.searchText1','');
        component.set('v.searchText','');
        component.set('v.selectedDate',null);
        component.set('v.toDate',null);
        component.set('v.modifiedDate',null);
        component.set('v.applyFilter',false);
        component.set("v.disableNext",false)
        component.get('v.offsetval',0);
        helper.fetchAccounts(component, helper);
	},
    getRecordsbydate  : function(component, event, helper) {
        var action=component.get("c.searchvisitaccRecords");
        action.setParams({'objectName': 'Lead',
                          'fields':component.get('v.fields'),
                          'date1':component.get('v.selectedArea'),
                          'Customers':component.get('v.selectedCustomers')})
        action.setCallback(this,function(response){ 
            if(response.getState() == "SUCCESS"){ 
                var data  = response.getReturnValue();
                component.set('v.items',data);
            }
        });
        $A.enqueueAction(action); 
    },
    onselectItem : function(component, event, helper) {
        var target = event.currentTarget;
        var dataIndex = target.dataset.index;
        var record = target.dataset.id ;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": record,
            "slideDevName": "detail"
        });
        navEvt.fire();
    /*    component.set('v.selectedRecordId',record);
        component.set('v.isShowCustomerMaster',true);
        component.set('v.isShowListView',false);
        var customer = [];
        customer =  component.get('v.items');
        if(dataIndex != null)
            component.set('v.customer',customer[dataIndex]); */
       
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
         component.set('v.selectedArea', event.currentTarget.dataset.id);
         var edi = component.get('v.allocatedProject');
         //alert(JSON.stringify(edi))
         var accounts= component.get('v.matchaccounts');
         for(var i=0;i<accounts.length; i++){ 
             if(accounts[i] ===  edi ){
                 component.set('v.searchText', accounts[i]);
                 component.set('v.allocatedProject', accounts[i]);
                 
                 break;
             } 
         } 
         
         component.set('v.matchaccounts',[]);
        
    },
    searchText1 : function(component, event, helper) {
        var users= component.get('v.users');
        var searchText= component.get('v.searchText1');
        var matchusers=[];
        if(searchText !=''){
            for(var i=0;i<users.length; i++){ 
                if(users[i].Name.toLowerCase().indexOf(searchText.toLowerCase())  != -1  ){
                    
                    if(matchusers.length <50){
                        matchusers.push( users[i] );
                    }else{
                        break;
                    }
                    
                } 
            } 
            if(matchusers.length >0){
                component.set('v.matchusers',matchusers);
            }
        }else{
            component.set('v.matchusers',[]);
        }
    },
    update1: function(component, event, helper) {
      
        var edi = event.currentTarget.dataset.id;
        
        var users= component.get('v.matchusers');
        for(var i=0;i<users.length; i++){ 
            
            if(users[i].Id ===  edi ){
                component.set('v.searchText1', users[i].Name);
                component.set('v.ownerId', users[i].Id);
                
                break;
            } 
        } 
        //alert(JSON.stringify(component.get('v.currentLead')))
        component.set('v.matchusers',[]);
        
    },
    
     // Data Table (Pagination)
    updateSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },
     
    handleNext: function(component, event, helper){        
        component.set("v.currentPageNumber", component.get("v.currentPageNumber") + 1);
        helper.setPaginateData(component);
    },
     
    handlePrevious: function(component, event, helper){
       component.set("v.currentPageNumber", component.get("v.currentPageNumber") - 1);
       component.set("v.isPrevious", true);
        component.set("v.disableNext",false);
       helper.setPaginateData(component);
    },
     
    onFirst: function(component, event, helper) {        
        component.set("v.currentPageNumber", 1);
        component.set("v.disableNext",false);
        helper.setPaginateData(component);
    },
     
    onLast: function(component, event, helper) {        
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        helper.setPaginateData(component);
    },

})