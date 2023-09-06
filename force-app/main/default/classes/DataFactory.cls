public class DataFactory {
    
    public static Account insertAccount(){
        Account acc = new Account();
        acc.Name = 'Account Test';
        insert acc;
        return acc;
    }
    
    public static Contact insertContact(Account acc){
        Contact contc = new Contact();
        contc.FirstName = 'FistName Test';
        contc.LastName = 'LastName Test';
        contc.AccountId = acc.Id;
        contc.Email = 'test@test.com';
        insert contc;
        return contc;
    }
    
    public static FS_ProductoAdquirido__c insertProduct(Account acc, String prod, String mod, String subM){
        FS_ProductoAdquirido__c p = new FS_ProductoAdquirido__c();
        p.FS_Cuenta__c = acc.Id;
        p.FS_Producto__c = prod;
        p.FS_Modulo__c = mod;
        p.FS_SubModulo__c = subM;
        insert p;
        return p;
    }
    
    public static Case insertCase(Account acc, Contact cont, FS_ProductoAdquirido__c p, String tipoRegistro){
        Case caso = new Case();
        caso.AccountId = acc.Id;
        caso.ContactId = cont.Id;
        caso.FS_Producto__c = p.FS_Producto__c;
        caso.FS_Modulo__c = p.FS_Modulo__c;
        caso.FS_SubModulo__c = p.FS_SubModulo__c;
        caso.FS_DescripcionCliente__c = '<p>Test</p>';
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(tipoRegistro).getRecordTypeId();
        insert caso;
        return caso;
    }
        

}