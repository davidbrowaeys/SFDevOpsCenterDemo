/**
 * @author David Browaeys
 * @date 2026-02-09
 * @description Service class for calculating metrics from SObject records
 * @group Universal Metric Panel
 */
public inherited sharing class UMP_MetricCalculator_Srv implements TRG_ServiceFactory.IService {
  //The filter evaluator service instance
  private UMP_FilterEvaluator_Srv filterEvaluator;

  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Creates a new instance of UMP_MetricCalculator_Srv class.
   * @return           A new instance of UMP_MetricCalculator_Srv class.
   *********************************************************************************************************/
  public static UMP_MetricCalculator_Srv getNewInstance() {
    return (UMP_MetricCalculator_Srv) TRG_ServiceFactory.getNewInstance(
      UMP_MetricCalculator_Srv.class
    );
  }

  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Initializes the service with the specified inputs.
   * @param            serviceInputs (Map<String, Object>): Map of inputs for initializing the service.
   *********************************************************************************************************/
  public void initialize(Map<String, Object> serviceInputs) {
    this.filterEvaluator = UMP_FilterEvaluator_Srv.getNewInstance();
  }

  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Calculates a metric value based on the aggregation type
   * @param            records (List<SObject>): The records to calculate from
   * @param            aggregationType (String): The type of aggregation (COUNT, SUM, AVG, etc.)
   * @param            aggregationField (String): The field to aggregate
   * @param            filterCriteria (String): Optional filter criteria
   * @param            dateField (String): Optional date field for filtering
   * @param            startDate (Date): Optional start date
   * @param            endDate (Date): Optional end date
   * @return           Decimal: The calculated value
   *********************************************************************************************************/
  public Decimal calculate(
    List<SObject> records,
    String aggregationType,
    String aggregationField,
    String filterCriteria,
    String dateField,
    Date startDate,
    Date endDate
  ) {
    //Filter records by date range and custom filter
    List<SObject> filteredRecords = filterRecords(
      records,
      filterCriteria,
      dateField,
      startDate,
      endDate
    );

    //Calculate based on aggregation type
    if (aggregationType == 'COUNT') {
      return calculateCount(filteredRecords);
    }

    if (aggregationType == 'COUNT_DISTINCT') {
      return calculateCountDistinct(filteredRecords, aggregationField);
    }

    if (aggregationType == 'SUM') {
      return calculateSum(filteredRecords, aggregationField);
    }

    if (aggregationType == 'AVG') {
      return calculateAverage(filteredRecords, aggregationField);
    }

    return 0;
  }

  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Calculates win rate from records
   * @param            records (List<SObject>): The records to calculate from
   * @param            numeratorFilter (String): Filter for numerator (wins)
   * @param            denominatorFilter (String): Filter for denominator (total)
   * @param            dateField (String): Optional date field for filtering
   * @param            startDate (Date): Optional start date
   * @param            endDate (Date): Optional end date
   * @return           Decimal: The win rate as a percentage
   *********************************************************************************************************/
  public Decimal calculateWinRate(
    List<SObject> records,
    String numeratorFilter,
    String denominatorFilter,
    String dateField,
    Date startDate,
    Date endDate
  ) {
    Integer numerator = 0;
    Integer denominator = 0;

    for (SObject record : records) {
      //Apply date filter
      if (!passesDateFilter(record, dateField, startDate, endDate)) {
        continue;
      }

      //Check denominator filter
      Boolean matchesDenominator = true;
      if (String.isNotBlank(denominatorFilter)) {
        matchesDenominator = this.filterEvaluator.evaluateFilter(
          record,
          denominatorFilter
        );
      }

      if (matchesDenominator) {
        denominator++;

        //Check numerator filter
        if (String.isNotBlank(numeratorFilter)) {
          if (this.filterEvaluator.evaluateFilter(record, numeratorFilter)) {
            numerator++;
          }
        }
      }
    }

    if (denominator == 0) {
      return 0;
    }

    return (Decimal.valueOf(numerator) / denominator * 100).setScale(0);
  }

  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Filters records by date range and custom filter criteria
   * @param            records (List<SObject>): The records to filter
   * @param            filterCriteria (String): Optional filter criteria
   * @param            dateField (String): Optional date field for filtering
   * @param            startDate (Date): Optional start date
   * @param            endDate (Date): Optional end date
   * @return           List<SObject>: The filtered records
   *********************************************************************************************************/
  private List<SObject> filterRecords(
    List<SObject> records,
    String filterCriteria,
    String dateField,
    Date startDate,
    Date endDate
  ) {
    List<SObject> filteredRecords = new List<SObject>();

    for (SObject record : records) {
      //Apply date filter
      if (!passesDateFilter(record, dateField, startDate, endDate)) {
        continue;
      }

      //Apply custom filter
      if (String.isNotBlank(filterCriteria)) {
        if (!this.filterEvaluator.evaluateFilter(record, filterCriteria)) {
          continue;
        }
      }

      filteredRecords.add(record);
    }

    return filteredRecords;
  }

  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Checks if a record passes the date filter
   * @param            record (SObject): The record to check
   * @param            dateField (String): The date field name
   * @param            startDate (Date): The start date
   * @param            endDate (Date): The end date
   * @return           Boolean: True if record passes filter
   *********************************************************************************************************/
  private Boolean passesDateFilter(
    SObject record,
    String dateField,
    Date startDate,
    Date endDate
  ) {
    if (startDate == null || endDate == null || String.isBlank(dateField)) {
      return true;
    }

    Object dateVal = record.get(dateField);
    if (dateVal == null) {
      return false;
    }

    Date recordDate = convertToDate(dateVal);
    if (recordDate == null) {
      return false;
    }

    return recordDate >= startDate && recordDate <= endDate;
  }

  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Calculates COUNT aggregation
   * @param            records (List<SObject>): The records to count
   * @return           Decimal: The count
   *********************************************************************************************************/
  private Decimal calculateCount(List<SObject> records) {
    return records.size();
  }

  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Calculates COUNT_DISTINCT aggregation
   * @param            records (List<SObject>): The records to process
   * @param            aggregationField (String): The field to count distinct values
   * @return           Decimal: The distinct count
   *********************************************************************************************************/
  private Decimal calculateCountDistinct(
    List<SObject> records,
    String aggregationField
  ) {
    if (String.isBlank(aggregationField)) {
      return 0;
    }

    Set<Object> distinctValues = new Set<Object>();
    for (SObject record : records) {
      Object val = record.get(aggregationField);
      if (val != null) {
        distinctValues.add(val);
      }
    }
    return distinctValues.size();
  }

  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Calculates SUM aggregation
   * @param            records (List<SObject>): The records to sum
   * @param            aggregationField (String): The field to sum
   * @return           Decimal: The sum
   *********************************************************************************************************/
  private Decimal calculateSum(List<SObject> records, String aggregationField) {
    if (String.isBlank(aggregationField)) {
      return 0;
    }

    Decimal total = 0;
    for (SObject record : records) {
      Object val = record.get(aggregationField);
      if (val != null) {
        total += (Decimal) val;
      }
    }
    return total;
  }

  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Calculates AVG aggregation
   * @param            records (List<SObject>): The records to average
   * @param            aggregationField (String): The field to average
   * @return           Decimal: The average
   *********************************************************************************************************/
  private Decimal calculateAverage(
    List<SObject> records,
    String aggregationField
  ) {
    if (String.isBlank(aggregationField)) {
      return 0;
    }

    Decimal total = 0;
    Integer count = 0;

    for (SObject record : records) {
      Object val = record.get(aggregationField);
      if (val != null) {
        total += (Decimal) val;
        count++;
      }
    }

    if (count == 0) {
      return 0;
    }

    return total / count;
  }

  /*********************************************************************************************************
   * @author           David Browaeys
   * @date             2026-02-09
   * @description      Converts an Object to Date, handling both Date and DateTime types
   * @param            dateValue (Object): The date value to convert
   * @return           Date: The converted Date value, or null if conversion fails
   *********************************************************************************************************/
  private Date convertToDate(Object dateValue) {
    if (dateValue == null) {
      return null;
    }

    if (dateValue instanceof Date) {
      return (Date) dateValue;
    }

    if (dateValue instanceof DateTime) {
      return ((DateTime) dateValue).date();
    }

    return null;
  }
}
