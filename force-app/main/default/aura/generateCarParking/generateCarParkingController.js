({
    doInit : function(component, event, helper) {
        let baseUrl = window.location.origin;
        var recordId = component.get("v.recordId");
        var url = baseUrl+'/apex/CarParkingSelection?Id='+component.get("v.recordId");
        var action = component.get("c.getBookingRecord");
        action.setParams({
            "recordId": recordId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var booking =result.booking;
                var floorParking = result.parkingFloorNames;
                //var trimmedFloorNames = floorParkingLevel.replace(/ *floor/gi, '').trim();
                //var trimmedFloorNames = floorParkingLevel.replace(/\b[Ff]loor\b/g, '').trim();
                var customerName = booking.salutation_Applicant1__c+' '+booking.First_Applicant_Name__c;
                var projectName = booking.Project__c;
                var individualParking = booking.No_of_Indivisual_Car_Parking__c;
                var backtobackParking = booking.No_of_Back_to_Back_Car_Parking__c;
                var extraIndividualParking = booking.No_of_additional_Individual_car_parkings__c;
                var extraBackToBackParking = booking.No_of_additional_Back_to_back_car_parki__c;
                var additionalNote = '';
                if (backtobackParking != null) {
                    additionalNote = "Back to Back Parking: " + "0"+backtobackParking+"<br/>";; 
                }
                var NoOfExtraIndividualCarParking= '';
                if (extraIndividualParking!=null){
                   NoOfExtraIndividualCarParking = "No. of Extra Individual Car Parking :"+"0"+extraIndividualParking+"<br/>";
                }
                var NoOfExtraBackToBackCarParking= '';
                if(extraBackToBackParking != null){
                    NoOfExtraBackToBackCarParking = "No. of Extra Back to Back Car Parking :"+"0"+extraBackToBackParking+"<br/>";
                }
                // console.log ('individualParking'+individualParking);
                var defaultEmailContent = "<div style='color: black;'>Dear " + customerName;
                defaultEmailContent +="<br/><br/><strong>Greetings From Veegaland Developers.</strong><br/><br/>"+
                    "We would like to inform you that we are giving special privileges to our existing customers to choose their preferred parking in our prestigious project <strong>" +projectName +"</strong>.<br/><br/>"+
                    "So, we are hereby requesting you to choose your parking slot for your apartment in the project. You may please find attached herewith the parking layout <strong>" +floorParking+ "</strong> level. You may kindly go through the layout and choose your preferred parking and let us know via a reply mail, so that we can verify, block and give you a confirmation on the same. Your selected parking number will be also mentioned in your sale agreement<br/><br/>"+
                    
                    "<strong>Available car parking slot for customer : </strong><br/><br/>"+
                    "<strong>Individual Car Parking :"+ " 0"+individualParking + "<br/>"+additionalNote + NoOfExtraIndividualCarParking + NoOfExtraBackToBackCarParking+ "</strong><br/>"+
                   
                    "<strong>Car Parking Selection Link</strong> : "+
                    "<a href='https://site-speed-6226--postsbox1.sandbox.my.salesforce-sites.com/slotSelection?id="+recordId+ "'>Please select Carparking Slot</a><br/><br/>"+

                    
                    
                    "<strong>KINDLY NOTE , PARKING SLOTS WITH  BACK TO BACK PARKING WILL BE ADDITIONAL COST</strong><br/><br/>"+
                    "<strong>Note : We kindly request you to finalize your car parking selection within the next 24 hours. If we do not receive your confirmation within this time frame, we may need to allocate the parking space to another customer on our waiting</strong><br/><br/>"+
                    "Thanks & Regards,<br/><br/>"+
                    "<strong>Midhu Siju | Officer - Customer relations | 9207054444</strong><br/>"+
                    "<strong>Alitta Lijoy | Customer relation Executive | 90482 37066</strong><br/><br/>"+
                    "<strong>Veegaland Developers Limited</strong><br/>"+
                    "Regd.Office:XXXV/564, 4TH FLOOR, <br/>"+
                    "K C F TOWER, BHARAT MATHA COLLEGE ROAD, KAKKANADU, <br/>"+
                    "Thrikkakara,Ernakulam- 682021, Kerala<br/>"+
                    "Tel: +91 484 2584000/2973944, +916235051144<br/>"+
                    "<a href='http://www.veegaland.com/'>www.veegaland.com</a><br/>"+
                    '<html> <body>Follow us on: <a href="https://www.facebook.com/VeegaLandHomes/" target="_blank">Facebook</a> | <a href="https://www.instagram.com/veegalandhomes/" target="_blank">Instagram</a> | <a href="https://in.linkedin.com/company/veegaland-homes" target="_blank">LinkedIn</a> | <a href="https://www.youtube.com/channel/UCkumX_5xi6KOrmm7oaO93kQ" target="_blank">YouTube</a></body></html>';
                
                component.set("v.vfPageUrl", url);
                component.set("v.emailContent", defaultEmailContent);
            } else {
                console.error("Error retrieving record data");
            }
        });
        
        $A.enqueueAction(action);
    },
   sendEmail: function(component, event, helper) {
    // Prevent multiple clicks
    if (component.get("v.isSending")) {
        return;
    }

    component.set("v.isSending", true);

    // Call the Apex method
    var action = component.get("c.sendEmailGenerateCarParking");
    action.setParams({
        "recId": component.get("v.recordId"),
        "emailContent": component.get("v.emailContent")
    });

    action.setCallback(this, function(response) {
        var state = response.getState();
        
        // enabling the button after the apex call back
        component.set("v.isSending", false); 

        if (state === 'SUCCESS') {
            var res_string = response.getReturnValue();
            event.stopPropagation();

            // Close modal
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();

            // Toast message
            var type = res_string === 'Email sent successfully' ? 'success' : 'error';
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": type,
                "title": type,
                "message": res_string,
                "duration": 10000
            });
            toastEvent.fire();

            $A.get('e.force:refreshView').fire();
        } else if (state === 'ERROR') {
            component.set("v.isSending", false);
            console.error('Failed to send email: ', response.getError());
        }
    });

    $A.enqueueAction(action);
},

    close : function(component, event, helper) {
        event.stopPropagation();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
})