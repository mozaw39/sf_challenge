trigger AssetTrigger on Asset (after insert, before delete) {
    new AssetTriggerHandler().run();
}