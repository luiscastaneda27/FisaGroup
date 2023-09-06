@isTest
public class TrabajoAgenteHelper_Test {
    
    @TestSetup
    static void setup(){
        Account acc = DataFactory.insertAccount();
        Contact cont = DataFactory.insertContact(acc);
        FS_ProductoAdquirido__c p = DataFactory.insertProduct(acc, 'FISA System', 'CLIENTES', 'Clientes');
        DataFactory.insertCase(acc, cont, p, 'FS_Consulta');
        DataFactory.insertCase(acc, cont, p, 'FS_Solicitud');
        DataFactory.insertCase(acc, cont, p, 'FS_Incidente');
        DataFactory.insertProduct(acc, 'FISA System', 'CLIENTES', 'Facturas');
    }
    
    @isTest
    static void TrabajoAgenteHelper() {
        ServiceChannel canal = [Select Id,DeveloperName from ServiceChannel where DeveloperName = 'FS_ServicioCliente'];
        Case caso =  [Select Id, RecordType.DeveloperName from Case Where RecordTypeId = :CaseTriggerHelper.CONSULTA_TIPO_REGISTRO];
        caso.OwnerId = CaseTriggerHelper.mapColas.get(CaseTriggerHelper.COLA_ATENCION_N1_CORE);
        update caso;
        //ServicePresenceStatus sta = [Select Id from ServicePresenceStatus where DeveloperName = 'Available_Case' limit 1];
        //insert new UserServicePresence(UserId =  UserInfo.getUserId(), ServicePresenceStatusId = sta.Id);
        insert new AgentWork(ServiceChannelId = canal.Id, WorkItemId = caso.Id, UserId = UserInfo.getUserId());
    }

}