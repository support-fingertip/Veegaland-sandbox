import { api, LightningElement, track } from 'lwc';
import getApplicantList from '@salesforce/apex/SaleAgreementDataController.getBookingApplicants';
import getVillagesByDistrictAndTaluk from '@salesforce/apex/SaleAgreementDataController.getVillagesByDistrictAndTaluk';
import getPostOfficesByDistrict from '@salesforce/apex/SaleAgreementDataController.getPostOfficesByDistrict';
import saveApplicantDetails from '@salesforce/apex/SaleAgreementDataController.saveApplicantDetails';
import veegalandResource from '@salesforce/resourceUrl/veegaland';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Customer_agreement_details extends LightningElement {
    @api recordId;
    agreementData;
    selectedvillage;
    @track selectedDistrict;
    @track selectedTaluk;
    filteredPostOfficeList;
    filteredvillageList;
    @track searchKey = '';
    applicantList;
    @track districtOptions;
    @track talukOptions = [];
    @track isSubmitted;
    districtTalukMap;
    @track errorMessages = [];
    @track hasErrors = false;
    occupationList;

    connectedCallback() {
        this.initGetApplicantList();
    }

    initGetApplicantList() {
        console.log('*** inside initGetApplicantList');

        getApplicantList({ bookingId: this.recordId })
            .then((result) => {
                this.agreementData = result;

                this.applicantList = JSON.parse(JSON.stringify(this.agreementData.applicants)) || [];
                this.districtOptions = this.agreementData.districtOptions || [];
                this.isSubmitted = this.agreementData.isSubmitted;
                this.districtTalukMap = this.agreementData.districtTalukMap || {};
                this.occupationList = this.agreementData.occupationList || [];

                this.applicantList = this.applicantList.map(applicant => {
                    const hasDistrict = applicant.district && applicant.district.trim() !== '';
                    const hasTaluk = applicant.taluk && applicant.taluk.trim() !== '';
                    

                    // --- Taluk Options ---
                    const talukList = hasDistrict ? this.districtTalukMap[applicant.district] || [] : [];
                    applicant.talukOptions = talukList.map(t => ({
                        label: t,
                        value: t
                    }));

                    // --- Post Offices ---
                    if (hasDistrict) {
                        this.getPostOfficeListForApplicant(applicant);
                    } else {
                        applicant.postOfficeOptions = [];
                    }
                    this.applicantList = [...this.applicantList];
                    // --- Villages ---
                    if (hasDistrict && hasTaluk) {
                        this.getVillageListForApplicant(applicant);
                    } else {
                        applicant.villageOptions = [];
                    }

                    return applicant;
                });

                this.applicantList = [...this.applicantList];
            })
            .catch((error) => {
                console.error('Error in initGetApplicantList:', error);
            });
    }



    updateApplicantEnables(applicantList) {
        if (!applicantList || applicantList.length === 0) {
            return [];
        }

        return applicantList.map(applicant => {
            const hasDistrict = applicant.district && applicant.district.trim() !== '';
            const hasTaluk = applicant.taluk && applicant.taluk.trim() !== '';

            return applicant;
        });
    }

    onChangeDistrict(event) {
        const applicantId = event.currentTarget.dataset.id;
        const selectedDistrict = event.detail.value;
        // Update only that applicant’s data
        this.applicantList = this.applicantList.map(applicant => {
            if (applicant.recordId === applicantId) {
                applicant.district = selectedDistrict;

                applicant.taluk = '';
                applicant.village = '';
                applicant.postOffice = '';

                const taluks = this.districtTalukMap[selectedDistrict] || [];

                applicant.talukOptions = taluks.map(t => ({ label: t, value: t }));

                this.getPostOfficeListForApplicant(applicant);

                // Optional: clear existing options
                applicant.postOfficeOptions = [];
            }
            return applicant;
        });

        this.applicantList = [...this.applicantList];

    }

    onChangeTaluk(event) {
        const applicantId = event.currentTarget.dataset.id;
        const selectedTaluk = event.detail.value;

        this.applicantList = this.applicantList.map(applicant => {
            if (applicant.recordId === applicantId) {
                applicant.taluk = selectedTaluk;

                applicant.village = '';


                if (applicant.district && applicant.taluk) {
                    this.getVillageListForApplicant(applicant);
                }
            }
            return applicant;
        });

        this.applicantList = [...this.applicantList];
    }

    onChangeVillage(event) {
        const applicantId = event.currentTarget.dataset.id;
        const selectedVillage = event.detail.value;
        this.applicantList = this.applicantList.map(applicant => {
            if (applicant.recordId === applicantId) {
                applicant.village = selectedVillage;
            }
            return applicant;
        });
        this.applicantList = [...this.applicantList];

    }

    onChangePostOffice(event) {
        const applicantId = event.currentTarget.dataset.id;
        const selectedPostOffice = event.detail.value;
         this.applicantList = this.applicantList.map(applicant => {
            if (applicant.recordId === applicantId) {
                applicant.postOffice = selectedPostOffice;
            }
            return applicant;
        });
        this.applicantList = [...this.applicantList];
    }

    onChangeDesom(event) {
        const applicantId = event.currentTarget.dataset.id;
        const selectedDesom = event.detail.value;
        this.applicantList = this.applicantList.map(applicant => {
            if (applicant.recordId === applicantId) {
                applicant.desom = selectedDesom;
            }
            return applicant;
            });
        this.applicantList = [...this.applicantList];
    }

    onChangeOccupation(event) {
        const applicantId = event.currentTarget.dataset.id;
        const selectedOccupation = event.detail.value;
        this.applicantList = this.applicantList.map(applicant => {
            if (applicant.recordId === applicantId) {
                applicant.occupation = selectedOccupation;
                if (selectedOccupation === 'Others') {
                    applicant.isOccupationOthers = true;
                } else {
                    applicant.isOccupationOthers = false;
                    applicant.occupationOthers = '';
                }
            }
            return applicant;
        });
        this.applicantList = [...this.applicantList];
    }
     onChangeOtherOccupation(event) {
        const applicantId = event.currentTarget.dataset.id;
        const selectedOccupation = event.detail.value;
        this.applicantList = this.applicantList.map(applicant => {
            if (applicant.recordId === applicantId) {
                applicant.occupationOthers = selectedOccupation;
            }
            return applicant;
        });
        this.applicantList = [...this.applicantList];
    }
    onChangeName(event) {
        const applicantId = event.currentTarget.dataset.id;
        const selectedName = event.detail.value;
        this.applicantList = this.applicantList.map(applicant => {
            if (applicant.recordId === applicantId) {
                applicant.name = selectedName;
            }
            return applicant;
        });
        this.applicantList = [...this.applicantList];

    }
    getVillageListForApplicant(applicant) {
        getVillagesByDistrictAndTaluk({
            district: applicant.district,
            taluk: applicant.taluk
        })
            .then((result) => {
                const updatedvillages = result.map(v => ({
                    label: v.Name,
                    value: v.Name
                }));

                this.applicantList = this.applicantList.map(app =>
                    app.recordId === applicant.recordId
                        ? { ...app, villageOptions: updatedvillages }
                        : app
                );
            })
            .catch((error) => {
                console.error('Error fetching villages:', error);
            });
    }

    getPostOfficeListForApplicant(applicant) {
        getPostOfficesByDistrict({ district: applicant.district })
            .then((result) => {
                const updatedPostOffices = result.map(po => ({
                    label: po.Name,
                    value: po.Name
                }));
                this.applicantList = this.applicantList.map(app =>
                    app.recordId === applicant.recordId
                        ? { ...app, postOfficeOptions: updatedPostOffices }
                        : app
                );

            })
            .catch((error) => {
                console.error('Error fetching post offices for', applicant.District__c, error);
            });
    }

    handleSave() {
        const validationErrors = this.validateApplicants(this.applicantList);
        if (validationErrors.length > 0) {
            this.errorMessages = validationErrors;
            this.hasErrors = true;
            return;
        }

        // 🔹 Prepare sanitized applicants list (only required fields)
        const cleanedApplicants = this.applicantList.map(app => ({
            name: app.name || '',
            occupation: app.occupation || '',
            district: app.district || '',
            taluk: app.taluk || '',
            village: app.village || '',
            desom: app.desom || '',
            postOffice: app.postOffice || '',
            recordId: app.recordId || null,
            type: app.type || '',
            type: app.type || '',
            villageOptions: [],
            postOfficeOptions: [],
            talukOptions:[],
            occupationOthers: app.occupationOthers || ''
        }));

        // 🔹 Send to Apex as JSON string
        saveApplicantDetails({ applicantJson:  JSON.stringify(cleanedApplicants)})
            .then((result) => {

                if (result == 'Success') {
                    this.isSubmitted = true;
                    this.hasErrors = false;
                } else {
                    this.errorMessages = [result.message];
                    this.hasErrors = true;
                }
            })
            .catch((error) => {
                console.error('Error saving applicant details:', error);
                this.errorMessages = [error.body?.message || 'Something went wrong'];
                this.hasErrors = true;
            });
    }


    validateApplicants(applicantList) {
        let errors = [];

        if (!applicantList || applicantList.length === 0) {
            errors.push('No applicants available to validate.');
            return errors;
        }

        applicantList.forEach((app, index) => {
            let missingFields = [];

            if (!app.name || app.name.trim() === '') missingFields.push('Name');
            if (!app.occupation || app.occupation.trim() === '') missingFields.push('Occupation');
            if (!app.district || app.district.trim() === '') missingFields.push('District');
            if (!app.taluk || app.taluk.trim() === '') missingFields.push('Taluk');
            if (!app.village || app.village.trim() === '') missingFields.push('Village');
            if (!app.postOffice || app.postOffice.trim() === '') missingFields.push('Post Office');
            if (!app.desom || app.desom.trim() === '') missingFields.push('Desom');
            
            console.log('app.occupationOthers: '+app.occupationOthers);
            
            const needsOthers = app.isOccupationOthers === true && app.occupation === 'Others';
            if (needsOthers && (!app.occupationOthers || app.occupationOthers.trim() === '')) {
                missingFields.push('Other Occupation');
            }

            if (missingFields.length > 0) {
                errors.push(
                    `Applicant ${index + 1} (${app.name || 'Unnamed'}): Missing ${missingFields.join(', ')}`
                );
            }
        });

        return errors;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: 'sticky'
            })
        );
    }


}