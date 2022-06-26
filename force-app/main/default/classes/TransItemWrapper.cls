/**
 * Created by Benjamin Lin on 25/6/22.
 */

public with sharing class TransItemWrapper {
    public Keys keys;
    public Values values;

    public class Keys{
        public String transactionItemID;
    }

    public class Values{
        public String itemCost;
        public String itemName;
    }
}