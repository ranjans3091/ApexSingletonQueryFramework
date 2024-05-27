public class AccountTriggerHandler implements ITriggerHandler{
    public void beforeInsert(List<sObject> newList)  {
        // Business logic for before insert
    }
    
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap)  {
        // Business logic for before update
    }
    
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        // Example of using SalesforceMasterQueries to fetch related data
        /*    QueryFactory.QueryBuilder accountQueryBuilder = QueryFactory.createQueryBuilder('Account')
            .selectFields(new List<String>{'Id', 'Name', 'Industry'})
            .whereClause('Id IN :newAccounts');
            
            List<Account> accountList = SalesforceMasterQueries.getDynamicAccountList(accountQueryBuilder, false);
             */
        
    }
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap)  {
        // Example of using SalesforceMasterQueries to fetch related data
        QueryFactory.QueryBuilder accountQueryBuilder = QueryFactory.createQueryBuilder('Account')
            .selectFields(new List<String>{'Id', 'Name', 'Industry'})
            .whereClause('Id IN :newList').setBindMap(new Map<String, Object>{'newList' => newList});
        List<Account> accountList = SalesforceMasterQueries.getDynamicAccountList(accountQueryBuilder, true);
    }
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) 
    {
         
    }
     
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) 
    {
         
    }
     
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) 
    {
         
    }
}