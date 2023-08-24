public class FeedCommentTriggerHandler {

    public static void afterInsert(List<FeedComment> newFeedCommentList){
        FeedCommentTriggerHelper.validacionComentario(newFeedCommentList);
    }
}