import { LightningElement, track } from 'lwc';
import getProjectAndPaymentPlan from '@salesforce/apex/DemandRaiseLWCController.getProjectAndPaymentPlan';
import getMasterPaymentSchedules from '@salesforce/apex/DemandRaiseLWCController.getMasterPaymentSchedules';

export default class Raise_demand_lwc extends LightningElement {
    @track projectOptions = [];
    @track paymentPlanOptions = [];
    SelectedPlanId;
    selectedProjectId;
    displayCombainedSchedules = false;
    projectData;

    columns = [
        { label: 'S.No', fieldName: 'S_No__c' },
        { label: 'Name', fieldName: 'Name' },
        { label: 'Status', fieldName: 'Status__c' },
        { label: 'Completed Date', fieldName: 'Completed_Date__c', type: 'date' },
        { label: 'Project Name', fieldName: 'Project_Name__c' },
        { label: 'Combined Schedule', fieldName: 'Combined_Schedule__c', type: 'boolean' }
    ];

    connectedCallback() {
        getProjectAndPaymentPlan()
            .then(data => {
                this.projectOptions = data.map(prj => ({
                    label: prj.projectLabel,
                    value: prj.projectValue
                }));
                this.projectData = data;
            })
            .catch(error => {
                console.log('error', error);
            });
    }

    handleProjectChange(event) {
        this.selectedProjectId = event.detail.value;
        console.log('selectedProjectId', this.selectedProjectId);
        
        const selectedProject = this.projectData.find(prj => prj.projectValue === this.selectedProjectId);
        this.paymentPlanOptions = selectedProject ? selectedProject.paymentPlans : [];
    }

    handleShowCombined(event) {
        this.displayCombainedSchedules = event.target.checked;
        console.log('displayCombainedSchedules', this.displayCombainedSchedules);
    }

    handlePaymentPlanChange(event) {
        this.SelectedPlanId = event.detail.value;
        console.log('SelectedPlanId', this.SelectedPlanId);
    }

    handleGetPaymentSchedules() {
        getMasterPaymentSchedules({
            selectedProject: this.selectedProjectId,
            selectedPlan: this.SelectedPlanId,
            displayCombinedSchedules: this.displayCombinedSchedules
        })
            .then(result => {
                this.data = result;
            })
            .catch(error => {
                console.error('Error loading schedules:', error);
            });
    }

}