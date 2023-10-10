public class FeedCommentTriggerHandler {

    public static void afterInsert(List<FeedComment> newFeedCommentList){
        FeedCommentTriggerHelper.validacionComentario(newFeedCommentList);
    }
    public static void beforeDelete(List<FeedComment> newFeedCommentList){
        FeedCommentTriggerHelper.validacionBorrado(newFeedCommentList);
    }
}