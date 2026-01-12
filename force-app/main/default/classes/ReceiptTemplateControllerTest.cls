@IsTest
private class ReceiptTemplateControllerTest {

    @IsTest
    static void testDefault_NoRowsParam_HeaderAndList() {
        // No ?rows= param -> default 50
        PageReference pr = new PageReference('/apex/ReceiptTemplate');
        Test.setCurrentPage(pr);

        ReceiptTemplateController ctrl = new ReceiptTemplateController();

        System.assertEquals(50, ctrl.rowCount, 'Default rowCount should be 50');
        List<Integer> rows = ctrl.getRows();
        System.assertEquals(50, rows.size(), 'Rows list size should match rowCount');
        System.assertEquals(Integer.valueOf(0), rows[0], 'First index should be 0');
        System.assertEquals(Integer.valueOf(49), rows[rows.size()-1], 'Last index should be rowCount-1');

        String cd = ApexPages.currentPage().getHeaders().get('Content-Disposition');
        System.assertEquals('attachment; filename=ReceiptUploadTemplate.xls', cd, 'Header must set the download filename');
    }

    @IsTest
    static void testNumericRowsParam_WithBounds() {
        // rows=1 -> min boundary
        PageReference pr1 = new PageReference('/apex/ReceiptTemplate');
        Test.setCurrentPage(pr1);
        ApexPages.currentPage().getParameters().put('rows', '1');
        ReceiptTemplateController c1 = new ReceiptTemplateController();
        System.assertEquals(1, c1.rowCount);
        System.assertEquals(1, c1.getRows().size());

        // rows=0 -> below min -> coerced to 1
        PageReference pr0 = new PageReference('/apex/ReceiptTemplate');
        Test.setCurrentPage(pr0);
        ApexPages.currentPage().getParameters().put('rows', '0');
        ReceiptTemplateController c0 = new ReceiptTemplateController();
        System.assertEquals(1, c0.rowCount);

        // rows=-5 -> below min -> coerced to 1
        PageReference prNeg = new PageReference('/apex/ReceiptTemplate');
        Test.setCurrentPage(prNeg);
        ApexPages.currentPage().getParameters().put('rows', '-5');
        ReceiptTemplateController cNeg = new ReceiptTemplateController();
        System.assertEquals(1, cNeg.rowCount);

        // rows=999 -> normal in-range
        PageReference pr999 = new PageReference('/apex/ReceiptTemplate');
        Test.setCurrentPage(pr999);
        ApexPages.currentPage().getParameters().put('rows', '999');
        ReceiptTemplateController c999 = new ReceiptTemplateController();
        System.assertEquals(999, c999.rowCount);

        // rows=1000 -> max boundary
        PageReference pr1000 = new PageReference('/apex/ReceiptTemplate');
        Test.setCurrentPage(pr1000);
        ApexPages.currentPage().getParameters().put('rows', '1000');
        ReceiptTemplateController c1000 = new ReceiptTemplateController();
        System.assertEquals(1000, c1000.rowCount);

        // rows=1001 -> above max -> coerced to 1000
        PageReference pr1001 = new PageReference('/apex/ReceiptTemplate');
        Test.setCurrentPage(pr1001);
        ApexPages.currentPage().getParameters().put('rows', '1001');
        ReceiptTemplateController c1001 = new ReceiptTemplateController();
        System.assertEquals(1000, c1001.rowCount);
    }

    @IsTest
    static void testNonNumericRowsParam_FallsBackToDefault() {
        // rows=abc -> parse error -> default 50
        PageReference prAlpha = new PageReference('/apex/ReceiptTemplate');
        Test.setCurrentPage(prAlpha);
        ApexPages.currentPage().getParameters().put('rows', 'abc');
        ReceiptTemplateController cAlpha = new ReceiptTemplateController();
        System.assertEquals(50, cAlpha.rowCount);
        System.assertEquals(50, cAlpha.getRows().size());
    }
}