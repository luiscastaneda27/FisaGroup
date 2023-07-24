import { LightningElement, track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import logoFisa from '@salesforce/resourceUrl/FS_FisaLogo';
import logoLike from '@salesforce/resourceUrl/FS_LogoLike';
import logoMuyInsatisfecho from '@salesforce/resourceUrl/FS_LogoMuyInsatisfecho';
import logoInsatisfecho from '@salesforce/resourceUrl/FS_LogoInsatisfecho';
import logoNeutral from '@salesforce/resourceUrl/FS_LogoNeutral';
import logoSatisfecho from '@salesforce/resourceUrl/FS_LogoSatisfecho';
import logoMuySatisfecho from '@salesforce/resourceUrl/FS_LogoMuySatisfecho';
import gatCaso from "@salesforce/apex/ControladorEncuesta.getCaso";
import actualizarCaso from "@salesforce/apex/ControladorEncuesta.actualizarCaso";

export default class Fs_Encuesta extends LightningElement {

    @track data = {
        logoFisa: logoFisa,
        logoMuyInsatisfecho: logoMuyInsatisfecho,
        logoInsatisfecho: logoInsatisfecho,
        logoNeutral: logoNeutral,
        logoSatisfecho: logoSatisfecho,
        logoMuySatisfecho: logoMuySatisfecho,
        logoLike: logoLike,
        casoObjeto: {},
        parametros: {}
    }
    showSpinner = true;

    connectedCallback() {
        this.data.parametros = this.getQueryParameters();
        console.log(this.data.parametros.recordId);
        this.getColorBlanco();
        this.init();
    }

    init() {
        this.showSpinner = true;
        gatCaso({recordId: this.data.parametros.recordId}).then(response => {
            this.data.casoObjeto = response;
            this.showSpinner = false;
        }).catch(error => {
            this.showSpinner = false;
            console.log("Error: "+JSOn.stringify(error));
            this.pushMessage('Error', 'error', 'Ha ocurrido un error, por favor contacte a su administrador.');
        });
    }

    onclickImg(event){
        this.getColorBlanco();
        const name = event.target.name;
        this.data.casoObjeto.mostrarMotivo = false;
        this.data.casoObjeto.deshabilitarBoton = true;
        let color = "background-color:#57b888;";
        if(name === "logoMuyInsatisfecho"){
            this.data.styleLogoMuyInsatisfecho = color;
            this.data.casoObjeto.mostrarMotivo = true;
            this.data.casoObjeto.resultadoEncuesta = "Muy Insatisfecho";
        }else if(name === "logoInsatisfecho"){
            this.data.styleLogoInsatisfecho= color;
            this.data.casoObjeto.mostrarMotivo = true;
            this.data.casoObjeto.resultadoEncuesta = "Insatisfecho";
        }else if(name === "logoNeutral"){
            this.data.styleLogoNeutral= color;
            this.data.casoObjeto.deshabilitarBoton = false;
            this.data.casoObjeto.resultadoEncuesta = "Neutral";
        }else if(name === "logoSatisfecho"){
            this.data.styleLogoSatisfecho= color;
            this.data.casoObjeto.deshabilitarBoton = false;
            this.data.casoObjeto.resultadoEncuesta = "Satisfecho";
        }else if(name === "logoMuySatisfecho"){
            this.data.styleLogoMuySatisfecho = color;
            this.data.casoObjeto.deshabilitarBoton = false;
            this.data.casoObjeto.resultadoEncuesta = "Muy Satisfecho";
        }
    }

    getColorBlanco(){
        let style = "background-color: ffffff; ";
        this.data.styleLogoMuyInsatisfecho = style;
        this.data.styleLogoInsatisfecho = style;
        this.data.styleLogoNeutral= style;
        this.data.styleLogoSatisfecho = style;
        this.data.styleLogoMuySatisfecho = style;
    }

    onchangeMotivo(event){
        const name = event.target.name;
        if(name === "motivo"){
            this.data.casoObjeto.motivoSeleccionado = event.detail.value;
            this.data.casoObjeto.deshabilitarBoton = false;
        }else if(name === "comentarios"){
            this.data.casoObjeto.comentarios = event.detail.value;
        }
    }

    enviarEncuesta(){
        this.showSpinner = true;
        actualizarCaso({jsonCaso: JSON.stringify(this.data.casoObjeto)}).then(response => {
            this.pushMessage('Exitoso', 'success', 'Encuesta creada exitosamente.');
            this.showSpinner = false;
            this.data.casoObjeto.esCerrado = true;
        }).catch(error => {
            this.showSpinner = false;
            this.pushMessage('Error', 'error', 'Ha ocurrido un error, por favor contacte a su administrador.');
        });
    }

    getQueryParameters() {
        var params = {};
        var search = location.search.substring(1);
        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        }
        return params;
    }

    pushMessage(title,variant,msj){
        const message = new ShowToastEvent({
            "title": title,
            "variant": variant,
            "message": msj
            });
        this.dispatchEvent(message);
    }
}