## Dynamic Apex Singleton Query Framework

### Overview

This framework provides a robust solution for managing SOQL queries in Apex code, addressing common challenges faced in Salesforce development, such as avoiding SOQL 101 errors, optimizing query performance, and ensuring code scalability. It comprises three key components: QueryFactory, QueryBuilder, and SalesforceMasterQueries, along with an example implementation with AccountTrigger and its handler.

### Features

- **QueryFactory**: A versatile class for building dynamic SOQL queries using a fluent interface. It provides methods to construct queries based on field sets, field API names, and custom conditions.

- **QueryBuilder**: An inner class of QueryFactory that facilitates the construction of SOQL queries. It supports chaining methods to add fields, conditions, group by clauses, and order by clauses. Additionally, QueryBuilder enables the use of With User Mode and queryWithBinds for enhanced query execution.

- **SalesforceMasterQueries**: A singleton class designed to manage and execute SOQL queries efficiently. It ensures that queries are executed only once per transaction, even in bulk processing scenarios, reducing the risk of hitting SOQL limits. SalesforceMasterQueries provides options to reset the query flags and perform fresh queries, catering to dynamic data requirements.

### Benefits

1. **SOQL Optimization**: By utilizing QueryFactory and QueryBuilder, developers can construct optimized SOQL queries dynamically, reducing code redundancy and improving performance.

2. **Singleton Pattern**: SalesforceMasterQueries implements a singleton pattern to ensure that queries are executed only once per transaction, minimizing the risk of hitting SOQL limits and optimizing resource usage.

3. **Scalability and Modularity**: The framework is designed to be scalable and modular, allowing developers to write one query per object in SalesforceMasterQueries. This approach promotes code reusability and maintainability across different projects.

4. **Dynamic Query Construction**: QueryFactory and QueryBuilder enable dynamic query construction, allowing developers to build queries based on runtime conditions, field sets, and other dynamic criteria.

5. **Bulk Processing Support**: The framework is optimized for bulk processing scenarios, ensuring that queries are executed efficiently even when processing large volumes of records.

### Technical Details

- **QueryFactory**: A versatile class for building dynamic SOQL queries using a fluent interface. It provides methods to construct queries based on field sets, field API names, and custom conditions.
- **QueryBuilder**: An inner class of QueryFactory that facilitates the construction of SOQL queries. It supports chaining methods to add fields, conditions, group by clauses, and order by clauses. Additionally, QueryBuilder enables the use of With User Mode and queryWithBinds for enhanced query execution.
- **SalesforceMasterQueries**: A singleton class designed to manage and execute SOQL queries efficiently. It ensures that queries are executed only once per transaction, even in bulk processing scenarios, reducing the risk of hitting SOQL limits. SalesforceMasterQueries provides options to reset the query flags and perform fresh queries, catering to dynamic data requirements.

### Best Practices

- **With User Mode**: Salesforce recommends enforcing Field Level Security (FLS) using WITH USER_MODE rather than WITH SECURITY-ENFORCED for additional advantages. WITH USER_MODE accounts for polymorphic fields like Owner and Task.whatId, processes all clauses in the SOQL SELECT statement including the WHERE clause, and finds all FLS errors in the SOQL query.

### Importance of Reset Flag

The reset flag is a critical aspect of the SalesforceMasterQueries class. It determines whether the static query flag should be reset and a fresh query should be performed. 

- **When reset is true**: If more than 200 records are processed in one transaction, Salesforce will not run the same query for the next batch of records. Instead, it will use the static list which is holding the queried values. This approach avoids redundant queries and optimizes performance.
  
- **When reset is false**: For the next set of records after the first 200 records in a single transaction, Salesforce will reattempt the query for the newer set of records in the same transaction. This is useful when the data changes dynamically between batches and fresh queries are needed to fetch the most up-to-date records.

Note: The reset method is not intended for unit testing. It is designed to indicate whether to reset the static query flag and perform a fresh query based on the dynamic data requirements.

### Example Usage

```apex
// Construct a dynamic query using QueryFactory
Map<String, Object> bindMap = new Map<String, Object>{'AnnualRevenue' => 50};
QueryFactory.QueryBuilder queryBuilder = QueryFactory.createQueryBuilder('Account')
    .selectFieldsFromFieldSet('AccountFieldSet')
    .whereClause('AnnualRevenue > :threshold')
    .withUserMode()
    .setBindMap(bindMap);

// Execute the query using SalesforceMasterQueries
List<Account> accountList = SalesforceMasterQueries.getDynamicAccountList(queryBuilder, false);
```

### Example Scenario

Suppose we are inserting 5000 records synchronously in an Apex trigger. Salesforce chunks the records into batches of 200, resulting in 25 executions of the trigger. Each trigger execution includes multiple queries. By leveraging SalesforceMasterQueries, the queries are executed only once per transaction, ensuring efficient resource utilization and preventing SOQL 101 errors.

### Conclusion

The Dynamic Apex Singleton Query Framework empowers Salesforce developers to write scalable, optimized, and efficient code when dealing with SOQL queries. By leveraging QueryFactory, QueryBuilder, and SalesforceMasterQueries, developers can streamline query construction, improve performance, and ensure code scalability in various Salesforce projects.

### Author

Ranjan Singh
