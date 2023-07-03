public with sharing class OpportunityTriggerHandler extends TriggerHandler {
    private Map<Id, Opportunity> newOpptyMap;
    private Map<Id, Opportunity> oldOpptyMap;
    static String CLOSED_WON_STAGE = 'Closed Won';

    public OpportunityTriggerHandler() {
        this.newOpptyMap = (Map<Id, Opportunity>) Trigger.newMap;
        this.oldOpptyMap = (Map<Id, Opportunity>) Trigger.oldMap;
    }
    public override void afterUpdate(){
        Map<Id, Opportunity> newOpptyMap = this.newOpptyMap;
        Map<Id, Opportunity> oldOpptyMap = this.oldOpptyMap;
        Set<Id> opptiesToProcess = new Set<Id>();

        for(Id opptyId: newOpptyMap.keySet()){
            //opportunity becomes closed won
            if(newOpptyMap.get(opptyId).StageName == CLOSED_WON_STAGE && newOpptyMap.get(opptyId).StageName != oldOpptyMap.get(opptyId).StageName){
                opptiesToProcess.add(opptyId);
            }
        }
        if(opptiesToProcess.size() > 0){
            OpportunityTriggerHelper.closedWonProcessing(opptiesToProcess);
        }
    }
}