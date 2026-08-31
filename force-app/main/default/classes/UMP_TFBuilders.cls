/**
 * @author David Browaeys
 * @date 2026-02-09
 * @description This class contains the SObject Builder classes used by the test classes to generate test data for UMP
 * @group Universal Metric Panel
 */
@IsTest
public inherited sharing class UMP_TFBuilders {
  /**
   * @author David Browaeys
   * @date 2026-02-09
   * @description Account builder class for UMP testing
   */
  public class AccountBuilder extends UTT_Factory.SObjectBuilder {
    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Constructor of the class
     */
    public AccountBuilder() {
      super(Account.SObjectType);
      setField(
        Account.Name,
        new UTT_ValueReplacer.CounterReplacer('Test Account {0}', 3)
      );
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Set the account name
     * @param name (String): the name of the account
     * @return AccountBuilder instance itself
     */
    public AccountBuilder withName(String name) {
      setField(Account.Name, name);
      return this;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Set the account industry
     * @param industry (String): the industry of the account
     * @return AccountBuilder instance itself
     */
    public AccountBuilder withIndustry(String industry) {
      setField(Account.Industry, industry);
      return this;
    }
  }

  /**
   * @author David Browaeys
   * @date 2026-02-09
   * @description Opportunity builder class for UMP testing
   */
  public class OpportunityBuilder extends UTT_Factory.SObjectBuilder {
    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Constructor of the class
     */
    public OpportunityBuilder() {
      super(Opportunity.SObjectType);
      setField(
        Opportunity.Name,
        new UTT_ValueReplacer.CounterReplacer('Test Opportunity {0}', 3)
      );
      setField(Opportunity.StageName, 'Prospecting');
      setField(Opportunity.CloseDate, Date.today().addDays(30));
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Set a default parent account for the opportunity
     * @return OpportunityBuilder instance itself
     */
    public OpportunityBuilder forDefaultAccount() {
      setParent(Opportunity.AccountId, UMP_TF.anAccount());
      return this;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Set the parent account of the opportunity
     * @param accountBuilder (AccountBuilder): the parent account builder
     * @return OpportunityBuilder instance itself
     */
    public OpportunityBuilder forAccount(AccountBuilder accountBuilder) {
      setParent(Opportunity.AccountId, accountBuilder);
      return this;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Set the stage name of the opportunity
     * @param stageName (String): the stage name
     * @return OpportunityBuilder instance itself
     */
    public OpportunityBuilder withStageName(String stageName) {
      setField(Opportunity.StageName, stageName);
      return this;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Set the amount of the opportunity
     * @param amount (Decimal): the amount
     * @return OpportunityBuilder instance itself
     */
    public OpportunityBuilder withAmount(Decimal amount) {
      setField(Opportunity.Amount, amount);
      return this;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Set the close date of the opportunity
     * @param closeDate (Date): the close date
     * @return OpportunityBuilder instance itself
     */
    public OpportunityBuilder withCloseDate(Date closeDate) {
      setField(Opportunity.CloseDate, closeDate);
      return this;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Configure opportunity as open (Prospecting stage)
     * @return OpportunityBuilder instance itself
     */
    public OpportunityBuilder asOpen() {
      setField(Opportunity.StageName, 'Prospecting');
      return this;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Configure opportunity as won (Closed Won stage)
     * @return OpportunityBuilder instance itself
     */
    public OpportunityBuilder asWon() {
      setField(Opportunity.StageName, 'Closed Won');
      return this;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Configure opportunity as lost (Closed Lost stage)
     * @return OpportunityBuilder instance itself
     */
    public OpportunityBuilder asLost() {
      setField(Opportunity.StageName, 'Closed Lost');
      return this;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Configure opportunity for current quarter
     * @return OpportunityBuilder instance itself
     */
    public OpportunityBuilder inCurrentQuarter() {
      setField(Opportunity.CloseDate, Date.today());
      return this;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Configure opportunity for last quarter
     * @return OpportunityBuilder instance itself
     */
    public OpportunityBuilder inLastQuarter() {
      setField(Opportunity.CloseDate, Date.today().addMonths(-3));
      return this;
    }
  }

  /**
   * @author David Browaeys
   * @date 2026-02-09
   * @description Case builder class for UMP testing
   */
  public class CaseBuilder extends UTT_Factory.SObjectBuilder {
    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Constructor of the class
     */
    public CaseBuilder() {
      super(Case.SObjectType);
      setField(
        Case.Subject,
        new UTT_ValueReplacer.CounterReplacer('Test Case {0}', 3)
      );
      setField(Case.Status, 'New');
      setField(Case.Origin, 'Web');
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Set a default parent account for the case
     * @return CaseBuilder instance itself
     */
    public CaseBuilder forDefaultAccount() {
      setParent(Case.AccountId, UMP_TF.anAccount());
      return this;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Set the parent account of the case
     * @param accountBuilder (AccountBuilder): the parent account builder
     * @return CaseBuilder instance itself
     */
    public CaseBuilder forAccount(AccountBuilder accountBuilder) {
      setParent(Case.AccountId, accountBuilder);
      return this;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Set the status of the case
     * @param status (String): the status
     * @return CaseBuilder instance itself
     */
    public CaseBuilder withStatus(String status) {
      setField(Case.Status, status);
      return this;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Set the priority of the case
     * @param priority (String): the priority
     * @return CaseBuilder instance itself
     */
    public CaseBuilder withPriority(String priority) {
      setField(Case.Priority, priority);
      return this;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Configure case as new
     * @return CaseBuilder instance itself
     */
    public CaseBuilder asNew() {
      setField(Case.Status, 'New');
      return this;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Configure case as closed
     * @return CaseBuilder instance itself
     */
    public CaseBuilder asClosed() {
      setField(Case.Status, 'Closed');
      return this;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Configure case as high priority
     * @return CaseBuilder instance itself
     */
    public CaseBuilder asHighPriority() {
      setField(Case.Priority, 'High');
      return this;
    }
  }

  /**
   * @author David Browaeys
   * @date 2026-02-09
   * @description Metric Config custom metadata builder for UMP testing
   */
  public class MetricConfigBuilder extends UTT_Factory.SObjectBuilder {
    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Constructor of the class
     */
    public MetricConfigBuilder() {
      super(UMP_Metric_Config__mdt.SObjectType);
      setField(UMP_Metric_Config__mdt.Active__c, true);
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Configure for Account-Opportunity relationship
     * @return MetricConfigBuilder instance itself
     */
    public MetricConfigBuilder asAccountOpportunities() {
      setField(UMP_Metric_Config__mdt.DeveloperName, 'Account_Opportunities');
      setField(UMP_Metric_Config__mdt.MasterLabel, 'Account Opportunities');
      setField(UMP_Metric_Config__mdt.Parent_Object__c, 'Account');
      setField(UMP_Metric_Config__mdt.Child_Object__c, 'Opportunity');
      setField(UMP_Metric_Config__mdt.Relationship_Field__c, 'AccountId');
      setField(UMP_Metric_Config__mdt.Donut_Group_Field__c, 'StageName');
      setField(UMP_Metric_Config__mdt.Donut_Title__c, 'Opportunities by Stage');
      return this;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Configure for Account-Case relationship
     * @return MetricConfigBuilder instance itself
     */
    public MetricConfigBuilder asAccountCases() {
      setField(UMP_Metric_Config__mdt.DeveloperName, 'Account_Cases');
      setField(UMP_Metric_Config__mdt.MasterLabel, 'Account Cases');
      setField(UMP_Metric_Config__mdt.Parent_Object__c, 'Account');
      setField(UMP_Metric_Config__mdt.Child_Object__c, 'Case');
      setField(UMP_Metric_Config__mdt.Relationship_Field__c, 'AccountId');
      setField(UMP_Metric_Config__mdt.Donut_Group_Field__c, 'Status');
      setField(UMP_Metric_Config__mdt.Donut_Title__c, 'Cases by Status');
      return this;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Set the donut filter
     * @param filter (String): the filter expression
     * @return MetricConfigBuilder instance itself
     */
    public MetricConfigBuilder withDonutFilter(String filter) {
      setField(UMP_Metric_Config__mdt.Donut_Filter__c, filter);
      return this;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Set the chart colors
     * @param colorsJson (String): the JSON color mapping
     * @return MetricConfigBuilder instance itself
     */
    public MetricConfigBuilder withChartColors(String colorsJson) {
      setField(UMP_Metric_Config__mdt.Chart_Colors__c, colorsJson);
      return this;
    }
  }

  /**
   * @author David Browaeys
   * @date 2026-02-09
   * @description Metric Definition custom metadata builder for UMP testing
   */
  public class MetricDefinitionBuilder extends UTT_Factory.SObjectBuilder {
    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Constructor of the class
     */
    public MetricDefinitionBuilder() {
      super(UMP_Metric_Definition__mdt.SObjectType);
      setField(UMP_Metric_Definition__mdt.Active__c, true);
      setField(UMP_Metric_Definition__mdt.Display_Order__c, 1);
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Set the config reference
     * @param configDeveloperName (String): the config developer name
     * @return MetricDefinitionBuilder instance itself
     */
    public MetricDefinitionBuilder forConfig(String configDeveloperName) {
      setField(UMP_Metric_Definition__mdt.Config__c, configDeveloperName);
      return this;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Configure as COUNT aggregation
     * @param label (String): the metric label
     * @return MetricDefinitionBuilder instance itself
     */
    public MetricDefinitionBuilder asCount(String label) {
      setField(UMP_Metric_Definition__mdt.Metric_Label__c, label);
      setField(UMP_Metric_Definition__mdt.Aggregation_Type__c, 'COUNT');
      setField(UMP_Metric_Definition__mdt.Format_Type__c, 'NUMBER');
      return this;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Configure as SUM aggregation
     * @param label (String): the metric label
     * @param field (String): the field to sum
     * @return MetricDefinitionBuilder instance itself
     */
    public MetricDefinitionBuilder asSum(String label, String field) {
      setField(UMP_Metric_Definition__mdt.Metric_Label__c, label);
      setField(UMP_Metric_Definition__mdt.Aggregation_Type__c, 'SUM');
      setField(UMP_Metric_Definition__mdt.Aggregation_Field__c, field);
      setField(UMP_Metric_Definition__mdt.Format_Type__c, 'CURRENCY');
      return this;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Configure as AVG aggregation
     * @param label (String): the metric label
     * @param field (String): the field to average
     * @return MetricDefinitionBuilder instance itself
     */
    public MetricDefinitionBuilder asAverage(String label, String field) {
      setField(UMP_Metric_Definition__mdt.Metric_Label__c, label);
      setField(UMP_Metric_Definition__mdt.Aggregation_Type__c, 'AVG');
      setField(UMP_Metric_Definition__mdt.Aggregation_Field__c, field);
      setField(UMP_Metric_Definition__mdt.Format_Type__c, 'CURRENCY');
      return this;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Configure as WIN_RATE aggregation
     * @param label (String): the metric label
     * @param numeratorFilter (String): the numerator filter
     * @param denominatorFilter (String): the denominator filter
     * @return MetricDefinitionBuilder instance itself
     */
    public MetricDefinitionBuilder asWinRate(
      String label,
      String numeratorFilter,
      String denominatorFilter
    ) {
      setField(UMP_Metric_Definition__mdt.Metric_Label__c, label);
      setField(UMP_Metric_Definition__mdt.Aggregation_Type__c, 'WIN_RATE');
      setField(
        UMP_Metric_Definition__mdt.Win_Numerator_Filter__c,
        numeratorFilter
      );
      setField(
        UMP_Metric_Definition__mdt.Win_Denominator_Filter__c,
        denominatorFilter
      );
      setField(UMP_Metric_Definition__mdt.Format_Type__c, 'PERCENT');
      return this;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Set the filter criteria
     * @param filter (String): the filter expression
     * @return MetricDefinitionBuilder instance itself
     */
    public MetricDefinitionBuilder withFilter(String filter) {
      setField(UMP_Metric_Definition__mdt.Filter_Criteria__c, filter);
      return this;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Set the date field for quarterly filtering
     * @param dateField (String): the date field API name
     * @return MetricDefinitionBuilder instance itself
     */
    public MetricDefinitionBuilder withDateField(String dateField) {
      setField(UMP_Metric_Definition__mdt.Date_Field__c, dateField);
      setField(UMP_Metric_Definition__mdt.Show_Quarters__c, true);
      return this;
    }

    /**
     * @author David Browaeys
     * @date 2026-02-09
     * @description Set the display order
     * @param order (Integer): the display order
     * @return MetricDefinitionBuilder instance itself
     */
    public MetricDefinitionBuilder withDisplayOrder(Integer order) {
      setField(UMP_Metric_Definition__mdt.Display_Order__c, order);
      return this;
    }
  }
}
