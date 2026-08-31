/**
 * @author David Browaeys
 * @date 2026-02-09
 * @description Service class for evaluating dynamic filter expressions against SObject records
 * @group Universal Metric Panel
 */
public inherited sharing class UMP_FilterEvaluator_Srv implements TRG_ServiceFactory.IService {
  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Creates a new instance of UMP_FilterEvaluator_Srv class.
   * @return           A new instance of UMP_FilterEvaluator_Srv class.
   *********************************************************************************************************/
  public static UMP_FilterEvaluator_Srv getNewInstance() {
    return (UMP_FilterEvaluator_Srv) TRG_ServiceFactory.getNewInstance(
      UMP_FilterEvaluator_Srv.class
    );
  }

  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Initializes the service with the specified inputs.
   * @param            serviceInputs (Map<String, Object>): Map of inputs for initializing the service.
   *********************************************************************************************************/
  public void initialize(Map<String, Object> serviceInputs) {
    //No initialization required for this stateless service
  }

  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Evaluates a simple filter expression against a record dynamically
   * @param            record (SObject): The record to evaluate
   * @param            filterExpr (String): The filter expression (e.g., "IsClosed = true")
   * @return           Boolean: True if record matches filter
   *********************************************************************************************************/
  public Boolean evaluateFilter(SObject record, String filterExpr) {
    if (String.isBlank(filterExpr)) {
      return true;
    }

    filterExpr = filterExpr.trim();

    String fieldName = null;
    String operator = null;
    String valueStr = null;

    List<String> operators = new List<String>{
      '!=',
      '<>',
      '>=',
      '<=',
      '=',
      '>',
      '<'
    };

    for (String op : operators) {
      if (filterExpr.contains(op)) {
        fieldName = filterExpr.substringBefore(op).trim();
        operator = op;
        valueStr = filterExpr.substringAfter(op).trim();
        break;
      }
    }

    if (fieldName == null || operator == null) {
      return true;
    }

    Object fieldValue;
    try {
      fieldValue = record.get(fieldName);
    } catch (Exception e) {
      return true;
    }

    Object expectedValue = parseFilterValue(valueStr);

    if (operator == '=' || operator == '==') {
      return compareValues(fieldValue, expectedValue) == 0;
    } else if (operator == '!=' || operator == '<>') {
      if (valueStr.equalsIgnoreCase('null')) {
        return fieldValue != null;
      }
      return compareValues(fieldValue, expectedValue) != 0;
    } else if (operator == '>') {
      return compareValues(fieldValue, expectedValue) > 0;
    } else if (operator == '<') {
      return compareValues(fieldValue, expectedValue) < 0;
    } else if (operator == '>=') {
      return compareValues(fieldValue, expectedValue) >= 0;
    } else if (operator == '<=') {
      return compareValues(fieldValue, expectedValue) <= 0;
    }

    return true;
  }

  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Parses a filter value string into the appropriate type
   * @param            valueStr (String): The value string from the filter expression
   * @return           Object: The parsed value
   *********************************************************************************************************/
  public Object parseFilterValue(String valueStr) {
    if (String.isBlank(valueStr)) {
      return null;
    }

    valueStr = valueStr.trim();

    if (valueStr.equalsIgnoreCase('true')) {
      return true;
    }
    if (valueStr.equalsIgnoreCase('false')) {
      return false;
    }
    if (valueStr.equalsIgnoreCase('null')) {
      return null;
    }

    if (
      (valueStr.startsWith('\'') && valueStr.endsWith('\'')) ||
      (valueStr.startsWith('"') && valueStr.endsWith('"'))
    ) {
      return valueStr.substring(1, valueStr.length() - 1);
    }

    return valueStr;
  }

  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Compares two values for filter evaluation
   * @param            actual (Object): The actual field value
   * @param            expected (Object): The expected value from filter
   * @return           Integer: -1 if actual < expected, 0 if equal, 1 if actual > expected
   *********************************************************************************************************/
  public Integer compareValues(Object actual, Object expected) {
    if (actual == null && expected == null) {
      return 0;
    }
    if (actual == null) {
      return -1;
    }
    if (expected == null) {
      return 1;
    }

    if (actual instanceof Boolean) {
      Boolean actualBool = (Boolean) actual;
      Boolean expectedBool;
      if (expected instanceof Boolean) {
        expectedBool = (Boolean) expected;
      } else {
        expectedBool = String.valueOf(expected).equalsIgnoreCase('true');
      }
      if (actualBool == expectedBool) {
        return 0;
      }
      return actualBool ? 1 : -1;
    }

    if (actual instanceof Decimal || actual instanceof Integer) {
      Decimal actualNum = (Decimal) actual;
      Decimal expectedNum;
      if (expected instanceof Decimal || expected instanceof Integer) {
        expectedNum = (Decimal) expected;
      } else {
        try {
          expectedNum = Decimal.valueOf(String.valueOf(expected));
        } catch (Exception e) {
          return 0;
        }
      }
      if (actualNum == expectedNum) {
        return 0;
      }
      return actualNum > expectedNum ? 1 : -1;
    }

    String actualStr = String.valueOf(actual);
    String expectedStr = String.valueOf(expected);
    return actualStr.compareTo(expectedStr);
  }

  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Extracts field names from a filter expression
   * @param            filterExpr (String): The filter expression (e.g., "IsClosed = true")
   * @return           Set<String>: Set of field names found in the expression
   *********************************************************************************************************/
  public Set<String> extractFieldsFromFilter(String filterExpr) {
    Set<String> fields = new Set<String>();
    if (String.isBlank(filterExpr)) {
      return fields;
    }

    //Common patterns: "FieldName = value", "FieldName != value"
    filterExpr = filterExpr.trim();

    //Split by common operators - order matters: multi-char operators first
    List<String> operators = new List<String>{
      '!=',
      '<>',
      '>=',
      '<=',
      '=',
      '>',
      '<'
    };

    for (String op : operators) {
      if (filterExpr.contains(op)) {
        String fieldPart = filterExpr.substringBefore(op).trim();
        if (String.isNotBlank(fieldPart) && isValidFieldName(fieldPart)) {
          fields.add(fieldPart);
        }
        break;
      }
    }

    return fields;
  }

  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Validates if a string is a valid field name format
   * @param            fieldName (String): The potential field name
   * @return           Boolean: True if valid field name format
   *********************************************************************************************************/
  public Boolean isValidFieldName(String fieldName) {
    if (String.isBlank(fieldName)) {
      return false;
    }
    Pattern p = Pattern.compile('^[a-zA-Z][a-zA-Z0-9_]*$');
    Matcher m = p.matcher(fieldName);
    return m.matches();
  }
}
