import { LightningElement, track, api } from 'lwc';
import getProductosAdquiridos from "@salesforce/apex/ControladorCrearCaso.getProductosAdquiridos";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
//import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils'
import guardarCaso from "@salesforce/apex/ControladorCrearCaso.guardarCaso";

export default class Fs_CrearCaso extends NavigationMixin(LightningElement) {
    @track data = {};
    showSpinner = true;

    connectedCallback() {
        this.init();
    }

    init() {
        this.showSpinner = true;
        getProductosAdquiridos({}).then(response => {
            this.data = response;
            this.data.listProductos = [];
            this.data.listModulos = [];
            this.data.listSubModulos = [];
            this.data.listArchivos = [];
            var productos = [];
            for(let j=0; j<response.listTodosProductos.length; j++){
                var p = {};
                p.label = response.listTodosProductos[j].producto;
                p.value = response.listTodosProductos[j].producto;
                let flag = true;
                for(let i=0; i<productos.length; i++){
                    if(productos[i].value === response.listTodosProductos[j].producto){
                        flag = false;
                    }
                }
                if(flag){
                    productos.push(p);
                }
           }
           this.data.listProductos = productos;
           this.showSpinner = false;
           this.habilitaBoton();
        }).catch(error => {
            this.showSpinner = false;
            console.log("Error: "+JSOn.stringify(error));
            this.pushMessage('Error', 'error', 'Ha ocurrido un error, por favor contacte a su administrador.');
        });
    }

    onchangeFilter(event){
        const name = event.target.name;
        const value = event.detail.value.trim() != "" ? event.detail.value : null;;
        if(name == "producto"){
            this.data.productoSeleccionado = value;
            this.data.subModuloSeleccionado = null;
            this.data.moduloSeleccionado = null;
            this.data.listModulos = [];
            this.data.listSubModulos = [];
            for(let j=0; j<this.data.listTodosProductos.length; j++){
                if(this.data.listTodosProductos[j].producto === value){
                    let flag = true;
                    var p = {};
                    p.label = this.data.listTodosProductos[j].modulo;
                    p.value = this.data.listTodosProductos[j].modulo;
                    for(let i=0; i<this.data.listModulos.length; i++){
                        if(this.data.listModulos[i].value === this.data.listTodosProductos[j].modulo){
                            flag = false;
                        }
                    }
                    if(flag){
                        this.data.listModulos.push(p);
                    }
                }
               
           }
        }else if(name == "modulo"){
            this.data.moduloSeleccionado = value;
            this.data.subModuloSeleccionado = null;
            this.data.listSubModulos = [];
            for(let j=0; j<this.data.listTodosProductos.length; j++){
                if(this.data.listTodosProductos[j].producto === this.data.productoSeleccionado && this.data.listTodosProductos[j].modulo == value && this.data.listTodosProductos[j].subModulo != null){
                    var p = {};
                    p.label = this.data.listTodosProductos[j].subModulo;
                    p.value = this.data.listTodosProductos[j].subModulo;
                    this.data.listSubModulos.push(p);
                }
               
           }
        }else if(name == "subModulo"){
            this.data.subModuloSeleccionado = value;
        }else if(name === "tipoRegistro"){
            this.data.registroSeleccionado = value;
            this.data.desabilitarSiguiente = false;
        }else if(name === "motivo"){
            this.data.motivoSeleccionado = value;
        }else if(name === "asunto"){
            this.data.asunto =  value;
        }else if(name === "descripcion"){
            this.data.descripcion = value;
        }
        this.habilitaBoton();
    }

    habilitaBoton(){
        this.data.habilitarBoton = true;
        let habilitarBoton = this.data.productoSeleccionado != null && this.data.moduloSeleccionado != null;
        //habilitarBoton = habilitarBoton || (this.data.subModuloSeleccionado === null && this.data.moduloSeleccionado != null && this.data.listSubModulos.length === 0);
        habilitarBoton = habilitarBoton && (this.data.registroSeleccionado != null && this.data.motivoSeleccionado != null);
        habilitarBoton = habilitarBoton && (this.data.asunto != null && this.data.descripcion != null);
        habilitarBoton = habilitarBoton && this.data.archivoSubido;
        this.data.habilitarBoton = !habilitarBoton;
    }
    
    clickCrearCaso(){
        var caso = {};
        this.showSpinner = true;
        this.data.popArchivo = false;
        this.data.habilitarBoton = true;

        caso.AccountId = this.data.cuentaId;
        caso.ContactId = this.data.contactId;
        caso.FS_Producto__c = this.data.productoSeleccionado;
        caso.FS_Modulo__c = this.data.moduloSeleccionado;
        caso.FS_SubModulo__c = this.data.subModuloSeleccionado;
        caso.Origin = "Web";
        caso.FS_DescripcionCliente__c = this.data.descripcion;
        caso.Subject = this.data.asunto;
        caso.Status = "Nuevo";
        caso.Reason = this.data.motivoSeleccionado;
        caso.RecordTypeId = this.data.registroSeleccionado;

        guardarCaso({casoJSON: JSON.stringify(caso), 
            archivosJSON:JSON.stringify(this.data.listArchivos)}).then(response => {
            this.data.casoId = response;
            this.showSpinner = false;
            this.pushMessage('Exitoso', 'success', 'Datos guardados exitosamente');
            console.log("this.data.casoId: "+this.data.casoId);
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                  objectApiName: "Case",
                  actionName: "view",
                  recordId: this.data.casoId
                }
              });
        }).catch(error => {
            this.showSpinner = false;
            this.pushMessage('Error', 'error', 'Ha ocurrido un error, por favor contacte a su administrador.');
        });


        /*const defaultValues = encodeDefaultFieldValues({
            AccountId: this.data.cuentaId,
            ContactId: this.data.contactId,
            FS_Producto__c: this.data.productoSeleccionado,
            FS_Modulo__c: this.data.moduloSeleccionado,
            FS_SubModulo__c: this.data.subModuloSeleccionado,
            Origin: "Web"
        });

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues,
                recordTypeId: this.data.registroSeleccionado
            }
        });
        this.showSpinner = false;*/
    }
    cancelar(){
        this.data.popArchivo = false;
    }
    finalizaCargaArchivo(event) {
        const uploadedFiles = event.detail.files;
        for(let i = 0; i<uploadedFiles.length; i++){
            var p = {};
            console.log(JSON.stringify(uploadedFiles[i]));
            p.label = uploadedFiles[i].name
            p.value = uploadedFiles[i].documentId;
            this.data.listArchivos.push(p);
        }
        console.log('Archivo Agregado: '+ JSON.stringify(this.data.listArchivos));
       this.data.archivoSubido = true;
       this.habilitaBoton();
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