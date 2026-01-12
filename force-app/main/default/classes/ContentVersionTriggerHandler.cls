public with sharing class ContentVersionTriggerHandler {
    public static void setFilePrefix(List<ContentVersion> newList) {
        for (ContentVersion cv : newList) {
            if (String.isNotBlank(cv.Prefix_fileupload__c) && String.isNotBlank(cv.PathOnClient)) {
                // Extract the file extension without adding an extra period
                String fileExtension = getFileExtension(cv.PathOnClient);

                // Concatenate the Prefix and the file extension
                String newTitle = cv.Prefix_fileupload__c/* + fileExtension*/;

                // Ensure the title does not exceed 255 characters
                if (newTitle.length() > 255) {
                    newTitle = newTitle.left(255);  // Truncate the title if it exceeds the limit
                }

                // Set the Title
                cv.Title = newTitle;
            }
        }
    }

    // Helper method to extract the file extension without adding an extra period
    private static String getFileExtension(String path) {
        // Extract the file extension using the split method
        List<String> parts = path.split('\\.');
        if (parts.size() > 1) {
            return '.' + parts[parts.size() - 1]; // Correctly append the period and extension
        }
        return ''; // Return empty if there's no extension
    }
}