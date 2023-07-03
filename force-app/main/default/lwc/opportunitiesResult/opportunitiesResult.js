import { LightningElement, api, wire } from 'lwc';
import apexExecute from '@salesforce/apex/CampaignManager.execute';
import { refreshApex } from "@salesforce/apex";

const COLUMNS = [
    { label: 'Account Name', fieldName: 'recordLink', type: 'url', sortable : 'true', typeAttributes: {label: {fieldName: 'AccountName'}, target: '_self'}},
    { label: 'Stage Name', fieldName: 'StageName', type: 'text', sortable : 'true' },
    { label: 'Type', fieldName: 'Type', type: 'text', sortable : 'true' },
    { label: 'CreatedDate', fieldName: 'CreatedDate', type: 'date', sortable : 'true'},
    { label: 'CloseDate', fieldName: 'CloseDate', type: 'date' },
    { label: 'Description', fieldName: 'Description', type: 'text' }
];
//Account Name, StageName, Type, CreatedDate, CloseDate, Description
export default class OpportunitiesResult extends LightningElement {
    data = [];
    error;
    @api param;
    @api apexName;
    resultData;
    pagesize = 10;
    columns = COLUMNS;
    @wire(apexExecute, { action: '$apexName', params: '$param' })
    getOpportunities(result){
        console.log('wire called');
        this.resultData = result;
        if(result.data){
            console.log('result.data:', result.data);
            this.data = result.data.map( oppty => ({...oppty, 'AccountName': oppty.Account.Name, 'recordLink': '/' + oppty.Account.Id}) );
        }else if(result.error) {
            this.error = result.error;
            console.log(JSON.stringify(result.error));
        }
    }

    @api
    refreshDatatable(){
        refreshApex(this.resultData);
    }
}
