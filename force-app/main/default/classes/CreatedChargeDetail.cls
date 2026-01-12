public without sharing class CreatedChargeDetail {
    
    public static final String[] CHARGE_TYPES = new String[]{
        'Apartment Cost', 'CGST-Output CGST - 3.75%', 'SGST-Output SGST - 3.75%', 'BASIC COST', 'CAR PARKING','FLOOR RISE CHARGE'
            };
               
    public static void createdcharge(List<Quote__c> listquote) {
        List<Charge_Type__c> chrtyplist = new List<Charge_Type__c>();
        Set<Id> quotesId = new Set<Id>();
        for (Quote__c qt : listquote) {
            quotesId.add(qt.Id);
        }

        Map<String, Charge_Type__c> chargetypMap = new Map<String, Charge_Type__c>();
        for (Charge_Type__c ct : [ SELECT Id, Name, Chargetype_Id__c, Amount_Type__c,  Rate_or_Fixed_Amount__c, Charge_Amount__c, Unit__c,  Charge_Type__c, Quote__c  FROM Charge_Type__c  WHERE Quote__c IN :quotesId
        ]) {
            chargetypMap.put(ct.Quote__c + ct.Name, ct);
        }

        for (Quote__c un : listquote) {
            for (String chargeName : CHARGE_TYPES) {
                Charge_Type__c ct = chargetypMap.get(un.Id + chargeName);
                if (ct == null) {
                    ct = new Charge_Type__c();
                }

                ct.Name = chargeName;
                ct.Quote__c = un.Id;
                ct.Unit__c = un.Unit__c;

                if (chargeName == 'Apartment Cost') {
                    ct.Chargetype_Id__c = '1';
                    ct.Amount_Type__c = '0';
                    ct.Rate_or_Fixed_Amount__c = un.Special_Launch_Base_Rate__c;
                    ct.Charge_Amount__c = un.Apartment_Cost_Including_Car_Parking__c;
                    ct.Charge_Type__c = 'Charge Detail';
                }
                else if (chargeName == 'CGST-Output CGST - 3.75%') {
                    ct.Chargetype_Id__c = '2';
                    ct.Amount_Type__c = '1';
                    ct.Rate_or_Fixed_Amount__c = 2.5;
                    ct.Charge_Amount__c = (un.Apartment_Cost_Including_Car_Parking__c * 2.5) / 100;
                    ct.Charge_Type__c = 'Charge Detail';
                }
                else if (chargeName == 'SGST-Output SGST - 3.75%') {
                    ct.Chargetype_Id__c = '3';
                    ct.Amount_Type__c = '1';
                    ct.Rate_or_Fixed_Amount__c = 2.5;
                    ct.Charge_Amount__c = (un.Apartment_Cost_Including_Car_Parking__c * 2.5) / 100;
                    ct.Charge_Type__c = 'Charge Detail';
                }
                else if (chargeName == 'BASIC COST') {
                    ct.Chargetype_Id__c = '1';
                    ct.Rate_or_Fixed_Amount__c = un.Total_Basic_Price__c - (un.Floor_Rise_Charges__c * un.Built_up_area__c);
                    ct.Charge_Type__c = 'Passive Charge';
                }
                else if (chargeName == 'CAR PARKING') {
                    ct.Chargetype_Id__c = '2';
                    ct.Rate_or_Fixed_Amount__c = un.Car_Parking_Charge__c + un.Extra_car_parking_charges__c;
                    ct.Charge_Type__c = 'Passive Charge';
                }
                else if (chargeName == 'FLOOR RISE CHARGE') {
                    ct.Chargetype_Id__c = '3';
                    ct.Rate_or_Fixed_Amount__c = un.Floor_Rise_Charges__c * un.Built_up_area__c;
                    ct.Charge_Type__c = 'Passive Charge';
                }

                chrtyplist.add(ct);
            }
        }

        if (!chrtyplist.isEmpty()) {
            upsert chrtyplist;
        }
    }

}