public class DiscountLimitHelper {
    public static void MappingLookupProject(list<Discount_Limit__c>DiscountLimit){
        set<string> ProjectName = new set<string>();
        for(Discount_Limit__c dis:DiscountLimit){
            ProjectName.add(dis.Project__c);
        }
        if(!ProjectName.isEmpty()){
            List<Project__c> projectList = [select Id,Name from Project__c where Name IN :ProjectName];
            Map<string,Id> projectMap = new Map<string,Id>();
            for(Project__c prj:projectList){
              projectMap.put(prj.Name,prj.Id);  
            }
            for(Discount_Limit__c dis:DiscountLimit){
                if(projectMap.containsKey(dis.Project__c)){
                    dis.Project_lookup__c = projectMap.get(dis.Project__c);
                }
            }
        }
    }  
}