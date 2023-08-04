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
        pendienteEncuesta: false,
        pendienteEncuestaDetalle: false,
        pendienteRespuesta: false,
        pendienteRespuestaDetalle: false,
        mostrarRechazo: false,
        botonDeshabilitado : true,
        pendienteHorasDetalle: false,
        pendienteHoras: false,

    }

    connectedCallback() {
        this.getQueryParameters();
        this.init();
    }

    init(){
        this.showSpinner = true;
        getCaso({casoId: this.casoId}).then(response => {
            this.data.caso = response.caso;
            this.data.listAceptaRespuesta = response.listAceptaRespuesta;
            this.data.listMotivosRechazo = response.listMotivosRechazo;
            if(response.caso.FS_SubEstado__c === "Envío de respuesta" && response.caso.FS_AceptaRespuesta__c === undefined){
                this.data.pendienteRespuesta = true;
                this.data.pendienteRespuestaDetalle = true;
            }else if(response.caso.FS_SubEstado__c === "Respuesta aceptada" && response.caso.Status === "Validación de Respuesta (Cliente)"){
                this.data.pendienteEncuesta = true;
                this.data.pendienteEncuestaDetalle = true;
            }else if(response.caso.FS_SubEstado__c === "En Espera de Respuesta del Cliente" && response.caso.Status === "En Análisis"){
                this.data.pendienteHorasDetalle = true;
                this.data.pendienteHoras = true;
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
    }

    handleChange(event){
        const name = event.target.name;
        const value = event.detail.value.trim() != "" ? event.detail.value.trim() : null; 
        this.data.botonDeshabilitado = true;
        if(name === "aceptaResp"){
            this.data.caso.FS_AceptaRespuesta__c = value;
            if(value == "Si"){
                this.data.mostrarRechazo = false;
                this.data.caso.FS_MotivoRechazo__c = null;
            }else{
                this.data.mostrarRechazo = true;
            }
        }else if(name === "motivoRechazo"){
            this.data.caso.FS_MotivoRechazo__c = value;
        }else if(name === "comentarioResp"){
            this.data.caso.FS_ComentariosRespuesta__c = value;
        }else if(name === "aceptaHoras"){
            this.data.caso.FS_Acepta1erCosto__c = value;
        }
        this.validarBotonPendResp();
    }

    guardarCaso(){
        this.showSpinner = true;
        console.log("Caso: "+this.casoId)
        guardarCaso({casoJSON: JSON.stringify(this.data.caso)}).then(response => {
            this.cancelar();
            this.data.pendienteEncuestaDetalle = false;
            this.data.pendienteRespuestaDetalle = false;
            this.data.pendienteHorasDetalle= false;
            this.init();
            this.showSpinner = false;
            this.pushMessage('Exitoso', 'success', 'Datos guardados exitosamente');
        }).catch(error => {
            this.showSpinner = false;
            this.pushMessage('Error', 'error', 'Ha ocurrido un error, por favor contacte a su administrador.');
        });
    }

    validarBotonPendResp(){
        if(this.data.caso.FS_AceptaRespuesta__c === "Si"){
            this.data.botonDeshabilitado = false;
        }else if(this.data.caso.FS_AceptaRespuesta__c === "No" && this.data.caso.FS_MotivoRechazo__c  != null && this.data.caso.FS_ComentariosRespuesta__c != null){
            this.data.botonDeshabilitado = false;
        }else if(this.data.caso.FS_Acepta1erCosto__c != null){
            this.data.botonDeshabilitado = false;
        }
    }


    popRespuesta(){
        if(this.data.pendienteRespuestaDetalle){
            this.data.pendienteRespuesta = true;
        }else if(this.data.pendienteHorasDetalle){
            this.data.pendienteHoras = true;
        }
    }

    get SiNo() {
        return [
            { label: 'Si', value: 'Si' },
            { label: 'No', value: 'No' },
        ];
    }

}