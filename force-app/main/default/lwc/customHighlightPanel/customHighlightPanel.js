import { LightningElement, api } from 'lwc';

export default class CustomHighlightPanel extends LightningElement {
    @api objectApiName;
    @api recordId;
    @api fieldList;
}