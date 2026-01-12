({
    validateEmails: function(emailString) {
        var emails = emailString.split(',');
        var emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        for (var i = 0; i < emails.length; i++) {
            var email = emails[i].trim();
            if (!emailPattern.test(email)) {
                return false;
            }
        }
        return true;
    },

    showToast: function(type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type
        });
        toastEvent.fire();
    }
})