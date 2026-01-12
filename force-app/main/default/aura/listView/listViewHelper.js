({
    
    getOpportunityList : function(component) {
        var action = component.get("c.getLead");
        action.setParams({
            
            "Limits": component.get("v.initRows"),
            
        });
        action.setCallback(this, function(response) {          
           var state = response.getState();
            if (state === "SUCCESS" ) {
                var showToast = $A.get("e.force:showToast");
               showToast.setParams({
                    'title' : 'Load',
                    'message' : 'Lead Load Sucessfully.'
                });
                showToast.fire();
                var Opplist = response.getReturnValue();
                component.set("v.Opplist",Opplist);
                var nextlimit=component.get("v.initRows")+component.get("v.Count");
                component.set("v.initRows",nextlimit);
                component.set('v.showSpinner',false);
            }
        });
        $A.enqueueAction(action);
    },
    columnsandquickactions: function(component){
        var actions =[
            
            {label: 'Edit',name:'edit'},
            {label: 'View' ,name:'view'},
            {label: 'Delete', name: 'delete'}         
        ];
        component.set('v.columns',[
            {label:'Name',fieldName:'Name', type:'text',shortable:true},
            {label:'Email', fieldName:'Email__c', type:'Email',shortable:true},
            {label: 'Lead status', fieldName: 'Lead_status__c', type: 'Picklist'},
            {label: 'Project Name', fieldName:'Allocated_Project__c', type:'Picklist'},
            {label: 'Lead source', fieldName:'Leadsource__c', type:'Picklist'},
            {type:'action', typeAttributes:{
               rowActions:actions
            }}
        ]);
    },
   totalopportunity : function(component) {
        var action = component.get("c.TotalLead");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" ) {
                var resultData = response.getReturnValue();
                component.set("v.totalResult", resultData);
            }
        });
        $A.enqueueAction(action);
    },

    getData : function(component, event, helper) {
        var action=component.get("c.searchRecords1");
        action.setParams({'objectName': 'Lead',
                          'fields':component.get('v.fields')})
        action.setCallback(this,function(response){ 
            if(response.getState() == "SUCCESS"){ 
                var data  = response.getReturnValue();
                //component.set('v.items',data);
                //alert(JSON.stringify(data))
                component.set("v.listOfAccounts", data);
            }
            component.set('v.showSpinner',false);
        });
        $A.enqueueAction(action); 
    },
    getProjectPickListValue : function(component, event, helper)
    {
        //var recoooordif = component.get("v.recordId");
        //alert('hiii getPickListValue  '+ recoooordif)
        var action = component.get("c.getProjectPickListValues");
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                var ProjectPickList = response.getReturnValue();
                console.log(ProjectPickList);
               component.set('v.accounts',ProjectPickList)
               
            }
        });
        $A.enqueueAction(action);
    },
    
	getPicklistValues : function(component, event, helper) {
          var action=component.get("c.getPickValues");
        action.setParams({'objectName': 'Lead',
                          'fieldName':'Lead_status__c'})
            action.setCallback(this,function(response){ 
                if(response.getState() == "SUCCESS"){ 
                   var data  = response.getReturnValue();
                    component.set('v.statusValues',data);
                }
            });
            $A.enqueueAction(action); 
		
	},
    getProject : function(component, event, helper) {
          var action=component.get("c.getPickValues");
        action.setParams({'objectName': 'Lead',
                          'fieldName':'Allocated_Project__c'})
            action.setCallback(this,function(response){ 
                if(response.getState() == "SUCCESS"){ 
                   var data  = response.getReturnValue();
                    component.set('v.areaValues',data);
                }
            });
            $A.enqueueAction(action); 
		
	},
      getUsers : function(component, event, helper) {
        
        var action = component.get("c.getAllUsers");
        action.setCallback(this, function(response) {
            //alert(JSON.stringify(response.getReturnValue()))
            var state=response.getState();
            console.log('Response : '+response.getReturnValue());            
            if(state==='SUCCESS'){
                component.set('v.users', response.getReturnValue());
                
            }
            else{
               
                helper.toastMsg(component, event, helper, "error", "Error!", "Something went Wrong! Please contact System Admin!");
            }
        });
        $A.enqueueAction(action);
    },
    getFilteredData : function(component, event, helper) {
        
    },
     //Data Table
    
    fetchAccounts : function(component, helper) {
        component.set('v.showSpinner',true);
        
        var limit = component.get('v.pageSize');
        var offsetvalue = component.get('v.offsetval');
       
        var action=component.get("c.searchRecords1");
        action.setParams({'objectName': 'Lead',
                          'limitVal' : limit,
                          'offsetval' : offsetvalue,
                          'fields':component.get('v.fields')})
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                //component.set('v.mapMarkers', result);
                //component.set('v.actualmapMarkers',result);
                
                component.set("v.listOfAccounts", result.leadData);
                component.set("v.totalCount", result.recordCount);
                
                component.set('v.showSpinner',false);
                helper.preparePagination(component, result.leadData);
            }
        });
        $A.enqueueAction(action);   
    },
    
    
    
    preparePagination: function (component, records) {
        let countTotalPage = Math.ceil(component.get("v.totalCount") / component.get("v.pageSize"));
        let totalPage = countTotalPage > 0 ? countTotalPage : 1;
        component.set("v.totalPages", totalPage);
        component.set("v.currentPageNumber", 1);
        component.set("v.totalRecords", records.length);
        this.setPaginateData(component);
    },
     
    setPaginateData: function(component){
        //alert("setPaginateData")
        let data = [];
        let titleData = [];
        var arr = 0;
        var applyFilter = component.get('v.applyFilter');
        //alert(applyFilter)
        let pageNumber = component.get("v.currentPageNumber");
        let pageSize = component.get("v.pageSize");
        let accountData = component.get('v.listOfAccounts');
        let currentPageCount = 0;
        let x = (pageNumber - 1) * pageSize;
        currentPageCount = x;
        //alert("currentPageCount "+currentPageCount)
        if(currentPageCount == 0 && applyFilter == false){
             //alert(currentPageCount)
            var leadData = component.get('v.listOfAccounts')
            var limit = component.get('v.pageSize');
            component.set('v.items', component.get('v.listOfAccounts'));
            
            if(leadData.length < limit ){
                //alert(data.length + " 0 "+ limit)
                component.set("v.disableNext",true);
            }
        
        }else if(applyFilter){
            //alert(applyFilter)
       
            var limit = component.get('v.pageSize');
            component.set('v.showSpinner',true);
            var action=component.get("c.searchRecords");
            action.setParams({'objectName': 'Lead',
                              'fields':component.get('v.fields'),
                              'status':component.get('v.selectedStatus'),
                              'customerName':component.get('v.customerName'),
                              'customerSort':component.get('v.sortOrder'),
                              'AreaName':component.get('v.selectedArea'),
                              'Customers':component.get('v.selectedCustomers'),
                              'owner' :component.get('v.ownerId'),
                              'modifiedOn' : component.get('v.modifiedDate'),
                              'date1':component.get('v.selectedDate'),
                              'toDate':component.get('v.toDate'),
                              'limitVal' : limit,
                              'offsetval' : currentPageCount,
                             })
            action.setCallback(this,function(response){ 
            if(response.getState() == "SUCCESS"){ 
                var data  = response.getReturnValue();
                component.set("v.listOfAccounts", data.leadData);
                component.set("v.items", data.leadData);
                component.set("v.totalCount", data.recordCount);
                let countTotalPage = Math.ceil(component.get("v.totalCount") / component.get("v.pageSize"));
                let totalPage = countTotalPage > 0 ? countTotalPage : 1;
                component.set("v.totalPages", totalPage);
                //alert(JSON.stringify(result))
                component.set('v.showSpinner',false);
                
                //helper.preparePagination(component, data);
                if(data.length < limit ){
                    //alert(data.length + " 2 "+ limit)
                    component.set("v.disableNext",true);
                }
                
            }
        });
        $A.enqueueAction(action);  
            
        }else{
            
            var isPrevious =  component.get("v.isPrevious");
            var limit = component.get('v.pageSize');
            //component.set("v.offsetval", component.get("v.offsetval") - limit);
            var action=component.get("c.searchRecords1");
            action.setParams({'objectName': 'Lead',
                              'limitVal' : limit,
                              'offsetval' : currentPageCount,
                              'fields':component.get('v.fields')})
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS'){
                    
                    var result = response.getReturnValue();
                    if(result.length < limit ){
                        //alert(data.length + " 3 "+ limit)
                        component.set("v.disableNext",true);
                    }
                    //alert(JSON.stringify(result)
                    component.set("v.totalCount", result.recordCount);
                    let countTotalPage = Math.ceil(component.get("v.totalCount") / component.get("v.pageSize"));
                    let totalPage = countTotalPage > 0 ? countTotalPage : 1;
                    component.set("v.totalPages", totalPage);
                    component.set("v.items", result.leadData);
                    component.set('v.showSpinner',false);
                    
                    //helper.preparePagination(component, result);
                }
        });
        $A.enqueueAction(action);
        }
        
        
      /*  
        for (; x < (pageNumber) * pageSize; x++){
            if (accountData[x]) {
                data.push(accountData[x]);
                currentPageCount++;
            }
        } */
        
        
        //component.set("v.currentPageRecords", currentPageCount);
    },
     
    sortData: function (cmp, fieldName, sortDirection) {
        var fname = fieldName;
        var data = cmp.get("v.listOfAccounts");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.listOfAccounts", data);
        //cmp.set('v.actualmapMarkers',data);
        this.setPaginateData(cmp);
    },
     
    sortBy: function (field, reverse) {
        var key = function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
})