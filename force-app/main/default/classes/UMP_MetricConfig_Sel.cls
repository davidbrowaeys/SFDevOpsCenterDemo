/**
 * @author David Browaeys
 * @date 2026-02-04
 * @description Selector class for UMP_Metric_Config__mdt custom metadata type
 * @group Selectors
 */
public inherited sharing class UMP_MetricConfig_Sel extends TRG_sObjectSelector 
{
    //Cached list of all active metric configurations
    private List<UMP_Metric_Config__mdt> cachedConfigs;
    
    //Cached map of configurations by DeveloperName
    private Map<String, UMP_Metric_Config__mdt> configsByDevName;
    
    //Cached map of configurations by Parent Object
    private Map<String, List<UMP_Metric_Config__mdt>> configsByParentObject;
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Creates a new instance of UMP_MetricConfig_Sel class.
    * @return           A new instance of UMP_MetricConfig_Sel class.
    *********************************************************************************************************/
    public static UMP_MetricConfig_Sel getNewInstance() 
    {
        return (UMP_MetricConfig_Sel) TRG_sObjectSelector.getNewInstance(UMP_MetricConfig_Sel.class);
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Returns the SObject type for this selector
    * @return           SObjectType: The UMP_Metric_Config__mdt SObject type
    *********************************************************************************************************/
    protected override SObjectType getSObjectType() 
    {
        return UMP_Metric_Config__mdt.SObjectType;
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
            UMP_Metric_Config__mdt.Id,
            UMP_Metric_Config__mdt.DeveloperName,
            UMP_Metric_Config__mdt.MasterLabel,
            UMP_Metric_Config__mdt.Parent_Object__c,
            UMP_Metric_Config__mdt.Child_Object__c,
            UMP_Metric_Config__mdt.Relationship_Field__c,
            UMP_Metric_Config__mdt.Donut_Group_Field__c,
            UMP_Metric_Config__mdt.Donut_Filter__c,
            UMP_Metric_Config__mdt.Donut_Title__c,
            UMP_Metric_Config__mdt.Chart_Colors__c,
            UMP_Metric_Config__mdt.Active__c
        };
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Returns the list of relationship joined fields to query
    * @return           List<String>: The list of relationship joined fields (empty for this selector)
    *********************************************************************************************************/
    protected override List<String> getRelationshipJoinedFieldsToQuery() 
    {
        return new List<String>();
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Retrieves all active metric configurations
    * @return           List<UMP_Metric_Config__mdt>: List of active configurations
    *********************************************************************************************************/
    public List<UMP_Metric_Config__mdt> selectAllActive() 
    {
        if (this.cachedConfigs == null) 
        {
            UTL_QueryBuilder qb = getNewQueryBuilder();
            qb.addCondition(new UTL_QB_ConditionMgr.PrimitiveCondition(
                UMP_Metric_Config__mdt.Active__c + '', 
                true, 
                UTL_QB_ConditionMgr.ComparisonOperatorType.EQUAL
            ));
            qb.setLimit(1000);
            this.cachedConfigs = (List<UMP_Metric_Config__mdt>) executeSOQL(qb, withoutSharing);
        }
        return this.cachedConfigs;
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Retrieves a configuration by its DeveloperName
    * @param            developerName (String): The DeveloperName of the configuration
    * @return           UMP_Metric_Config__mdt: The matching configuration or null
    *********************************************************************************************************/
    public UMP_Metric_Config__mdt selectByDeveloperName(String developerName) 
    {
        if (this.configsByDevName == null) 
        {
            this.configsByDevName = new Map<String, UMP_Metric_Config__mdt>();
            for (UMP_Metric_Config__mdt config : selectAllActive()) 
            {
                this.configsByDevName.put(config.DeveloperName, config);
            }
        }
        return this.configsByDevName.get(developerName);
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Retrieves configurations for a specific parent object
    * @param            parentObjectApiName (String): The API name of the parent object
    * @return           List<UMP_Metric_Config__mdt>: List of configurations for the parent object
    *********************************************************************************************************/
    public List<UMP_Metric_Config__mdt> selectByParentObject(String parentObjectApiName) 
    {
        if (this.configsByParentObject == null) 
        {
            this.configsByParentObject = new Map<String, List<UMP_Metric_Config__mdt>>();
            for (UMP_Metric_Config__mdt config : selectAllActive()) 
            {
                String parentObj = config.Parent_Object__c;
                if (!this.configsByParentObject.containsKey(parentObj)) 
                {
                    this.configsByParentObject.put(parentObj, new List<UMP_Metric_Config__mdt>());
                }
                this.configsByParentObject.get(parentObj).add(config);
            }
        }
        List<UMP_Metric_Config__mdt> result = this.configsByParentObject.get(parentObjectApiName);
        return result != null ? result : new List<UMP_Metric_Config__mdt>();
    }
}
