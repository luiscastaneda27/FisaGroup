public class FeedItemTriggerHandler {

    public static void beforeDelete(List<FeedItem> feedItemList){
        FeedItemTriggerHelper.validacionBorrado(feedItemList);
    }
}