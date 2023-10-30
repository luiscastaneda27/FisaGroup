@isTest
public class FeedCommentTriggerHelper_Test {
    
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
    }
    
    @isTest
    static void FeedComment() {
        User u = [Select Id from User Where Profile.Name = 'Customer Community User' limit 1];
        Case caso =  [Select Id, RecordType.DeveloperName, FS_SubEstadoQueSePideInformacion__c, FS_SubEstado__c from Case Where RecordTypeId = :CaseTriggerHelper.CONSULTA_TIPO_REGISTRO];
        caso.FS_SubEstado__c = 'Apertura de caso';
        caso.FS_SubEstadoQueSePideInformacion__c = caso.FS_SubEstado__c;
        update caso;
        Test.startTest();
        caso.FS_InformacionCompleta__c = 'No';
        update caso;
        System.runAs(u){
            FeedItem fi = new FeedItem(ParentId = caso.Id, Body = 'Test', Visibility = 'AllUsers');
            insert fi;
            FeedComment df = new FeedComment (FeedItemId = fi.Id, CommentBody = fi.Body);
            insert df;
            Database.delete(df, false);
            Database.delete(fi, false);
            
        }
        Test.stopTest();
        
    }

}