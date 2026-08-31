/**
 * @author David Browaeys
 * @date 2026-02-09
 * @description Test class for UMP_MetricCalculator_Srv
 * @group Universal Metric Panel
 */
@IsTest
private class UMP_MetricCalculator_Srv_Test {
  /*********************************************************************************************************
   * @description Test data setup
   *********************************************************************************************************/
  @TestSetup
  private static void setup() {
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;

    List<Opportunity> opportunities = new List<Opportunity>();
    //Create 5 opportunities with varying amounts and stages
    opportunities.add(
      new Opportunity(
        Name = 'Open Opp 1',
        AccountId = testAccount.Id,
        StageName = 'Prospecting',
        Amount = 10000,
        CloseDate = Date.today().addDays(30)
      )
    );
    opportunities.add(
      new Opportunity(
        Name = 'Open Opp 2',
        AccountId = testAccount.Id,
        StageName = 'Qualification',
        Amount = 20000,
        CloseDate = Date.today().addDays(30)
      )
    );
    opportunities.add(
      new Opportunity(
        Name = 'Won Opp 1',
        AccountId = testAccount.Id,
        StageName = 'Closed Won',
        Amount = 30000,
        CloseDate = Date.today()
      )
    );
    opportunities.add(
      new Opportunity(
        Name = 'Won Opp 2',
        AccountId = testAccount.Id,
        StageName = 'Closed Won',
        Amount = 40000,
        CloseDate = Date.today()
      )
    );
    opportunities.add(
      new Opportunity(
        Name = 'Lost Opp',
        AccountId = testAccount.Id,
        StageName = 'Closed Lost',
        Amount = 50000,
        CloseDate = Date.today()
      )
    );
    insert opportunities;
  }

  /*********************************************************************************************************
   * @description Tests getNewInstance returns valid instance
   *********************************************************************************************************/
  @IsTest
  private static void test_getNewInstance_returnsValidInstance() {
    //Act
    Test.startTest();
    UMP_MetricCalculator_Srv service = UMP_MetricCalculator_Srv.getNewInstance();
    Test.stopTest();

    //Assert
    Assert.isNotNull(service, 'Service instance should not be null');
  }

  /*********************************************************************************************************
   * @description Tests calculate with COUNT aggregation
   *********************************************************************************************************/
  @IsTest
  private static void test_calculate_countAggregation_returnsCorrectCount() {
    //Arrange
    List<Opportunity> records = [
      SELECT Id, Name, Amount, StageName
      FROM Opportunity
    ];
    UMP_MetricCalculator_Srv service = UMP_MetricCalculator_Srv.getNewInstance();

    //Act
    Test.startTest();
    Decimal result = service.calculate(
      records,
      'COUNT',
      null,
      '',
      null,
      null,
      null
    );
    Test.stopTest();

    //Assert
    Assert.areEqual(5, result, 'Should count all 5 opportunities');
  }

  /*********************************************************************************************************
   * @description Tests calculate with COUNT and filter
   *********************************************************************************************************/
  @IsTest
  private static void test_calculate_countWithFilter_returnsFilteredCount() {
    //Arrange
    List<Opportunity> records = [
      SELECT Id, Name, Amount, StageName
      FROM Opportunity
    ];
    UMP_MetricCalculator_Srv service = UMP_MetricCalculator_Srv.getNewInstance();

    //Act
    Test.startTest();
    Decimal result = service.calculate(
      records,
      'COUNT',
      null,
      'StageName = Closed Won',
      null,
      null,
      null
    );
    Test.stopTest();

    //Assert
    Assert.areEqual(2, result, 'Should count only 2 Closed Won opportunities');
  }

  /*********************************************************************************************************
   * @description Tests calculate with SUM aggregation
   *********************************************************************************************************/
  @IsTest
  private static void test_calculate_sumAggregation_returnsCorrectSum() {
    //Arrange
    List<Opportunity> records = [
      SELECT Id, Name, Amount, StageName
      FROM Opportunity
    ];
    UMP_MetricCalculator_Srv service = UMP_MetricCalculator_Srv.getNewInstance();

    //Act
    Test.startTest();
    Decimal result = service.calculate(
      records,
      'SUM',
      'Amount',
      '',
      null,
      null,
      null
    );
    Test.stopTest();

    //Assert
    Assert.areEqual(
      150000,
      result,
      'Should sum all amounts: 10000+20000+30000+40000+50000'
    );
  }

