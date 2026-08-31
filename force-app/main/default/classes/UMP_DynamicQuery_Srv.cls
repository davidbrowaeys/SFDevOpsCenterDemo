/**
 * @author David Browaeys
 * @date 2026-02-09
 * @description Reusable service for building and executing dynamic SOQL queries
 * @group Universal Metric Panel
 */
public inherited sharing class UMP_DynamicQuery_Srv implements TRG_ServiceFactory.IService {
  //The object API name to query
  private String objectApiName;

  //The fields to query
  private Set<String> fieldsToQuery;

  //The filter field and value for WHERE clause
  private String filterField;

  //The filter value
  private Id filterValue;

  //The query limit
  private Integer queryLimit;

  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Creates a new instance of UMP_DynamicQuery_Srv class.
   * @param            objectApiName (String): The object API name to query
   * @return           A new instance of UMP_DynamicQuery_Srv class.
   *********************************************************************************************************/
  public static UMP_DynamicQuery_Srv getNewInstance(String objectApiName) {
    Map<String, Object> params = new Map<String, Object>{
      'objectApiName' => objectApiName
    };
    return (UMP_DynamicQuery_Srv) TRG_ServiceFactory.getNewInstance(
      UMP_DynamicQuery_Srv.class,
      params
    );
  }

  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Initializes the service with the specified inputs.
   * @param            serviceInputs (Map<String, Object>): Map of inputs for initializing the service.
   *********************************************************************************************************/
  public void initialize(Map<String, Object> serviceInputs) {
    this.objectApiName = (String) serviceInputs.get('objectApiName');
    this.fieldsToQuery = new Set<String>{ 'Id' };
    this.queryLimit = 10000;
  }

  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Adds a single field to the query
   * @param            fieldName (String): The field API name to add
   * @return           UMP_DynamicQuery_Srv: The service instance for chaining
   *********************************************************************************************************/
  public UMP_DynamicQuery_Srv addField(String fieldName) {
    if (String.isNotBlank(fieldName)) {
      this.fieldsToQuery.add(String.escapeSingleQuotes(fieldName));
    }
    return this;
  }

  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Adds multiple fields to the query
   * @param            fieldNames (Set<String>): The field API names to add
   * @return           UMP_DynamicQuery_Srv: The service instance for chaining
   *********************************************************************************************************/
  public UMP_DynamicQuery_Srv addFields(Set<String> fieldNames) {
    if (fieldNames != null) {
      for (String fieldName : fieldNames) {
        this.addField(fieldName);
      }
    }
    return this;
  }

  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Sets the filter condition for the WHERE clause
   * @param            fieldName (String): The field to filter on
   * @param            value (Id): The Id value to filter by
   * @return           UMP_DynamicQuery_Srv: The service instance for chaining
   *********************************************************************************************************/
  public UMP_DynamicQuery_Srv filterByLookup(String fieldName, Id value) {
    this.filterField = String.escapeSingleQuotes(fieldName);
    this.filterValue = value;
    return this;
  }

  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Sets the query limit
   * @param            limitValue (Integer): The maximum number of records to return
   * @return           UMP_DynamicQuery_Srv: The service instance for chaining
   *********************************************************************************************************/
  public UMP_DynamicQuery_Srv setLimit(Integer limitValue) {
    this.queryLimit = limitValue;
    return this;
  }

  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Executes the query and returns the results
   * @return           List<SObject>: The queried records
   *********************************************************************************************************/
  public List<SObject> execute() {
    //Validate fields exist on the object
    Set<String> validFields = getValidFields();

    if (validFields.isEmpty()) {
      validFields.add('Id');
    }

    String fieldList = String.join(new List<String>(validFields), ', ');
    String escapedObject = String.escapeSingleQuotes(this.objectApiName);
    Id recId = this.filterValue;

    String query = 'SELECT ' + fieldList + ' FROM ' + escapedObject;

    if (String.isNotBlank(this.filterField) && this.filterValue != null) {
      query += ' WHERE ' + this.filterField + ' = :recId';
    }

    query += ' LIMIT ' + this.queryLimit;

    return Database.query(query);
  }

  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Validates fields exist on the object and returns only valid ones
   * @return           Set<String>: Set of valid field names that exist on the object
   *********************************************************************************************************/
  private Set<String> getValidFields() {
    Set<String> validFields = new Set<String>();

    try {
      Schema.SObjectType objType = ((SObject) Type.forName(this.objectApiName)
          .newInstance())
        .getSObjectType();
      if (objType == null) {
        return this.fieldsToQuery;
      }

      Map<String, Schema.SObjectField> fieldMap = objType.getDescribe()
        .fields.getMap();

      for (String field : this.fieldsToQuery) {
        if (fieldMap.containsKey(field.toLowerCase())) {
          validFields.add(field);
        }
      }
    } catch (Exception e) {
      //If validation fails, return requested fields
      return this.fieldsToQuery;
    }

    validFields.add('Id');
    return validFields;
  }

  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Gets the fields currently configured for the query
   * @return           Set<String>: The fields to query
   *********************************************************************************************************/
  public Set<String> getFieldsToQuery() {
    return this.fieldsToQuery;
  }
}
