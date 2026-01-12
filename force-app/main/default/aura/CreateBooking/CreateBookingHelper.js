({
    addAppliacantRecord: function(component, event, helper) {
        var appList = component.get("v.applicantList");
        appList.push({
            'sObjectType': 'Co_Applicant__c',
            'Salutation__c':'',
            'Name':'',
            'Relalation_Details__c':'Son',
            'W_o_S_o_C_o_c__c':'',
            'Contact_Number__c':'',
            'Country__c': '',
            'Date_of_Birth__c': '',
            'Email__c': '',
            'PAN_Number__c': '',
            'Booking__c':''        
        });
        component.set("v.applicantList", appList);
    },
    getBookingPicklists: function (component, event, helper) {
        var action = component.get("c.getBookingPicklists");
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var picklists = response.getReturnValue();
                component.set("v.paymentTypePicklist", picklists.ModeOfPayment);
                component.set("v.fundingTypePicklist", picklists.FundingType);
                component.set("v.advanceBankPicklist", picklists.AdvanceBank);
                component.set("v.paymentFromPicklist", picklists.PaymentFrom);
                component.set("v.categoryPicklist", picklists.category);
                component.set("v.bookingThroughPicklist", picklists.bookingThrough);
                component.set("v.bookedAtPicklist", picklists.bookedAt);
                component.set("v.bookingTypePicklist", picklists.bookingType);
            }
        });
        $A.enqueueAction(action);
    },
    mapQuoteToBooking: function(component,quote) {
        let fieldMapping = {
            'Primary_Applicant_Name__c': 'First_Applicant_Name__c',
            'Primary_Applicant_Saluaion__c': 'salutation_Applicant1__c',
            'Primary_Applicant_DoB__c': 'Date_of_Birth1__c',
            'Primary_Applicant_NRI_RI__c': 'Primary_Applicant_NRI_RI__c',
            'Primary_Applicant_Profession__c': 'Occupation__c',
            'Primary_Applicant_Father_Husband_s_Name__c': 'Primary_Applicant_Father_Husband_s_Name__c',
            'Primary_Applicant_PAN__c': 'PAN_Number1__c',
            'Primary_Applicant_Aadhaar_No__c': 'Aadhaar_Number__c',
            'Primary_Applicant_Passport_No__c': 'Passport_Aadhar__c',
            'Primary_Applicant_Driving_License_No__c': 'Primary_Applicant_Driving_License_No__c',
            'Primary_Applicant_Email__c': 'Email1__c',
            'Primary_Applicant_Mobile_No__c': 'Mobile_Primary__c',
            'Primary_Applicant_Telephone_No__c': 'Mobile_Primary2__c',
            'Permanent_House_No_Name__c': 'Permanent_House_No_Name__c',
            'Permanent_Street_Location__c': 'Permanent_Street_Location__c',
            'Permanent_Post_Office__c': 'Permanent_Post_Office__c',
            'Permanent_City__c': 'Permanent_City__c',
            'Permanent_State__c': 'Permanent_State__c',
            'Permanent_Postal_Code__c': 'Permanent_Postal_Code__c',
            'Permanent_Country__c': 'Permanent_Country__c',
            'Primary_Applicant_International_No__c': 'Primary_Applicant_International_No__c',
            'Correspondence_House_No_Name__c': 'Correspondence_House_No_Name__c',
            'Correspondence_Street_Location__c': 'Correspondence_Street_Location__c',
            'Correspondence_Post_Office__c': 'Correspondence_Post_Office__c',
            'Correspondence_City__c': 'Correspondence_City__c',
            'Correspondence_State__c': 'Correspondence_State__c',
            'Correspondence_Postal_Code__c': 'Correspondence_Postal_Code__c',
            'Correspondence_Country__c': 'Correspondence_Country__c',
            'Actual_Base_Rate__c': 'Base_Rate__c',
            'Floor_Rise_Charges__c': 'Floor_Rise_Charges_Rate__c',
            'Car_Parking_Charge__c': 'Covered_Park_Parking__c',
            'Extra_car_parking_charges__c': 'Extra_Covered_Parking_Charges__c',
            'Additional_Car_Parking_Required__c': 'Additional_Car_Parking_Required__c',
            'Built_up_area__c': 'Built_up_area__c',
            'Open_Terrace_Area_Charges__c': 'Open_Terrace_Area_Charges__c',
            'Terrace_Area_SqFt__c': 'Terrace_Area_SqFt__c',
            'Common_Area_SqFt__c': 'Common_Area_SqFt__c',
            'Landscape_Charge__c': 'Landscape_Charge__c',
            'Lead_Source__c':'Enquiry_Source__c',
            'Lead_Date__c':'Lead_Created_Date__c',
            'Lead_Country_Code__c':'Country_Code__c',
            'Project__c': 'Project__c',
            'Block__c': 'Block1__c',
            'Special_Launch__c': 'Special_Launch__c',
            'Discount_In_Rupees__c': 'Discount__c',
            'BHK_Type__c': 'BHK_Type__c',
            'Leads__c': 'SLead__c',
            'Unit__c': 'Plot__c',
            'Payment_Plan__c': 'Payment_Plan__c',
            'Advance_Amount_Received__c':'Booking_Advance_Paid__c', // Handle duplication
            'GST__c':'GST__c',
            'Projects__c':'Project1__c',
            'Payment_Bank_Name__c':'Advance_Payment_Bank__c',
            'Payment_From__c':'Advance_Payment_From__c',
            'Draft_Cheque_RTGS_NEFT_No__c':'Cheque_DD_NEFT_RTGS_No__c',
            'Mode_of_Payment__c':'Mode_Of_Payment__c',
            'No_of_Back_to_Back_Car_Parking__c':'No_of_Back_to_Back_Car_Parking__c',
            'No_of_Individual_Car_Parking__c':'No_of_Indivisual_Car_Parking__c',
            'No_of_Extra_Back_to_Back_Car_Parking__c':'No_of_additional_Back_to_back_car_parki__c',
            'No_of_Extra_Individual_Car_Parking__c':'No_of_additional_Individual_car_parkings__c',
            'Date_Of_Transaction__c':'Advance_Transaction_Date__c',
            'WhatsApp_Number__c':'WhatsApp_Number__c',
            'Primary_Applicant_Secondary_Email__c':'Primary_Applicant_Secondary_Email__c',
            'OwnerId':'OwnerId',
            'Branch__c':'Advance_Branch__c',
            'Booking_Currency__c':'' // Empty string; consider leaving undefined
            
        };
        let msg='';
        let mappedBooking = {};
        for (let quoteField in fieldMapping) {
            
            let bookingField = fieldMapping[quoteField];
            if (bookingField !== null) {
                mappedBooking[bookingField] = quote[quoteField];
            }
            if (quoteField === 'Booking_Currency__c') {
                mappedBooking['Booking_Currency__c'] = 'Indian Rupee';
            }
            
            // Check and fix the country code for 'Country_Code__c'
            if (quoteField === 'Lead_Country_Code__c' && mappedBooking['Country_Code__c']) {
                if (!mappedBooking['Country_Code__c'].startsWith('+')) {
                    mappedBooking['Country_Code__c'] = `+${mappedBooking['Country_Code__c']}`;
                }
            }
            
            mappedBooking['Individual_Car_Parking_Area__c'] = '14.85';
            mappedBooking['Back_To_Back_Car_Parking_Area__c'] = '29.7Sq.M2';
            mappedBooking['Individual_Car_Parking_Dimension__c'] = '2.7m x 5.5m';
            mappedBooking['Back_To_Back_Car_Parking_Dimension__c'] = '2.7m x 11m';
        } 

        let missingFields = [];
        
        const requiredFields = [
            { field: 'salutation_Applicant1__c', label: 'Primary Applicant salutation' },
            { field: 'First_Applicant_Name__c', label: 'Primary Applicant First Name' },
            { field: 'Date_of_Birth1__c', label: 'Primary Applicant DOB' },
            { field: 'PAN_Number1__c', label: 'PAN Number' },
            { field: 'Aadhaar_Number__c', label: 'Aadhaar Number' },
            { field: 'Primary_Applicant_NRI_RI__c', label: 'Residential Status' }
        ];
        
        // Check for missing required fields
        requiredFields.forEach(field => {
            if (!mappedBooking[field.field]) missingFields.push(field.label);
        });
        
        // If NRI, ensure the International Mobile Number is checked
        if (mappedBooking['Primary_Applicant_NRI_RI__c'] === 'NRI' && !mappedBooking['Primary_Applicant_International_No__c']) {
            missingFields.push('International Mobile Number');
        }else if(!mappedBooking['Mobile_Primary__c']){
               missingFields.push('Primary Mobile Number');
        }
        
        // If there are missing fields, show the error message
        if (missingFields.length) {
            component.find('notifLib').showNotice({
                "variant": "error",
                "header": "Mandatory fields missing!",
                "message": "Please fill the following fields: " + missingFields.join(', '),
                "title": 'Error!!',
                closeCallback: function() {}
            });
        } else {
            component.set('v.isSubmit', false);
        }
        
        
        return mappedBooking;
    }
    
    
})