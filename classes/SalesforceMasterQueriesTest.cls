@isTest
private class SalesforceMasterQueriesTest {
    @isTest
    static void testGetDynamicAccountList() 
    {
        // Create test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create QueryBuilder mock
        QueryFactory.QueryBuilder queryBuilderMock = new QueryFactory.QueryBuilder('Account')
            .selectFields(new List<String>{'Id', 'Name'})
            .whereClause('Id = :acc.Id').setBindMap(new Map<String, Object>{'Id' => acc.Id});

        // Test with reset flag false
        List<Account> accountList = SalesforceMasterQueries.getDynamicAccountList(queryBuilderMock, false);
        Assert.areEqual(1, accountList.size(), 'Account list should contain one record');
        Assert.areEqual('Test Account', accountList[0].Name, 'Account name should match');

        // Test with reset flag true
        accountList = SalesforceMasterQueries.getDynamicAccountList(queryBuilderMock, true);
        Assert.areEqual(1, accountList.size(), 'Account list should contain one record');
        Assert.areEqual('Test Account', accountList[0].Name, 'Account name should match');
    }
}