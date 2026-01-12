public class BookingFileUploadController {
	@AuraEnabled  
    public static List<ContentDocument> getFiles(String recordId,String filterName){ 
       System.debug('here==>toload'+filterName+'recordId'+recordId);
             ID filter = recordId;
        	 filterName='%'+filterName+'%';
        List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:filter];                         
        Set<Id> documentIds = new Set<Id>(); 
       
        for(ContentDocumentLink cdl:cdlList){  
            documentIds.add(cdl.ContentDocumentId);  
        }   
        system.debug('documentIds'+documentIds);
        return [SELECT Id, Title, SystemModStamp FROM ContentDocument WHERE Id IN :documentIds and Title like :filterName];        
    } 
    
    @AuraEnabled  
    public static void deleteFile(String contentDocumentId){ 
        delete [SELECT Id from ContentDocument WHERE Id = :contentDocumentId];       
    }  
    
    
    @AuraEnabled
    public static void updateDocument(String prefixName,List<String> idList)
    {
        System.debug('here to Update with '+prefixName);
          List<ContentDocument> cdlList = [SELECT Id, Title FROM ContentDocument WHERE Id=:idList]; 
        for(integer i=0;i<cdlList.size();i++){
            cdlList[i].Title+='-'+prefixName;
        }
        update cdlList; 
    }
  @AuraEnabled  
    public static List<ContentDocument> getFilesAll(String recordId,String filterName){ 
       System.debug('here==>toload'+filterName+'recordId'+recordId);
         list<ContentDocument> listContentDocAll= new  list<ContentDocument>(); 
             ID filter = recordId;
      string[] filterArray = filterName.split(',');
       
  List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:filter];
        Set<Id> documentIds = new Set<Id>(); 
       
        for(ContentDocumentLink cdl:cdlList){  
            documentIds.add(cdl.ContentDocumentId);  
        }   
        system.debug('documentIds'+documentIds);
         for(integer i=0;i<filterArray.size();i++){
        	 filterName='%'+filterArray[i]+'%';
            list<ContentDocument> listContentDoc =[SELECT Id, Title, SystemModStamp FROM ContentDocument WHERE Id IN :documentIds and Title like :filterName];
             listContentDocAll.addAll(listContentDoc);

         }
        return  listContentDocAll;       
    } 
    
    @AuraEnabled  
    public static String leadststus(Id recordId)
    { 
        String Objectname=recordId.getSObjectType().getDescribe().getName();
        if(Objectname=='Booking__c')
        {
        Booking__c lsc=[select id,Stage__c from Booking__c where id=:recordId];
        return lsc.Stage__c;
        }
        else
        {
           return Objectname;  
        }
    }
    
    @AuraEnabled  
    public static String accountstatus(Id recordId)
    { 
        String Objectname=recordId.getSObjectType().getDescribe().getName();
        if(Objectname=='Booking__c')
        {
        Booking__c lsc=[select id,Stage__c,Booking__c from Booking__c where id=:recordId];
        return lsc.Booking__c;
        }
        else
        {
           return Objectname;  
        }
    }
    
    @AuraEnabled  
    public static void updateQuoteDocument(String contentDocumentId){ 
        Booking__c qt=[SELECT Id,Stage__c from Booking__c WHERE Id = :contentDocumentId]; 
        /*if(qt.LOI_Uploaded__c==false)
        {
            qt.LOI_Uploaded__c=true;
            update qt;
        }*/
    } 
    
    
   /* @AuraEnabled  
    public static void updateAccountDocument(String contentDocumentId){ 
        Account qt=[SELECT Id,Inventory_uploded__c,Exit_File_Uploaded__c,Account_Status__c from Account WHERE Id = :contentDocumentId]; 
        if(qt.Inventory_uploded__c==false && qt.Account_Status__c=='On-Boarding')
        {
            qt.Inventory_uploded__c=true;
            update qt;
        }
         if(qt.Exit_File_Uploaded__c==false && qt.Account_Status__c=='Exit')
        {
            qt.Exit_File_Uploaded__c=true;
            update qt;
        }
    }*/
}