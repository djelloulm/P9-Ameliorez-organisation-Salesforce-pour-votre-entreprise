public with sharing class OrderController {
    
    @AuraEnabled(cacheable=true)
    public static Decimal getTotalOrderAmountByAccount(Id accountId) {
        if (accountId == null) {
            throw new AuraHandledException('Id du compte est obligatoire');
        }

        AggregateResult result = [
            SELECT SUM(TotalAmount) total 
            FROM Order 
            WHERE AccountId = :accountId AND 
            Status = 'Activated'
        ];

        Decimal totalAmount = (Decimal) result.get('total');
        return totalAmount != null ? totalAmount : 0;
    }
}
