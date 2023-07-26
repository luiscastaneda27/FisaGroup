public without sharing class ControladorEncuesta {

     @AuraEnabled
    public static EncuestaWrapper getCaso(String recordId){
        EncuestaWrapper respuesta = new EncuestaWrapper();
        respuesta.listMotivoInsatisfaccion = new List<PickListOption>();
        Case caso = [Select CaseNumber, Status From Case Where id = :recordId];
        respuesta.numeroCaso = caso.CaseNumber;
        respuesta.idCaso = caso.Id;
        respuesta.esCerrado = caso.Status == 'Cerrado';
        respuesta.deshabilitarBoton = true;
        SObjectType objectType = Schema.getGlobalDescribe().get('Case');
        List<Schema.PicklistEntry> ple = objectType.getDescribe().fields.getMap()
            .get('FS_MotivoInsatisfaccion__c').getDescribe().getPickListValues();
        for(Schema.PicklistEntry entry : ple)  {
            PickListOption p = new PickListOption();
            p.label = entry.getLabel();
            p.value = entry.getvalue();
            respuesta.listMotivoInsatisfaccion.add(p);
        }
        return respuesta;
    }
    
    @AuraEnabled
    public static void actualizarCaso(String jsonCaso){
         EncuestaWrapper casoObj = (EncuestaWrapper) JSON.deserialize(jsonCaso, EncuestaWrapper.class);
        Case caso = new Case();
        caso.Id = casoObj.idCaso;
        caso.FS_MotivoInsatisfaccion__c = casoObj.motivoSeleccionado;
        caso.FS_ResultadoEncuesta__c = casoObj.resultadoEncuesta;
        caso.FS_ComentariosEncuesta__c = casoObj.comentarios;
        caso.FS_FechaContestacionEncuesta__c = System.now();
        caso.Status = 'Cerrado';
        update caso;
        
        FS_Encuesta__c encuesta = [Select Id, FS_MotivoInsatisfaccion__c, FS_ResultadoEncuesta__c, FS_Comentarios__c from FS_Encuesta__c Where FS_Caso__c = :caso.Id limit 1];
        encuesta.FS_MotivoInsatisfaccion__c = casoObj.motivoSeleccionado;
        encuesta.FS_ResultadoEncuesta__c = casoObj.resultadoEncuesta;
        encuesta.FS_Comentarios__c = casoObj.comentarios;
        update encuesta;
    }
    public class EncuestaWrapper{
        @AuraEnabled public String numeroCaso{get;set;}
        @AuraEnabled public String idCaso{get;set;}
        @AuraEnabled public String motivoSeleccionado{get;set;}
        @AuraEnabled public String mostrarMotivo{get;set;}
        @AuraEnabled public String comentarios{get;set;}
        @AuraEnabled public String resultadoEncuesta{get;set;}
        @AuraEnabled public Boolean esCerrado{get;set;}
        @AuraEnabled public Boolean deshabilitarBoton{get;set;}
        @AuraEnabled public List<PickListOption> listMotivoInsatisfaccion{get;set;}
    }
    public class PickListOption{
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public String value{get;set;}
    }
}