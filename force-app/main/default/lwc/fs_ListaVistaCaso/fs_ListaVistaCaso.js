import { LightningElement, track } from 'lwc';
import getCasos from "@salesforce/apex/ControladorCrearCaso.getCasos";
 
const columns = [
    { label: 'Número del Caso', fieldName: 'casoLink', type: 'url', hideDefaultActions: true , typeAttributes: { label: { fieldName: 'CaseNumber' }, target: '_self' }},
    { label: 'Nombre del Contacto', fieldName: 'FS_NombreContacto__c', type: 'text', hideDefaultActions: true },
    { label: 'Nombre de Tipo de Registro', fieldName: 'FS_NombreTipoRegistro__c', type: 'text', hideDefaultActions: true },
    { label: 'Estado', fieldName: 'Status', type: 'text', hideDefaultActions: true },
    { label: 'Prioridad', fieldName: 'Priority', type: 'text', hideDefaultActions: true },
    { label: 'Fecha de Apertura', fieldName: 'CreatedDate', type: 'text', hideDefaultActions: true },
];
 
const filterOptions = [
    { value: 'CasosAbiertos', label: 'Todos los Casos Abiertos' },
    { value: 'CasosCerrados', label: 'Todos los Casos Cerrados' },
    { value: 'CasosMostrados', label: 'Mostrados Recientemente' },
];
 
export default class Fs_ListaVistaCaso extends LightningElement {
    @track currentFilter = 'Todos los Casos Abiertos';
    @track isExpanded = false;
    @track itemsForCurrentView = [];
    @track isLoaded = false;
    @track data = {};
    filterOptions = filterOptions;
    columns = columns;
 
    connectedCallback() {
        getCasos({}).then(response => {
            console.log(JSON.stringify(response))
            this.data = response;
            this.itemsForCurrentView = response.casosAbiertos;
            this.itemsForCurrentView.forEach(item => {
                item.casoLink = '/case/' + item.Id;
            });
         })
    }

    renderedCallback() {
        this.isLoaded = true;
    }
 
    get dropdownTriggerClass() {
        if (this.isExpanded) {
            return 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click custom_list_view slds-is-open'
        } else {
            return 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click custom_list_view'
        }
    }
 
    handleFilterChangeButton(event) {
        this.isLoaded = false;
        let filter = event.target.dataset.filter;
        console.log(filter);
        this.isExpanded = !this.isExpanded;
        if(filter === 'CasosCerrados'){
            this.itemsForCurrentView = this.data.casosCerrados;
            this.currentFilter = 'Todos los Casos Cerrado';
        }else if(filter === 'CasosMostrados'){
            this.itemsForCurrentView = this.data.casosMostrados;
            this.currentFilter = 'Mostrados Recientemente';
        }else if(filter === 'CasosAbiertos'){
            this.itemsForCurrentView = this.data.casosAbiertos;
            this.currentFilter = 'Todos los Casos Abiertos';
        }
        this.itemsForCurrentView.forEach(item => {
            item.casoLink = '/case/' + item.Id;
        });
    }
 
    handleClickExtend() {
        this.isExpanded = !this.isExpanded;
    }
}