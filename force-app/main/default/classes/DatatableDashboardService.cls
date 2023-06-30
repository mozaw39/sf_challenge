public with sharing class DatatableDashboardService {
    public List<Opportunity> getOpportunitiesByCampaignId(String campaignId){
        List<Opportunity> opportunitiesResult;
        List<Campaign> lstCampaign= [SELECT ID, (SELECT AccountId,Account.Name, StageName, Type, CreatedDate, CloseDate, Description FROM OPPORTUNITIES) FROM CAMPAIGN WHERE Id =:campaignId];
        if(lstCampaign.size()>0 && lstCampaign[0].opportunities.size() > 0){
            opportunitiesResult = lstCampaign[0].opportunities;
        }
        return opportunitiesResult;
    }//Account Name, StageName, Type, CreatedDate, CloseDate, Description
}