  /*********************************************************************************************************
   * @description Tests calculate with SUM and filter
   *********************************************************************************************************/
  @IsTest
  private static void test_calculate_sumWithFilter_returnsFilteredSum() {
    //Arrange
    List<Opportunity> records = [
      SELECT Id, Name, Amount, StageName
      FROM Opportunity
    ];
    UMP_MetricCalculator_Srv service = UMP_MetricCalculator_Srv.getNewInstance();

    //Act
    Test.startTest();
    Decimal result = service.calculate(
      records,
      'SUM',
      'Amount',
      'StageName = Closed Won',
      null,
      null,
      null
    );
    Test.stopTest();

    //Assert
    Assert.areEqual(
      70000,
      result,
      'Should sum only Closed Won amounts: 30000+40000'
    );
  }

  /*********************************************************************************************************
   * @description Tests calculate with AVG aggregation
   *********************************************************************************************************/
  @IsTest
  private static void test_calculate_avgAggregation_returnsCorrectAverage() {
    //Arrange
    List<Opportunity> records = [
      SELECT Id, Name, Amount, StageName
      FROM Opportunity
    ];
    UMP_MetricCalculator_Srv service = UMP_MetricCalculator_Srv.getNewInstance();

    //Act
    Test.startTest();
    Decimal result = service.calculate(
      records,
      'AVG',
      'Amount',
      '',
      null,
      null,
      null
    );
    Test.stopTest();

    //Assert
    Assert.areEqual(30000, result, 'Should average all amounts: 150000/5');
  }

  /*********************************************************************************************************
   * @description Tests calculate with COUNT_DISTINCT aggregation
   *********************************************************************************************************/
  @IsTest
  private static void test_calculate_countDistinct_returnsUniqueCount() {
    //Arrange
    List<Opportunity> records = [
      SELECT Id, Name, Amount, StageName
      FROM Opportunity
    ];
    UMP_MetricCalculator_Srv service = UMP_MetricCalculator_Srv.getNewInstance();

    //Act
    Test.startTest();
    Decimal result = service.calculate(
      records,
      'COUNT_DISTINCT',
      'StageName',
      '',
      null,
      null,
      null
    );
    Test.stopTest();

    //Assert
    Assert.areEqual(
      4,
      result,
      'Should count 4 distinct stages: Prospecting, Qualification, Closed Won, Closed Lost'
    );
  }

  /*********************************************************************************************************
   * @description Tests calculateWinRate returns correct percentage
   *********************************************************************************************************/
  @IsTest
  private static void test_calculateWinRate_returnsCorrectPercentage() {
    //Arrange
    List<Opportunity> records = [
      SELECT Id, Name, Amount, StageName
      FROM Opportunity
    ];
    UMP_MetricCalculator_Srv service = UMP_MetricCalculator_Srv.getNewInstance();

    //Act
    Test.startTest();
    Decimal result = service.calculateWinRate(
      records,
      'StageName = Closed Won',
      'StageName = Closed Won',
      null,
      null,
      null
    );
    Test.stopTest();

    //Assert - 2 won out of 2 matching denominator = 100%
    Assert.isNotNull(result, 'Win rate should be calculated');
    Assert.areEqual(
      100,
      result,
      'Win rate should be 100% when numerator and denominator filters are the same'
    );
  }

  /*********************************************************************************************************
   * @description Tests calculate with empty records returns zero
   *********************************************************************************************************/
  @IsTest
  private static void test_calculate_emptyRecords_returnsZero() {
    //Arrange
    List<Opportunity> records = new List<Opportunity>();
    UMP_MetricCalculator_Srv service = UMP_MetricCalculator_Srv.getNewInstance();

    //Act
    Test.startTest();
    Decimal result = service.calculate(
      records,
      'COUNT',
      null,
      '',
      null,
      null,
      null
    );
    Test.stopTest();

    //Assert
    Assert.areEqual(0, result, 'Empty records should return 0');
  }

  /*********************************************************************************************************
   * @description Tests calculate with filter that matches no records
   *********************************************************************************************************/
  @IsTest
  private static void test_calculate_noMatchingFilter_returnsZero() {
    //Arrange
    List<Opportunity> records = [
      SELECT Id, Name, Amount, StageName
      FROM Opportunity
    ];
    UMP_MetricCalculator_Srv service = UMP_MetricCalculator_Srv.getNewInstance();

    //Act
    Test.startTest();
    Decimal result = service.calculate(
      records,
      'COUNT',
      null,
      'StageName = NonExistentStage',
      null,
      null,
      null
    );
    Test.stopTest();

    //Assert
    Assert.areEqual(0, result, 'No matching records should return 0');
  }

