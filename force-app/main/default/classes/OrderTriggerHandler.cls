public class OrderTriggerHandler {

    // Méthode appelée avant la mise à jour des commandes
    public static void handleBeforeUpdate(List<Order> newOrders, Map<Id, Order> oldOrders) {
        for (Order o : newOrders) {
            Order oldOrder = oldOrders.get(o.Id);
            
            // Exemple de logique pour calculer le NetAmount
            if (o.ShipmentCost__c != null && o.TotalAmount != null) {
                o.NetAmount__c = o.TotalAmount - o.ShipmentCost__c;
            }
        }
    }

    // Méthode appelée après la mise à jour des commandes pour recalculer le chiffre d'affaires
    public static void handleAfterUpdate(List<Order> newOrders, Map<Id, Order> oldOrders) {
        Set<Id> accountIdsToUpdate = new Set<Id>();

        for (Order newOrder : newOrders) {
            Order oldOrder = oldOrders.get(newOrder.Id);

            // Ne prendre en compte que les commandes qui viennent d’être activées
            if (oldOrder.Status != 'Activated' && newOrder.Status == 'Activated' && newOrder.AccountId != null) {
                accountIdsToUpdate.add(newOrder.AccountId);
            }
        }

        if (accountIdsToUpdate.isEmpty()) return;

        // Calculer la somme des TotalAmount des commandes "Activated" pour chaque compte
        Map<Id, Decimal> accountToTotalAmount = new Map<Id, Decimal>();

        for (AggregateResult ar : [
            SELECT AccountId accId, SUM(TotalAmount) total
            FROM Order
            WHERE AccountId IN :accountIdsToUpdate AND Status = 'Activated'
            GROUP BY AccountId
        ]) {
            Id accId = (Id) ar.get('accId');
            Decimal total = (Decimal) ar.get('total');
            accountToTotalAmount.put(accId, total);
        }

        List<Account> accountsToUpdate = new List<Account>();

        for (Id accId : accountIdsToUpdate) {
            Decimal total = accountToTotalAmount.containsKey(accId)
                ? accountToTotalAmount.get(accId)
                : 0;

            accountsToUpdate.add(new Account(
                Id = accId,
                Chiffre_d_affaire__c = total
            ));
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}