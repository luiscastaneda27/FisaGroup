global class scheduledSendMilestoneNotification implements Schedulable {
   global void execute(SchedulableContext sc) {
      SendMilestoneNotification b = new SendMilestoneNotification(); 
      Database.executeBatch(b);
   }
}