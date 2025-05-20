public with sharing class ScheduleUpdateCABatch implements Schedulable {
    
    // Implémentation de la méthode execute obligatoire
    public void execute(SchedulableContext sc) {
        UpdateCABatch batch = new UpdateCABatch();
        Database.executeBatch(batch, 200); // Taille du lot de 200
    }
}
