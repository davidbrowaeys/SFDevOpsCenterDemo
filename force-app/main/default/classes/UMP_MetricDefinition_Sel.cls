/**
 * @author David Browaeys
 * @date 2026-02-04
 * @description Selector class for UMP_Metric_Definition__mdt custom metadata type
 * @group Selectors
 */
public inherited sharing class UMP_MetricDefinition_Sel extends TRG_sObjectSelector 
{
    //Cached list of all active metric definitions
    private List<UMP_Metric_Definition__mdt> cachedDefinitions;
    
    //Cached map of definitions by Config DeveloperName
    private Map<String, List<UMP_Metric_Definition__mdt>> definitionsByConfig;
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Creates a new instance of UMP_MetricDefinition_Sel class.
    * @return           A new instance of UMP_MetricDefinition_Sel class.
    *********************************************************************************************************/
    public static UMP_MetricDefinition_Sel getNewInstance() 
    {
        return (UMP_MetricDefinition_Sel) TRG_sObjectSelector.getNewInstance(UMP_MetricDefinition_Sel.class);
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Returns the SObject type for this selector
    * @return           SObjectType: The UMP_Metric_Definition__mdt SObject type
    *********************************************************************************************************/
    protected override SObjectType getSObjectType() 
    {
        return UMP_Metric_Definition__mdt.SObjectType;
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Returns the list of fields to query
    * @return           List<SObjectField>: The list of fields to include in queries
    *********************************************************************************************************/
    protected override List<SObjectField> getFieldsToQuery() 
    {
        return new List<SObjectField>
        {
            UMP_Metric_Definition__mdt.Id,
            UMP_Metric_Definition__mdt.DeveloperName,
            UMP_Metric_Definition__mdt.MasterLabel,
            UMP_Metric_Definition__mdt.Config__c,
            UMP_Metric_Definition__mdt.Display_Order__c,
            UMP_Metric_Definition__mdt.Metric_Label__c,
            UMP_Metric_Definition__mdt.Aggregation_Field__c,
            UMP_Metric_Definition__mdt.Aggregation_Type__c,
            UMP_Metric_Definition__mdt.Date_Field__c,
            UMP_Metric_Definition__mdt.Filter_Criteria__c,
            UMP_Metric_Definition__mdt.Win_Numerator_Filter__c,
            UMP_Metric_Definition__mdt.Win_Denominator_Filter__c,
            UMP_Metric_Definition__mdt.Format_Type__c,
            UMP_Metric_Definition__mdt.Show_Quarters__c,
            UMP_Metric_Definition__mdt.Active__c
        };
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Returns the list of relationship joined fields to query
    * @return           List<String>: The list of relationship joined fields
    *********************************************************************************************************/
    protected override List<String> getRelationshipJoinedFieldsToQuery() 
    {
        return new List<String>
        {
            'Config__r.DeveloperName'
        };
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Retrieves all active metric definitions
    * @return           List<UMP_Metric_Definition__mdt>: List of active definitions
    *********************************************************************************************************/
    public List<UMP_Metric_Definition__mdt> selectAllActive() 
    {
        if (this.cachedDefinitions == null) 
        {
            UTL_QueryBuilder qb = getNewQueryBuilder();
            qb.addCondition(new UTL_QB_ConditionMgr.PrimitiveCondition(
                UMP_Metric_Definition__mdt.Active__c + '', 
                true, 
                UTL_QB_ConditionMgr.ComparisonOperatorType.EQUAL
            ));
            qb.addSortingOrder(UMP_Metric_Definition__mdt.Display_Order__c + '', UTL_QueryBuilder.SortingType.ASC_SORTING);
            qb.setLimit(1000);
            this.cachedDefinitions = (List<UMP_Metric_Definition__mdt>) executeSOQL(qb, withoutSharing);
        }
        return this.cachedDefinitions;
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Retrieves metric definitions for a specific configuration
    * @param            configDeveloperName (String): The DeveloperName of the parent configuration
    * @return           List<UMP_Metric_Definition__mdt>: List of definitions for the configuration
    *********************************************************************************************************/
    public List<UMP_Metric_Definition__mdt> selectByConfigDeveloperName(String configDeveloperName) 
    {
        if (this.definitionsByConfig == null) 
        {
            this.definitionsByConfig = new Map<String, List<UMP_Metric_Definition__mdt>>();
            for (UMP_Metric_Definition__mdt def : selectAllActive()) 
            {
                String configName = def.Config__r.DeveloperName;
                if (String.isNotBlank(configName)) 
                {
                    if (!this.definitionsByConfig.containsKey(configName)) 
                    {
                        this.definitionsByConfig.put(configName, new List<UMP_Metric_Definition__mdt>());
                    }
                    this.definitionsByConfig.get(configName).add(def);
                }
            }
        }
        List<UMP_Metric_Definition__mdt> result = this.definitionsByConfig.get(configDeveloperName);
        return result != null ? result : new List<UMP_Metric_Definition__mdt>();
    }
}
