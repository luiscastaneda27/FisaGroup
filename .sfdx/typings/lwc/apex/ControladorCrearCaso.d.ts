declare module "@salesforce/apex/ControladorCrearCaso.getProductosAdquiridos" {
  export default function getProductosAdquiridos(): Promise<any>;
}
declare module "@salesforce/apex/ControladorCrearCaso.getCaso" {
  export default function getCaso(param: {casoId: any}): Promise<any>;
}
declare module "@salesforce/apex/ControladorCrearCaso.guardarCaso" {
  export default function guardarCaso(param: {casoJSON: any, archivosJSON: any}): Promise<any>;
}
