public with sharing class CampaignManager {
    
    @AuraEnabled(cacheable=true)
    public static List<Object> execute(String action,Map<String, Object> params){
        switch on action {
            when 'getOpportunitiesByCampaignId' {
                return new DatatableDashboardService().getOpportunitiesByCampaignId((String)params.get('campaignId'));
            }
            when else {
                return null;
            //throw new BaseException('Method not implemented');
            }
        }
    }
    /*public class DataWrapper {
        @auraEnabled
        public List<sObject> dataResult{get;set;}
        @auraEnabled
        public List<Map<String ,String>> columns{get;set;}
    }*/
}