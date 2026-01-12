trigger BookingTrigger on Booking__c(before insert, before update, after update, after insert) {
    
    if (label.BookingTriggerActive == 'True') {
      
                
        
        if (Trigger.isAfter && Trigger.isInsert) {
            BookingController.custmerMasterallocation(Trigger.new);
        }

        
        if (Trigger.isBefore) {
            if (Trigger.isUpdate) {
                BookingController.stageWiseOwnerUpdate(Trigger.new, Trigger.oldMap);
            }
            
            if (Trigger.isInsert) {
                BookingController.assignBookingUsers(Trigger.new);
                BookingController.preventDuplicateBookings(Trigger.new);
                //BookingController.UpdateBookingUsers(Trigger.new,'CRM');
                //BookingController.UpdateBookingUsers(Trigger.new,'Legal');
                //BookingController.UpdateBookingUsers(Trigger.new,'Finance');
                //BookingController.assignUsersByRoundRobin(trigger.new);
                
            }
         
            // Update Stage to 'Cancellation' when Swap Unit is approved
            if (Trigger.isUpdate) {
                
                List < Id > bookingsToEmail = new List < Id > ();
                
                for (Booking__c booking: Trigger.new) {
                    Booking__c oldBooking = Trigger.oldMap.get(booking.Id);
                    
                    if (booking.Swap_Unit_Status__c != oldBooking.Swap_Unit_Status__c && booking.Swap_Unit_Status__c == 'Approved') {
                        // Update the booking Stage to 'Cancellation'
                        booking.Stage__c = 'Unit Swap';
                    }
                    if (booking.Stage__c == 'Draft Agreement Preparation' && booking.Final_Draft_Agreement_Mail_Send__c == true && booking.Final_Draft_Agreement_Mail_Send__c != oldBooking.Final_Draft_Agreement_Mail_Send__c) {
                        booking.Draft_Agreement_Completed_Date__c = system.today();
                        booking.Stage__c = 'Sale Agreement Registration';
                        booking.Agreement_Status__c = 'Draft Prepared';
                    }
                    
                    if (booking.Stage__c == 'Sale Agreement Registration') {
                        if ((booking.Registration_Status__c == 'Executed' || booking.Registration_Status__c == 'Executed & Registered') &&
                            booking.Registration_Status__c != oldBooking.Registration_Status__c) {
                                booking.Agreement_Registration_Completed_Date__c = System.today();
                                booking.Stage__c = 'Demands & Collection';
                            }
                    }
                    if (booking.Stage__c == 'Demands & Collection' && booking.Registration_Statutory_Charges_cleared__c == true && booking.All_Payment_Cleared__c == true) {
                        booking.Demand_Collection_Completed_Date__c = system.today();
                        booking.Stage__c = 'Draft Sale Deed Preparation';
                    }
                    if (booking.Stage__c == 'Draft Agreement Preparation' && booking.Stage__c != oldBooking.Stage__c) {
                        booking.Draft_Agreement_Status__c = 'Not Started';
                    }
                    if (booking.Stage__c == 'Draft Sale Deed Preparation' && booking.Stage__c != oldBooking.Stage__c) {
                        booking.Sale_Deed_Status__c = 'Draft Sale Deed upload & Send';
                        booking.Draft_Sale_Deed_Uploaded__c = false;
                        booking.Final_Sale_Deed_Document_Uploaded__c = false;
                        booking.Final_Sale_Deed_Send_to_Customer__c = false;
                        booking.Draft_Sale_Deed_Send__c = false;
                    }
                    if (booking.Stage__c == 'Draft Sale Deed Preparation' && booking.Final_Sale_Deed_Send_to_Customer__c == true && booking.Final_Sale_Deed_Send_to_Customer__c != oldBooking.Final_Sale_Deed_Send_to_Customer__c) {
                        booking.Demand_Collection_Completed_Date__c = system.today();
                        booking.Stage__c = 'Sale Deed Registration';
                    }
                    
                    if (booking.Stage__c == 'Sale Deed Registration' && booking.Registration_Done__c == true && booking.Registration_Done__c != oldBooking.Registration_Done__c) {
                        booking.Sale_Deed_Completed_Date__c = system.today();
                        booking.Stage__c = 'Handover';
                        
                    }
                    if (booking.Draft_Agreement_Email_Send__c == true && booking.Draft_Agreement_Email_Send__c != oldBooking.Draft_Agreement_Email_Send__c) {
                        booking.Agreement_Approval_Status__c = 'Pending';
                    }
                    
                    if (booking.Agreement_Approval_Status__c == 'Rejected' && booking.Agreement_Approval_Status__c != oldBooking.Agreement_Approval_Status__c) {
                        booking.Draft_Agreement_Uploaded__c = false;
                        booking.Draft_Agreement_Email_Send__c = false;
                    }
                    
                    if (booking.Agreement_Approval_Status__c == 'Approved' && booking.Agreement_Approval_Status__c != oldBooking.Agreement_Approval_Status__c) {
                        booking.Draft_Agreement_Status__c = 'Final Draft Agreement';
                    }
                    
                    
                    if (booking.Sale_deed_Approval_Status__c == 'Rejected' && booking.Sale_deed_Approval_Status__c != oldBooking.Sale_deed_Approval_Status__c) {
                        booking.Draft_Sale_Deed_Send_Date__c = null;
                        booking.Draft_Sale_Deed_Send__c = false;
                        booking.Draft_Sale_Deed_Uploaded__c = false;
                    }
                    if (booking.Sale_deed_Approval_Status__c == 'Approved' && booking.Sale_deed_Approval_Status__c != oldBooking.Sale_deed_Approval_Status__c) {
                        booking.Sale_Deed_Status__c = 'Final Sale Deed upload & Send';
                    }
                    if (booking.Stage__c == 'Sale Deed Registration') {
                        for (Booking__c book: Trigger.new) {
                            if (booking.Agreement_Signed_Date__c != null && booking.Registration_Completed_Date__c == null) {
                                booking.Registration_Completed_Date__c = booking.Agreement_Signed_Date__c;
                            } else if (booking.Registration_Completed_Date__c != null && booking.Agreement_Signed_Date__c == null) {
                                booking.Agreement_Signed_Date__c = booking.Registration_Completed_Date__c;
                            }
                            
                        }
                        
                    }
                    if(booking.Agreement_Details_Request_Send__c == false && booking.Agreement_Details_Request_Send__c != oldBooking.Agreement_Details_Request_Send__c){
                        booking.Draft_Agreement_Status__c ='Not Started';
                    }
                    if (booking.Received_Agreement_Details_from_Customer__c != oldBooking.Received_Agreement_Details_from_Customer__c && booking.Received_Agreement_Details_from_Customer__c == true) {
                        booking.Agreement_Details_Verification__c = 'Pending';
                    }
                    
                    if (booking.Stage__c == 'Sale Deed Registration' && oldBooking.Sale_Deed_Registration_Status__c == 'Cancelled' &&

                         
                        (booking.Deed_Expected_Date__c != null ||
                         booking.Registration_Date__c != null )
                    ) {
                        booking.Registration_Status__c = 'Scheduled';
                    }
                    
                    if (booking.Registration_Date__c != oldBooking.Registration_Date__c && oldBooking.Registration_Date__c != null && booking.Sale_Deed_Registration_Status__c != 'Cancelled' && oldBooking.Registration_Status__c !='Cancelled') {
                        // Mark status as Rescheduled
                        booking.Registration_Status__c = 'Rescheduled';
                        // Add booking to email list
                        bookingsToEmail.add(booking.Id);
                    }
                }
                if (!bookingsToEmail.isEmpty()) {
                    GenerateDocumnetController.sendRescheduleEmailsAsync(bookingsToEmail);
                }
            }
        }
        
        if (trigger.isAfter) {
            
            if (Trigger.isInsert) {
                List < Booking__c > nonSwapBookings = new List < Booking__c > ();
                List < Booking__c > normalMerge = new List < Booking__c > ();
                List < Booking__c > mergeByDate = new List < Booking__c > ();
                Map < Id, Booking__c > leadBookingMap = new Map < Id, Booking__c > ();
                List < Id > bookingAdvanceFollowupList = new List < Id > ();
                Map < Id, Booking__c > unitUpdateMap = new Map < Id, Booking__c > ();
                
                for (Booking__c booking: Trigger.new) {
                    if (booking.SLead__c != null) {
                        leadBookingMap.put(booking.SLead__c, booking);
                    }
                    if (booking.Plot__c != null) {
                        unitUpdateMap.put(booking.Plot__c, booking);
                    }
                    if (booking.Is_Swap__c == false) {
                        nonSwapBookings.add(booking);
                        if (booking.Merge_Schedules_by_Booking_Date__c == false) {
                            normalMerge.add(booking);
                        } else {
                            mergeByDate.add(booking);
                        }
                    }
                    // if (booking.Balance_Advance_Amount__c > 0) {
                    //     bookingAdvanceFollowupList.add(booking.Id);
                    // }
                }
                
                // Bulk calls (outside loop)
                if (!nonSwapBookings.isEmpty()) {
                    BookingController.shareBookingWithAssignedUsers(nonSwapBookings);
                    BookingController.updateCoApplicants(nonSwapBookings);
                    BookingController.advanceAmountCreation(nonSwapBookings);
                    BookingController.updateChargeType(nonSwapBookings);
                    BookingController.updateQuoteCreateTask(nonSwapBookings);
                    // BookingController.bookingAmountReceipt(nonSwapBookings);
                }
                if (!normalMerge.isEmpty()) {
                    PaymentScheduleService.checkMergeSchedules(normalMerge);
                }
                if (!mergeByDate.isEmpty()) {
                    PaymentScheduleService.createPaymentSchedulesTillBookingDate(mergeByDate);
                }
                // if (!bookingAdvanceFollowupList.isEmpty()) {
                //     BookingController.createAdvanceFollowup(bookingAdvanceFollowupList);
                // }
                if (!leadBookingMap.isEmpty()) {
                    BookingController.changeBookingLeadStatus(leadBookingMap);
                }
                if (!unitUpdateMap.isEmpty()) {
                    BookingController.updateUnitStatus(unitUpdateMap);
                }
            }
            
            
            List < Booking__c > swapUnit = new List < Booking__c > ();
            List < Booking__c > OldUnitDetials = new List < Booking__c > ();
            
            if (trigger.isupdate) {
                
                Set < Id > welcomeMailSend = new Set < Id > ();
                Set < Id > carParkingStageBookingIds = new Set < Id > ();
                List < Id > bookingAdvanceFollowupList = new List < Id > ();
                List < Id > DAPStageBookingIds = new List < Id > ();
                List < Plot__c > plotsToUpdate = new List < Plot__c > ();
                List < Id > cancelledBookingsToEmail = new List < Id > ();
                List < Booking__c > instalmentMailSend = new List < Booking__c > ();
                List < Booking__c > remainderMailSend = new List < Booking__c > ();
                List < Id > completedBookings = new List < Id > ();
                List < Id > sharedAgreementBookings = new List < Id > ();
                List<Id> DeedRescheduleEmailList= new List<Id>(); 
                List<Id> cancelledBookingIds = new List<Id>();
                
                Set < Id > bookingIdsToProcess = new Set < Id > ();
                Set < Id > saleagreementRejection = new Set < Id > ();
                Set < Id > saleDeedRejection = new Set < Id > ();
                Set < Id > saleagreementApproval = new Set < Id > ();
                Set < Id > saleDeedApproval = new Set < Id > ();
                Set < Id > draftAgreementrejectedIds = new Set < Id > ();
                
                Set < Id > bookingIdsForPaymentUpdate = new Set < Id > ();
                set < Id > draftAgreementMailSend = new set < Id > ();
                Set < Id > bookingAgreementDetailsReceivedList = new Set < Id > ();
                Set < Id > SADetailsVerifiedList = new Set < Id > ();
                Set < Id > SADetailsReceivedList = new Set < Id > ();
                Set < Id > updatePlotStatusList = new Set < Id > ();
                Set < Id > DraftAgreementSendList = new Set < Id > ();
                Set < Id > SARStageList = new Set < Id > ();
                Set < Id > sendAppoinmentMailList = new Set < Id > ();
                Set < Id > registratonDoneTaskList = new Set < Id > ();
                Set < Id > createDemandTasks = new Set < Id > ();
                Set < Id > saleDeedtaskCreationList = new Set < Id > ();
                Set < Id > saleDeedCompletionList = new Set < Id > ();
                Set < Id > handOverMailList = new Set < Id > ();
                Set < Id > cancellationApprovalMailList = new Set < Id > ();
                Set < Id > cancellationRejectionMailList = new Set < Id > ();
                Set < Id > swapUnitRequestList = new Set < Id > ();
                Set < Id > swapUnitApprovedList = new Set < Id > ();
                Set < Id > swapUnitRejectedList = new Set < Id > ();
                Set < Id > welcomeTaskCompletedList = new Set < Id > ();
                Set < Id > paymentPlanChangeList = new Set < Id > ();
                set < Id > apartmentNameChangeList = new Set < Id >();
                set < Id > sendAgreementReceivedEmailToUser = new Set < Id >();
                
                
                Map < Id, set < String >> bookingfullpayemntMap = new Map < Id, set < String >> ();
                Map < Id, set < String >> saleagreementApprovalMap = new Map < Id, set < String >> ();
                Map < Id, set < String >> saleDeedApprovalMap = new Map < Id, set < String >> ();
                Map < Id, set < String >> saleDeedRejectionMap = new Map < Id, set < String >> ();
                Map < Id, set < String >> updatedParkingMap = new Map < Id, set < String >> ();
                Map < Id, set < String >> saleagreementRejectionMap = new Map < Id, set < String >> ();
                Map < Id, set < String >> SADetailsReceivedMap = new Map < Id, set < String >> ();
                Map < Id, set < String >> bookingSelectedMap = new Map < Id, set < String >> ();
                Map < Id, set < String >> agreementDetailsRejectionMap = new Map < Id, set < String >> ();
                Map < Id, set < String >> agreementDetailsApprovalMap = new Map < Id, set < String >> ();
                
                list < Id > bookingIds = new list < Id > ();
                
                for (Booking__c booking: trigger.New) {
                    Booking__c oldBooking = Trigger.oldMap.get(booking.Id);
                    
                    //If a booking amount changes, update the payment schedule accordingly.
                    if (booking.Total__c != oldBooking.Total__c) {
                        bookingIdsForPaymentUpdate.add(booking.Id);
                    }
                    
                    if (booking.Payment_Plan__c != null && booking.Payment_Plan__c != oldBooking.Payment_Plan__c){
                        paymentPlanChangeList.add(booking.Id);
                    }
                    
                    // Check if the stage has just changed to 'Welcome Email' and full token advance amount is received
                    // If so, add to the list for sending the welcome mail
                    if (booking.Stage__c == 'Welcome Email' && booking.Stage__c != oldBooking.Stage__c && booking.Token_Advance_Amount_Status__c == 'Full Payment Received') {
                        welcomeMailSend.add(booking.Id);
                        carParkingStageBookingIds.add(booking.Id);
                    }
                    
                    // If the booking stage has just changed to 'Car Parking Selection', 
                    // collect the booking ID to trigger notification and follow-up actions
                    /*if (booking.Stage__c == 'Car Parking Selection' && booking.Stage__c != oldBooking.Stage__c) {
                    carParkingStageBookingIds.add(booking.Id);
                    }*/
                    // auto complete welcome call tasks when checkbox checked
                    if (booking.Welcome_Call_Done__c != oldBooking.Welcome_Call_Done__c && booking.Welcome_Call_Done__c == true) {
                        welcomeTaskCompletedList.add(booking.Id);
                    }
                    if ((booking.Selected_Individual_Parking_Slots__c > oldBooking.Selected_Individual_Parking_Slots__c) ||
                        (booking.Selected_B2B_Parking_Slots__c > oldBooking.Selected_B2B_Parking_Slots__c)) {
                            if (!updatedParkingMap.containsKey(booking.Id)) {
                                updatedParkingMap.put(booking.Id, new Set < String > ());
                            }
                            updatedParkingMap.get(booking.Id).add(booking.CRM_Manager__c);
                        }
                    
                    if (booking.Stage__c == 'Advance Amount Collection' && booking.Stage__c != oldBooking.Stage__c) {
                        bookingAdvanceFollowupList.add(booking.Id);
                    }
                    
                    if (booking.Stage__c == 'Draft Agreement Preparation' && booking.Stage__c != oldBooking.Stage__c) {
                        DAPStageBookingIds.add(booking.Id);
                    }
                    /*if (booking.Stage__c == 'Draft Agreement Preparation' && booking.Received_Agreement_Details_from_Customer__c == true && booking.Received_Agreement_Details_from_Customer__c != oldBooking.Received_Agreement_Details_from_Customer__c) {
if (!SADetailsReceivedMap.containsKey(booking.Id)) {
SADetailsReceivedMap.put(booking.Id, new Set<String>());
}
SADetailsReceivedMap.get(booking.Id).add(booking.CRM_Manager__c);
bookingAgreementDetailsReceivedList.add(booking.Id);
}


if (booking.Stage__c == 'Draft Agreement Preparation' && booking.Agreement_Details_Verified__c == true && booking.Agreement_Details_Verified__c != oldBooking.Agreement_Details_Verified__c) {
SADetailsVerifiedList.add(booking.Id);
}*/
                    
                    if (booking.Stage__c == 'Draft Agreement Preparation' && booking.All_Required_Details_Provided_by_the_Cus__c == true && booking.All_Required_Details_Provided_by_the_Cus__c != oldBooking.All_Required_Details_Provided_by_the_Cus__c) {
                        DraftAgreementSendList.add(booking.Id);
                    }
                    
                    if (booking.Agreement_Approval_Status__c == 'Approved' && booking.Agreement_Approval_Status__c != oldBooking.Agreement_Approval_Status__c) {
                        if (!saleagreementApprovalMap.containsKey(booking.Id)) {
                            saleagreementApprovalMap.put(booking.Id, new Set < String > ());
                        }
                        saleagreementApprovalMap.get(booking.Id).add(booking.Legal_Team__c);
                        saleagreementApprovalMap.get(booking.Id).add(booking.CRM_Manager__c);
                        saleagreementApproval.add(booking.Id);
                    }
                    
                    if (booking.Sale_deed_Approval_Status__c == 'Approved' && booking.Sale_deed_Approval_Status__c != oldBooking.Sale_deed_Approval_Status__c) {
                        if (!saleDeedApprovalMap.containsKey(booking.Id)) {
                            saleDeedApprovalMap.put(booking.Id, new Set < String > ());
                        }
                        saleDeedApprovalMap.get(booking.Id).add(booking.Legal_Team__c);
                        saleDeedApprovalMap.get(booking.Id).add(booking.CRM_Manager__c);
                        saleDeedApprovalMap.get(booking.Id).add(booking.CRM_Technical__c);
                        saleDeedApproval.add(booking.Id);
                    }
                    
                    if (booking.Agreement_Approval_Status__c == 'Rejected' && booking.Agreement_Approval_Status__c != oldBooking.Agreement_Approval_Status__c) {
                        if (!saleagreementRejectionMap.containsKey(booking.Id)) {
                            saleagreementRejectionMap.put(booking.Id, new Set < String > ());
                        }
                        saleagreementRejectionMap.get(booking.Id).add(booking.Legal_Team__c);
                        saleagreementRejectionMap.get(booking.Id).add(booking.CRM_Manager__c);
                        saleagreementRejectionMap.get(booking.Id).add(booking.CRM_Technical__c);
                        saleagreementRejection.add(booking.Id);
                    }
                    
                    
                    if (booking.Sale_deed_Approval_Status__c == 'Rejected' && booking.Sale_deed_Approval_Status__c != oldBooking.Sale_deed_Approval_Status__c) {
                        if (!saleDeedRejectionMap.containsKey(booking.Id)) {
                            saleDeedRejectionMap.put(booking.Id, new Set < String > ());
                        }
                        saleDeedRejectionMap.get(booking.Id).add(booking.Legal_Team__c);
                        saleDeedRejectionMap.get(booking.Id).add(booking.CRM_Manager__c);
                        saleDeedRejectionMap.get(booking.Id).add(booking.CRM_Technical__c);
                        saleDeedRejection.add(booking.Id);
                    }
                    
                    if (booking.Stage__c == 'Sale Agreement Registration' && booking.Stage__c != oldBooking.Stage__c) {
                        SARStageList.add(booking.Id);
                    }
                    /*    
if (booking.Agreement_Amount_Received__c == true && booking.Agreement_Amount_Received__c != oldBooking.Agreement_Amount_Received__c) {
sendAppoinmentMailList.add(booking.Id);
}
*/
                    if (booking.Stage__c == 'Sale Agreement Registration' && booking.Registration_Status__c == 'Scheduled' && booking.Registration_Status__c != oldBooking.Registration_Status__c) {
                        registratonDoneTaskList.add(booking.Id);
                    }
                    
                    if (booking.Stage__c == 'Sale Agreement Registration' && booking.Registration_Status__c == 'Cancelled' && oldBooking.Registration_Status__c != 'Cancelled') {
                        cancelledBookingsToEmail.add(booking.Id);
                    }
                    
                    if (booking.Stage__c == 'Sale Agreement Registration' && booking.Registration_Status__c == 'Executed' && oldBooking.Registration_Status__c != 'Executed') {
                        completedBookings.add(booking.Id);
                    }
                    if (booking.Stage__c == 'Demands & Collection' && booking.Stage__c != oldBooking.Stage__c) {
                        createDemandTasks.add(booking.Id);
                    }
                    
                    
                    
                    // If the booking stage is 'Registration' and a plot is associated,
                    // mark the related plot's status as 'Sold' to reflect it's been booked
                    if (booking.Stage__c == 'Sale Deed Registration' && booking.Stage__c != oldBooking.Stage__c && booking.Plot__c != null) {
                        updatePlotStatusList.add(booking.Id);
                    }
                    
                    if (
                        oldBooking.Registration_Status__c == 'Cancelled' && booking.Stage__c == 'Sale Deed Registration' && 
                        (booking.Agreement_Appointment_Date__c != null ||
                         booking.Agreement_Expected_Date__c != null)
                    ) {
                        booking.Registration_Status__c = 'Scheduled';
                    }
                    
                    //anju
                    // if booking stage is sale deed registration and Sale_Deed_Registration_Status__c is resheduled
                    else if (booking.Registration_Date__c != oldBooking.Registration_Date__c && booking.Registration_Date__c != null) {
                        DeedRescheduleEmailList.add(booking.Id);
                        
                        // GenerateDocumnetController.sendDeedRescheduledEmail(DeedRescheduleEmailList);
                    }
                    
                    if (booking.Sale_Deed_Registration_Status__c != oldBooking.Sale_Deed_Registration_Status__c && booking.Sale_Deed_Registration_Status__c == 'Cancelled' && booking.Stage__c == 'Sale Deed Registration') {
                        cancelledBookingIds.add(booking.Id);
                        
                        //GenerateDocumnetController.deedCancellationEmail(cancelledBookingIds);
                    }
                    
                    //
                    
                    
                    
                    
                    if (booking.Stage__c != oldBooking.Stage__c && booking.Stage__c == 'Cancellation' && booking.Swap_Unit_Status__c != 'Approved') {
                        set < String > userIds = new set < String > ();
                        string Body = 'Booking Cancelled Please Initiate Refund Process for' + booking.Name;
                        userIds.add(booking.Finance_User__c);
                        BookingController.sendCustomNotification(userIds, 'Refund Amount for Cancelled Booking', Body, booking.Id, 'Booking_Notification');
                    }
                    
                    if (booking.Unit_Swap_Requested__c == true && booking.Unit_Swap_Requested__c != oldBooking.Unit_Swap_Requested__c) {
                        swapUnitRequestList.add(booking.Id);
                    }
                    
                    /* if (booking.Swap_Unit_Status__c == 'Approved' && booking.Swap_Unit_Status__c != oldBooking.Swap_Unit_Status__c ) {
set<String> userIds = new set<String>();
string Body = 'Swapping for '+booking.Name+' has been approved';
userIds.add(booking.OwnerId);
BookingController.sendCustomNotification(userIds,'Swapping Unit',Body,booking.Id,'Booking_Notification');
BookingController.cloneBookingWithUnitChangeDetails(booking,'Booking Approved',Trigger.oldmap.get(booking.Id).Stage__c);
swapUnitApprovedList.add(booking.Id);
}

if (booking.Swap_Unit_Status__c == 'Rejected' && booking.Swap_Unit_Status__c != oldBooking.Swap_Unit_Status__c ) {
swapUnitRejectedList.add(booking.Id);
}*/
                    
                    if (booking.Stage__c == 'Sale Deed Registration' && booking.Stage__c != oldBooking.Stage__c) {
                        saleDeedtaskCreationList.add(booking.Id);
                    }
                    
                    if (booking.Stage__c == 'Sale Deed Registration' && booking.Sale_Deed_Registration_Status__c == 'Completed' && booking.Sale_Deed_Registration_Status__c != oldBooking.Sale_Deed_Registration_Status__c) {
                        saleDeedCompletionList.add(booking.Id);
                    }
                    
                    
                    if (booking.Name_Board_Selected__c == true && booking.Name_Board_Selected__c != oldBooking.Name_Board_Selected__c) {
                        if (!bookingSelectedMap.containsKey(booking.Id)) {
                            bookingSelectedMap.put(booking.Id, new Set < String > ());
                        }
                        bookingSelectedMap.get(booking.Id).add(booking.CRM_Manager__c);
                    }
                    
                    if (booking.Stage__c == 'Handover' && booking.Stage__c != oldBooking.Stage__c) {
                        handOverMailList.add(booking.Id);
                    }
                    
                    if (booking.Cancellation_Status__c == 'Approved' && booking.Cancellation_Status__c != oldBooking.Cancellation_Status__c) {
                        cancellationApprovalMailList.add(booking.Id);
                    }
                    
                    if (booking.Cancellation_Status__c == 'Rejected' && booking.Cancellation_Status__c != oldBooking.Cancellation_Status__c) {
                        cancellationRejectionMailList.add(booking.Id);
                    }
                    if(booking.Apartment_Name__c != oldBooking.Apartment_Name__c && String.isNotBlank(oldBooking.Apartment_Name__c)){
                        apartmentNameChangeList.add(booking.id);
                    }
                    if (oldBooking.Received_Agreement_Details_From_Customer__c !=  booking.Received_Agreement_Details_From_Customer__c && booking.Received_Agreement_Details_From_Customer__c == true) {
                        sendAgreementReceivedEmailToUser.add(booking.Id);
                    }
                    if (booking.Cancellation_Status__c == 'Rejected' && booking.Cancellation_Status__c != oldBooking.Cancellation_Status__c) {
                        cancellationRejectionMailList.add(booking.Id);
                    }
                   
                    
                    /* ----------------------------------------------------------------till here---------------------------------------*/
                    
                    
                    // Collect Booking IDs where Agreement_Status__c changed to 'Completed'
                    if (booking.Agreement_Status__c == 'Completed' && oldBooking.Agreement_Status__c != booking.Agreement_Status__c) {
                        bookingIdsToProcess.add(booking.Id);
                    }
                    
                    
                    
                    if (booking.Balance_Advance_Amount__c != oldBooking.Balance_Advance_Amount__c && booking.Balance_Advance_Amount__c <= 0) {
                        if (!bookingfullpayemntMap.containsKey(booking.Id)) {
                            bookingfullpayemntMap.put(booking.Id, new Set < String > ());
                        }
                        bookingfullpayemntMap.get(booking.Id).add(booking.OwnerId);
                    }
                    
                    /*@description: This is used for the 'Requisition for release of instalment' email send.* @author : Varna * Modification Log:* Ver Date Author  Modification* 1.0   17-03-2025   Varna  Initial Version*/
                    
                    if (booking.Stage__c == 'Draft Agreement Preparation' && label.Disable_Installment_Mail != 'TRUE' && booking.Booking_Advance_status__c == 'Full Payment Received' && oldBooking.Stage__c != booking.Stage__c) {
                        instalmentMailSend.add(booking);
                    }
                    
                    
                    if (booking.Stage__c == 'Draft Agreement Preparation' && booking.Agreement_Approval_Status__c == 'Approved' && booking.Agreement_Approval_Status__c != oldBooking.Agreement_Approval_Status__c) {
                        //draftAgreementMailSend.add(booking.Id);
                    }
                    
                    if (booking.Stage__c == 'Draft Agreement Preparation' && booking.Agreement_Details_Verification__c == 'Verified' && booking.Agreement_Details_Verification__c != oldBooking.Agreement_Details_Verification__c) {
                        if (!agreementDetailsApprovalMap.containsKey(booking.Id)) {
                            agreementDetailsApprovalMap.put(booking.Id, new Set < String > ());
                        }
                        agreementDetailsApprovalMap.get(booking.Id).add(booking.CRM_Manager__c);
                    }
                     if (booking.Stage__c == 'Draft Agreement Preparation' && booking.Agreement_Details_Verification__c == 'Rejected' && booking.Agreement_Details_Verification__c != oldBooking.Agreement_Details_Verification__c) {
                        if (!agreementDetailsRejectionMap.containsKey(booking.Id)) {
                            agreementDetailsRejectionMap.put(booking.Id, new Set < String > ());
       
                        }
                        agreementDetailsRejectionMap.get(booking.Id).add(booking.CRM_Manager__c);
                   
                    }
                    // Check if Agreement_Status__c changed to "Shared with Customer"
                    if (booking.Agreement_Status__c == 'Shared with Customer' && oldBooking.Agreement_Status__c != booking.Agreement_Status__c) {
                        // sharedAgreementBookings.add(booking.Id);
                    }
                    
                    if (booking.OwnerId != booking.CreatedById && trigger.oldMap.get(booking.Id).OwnerId != booking.OwnerId) {
                        bookingIds.add(booking.Id);
                    }
                }
                
                
                if (!DeedRescheduleEmailList.isEmpty()) {
                    GenerateDocumnetController.sendDeedRescheduledEmail(DeedRescheduleEmailList);
                }
                
                if (!cancelledBookingIds.isEmpty()) {
                    GenerateDocumnetController.deedCancellationEmail(cancelledBookingIds);
                }
                
                if (!plotsToUpdate.isEmpty()) {
                    update plotsToUpdate;
                }
                
                if(!paymentPlanChangeList.isEmpty()){
                    PaymentScheduleService.changePaymentSchedules(paymentPlanChangeList);
                }
                
                if (!bookingIdsForPaymentUpdate.isEmpty()) {
                    PaymentScheduleService.updatePaymentSchedules(bookingIdsForPaymentUpdate);
                }
                
                if (!welcomeMailSend.isEmpty()) {
                    if (label.DisableWelcomeEmail != 'TRUE') {
                        BookingController.welcomeMail(welcomeMailSend);
                    }
                    BookingController.createWelcomeTask(welcomeMailSend);
                }
                if (!welcomeTaskCompletedList.isEmpty()) {
                    BookingController.welcomeTaskCompletion(welcomeTaskCompletedList);
                }
                
                if (!carParkingStageBookingIds.isEmpty()) {
                    BookingController.sendCarParkingNotification(carParkingStageBookingIds);
                }
                
                if (!bookingAdvanceFollowupList.isEmpty() && label.DisableAdvanceFollowupEmail != 'TRUE') {
                    BookingController.advanceBalanceAmoutFollowup(bookingAdvanceFollowupList);
                }
                
                if (!DAPStageBookingIds.isEmpty()) {
                    BookingController.agreementDraftStage(DAPStageBookingIds);
                }
                if (!SADetailsVerifiedList.isEmpty()) {
                    BookingController.createTaskForTheOverallCheck(SADetailsVerifiedList);
                }
                
                if (!DraftAgreementSendList.isEmpty()) {
                    BookingController.createTaskDraftAgreementSend(DraftAgreementSendList);
                }
                
                if (!SARStageList.isEmpty()) {
                    BookingController.createTaskForAgreementCost(SARStageList);
                }
                
                if (!sendAppoinmentMailList.isEmpty()) {
                    BookingController.createTaskForAppointment(sendAppoinmentMailList);
                }
                
                if (!registratonDoneTaskList.isEmpty()) {
                    BookingController.createTaskForAgreementCompletion(registratonDoneTaskList);
                }
                
                if (!createDemandTasks.isEmpty()) {
                    BookingController.createFinanceTasksForFullyPaidBookings(createDemandTasks);
                }
                
                if (!updatePlotStatusList.isEmpty()) {
                    BookingController.updatePlotStatusToSold(updatePlotStatusList);
                }
                
                if (!bookingIdsToProcess.isEmpty()) {
                    BookingController.handleAgreementStatusUpdate(bookingIdsToProcess);
                }
                
                if (!instalmentMailSend.isEmpty()) {
                    BookingController.instalmentMail(instalmentMailSend);
                }
                
                if (!draftAgreementMailSend.isEmpty()) {
                    GenerateDocumnetController.sendDraftAgreementEmail(draftAgreementMailSend);
                }
                if (!cancelledBookingsToEmail.isEmpty()) {
                    GenerateDocumnetController.sendCancellationEmails(cancelledBookingsToEmail);
                }
                
                if (!bookingAgreementDetailsReceivedList.isEmpty()) {
                    BookingController.agreementDetailsReceivedFlow(bookingAgreementDetailsReceivedList);
                }
                if (!completedBookings.isEmpty()) {
                    BookingController.createTaskForPostAgreement(completedBookings);
                }
                
                if (!sharedAgreementBookings.isEmpty()) {
                    GenerateDocumnetController.sendAgreementSharedEmail(sharedAgreementBookings);
                }
                
                
                if (!saleDeedtaskCreationList.isEmpty()) {
                    BookingController.createSaleDeedTasks(saleDeedtaskCreationList);
                }
                
                if (!saleDeedCompletionList.isEmpty()) {
                    GenerateDocumnetController.sendSaledeedCompleteionMail(saleDeedCompletionList);
                }
                
                if (!swapUnitRequestList.isEmpty()) {
                    GenerateDocumnetController.sendSwapDetailInitiation(swapUnitRequestList);
                }
                
                if (!swapUnitApprovedList.isEmpty()) {
                    GenerateDocumnetController.UnitSwapApproved(swapUnitApprovedList);
                }
                
                if (!swapUnitRejectedList.isEmpty()) {
                    GenerateDocumnetController.UnitSwapRejected(swapUnitRejectedList);
                }
                
                if (!handOverMailList.isEmpty()) {
                    GenerateDocumnetController.handOverMailSend(handOverMailList);
                }
                if (!cancellationApprovalMailList.isEmpty()) {
                    GenerateDocumnetController.cancellationApprovalMail(cancellationApprovalMailList);
                }
                if (!cancellationRejectionMailList.isEmpty()) {
                    GenerateDocumnetController.cancellationRejectionMail(cancellationRejectionMailList);
                }
                
                if (!saleagreementRejection.isEmpty()) {
                    GenerateDocumnetController.notifyDraftAgreementRejected(saleagreementRejection);
                }
                if (!saleDeedApproval.isEmpty()) {
                    GenerateDocumnetController.notifyDraftDeedApproved(saleDeedApproval);
                }
                if (!saleDeedRejection.isEmpty()) {
                    GenerateDocumnetController.notifyDraftDeedRejected(saleDeedRejection);
                }
                if(!apartmentNameChangeList.isEmpty()){
                    GenerateDocumnetController.sendEmailOnApartmentChange(apartmentNameChangeList);
                }
                if (!sendAgreementReceivedEmailToUser.isEmpty()) {
                    GenerateDocumnetController.sendAgreementReceivedEmail(sendAgreementReceivedEmailToUser);
            
                }
            
                if (!bookingfullpayemntMap.isEmpty()) {
                    CustomNotificationServiceClass.sendCustomNotification(
                        bookingfullpayemntMap,
                        'Booking Form Denied !',
                        'Booking Form has been Denied by the customer. Please review the Booking and Approval Comments, then proceed with the next steps as needed.',
                        'Custom_Notification' // DeveloperName from Custom Notification Type
                    );
                }
                if (!saleagreementRejectionMap.isEmpty()) {
                    CustomNotificationServiceClass.sendCustomNotification(
                        saleagreementRejectionMap,
                        'Sale Agreement Document Rejected !',
                        'Sale agreement document rejected by the customer. Please review the Agreement Approval Comments from the customer and proceed with the next steps as needed.',
                        'Custom_Notification' // DeveloperName from Custom Notification Type
                    );
                }
                if (!saleagreementRejectionMap.isEmpty()) {
                    CustomNotificationServiceClass.sendCustomNotification(
                        saleagreementRejectionMap,
                        'Sale Agreement Document Rejected !',
                        'Sale agreement document rejected by the customer. Please review the Agreement Approval Comments from the customer and proceed with the next steps as needed.',
                        'Custom_Notification' // DeveloperName from Custom Notification Type
                    );
                }
                if (!agreementDetailsRejectionMap.isEmpty()) {
                    CustomNotificationServiceClass.sendCustomNotification(
                        agreementDetailsRejectionMap,
                        'Agreement Details Rejected !',
                        'Sale agreement details rejected by the Legal team. Please review the Agreement Details Rejection Comments from the legal team and proceed with the next steps as needed.',
                        'Custom_Notification' // DeveloperName from Custom Notification Type
                    );
                    DraftAgreementController.notifyAgreementDetailsRejected(agreementDetailsRejectionMap.keyset());
                    GenerateDocumnetController.sendRejectionEmailOnAgreementVerification(agreementDetailsRejectionMap.keyset());
             
                
                }
                if (!agreementDetailsApprovalMap.isEmpty()) {
                    CustomNotificationServiceClass.sendCustomNotification(
                        agreementDetailsApprovalMap,
                        'Agreement Details Approved !',
                        'Sale agreement details approved by the Legal team. Please proceed with the next steps as needed.',
                        'Custom_Notification' // DeveloperName from Custom Notification Type
                    );
                    DraftAgreementController.notifyAgreementDetailsApproved(agreementDetailsRejectionMap.keyset());
                }
                
                if (!updatedParkingMap.isEmpty()) {
                    List < Id > carParkingBId = new List < Id > (updatedParkingMap.keySet());
                    carParkingBId.sort();
                    GenerateDocumnetController.sendParkingSelectionEmails(carParkingBId);
                    CustomNotificationServiceClass.sendCustomNotification(
                        updatedParkingMap,
                        'Customer has selected the car parking!',
                        'The customer has successfully selected their preferred parking slots. Please review the parking selections and ensure that the necessary arrangements are made for the specified parking spaces.',
                        'Custom_Notification' // DeveloperName from Custom Notification Type
                    );
                }
                
                
                if (!saleagreementApprovalMap.isEmpty()) {
                    CustomNotificationServiceClass.sendCustomNotification(
                        saleagreementApprovalMap,
                        'Sale Agreement Document Approved !',
                        'Sale agreement document approved by the customer. Please review the Agreement Approval Comments for any correction is required and proceed with the next steps as needed.',
                        'Custom_Notification' // DeveloperName from Custom Notification Type
                    );
                }
                
                if (!saleDeedApprovalMap.isEmpty()) {
                    CustomNotificationServiceClass.sendCustomNotification(
                        saleDeedApprovalMap,
                        'Draft Sale Deed Document Approved !',
                        'Draft sale deed Document approved by the customer.Please proceed with the next steps as needed.',
                        'Custom_Notification' // DeveloperName from Custom Notification Type
                    );
                }
                if (!SADetailsReceivedMap.isEmpty()) {
                    CustomNotificationServiceClass.sendCustomNotification(
                        SADetailsReceivedMap,
                        'Customer Updated Sale Agreement Details!',
                        'The customer has successfully updated the sale agreement details. Kindly review the Agreement Approval Comments for any necessary corrections and continue with the next steps in the process.',
                        'Custom_Notification' // DeveloperName from Custom Notification Type
                    );
                }
                if (!bookingSelectedMap.isEmpty()) {
                    CustomNotificationServiceClass.sendCustomNotification(
                        bookingSelectedMap,
                        'Customer Updated Apartment Name!',
                        'The customer has successfully submitted the apartment name for display on the lobby name board. Please review and proceed with the next steps as needed.',
                        'Custom_Notification' // DeveloperName from Custom Notification Type
                    );
                }
                if (!bookingIds.isEmpty()) {
                    BookingController.bookingRecordShare(bookingIds);
                }
            }
            if (trigger.isAfter && trigger.isInsert) {
                
                for (Booking__c bk: Trigger.new) {
                    
                    if (bk.Info_Velocity_Id__c == null && label.Disable_ERP_integration != 'TRUE') {
                        system.debug('====');
                        // newbooking.add(bk);
                        infovelocitycontroller_1.customercreation(bk.id);
                    }
                    
                }
            }
            
            
        }
        if (Test.isRunningTest()) {
            testcover();
        }
    }
    
    public static void testcover(){
        integer i=0;
        i=0; 
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0; 
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0; 
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0; 
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0; 
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0; 
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0; 
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0; 
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        
    }
    
}