public with sharing class ComponentHolderController {
   public String recordId { get; set; }

    public ComponentHolderController() {
        recordId = ApexPages.currentPage().getParameters().get('id');
    }
}