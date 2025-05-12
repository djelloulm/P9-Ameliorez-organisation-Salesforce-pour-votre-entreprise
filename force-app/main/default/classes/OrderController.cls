public with sharing class OrderController {
    
    @AuraEnabled(cacheable=true)
    public static Decimal getTotalOrderAmountByAccount(Id accountId) {
        if (accountId == null) {
            throw new AuraHandledException('L\'ID du compte est requis.');
        }

        AggregateResult result = [
            SELECT SUM(TotalAmount) total 
            FROM Order 
            WHERE AccountId = :accountId
        ];

        Decimal totalAmount = (Decimal) result.get('total');
        return totalAmount != null ? totalAmount : 0;
    }
}