@isTest
public class ReceiptControllerTest {
    @isTest
    public static void ReceiptController(){
        
        User owner = new User(
            Email = 'owner112@example.com',
            Alias = 'owner',
            LastName='andy',
            ProfileId = UserInfo.getProfileId(),
            Username = 'owner43221163@example.com',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert owner;
        
        
        Project__c project = new  Project__c();
        project.Name = 'Veegaland Green Heights';
        project.Project_Type__c ='Villas';
        project.Company__c='Veegaland Homes';
        project.Finance_User__c = owner.Id;
        insert project;
        
        Lead ld1 = new Lead();
        ld1.LastName = 'test';
        ld1.Company = 'testCompanyxx';
        ld1.phone ='9876543457';
        ld1.LeadSource = '99 acres';
        ld1.Project_City__c = 'Ernakulam';
        ld1.Email ='test1234@gmail.com';
        ld1.Secondary_Email__c ='test2343@gmail.com';
        ld1.OwnerId=owner.Id;
        
        insert ld1; 
        
        Payment_Plan__c payplan = new Payment_Plan__c();
        payplan.Active__c = true;
        payplan.Project__c = project.Id;
        payplan.Disable_Merge__c = true;
        insert payplan;
        
        // Create Master Payment Schedules
        Master_payment_schedule__c mpy = new Master_payment_schedule__c(S_No__c = 1, Status__c = 'Completed', Project__c = project.Id, Payment_Plan__c = payplan.Id, Payment_Percent__c = 50);
        insert mpy;
        
        Master_payment_schedule__c mpy1 = new Master_payment_schedule__c(S_No__c = 2, Status__c = 'Completed', Project__c = project.Id, Payment_Plan__c = payplan.Id, Payment_Percent__c = 50);
        insert mpy1;
        
        Block__c block = new Block__c();
        block.Name='Tower A';
        block.Project__c=project.id;
        insert block;
        
        Plot__c unit = new Plot__c();
        unit.Name = '101';
        unit.Status__c = 'Available';
        unit.Project__c = project.Id;
        unit.Block__c = 'A4';
        unit.Plot_Type__c = 'Residential';
        unit.Block1__c = block.Id;
        unit.Carpet_Area__c = 850;
        unit.Balcony_Sq_mts__c = 20;
        unit.Balcony_Area__c = 100;
        unit.BHK_Type__c = '3 BHK';
        unit.Premium_Status__c = 'Premium';
        unit.Floor__c = '1';
        unit.Share__c = 'MHPL';
        unit.Facing__c = 'EAST';
        unit.Carpet_Sq_mts__c = 80;
        unit.CA__c = 75;
        unit.Built_up_area__c = 1200;
        unit.UDS__c = 300;
        unit.UDS_Sq_mts__c = 50;
        unit.Super_built_up_area__c = 1500;
        unit.Price_Per_Sq_Ft__c = 5000;
        unit.Floor_Rise__c = 200;
        unit.Premium_Charge__c = 100000;
        unit.Covered_Park_Parking__c = 50000;
        unit.Other_Charges__c = 20000;
        unit.Solar_Charges__c = 15000;
        unit.GST1__c = 18;
        unit.Floor__c = '30';
        insert unit;
        
        Booking__c book = new Booking__c();
        book.SLead__c = ld1.Id;
        book.Payment_Plan__c = payplan.Id;
        book.Followup_Date__c = system.today();
        book.Followup_Subject__c = 'test22';
        book.Last_Comment__c = 'test22';
        book.Project__c = 'Veegaland Green Heights';
        book.Project1__c = project.Id;
        book.Payment_Type__c = 'Custom';
        book.Sale_Agreement_Completed__c = false;
        book.Agreement_Amount_Cleared__c ='Received Partial Amount';
        book.Stage__c ='Welcome Email';
        book.Demand_Number__c = '12345'; 
        book.Date_of_Booking__c = System.today(); 
        book.Mode_Of_Payment__c = 'Credit Card';
        book.Funding_Type__c = 'Own Funds';
        book.Plot__c = unit.Id;
        book.Loan_Sanction_Confirmed__c = true;
        book.Loan_Sanctioned_Amount__c = 10000;
        book.Finance_User__c = owner.Id;
        book.Sales_Manager1__c = owner.Id;
        book.Sales_Executive__c =owner.Id;
        book.Legal_Team__c = owner.Id;
        book.CRM_Manager__c=owner.Id;
        book.First_Applicant_Name__c = 'Akhil';
        book.Legal_Advocate_Assigned__c = owner.Id;
        book.Email1__c = 'Test@gamil.com';
        book.GST__c = 5;
        insert book;
        
       Advance_Receipt__c advReceipt = new Advance_Receipt__c(
            Advance_Amount__c = 105000,
            Advance_Receipt_Date__c = Date.today(),
            Bank_Name__c = 'ICICI Bank',
            Branch__c = 'MG Road',
            Cheque_Transaction_Number__c = 'TXN123456',
            Mode_of_Payment__c = 'Cheque',
            Payment_From__c = 'Customer',
            Finance_User__c = UserInfo.getUserId(),
            Remarks__c = 'Initial Payment',
            Invoice_Id__c = 'VD/AR/24-25/01',
            Booking__c = book.Id
        );
        insert advReceipt;
        
        Test.startTest();
        ReceiptController.getInterestAmount(book.id);
        ReceiptController.getBookingDetails(book.id);
        ReceiptController.getpaymentsc(book.id);
        ReceiptController.getPaymentTypePicklistValues();
        ReceiptController.getPaymentSchedules(book.id);
        ReceiptController.getAdvanceReceipts(book.id);
        ReceiptController.testCover();
        
        Map<String, Object> receiptDataMap = new  Map<String, Object>();
        
        receiptDataMap.put('recordId',book.Id);
        receiptDataMap.put('receiptDate', string.valueOf(Date.today()));
        receiptDataMap.put('remarks','test');
        receiptDataMap.put('paymentFrom','Bank');
        receiptDataMap.put('modeofPayment','UPI');
        receiptDataMap.put('bankName', 'HDFC Bank');
        receiptDataMap.put('receiptType','Normal Receipt');
        receiptDataMap.put('paymentType','Payment Schedule');
        receiptDataMap.put('receivedAmount', 5000);
        receiptDataMap.put('transactionNumber','23243');
        receiptDataMap.put('amountFromCustomer', 4000);
        receiptDataMap.put('receivedInterestAmount', 4000);
        ReceiptController.saveManualReceipt(JSON.serialize(receiptDataMap));
        
        
        List<Receipt__c> recpt = [SELECT Id,Approval_Status__c FROM Receipt__c where Booking__c =:Book.id Limit 1 ];
        recpt[0].Approval_Status__c = 'Approved by Finance Team';
        
        update recpt;
        recpt.sort(new ReceiptDateComparator());
        Test.stopTest();  
    }
    
}