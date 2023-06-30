public with sharing class AssetTriggerHandler extends TriggerHandler {
    private Map<Id, Asset> newAssetMap;
    private Map<Id, Asset> oldAssetMap;
    public AssetTriggerHandler() {
        this.newAssetMap = (Map<Id, Asset>) Trigger.newMap;
        this.oldAssetMap = (Map<Id, Asset>) Trigger.oldMap;
    }
    public override void afterInsert(){
        Map<Id, Asset> newAssetMap = this.newAssetMap;
        System.debug('newAssetMap:'+ newAssetMap);
        if(newAssetMap.keySet().size() > 0){
            //AssetTriggerHelper.generateAssetExternalId(newAssetMap.keySet());
        }
    }
}