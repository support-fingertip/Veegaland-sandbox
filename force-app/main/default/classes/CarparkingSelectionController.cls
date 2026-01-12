public without sharing class CarparkingSelectionController {
    public String bookingId { get; set; }
    public List<FloorWrapper> floorList { get; set; }
    public Id selectedFloorId { get; set; }
    public Integer backToBackParking { get; set; }
    public Integer individualParking { get; set; }
    
    public CarparkingSelectionController() {
        bookingId = ApexPages.currentPage().getParameters().get('Id');
        floorList = new List<FloorWrapper>();
        
        if (bookingId != null) {
            Booking__c booking = [
                SELECT Id, Project1__c,No_of_Back_to_Back_Car_Parking__c,No_of_Indivisual_Car_Parking__c,Selected_B2B_Parking_Slots__c,Selected_Individual_Parking_Slots__c,
                No_of_additional_Back_to_back_car_parki__c,No_of_additional_Individual_car_parkings__c
                FROM Booking__c
                WHERE Id = :bookingId
                LIMIT 1
            ];
            if (booking.No_of_Back_to_Back_Car_Parking__c != null) {
                Integer selectedB2B = booking.Selected_B2B_Parking_Slots__c != null ? booking.Selected_B2B_Parking_Slots__c.intValue() : 0;
                Integer totalB2b = (booking.No_of_Back_to_Back_Car_Parking__c != null ? booking.No_of_Back_to_Back_Car_Parking__c.intValue() : 0) +
                    (booking.No_of_additional_Back_to_back_car_parki__c != null ? booking.No_of_additional_Back_to_back_car_parki__c.intValue() : 0);
                backToBackParking = totalB2b - selectedB2B;
            }
            
            if (booking.No_of_Indivisual_Car_Parking__c != null) {
                Integer selectedIndividual = booking.Selected_Individual_Parking_Slots__c != null ? booking.Selected_Individual_Parking_Slots__c.intValue() : 0;
                Integer totalindv = (booking.No_of_Indivisual_Car_Parking__c != null ? booking.No_of_Indivisual_Car_Parking__c.intValue() : 0) +
                    (booking.No_of_additional_Individual_car_parkings__c != null ? booking.No_of_additional_Individual_car_parkings__c.intValue() : 0);
                individualParking = totalindv - selectedIndividual;
            }
            
            if (booking.Project1__c != null) {
                // Step 1: Fetch all floors for the project
                List<Parking_Floor__c> floors = [
                    SELECT Id, Name, Floor_File_Id__c, Project__c,Floor_Short_Name__c,Layout_Public_url__c
                    FROM Parking_Floor__c
                    WHERE Project__c = :booking.Project1__c
                    ORDER BY Name
                ];
                
                Set<Id> floorIds = new Set<Id>();
                for (Parking_Floor__c floor : floors) {
                    floorIds.add(floor.Id);
                }
                
                // Step 2: Fetch related parkings
                Map<Id, List<Parking__c>> floorToParkingsMap = new Map<Id, List<Parking__c>>();
                for (Parking__c p : [
                    SELECT Id, Name, Parking_Floor__c, Parking_Type__c, Size__c, Cost__c, Status__c
                    FROM Parking__c
                    WHERE Parking_Floor__c IN :floorIds
                    ORDER BY Name
                ]) {
                    if (!floorToParkingsMap.containsKey(p.Parking_Floor__c)) {
                        floorToParkingsMap.put(p.Parking_Floor__c, new List<Parking__c>());
                    }
                    floorToParkingsMap.get(p.Parking_Floor__c).add(p);
                }
                
                // Step 6: Build wrapper list
                for (Parking_Floor__c floor : floors) {
                    List<Parking__c> parkings = floorToParkingsMap.containsKey(floor.Id)
                        ? floorToParkingsMap.get(floor.Id)
                        : new List<Parking__c>();
                    
                    FloorWrapper fw = new FloorWrapper();
                    fw.floor = floor;
                    fw.parkings = parkings;
                    
                    floorList.add(fw);
                }
                
                if (!floorList.isEmpty()) {
                    selectedFloorId = floorList[0].floor.Id;
                }
            }
        }
    }
    
    public class FloorWrapper {
        public Parking_Floor__c floor { get; set; }
        public List<Parking__c> parkings { get; set; }
    }
    
    @RemoteAction
    public static void saveSelectedSlots(
        Id bookingId, 
        String slotNames, 
        List<Id> parkingIds, 
        String comment, 
        Integer individualCount,
        Integer backToBackCount
    ) {
        try {
            // Fetch the booking with limits
            Booking__c booking = [
                SELECT Id, Parking_Slot_Numbers__c, Car_Parking_Selection_Comments__c, 
                Selected_Individual_Parking_Slots__c, Selected_B2B_Parking_Slots__c,No_of_additional_Individual_car_parkings__c,
                No_of_Indivisual_Car_Parking__c, No_of_Back_to_Back_Car_Parking__c,No_of_additional_Back_to_back_car_parki__c
                FROM Booking__c 
                WHERE Id = :bookingId 
                LIMIT 1
            ];
            
            Decimal existingInd = booking.Selected_Individual_Parking_Slots__c != null ? booking.Selected_Individual_Parking_Slots__c : 0;
            Decimal existingB2B = booking.Selected_B2B_Parking_Slots__c != null ? booking.Selected_B2B_Parking_Slots__c : 0;
            
            Decimal noOfInd = booking.No_of_Indivisual_Car_Parking__c != null ? booking.No_of_Indivisual_Car_Parking__c : 0;
            Decimal noOfIndExtra = booking.No_of_additional_Individual_car_parkings__c != null ? booking.No_of_additional_Individual_car_parkings__c : 0;
            
            Decimal noOfB2B = booking.No_of_Back_to_Back_Car_Parking__c != null ? booking.No_of_Back_to_Back_Car_Parking__c : 0;
            Decimal noOfB2BExtra = booking.No_of_additional_Back_to_back_car_parki__c != null ? booking.No_of_additional_Back_to_back_car_parki__c : 0;
            
            if (existingInd + individualCount > noOfInd + noOfIndExtra) {
                throw new AuraHandledException(
                    'You have already selected maximum allowed individual car parking slots.'
                );
            }
            
            if (existingB2B + backToBackCount > noOfB2B + noOfB2BExtra) {
                throw new AuraHandledException(
                    'You have already selected maximum allowed back-to-back car parking slots.'
                );
            }
            
            // Lock the requested parking slots
            Map<Id, Parking__c> availableSlots = new Map<Id, Parking__c>(
                [SELECT Id, Booking__c, Status__c 
                 FROM Parking__c 
                 WHERE Id IN :parkingIds 
                 FOR UPDATE]
            );
            
            // Check if all requested slots are still available
            for (Id slotId : parkingIds) {
                if (!availableSlots.containsKey(slotId) || availableSlots.get(slotId).Status__c != 'Available') {
                    throw new AuraHandledException(
                        'One or more of the selected parking slots have already been allocated. Please select different slots.'
                    );
                }
            }
            
            // Update booking fields
            booking.Parking_Slot_Numbers__c = 
                String.isNotBlank(booking.Parking_Slot_Numbers__c)
                ? booking.Parking_Slot_Numbers__c + ', ' + slotNames
                : slotNames;
            
            booking.Car_Parking_Selection_Comments__c = comment;
            booking.Selected_Individual_Parking_Slots__c = existingInd + individualCount;
            booking.Selected_B2B_Parking_Slots__c = existingB2B + backToBackCount;
            
            // Update slots
            for (Parking__c slot : availableSlots.values()) {
                slot.Booking__c = bookingId;
                slot.Status__c = 'Allocated';
            }
            
            update booking;
            update availableSlots.values();
            
        } catch (AuraHandledException e) {
            throw e; // Passes message back to LWC/Aura UI
        } catch (Exception e) {
            throw new AuraHandledException(
                'An unexpected error occurred while saving parking slots. Please try again.'
            );
        }
    }
    
}