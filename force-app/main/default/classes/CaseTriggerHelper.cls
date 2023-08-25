public without sharing class CaseTriggerHelper {

    public static final String COLA_ATENCION_N1_CORE ='FS_AtencionN1Core';
    public static final String COLA_ATENCION_N2_CORE ='FS_AtencionN2Core';
    public static final String COLA_ATENCION_N1_OMNIA ='FS_AtencionN1Omnia';
    public static final String COLA_ATENCION_N2_OMNIA ='FS_AtencionN2Omnia';
    public static final String COLA_ATENCION_QA_OMNIA ='FS_AtencionQAOmnia';
    public static final String COLA_ATENCION_QA_CORE ='FS_AtencionQACore';
    public static Map<String, String> mapColas;
    
    static{
        mapColas = new Map<String, String>();
        Map<String, String> mapColas = new Map<String, String>();
        for(Group item: [Select Id, DeveloperName from Group Where DeveloperName Like '%FS_%' and Type = 'Queue']){
            mapColas.put(item.DeveloperName, item.Id);
        }
    }
    
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
    
    public static void validacionProducto(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        Boolean flag = false;
        List<String> listAccount = new  List<String>();
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_Producto__c != item.FS_Producto__c || caso.FS_Modulo__c != item.FS_Modulo__c || caso.FS_SubModulo__c != item.FS_SubModulo__c){
                flag = true;
                listAccount.add(item.AccountId);
            }
        }
        if(flag){
            List<FS_ProductoAdquirido__c> productos = [Select FS_Cuenta__c, FS_Producto__c, FS_Modulo__c, FS_SubModulo__c from FS_ProductoAdquirido__c Where FS_Cuenta__c in :listAccount];
            for(Case item: newCaseList){
                flag = false;
                for(FS_ProductoAdquirido__c p :productos){
                    if(item.AccountId == p.FS_Cuenta__c && item.FS_Producto__c == p.FS_Producto__c && item.FS_Modulo__c == p.FS_Modulo__c && item.FS_SubModulo__c == p.FS_SubModulo__c){
                        flag = true;
                    }
                }
                if(!flag){
                    item.addError('El cliente no tiene la combinación de productos seleccionados');
                }else{
                     Case caso = oldCaseMap.get(item.Id);
                    if(caso.FS_Producto__c != item.FS_Producto__c){
                        Boolean esCore = item.FS_Producto__c == 'FISA System' || item.FS_Producto__c == 'FISA Credit Card' ;
                        item.FS_Area__c = esCore ? 'N1. CORE' : 'N1. OMNIA';
                        item.OwnerId = [Select Id from Group Where DeveloperName = :(esCore ? COLA_ATENCION_N1_CORE : COLA_ATENCION_N1_OMNIA) and Type = 'Queue'].Id;
                    }
                }
            }
            
        }
        
    }
    
    public static void informacionCompleta(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        List<String> listAccount = new  List<String>();
        List<String> listProductos = new  List<String>();
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(String.isBlank(item.FS_SubModulo__c)){
                listAccount.add(item.AccountId);
            }
        }
        for(FS_ProductoAdquirido__c item: [Select FS_Cuenta__c, FS_Producto__c, FS_Modulo__c, FS_SubModulo__c from FS_ProductoAdquirido__c Where FS_Cuenta__c = :listAccount]){
            String prod = item.FS_Cuenta__c  + item.FS_Producto__c + item.FS_Modulo__c + item.FS_SubModulo__c;
            listProductos.add(prod);
        }
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_InformacionCompleta__c != item.FS_InformacionCompleta__c){
                if(item.FS_InformacionCompleta__c == 'Si'){
                    String prod = item.AccountId  + item.FS_Producto__c + item.FS_Modulo__c + item.FS_SubModulo__c;
                    String msjError = 'Debe Completar los siguientes campos ';
                    msjError += String.isBlank(item.FS_Proyecto__c) ? 'Proyecto, ' : '';
                    msjError += item.FS_FechaCompromisoEntrega__c == null ? 'Fecha de Compromiso de Entrega, ' : '';
                    msjError += String.isBlank(item.FS_SubModulo__c) && !listProductos.contains(prod) ? 'Sub Módulo, ' : '';
                    if(msjError.length() > 37){
                        item.addError(msjError.substring(0, msjError.length() - 2));
                    }
                    if(item.FS_SubEstado__c == 'Revisión Documentación N2'){
                        item.FS_SubEstado__c = item.FS_TipoIncidente__c == 'Puntual' ? 'Desarrollo Incidente Puntual' : 'Desarrollo Incidente Definitivo';
                    }else{
                        item.FS_SubEstado__c = 'Información validada';
                        item.Status = 'En Análisis';
                    }
                }else if(item.FS_InformacionCompleta__c == 'No'){
                    item.FS_SubEstadoQueSePideInformacion__c = item.FS_SubEstado__c;
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
                    item.FS_SubEstado__c = item.FS_SubEstadoQueSePideInformacion__c;
                    item.FS_SubEstadoQueSePideInformacion__c = null;
                    item.Status = 'En Análisis';
                    item.FS_InformacionCompleta__c = null;
                    envioCorreo(item, 'FS_ActualizacionInformacionCliente', false);
                }
            }
        }
    }
    
    public static void solventarPregunta(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        /*Map<String, String> m.apColas = new Map<String, String>();
        for(Group item: [Select Id, DeveloperName from Group Where DeveloperName In (:COLA_ATENCION_N2_CORE, :COLA_ATENCION_N2_OMNIA) and Type = 'Queue']){
            m.apColas.put(item.DeveloperName, item.Id);
        }*/
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
                    item.Status = 'Pendiente de Respuesta CSAT';
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
    
    public static void validacionSubEstado(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            if(item.FS_SubEstado__c == 'Aprobación Solución IP-N2' && item.FS_UsuarioAprobadorSolucionIPN2__c != UserInfo.getUserId() ){
                item.addError('El caso se encuentra en Aprobación de Solución IP-N2 y no tiene permisos para modificarlo.');
            }else if(item.FS_SubEstado__c == 'Aprobación de Solución IP-Release' && String.isBlank(item.FS_UsuarioAprobacionSolucionRelease__c) ){
                item.addError('El caso se encuentra en Aprobación de Solución IP-Release y no tiene permisos para modificarlo.');
            }else if(item.FS_SubEstado__c == 'Aprobación Diseño Técnico' && item.FS_UsuarioAprobadorDT__c != UserInfo.getUserId()){
                item.addError('El caso se encuentra en Aprobación de Diseño Técnico y no tiene permisos para modificarlo.');
            }else if(item.FS_SubEstado__c == 'Aprobación Solución Definitiva N2' && item.FS_UsuarioAprobadorDT__c != UserInfo.getUserId()){
                item.addError('El caso se encuentra en Aprobación Solución Definitiva N2 y no tiene permisos para modificarlo.');
            }else if(item.FS_SubEstado__c == 'Aprobación Solución Definitiva Releases' && String.isBlank(item.FS_UsuarioAprobacionSolucionRelease__c)){
                item.addError('El caso se encuentra en Aprobación de Solución Definitiva Releases y no tiene permisos para modificarlo.');
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
                item.FS_SubEstado__c = 'Aprobación Solución IP-N2';
                item.FS_AprobacionSolucionIPN2__c = null;
                item.FS_MotivosRechazoAprobacionIPN2__c = null;
                if(item.FS_UsuarioAprobadorSolucionIPN2__c == null){
                    for(User usuario : [Select Id, FS_FechaUltimaAprobacion__c from User where UserRoleId = :item.FS_RolPropietario__c And Id != :item.OwnerId Order by FS_FechaUltimaAprobacion__c asc limit 1]){
                        usuario.FS_FechaUltimaAprobacion__c = System.now();
                        item.FS_UsuarioAprobadorSolucionIPN2__c = usuario.Id;
                        update usuario;
                    }
                }
                String titulo = 'Aprobación Solución IP-N2 para caso '+item.CaseNumber;
                String descripcion = 'El agente '+item.FS_NombrePropietario__c + ' necesita Aprobación de Solución IP-N2 para el caso número '+item.CaseNumber +' \nPor favor dar seguimiento.';
                enviarNotificacion(item.FS_UsuarioAprobadorSolucionIPN2__c, item.Id, titulo, descripcion);
            }
        }
    }
    
    public static void validacionAutorizacionSolucionIPN2(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_AprobacionSolucionIPN2__c != item.FS_AprobacionSolucionIPN2__c){
                if(item.FS_AprobacionSolucionIPN2__c == 'Si'){
                    item.FS_AprobacionSolucionIPRelease__c = null;
                    item.FS_MotivoRechazoAprobacionIPRealease__c = null;
                    item.FS_SubEstado__c = 'Aprobación de Solución IP-Release';
                }else if(item.FS_AprobacionSolucionIPN2__c == 'No'){
                    item.FS_URLResultadoAnalasis__c = null;
                    item.FS_SubEstado__c = 'Desarrollo Incidente Puntual';
                    String titulo = 'Rechazo de Aprobación Solución IP-N2 para caso '+item.CaseNumber;
                    String descripcion = 'El agente '+UserInfo.getFirstName() + ' ha rechzado la Aprobación de Solución IP-N2 para el caso número '+item.CaseNumber +' \nPor favor dar seguimiento.';
                    enviarNotificacion(item.OwnerId, item.Id, titulo, descripcion);
                }
            }
        }
    }
    
    public static void validacionAprobacionSolucionIPRelease(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_AprobacionSolucionIPRelease__c != item.FS_AprobacionSolucionIPRelease__c){
                if(item.FS_AprobacionSolucionIPRelease__c == 'Si'){
                    item.FS_SubEstado__c = 'Envío de respuesta';
                    item.Status = 'Validación de Respuesta (Cliente)';
                    item.FS_AceptaRespuesta__c = null;
                    
                    String titulo = 'Aprobación de Solución IP-Release para caso '+item.CaseNumber;
                    String descripcion = 'El Jefe de Release ' + item.FS_UsuarioAprobacionSolucionRelease__c + ' ha aprobado la Solución IP-Release para el caso número '+item.CaseNumber +' \nMuchas gracias.';
                    enviarNotificacion(item.OwnerId, item.Id, titulo, descripcion);
                }else if(item.FS_AprobacionSolucionIPRelease__c == 'No'){
                     item.FS_URLResultadoAnalasis__c = null;
                    item.FS_SubEstado__c = 'Desarrollo Incidente Puntual';
                    String titulo = 'Rechazo de Solución IP-Release para caso '+item.CaseNumber;
                    String descripcion = 'El Jefe de Release ' + item.FS_UsuarioAprobacionSolucionRelease__c + ' ha rechzado la Solución IP-Release para el caso número '+item.CaseNumber +' \nPor favor dar seguimiento.';
                    enviarNotificacion(item.OwnerId, item.Id, titulo, descripcion);
                }
            }
        }
    }
    
    public static void validacionTipoIncidente(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_TipoIncidente__c != item.FS_TipoIncidente__c){
                item.Status = 'En Análisis';
                Boolean esCore = item.FS_Producto__c == 'FISA System' || item.FS_Producto__c == 'FISA Credit Card' ;
                item.OwnerId = mapColas.get(esCore ? COLA_ATENCION_N2_CORE : COLA_ATENCION_N2_OMNIA);
                item.FS_Area__c =  esCore ? 'N2- CORE' : 'N2-OMNIA';
                item.FS_SubEstado__c = 'Escalado a N2';
                item.IsEscalated = true;
                item.FS_InformacionCompleta__c = null;
            }
        }
    }
    
    public static void validacionSolucionCortoPlazo(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_SolucionCortoPlazo__c != item.FS_SolucionCortoPlazo__c && String.isNotBlank(item.FS_SolucionCortoPlazo__c)){
                if(item.FS_SolucionCortoPlazo__c == 'Si'){
                    if(String.isBlank(item.FS_PropietarioCasoSolucionCortoPlazo__c)){
                        item.FS_PropietarioCasoSolucionCortoPlazo__c.addError('Debe completar el propietario del caso que esta por crearse.');
                        return;
                    }
                    Case casoHijo = item.clone(false, false, false, false);
                    casoHijo.OwnerId = item.FS_PropietarioCasoSolucionCortoPlazo__c;
                    casoHijo.Subject += ' Caso hijo de ' + Item.CaseNumber;
                    casoHijo.Status = 'En Análisis';
                    casoHijo.FS_SubEstado__c = 'Revisión Documentación N2';
                    casoHijo.ParentId = item.Id;
                    casoHijo.FS_TipoIncidente__c = 'Puntual';
                    casoHijo.FS_SolucionCortoPlazo__c = null;
                    insert casoHijo;
                }
                item.FS_SubEstado__c = 'Elaboración Diseño Técnico';
            }
        }
    }
    
    public static void validacionURLDisenioTecnico(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_URLDisenioTecnico__c  != item.FS_URLDisenioTecnico__c  && String.isBlank(caso.FS_URLDisenioTecnico__c)){
                item.FS_SubEstado__c = 'Aprobación Diseño Técnico';
                item.FS_AprobacionDisenioTecnico__c = null;
                item.FS_MotivosRechazoDT__c = null;
                if(item.FS_UsuarioAprobadorDT__c == null){
                    for(User usuario : [Select Id, FS_FechaUltimaAprobacion__c from User where UserRoleId = :item.FS_RolPropietario__c And Id != :item.OwnerId and IsActive = true Order by FS_FechaUltimaAprobacion__c asc limit 1]){
                        usuario.FS_FechaUltimaAprobacion__c = System.now();
                        item.FS_UsuarioAprobadorDT__c = usuario.Id;
                        update usuario;
                    }
                }
                String titulo = 'Aprobación Diseño Técnico para caso '+item.CaseNumber;
                String descripcion = 'El agente '+item.FS_NombrePropietario__c + ' necesita Aprobación Diseño Técnico para el caso número '+item.CaseNumber +' \nPor favor dar seguimiento.';
                enviarNotificacion(item.FS_UsuarioAprobadorDT__c, item.Id, titulo, descripcion);

            }
        }
    }
    
    public static void validacionAprobacionDisenioTecnico(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_AprobacionDisenioTecnico__c  != item.FS_AprobacionDisenioTecnico__c){
                if(item.FS_AprobacionDisenioTecnico__c == 'Si'){
                    item.FS_SubEstado__c = 'Validación-Entrega de Fuentes';
                }else if(item.FS_AprobacionDisenioTecnico__c == 'No'){
                    item.FS_URLDisenioTecnico__c = null;
                    item.FS_SubEstado__c = 'Elaboración Diseño Técnico';
                    String titulo = 'Rechazo Diseño Técnico para caso '+item.CaseNumber;
                    String descripcion = 'El agente '+UserInfo.getUserName() + ' ha rechazado el diseño técnico para el caso número '+item.CaseNumber +' \nPor favor dar seguimiento.';
                    enviarNotificacion(item.OwnerId, item.Id, titulo, descripcion);
                }
            }
        }
    }
    
    public static void validacionURLCodigoFuente(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_URLCodigoFuente__c != item.FS_URLCodigoFuente__c  && String.isBlank(caso.FS_URLCodigoFuente__c)){
                item.FS_SubEstado__c = 'Elaboración Solución Definitiva';
            }
        }
    }
    
    public static void validacionURLSolucionDefinitiva(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_URLSolucionDefinitiva__c != item.FS_URLSolucionDefinitiva__c  && String.isBlank(caso.FS_URLSolucionDefinitiva__c)){
                item.FS_SubEstado__c = 'Aprobación Solución Definitiva N2';
            }
        }
    }
    
     public static void validacionAprobacionSolucionDefinitiva(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_AprobacionSolucionDefinitivaN2__c != item.FS_AprobacionSolucionDefinitivaN2__c ){
                if(item.FS_AprobacionSolucionDefinitivaN2__c == 'Si'){
                    item.FS_SubEstado__c = 'Aprobación Solución Definitiva Releases';
                }else if(item.FS_AprobacionSolucionDefinitivaN2__c == 'No'){
                    item.FS_URLSolucionDefinitiva__c = null;
                    item.FS_SubEstado__c = 'Elaboración Solución Definitiva';
                    String titulo = 'Rechazo de Solución Definitiva N2 para caso '+item.CaseNumber;
                    String descripcion = 'El agente '+UserInfo.getUserName() + ' ha rechazado la Solución Definitiva N2 para el caso número '+item.CaseNumber +' \nPor favor dar seguimiento.';
                    enviarNotificacion(item.OwnerId, item.Id, titulo, descripcion);
                }
            }
        }
    }
    
    public static void validacionAprobacionSolucionDefinitivaRelease(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_AprobacionSolucionDefinitivaRelease__c != item.FS_AprobacionSolucionDefinitivaRelease__c){
                if(item.FS_AprobacionSolucionDefinitivaRelease__c == 'Si'){
                    Boolean esCore = item.FS_Producto__c == 'FISA System' || item.FS_Producto__c == 'FISA Credit Card' ;
                    item.OwnerId = mapColas.get(esCore ? COLA_ATENCION_QA_CORE : COLA_ATENCION_QA_OMNIA);
                    item.FS_Area__c =  esCore ? 'QA CC-CORE' : 'QA CC-OMNIA';
                    item.FS_SubEstado__c = 'Escalado a QA';
                }else if(item.FS_AprobacionSolucionDefinitivaRelease__c == 'No'){
                    
                }
            }
        }
    }

     
    public static void upsertCaseJira(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        List<Case> casesNewIP = new List<Case>();
        List<Case> casesNewID = new List<Case>();
        List<Case> casesOldIP = new List<Case>();
        List<Case> casesOldID = new List<Case>();
        
        List<Case> casesNewUpdateIP = new List<Case>();
        List<Case> casesNewUpdateID = new List<Case>();
        List<Case> casesOldUpdateIP = new List<Case>();
        List<Case> casesOldUpdateID = new List<Case>();
        
        for(Case item: newCaseList){
            Case caso = oldCaseMap.get(item.Id);
            if(caso.FS_SubEstado__c != item.FS_SubEstado__c && item.FS_TipoIncidente__c == 'Puntual'){
                if(item.FS_SubEstado__c == 'Desarrollo Incidente Puntual'){
                    casesNewIP.add(item);
                    casesOldIP.add(caso);
                }
            }if(caso.FS_SubEstado__c != item.FS_SubEstado__c && item.FS_TipoIncidente__c == 'Definitivo'){
                if(item.FS_SubEstado__c == 'Desarrollo Incidente Definitivo'){
                    casesNewID.add(item);
                    casesOldID.add(caso);
                }
            }
        }
        if(!casesNewIP.isEmpty()){
            createIssueJira(casesNewIP, casesOldIP);
        }
        if(!casesNewID.isEmpty()){
            createIssueJira(casesNewID, casesOldID);
        }
        if(!casesNewUpdateIP.isEmpty()){
            updateIssueJira(casesNewUpdateIP, casesOldUpdateIP);
        }
        if(!casesNewUpdateID.isEmpty()){
            updateIssueJira(casesNewUpdateID, casesOldUpdateID);
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
    
    public static void enviarNotificacion(String usuarioId, String recordId, String titulo, String descripcion){
        Id notificacionId = [SELECT Id FROM CUstomNotificationType Where DeveloperName = 'FS_NotificacionServicio' LIMIT 1].Id;
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
    
    public static void createIssueJira(List<Case> newCaseList, List<Case> oldCaseList) { 
        String jiraProjectId = System.Label.FS_IdJiraProject; // Id Jira Project
        String jiraIssueTypeId = newCaseList[0].FS_TipoIncidente__c == 'Definitivo' ? System.Label.FS_IdIssueJiraIncidenteDefinitivo : System.Label.FS_IdIssueJiraPuntual; // Id Issue Jira: Incidente Definitivo
        System.debug('jiraIssueTypeId: '+jiraIssueTypeId);
        JCFS.API.createJiraIssue(jiraProjectId, '11150', newCaseList, oldCaseList);
    }
    
    public static void updateIssueJira(List<Case> newCaseList, List<Case> oldCaseList) {       
        //Conditions to update de Issue in Jira
        JCFS.API.pushUpdatesToJira(newCaseList, oldCaseList);
    }
    
}