trigger FeedItemTrigger on FeedItem (before insert, before update, before delete, after insert, after update, after delete) {
    if(trigger.isDelete){
        if(trigger.isBefore){
            FeedItemTriggerHandler.beforeDelete(trigger.old);
        }
    }
}