  /*********************************************************************************************************
   * @description Tests calculate with SUM on null amounts
   *********************************************************************************************************/
  @IsTest
  private static void test_calculate_sumWithNullAmounts_handlesGracefully() {
    //Arrange - Create opportunity with null amount
    Account testAccount = [SELECT Id FROM Account LIMIT 1];
    Opportunity nullAmountOpp = new Opportunity(
      Name = 'Null Amount Opp',
      AccountId = testAccount.Id,
      StageName = 'Prospecting',
      CloseDate = Date.today().addDays(30)
    );
    insert nullAmountOpp;

    List<Opportunity> records = [
      SELECT Id, Name, Amount, StageName
      FROM Opportunity
      WHERE Amount = NULL
    ];
    UMP_MetricCalculator_Srv service = UMP_MetricCalculator_Srv.getNewInstance();

    //Act
    Test.startTest();
    Decimal result = service.calculate(
      records,
      'SUM',
      'Amount',
      '',
      null,
      null,
      null
    );
    Test.stopTest();

    //Assert
    Assert.areEqual(0, result, 'Null amounts should be treated as 0');
  }

  /*********************************************************************************************************
   * @description Tests bulk calculation
   *********************************************************************************************************/
  @IsTest
  private static void test_calculate_bulkRecords_handlesCorrectly() {
    //Arrange - Create bulk test data
    Account testAccount = [SELECT Id FROM Account LIMIT 1];
    List<Opportunity> bulkOpps = new List<Opportunity>();
    for (Integer i = 0; i < 200; i++) {
      bulkOpps.add(
        new Opportunity(
          Name = 'Bulk Opp ' + i,
          AccountId = testAccount.Id,
          StageName = 'Prospecting',
          Amount = 1000,
          CloseDate = Date.today().addDays(30)
        )
      );
    }
    insert bulkOpps;

    List<Opportunity> records = [
      SELECT Id, Name, Amount, StageName
      FROM Opportunity
      WHERE Name LIKE 'Bulk Opp%'
    ];
    UMP_MetricCalculator_Srv service = UMP_MetricCalculator_Srv.getNewInstance();

    //Act
    Test.startTest();
    Decimal result = service.calculate(
      records,
      'SUM',
      'Amount',
      '',
      null,
      null,
      null
    );
    Test.stopTest();

    //Assert
    Assert.areEqual(
      200000,
      result,
      'Should sum all 200 opportunities: 200 * 1000'
    );
  }

  /*********************************************************************************************************
   * @description Tests calculate with comparison filter operators
   *********************************************************************************************************/
  @IsTest
  private static void test_calculate_comparisonFilter_returnsCorrectResult() {
    //Arrange
    List<Opportunity> records = [
      SELECT Id, Name, Amount, StageName
      FROM Opportunity
    ];
    UMP_MetricCalculator_Srv service = UMP_MetricCalculator_Srv.getNewInstance();

    //Act
    Test.startTest();
    Decimal result = service.calculate(
      records,
      'COUNT',
      null,
      'Amount >= 30000',
      null,
      null,
      null
    );
    Test.stopTest();

    //Assert
    Assert.areEqual(
      3,
      result,
      'Should count opportunities with Amount >= 30000'
    );
  }

  /*********************************************************************************************************
   * @description Tests calculate with date filter
   *********************************************************************************************************/
  @IsTest
  private static void test_calculate_withDateFilter_returnsFilteredResults() {
    //Arrange
    List<Opportunity> records = [
      SELECT Id, Name, Amount, StageName, CloseDate
      FROM Opportunity
    ];
    UMP_MetricCalculator_Srv service = UMP_MetricCalculator_Srv.getNewInstance();
    Date startDate = Date.today().addDays(-1);
    Date endDate = Date.today().addDays(1);

    //Act
    Test.startTest();
    Decimal result = service.calculate(
      records,
      'COUNT',
      null,
      '',
      'CloseDate',
      startDate,
      endDate
    );
    Test.stopTest();

    //Assert - Only the 3 closed opportunities have CloseDate = today
    Assert.areEqual(
      3,
      result,
      'Should count only opportunities with CloseDate in range'
    );
  }

  /*********************************************************************************************************
   * @description Tests calculateWinRate with different numerator and denominator
   *********************************************************************************************************/
  @IsTest
  private static void test_calculateWinRate_differentFilters_returnsCorrectRate() {
    //Arrange
    List<Opportunity> records = [
      SELECT Id, Name, Amount, StageName
      FROM Opportunity
    ];
    UMP_MetricCalculator_Srv service = UMP_MetricCalculator_Srv.getNewInstance();

    //Act - 2 won out of 5 total = 40%
    Test.startTest();
    Decimal result = service.calculateWinRate(
      records,
      'StageName = Closed Won',
      '',
      null,
      null,
      null
    );
    Test.stopTest();

    //Assert
    Assert.areEqual(
      40,
      result,
      'Win rate should be 40% (2 won out of 5 total)'
    );
  }
}
