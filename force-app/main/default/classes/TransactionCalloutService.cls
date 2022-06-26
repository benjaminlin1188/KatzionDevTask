/**
 * Created by Benjamin Lin on 25/6/22.
 */

public with sharing class TransactionCalloutService {
    public static Map<Id, List<Transaction_Item__c>> transactionItemsByIds =
            new Map<Id, List<Transaction_Item__c>>();
    private final static String endPoint = 'callout:TransactionService';


    public static void callTransactionService(List<Transaction_Item__c> transactionItems){
        Set<Id> transactionItemIds = new Set<Id>();   // prepare set of transaction Ids
        List<Transaction__c> transactions = new List<Transaction__c>();

        for(Transaction_Item__c transactionItem : transactionItems){
            transactionItemIds.add(transactionItem.Id);
        }

        for(Transaction_Item__c item : [SELECT Id, Name, Discount__c, ItemCost__c,Transaction__c FROM Transaction_Item__c
        WHERE Id IN : transactionItemIds]){
            if(!transactionItemsByIds.containsKey(item.Transaction__c)){
                transactionItemsByIds.put(item.Transaction__c, new List<Transaction_Item__c>());
            }
            transactionItemsByIds.get(item.Transaction__c).add(item);
        }

        transactions = [SELECT Id, TransactionCount__c, TotalDiscount__c, TotalCost__c, TransactionDate__c
        FROM Transaction__c WHERE Id IN : transactionItemsByIds.keySet()];

        /* //this function is not required

        //double check the transaction items count against the header's transaction count field
        //Map<Id, Integer> itemCount = getItemCount(transactionItemIds);
        //System.debug('Item Count checking : '+ itemCount);

        // consolidate List of records to callout
        List<Transaction__c> transactionsCallout = new List<Transaction__c>();
        for(Transaction__c tran : transactions){
            if(itemCount.containsKey(tran.Id) ){//&& tran.TransactionCount__c == itemCount.get(tran.Id)){
                System.debug('Adding To transactionsCallout List ');
                transactionsCallout.add(tran);
            }
        }
        */

        // start callout process
        //processCallout(transactions);

        // start the queue
        if(!Test.isRunningTest() && transactions.size() > 0){
            System.enqueueJob(new QueueableCallout(transactions));
        }
    }

    // using Queueable method
    public  class QueueableCallout implements Queueable, Database.AllowsCallouts {
        List<Transaction__c> transactions = new List<Transaction__c>();

        // constructor
        public QueueableCallout(List<Transaction__c> transactions){
            this.transactions = transactions;
        }

        // implement execute interface
        public  void execute(QueueableContext queueableContext){
            List<Transaction_Item__c> transactionItems = new List<Transaction_Item__c>();
            for(Transaction__c tran : transactions){
                for(Transaction_Item__c item : [SELECT Id, ItemCost__c, Name
                FROM Transaction_Item__c WHERE Transaction__c =: tran.Id]){
                    transactionItems.add(item);
                }
                String jsonItems = serializeTransactionItems(transactionItems);

                if(callOut(jsonItems).getStatusCode() == 200){
                    String jsonHeader = serializeTransaction(tran);
                    callOutTrans(jsonHeader);
                }
                //callOut(jsonItems, jsonHeader);
            }
        }
    }

    /* // this function is not required any more
    private static Map<Id, Integer> getItemCount(Set<Id> itemIds) {
        Map<Id, Integer> transactionItemCountByIds = new Map<Id, Integer>();
        for (AggregateResult aggregateResult : [SELECT COUNT(Id) itemCount, Transaction__c FROM Transaction_Item__c
        WHERE Id IN :itemIds GROUP BY Transaction__c]){
            transactionItemCountByIds.put((Id) aggregateResult.get('Transaction__c') , (Integer) aggregateResult.get('itemCount') );
        }
        return transactionItemCountByIds;
    }*/
/*

    public static void processCallout(List<Transaction__c> transactions){
        List<Transaction_Item__c> transactionItems = new List<Transaction_Item__c>();
        for(Transaction__c tran : transactions){
            for(Transaction_Item__c item : [SELECT Id, ItemCost__c, Name
            FROM Transaction_Item__c WHERE Transaction__c =: tran.Id]){
                transactionItems.add(item);
            }
            String jsonItems = serializeTransactionItems(transactionItems);
            String jsonHeader = serializeTransaction(tran);
            System.debug(jsonItems);
            System.debug(jsonHeader);
            callOut(jsonItems, jsonHeader);
        }

    }

*/
   // @Future(Callout = true)
    //public static void callOut(String jsonHeader, String jsonItem){
    public static HttpResponse callOut( String jsonItem){
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setHeader('content-type', 'application/json');
        request.setEndpoint(endPoint);
        request.setBody(jsonItem);
        HttpResponse response;
        try{
             response = new Http().send(request);

            /*
            if (response.getStatusCode() == 200) {
                System.debug('The status code returned: ' + response.getStatusCode());
               // callOutTrans(jsonHeader);
            }
            */
        }
        catch (System.CalloutException e){
            System.debug(e);
        }
        return response;
    }


    public static void callOutTrans(String jsonString){
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setHeader('content-type', 'application/json');
        request.setEndpoint(endPoint);
        request.setBody(jsonString);
        try{
            HttpResponse response = new Http().send(request);

            if (response.getStatusCode() != 200) {
                System.debug('The status code returned from transaction header: ' + response.getStatusCode());
            }
        }
        catch (System.CalloutException e){
            System.debug(e);
        }
    }

    // serialize transaction Items
    @TestVisible
    private static String serializeTransactionItems(List<Transaction_Item__c> transactionItems){
        List<TransItemWrapper> transactionItems2 = new List<TransItemWrapper>();
        for(Transaction_Item__c item : transactionItems){
            TransItemWrapper itemWrapper = new TransItemWrapper();
            TransItemWrapper.Keys keys = new TransItemWrapper.Keys();
            TransItemWrapper.Values values = new TransItemWrapper.Values();
            keys.transactionItemID = item.Id;
            values.itemCost = String.valueOf(item.ItemCost__c);
            values.itemName = item.Name;
            itemWrapper.keys = keys;
            itemWrapper.values = values;

            transactionItems2.add(itemWrapper);
        }
        return  JSON.serialize(transactionItems2);
    }

    // serialize transaction
    @TestVisible
    private static String serializeTransaction(Transaction__c tran){
            TransHeaderWrapper headerWrapper = new TransHeaderWrapper();
            TransHeaderWrapper.Keys keys = new TransHeaderWrapper.Keys();
            TransHeaderWrapper.Values values = new TransHeaderWrapper.Values();
            keys.transactionID = tran.Id;
            values.totalCost = String.valueOf(tran.TotalCost__c);
            values.totalDiscount = String.valueOf(tran.TotalDiscount__c);
            values.transactionDate = String.valueOf(tran.TransactionDate__c);
            headerWrapper.keys = keys;
            headerWrapper.values = values;

        return  JSON.serialize(headerWrapper);
    }





}