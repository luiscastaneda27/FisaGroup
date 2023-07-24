public without sharing class CaseTriggerHelper {

    private static final String COLA_ATENCION_N1 ='FS_AtencionN1';
    private static final String COLA_ATENCION_N2 ='FS_AtencionN2';
    
    private static final String CONSULTA_TIPO_REGISTRO = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('FS_Consulta').getRecordTypeId();
    private static final String SOLICITUD_TIPO_REGISTRO = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('FS_Solicitud').getRecordTypeId();
    
    public static void asignacionCola(List<Case> newCaseList){
        Id colaAtencionN1Id = [Select Id from Group Where DeveloperName = :COLA_ATENCION_N1 and Type = 'Queue'].Id;
        for(Case item: newCaseList){
            if(item.RecordTypeId == CONSULTA_TIPO_REGISTRO){
                item.OwnerId = colaAtencionN1Id;
                item.Status = 'Nuevo';
                item.FS_SubEstado__c = 'Apertura de caso';
            }
        }
    }
    
    public static void validacionCorreoNuevo(List<Case> newCaseList){
        for(Case item: newCaseList){
            if(item.RecordTypeId == CONSULTA_TIPO_REGISTRO){
                envioCorreo(item, 'FS_CreacionCaso', true);
            }
        }
    }
    
    /*public static void validacionCorreoActualizacion(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
         List<String> listUserId = new  List<String>();
         List<String> listUser = new  List<String>();
         Id colaAtencionN1Id = [Select Id from Group Where DeveloperName = :COLA_ATENCION_N1 and Type = 'Queue'].Id;
         for(Case item: newCaseList){
             Case caso = oldCaseMap.get(item.Id);
             if(caso.OwnerId != item.OwnerId && caso.OwnerId == colaAtencionN1Id){
                 listUserId.add(item.OwnerId);
                 System.debug('Hola');
             }
         }
         if(listUserId.size() > 0){
             for(User item :[Select Id from User Where Id in :listUserId]){
                 listUser.add(item.Id);
             }
             System.debug('Hola');
             for(Case item: newCaseList){
                 if(listUser.contains(item.OwnerId)){
                     System.debug('Hola');
                     item.FS_SubEstado__c = 'Entrega 1a respuesta';
                     envioCorreo(item, 'FS_AsignacionCaso', true);
                 }
             }
         }
    }
    
    public static void cambioSubEstadoAnalisis(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.Status != item.Status && item.Status == 'En Análisis'){
                envioCorreo(item, 'FS_AnalisisCaso', true);
            }
        }
    }*/
    
    public static void informacionCompleta(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_InformacionCompleta__c != item.FS_InformacionCompleta__c){
                if(item.FS_InformacionCompleta__c == 'Si'){
                    item.FS_SubEstado__c = 'Información validada'; 
                }else if(item.FS_InformacionCompleta__c == 'No'){
                    item.FS_SubEstado__c = 'En Espera de Respuesta del Cliente'; 
                    envioCorreo(item, 'FS_InformacionFaltante', true);
                }
            }
        }
    }
    
    public static void actualizacionDescripcion(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_DescripcionCliente__c != item.FS_DescripcionCliente__c && item.FS_SubEstado__c == 'En Espera de Respuesta del Cliente'){
                item.FS_SubEstado__c = 'Análisis Consulta N1'; 
                item.Status = 'En Análisis';
                item.FS_InformacionCompleta__c = null;
                envioCorreo(item, 'FS_ActualizacionInformacionCliente', false);
            }
        }
    }
    
    public static void solventarPregunta(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        Id colaAtencionN2Id = [Select Id from Group Where DeveloperName = :COLA_ATENCION_N2 and Type = 'Queue'].Id;
         for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_PudeSolventarPregunta__c != item.FS_PudeSolventarPregunta__c){
                if(item.FS_PudeSolventarPregunta__c == 'Si'){
                    item.FS_SubEstado__c = 'Envío de respuesta';
                    item.Status = 'Entregado';
                    item.FS_AceptaRespuesta__c = null;
                    envioCorreo(item, 'FS_ValidacionInformacion', true);
                }else if(item.FS_PudeSolventarPregunta__c == 'No'){
                    item.OwnerId = colaAtencionN2Id;
                    item.FS_SubEstado__c = 'Escalado a N2';
                    item.FS_InformacionCompleta__c = null;
                }
                
            }
        }
    }
    
    public static void aceptaRespuesta(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_AceptaRespuesta__c != item.FS_AceptaRespuesta__c && item.FS_AceptaRespuesta__c != null){
                crearHistorialAprobaciones(item);
                if(item.FS_AceptaRespuesta__c == 'Si'){
                    item.FS_SubEstado__c = 'Respuesta aceptada';
                    item.Status = 'Pendiente de Respuesta CSAT';
                    item.FS_EncuestaEnviada__c = true;
                    item.FS_FechaEnvioEncuesta__c = System.now();
                    envioCorreo(item, 'FS_Encuesta', true);
                }else if(item.FS_AceptaRespuesta__c == 'No'){
                    item.FS_SubEstado__c = 'Respuesta rechazada';
                    item.FS_PudeSolventarPregunta__c = null;
                    envioCorreo(item, 'FS_RechazoRespuesta', false);
                }
                
            }
        }
    }
    
    public static void casoCancelado(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.Status  != item.Status && item.Status == 'Dado de baja'){
                envioCorreo(item, 'FS_CasoCancelado', true);
            }
        }
    }
    
   /* public static void respuestaValidada(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_RespuestaValidada__c  != item.FS_RespuestaValidada__c){
                if(item.FS_InformacionCompleta__c == 'Si'){
                    item.Status = 'Validación de Respuesta (Cliente)';
                }else if(item.FS_InformacionCompleta__c == 'No'){
                    item.FS_SubEstado__c = 'Respuesta rechazada';
                    envioCorreo(item, 'FS_RechazoRespuesta', false);
                }
            }
        }
    }*/

     
    
    public static void envioCorreo(Case caso, String nombrePlantilla, Boolean esContacto){
        List<Messaging.SingleEmailMessage> MessageList = new List<Messaging.SingleEmailMessage>();
        EmailTemplate plantilla = [Select Id, Subject, HTMLValue from EmailTemplate Where DeveloperName = :nombrePlantilla limit 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String asunnto = reemplazarCampos(caso, plantilla.Subject, 'Case');
        String html = reemplazarCampos(caso, plantilla.HTMLValue, 'Case');
        String urlLogo = getLogoImagen();
        html = getLogoImagen() + html.replace('{urlSiteServicios}', Label.FS_UrlPortalServicios);
        html =html.replace('{urlSiteEncuestas}', Label.FS_UrlPortalEncuestas);
        html = html.replace(']]>', '') + '</td><td style="width: 25%;" /></table>';
        mail.setSubject(asunnto);
        mail.setHtmlBody(html);
        System.debug(html);
        mail.saveAsActivity = esContacto;
        if(esContacto){
            //mail.setWhatId(caso.Id);
            mail.setTargetObjectId(caso.ContactId);
        }else{
            mail.setTargetObjectId(caso.OwnerId);
        }
        MessageList.add(mail);
        try{
            Messaging.SendEmailResult[] results = Messaging.sendEmail(MessageList);
        }catch(Exception ex){
            caso.addError(JSON.serialize(caso)+' ----- '+ex.getLineNumber() +' ----- '+ex.getMessage());
        }
    }
    public static void crearHistorialAprobaciones(Case caso){
        FS_AceptacionRechazoCaso__c aceptacion = new FS_AceptacionRechazoCaso__c ();
        aceptacion.FS_Caso__c = caso.Id;
        aceptacion.FS_Cliente__c = caso.AccountId;
        aceptacion.FS_Tipo__c = caso.FS_AceptaRespuesta__c == 'Si' ? 'Aceptación' : 'Rechazo'; 
        aceptacion.FS_MotivoInsatisfaccion__c = caso.FS_MotivoInsatisfaccion__c;
        insert aceptacion;
    }
    
    public static Contact crearContacto(String userId){
        User usuario = [Select FirstName, LastName, Email from user Where Id = :userId];
        Contact contacto = new Contact();
        contacto.FirstName = usuario.FirstName;
        contacto.LastName = usuario.LastName;
        contacto.Email = usuario.Email;
        insert contacto;
        return contacto;
    }
    
    public static String getLogoImagen(){
        StaticResource staticResource = [SELECT Id, SystemModStamp, Name
                                         FROM StaticResource 
                                         WHERE Name = 'FS_FisaLogo'
                                         LIMIT 1];
        String urlRecurso = '<table width="100%" ><td style="width: 25%;" /><td style="width: 50%;" ><table><tr><td><img src="';
        //urlRecurso +='https://fisagrp--devfs.sandbox.file.force.com/servlet/servlet.ImageServer?id=0156C000000QROw&oid=00D6C0000000gkO&lastMod=1689260873000' ;
        urlRecurso += Label.FS_UrlPortalEncuestas.substring(0, Label.FS_UrlPortalEncuestas.length()- 1);
        urlRecurso +='resource/' + String.valueOf(staticResource.SystemModStamp.getTime())+ '/' + staticResource.Name;
        urlRecurso += '"/></td></tr></table>';
        return urlRecurso;
    }
    
    public static String reemplazarCampos(Case caso, String html, String objeto){
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objeto).getDescribe().fields.getMap();
        for(Schema.SObjectField sfield : fieldMap.Values()){
            schema.describefieldresult dfield = sfield.getDescribe();
            String campo = dfield.getname();
            String objCampo = '{!' + objeto + '.' + campo +'}';
            if(html.contains(objCampo)){
                String valorCampo = caso.get(campo) != null ? (String) caso.get(campo) : '';
                html = html.replace(objCampo, valorCampo);
            }
        }
        return html;
    }
    
}