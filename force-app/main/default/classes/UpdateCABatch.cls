public class UpdateCABatch implements Database.Batchable<SObject> {

    // Query initiale - on récupère tous les comptes
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id FROM Account');
    }

    // Traitement de chaque lot de comptes
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : scope) {
            accountIds.add(acc.Id);
        }

        // Prendre seulement les commandes dont le statut = "Validé" 
        Map<Id, Decimal> accountToTotalAmount = new Map<Id, Decimal>();

        for (AggregateResult ar : [
            SELECT AccountId accId, SUM(TotalAmount) total
            FROM Order
            WHERE AccountId IN :accountIds AND Status = 'Activated'
            GROUP BY AccountId
        ]) {
            Id accId = (Id) ar.get('accId');
            Decimal total = (Decimal) ar.get('total');
            accountToTotalAmount.put(accId, total);
        }

        // Mise à jour des comptes avec le montant agrégé.
        List<Account> accountsToUpdate = new List<Account>();

        for (Account acc : scope) {
            Decimal totalAmount = accountToTotalAmount.containsKey(acc.Id)
                ? accountToTotalAmount.get(acc.Id)
                : 0;

            acc.Chiffre_d_affaire__c = totalAmount;
            accountsToUpdate.add(acc);
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }

    // Étape 3 : Fin du traitement
    public void finish(Database.BatchableContext bc) {
        System.debug('Mise à jour du chiffre d\'affaire terminée.');
    }
}