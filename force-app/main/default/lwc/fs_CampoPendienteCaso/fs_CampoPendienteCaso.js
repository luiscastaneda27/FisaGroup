import { LightningElement, track } from 'lwc';

import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getCaso from "@salesforce/apex/ControladorCrearCaso.getCaso";
import guardarCaso from "@salesforce/apex/ControladorCrearCaso.guardarCaso";

export default class Fs_CampoPendienteCaso extends LightningElement {

    casoId;
    showSpinner = true;
    @track data = {
        caso: {},
        listAceptaRespuesta: [],
        pendienteEncuesta: false,
        pendienteEncuestaDetalle: false,
        pendienteRespuesta: false,
        pendienteRespuestaDetalle: false,

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
            console.log(response.caso.FS_SubEstado__c +" --- "+response.caso.FS_AceptaRespuesta__c)
            console.log(JSON.stringify(response.caso));
            if(response.caso.FS_SubEstado__c === "Envío de respuesta" && response.caso.FS_AceptaRespuesta__c === undefined){
                this.data.pendienteRespuesta = true;
                this.data.pendienteRespuestaDetalle = true;
            }
            this.showSpinner = false;
        }).catch(error => {
            this.showSpinner = false;
            console.log("Error: "+JSOn.stringify(error));
            this.pushMessage('Error', 'error', 'Ha ocurrido un error, por favor contacte a su administrador.');
        });
    }

    getQueryParameters() {
        let urlCompleta = window.location.href;
        urlCompleta = urlCompleta.split("case/")[1];
        this.casoId = urlCompleta.split("/")[0];
        console.log("Caso Id: "+this.casoId)
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
        }
    }

    guardarCaso(){
        this.showSpinner = true;
        console.log("Caso: "+this.casoId)
        guardarCaso({casoJSON: JSON.stringify(this.data.caso)}).then(response => {
            this.cancelar();
            this.init();
            this.showSpinner = false;
            this.pushMessage('Exitoso', 'success', 'Datos guardados exitosamente');
        }).catch(error => {
            this.showSpinner = false;
            console.log("Error: "+JSOn.stringify(error));
            this.pushMessage('Error', 'error', 'Ha ocurrido un error, por favor contacte a su administrador.');
        });
    }

}