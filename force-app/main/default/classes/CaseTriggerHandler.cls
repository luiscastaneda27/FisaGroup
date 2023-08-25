public without sharing class CaseTriggerHandler {

    public static void beforeInsert(List<Case> newCaseList){
        //CaseTriggerHelper.asignacionCola(newCaseList);
    }
    
    public static void afterInsert(List<Case> newCaseList, List<Case> oldCaseList){
        CaseTriggerHelper.validacionCorreoNuevo(newCaseList);
        //Create Issue in Jira
        CaseTriggerHelper.createIssueJira(newCaseList, oldCaseList);
    }
    
    public static void beforeUpdate(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        CaseTriggerHelper.validacionEstado(newCaseList, oldCaseMap);
        //CaseTriggerHelper.validacionSubEstado(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionProducto(newCaseList, oldCaseMap);
        CaseTriggerHelper.informacionCompleta(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionTipo(newCaseList, oldCaseMap);
        CaseTriggerHelper.solventarPregunta(newCaseList, oldCaseMap);
        CaseTriggerHelper.aceptaRespuesta(newCaseList, oldCaseMap);
        CaseTriggerHelper.actualizacionDescripcion(newCaseList, oldCaseMap);
        CaseTriggerHelper.horasSolicitud(newCaseList, oldCaseMap);
        CaseTriggerHelper.acepta1erCosto(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionFechaEntrega(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionTipoIncidente(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionURLResultadoAnalasis(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionAutorizacionSolucionIPN2(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionAprobacionSolucionIPRelease(newCaseList, oldCaseMap);
        
        CaseTriggerHelper.validacionSolucionCortoPlazo(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionURLDisenioTecnico(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionAprobacionDisenioTecnico(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionURLCodigoFuente(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionURLSolucionDefinitiva(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionAprobacionSolucionDefinitiva(newCaseList, oldCaseMap);
        
    }
    
    public static void afterUpdate(List<Case> newCaseList, Map<Id, Case> oldCaseMap) {
    	//Update Issue in Jira
        //CaseTriggerHelper.updateIssueJira(newCaseList, oldCaseList);
        CaseTriggerHelper.upsertCaseJira(newCaseList, oldCaseMap);
    }
    
    
}