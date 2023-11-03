import { LightningElement, track } from 'lwc';

import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getCaso from "@salesforce/apex/ControladorCrearCaso.getCaso";
import guardarCaso from "@salesforce/apex/ControladorCrearCaso.guardarCaso";
import urlEncuesta from '@salesforce/label/c.FS_UrlPortalEncuestas';

export default class Fs_CampoPendienteCaso extends LightningElement {

    casoId;
    showSpinner = true;
    @track data = {
        caso: {},
        listAceptaRespuesta: [],
        listMotivosRechazo: [],
        esConsulta: false,
        esSolicitud: false,
        esIncidentePuntual: false,
        esIncidenteDefinitivo: false,
        pendienteEncuesta: false,
        pendienteEncuestaDetalle: false,
        pendienteRespuesta: false,
        pendienteRespuestaDetalle: false,
        mostrarRechazo: false,
        botonDeshabilitado : true,
        pendienteHorasDetalle: false,
        pendienteHoras: false,
        pendienteInformacionDetalle: false,
        pendienteInformacion: false,
        pendienteInstalacionParcheDetalle: false,
        pendienteInstalacionParche: false,
        pendientePaseProduccionDetalle: false,
        pendientePaseProduccion: false,

    }

    connectedCallback() {
        this.getQueryParameters();
        this.init();
    }

    init(){
        this.showSpinner = true;
        getCaso({casoId: this.casoId}).then(response => {
            this.data.caso = response.caso;
            console.log(this.data.caso.FS_ComentariosRespuesta__c);
            this.data.esConsulta = response.caso.FS_NombreTipoRegistro__c == 'Consulta';
            this.data.esSolicitud = response.caso.FS_NombreTipoRegistro__c == 'Solicitud (Falla Operativa)';
            this.data.esIncidentePuntual = response.caso.FS_NombreTipoRegistro__c == 'Incidente' && response.caso.FS_TipoIncidente__c == 'Puntual';
            this.data.esIncidenteDefinitivo = response.caso.FS_NombreTipoRegistro__c == 'Consulta' && response.caso.FS_TipoIncidente__c == 'Definitivo';
            this.data.listAceptaRespuesta = response.listAceptaRespuesta;
            this.data.listMotivosRechazo = response.listMotivosRechazo;
            this.data.listMotivosRechazoParche = response.listMotivosRechazoParche;
            if(response.caso.FS_SubEstado__c === "Envío de respuesta" && response.caso.FS_AceptaRespuesta__c === undefined){
                this.data.pendienteRespuesta = true;
                this.data.pendienteRespuestaDetalle = true;
            }else if(response.caso.FS_SubEstado__c === "Respuesta aceptada" && response.caso.Status === "Pendiente de Respuesta CSAT"){
                this.data.pendienteEncuesta = true;
                this.data.pendienteEncuestaDetalle = true;
            }else if(response.caso.FS_SubEstado__c === "En Espera de Respuesta del Cliente" && response.caso.FS_InformacionCompleta__c === "Si"){
                this.data.pendienteHorasDetalle = true;
                this.data.pendienteHoras = true;
            }else if(response.caso.FS_SubEstado__c === "En Espera de Respuesta del Cliente" && response.caso.FS_InformacionCompleta__c === "No"){
                this.data.pendienteInformacionDetalle = true;
                this.data.pendienteInformacion = true;
            }else if(response.caso.FS_SubEstado__c === "Instalación de Parche"){
                this.data.pendienteInstalacionParcheDetalle = true;
                this.data.pendienteInstalacionParche = true;
            }else if(response.caso.FS_SubEstado__c === "Paso a Producción"){
                this.data.pendientePaseProduccionDetalle = true;
                this.data.pendientePaseProduccion = true;
            }else if(response.caso.FS_SubEstado__c === "Paso a Producción Confirmado" && response.caso.Status === "Pendiente de Respuesta CSAT"){
                this.data.pendienteEncuesta = true;
                this.data.pendienteEncuestaDetalle = true;
            }
            this.showSpinner = false;
        }).catch(error => {
            this.showSpinner = false;
            this.pushMessage('Error', 'error', 'Ha ocurrido un error, por favor contacte a su administrador.');
        });
    }

    getQueryParameters() {
        let urlCompleta = window.location.href;
        urlCompleta = urlCompleta.split("case/")[1];
        this.casoId = urlCompleta.split("/")[0];
        console.log("Caso Id: "+this.casoId)
        this.data.urlEncuesta = urlEncuesta + '/encuesta?recordId=' +  this.casoId;
    }

