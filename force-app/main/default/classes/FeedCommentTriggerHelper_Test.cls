@isTest
public class FeedCommentTriggerHelper_Test {
    
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
    static void FeedComment() {
        User u = [Select Id from User Where Profile.Name = 'Customer Community User' limit 1];
        Case caso =  [Select Id, RecordType.DeveloperName from Case Where RecordTypeId = :CaseTriggerHelper.CONSULTA_TIPO_REGISTRO];
        Test.startTest();
        caso.FS_InformacionCompleta__c = 'No';
        update caso;
        System.runAs(u){
            FeedItem fi = new FeedItem(ParentId = caso.Id, Body = 'Test', Visibility = 'AllUsers');
            insert fi;
            insert new FeedComment (FeedItemId = fi.Id, CommentBody = fi.Body);
        }
        Test.stopTest();
        
    }

}