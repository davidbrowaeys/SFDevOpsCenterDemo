/**
 * @author David Browaeys
 * @date 2026-02-04
 * @description Controller class for Universal Metric Panel LWC component
 * @group Universal Metric Panel
 */
public with sharing class UMP_MetricPanel_Ctrl 
{
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Retrieves panel data for a specific record and configuration
    * @param            recordId (Id): The parent record Id
    * @param            configDeveloperName (String): The DeveloperName of the metric configuration
    * @return           UMP_MetricPanel_Srv.PanelData: The aggregated panel data
    *********************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static UMP_MetricPanel_Srv.PanelData getPanelData(Id recordId, String configDeveloperName) 
    {
        return UMP_MetricPanel_Srv.getNewInstance(recordId, configDeveloperName).getPanelData();
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Retrieves available configurations for a parent object
    * @param            parentObjectApiName (String): The API name of the parent object
    * @return           List<ConfigOption>: List of available configurations
    *********************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<ConfigOption> getAvailableConfigs(String parentObjectApiName) 
    {
        List<ConfigOption> options = new List<ConfigOption>();
        List<UMP_Metric_Config__mdt> configs = UMP_MetricConfig_Sel.getNewInstance().selectByParentObject(parentObjectApiName);
        
        for (UMP_Metric_Config__mdt config : configs) 
        {
            ConfigOption opt = new ConfigOption();
            opt.label = config.MasterLabel;
            opt.value = config.DeveloperName;
            options.add(opt);
        }
        
        return options;
    }
    
    /**
     * @author David Browaeys
     * @date 2026-02-04
     * @description Wrapper class for configuration options
     */
    public class ConfigOption 
    {
        @AuraEnabled 
        public String label;
        @AuraEnabled 
        public String value;
    }
}
