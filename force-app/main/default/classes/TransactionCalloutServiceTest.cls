/**
 * Created by Benjamin Lin on 26/6/22.
 */

@IsTest
private class TransactionCalloutServiceTest {
    @TestSetup
    static void setupTestData(){

        Transaction__c trans = new Transaction__c(TransactionDate__c = Date.today());
        insert trans;

        Transaction_Item__c transactionItem = new Transaction_Item__c();
        transactionItem.Transaction__c = trans.Id;
        transactionItem.ItemCost__c = 1000;
        transactionItem.Discount__c = 10;
        insert transactionItem;
    }

    // Test successful post
    @IsTest
    static void testSuccess(){
        List<Transaction_Item__c> transactionItems = new List<Transaction_Item__c>([SELECT Id, ItemCost__c, Name
        FROM Transaction_Item__c]);

        List<Transaction__c> transactions = [SELECT Id, TransactionCount__c, TotalDiscount__c,
                TotalCost__c, TransactionDate__c FROM Transaction__c ];
        //Transaction__c trans = transactions[0];
        //String jsonTransactionItems = TransactionCalloutService.serializeTransactionItems(transactionItems);
        //String jsonTransactionHeader = TransactionCalloutService.serializeTransaction(trans);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new TransactionCalloutServiceMock());
        TransactionCalloutService.callTransactionService(transactionItems);
        //HttpResponse response = TransactionCalloutService.callOut(jsonTransactionItems);
        //TransactionCalloutService.callOutTrans(jsonTransactionHeader);
        Id jobID = System.enqueueJob(new TransactionCalloutService.QueueableCallout(transactions));
        Test.stopTest();

        System.assertEquals(1, transactionItems.size());
        System.assertNotEquals(null, jobID);
        //System.assertEquals(200, response.getStatusCode());
    }

    // Test failure post
    @IsTest
    static void testFailure(){
        List<Transaction_Item__c> transactionItems = new List<Transaction_Item__c>([SELECT Id, ItemCost__c, Name
        FROM Transaction_Item__c]);
        List<Transaction__c> transactions = [SELECT Id, TransactionCount__c, TotalDiscount__c,
                TotalCost__c, TransactionDate__c FROM Transaction__c ];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class,new TransactionCalloutServiceMockFailure());
        TransactionCalloutService.callTransactionService(transactionItems);
        Id jobID = System.enqueueJob(new TransactionCalloutService.QueueableCallout(transactions));

        Test.stopTest();

        System.assertEquals(1, transactionItems.size());
        System.assertNotEquals(null, jobID);
    }

}