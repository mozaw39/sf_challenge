import { LightningElement } from 'lwc';

export default class SearchInput extends LightningElement {
    queryTerm;

    handleKeyUp(evt) {
        const isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            this.queryTerm = evt.target.value;
            let ev = new CustomEvent('campaignfilterapplied', 
                                 {detail : this.queryTerm}
                                );
            this.dispatchEvent(ev); 
        }
    }
    handleSubmit(event){
        event.preventDefault();
        this.queryTerm = event.detail.fields.CampaignId;
        console.log('this.queryTerm:',this.queryTerm);
            let ev = new CustomEvent('campaignfilterapplied', 
                                 {detail : this.queryTerm}
                                );
            this.dispatchEvent(ev); 
    }
}