@isTest
private class AmountInWordsTest {
    
    // Test case 1: Test with a whole number value (no decimal part)
    @isTest
    static void testWholeNumber() {
        Decimal amount = 12345;
        String result = AmountInWords.convertToWords(amount);
        System.assertEquals('Twelve Thousand Three Hundred Forty-Five Rupees Only', result);
    }
    
    // Test case 2: Test with a number having a decimal (paise) part
    @isTest
    static void testWithDecimal() {
        Decimal amount = 12345.67;
        String result = AmountInWords.convertToWords(amount);
        System.assertEquals('Twelve Thousand Three Hundred Forty-Five Rupees and Sixty-Seven Paise Only', result);
    }
    
    // Test case 3: Test with zero value
    @isTest
    static void testZeroAmount() {
        Decimal amount = 0;
        String result = AmountInWords.convertToWords(amount);
        System.assertEquals('Zero Rupees Only', result);
    }
    
    // Test case 4: Test with an amount under 20
    @isTest
    static void testUnderTwenty() {
        Decimal amount = 15;
        String result = AmountInWords.convertToWords(amount);
        System.assertEquals('Fifteen Rupees Only', result);
    }
    
    // Test case 5: Test with an amount in the hundreds (no decimal)
    @isTest
    static void testHundreds() {
        Decimal amount = 875;
        String result = AmountInWords.convertToWords(amount);
        System.assertEquals('Eight Hundred Seventy-Five Rupees Only', result);
    }
    
    // Test case 6: Test with an amount in the thousands
    @isTest
    static void testThousands() {
        Decimal amount = 10567;
        String result = AmountInWords.convertToWords(amount);
        System.assertEquals('Ten Thousand Five Hundred Sixty-Seven Rupees Only', result);
    }
    
    // Test case 7: Test with an amount in Lakhs
    @isTest
    static void testLakhs() {
        Decimal amount = 1256789;
        String result = AmountInWords.convertToWords(amount);
    }
    
    // Test case 8: Test with an amount in Crores
    @isTest
    static void testCrores() {
        Decimal amount = 12345678;
        String result = AmountInWords.convertToWords(amount);
        System.assertEquals('One Crore Twenty-Three Lakh Forty-Five Thousand Six Hundred Seventy-Eight Rupees Only', result);
    }
    
    // Test case 9: Test with zero decimal (paise) part
    @isTest
    static void testZeroDecimal() {
        Decimal amount = 12345.00;
        String result = AmountInWords.convertToWords(amount);
        System.assertEquals('Twelve Thousand Three Hundred Forty-Five Rupees Only', result);
    }
    
    // Test case 10: Test with paise less than 10
    @isTest
    static void testPaiseLessThanTen() {
        Decimal amount = 12345.09;
        String result = AmountInWords.convertToWords(amount);
        System.assertEquals('Twelve Thousand Three Hundred Forty-Five Rupees and Nine Paise Only', result);
    }
    
    // Test case 11: Test with an exact whole number in Lakh
    @isTest
    static void testExactLakh() {
        Decimal amount = 100000;
        String result = AmountInWords.convertToWords(amount);
        System.assertEquals('One Lakh Rupees Only', result);
    }
}