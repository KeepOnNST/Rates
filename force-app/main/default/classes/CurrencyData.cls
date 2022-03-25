public with sharing class CurrencyData implements Schedulable{

    public void execute(SchedulableContext ctx){
        String apiKey = [SELECT Api_Key__c FROM Currency_Values__mdt].Api_Key__c;
        String defaultCurrency = [SELECT Default_Currency__c FROM Currency_Values__mdt].Default_Currency__c;
        List<String> pickListValuesList= new List<String>();
        String findingCurrencies = '';
        Map<String,Object> results = new Map<String,Object>();
        Datetime dateCurrency;
        Map<String,String> labels = new Map<String,String>();
        String currencyDate;
        Exchange_Rate__c insertingRecord = new Exchange_Rate__c();
		Schema.DescribeFieldResult fieldResult = Exchange_Rate__c.Base_Currency__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

		for(Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		}
        for(integer i=0; i<pickListValuesList.size(); i++){
            if (pickListValuesList[i] != defaultCurrency){
                findingCurrencies += pickListValuesList[i] + ',';
            }
        }
        findingCurrencies = findingCurrencies.removeEnd(',');
        System.debug('Needed string ' + findingCurrencies);

        http http = new http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.fastforex.io/fetch-multi?from=' + defaultCurrency + '&to=' + findingCurrencies + '&api_key='+ apiKey);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200) {
            Map<String, Object> rate = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            results =(Map<String, Object>) rate.get('results');
            currencyDate =(String)rate.get('updated');
            dateCurrency = datetime.valueOf(currencyDate);
        }       
        insertingRecord.Base_Currency__c = defaultCurrency;
        insertingRecord.Date__c = dateCurrency;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get('Exchange_Rate__c').getDescribe().fields.getMap();
        for(String fieldName : fieldMap.keyset())
            {
                if(fieldName.length() == 6 && fieldName != 'Log__c')
                labels.put(fieldMap.get(fieldName).getDescribe().getLabel(),fieldName);
                // labels.add(fieldMap.get(fieldName).getDescribe().getLabel());
            }
        for (String eachCurrency : labels.keyset()) {
            insertingRecord.put(labels.get(eachCurrency),results.get(eachCurrency));
        }

    }

    // public class Currencies {
    //     @AuraEnabled public Map<String,Object> results = new Map<String,Object>();
    //     @AuraEnabled public Date dateCurrency = new Date();
    // }
}
