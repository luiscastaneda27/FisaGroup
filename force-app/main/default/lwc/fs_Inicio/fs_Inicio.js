import { LightningElement } from 'lwc';

import urlVideo1 from '@salesforce/label/c.FS_UrlVideoDestacado1';
import tituloVideo1 from '@salesforce/label/c.FS_TituloVideoDestacado1';
import urlVideo2 from '@salesforce/label/c.FS_UrlVideoDestacado2';
import tituloVideo2 from '@salesforce/label/c.FS_TituloVideoDestacado2';
import urlVideo3 from '@salesforce/label/c.FS_UrlVideoDestacado3';
import tituloVideo3 from '@salesforce/label/c.FS_TituloVideoDestacado3';
import urlVideo4 from '@salesforce/label/c.FS_UrlVideoDestacado4';
import tituloVideo4 from '@salesforce/label/c.FS_TituloVideoDestacado4';
import urlPaginaNoticias from '@salesforce/label/c.FS_UrlPaginaNoticias';

export default class Fs_Inicio extends LightningElement {
    data = {
        urlVideo1 : urlVideo1,
        urlVideo2 : urlVideo2,
        urlVideo3 : urlVideo3,
        urlVideo4 : urlVideo4,
        tituloVideo1: tituloVideo1,
        tituloVideo2: tituloVideo2,
        tituloVideo3: tituloVideo3,
        tituloVideo4: tituloVideo4,
        urlPaginaNoticias: urlPaginaNoticias
    }
}