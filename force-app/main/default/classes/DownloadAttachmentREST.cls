@RestResource(urlMapping='/downloadAttachment/*')
global with sharing class DownloadAttachmentREST {

    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String attachmentIdWithExt = req.requestURI.substringAfterLast('/');
        String attachmentId = attachmentIdWithExt.contains('.') ?
            attachmentIdWithExt.substringBefore('.') : attachmentIdWithExt;

        try {
            Attachment att = [
                SELECT Id, Name, Body, ContentType
                FROM Attachment
                WHERE Id = :attachmentId
                LIMIT 1
            ];

            String mimeType = att.ContentType != null ? att.ContentType : 'application/octet-stream';
            String fileName = att.Name;

            res.addHeader('Content-Type', mimeType);
            res.addHeader('Content-Disposition', 'inline; filename="' + fileName + '"');
            res.responseBody = att.Body;

        } catch (Exception e) {
            res.statusCode = 404;
            res.responseBody = Blob.valueOf('File not found or access denied.');
        }
    }
}