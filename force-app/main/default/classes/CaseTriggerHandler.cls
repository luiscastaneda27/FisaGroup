public without sharing class CaseTriggerHandler {

    public static void beforeInsert(List<Case> newCaseList){
    }
    
    public static void afterInsert(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        CaseTriggerHelper.validacionCorreoNuevo(newCaseList);
         CaseTriggerHelper.historialCaso(newCaseList);
    }
    
    public static void beforeUpdate(List<Case> newCaseList, Map<Id, Case> oldCaseMap){
        CaseTriggerHelper.validacionEstado(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionSubEstado(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionCamposAporbacion(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionProducto(newCaseList, oldCaseMap);
        CaseTriggerHelper.informacionCompleta(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionTipo(newCaseList, oldCaseMap);
        CaseTriggerHelper.solventarPregunta(newCaseList, oldCaseMap);
        CaseTriggerHelper.aceptaRespuesta(newCaseList, oldCaseMap);
        CaseTriggerHelper.actualizacionDescripcion(newCaseList, oldCaseMap);
        CaseTriggerHelper.horasSolicitud(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionAprobacionSolucion(newCaseList, oldCaseMap);
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
        CaseTriggerHelper.validacionAprobacionSolucionDefinitivaN2(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionAprobacionSolucionDefinitivaRelease(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionURLPlanPruebas(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionAprobacionPlanPruebas(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionURLAmbientePruebas(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionAprobacionInstalacionRelease(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionURLEvidenciaPruebas(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionAprobacionCertificacionQA(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionUrlEntregaParche(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionAceptaInstalacionParche(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionAceptaPaseProduccion(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionIngProducto(newCaseList, oldCaseMap);
        CaseTriggerHelper.asignarAprobadorActual(newCaseList, oldCaseMap);
        CaseTriggerHelper.llenarOrigen(newCaseList, oldCaseMap);
        CaseTriggerHelper.mapeoFechaEstado(newCaseList, oldCaseMap);
        
    }
    
    public static void afterUpdate(List<Case> newCaseList, Map<Id, Case> oldCaseMap) {
        CaseTriggerHelper.historialCaso(newCaseList, oldCaseMap);
        CaseTriggerHelper.upsertCaseJira(newCaseList, oldCaseMap);
        CaseTriggerHelper.validacionChatter(newCaseList, oldCaseMap);
    }
    
    
}