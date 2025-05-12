import { LightningElement, api } from 'lwc';
import getTotalOrderAmountByAccount from '@salesforce/apex/OrderController.getTotalOrderAmountByAccount';

export default class Orders extends LightningElement {
    @api recordId;
    sumOrdersOfCurrentAccount;
    errorMessage;

    connectedCallback() {
        this.fetchSumOrders();
    }

    fetchSumOrders() {
        getTotalOrderAmountByAccount({ accountId: this.recordId })
            .then(result => {
                this.sumOrdersOfCurrentAccount = result;

                // Pas besoin d’un message d’erreur ici, on gère ça dans le getter
                this.errorMessage = null;
            })
            .catch(error => {
                this.sumOrdersOfCurrentAccount = null;
                this.errorMessage = 'Erreur lors de la récupération des commandes.';
                console.error(error);
            });
    }

    get showError() {
        return !this.sumOrdersOfCurrentAccount || this.sumOrdersOfCurrentAccount <= 0;
    }

    get showSuccess() {
        return this.sumOrdersOfCurrentAccount && this.sumOrdersOfCurrentAccount > 0;
    }
}
