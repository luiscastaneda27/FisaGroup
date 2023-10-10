public class FeedCommentTriggerHelper {

    public static void validacionComentario(List<FeedComment> newFeedCommentList){
        List<String> listFeedItemIds = new List<String>();
        List<String> listCasosIds = new List<String>();
        List<Case> listCasosUpdate = new List<Case>();
        for(Profile p: [Select Id from Profile Where Name = 'Customer Community User' and Id =:UserInfo.getProfileId()] ){
            for(FeedComment item: newFeedCommentList){
                listFeedItemids.add(item.FeedItemId);
            } 
        }
        for(FeedItem item: [Select ParentId From FeedItem Where Id in :listFeedItemids]){
            listCasosIds.add(item.ParentId);
        }
        for(Case item: [Select FS_SubEstado__c, FS_SubEstadoQueSePideInformacion__c, FS_InformacionCompleta__c from case Where Id in :listCasosIds and FS_SubEstadoQueSePideInformacion__c != null]){
            item.FS_SubEstado__c = item.FS_SubEstadoQueSePideInformacion__c;
            item.FS_SubEstadoQueSePideInformacion__c = null;
            item.FS_InformacionCompleta__c = null;
            listCasosUpdate.add(item);
        }
        update listCasosUpdate;
        
    }
}