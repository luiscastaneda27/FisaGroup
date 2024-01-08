global class MilestoneCalculator implements Support.MilestoneTriggerTimeCalculator {
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
        integer timerSLA;
        String recordTypeName;
        String subEstado;
        String accId;
        set<String> milestoneNames = new set <String>();
        List<FS_ConfiguracionSLA__c> slaLs = new List<FS_ConfiguracionSLA__c>();
        list<case> caseList = new list<case>();
        //recuperamos el caso del que se busca SLA. 
        caseList = [SELECT Priority, RecordType.Name, FS_SubEstado__c, AccountId FROM Case WHERE Id=:caseId];
        Case c = [SELECT Priority, RecordType.Name, FS_SubEstado__c, AccountId FROM Case WHERE Id=:caseId];
        
        for(Case lstCase : caseList){
            recordTypeName = lstCase.RecordType.Name;
            accId = lstCase.AccountId;
            subEstado = lstCase.FS_SubEstado__c;
        }
        //buscamos la configuracion de sla dependiendo del tipo de registro, nombre de cuenta y sub estado.
        slaLs = [select id, FS_NombreDeCuenta__c, FS_NombreTipoRegistro__c, FS_SLA__c, FS_SubEstado__c, FS_EsCliente__c, 
                 FS_Activo__c from FS_ConfiguracionSLA__c where FS_Activo__c = true AND FS_NombreTipoRegistro__c =: recordTypeName
                 AND FS_NombreDeCuenta__c =: accId AND FS_SubEstado__c INCLUDES(:subEstado) limit 1];
        for(FS_ConfiguracionSLA__c lstSLA: slaLs){
            //asignamos el SLA correspondiente convirtiendo el valor de horas a minutos.
            timerSLA = integer.ValueOf(lstSLA.FS_SLA__c) * 60;
        }
        return timerSLA;
    }
}