    pushMessage(title,variant,msj){
        const message = new ShowToastEvent({
            "title": title,
            "variant": variant,
            "message": msj
            });
        this.dispatchEvent(message);
    }

    cancelar(){
        this.data.pendienteEncuesta = false;
        this.data.pendienteRespuesta = false;
        this.data.pendienteHoras = false;
        this.data.pendienteInformacion = false;
        this.data.pendienteInstalacionParche = false;
        this.data.pendientePaseProduccion = false;
    }

    handleChange(event){
        const name = event.target.name;
        const value = event.detail.value.trim() != "" ? event.detail.value.trim() : null; 
        this.data.botonDeshabilitado = true;
        if(name === "aceptaResp"){
            this.data.caso.FS_AceptaRespuesta__c = value;
            this.data.mostrarRechazo = (value != "Si");
            this.data.caso.FS_MotivoRechazo__c = !this.data.mostrarRechazo ? null : this.data.caso.FS_MotivoRechazo__c; 
        }else if(name === "motivoRechazo"){
            this.data.caso.FS_MotivoRechazo__c = value;
        }else if(name === "comentarioResp"){
            this.data.caso.FS_ComentariosRespuesta__c = value;
        }else if(name === "aceptaHoras"){
            this.data.caso.FS_Acepta1erCosto__c = value;
        }else if(name === "motivoRechazoParche"){
            this.data.caso.FS_MotivoRechazo__c = value;
        }else if(name === "comentarioParch"){
            this.data.caso.FS_ComentariosRespuesta__c = value;
        }else if(name === "aceptaParche"){
            this.data.caso.FS_AceptaInstalacionParche__c = value;
            this.data.mostrarRechazo = (value != "Si");
            this.data.caso.FS_MotivoRechazo__c = !this.data.mostrarRechazo ? null : this.data.caso.FS_MotivoRechazo__c; 
        }else if(name === "aceptaPase"){
            this.data.caso.FS_AceptaPaseProducion__c = value;
        }
        this.validarBotonPendResp();
    }

    guardarCaso(){
        if(this.data.pendienteInformacion){
            this.data.pendienteInformacion = false;
            return;
        }
        this.showSpinner = true;
        console.log("Caso: "+this.casoId)
        guardarCaso({casoJSON: JSON.stringify(this.data.caso)}).then(response => {
            this.cancelar();
            this.data.pendienteEncuestaDetalle = false;
            this.data.pendienteRespuestaDetalle = false;
            this.data.pendienteHorasDetalle= false;
            this.data.pendienteInformacionDetalle = false;
            this.data.pendienteInstalacionParcheDetalle = false;
            this.data.pendientePaseProduccionDetalle = false;
            this.init();
            this.showSpinner = false;
            this.pushMessage('Exitoso', 'success', 'Datos guardados exitosamente');
        }).catch(error => {
            this.showSpinner = false;
            this.pushMessage('Error', 'error', 'Ha ocurrido un error, por favor contacte a su administrador.');
        });
    }

    validarBotonPendResp(){
        if(this.data.caso.FS_AceptaRespuesta__c === "Si" || this.data.caso.FS_AceptaInstalacionParche__c === "Si" ){
            this.data.botonDeshabilitado = false;
        }else if(this.data.caso.FS_AceptaRespuesta__c === "No" && this.data.caso.FS_MotivoRechazo__c != null && this.data.caso.FS_ComentariosRespuesta__c != null){
            this.data.botonDeshabilitado = false;
        }else if(this.data.caso.FS_AceptaInstalacionParche__c === "No" && this.data.caso.FS_MotivoRechazo__c  != null && this.data.caso.FS_ComentariosRespuesta__c != null){
            this.data.botonDeshabilitado = false;
        }else if(this.data.caso.FS_Acepta1erCosto__c != null && this.data.caso.FS_SubEstado__c === "En Espera de Respuesta del Cliente"){
            this.data.botonDeshabilitado = false;
        }
    }


    popRespuesta(){
        if(this.data.pendienteRespuestaDetalle){
            this.data.pendienteRespuesta = true;
        }else if(this.data.pendienteHorasDetalle){
            this.data.pendienteHoras = true;
        }else if(this.data.pendienteInformacionDetalle){
            this.data.pendienteInformacion = true;
        }else if(this.data.pendienteInstalacionParcheDetalle){
            this.data.pendienteInstalacionParche = true;
        }else if(this.data.pendientePaseProduccionDetalle){
            this.data.pendientePaseProduccion = true;
        }
    }

    get SiNo() {
        return [
            { label: 'Si', value: 'Si' },
            { label: 'No', value: 'No' },
        ];
    }

}