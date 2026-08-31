/**
 * @author David Browaeys
 * @date 2026-02-09
 * @description This class is the SObject Builder Factory class used by the test classes to generate test data for UMP
 * @group Universal Metric Panel
 */
@IsTest
public inherited sharing class UMP_TF {
  /**
   * @author David Browaeys
   * @date 2026-02-09
   * @description Generate an Account builder instance
   * @return (UMP_TFBuilders.AccountBuilder) Return the Account Builder Instance
   */
  public static UMP_TFBuilders.AccountBuilder anAccount() {
    return new UMP_TFBuilders.AccountBuilder();
  }

  /**
   * @author David Browaeys
   * @date 2026-02-09
   * @description Generate an Opportunity builder instance
   * @return (UMP_TFBuilders.OpportunityBuilder) Return the Opportunity Builder Instance
   */
  public static UMP_TFBuilders.OpportunityBuilder anOpportunity() {
    return new UMP_TFBuilders.OpportunityBuilder();
  }

  /**
   * @author David Browaeys
   * @date 2026-02-09
   * @description Generate a Case builder instance
   * @return (UMP_TFBuilders.CaseBuilder) Return the Case Builder Instance
   */
  public static UMP_TFBuilders.CaseBuilder aCase() {
    return new UMP_TFBuilders.CaseBuilder();
  }

  /**
   * @author David Browaeys
   * @date 2026-02-09
   * @description Generate a Metric Config builder instance
   * @return (UMP_TFBuilders.MetricConfigBuilder) Return the Metric Config Builder Instance
   */
  public static UMP_TFBuilders.MetricConfigBuilder aMetricConfig() {
    return new UMP_TFBuilders.MetricConfigBuilder();
  }

  /**
   * @author David Browaeys
   * @date 2026-02-09
   * @description Generate a Metric Definition builder instance
   * @return (UMP_TFBuilders.MetricDefinitionBuilder) Return the Metric Definition Builder Instance
   */
  public static UMP_TFBuilders.MetricDefinitionBuilder aMetricDefinition() {
    return new UMP_TFBuilders.MetricDefinitionBuilder();
  }

  /**
   * @author David Browaeys
   * @date 2026-02-09
   * @description Generate a complete Account with Opportunities scenario for metric panel testing
   *              Creates an account with a mix of opportunities in different stages
   * @return (Account) The saved Account record
   */
  public static Account generateAccountWithOpportunities() {
    //Create account first
    Account testAccount = (Account) anAccount()
      .withName('Test Account for Metrics')
      .save();

    //Create opportunities in different stages - bulk insert
    List<Opportunity> opportunities = new List<Opportunity>();

    opportunities.add(
      new Opportunity(
        Name = 'Open Opp 1',
        AccountId = testAccount.Id,
        StageName = 'Prospecting',
        CloseDate = Date.today().addDays(30),
        Amount = 10000
      )
    );
    opportunities.add(
      new Opportunity(
        Name = 'Open Opp 2',
        AccountId = testAccount.Id,
        StageName = 'Qualification',
        CloseDate = Date.today().addDays(45),
        Amount = 25000
      )
    );
    opportunities.add(
      new Opportunity(
        Name = 'Won Opp 1',
        AccountId = testAccount.Id,
        StageName = 'Closed Won',
        CloseDate = Date.today().addDays(-10),
        Amount = 50000
      )
    );
    opportunities.add(
      new Opportunity(
        Name = 'Won Opp 2',
        AccountId = testAccount.Id,
        StageName = 'Closed Won',
        CloseDate = Date.today().addDays(-60),
        Amount = 75000
      )
    );
    opportunities.add(
      new Opportunity(
        Name = 'Lost Opp 1',
        AccountId = testAccount.Id,
        StageName = 'Closed Lost',
        CloseDate = Date.today().addDays(-5),
        Amount = 30000
      )
    );

    insert opportunities;

    return testAccount;
  }

  /**
   * @author David Browaeys
   * @date 2026-02-09
   * @description Generate a complete Account with Cases scenario for metric panel testing
   *              Creates an account with a mix of cases in different statuses
   * @return (Account) The saved Account record
   */
  public static Account generateAccountWithCases() {
    //Create account first
    Account testAccount = (Account) anAccount()
      .withName('Test Account for Cases')
      .save();

    //Create cases in different statuses - bulk insert
    List<Case> cases = new List<Case>();

    cases.add(
      new Case(
        AccountId = testAccount.Id,
        Subject = 'Test Case 1',
        Status = 'New',
        Priority = 'Medium'
      )
    );
    cases.add(
      new Case(
        AccountId = testAccount.Id,
        Subject = 'Test Case 2',
        Status = 'New',
        Priority = 'High'
      )
    );
    cases.add(
      new Case(
        AccountId = testAccount.Id,
        Subject = 'Test Case 3',
        Status = 'Closed',
        Priority = 'Medium'
      )
    );
    cases.add(
      new Case(
        AccountId = testAccount.Id,
        Subject = 'Test Case 4',
        Status = 'Closed',
        Priority = 'Medium'
      )
    );
    cases.add(
      new Case(
        AccountId = testAccount.Id,
        Subject = 'Test Case 5',
        Status = 'Closed',
        Priority = 'Low'
      )
    );

    insert cases;

    return testAccount;
  }

  /**
   * @author David Browaeys
   * @date 2026-02-09
   * @description Generate a complete test scenario with Account, Opportunities and mocked metadata
   *              This is the main scenario method for testing the full metric panel functionality
   * @param accountBuilder (UMP_TFBuilders.AccountBuilder): The account builder to use
   * @param numOpenOpps (Integer): Number of open opportunities to create
   * @param numWonOpps (Integer): Number of won opportunities to create
   * @param numLostOpps (Integer): Number of lost opportunities to create
   */
  public static void generateOpportunityMetricScenario(
    UMP_TFBuilders.AccountBuilder accountBuilder,
    Integer numOpenOpps,
    Integer numWonOpps,
    Integer numLostOpps
  ) {
    UTL_SObjectUnitOfWork uow = UTL_DefaultUOWFactory.getNewUOW();

    //Create open opportunities
    for (Integer i = 0; i < numOpenOpps; i++) {
      anOpportunity()
        .forAccount(accountBuilder)
        .asOpen()
        .withAmount(10000 + (i * 5000))
        .inCurrentQuarter()
        .save(uow);
    }

    //Create won opportunities
    for (Integer i = 0; i < numWonOpps; i++) {
      anOpportunity()
        .forAccount(accountBuilder)
        .asWon()
        .withAmount(25000 + (i * 10000))
        .inCurrentQuarter()
        .save(uow);
    }

    //Create lost opportunities
    for (Integer i = 0; i < numLostOpps; i++) {
      anOpportunity()
        .forAccount(accountBuilder)
        .asLost()
        .withAmount(15000 + (i * 5000))
        .inCurrentQuarter()
        .save(uow);
    }

    uow.commitWork();
  }

  /**
   * @author David Browaeys
   * @date 2026-02-09
   * @description Generate a complete test scenario with Account and Cases
   * @param accountBuilder (UMP_TFBuilders.AccountBuilder): The account builder to use
   * @param numNewCases (Integer): Number of new cases to create
   * @param numClosedCases (Integer): Number of closed cases to create
   */
  public static void generateCaseMetricScenario(
    UMP_TFBuilders.AccountBuilder accountBuilder,
    Integer numNewCases,
    Integer numClosedCases
  ) {
    UTL_SObjectUnitOfWork uow = UTL_DefaultUOWFactory.getNewUOW();

    //Create new cases
    for (Integer i = 0; i < numNewCases; i++) {
      aCase().forAccount(accountBuilder).asNew().save(uow);
    }

    //Create closed cases
    for (Integer i = 0; i < numClosedCases; i++) {
      aCase().forAccount(accountBuilder).asClosed().save(uow);
    }

    uow.commitWork();
  }

  /**
   * @author David Browaeys
   * @date 2026-02-09
   * @description Create a mocked Metric Config for Account-Opportunity relationship
   * @return (UMP_Metric_Config__mdt) The mocked config record
   */
  public static UMP_Metric_Config__mdt createMockedAccountOpportunityConfig() {
    return (UMP_Metric_Config__mdt) aMetricConfig()
      .asAccountOpportunities()
      .mock();
  }

  /**
   * @author David Browaeys
   * @date 2026-02-09
   * @description Create a mocked Metric Config for Account-Case relationship
   * @return (UMP_Metric_Config__mdt) The mocked config record
   */
  public static UMP_Metric_Config__mdt createMockedAccountCaseConfig() {
    return (UMP_Metric_Config__mdt) aMetricConfig().asAccountCases().mock();
  }

  /**
   * @author David Browaeys
   * @date 2026-02-09
   * @description Create a list of mocked Metric Definitions for opportunity metrics
   * @return (List<UMP_Metric_Definition__mdt>) The list of mocked definition records
   */
  public static List<UMP_Metric_Definition__mdt> createMockedOpportunityMetricDefinitions() {
    List<UMP_Metric_Definition__mdt> definitions = new List<UMP_Metric_Definition__mdt>();

    //Total Count metric
    definitions.add(
      (UMP_Metric_Definition__mdt) aMetricDefinition()
        .forConfig('Account_Opportunities')
        .asCount('Total Opportunities')
        .withDisplayOrder(1)
        .mock()
    );

    //Revenue Sum metric
    definitions.add(
      (UMP_Metric_Definition__mdt) aMetricDefinition()
        .forConfig('Account_Opportunities')
        .asSum('Total Revenue', 'Amount')
        .withDateField('CloseDate')
        .withDisplayOrder(2)
        .mock()
    );

    //Win Rate metric
    definitions.add(
      (UMP_Metric_Definition__mdt) aMetricDefinition()
        .forConfig('Account_Opportunities')
        .asWinRate(
          'Win Rate',
          'StageName = \'Closed Won\'',
          'StageName LIKE \'Closed%\''
        )
        .withDateField('CloseDate')
        .withDisplayOrder(3)
        .mock()
    );

    return definitions;
  }

  /**
   * @author David Browaeys
   * @date 2026-02-09
   * @description Create a list of mocked Metric Definitions for case metrics
   * @return (List<UMP_Metric_Definition__mdt>) The list of mocked definition records
   */
  public static List<UMP_Metric_Definition__mdt> createMockedCaseMetricDefinitions() {
    List<UMP_Metric_Definition__mdt> definitions = new List<UMP_Metric_Definition__mdt>();

    //Total Count metric
    definitions.add(
      (UMP_Metric_Definition__mdt) aMetricDefinition()
        .forConfig('Account_Cases')
        .asCount('Total Cases')
        .withDisplayOrder(1)
        .mock()
    );

    //Resolution Rate metric
    definitions.add(
      (UMP_Metric_Definition__mdt) aMetricDefinition()
        .forConfig('Account_Cases')
        .asWinRate('Resolution Rate', 'Status = \'Closed\'', 'Id != null')
        .withDisplayOrder(2)
        .mock()
    );

    return definitions;
  }
}
