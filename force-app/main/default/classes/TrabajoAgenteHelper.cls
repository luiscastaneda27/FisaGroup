public class TrabajoAgenteHelper {

    public static void verificacionCaso(List<AgentWork> newAgentWork){
        List<String> recordIds = new List<String>();
        List<String> listUserId = new  List<String>();
        List<String> listUser = new  List<String>();
        List<Case> listCasosActualizar = new List<Case>();
        
        for(AgentWork item: newAgentWork){
            recordIds.add(item.WorkItemId);
            listUserId.add(item.UserId);
        }
        String query = 'Select ';
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap();
        for(Schema.SObjectField sfield : fieldMap.Values()){
            schema.describefieldresult dfield = sfield.getDescribe();
            query += dfield.getname() + ',';
        }
        query = query.substring(0, query.length() - 1) + ' from Case Where Id in :recordIds';
        List<Case> listCasos = DataBase.query(query);
        for(User item :[Select Id from User Where Id in :listUserId]){
            listUser.add(item.Id);
        }
        List<String> colasAtencion = new List<String>();
        List<String> colasAtencionN2 = new List<String>();
        for(Group item: [Select Id,Developername from Group Where DeveloperName In ('FS_AtencionN1Core', 'FS_AtencionN1Omnia','FS_AtencionN2Core', 'FS_AtencionN2Omnia') and Type = 'Queue']){
            if(item.DeveloperName == 'FS_AtencionN1Core' || item.DeveloperName == 'FS_AtencionN1Omnia'){
                colasAtencion.add(item.Id);
            }else if(item.DeveloperName == 'FS_AtencionN2Core' || item.DeveloperName == 'FS_AtencionN2Omnia'){
                colasAtencionN2.add(item.Id);
            }
        }
        for(Case item: listCasos){
            Boolean esCore = item.FS_Producto__c == 'FISA System' || item.FS_Producto__c == 'FISA Credit Card' ;
            for(AgentWork aw: newAgentWork){
                if(item.Id == aw.WorkItemId && listUser.contains(aw.UserId) && colasAtencion.contains(aw.OriginalQueueId) &&
                  item.FS_SubEstado__c == 'Apertura de caso'){
                      item.FS_SubEstado__c = 'Entrega 1a respuesta';
                      CaseTriggerHelper.envioCorreo(item, 'FS_AsignacionCaso', true);
                      listCasosActualizar.add(item);
                  }else if(item.Id == aw.WorkItemId && listUser.contains(aw.UserId) && colasAtencionN2.contains(aw.OriginalQueueId) &&
                           item.FS_SubEstado__c == 'Escalado a N2' && item.FS_NombreTipoRegistro__c == 'Incidente'){
                               item.FS_SubEstado__c = 'Revisión Documentación N2';
                               listCasosActualizar.add(item);
                  }
            }
        }
        update listCasosActualizar;
    }
}