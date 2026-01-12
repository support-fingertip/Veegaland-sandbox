public with sharing class ReceiptTemplateController {
    public Integer rowCount { get; private set; }

    public ReceiptTemplateController() {
        // Set the download file name header (works in Lightning + Classic)
        ApexPages.currentPage().getHeaders().put('Content-Disposition',
            'attachment; filename=ReceiptUploadTemplate.xls');

        // Read optional ?rows= param, safely bounded
        String p = ApexPages.currentPage().getParameters().get('rows');
        Integer n;
        try {
            n = (p == null) ? 50 : Integer.valueOf(p);
        } catch (Exception e) { n = 50; }

        if (n < 1) n = 1;
        if (n > 1000) n = 1000;
        rowCount = n;
    }

    // Builds a list [0..rowCount-1] just to loop in VF.
    public List<Integer> getRows() {
        List<Integer> out = new List<Integer>();
        for (Integer i = 0; i < rowCount; i++) out.add(i);
        return out;
    }
}