public without sharing class DigitalDocumentInterfaceVFPController {
    public String recordId { get; set; }

    public DigitalDocumentInterfaceVFPController() {
        recordId = ApexPages.currentPage().getParameters().get('id');
    }
}