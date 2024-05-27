/**
 * @class QueryFactory
 * @description The QueryFactory class provides a fluent interface for building and executing dynamic SOQL queries.
 *              This class includes the QueryBuilder inner class, which allows the chaining of methods to construct complex queries.
 * @author Ranjan Singh
 */
public with sharing class QueryFactory {

    /**
     * @description Creates a new instance of QueryBuilder for the specified sObject type.
     * @param sObjectType The API name of the sObject type to query.
     * @return A new instance of QueryBuilder.
     */
    public static QueryBuilder createQueryBuilder(String sObjectType) {
        return new QueryBuilder(sObjectType);
    }

    /**
     * @class QueryBuilder
     * @description The QueryBuilder class provides methods for constructing and executing dynamic SOQL queries.
     *              It supports adding fields, WHERE clauses, GROUP BY clauses, ORDER BY clauses, limits, and security enforcement.
     * @Author Ranjan Singh
     */
    public with sharing class QueryBuilder {
        private String fieldsToSelect = '';
        private String sObjectType;
        private String queryString = '';
        private String whereClause = '';
        private String groupByClause = '';
        private String orderByClause = '';
        private Boolean withSecurityEnforced = false;
        private Boolean withUserMode = false;
        private Integer limitValue;
        private Schema.DescribeSObjectResult sObjectDescribe; 
        private Map<String,Object> bindMap;

        /**
         * @description Initializes a new instance of the QueryBuilder class for the specified sObject type.
         * @param sObjectType The API name of the sObject type to query.
         */
        public QueryBuilder(String sObjectType) {
            this.sObjectType = sObjectType;
            this.sObjectDescribe = Schema.getGlobalDescribe().get(sObjectType).getDescribe();
            bindMap = new Map<String,Object>();
        }

        /**
         * @description Adds fields to select in the query.
         * @param fields A list of field API names to select.
         * @return The current instance of QueryBuilder for method chaining.
         */
        public QueryBuilder selectFields(List<String> fields) {
            fieldsToSelect = String.isNotBlank(fieldsToSelect) ? fieldsToSelect += ', ' : '' ;
            fieldsToSelect += String.join(fields, ', ');
            return this;
        }

        /**
         * @description Adds fields to select in the query from a comma-separated string.
         * @param fields A comma-separated string of field API names to select.
         * @return The current instance of QueryBuilder for method chaining.
         */
        public QueryBuilder addFieldsFromString(String fields) {
            fieldsToSelect = String.isNotBlank(fieldsToSelect) ? fieldsToSelect += ', ' : '' ;
            fieldsToSelect += fields;
            return this;
        }

        /**
         * @description Adds fields to select in the query from a field set.
         * @param fieldSetName The API name of the field set.
         * @return The current instance of QueryBuilder for method chaining.
         */
        public QueryBuilder selectFieldsFromFieldSet(String fieldSetName) {
            Schema.FieldSet fieldSet = sObjectDescribe.fieldSets.getMap().get(fieldSetName);
            List<String> fieldSetFields = new List<String>();
            for (Schema.FieldSetMember f : fieldSet.getFields()) {
                fieldSetFields.add(f.getFieldPath());
            }
            return selectFields(fieldSetFields);
        }

        /**
         * @description Adds all fields of the sObject type to select in the query.
         * @return The current instance of QueryBuilder for method chaining.
         */
        public QueryBuilder selectAllFields() {
            List<String> allFields = new List<String>();
            for (Schema.SObjectField field : sObjectDescribe.fields.getMap().values()) {
                allFields.add(field.getDescribe().getName());
            }
            return selectFields(allFields);
        }

        /**
         * @description Enforces field-level security for the query.
         * @return The current instance of QueryBuilder for method chaining.
         */
        public QueryBuilder withSecurityEnforced() {
            this.withSecurityEnforced = true;
            return this;
        }
        /**
         * @description Enforces UserMode for the query.
         * @return The current instance of QueryBuilder for method chaining.
         */
        public QueryBuilder withUserMode() {
            this.withUserMode = true;
            return this;
        }

        /**
         * @description Adds a GROUP BY clause to the query.
         * @param fields A comma-separated string of field API names to group by.
         * @return The current instance of QueryBuilder for method chaining.
         */
        public QueryBuilder groupBy(String fields) {
            this.groupByClause = String.isNotBlank(fields) ? ' GROUP BY ' + fields : '' ;
            return this;
        }

        /**
         * @description Adds a WHERE clause to the query.
         * @param condition The condition for the WHERE clause.
         * @return The current instance of QueryBuilder for method chaining.
         */
        public QueryBuilder whereClause(String condition) {
            this.whereClause = ' WHERE ' + condition;
            return this;
        }

        /**
         * @description Adds an ORDER BY clause to the query.
         * @param fields A comma-separated string of field API names to order by.
         * @return The current instance of QueryBuilder for method chaining.
         */
        public QueryBuilder orderBy(String fields) {
            this.orderByClause = ' ORDER BY ' + fields;
            return this;
        }
        
        /**
         * @description Set the bindMap for queryWithBinds operation. 
         * @param bindMap This map contains all the bind key value pair. key will be the variable name and value of map will be the value against the key
         * @return The current instance of QueryBuilder for method chaining.
         */
        public QueryBuilder setBindMap(Map<String,Object> bindMap) {
            this.bindMap = bindMap;
            return this;
        }

        /**
         * @description Adds a LIMIT clause to the query.
         * @param limitVal The maximum number of records to return.
         * @return The current instance of QueryBuilder for method chaining.
         */
        public QueryBuilder getlimit(Integer limitVal) {
            this.limitValue = limitVal;
            return this;
        }

        /**
         * @description Builds the final SOQL query string based on the specified clauses.
         * @return The complete SOQL query string.
         */
        private String buildQueryString() {
            queryString = 'SELECT ' + fieldsToSelect + ' FROM ' + sObjectType;
            if (String.isNotBlank(whereClause)) {
                queryString += whereClause;
            }
            if(withUserMode && queryString.containsNone(':')) //Salesforce recommends that you enforce Field Level Security (FLS) by using WITH USER_MODE rather than WITH SECURITY-ENFORCED
            {
               queryString += ' WITH USER_MODE '; 
            }else if (withSecurityEnforced && !withUserMode) {
                queryString += ' WITH SECURITY_ENFORCED';
            }
            if (String.isNotBlank(groupByClause)) {
                queryString += groupByClause;
            }
            if (String.isNotBlank(orderByClause)) {
                queryString += orderByClause;
            }
            if (limitValue != null) {
                queryString += ' LIMIT ' + limitValue;
            }
            return queryString;
        }

        /**
         * @description Executes the built SOQL query and returns the result as a list of SObjects.
         * @return A list of SObjects resulting from the query.
         */
        public List<SObject> execute() {
            String finalQuery = buildQueryString();
            return finalQuery.contains(':') ? Database.queryWithBinds(finalQuery, bindMap, withUserMode ? AccessLevel.USER_MODE : AccessLevel.SYSTEM_MODE) : Database.query(finalQuery);
        }
        
        /**
         * @description Executes the built SOQL query with a LIMIT 1 clause and returns the first result.
         * @return The first SObject resulting from the query, or null if no records are found.
         */
        public SObject first() {
            this.getlimit(1);
            List<SObject> result = execute();
            return result.isEmpty() ? null : result[0];
        }
    }
}