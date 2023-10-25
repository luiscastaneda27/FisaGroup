@isTest
public class ControladorCrearCaso_Test {
    
     @TestSetup
    static void setup(){
        Account acc = DataFactory.insertAccount();
        Contact cont = DataFactory.insertContact(acc);
        FS_ProductoAdquirido__c p = DataFactory.insertProduct(acc, 'FISA System', 'Núcleo del Sistema', '');
        DataFactory.insertCase(acc, cont, p, 'FS_Consulta');
        DataFactory.insertProduct(acc, 'FISA System', 'Núcleo del Sistema', '');
    }
    
    
    @isTest
    static void ControladorCrearCaso() {
        Case caso =  [Select Id, RecordType.DeveloperName, ContactId, AccountId from Case Where RecordTypeId = :CaseTriggerHelper.CONSULTA_TIPO_REGISTRO];
        Blob fileBody = Blob.valueof('Test');
        String fileName = 'Test';
        
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.ContentDocumentId = null;
        cv.VersionData = fileBody; // Variable del archivo tipo Blob
        cv.Title = fileName; // variable nombre del archivo tipo string
        cv.PathOnClient = fileName; // variable nombre del archivo tipo string
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = caso.ContactId; // id del caso
        cdl.ShareType = 'V';
        insert cdl;
        
        List<ControladorCrearCaso.PickListOption> listArchivos = new List<ControladorCrearCaso.PickListOption>();
        ControladorCrearCaso.PickListOption archivo = new ControladorCrearCaso.PickListOption();
        archivo.label = cdl.ContentDocumentId;
        archivo.value = cdl.ContentDocumentId;
        listArchivos.add(archivo);
        
        ControladorCrearCaso.getProductosAdquiridos();
        ControladorCrearCaso.getCaso(caso.Id);
        
        caso.Id = null;
        caso.FS_TipoIncidente__c = 'Puntual';
        ControladorCrearCaso.guardarCaso(JSON.serialize(caso), JSON.serialize(listArchivos));
        
        ControladorCrearCaso.queyCasos(caso.AccountId);
       
    }

}