global class SendMilestoneNotification implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
         
        String query = 'select id, CaseId, IsCompleted, IsViolated, Case.OwnerId from CaseMilestone where isCompleted = false';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<CaseMilestone> caseMilestoneList) {
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='FS_IncumplimientoSLA'];
        // Create a new custom notification
		Messaging.CustomNotification notification = new Messaging.CustomNotification();
        Set<id> userId = new Set<id>();
        Set<id> accId = new Set<id>();
        // process each batch of records default size is 200
        for(CaseMilestone ltsCase : caseMilestoneList) {    
            userId.add(ltsCase.Case.OwnerId);
            accId.add(ltsCase.CaseId);
           /* // Update the Account Name 
            // Set the contents for the notification
			notification.setTitle('Vencimiento de SLA');
			notification.setBody('El SLA esta a punto de vencer');

			// Set the notification type and target
			notification.setNotificationTypeId(notificationType.Id);
            Set<String> addressee = new Set<String>();
            
            //addressee.add(userId);
          
			//notification.setTargetId(accId);
			notification.send(addressee);*/

        }
        
		
        Map<String, Object> variables = new Map<String, Object>();
    	variables.put('UserIds', userId);
        variables.put('CaseId', accId);
    	Flow.Interview.Send_SLA_Notification myFlow = new Flow.Interview.Send_SLA_Notification(variables);
    	myFlow.start();

		
		
        
        try {
            // Update the Account Record
            //update accList;
            
         
        } catch(Exception e) {
            System.debug(e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}