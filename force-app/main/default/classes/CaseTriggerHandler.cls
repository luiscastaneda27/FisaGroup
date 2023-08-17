public without sharing class CaseTriggerHandler {

    public static void beforeInsert(List<Case> newCaseList){
        //CaseTriggerHelper.asignacionCola(newCaseList);
    }
    
    public static void afterInsert(List<Case> newCaseList){
        CaseTriggerHelper.validacionCorreoNuevo(newCaseList);
        CaseTriggerHelper.createIssueJira(newCaseList);
    }
    
    public static void beforeUpdate(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        CaseTriggerHelper.validacionEstado(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionSubEstado(newCaseList, oldCaseMap);
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
        CaseTriggerHelper.validacionFechaEntregaDesarollo(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionAutorizacionSolucionIPN2(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionAprobacionSolucionIPRelease(newCaseList, oldCaseMap);
    }
    
    public static void afterUpdate(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
    	CaseTriggerHelper.updateIssueJira(newCaseList);   
    }
    
    
}