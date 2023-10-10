trigger FeedCommentTrigger on FeedComment (before insert, before update, before delete, after insert, after update, after delete) {
	if(trigger.isInsert){
        if(trigger.isBefore){
        }else if(trigger.isAfter){
            FeedCommentTriggerHandler.afterInsert(trigger.new);
        }
    }else if(trigger.isDelete){
        if(trigger.isBefore){
            FeedCommentTriggerHandler.beforeDelete(trigger.old);
        }
    }
}