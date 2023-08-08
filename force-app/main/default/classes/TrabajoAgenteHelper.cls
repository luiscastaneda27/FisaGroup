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
        for(Group item: [Select Id from Group Where DeveloperName In ('FS_AtencionN1Core', 'FS_AtencionN1Omnia') and Type = 'Queue']){
            colasAtencion.add(item.Id);
        }
        for(Case item: listCasos){
            Boolean esCore = item.FS_Producto__c == 'FISA System' || item.FS_Producto__c == 'FISA Credit Card' ;
            for(AgentWork aw: newAgentWork){
                if(item.id == aw.WorkItemId && listUser.contains(aw.UserId) && colasAtencion.contains(aw.OriginalQueueId) &&
                  item.FS_SubEstado__c == 'Apertura de caso'){
                      item.FS_SubEstado__c = 'Entrega 1a respuesta';
                      CaseTriggerHelper.envioCorreo(item, 'FS_AsignacionCaso', true);
                      listCasosActualizar.add(item);
                }
            }
        }
        update listCasosActualizar;
    }
}