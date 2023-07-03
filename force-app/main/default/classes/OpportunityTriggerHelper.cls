public with sharing class OpportunityTriggerHelper {
    static String ASSET_SOBJECT_TYPE = 'Asset';
    // handle closed won opportunities process
    //@future
    public static void closedWonProcessing(Set<Id> opportunitiesIds){
        List<Asset> assetsToCreate = new List<Asset>();
        Map<ID, String> productRTMap = new Map<Id, String>();
        Map<String, String> assetRTPrefixMap = new Map<String, String>();
        Map<String, List<Asset>> identifierAssetMap = new Map<String, List<Asset>>();
        Map<String, Integer> identifierIncrementMap = new Map<String, Integer>();
        Map<String, Id> productRecordTypesMap = new Map<String, Id>();
        Map<ID, String> productCodeMap = new Map<Id, String>();
        map<Id, Opportunity> opptiesMap = new Map<Id, Opportunity>([SELECT ID, AccountId, CloseDate FROM OPPORTUNITY WHERE ID IN :opportunitiesIds]);
        // map asset record types
        for(RecordType RT: [SELECT ID, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType =:ASSET_SOBJECT_TYPE]){
            productRecordTypesMap.put(RT.DeveloperName, RT.ID);
            productRTMap.put(RT.ID, RT.DeveloperName);
        }
        for(OpportunityLineItem OLI: [SELECT ID, OpportunityId, Product2Id, UnitPrice, Product2.Name, Product2.ProductCode, Product2.RecordType.DeveloperName FROM OpportunityLineItem WHERE OpportunityId in :opportunitiesIds]){
            Asset assetToCreate = new Asset();
            //popluate fields from opportunity
            assetToCreate.Opportunity__c = OLI.OpportunityId;
            assetToCreate.AccountId = opptiesMap.get(OLI.OpportunityId).AccountId;
            assetToCreate.PurchaseDate = opptiesMap.get(OLI.OpportunityId).CloseDate;
            //populate fields from OLI
            assetToCreate.Opportunity_Product__c = OLI.Id;
            assetToCreate.Price = OLI.UnitPrice;
            //populate fields from OLI Product
            assetToCreate.Name = OLI.Product2.Name;
            productCodeMap.put(OLI.Product2Id, OLI.Product2.ProductCode);
            assetToCreate.Product2Id = OLI.Product2Id;
            assetToCreate.RecordTypeId = productRecordTypesMap.get(OLI.Product2.RecordType.DeveloperName);
            assetsToCreate.add(assetToCreate);
        }
        //get Asset Record Prefix map mdt
        for(AssetPrefixMapping__mdt assetPrefMap: [SELECT Prefix__c, RecordTypeDeveloperName__c FROM AssetPrefixMapping__mdt]){
            assetRTPrefixMap.put(assetPrefMap.RecordTypeDeveloperName__c, assetPrefMap.Prefix__c);
        }
        // map assets per idenftifier
        for(Asset assetElement: [SELECT ID, RecordTypeId, Product2Id FROM Asset]){
            String assetIdentifier = assetRTPrefixMap.get(productRTMap.get(assetElement.RecordTypeId)) + '-' + productCodeMap.Get(assetElement.Product2Id);
            String newAssetIdentifier;
            if(identifierAssetMap.keySet().contains(assetIdentifier)){
                identifierAssetMap.get(assetIdentifier).add(assetElement);
            }else{
                List<Asset> nAssets = new List<Asset>{assetElement};
                identifierAssetMap.put(assetIdentifier, nAssets);
            }
            assetElement.External_Id__c = newAssetIdentifier;
            //assetsToUpdate.add(assetToUpdate);
            System.debug('newAssetIdentifier:' + newAssetIdentifier);
        }
        for(Asset assetElement: assetsToCreate){
            String assetIdentifier = assetRTPrefixMap.get(productRTMap.get(assetElement.RecordTypeId)) + '-' + productCodeMap.Get(assetElement.Product2Id);
            String newAssetIdentifier;
            if(identifierAssetMap.keySet().contains(assetIdentifier)){
                identifierAssetMap.get(assetIdentifier).add(assetElement);
            }else{
                List<Asset> nAssets = new List<Asset>{assetElement};
                identifierAssetMap.put(assetIdentifier, nAssets);
            }
            assetElement.External_Id__c = newAssetIdentifier;
            //assetsToUpdate.add(assetToUpdate);
            System.debug('newAssetIdentifier:' + newAssetIdentifier);
        }
        //calculate identifier reference
        for(String identif: identifierAssetMap.keySet()){
            identifierIncrementMap.put(identif, identifierAssetMap.get(identif).size());
        }
        //generate external id
        for(Asset assetElement: assetsToCreate){
            String assetIdentifier = assetRTPrefixMap.get(productRTMap.get(assetElement.RecordTypeId)) + '-' + productCodeMap.Get(assetElement.Product2Id);
            assetElement.External_Id__c = assetIdentifier + '-' + UtilityClass.formatInteger(identifierIncrementMap.get(assetIdentifier));
            identifierIncrementMap.put(assetIdentifier, identifierIncrementMap.get(assetIdentifier) + 1);
        }
        insert assetsToCreate;

    }
    
}