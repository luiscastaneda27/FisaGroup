public without sharing class CaseTriggerHandler {

    public static void beforeInsert(List<Case> newCaseList){
        //CaseTriggerHelper.asignacionCola(newCaseList);
    }
    
    public static void afterInsert(List<Case> newCaseList){
        CaseTriggerHelper.validacionCorreoNuevo(newCaseList);
    }
    
    public static void beforeUpdate(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        CaseTriggerHelper.validacionEstado(newCaseList, oldCaseMap);
        CaseTriggerHelper.informacionCompleta(newCaseList, oldCaseMap);
        CaseTriggerHelper.solventarPregunta(newCaseList, oldCaseMap);
        CaseTriggerHelper.aceptaRespuesta(newCaseList, oldCaseMap);
        CaseTriggerHelper.actualizacionDescripcion(newCaseList, oldCaseMap);
        CaseTriggerHelper.horasSolicitud(newCaseList, oldCaseMap);
        CaseTriggerHelper.acepta1erCosto(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionFechaEntrega(newCaseList, oldCaseMap);
    }
    
    public static void afterUpdate(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        
    }
    
    
}