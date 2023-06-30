public with sharing class AssetTriggerHelper {
    static String ASSET_SOBJECT_TYPE = 'Asset';
    static List<Asset> currentAssets;
    
    public static void generateAssetExternalId(Set<Id> assetIds){
        List<Asset> assets = [SELECT ID, RecordTypeId, ProductCode FROM Asset WHERE ID in :assetIds];
        List<Asset> assetsToUpdate = new List<Asset>();
        Map<String, String> assetRTPrefixMap = new Map<String, String>();
        Map<String, Decimal> assetIncrementMap = new Map<String, Decimal>();
        Map<ID, String> productRTMap = new Map<Id, String>();
        Map<ID, String> productCodeMap = new Map<Id, String>();
        // map asset record types
        for(RecordType RT: [SELECT ID, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType =:ASSET_SOBJECT_TYPE]){
            productRTMap.put(RT.ID, RT.DeveloperName);
        }
        //get increment map mdt
        for(AssetIncrementManager__mdt incManager : [SELECT Asset_Identifier__c, AssetIncrementCounter__c FROM AssetIncrementManager__mdt]){
            assetIncrementMap.put(incManager.Asset_Identifier__c, incManager.AssetIncrementCounter__c);
        }
        //get Asset Record Prefix map mdt
        for(AssetPrefixMapping__mdt assetPrefMap: [SELECT Prefix__c, RecordTypeDeveloperName__c FROM AssetPrefixMapping__mdt]){
            assetRTPrefixMap.put(assetPrefMap.RecordTypeDeveloperName__c, assetPrefMap.Prefix__c);
        }
        // generate external id
        for(Asset assetElement: assets){
            Asset assetToUpdate = new Asset();
            assetToUpdate.Id = assetElement.Id;
            String assetIdentifier = assetRTPrefixMap.get(productRTMap.get(assetElement.RecordTypeId)) + '-' + assetElement.ProductCode;
            String newAssetIdentifier;
            if(assetIncrementMap != null && assetIncrementMap.keySet() != null && assetIncrementMap.keySet().contains(assetIdentifier)){
                newAssetIdentifier = assetIdentifier + '-' + UtilityClass.formatInteger(assetIncrementMap.get(assetIdentifier));
                //increment
                assetIncrementMap.put(assetIdentifier, assetIncrementMap.get(assetIdentifier) + 1);
            }else{
                assetIncrementMap.put(assetIdentifier, 1);
                newAssetIdentifier = assetIdentifier  + '-0000';
            }
        }
        //update increment metadata
        List<Map<String, Object>> mapTestDataLst = new List<Map<String, Object>>();
        for(String incManager : assetIncrementMap.keySet()){
            Map<String, Object> mapTestData = new Map<String, Object>();
            mapTestData.put('Asset_Identifier__c', incManager);
            mapTestData.put('label', incManager);
            mapTestData.put('AssetIncrementCounter__c', assetIncrementMap.get(incManager));
            mapTestDataLst.add(mapTestData);
        }
        metadataInsertUpdate.handleInsertAndUpdate(mapTestDataLst);
        //updateAssets();
    }
}