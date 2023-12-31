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
            }else if(response.caso.FS_SubEstado__c === "Respuesta aceptada" && response.caso.Status === "Pendiente de Respuesta CSAT"){
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
    }

    handleChange(event){
        const name = event.target.name;
        const value = event.detail.value;
        if(name === "aceptaResp"){
            this.data.caso.FS_AceptaRespuesta__c = value;
            if(value == "Si"){
                this.data.mostrarRechazo = false;
            }else{
                this.data.mostrarRechazo = true;
                this.data.caso.FS_MotivoRechazo__c = null;
            }
        }else if(name === "motivoRechazo"){
            this.data.caso.FS_MotivoRechazo__c = value;
        }else if(name === "comentarioResp"){
            this.data.caso.FS_ComentariosRespuesta__c = value;
        }
    }

    guardarCaso(){
        this.showSpinner = true;
        console.log("Caso: "+this.casoId)
        guardarCaso({casoJSON: JSON.stringify(this.data.caso)}).then(response => {
            this.cancelar();
            this.data.pendienteEncuestaDetalle = false;
            this.data.pendienteRespuestaDetalle = false;
            this.init();
            this.showSpinner = false;
            this.pushMessage('Exitoso', 'success', 'Datos guardados exitosamente');
        }).catch(error => {
            this.showSpinner = false;
            this.pushMessage('Error', 'error', 'Ha ocurrido un error, por favor contacte a su administrador.');
        });
    }


    popRespuesta(){
        this.data.pendienteRespuesta = true;
    }

}