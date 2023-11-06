@istest
public class ControladorBaseConocimientos_Test {
    
    @TestSetup
    static void setup(){
        Account acc = DataFactory.insertAccount();
        Contact cont = DataFactory.insertContact(acc);
        DataFactory.insertUserCommunity(cont);
        FS_ProductoAdquirido__c p = DataFactory.insertProduct(acc, 'FISA System', 'Núcleo del Sistema', '');
        DataFactory.insertCase(acc, cont, p, 'FS_Consulta');
        DataFactory.insertCase(acc, cont, p, 'FS_Solicitud');
        DataFactory.insertCase(acc, cont, p, 'FS_Incidente');
        DataFactory.insertProduct(acc, 'FISA System', 'Núcleo del Sistema', '');
        DataFactory.inserBaseConocimientos(p);
    }
    
     @isTest
    static void BaseConocimientos() {
        Case caso =  [Select Id, ContactId from Case Where RecordTypeId = :CaseTriggerHelper.CONSULTA_TIPO_REGISTRO];
        User u = [Select Id from User Where Profile.Name = 'Customer Community User' and ContactId =:caso.ContactId limit 1];
        Test.startTest();
        System.runAs(u){
            ControladorBaseConocimientos.gatListaBase();
        }
        Test.stopTest();
    }

}