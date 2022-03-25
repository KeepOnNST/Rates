public with sharing class DisplayExchangeRate {

    @AuraEnabled
    // Datetime currentCurrency
    public static Map<String,Object> getRecord () {
        // Exchange_Rate__c outputCurrency = new Exchange_Rate__c();
        // [SELECT FIELDS(CUSTOM) FROM Exchange_Rate__c WHERE Date__c =: currentCurrency];
        Map<String,Object> finalCurrencyMap = new Map<String,Object> ();
        String defaultCurrency = [SELECT Default_Currency__c FROM Currency_Values__mdt].Default_Currency__c;
        String labelsGET = '';
        List<String> Names = new List<String>();
        List<Object> values = new List<Object>();

        Map<String, Schema.SObjectType> schemaMapGET = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMapGET = schemaMapGET.get('Exchange_Rate__c').getDescribe().fields.getMap();
        for (String fieldName : fieldMapGET.keyset()) {
            if(fieldName.length() == 6 && fieldName != 'Log__c' && fieldName != defaultCurrency) {
                labelsGET += fieldName + ',';
                Names.add(fieldName);
            }
        }
        labelsGET = labelsGET.removeEnd(',');
        Exchange_Rate__c outputCurrency = Database.query('SELECT ' + labelsGET +' FROM Exchange_Rate__c WHERE Date__c =: YESTERDAY');
        for(String fieldNames : Names) {
            values.add(outputCurrency.get(fieldNames));
        }

        for (integer i=0; i<Names.size(); i++) {
            finalCurrencyMap.put(Names[i],values[i]);
        }
        return finalCurrencyMap;
    }

    @AuraEnabled
    public static String getDefaultCity () {
        String def = [SELECT Default_Currency__c FROM Currency_Values__mdt].Default_Currency__c;
        return def;
    }
}
