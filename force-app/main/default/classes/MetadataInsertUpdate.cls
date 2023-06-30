public with sharing class MetadataInsertUpdate implements Metadata.DeployCallback, Queueable, Database.AllowsCallouts {
    //List<Map<String, Object>> fieldWithValueslist;
    static String ASSET_SOBJECT_TYPE = 'Asset';
    List<Asset> assetsToCreate;
    public MetadataInsertUpdate(List<Asset> assetsToCreate){
        this.assetsToCreate = assetsToCreate;
    }
    public MetadataInsertUpdate(){
    }
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if(result.status == Metadata.DeployStatus.Succeeded) {
            System.debug('success: '+ result);
        }else{
            System.debug('fail:' + result);
        }
    }

    public void execute(QueueableContext context){
        //insert this.assetsToCreate;
    }

    public static void start(List<Asset> assetsToCreate) {
        ID jobID = System.enqueueJob(new MetadataInsertUpdate(assetsToCreate));
        System.debug('jobID: ' + jobID);
    }
    @future
    public static void closedWonProcessing(Set<Id> opportunitiesIds){
        List<Asset> assetsToCreate = new List<Asset>();
        Map<ID, String> productRTMap = new Map<Id, String>();
        Map<String, String> assetRTPrefixMap = new Map<String, String>();
        Map<String, Decimal> assetIncrementMap = new Map<String, Decimal>();
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
        //get increment map mdt
        for(AssetIncrementManager__mdt incManager : [SELECT Asset_Identifier__c, AssetIncrementCounter__c FROM AssetIncrementManager__mdt]){
            assetIncrementMap.put(incManager.Asset_Identifier__c, incManager.AssetIncrementCounter__c);
        }
        //get Asset Record Prefix map mdt
        for(AssetPrefixMapping__mdt assetPrefMap: [SELECT Prefix__c, RecordTypeDeveloperName__c FROM AssetPrefixMapping__mdt]){
            assetRTPrefixMap.put(assetPrefMap.RecordTypeDeveloperName__c, assetPrefMap.Prefix__c);
        }
        // generate external id
        for(Asset assetElement: assetsToCreate){
            Asset assetToUpdate = new Asset();
            assetToUpdate.Id = assetElement.Id;
            String assetIdentifier = assetRTPrefixMap.get(productRTMap.get(assetElement.RecordTypeId)) + '-' + productCodeMap.Get(assetElement.Product2Id);
            String newAssetIdentifier;
            if(assetIncrementMap != null && assetIncrementMap.keySet() != null && assetIncrementMap.keySet().contains(assetIdentifier)){
                newAssetIdentifier = assetIdentifier + '-' + UtilityClass.formatInteger(assetIncrementMap.get(assetIdentifier));
                //increment
                assetIncrementMap.put(assetIdentifier, assetIncrementMap.get(assetIdentifier) + 1);
            }else{
                assetIncrementMap.put(assetIdentifier, 1);
                newAssetIdentifier = assetIdentifier  + '-0000';
            }
            assetElement.External_Id__c = newAssetIdentifier;
            //assetsToUpdate.add(assetToUpdate);
            System.debug('newAssetIdentifier:' + newAssetIdentifier);
        }
        insert assetsToCreate;
    }

    public static void handleInsertAndUpdate(List<Map<String, Object>> fieldWithValueslist){
        Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
        //customMetadata.fullName = fullName;
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        for(Map<String, Object> fieldWithValuesMap:fieldWithValueslist){
            for(String key: fieldWithValuesMap.keySet()){
                customMetadata.label = (String)fieldWithValuesMap.get('label');
                customMetadata.fullName = (String)fieldWithValuesMap.get('label');
                Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
                customField.field = key;
                customField.value = fieldWithValuesMap.get(key);
                customMetadata.values.add(customField);
                mdContainer.addMetadata(customMetadata);
            }
        }
        MetadataInsertUpdate callback = new MetadataInsertUpdate();
        Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
        }
    
}