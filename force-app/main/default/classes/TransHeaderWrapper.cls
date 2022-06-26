/**
 * Created by Benjamin Lin on 25/6/22.
 */

public with sharing class TransHeaderWrapper {
    public Keys keys;
    public Values values;

    public class Keys{
        public String transactionID;
    }

    public class Values{
        public String totalCost;
        public String totalDiscount;
        public String transactionDate;

    }
}