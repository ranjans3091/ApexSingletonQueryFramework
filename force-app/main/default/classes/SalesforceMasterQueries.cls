public class SalesforceMasterQueries {
	public static boolean accountQueryFlag = false;
    public static list<Account> accountList;
  
    /**
     * @description Gets a List of Account records dynamically using QueryFactory and QueryBuilder.
     * @param queryBuilder The QueryBuilder instance to build the dynamic SOQL query.
     * @param reset Flag to indicate whether to reset the static query flag and perform a fresh query.
     * @return List<Account> List of Account records.
     */
    public static List<Account> getDynamicAccountList(QueryFactory.QueryBuilder queryBuilder, Boolean reset) {
        if (reset || !accountQueryFlag) {
            accountList = queryBuilder.execute();
            accountQueryFlag = true;
        }  
        return accountList;
    }
}