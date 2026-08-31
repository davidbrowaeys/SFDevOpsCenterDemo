/**
 * @author David Browaeys
 * @date 2026-02-04
 * @description Service class for Universal Metric Panel - handles data aggregation and metric calculations
 * @group Universal Metric Panel
 */
public inherited sharing class UMP_MetricPanel_Srv implements TRG_ServiceFactory.IService 
{
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Creates a new instance of UMP_MetricPanel_Srv class.
    * @param            recordId (Id): The parent record Id
    * @param            configDeveloperName (String): The DeveloperName of the metric configuration
    * @return           A new instance of UMP_MetricPanel_Srv class.
    *********************************************************************************************************/
    public static UMP_MetricPanel_Srv getNewInstance(Id recordId, String configDeveloperName) 
    {
        Map<String, Object> params = new Map<String, Object>
        {
            'recordId' => recordId,
            'configDeveloperName' => configDeveloperName
        };
        return (UMP_MetricPanel_Srv) TRG_ServiceFactory.getNewInstance(UMP_MetricPanel_Srv.class, params);
    }

    //The parent record Id
    private Id recordId;
    
    //The configuration developer name
    private String configDeveloperName;

    //The filter evaluator service instance
    private UMP_FilterEvaluator_Srv filterEvaluator
    {
        get
        {
            if (this.filterEvaluator == null)
            {
                this.filterEvaluator = UMP_FilterEvaluator_Srv.getNewInstance();
            }
            return this.filterEvaluator;
        }
        set;
    }

    //The metric calculator service instance
    private UMP_MetricCalculator_Srv metricCalculator
    {
        get
        {
            if (this.metricCalculator == null)
            {
                this.metricCalculator = UMP_MetricCalculator_Srv.getNewInstance();
            }
            return this.metricCalculator;
        }
        set;
    }

    //The metric configuration loaded from custom metadata
    private UMP_Metric_Config__mdt config
    {
        get
        {
            if (this.config == null)
            {
                this.config = UMP_MetricConfig_Sel.getNewInstance().selectByDeveloperName(this.configDeveloperName);
            }
            return this.config;
        }
        set;
    }

    //The metric definitions loaded from custom metadata
    private List<UMP_Metric_Definition__mdt> metricDefs
    {
        get
        {
            if (this.metricDefs == null)
            {
                this.metricDefs = UMP_MetricDefinition_Sel.getNewInstance().selectByConfigDeveloperName(this.configDeveloperName);
            }
            return this.metricDefs;
        }
        set;
    }

    //The fiscal quarter date boundaries
    private Map<String, Date> quarterDates
    {
        get
        {
            if (this.quarterDates == null)
            {
                this.quarterDates = getFiscalQuarterDates();
            }
            return this.quarterDates;
        }
        set;
    }

    //The child records queried from the database
    private List<SObject> childRecords
    {
        get
        {
            if (this.childRecords == null)
            {
                this.childRecords = queryChildRecords();
            }
            return this.childRecords;
        }
        set;
    }

    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Initializes the service with the specified inputs.
    * @param            serviceInputs (Map<String, Object>): Map of inputs for initializing the service.
    *********************************************************************************************************/
    public void initialize(Map<String, Object> serviceInputs) 
    {
        this.recordId = (Id) serviceInputs.get('recordId');
        this.configDeveloperName = (String) serviceInputs.get('configDeveloperName');
    }

    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Retrieves panel data for the configured record and configuration
    * @return           PanelData: The aggregated panel data
    *********************************************************************************************************/
    public PanelData getPanelData() 
    {
        if (this.config == null) 
        {
            throw new AuraHandledException('Configuration not found: ' + this.configDeveloperName);
        }

        PanelData result = new PanelData();
        result.donutTitle = this.config.Donut_Title__c;
        result.childObjectApiName = this.config.Child_Object__c;
        result.relationshipField = this.config.Relationship_Field__c;

        //Get parent record name
        result.parentName = getParentRecordName();

        //Get donut chart data from queried records
        result.donutSegments = buildDonutSegments();
        result.totalCount = 0;
        for (DonutSegment seg : result.donutSegments) 
        {
            result.totalCount += seg.count;
        }

        //Calculate percentages
        for (DonutSegment seg : result.donutSegments) 
        {
            seg.percentage = result.totalCount > 0
                ? (Decimal.valueOf(seg.count) / result.totalCount * 100).setScale(1)
                : 0;
        }

        //Calculate metrics from queried records (no additional SOQL)
        result.metrics = calculateMetricsFromRecords();

        return result;
    }

    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Gets the parent record name
    * @return           String: The record name
    *********************************************************************************************************/
    private String getParentRecordName() 
    {
        String objectApiName = this.config.Parent_Object__c;
        Id recId = this.recordId;
        String query = 'SELECT Name FROM ' + String.escapeSingleQuotes(objectApiName) + ' WHERE Id = :recId LIMIT 1';
        List<SObject> records = Database.query(query);
        return records.isEmpty() ? '' : (String) records[0].get('Name');
    }

    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Queries all child records with fields needed for metrics using dynamic query service
    * @return           List<SObject>: The queried child records
    *********************************************************************************************************/
    private List<SObject> queryChildRecords() 
    {
        //Collect all fields needed
        Set<String> fieldsToQuery = collectFieldsToQuery();

        //Use dynamic query service
        return UMP_DynamicQuery_Srv.getNewInstance(this.config.Child_Object__c)
            .addFields(fieldsToQuery)
            .filterByLookup(this.config.Relationship_Field__c, this.recordId)
            .setLimit(10000)
            .execute();
    }

    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-09
    * @description      Collects all fields needed for the query from config and metric definitions
    * @return           Set<String>: The set of field names to query
    *********************************************************************************************************/
    private Set<String> collectFieldsToQuery() 
    {
        Set<String> fieldsToQuery = new Set<String>{ 'Id', this.config.Donut_Group_Field__c };

        for (UMP_Metric_Definition__mdt def : this.metricDefs) 
        {
            if (String.isNotBlank(def.Aggregation_Field__c)) 
            {
                fieldsToQuery.add(def.Aggregation_Field__c);
            }
            if (String.isNotBlank(def.Date_Field__c)) 
            {
                fieldsToQuery.add(def.Date_Field__c);
            }
            //Extract fields from filter expressions dynamically using filter evaluator service
            if (String.isNotBlank(def.Filter_Criteria__c)) 
            {
                fieldsToQuery.addAll(this.filterEvaluator.extractFieldsFromFilter(def.Filter_Criteria__c));
            }
            if (String.isNotBlank(def.Win_Numerator_Filter__c)) 
            {
                fieldsToQuery.addAll(this.filterEvaluator.extractFieldsFromFilter(def.Win_Numerator_Filter__c));
            }
            if (String.isNotBlank(def.Win_Denominator_Filter__c)) 
            {
                fieldsToQuery.addAll(this.filterEvaluator.extractFieldsFromFilter(def.Win_Denominator_Filter__c));
            }
        }

        //Extract fields from donut filter
        if (String.isNotBlank(this.config.Donut_Filter__c)) 
        {
            fieldsToQuery.addAll(this.filterEvaluator.extractFieldsFromFilter(this.config.Donut_Filter__c));
        }

        return fieldsToQuery;
    }

    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Builds donut segments from queried records
    * @return           List<DonutSegment>: The donut segments
    *********************************************************************************************************/
    private List<DonutSegment> buildDonutSegments() 
    {
        List<DonutSegment> segments = new List<DonutSegment>();
        String groupField = this.config.Donut_Group_Field__c;

        //Parse color mapping
        Map<String, String> colorMap = parseColorMapping();

        //Group records by the group field, applying donut filter
        Map<String, Integer> countsByGroup = groupRecordsByField(groupField);

        //Default colors for segments without configured colors
        List<String> defaultColors = new List<String>{
            '#10B981', '#06B6D4', '#8B5CF6', '#EC4899', '#F59E0B',
            '#A855F7', '#3B82F6', '#EF4444', '#22C55E', '#6B7280'
        };
        Integer colorIndex = 0;

        //Sort by count descending
        List<GroupCount> sortedGroups = sortGroupsByCount(countsByGroup);

        for (GroupCount gc : sortedGroups) 
        {
            DonutSegment seg = new DonutSegment();
            seg.label = gc.groupValue;
            seg.count = gc.count;

            if (colorMap.containsKey(seg.label)) 
            {
                seg.color = colorMap.get(seg.label);
            } 
            else 
            {
                seg.color = defaultColors[Math.mod(colorIndex, defaultColors.size())];
                colorIndex++;
            }

            segments.add(seg);
        }

        return segments;
    }

    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-09
    * @description      Parses the color mapping from config
    * @return           Map<String, String>: Map of group value to color
    *********************************************************************************************************/
    private Map<String, String> parseColorMapping() 
    {
        Map<String, String> colorMap = new Map<String, String>();
        if (String.isNotBlank(this.config.Chart_Colors__c)) 
        {
            Map<String, Object> colors = (Map<String, Object>) JSON.deserializeUntyped(this.config.Chart_Colors__c);
            for (String key : colors.keySet()) 
            {
                colorMap.put(key, String.valueOf(colors.get(key)));
            }
        }
        return colorMap;
    }

    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-09
    * @description      Groups records by a field value, applying donut filter
    * @param            groupField (String): The field to group by
    * @return           Map<String, Integer>: Map of group value to count
    *********************************************************************************************************/
    private Map<String, Integer> groupRecordsByField(String groupField) 
    {
        Map<String, Integer> countsByGroup = new Map<String, Integer>();

        for (SObject record : this.childRecords) 
        {
            //Apply donut filter if configured using filter evaluator service
            if (String.isNotBlank(this.config.Donut_Filter__c)) 
            {
                if (!this.filterEvaluator.evaluateFilter(record, this.config.Donut_Filter__c)) 
                {
                    continue;
                }
            }

            String groupValue = String.valueOf(record.get(groupField));
            if (groupValue == null) 
            {
                groupValue = '(None)';
            }

            if (!countsByGroup.containsKey(groupValue)) 
            {
                countsByGroup.put(groupValue, 0);
            }
            countsByGroup.put(groupValue, countsByGroup.get(groupValue) + 1);
        }

        return countsByGroup;
    }

    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-09
    * @description      Sorts groups by count descending
    * @param            countsByGroup (Map<String, Integer>): Map of group value to count
    * @return           List<GroupCount>: Sorted list of group counts
    *********************************************************************************************************/
    private List<GroupCount> sortGroupsByCount(Map<String, Integer> countsByGroup) 
    {
        List<GroupCount> sortedGroups = new List<GroupCount>();
        for (String groupValue : countsByGroup.keySet()) 
        {
            sortedGroups.add(new GroupCount(groupValue, countsByGroup.get(groupValue)));
        }
        sortedGroups.sort();
        return sortedGroups;
    }

    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Calculates metrics from already queried records
    * @return           List<MetricResult>: The calculated metrics
    *********************************************************************************************************/
    private List<MetricResult> calculateMetricsFromRecords() 
    {
        List<MetricResult> results = new List<MetricResult>();

        for (UMP_Metric_Definition__mdt def : this.metricDefs) 
        {
            MetricResult metric = new MetricResult();
            metric.label = def.Metric_Label__c;
            metric.formatType = def.Format_Type__c;
            metric.showQuarters = def.Show_Quarters__c;

            if (def.Show_Quarters__c && String.isNotBlank(def.Date_Field__c)) 
            {
                metric.lastQuarterValue = calculateMetricValue(
                    def,
                    this.quarterDates.get('lastQuarterStart'),
                    this.quarterDates.get('lastQuarterEnd')
                );

                metric.thisQuarterValue = calculateMetricValue(
                    def,
                    this.quarterDates.get('thisQuarterStart'),
                    this.quarterDates.get('thisQuarterEnd')
                );
            } 
            else 
            {
                metric.thisQuarterValue = calculateMetricValue(def, null, null);
                metric.lastQuarterValue = metric.thisQuarterValue;
            }

            metric.lastQuarterFormatted = formatValue(metric.lastQuarterValue, def.Format_Type__c);
            metric.thisQuarterFormatted = formatValue(metric.thisQuarterValue, def.Format_Type__c);

            results.add(metric);
        }

        return results;
    }

    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Calculates a single metric value from records using the metric calculator service
    * @param            def (UMP_Metric_Definition__mdt): The metric definition
    * @param            startDate (Date): Optional start date filter
    * @param            endDate (Date): Optional end date filter
    * @return           Decimal: The calculated value
    *********************************************************************************************************/
    private Decimal calculateMetricValue(UMP_Metric_Definition__mdt def, Date startDate, Date endDate) 
    {
        String aggregationType = def.Aggregation_Type__c;

        //Handle WIN_RATE separately as it has different parameters
        if (aggregationType == 'WIN_RATE') 
        {
            return this.metricCalculator.calculateWinRate(
                this.childRecords,
                def.Win_Numerator_Filter__c,
                def.Win_Denominator_Filter__c,
                def.Date_Field__c,
                startDate,
                endDate
            );
        }

        //Use metric calculator for standard aggregations
        return this.metricCalculator.calculate(
            this.childRecords,
            aggregationType,
            def.Aggregation_Field__c,
            def.Filter_Criteria__c,
            def.Date_Field__c,
            startDate,
            endDate
        );
    }

    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Gets fiscal quarter date boundaries
    * @return           Map<String, Date>: Map containing quarter start/end dates
    *********************************************************************************************************/
    private Map<String, Date> getFiscalQuarterDates() 
    {
        Map<String, Date> dates = new Map<String, Date>();

        Organization org = [SELECT FiscalYearStartMonth, UsesStartDateAsFiscalYearName FROM Organization LIMIT 1];
        Integer fiscalStartMonth = org.FiscalYearStartMonth;

        Date today = Date.today();
        Integer currentMonth = today.month();
        Integer currentYear = today.year();

        Integer monthsFromFiscalStart = Math.mod(currentMonth - fiscalStartMonth + 12, 12);
        Integer currentQuarter = (monthsFromFiscalStart / 3) + 1;

        Integer thisQuarterStartMonth = Math.mod(fiscalStartMonth + ((currentQuarter - 1) * 3) - 1, 12) + 1;
        Integer thisQuarterStartYear = currentYear;
        if (thisQuarterStartMonth > currentMonth) 
        {
            thisQuarterStartYear--;
        }

        Date thisQuarterStart = Date.newInstance(thisQuarterStartYear, thisQuarterStartMonth, 1);
        Date thisQuarterEnd = thisQuarterStart.addMonths(3).addDays(-1);

        Date lastQuarterStart = thisQuarterStart.addMonths(-3);
        Date lastQuarterEnd = thisQuarterStart.addDays(-1);

        dates.put('thisQuarterStart', thisQuarterStart);
        dates.put('thisQuarterEnd', thisQuarterEnd);
        dates.put('lastQuarterStart', lastQuarterStart);
        dates.put('lastQuarterEnd', lastQuarterEnd);

        return dates;
    }

    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Formats a value based on format type
    * @param            value (Decimal): The value to format
    * @param            formatType (String): The format type
    * @return           String: The formatted value
    *********************************************************************************************************/
    private String formatValue(Decimal value, String formatType) 
    {
        if (value == null) 
        {
            return '-';
        }

        if (formatType == 'CURRENCY') 
        {
            return formatCurrency(value);
        } 
        else if (formatType == 'PERCENT') 
        {
            return value.setScale(0) + '%';
        } 
        else 
        {
            return formatNumber(value);
        }
    }

    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-09
    * @description      Formats a currency value with appropriate suffix
    * @param            value (Decimal): The value to format
    * @return           String: The formatted currency value
    *********************************************************************************************************/
    private String formatCurrency(Decimal value) 
    {
        if (value >= 1000000) 
        {
            return '$' + (value / 1000000).setScale(1) + 'M';
        } 
        else if (value >= 1000) 
        {
            return '$' + (value / 1000).setScale(0) + 'K';
        } 
        else 
        {
            return '$' + value.setScale(0);
        }
    }

    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-09
    * @description      Formats a number value with appropriate suffix
    * @param            value (Decimal): The value to format
    * @return           String: The formatted number value
    *********************************************************************************************************/
    private String formatNumber(Decimal value) 
    {
        if (value >= 1000000) 
        {
            return (value / 1000000).setScale(1) + 'M';
        } 
        else if (value >= 1000) 
        {
            return (value / 1000).setScale(0) + 'K';
        } 
        else 
        {
            return String.valueOf(value.setScale(0));
        }
    }

    /**
     * @author David Browaeys
     * @date 2026-02-04
     * @description Wrapper class for panel data returned to LWC
     */
    public class PanelData 
    {
        @AuraEnabled
        public String parentName;
        @AuraEnabled
        public String donutTitle;
        @AuraEnabled
        public Integer totalCount;
        @AuraEnabled
        public List<DonutSegment> donutSegments;
        @AuraEnabled
        public List<MetricResult> metrics;
        @AuraEnabled
        public String childObjectApiName;
        @AuraEnabled
        public String relationshipField;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-04
     * @description Wrapper class for donut chart segments
     */
    public class DonutSegment 
    {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public Integer count;
        @AuraEnabled
        public String color;
        @AuraEnabled
        public Decimal percentage;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-04
     * @description Wrapper class for metric results
     */
    public class MetricResult 
    {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String formatType;
        @AuraEnabled
        public Boolean showQuarters;
        @AuraEnabled
        public Decimal lastQuarterValue;
        @AuraEnabled
        public Decimal thisQuarterValue;
        @AuraEnabled
        public String lastQuarterFormatted;
        @AuraEnabled
        public String thisQuarterFormatted;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-04
     * @description Helper class for sorting groups by count
     */
    private class GroupCount implements Comparable 
    {
        public String groupValue;
        public Integer count;

        public GroupCount(String groupValue, Integer count) 
        {
            this.groupValue = groupValue;
            this.count = count;
        }

        public Integer compareTo(Object other) 
        {
            GroupCount otherGc = (GroupCount) other;
            return otherGc.count - this.count;
        }
    }
}
