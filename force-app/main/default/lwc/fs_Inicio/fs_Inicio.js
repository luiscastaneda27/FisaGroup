import { LightningElement, track } from 'lwc';

import urlVideo1 from '@salesforce/label/c.FS_UrlVideoDestacado1';
import tituloVideo1 from '@salesforce/label/c.FS_TituloVideoDestacado1';
import urlVideo2 from '@salesforce/label/c.FS_UrlVideoDestacado2';
import tituloVideo2 from '@salesforce/label/c.FS_TituloVideoDestacado2';
import urlVideo3 from '@salesforce/label/c.FS_UrlVideoDestacado3';
import tituloVideo3 from '@salesforce/label/c.FS_TituloVideoDestacado3';
import urlVideo4 from '@salesforce/label/c.FS_UrlVideoDestacado4';
import tituloVideo4 from '@salesforce/label/c.FS_TituloVideoDestacado4';
import urlPaginaNoticias from '@salesforce/label/c.FS_UrlPaginaNoticias';

import gatListaBase from "@salesforce/apex/ControladorBaseConocimientos.gatListaBase";

export default class Fs_Inicio extends LightningElement {
   @track data = {
        urlVideo1 : urlVideo1,
        urlVideo2 : urlVideo2,
        urlVideo3 : urlVideo3,
        urlVideo4 : urlVideo4,
        tituloVideo1: tituloVideo1,
        tituloVideo2: tituloVideo2,
        tituloVideo3: tituloVideo3,
        tituloVideo4: tituloVideo4,
        urlPaginaNoticias: urlPaginaNoticias,
        listBase: [],
        listBaseShow: [],
        listProductos: [],
        //listProductosM: [],
        //listProductos: [],
        //listProductos: [],
        mostrarBaseCon: false,
        hayResultado: false,
        valorABuscar: ''
    }
    showSpinner = true;


    connectedCallback() {
        this.showSpinner = true;
        gatListaBase({}).then(response => {
            this.data.listBase = response.listBaseConocimiento;
            this.data.listProductos = response.listProducto;
            this.data.mostrarBaseCon = this.data.listBase.length > 0;
            this.data.hayResultado = this.data.mostrarBaseCon;
            for(let i=0; i < this.data.listBase.length; i++){
                if(this.data.listBaseShow.length < 3){
                    this.data.listBaseShow.push(this.data.listBase[i]);
                }
            }
            this.showSpinner = false;
        }).catch(error => {
            this.showSpinner = false;
            console.log("Error: "+JSOn.stringify(error));
        });
    }

    onchangeSearch(event){
        let value = event.target.value;
        this.data.valorABuscar = value;
        if(value.length > 2){
            this.data.listBaseShow = this.data.listBase.filter(item => item.contenido.toUpperCase().includes(value.toUpperCase() ) || item.nombre.toUpperCase().includes(value.toUpperCase()) ||
            item.producto.toUpperCase().includes(value.toUpperCase()) || item.modulo.toUpperCase().includes(value.toUpperCase()) ||
            (item.subModulo != null && item.subModulo.toUpperCase().includes(value.toUpperCase())));
        }else if(value.length === 0){
            this.data.listBaseShow = [];
            for(let i=0; i < this.data.listBase.length; i++){
                if(this.data.listBaseShow.length < 3){
                    this.data.listBaseShow.push(this.data.listBase[i]);
                }
            }
        }
        this.data.hayResultado = this.data.listBaseShow.length > 0;
    }

    onclickAllShow(){
        this.data.valorABuscar = null;
        this.data.listBaseShow = this.data.listBase;
        this.data.hayResultado = this.data.listBaseShow.length > 0;
    }
}