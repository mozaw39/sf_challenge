public with sharing class OpportunityTriggerHelper {
    static String ASSET_SOBJECT_TYPE = 'Asset';
    // handle closed won opportunities process
    public static void closedWonProcessing(Set<Id> opportunitiesIds){
        List<Asset> assetsToCreate = new List<Asset>();
        Map<String, Id> productRecordTypesMap = new Map<String, Id>();
        for(RecordType RT: [SELECT ID, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType =:ASSET_SOBJECT_TYPE]){
            productRecordTypesMap.put(RT.DeveloperName, RT.ID);
        }
        map<Id, Opportunity> opptiesMap = new Map<Id, Opportunity>([SELECT ID, AccountId, CloseDate FROM OPPORTUNITY WHERE ID IN :opportunitiesIds]);
        for(OpportunityLineItem OLI: [SELECT ID, OpportunityId, Product2Id, UnitPrice, Product2.Name, Product2.RecordType.DeveloperName FROM OpportunityLineItem WHERE OpportunityId in :opportunitiesIds]){
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
            assetToCreate.Product2Id = OLI.Product2Id;
            assetToCreate.RecordTypeId = productRecordTypesMap.get(OLI.Product2.RecordType.DeveloperName);

            assetsToCreate.add(assetToCreate);
        }

        // insert assets
        insert assetsToCreate;
    }
}