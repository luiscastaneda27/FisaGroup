global without sharing class JobValidacionRespuesta implements Schedulable { 
    
    global void execute(SchedulableContext ctx) {
        recordatorioRespuesta();
        recordatorioEncuesta();
    }
    
    public static void recordatorioRespuesta(){
        DateTime fecha = DateTime.now().addDays(-Integer.valueOf(Label.FS_DiasEnvioEncuesta));
        String nombrePlantilla = 'FS_ValidacionInformacion';
        String subEstado = 'Respuesta Enviada';
        List<Messaging.SingleEmailMessage> MessageList = new List<Messaging.SingleEmailMessage>();
        EmailTemplate plantilla = [Select Id, Subject, HTMLValue from EmailTemplate Where DeveloperName = :nombrePlantilla limit 1];
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :Label.FS_CorreoElectronicoServicio];
        String query = camposCaso();
        query += ' Where FS_SubEstado__c = :subEstado and FS_AceptaRespuesta__c = null and LastModifiedDate >= :fecha';
        for(Case item: Database.query(query)){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String asunnto = CaseTriggerHelper.reemplazarCampos(item, plantilla.Subject, 'Case');
            String html = CaseTriggerHelper.reemplazarCampos(item, plantilla.HTMLValue, 'Case');
            String urlLogo = CaseTriggerHelper.getLogoImagen();
            html = CaseTriggerHelper.getLogoImagen() + html.replace('{urlSiteServicios}', Label.FS_UrlPortalServicios);
            html =html.replace('{urlSiteEncuestas}', Label.FS_UrlPortalEncuestas);
            html = html.replace(']]>', '') + '</td><td style="width: 25%;" /></table>';
            mail.setSubject(asunnto);
            mail.setHtmlBody(html);
            mail.saveAsActivity = true;
            mail.setWhatId(item.Id);
            mail.setTargetObjectId(item.ContactId);
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
            MessageList.add(mail);
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(MessageList);
    }
    
    public static void recordatorioEncuesta(){
        DateTime fecha = DateTime.now().addDays(-Integer.valueOf(Label.FS_DiasEnvioEncuesta));
        String nombrePlantilla = 'FS_Encuesta';
        String subEstado = 'Respuesta aceptada';
        List<Messaging.SingleEmailMessage> MessageList = new List<Messaging.SingleEmailMessage>();
        EmailTemplate plantilla = [Select Id, Subject, HTMLValue from EmailTemplate Where DeveloperName = :nombrePlantilla limit 1];
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :Label.FS_CorreoElectronicoServicio];
        String query = camposCaso();
        query += ' Where FS_SubEstado__c = :subEstado and FS_FechaEnvioEncuesta__c >= :fecha';
        for(Case item: Database.query(query)){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String asunnto = CaseTriggerHelper.reemplazarCampos(item, plantilla.Subject, 'Case');
            String html = CaseTriggerHelper.reemplazarCampos(item, plantilla.HTMLValue, 'Case');
            String urlLogo = CaseTriggerHelper.getLogoImagen();
            html = CaseTriggerHelper.getLogoImagen() + html.replace('{urlSiteServicios}', Label.FS_UrlPortalServicios);
            html =html.replace('{urlSiteEncuestas}', Label.FS_UrlPortalEncuestas);
            html = html.replace(']]>', '') + '</td><td style="width: 25%;" /></table>';
            mail.setSubject(asunnto);
            mail.setHtmlBody(html);
            mail.saveAsActivity = true;
            mail.setWhatId(item.Id);
            mail.setTargetObjectId(item.ContactId);
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
            MessageList.add(mail);
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(MessageList);
    }
    
    public static String camposCaso(){
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap();
        String query = 'Select ';
        for(Schema.SObjectField sfield : fieldMap.Values()){
            schema.describefieldresult dfield = sfield.getDescribe();
            query += dfield.getname() + ',';
        }
        query =  query.substring(0, query.length() - 1) + ' From Case ';
        return query;
    }
    
}