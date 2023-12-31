global without sharing class JobValidacionRespuesta implements Schedulable { 
    
    global void execute(SchedulableContext ctx) {
        recordatorioRespuesta();
        recordatorioEncuesta();
    }
    
    public static void recordatorioRespuesta(){
        String nombrePlantilla = 'FS_ValidacionInformacion';
        String subEstado = 'Respuesta Enviada';
        List<Messaging.SingleEmailMessage> MessageList = new List<Messaging.SingleEmailMessage>();
        EmailTemplate plantilla = [Select Id from EmailTemplate Where DeveloperName = :nombrePlantilla limit 1];
        
        for(Case item: [Select Id, ContactId from Case Where FS_SubEstado__c = :subEstado and FS_AceptaRespuesta__c = null]){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(plantilla.Id);      
            mail.saveAsActivity = true;
            mail.setWhatId(item.Id);
            mail.setTargetObjectId(item.ContactId);
            MessageList.add(mail);
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(MessageList);
    }
    
    public static void recordatorioEncuesta(){
        String nombrePlantilla = 'FS_Encuesta';
        String subEstado = 'Respuesta aceptada';
        List<Messaging.SingleEmailMessage> MessageList = new List<Messaging.SingleEmailMessage>();
        EmailTemplate plantilla = [Select Id from EmailTemplate Where DeveloperName = :nombrePlantilla limit 1];
        
        for(Case item: [Select Id, ContactId from Case Where FS_SubEstado__c = :subEstado and FS_AceptaRespuesta__c = null]){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(plantilla.Id);      
            mail.saveAsActivity = true;
            mail.setWhatId(item.Id);
            mail.setTargetObjectId(item.ContactId);
            MessageList.add(mail);
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(MessageList);
    }
    
}