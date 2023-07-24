public without sharing class ControladorCrearCaso {

    @AuraEnabled
    public static ContactoWrapper getProductosAdquiridos(){
        ContactoWrapper respuesta = new ContactoWrapper();
        user usuario = [Select ContactId, Contact.AccountId from User  Where Id = :userInfo.getUserId()];
        respuesta.contactId = usuario.ContactId;
        respuesta.cuentaId = usuario.Contact.AccountId;
        respuesta.listTodosProductos = new List<Producto>();
        respuesta.listTiporegistro = new List<PickListOption>();
        for(FS_ProductoAdquirido__c item: [Select FS_Producto__c, FS_Modulo__c, FS_SubModulo__c from FS_ProductoAdquirido__c where FS_Cuenta__c =:respuesta.cuentaId]){
            Producto p = new Producto();
            p.producto = item.FS_Producto__c;
            p.modulo = item.FS_Modulo__c;
            p.subModulo = item.FS_SubModulo__c;
            respuesta.listTodosProductos.add(p);
        }
        for(RecordType item : [Select Name, Id from RecordType Where SObjectType = 'Case' and IsActive = true Order by Name asc]){
            PickListOption p = new PickListOption();
            p.value = item.Id;
            p.label = item.Name;
            respuesta.listTiporegistro.add(p);
        }
        return respuesta;
    }
    
    @AuraEnabled
    public static CasoWrapper getCaso(String casoId){
        CasoWrapper respuesta = new CasoWrapper();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap();
        String query = 'Select ';
        for(Schema.SObjectField sfield : fieldMap.Values()){
            schema.describefieldresult dfield = sfield.getDescribe();
            query += dfield.getname() + ',';
        }
        query =  query.substring(0, query.length() - 1) + ' From Case Where Id = :casoId';
        respuesta.caso = DataBase.query(query);
        respuesta.listAceptaRespuesta = getPickListOption('Case', 'FS_AceptaRespuesta__c');
        return respuesta;
    }
    
    @AuraEnabled
    public static void guardarCaso(String casoJSON){
        Case caso = (Case) JSON.deserialize(casoJSON, Case.class);
        update caso;
    }
    
    public static List<PickListOption> getPickListOption(String objeto, String campo){
       List<PickListOption> listOptions = new List<PickListOption>();
        SObjectType objectType = Schema.getGlobalDescribe().get(objeto);
        List<Schema.PicklistEntry> ple = objectType.getDescribe().fields.getMap()
            .get(campo).getDescribe().getPickListValues();
        for(Schema.PicklistEntry entry : ple)  {
            PickListOption p = new PickListOption();
            p.label = entry.getLabel();
            p.value = entry.getvalue();
            listOptions.add(p);
        }
        return listOptions;
    }
    
    public class ContactoWrapper{
        @AuraEnabled public String cuentaId {get;set;}
        @AuraEnabled public String contactId {get;set;}
        @AuraEnabled public List<Producto> listTodosProductos {get;set;}
        @AuraEnabled public List<PickListOption> listTiporegistro {get;set;}
    }
    
    public class CasoWrapper{
        @AuraEnabled public Case caso {get;set;}
        @AuraEnabled public List<PickListOption> listAceptaRespuesta {get;set;}
    }
    
    public class Producto{
        @AuraEnabled public String producto{get;set;}
        @AuraEnabled public String modulo{get;set;}
        @AuraEnabled public String subModulo{get;set;}
    }
    
    public class PickListOption{
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public String value{get;set;}
    }
}