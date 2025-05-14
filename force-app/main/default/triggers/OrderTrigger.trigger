/**
 * Trigger sur l'objet Order, qui gère :
 * - Le calcul du montant net (NetAmount__c) AVANT mise à jour
 * - La mise à jour du chiffre d'affaires du compte APRÈS mise à jour
 */
trigger OrderTrigger on Order (before update, after update) {

    if (Trigger.isBefore && Trigger.isUpdate) {
        OrderTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        OrderTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }

}