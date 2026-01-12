public class CompanyDetailsUtility {
    public static Company_Name__mdt getCompanyDetails(){
        List<Company_Name__mdt> companyDetails = [select Id, DeveloperName,	Address2__c,Label,	Address3__c, CIN__c, Registered_Address__c from Company_Name__mdt limit 1];
        return companyDetails.isEmpty()? null : companyDetails[0];
    }
}