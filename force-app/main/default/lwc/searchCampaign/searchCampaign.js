import { LightningElement } from 'lwc';

export default class SearchCampaign extends LightningElement {
    showSearchComponent = true;
    searchHelpText = 'Search all the opportunities related to the Campaign name';
    searchHelpTitle = 'Campaign Check';
    objectApiName = 'Campaign';
    fieldList = ['Name', 'Status', 'StartDate', 'EndDate'];
    campaignId;
    apexName = 'getOpportunitiesByCampaignId';
    param = {};
    handleCampaignFilter(event){
        this.campaignId = event.detail;
        this.param = {campaignId: this.campaignId};
        this.showSearchComponent = false;
    }
    checkAnotherCampaign(){
        this.showSearchComponent = true;
    }
}