public without sharing class NameBoardController {
    public String apartmentName { get; set; }
    public Boolean nameAlreadySelected { get; set; }
    public Id bookingId { get; set; }

    public NameBoardController() {
        // Get Booking Id from URL if passed like ?id=xxxx
        bookingId = ApexPages.currentPage().getParameters().get('id');
        
        // Check if the apartment name is already selected
        Booking__c booking = [SELECT Id, Apartment_Name__c FROM Booking__c WHERE Id = :bookingId LIMIT 1];
        if (booking != null && String.isNotBlank(booking.Apartment_Name__c)) {
            nameAlreadySelected = true;
            apartmentName = booking.Apartment_Name__c;
        } else {
            nameAlreadySelected = false;
        }
    }
    @RemoteAction
    public static String saveApartmentName(Id bookingId, String apartmentName) {
        if (String.isBlank(bookingId) || String.isBlank(apartmentName)) {
            return 'missing';
        }

        try {
            Booking__c booking = [
                SELECT Id, Apartment_Name__c, Name_Board_Selected__c 
                FROM Booking__c 
                WHERE Id = :bookingId 
                LIMIT 1
            ];

            if (booking.Name_Board_Selected__c) {
                return 'alreadySelected';
            }

            booking.Apartment_Name__c = apartmentName;
            booking.Name_Board_Selected__c = true;
            update booking;

            return 'saved';
        } catch (Exception e) {
            return 'error: ' + e.getMessage();
        }
    }
}