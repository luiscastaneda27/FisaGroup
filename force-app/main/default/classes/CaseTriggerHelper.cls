public without sharing class CaseTriggerHelper {

    public static final String COLA_ATENCION_N1_CORE ='FS_AtencionN1Core';
    public static final String COLA_ATENCION_N2_CORE ='FS_AtencionN2Core';
    public static final String COLA_ATENCION_N1_OMNIA ='FS_AtencionN1Omnia';
    public static final String COLA_ATENCION_N2_OMNIA ='FS_AtencionN2Omnia';
    
    private static final String CONSULTA_TIPO_REGISTRO = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('FS_Consulta').getRecordTypeId();
    private static final String SOLICITUD_TIPO_REGISTRO = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('FS_Solicitud').getRecordTypeId();
    private static final String INCIDENTE_TIPO_REGISTRO = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('FS_Incidente').getRecordTypeId();
    
    public static void validacionCorreoNuevo(List<Case> newCaseList){
        for(Case item: newCaseList){
            if(item.RecordTypeId == CONSULTA_TIPO_REGISTRO || item.RecordTypeId == SOLICITUD_TIPO_REGISTRO || item.RecordTypeId == INCIDENTE_TIPO_REGISTRO){
                envioCorreo(item, 'FS_CreacionCaso', true);
                crearHistorialDescripcion(item, null, item.FS_DescripcionCliente__c);
            }
        }
    }
    
    public static void informacionCompleta(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_InformacionCompleta__c != item.FS_InformacionCompleta__c){
                if(item.FS_InformacionCompleta__c == 'Si'){
                    item.FS_SubEstado__c = 'Información validada';
                    item.Status = 'En Análisis';
                }else if(item.FS_InformacionCompleta__c == 'No'){
                    item.FS_SubEstado__c = 'En Espera de Respuesta del Cliente'; 
                    envioCorreo(item, 'FS_InformacionFaltante', true);
                }
            }
        }
    }
    
    public static void validacionTipo(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.Type  != item.Type && item.RecordTypeId == SOLICITUD_TIPO_REGISTRO){
                item.Status = 'En Análisis';
                item.FS_SubEstado__c = 'Análisis N1';
            }
        }
    }
    
    public static void actualizacionDescripcion(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_DescripcionCliente__c != item.FS_DescripcionCliente__c){
                crearHistorialDescripcion(item, caso.FS_DescripcionCliente__c, item.FS_DescripcionCliente__c);
                if(item.FS_SubEstado__c == 'En Espera de Respuesta del Cliente'){
                    item.FS_SubEstado__c = 'Análisis N1'; 
                    item.Status = 'En Análisis';
                    item.FS_InformacionCompleta__c = null;
                    envioCorreo(item, 'FS_ActualizacionInformacionCliente', false);
                }
            }
        }
    }
    
    public static void solventarPregunta(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        Map<String, String> mapColas = new Map<String, String>();
        for(Group item: [Select Id, DeveloperName from Group Where DeveloperName In (:COLA_ATENCION_N2_CORE, :COLA_ATENCION_N2_OMNIA) and Type = 'Queue']){
            mapColas.put(item.DeveloperName, item.Id);
        }
         for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_PudeSolventarPregunta__c != item.FS_PudeSolventarPregunta__c){
                if(item.FS_PudeSolventarPregunta__c == 'Si'){
                    item.FS_SubEstado__c = 'Envío de respuesta';
                    item.Status = 'Validación de Respuesta (Cliente)';
                    item.FS_AceptaRespuesta__c = null;
                    envioCorreo(item, 'FS_ValidacionInformacion', true);
                }else if(item.FS_PudeSolventarPregunta__c == 'No'){
                    Boolean esCore = item.FS_Producto__c == 'FISA System' || item.FS_Producto__c == 'FISA Credit Card' ;
                    item.OwnerId = mapColas.get(esCore ? COLA_ATENCION_N2_CORE : COLA_ATENCION_N2_OMNIA);
                    item.FS_Area__c =  esCore ? 'N2- CORE' : 'N2-OMNIA';
                    item.FS_SubEstado__c = 'Escalado a N2';
                    item.IsEscalated = true;
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
                    item.Status = 'Validación de Respuesta (Cliente)';
                    item.FS_EncuestaEnviada__c = true;
                    item.FS_FechaEnvioEncuesta__c = System.now();
                    envioCorreo(item, 'FS_Encuesta', true);
                    crearEncuesta(item);
                }else if(item.FS_AceptaRespuesta__c == 'No'){
                    item.FS_SubEstado__c = 'Respuesta rechazada';
                    item.FS_PudeSolventarPregunta__c = null;
                    envioCorreo(item, 'FS_RechazoRespuesta', false);
                }
                
            }
        }
    }
    
    public static void horasSolicitud(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_NumeroHorasSolicitud__c  != item.FS_NumeroHorasSolicitud__c){
                item.FS_SubEstado__c = 'En Espera de Respuesta del Cliente';
                item.Status = 'En Análisis';
                envioCorreo(item, 'FS_EnvioPrimerCosto', true);
            }
        }
    }
    
    public static void acepta1erCosto(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_Acepta1erCosto__c  != item.FS_Acepta1erCosto__c){
                if(item.FS_Acepta1erCosto__c == 'Si'){
                    item.Status = 'Aprobación 1er Costo';
                    item.FS_SubEstado__c = 'Costo Aceptado';
                    item.FS_FechaAprobacion1erCosto__c = System.now();
                    item.FS_UsuarioAprobador1erCosto__c = UserInfo.getUserId();
                }else if(item.FS_Acepta1erCosto__c == 'No'){
                    item.Status = 'Dado de baja';
                    item.FS_SubEstado__c = 'Costo Rechazado';
                }
            }
        }
    }
    
    public static void validacionEstado(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.Status  != item.Status){
                if(item.Status == 'Dado de baja'){
                    envioCorreo(item, 'FS_CasoCancelado', true);
                }else if (caso.FS_FechaContestacionEncuesta__c == item.FS_FechaContestacionEncuesta__c){
                    item.Status.addError('Privilegios insuficiente para modificar el estado del caso');   
                }
            }
        }
    }
    
    public static void validacionFechaEntrega(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_FechaCompromisoEntrega__c != item.FS_FechaCompromisoEntrega__c && caso.FS_FechaCompromisoEntrega__c == null){
                if(item.RecordTypeId == SOLICITUD_TIPO_REGISTRO){
                    item.Status = 'Análisis Falla Operativa';
                    item.FS_SubEstado__c = 'Análisis Falla Operativa';
                }else if(item.RecordTypeId == INCIDENTE_TIPO_REGISTRO){
                    item.Status = 'En Análisis';                    
                }
                
            }
        }
    }
    
    public static void validacionURLResultadoAnalasis(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_URLResultadoAnalasis__c != item.FS_URLResultadoAnalasis__c && String.isBlank(caso.FS_URLResultadoAnalasis__c)){
                item.FS_SubEstado__c = 'Desarrollo Incidente Puntual';
            }
        }
    }
    
    public static void validacionFechaEntregaDesarollo(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_FechaEntregaDesarrollo__c != item.FS_FechaEntregaDesarrollo__c){
                item.FS_SubEstado__c = 'Autorización Solución IP-N2';
                Id notificacionId = [SELECT Id FROM CUstomNotificationType Where DeveloperName = 'FS_NotificacionServicio' LIMIT 1].Id;
                for(User usuario : [Select Id from User where UserRoleId = :userInfo.getUserRoleId() And Id != :item.OwnerId]){
                    String titulo = 'Autorización Solución IP-N2 para caso '+item.CaseNumber;
                    String descripcion = 'El agente '+item.FS_NombrePropietario__c + ' necesita Autorización de Solución IP-N2 para el caso número '+item.CaseNumber +' \nPor favor dar seguimiento.';
                    enviarNotificacion(notificacionId, usuario.Id, item.Id, titulo, descripcion);
                }
            }
        }
    }
    
    public static void validacionAutorizacionSolucionIPN2(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_AutorizacionSolucionIPN2__c != item.FS_AutorizacionSolucionIPN2__c){
                Id notificacionId = [SELECT Id FROM CUstomNotificationType Where DeveloperName = 'FS_NotificacionServicio' LIMIT 1].Id;
                if(item.FS_AutorizacionSolucionIPN2__c == 'Si'){
                    item.FS_SubEstado__c = 'Aprobación de Solución IP-Release';
                    for(User usuario : [Select Id from User where UserRole.DeveloperName = 'FS_JefeReleases' And Id != :item.OwnerId]){
                        String titulo = 'Aprobación de Solución IP-Release para caso '+item.CaseNumber;
                        String descripcion = 'El agente '+item.FS_NombrePropietario__c + ' necesita Aprobación de Solución IP-Release para el caso número '+item.CaseNumber +' \nPor favor dar seguimiento.';
                        enviarNotificacion(notificacionId, usuario.Id, item.Id, titulo, descripcion);
                    }
                }else if(item.FS_AutorizacionSolucionIPN2__c == 'No'){
                    item.FS_SubEstado__c = 'Desarrollo Incidente Puntual';
                    String titulo = 'Rechazo de Autorización Solución IP-N2 para caso '+item.CaseNumber;
                    String descripcion = 'El agente '+UserInfo.getUserName() + ' ha rechzado la Autorización de Solución IP-N2 para el caso número '+item.CaseNumber +' \nPor favor dar seguimiento.';
                    enviarNotificacion(notificacionId, item.OwnerId, item.Id, titulo, descripcion);
                }
            }
        }
    }
    
    public static void validacionAprobacionSolucionIPRelease(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_AprobacionSolucionIPRelease__c != item.FS_AprobacionSolucionIPRelease__c){
                Id notificacionId = [SELECT Id FROM CUstomNotificationType Where DeveloperName = 'FS_NotificacionServicio' LIMIT 1].Id;
                if(item.FS_AprobacionSolucionIPRelease__c == 'Si'){
                    item.FS_SubEstado__c = 'Envío de respuesta';
                    item.Status = 'Validación de Respuesta (Cliente)';
                    item.FS_AceptaRespuesta__c = null;
                    
                    String titulo = 'Aprobación de Solución IP-Release para caso '+item.CaseNumber;
                    String descripcion = 'El Jefe de Release '+UserInfo.getUserName() + ' ha aprobado la Solución IP-Release para el caso número '+item.CaseNumber +' \nMuchas gracias.';
                    enviarNotificacion(notificacionId, item.OwnerId, item.Id, titulo, descripcion);
                }else if(item.FS_AutorizacionSolucionIPN2__c == 'No'){
                    item.FS_SubEstado__c = 'Desarrollo Incidente Puntual';
                    String titulo = 'Rechazo de Solución IP-Release para caso '+item.CaseNumber;
                    String descripcion = 'El Jefe de Release '+UserInfo.getUserName() + ' ha rechzado la Solución IP-Release para el caso número '+item.CaseNumber +' \nPor favor dar seguimiento.';
                    enviarNotificacion(notificacionId, item.OwnerId, item.Id, titulo, descripcion);
                }
            }
        }
    }
    
    public static void validacionTipoIncidente(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_TipoIncidente__c != item.FS_TipoIncidente__c && item.FS_TipoIncidente__c == 'Puntual'){
                item.Status = 'En Análisis';
                item.FS_SubEstado__c = 'Revisión Documentación N2';
            }
        }
    }

     
    
    public static void envioCorreo(Case caso, String nombrePlantilla, Boolean esContacto){
        List<Messaging.SingleEmailMessage> MessageList = new List<Messaging.SingleEmailMessage>();
        EmailTemplate plantilla = [Select Id, Subject, HTMLValue from EmailTemplate Where DeveloperName = :nombrePlantilla limit 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String asunnto = reemplazarCampos(caso, plantilla.Subject, 'Case');
        String html = reemplazarCampos(caso, plantilla.HTMLValue, 'Case');
        String urlLogo = getLogoImagen();
        html = getLogoImagen() + html.replace('{urlSiteServicios}', Label.FS_UrlPortalServicios);
        html = html.replace('{urlSiteEncuestas}', Label.FS_UrlPortalEncuestas);
        html = html.replace(']]>', '') + '</td><td style="width: 25%;" /></table>';
        mail.setSubject(asunnto);
        mail.setHtmlBody(html);
        mail.saveAsActivity = esContacto;
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :Label.FS_CorreoElectronicoServicio];
        mail.setOrgWideEmailAddressId(owea.get(0).Id);
        if(esContacto){
            User usuario = [Select Id, Profile.Name from user Where Id = :userInfo.getUserId()];
            if(usuario.Profile.Name != 'Customer Community User'){
                mail.setWhatId(caso.Id);
            }
            mail.setTargetObjectId(caso.ContactId);
        }else{
            User usuario = [Select Email from user Where Id = :caso.OwnerId];
            mail.setBccAddresses(new List<String>{usuario.Email});
        }
        MessageList.add(mail);
        try{
            Messaging.SendEmailResult[] results = Messaging.sendEmail(MessageList);
        }catch(Exception ex){
            System.debug(ex.getMessage()+' ----- '+ex.getLineNumber());
        }
    }
    
    public static void enviarNotificacion(String notificacionId, String usuarioId, String recordId, String titulo, String descripcion){
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle(titulo);
        notification.setBody(descripcion);
        notification.setNotificationTypeId(notificacionId);
        notification.setTargetId(recordId); 
        notification.send(new Set<String> { usuarioId }); 
    }
    public static void crearHistorialAprobaciones(Case caso){
        FS_AceptacionRechazoCaso__c aceptacion = new FS_AceptacionRechazoCaso__c ();
        aceptacion.FS_Caso__c = caso.Id;
        aceptacion.FS_Cliente__c = caso.AccountId;
        aceptacion.FS_Tipo__c = caso.FS_AceptaRespuesta__c == 'Si' ? 'Aceptación' : 'Rechazo'; 
        aceptacion.FS_MotivoRechazo__c = caso.FS_MotivoRechazo__c;
        aceptacion.FS_Comentarios__c = caso.FS_ComentariosRespuesta__c;
        insert aceptacion;
    }
    
    public static void crearHistorialDescripcion(Case caso, String valorOriginal, String valorNuevo){
        FS_HistorialDescripcionCaso__c historial = new FS_HistorialDescripcionCaso__c  ();
        historial.FS_Caso__c = caso.Id;
        historial.FS_ValorOriginal__c = valorOriginal;
        historial.FS_ValorNuevo__c = valorNuevo;
        insert historial;
    }
    
    public static void crearEncuesta(Case caso){
        FS_Encuesta__c encuesta = new FS_Encuesta__c (FS_Caso__c = Caso.Id, FS_CreadoPor__c = UserInfo.getUserId());
        insert encuesta;
    }
    
    public static String getLogoImagen(){
        StaticResource staticResource = [SELECT Id, SystemModStamp, Name
                                         FROM StaticResource 
                                         WHERE Name = 'FS_FisaLogo'
                                         LIMIT 1];
        String urlRecurso = '<table width="100%" ><td style="width: 25%;" /><td style="width: 50%;" ><table><tr><td><img src="';
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