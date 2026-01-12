({
    searchPlots: function (component, searchText) {
        var action = component.get("c.getAvailablePlots");
        action.setParams({
            bookingId: component.get("v.bookingId"),
            searchText: searchText
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.plotList", result);

                if (!result || result.length === 0) {
                    this.showToast("No Units Available", "No units available for swap or booking has no project.", "warning");
                }
            } else {
                this.showToast("Error", "Failed to fetch available units.", "error");
            }
        });

        $A.enqueueAction(action);
    },

    showToast: function (title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                title: title,
                message: message,
                type: type || "info",
                mode: "dismissible"
            });
            toastEvent.fire();
        } else {
            alert(title + ": " + message); // fallback
        }
    }
});