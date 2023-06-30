public with sharing class AssetTriggerHandler extends TriggerHandler {
    private Map<Id, Asset> newAssetMap;
    private Map<Id, Asset> oldAssetMap;
    public AssetTriggerHandler() {

    }
    public override void afterDelete(){
       /* Map<Id, Asset> newAssetMap = this.newAssetMap;
        
        if(opptiesToProcess.size() > 0){
            OpportunityTriggerHelper.closedWonProcessing(opptiesToProcess);
        }*/
    }
}