/**
 * Created by Benjamin Lin on 25/6/22.
 */

trigger TransactionItemTrigger on Transaction_Item__c (after insert, after update) {
    // Call the transaction/transaction items callout logic here
    TransactionCalloutService.callTransactionService(Trigger.new);

}