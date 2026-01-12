public class AmountInWords {
private static final List<String> BELOW_TWENTY = new List<String>{
        '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten',
        'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'
    };

    private static final List<String> TENS = new List<String>{
        '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
    };

    private static final List<String> INDIAN_UNITS = new List<String>{
        '', 'Thousand', 'Lakh', 'Crore'
    };
	public static String convertToWords(Decimal amount) {
        // Convert the decimal amount to an integer value (whole number)
        Integer num = amount.intValue();
        // Extract the decimal part (paise) by rounding off the remaining fraction
        Integer decimalPart = Math.round((amount - num) * 100); // Get the decimal (paise) part
        // If the number is zero, return "Zero Rupees Only"
        if (num == 0) return 'Zero Rupees Only';
        // Convert the integer part to words using Indian format
        String words = convertIndianFormat(num);
        // Append the decimal (paise) part if it exists
        if (decimalPart > 0) {
            words += ' and ' + formatWithHyphens(helper(decimalPart)) + ' Paise';
        }
        // Return the final formatted currency text
        return words + ' Only';
    }
    
    private static String convertIndianFormat(Integer num) {
        // If the number is zero, return "Zero"
        if (num == 0) return 'Zero';
        // Create a list to store different parts of the number
        List<Integer> parts = new List<Integer>();
        // Extract the first 3 digits (Hundreds, Tens, Units)
        parts.add(Math.mod(num, 1000)); // First 3 digits (Hundreds, Tens, Units)
        num = Math.floor(num / 1000).intValue();
        // Extract remaining parts in 2-digit pairs (Thousands, Lakhs, Crores)
        while (num > 0) {
            parts.add(Math.mod(num, 100)); // Next 2 digits (Thousands, Lakhs, Crores)
            num = Math.floor(num / 100).intValue();
        }
        
        String words = '';
        Integer unitIndex = 0;
        // Convert each part into words and append the corresponding Indian unit
        for (Integer i = 0; i < parts.size(); i++) {
            if (parts[i] != 0) {
                words = formatWithHyphens(helper(parts[i])) + ' ' + INDIAN_UNITS[unitIndex] + ' ' + words;
            }
            unitIndex++;
        }
         // Return the formatted number in words with "Rupees" appended
        return words.trim() + ' Rupees';
    }
    
    private static String helper(Integer num) {
        // If number is zero, return empty string
        if (num == 0) return '';
        // If number is less than 20, return the corresponding word
        else if (num < 20) return BELOW_TWENTY[num];
        // If number is between 20-99, fetch the tens place word and recursively add units place
        else if (num < 100) return TENS[Math.floor(num / 10).intValue()] + ' ' + BELOW_TWENTY[Math.mod(num, 10)];
        // If number is 100 or more, add "Hundred" and process the remaining part
        else return BELOW_TWENTY[Math.floor(num / 100).intValue()] + ' Hundred ' + helper(Math.mod(num, 100));
    }
    
    private static String formatWithHyphens(String amountWords) {
        // Ensure numbers below 100 have proper hyphenation for readability
        amountWords = amountWords.replace('Twenty ', 'Twenty-');
        amountWords = amountWords.replace('Thirty ', 'Thirty-');
        amountWords = amountWords.replace('Forty ', 'Forty-');
        amountWords = amountWords.replace('Fifty ', 'Fifty-');
        amountWords = amountWords.replace('Sixty ', 'Sixty-');
        amountWords = amountWords.replace('Seventy ', 'Seventy-');
        amountWords = amountWords.replace('Eighty ', 'Eighty-');
        amountWords = amountWords.replace('Ninety ', 'Ninety-');
        // Remove any extra spaces and return the cleaned-up string
        return amountWords.replaceAll('\\s+', ' ').trim(); // Remove extra spaces
    }
}