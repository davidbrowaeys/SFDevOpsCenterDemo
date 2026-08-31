/**
 * @author David Browaeys
 * @date 2026-02-09
 * @description Test class for UMP_FilterEvaluator_Srv
 * @group Universal Metric Panel
 */
@IsTest
private class UMP_FilterEvaluator_Srv_Test {
  /*********************************************************************************************************
   * @description Tests evaluateFilter with equality operator
   *********************************************************************************************************/
  @IsTest
  private static void test_evaluateFilter_equalityOperator_returnsCorrectResult() {
    //Arrange
    UMP_FilterEvaluator_Srv service = UMP_FilterEvaluator_Srv.getNewInstance();
    Opportunity opp = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Prospecting',
      Amount = 50000,
      CloseDate = Date.today().addDays(30)
    );

    //Act & Assert - String equality
    Test.startTest();
    Boolean matchesStage = service.evaluateFilter(
      opp,
      'StageName = Prospecting'
    );
    Boolean notMatchesStage = service.evaluateFilter(
      opp,
      'StageName = Closed Won'
    );
    Test.stopTest();

    Assert.isTrue(matchesStage, 'Filter StageName = Prospecting should match');
    Assert.isFalse(
      notMatchesStage,
      'Filter StageName = Closed Won should not match'
    );
  }

  /*********************************************************************************************************
   * @description Tests evaluateFilter with inequality operator
   *********************************************************************************************************/
  @IsTest
  private static void test_evaluateFilter_inequalityOperator_returnsCorrectResult() {
    //Arrange
    UMP_FilterEvaluator_Srv service = UMP_FilterEvaluator_Srv.getNewInstance();
    Opportunity opp = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Prospecting',
      Amount = 50000,
      CloseDate = Date.today().addDays(30)
    );

    //Act
    Test.startTest();
    Boolean notEqualsMatch = service.evaluateFilter(
      opp,
      'StageName != Closed Won'
    );
    Boolean notEqualsNoMatch = service.evaluateFilter(
      opp,
      'StageName != Prospecting'
    );
    Boolean notEqualsAlt = service.evaluateFilter(
      opp,
      'StageName <> Closed Won'
    );
    Test.stopTest();

    //Assert
    Assert.isTrue(
      notEqualsMatch,
      'Filter StageName != Closed Won should match'
    );
    Assert.isFalse(
      notEqualsNoMatch,
      'Filter StageName != Prospecting should not match'
    );
    Assert.isTrue(notEqualsAlt, 'Filter StageName <> Closed Won should match');
  }

  /*********************************************************************************************************
   * @description Tests evaluateFilter with comparison operators
   *********************************************************************************************************/
  @IsTest
  private static void test_evaluateFilter_comparisonOperators_returnsCorrectResult() {
    //Arrange
    UMP_FilterEvaluator_Srv service = UMP_FilterEvaluator_Srv.getNewInstance();
    Opportunity opp = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Prospecting',
      Amount = 50000,
      CloseDate = Date.today().addDays(30)
    );

    //Act
    Test.startTest();
    Boolean greaterThan = service.evaluateFilter(opp, 'Amount > 40000');
    Boolean greaterThanFalse = service.evaluateFilter(opp, 'Amount > 60000');
    Boolean lessThan = service.evaluateFilter(opp, 'Amount < 60000');
    Boolean lessThanFalse = service.evaluateFilter(opp, 'Amount < 40000');
    Boolean greaterOrEqual = service.evaluateFilter(opp, 'Amount >= 50000');
    Boolean lessOrEqual = service.evaluateFilter(opp, 'Amount <= 50000');
    Test.stopTest();

    //Assert
    Assert.isTrue(greaterThan, 'Filter Amount > 40000 should match');
    Assert.isFalse(greaterThanFalse, 'Filter Amount > 60000 should not match');
    Assert.isTrue(lessThan, 'Filter Amount < 60000 should match');
    Assert.isFalse(lessThanFalse, 'Filter Amount < 40000 should not match');
    Assert.isTrue(greaterOrEqual, 'Filter Amount >= 50000 should match');
    Assert.isTrue(lessOrEqual, 'Filter Amount <= 50000 should match');
  }

  /*********************************************************************************************************
   * @description Tests evaluateFilter with blank filter returns true
   *********************************************************************************************************/
  @IsTest
  private static void test_evaluateFilter_blankFilter_returnsTrue() {
    //Arrange
    UMP_FilterEvaluator_Srv service = UMP_FilterEvaluator_Srv.getNewInstance();
    Opportunity opp = new Opportunity(Name = 'Test');

    //Act
    Test.startTest();
    Boolean resultNull = service.evaluateFilter(opp, null);
    Boolean resultEmpty = service.evaluateFilter(opp, '');
    Boolean resultBlank = service.evaluateFilter(opp, '   ');
    Test.stopTest();

    //Assert
    Assert.isTrue(resultNull, 'Null filter should return true');
    Assert.isTrue(resultEmpty, 'Empty filter should return true');
    Assert.isTrue(resultBlank, 'Blank filter should return true');
  }

  /*********************************************************************************************************
   * @description Tests evaluateFilter with invalid field returns true
   *********************************************************************************************************/
  @IsTest
  private static void test_evaluateFilter_invalidField_returnsTrue() {
    //Arrange
    UMP_FilterEvaluator_Srv service = UMP_FilterEvaluator_Srv.getNewInstance();
    Opportunity opp = new Opportunity(Name = 'Test');

    //Act
    Test.startTest();
    Boolean result = service.evaluateFilter(opp, 'InvalidField__c = test');
    Test.stopTest();

    //Assert
    Assert.isTrue(
      result,
      'Invalid field should return true (graceful handling)'
    );
  }

  /*********************************************************************************************************
   * @description Tests parseFilterValue with various value types
   *********************************************************************************************************/
  @IsTest
  private static void test_parseFilterValue_variousTypes_returnsCorrectType() {
    //Arrange
    UMP_FilterEvaluator_Srv service = UMP_FilterEvaluator_Srv.getNewInstance();

    //Act
    Test.startTest();
    Object boolTrue = service.parseFilterValue('true');
    Object boolFalse = service.parseFilterValue('false');
    Object nullValue = service.parseFilterValue('null');
    Object quotedString = service.parseFilterValue('\'test value\'');
    Object doubleQuoted = service.parseFilterValue('"test value"');
    Object plainString = service.parseFilterValue('plaintext');
    Object blankValue = service.parseFilterValue('');
    Test.stopTest();

    //Assert
    Assert.areEqual(true, boolTrue, 'Should parse true as Boolean');
    Assert.areEqual(false, boolFalse, 'Should parse false as Boolean');
    Assert.isNull(nullValue, 'Should parse null as null');
    Assert.areEqual('test value', quotedString, 'Should strip single quotes');
    Assert.areEqual('test value', doubleQuoted, 'Should strip double quotes');
    Assert.areEqual(
      'plaintext',
      plainString,
      'Should return plain string as-is'
    );
    Assert.isNull(blankValue, 'Should return null for blank');
  }

  /*********************************************************************************************************
   * @description Tests compareValues with various types
   *********************************************************************************************************/
  @IsTest
  private static void test_compareValues_variousTypes_returnsCorrectComparison() {
    //Arrange
    UMP_FilterEvaluator_Srv service = UMP_FilterEvaluator_Srv.getNewInstance();

    //Act
    Test.startTest();
    //Null comparisons
    Integer bothNull = service.compareValues(null, null);
    Integer actualNull = service.compareValues(null, 'test');
    Integer expectedNull = service.compareValues('test', null);

    //Boolean comparisons
    Integer boolEqual = service.compareValues(true, true);
    Integer boolNotEqual = service.compareValues(true, false);
    Integer boolWithString = service.compareValues(true, 'true');

    //Numeric comparisons
    Integer numEqual = service.compareValues(100, 100);
    Integer numGreater = service.compareValues(200, 100);
    Integer numLess = service.compareValues(50, 100);
    Integer numWithString = service.compareValues(100, '100');

    //String comparisons
    Integer strEqual = service.compareValues('abc', 'abc');
    Integer strGreater = service.compareValues('xyz', 'abc');
    Integer strLess = service.compareValues('abc', 'xyz');
    Test.stopTest();

    //Assert
    Assert.areEqual(0, bothNull, 'Both null should be equal');
    Assert.areEqual(-1, actualNull, 'Null actual should be less');
    Assert.areEqual(1, expectedNull, 'Null expected should be greater');

    Assert.areEqual(0, boolEqual, 'Same booleans should be equal');
    Assert.areEqual(1, boolNotEqual, 'true > false');
    Assert.areEqual(0, boolWithString, 'Boolean should match string true');

    Assert.areEqual(0, numEqual, 'Same numbers should be equal');
    Assert.areEqual(1, numGreater, '200 > 100');
    Assert.areEqual(-1, numLess, '50 < 100');
    Assert.areEqual(0, numWithString, 'Number should match string number');

    Assert.areEqual(0, strEqual, 'Same strings should be equal');
    Assert.isTrue(strGreater > 0, 'xyz > abc');
    Assert.isTrue(strLess < 0, 'abc < xyz');
  }

  /*********************************************************************************************************
   * @description Tests extractFieldsFromFilter with various expressions
   *********************************************************************************************************/
  @IsTest
  private static void test_extractFieldsFromFilter_variousExpressions_returnsFields() {
    //Arrange
    UMP_FilterEvaluator_Srv service = UMP_FilterEvaluator_Srv.getNewInstance();

    //Act
    Test.startTest();
    Set<String> equalityField = service.extractFieldsFromFilter(
      'StageName = Closed Won'
    );
    Set<String> inequalityField = service.extractFieldsFromFilter(
      'Status != Open'
    );
    Set<String> greaterThanField = service.extractFieldsFromFilter(
      'Amount > 50000'
    );
    Set<String> greaterOrEqualField = service.extractFieldsFromFilter(
      'Amount >= 50000'
    );
    Set<String> lessThanField = service.extractFieldsFromFilter('Count < 10');
    Set<String> lessOrEqualField = service.extractFieldsFromFilter(
      'Count <= 10'
    );
    Set<String> emptyFilter = service.extractFieldsFromFilter('');
    Set<String> nullFilter = service.extractFieldsFromFilter(null);
    Test.stopTest();

    //Assert
    Assert.isTrue(
      equalityField.contains('StageName'),
      'Should extract StageName field'
    );
    Assert.isTrue(
      inequalityField.contains('Status'),
      'Should extract Status field'
    );
    Assert.isTrue(
      greaterThanField.contains('Amount'),
      'Should extract Amount field'
    );
    Assert.isTrue(
      greaterOrEqualField.contains('Amount'),
      'Should extract Amount field from >='
    );
    Assert.isTrue(
      lessThanField.contains('Count'),
      'Should extract Count field'
    );
    Assert.isTrue(
      lessOrEqualField.contains('Count'),
      'Should extract Count field from <='
    );
    Assert.isTrue(
      emptyFilter.isEmpty(),
      'Empty filter should return empty set'
    );
    Assert.isTrue(nullFilter.isEmpty(), 'Null filter should return empty set');
  }

  /*********************************************************************************************************
   * @description Tests isValidFieldName with various inputs
   *********************************************************************************************************/
  @IsTest
  private static void test_isValidFieldName_variousInputs_returnsCorrectResult() {
    //Arrange
    UMP_FilterEvaluator_Srv service = UMP_FilterEvaluator_Srv.getNewInstance();

    //Act
    Test.startTest();
    Boolean validSimple = service.isValidFieldName('Name');
    Boolean validWithUnderscore = service.isValidFieldName('Custom_Field__c');
    Boolean validWithNumbers = service.isValidFieldName('Field123');
    Boolean invalidStartsWithNumber = service.isValidFieldName('123Field');
    Boolean invalidWithSpaces = service.isValidFieldName('Field Name');
    Boolean invalidEmpty = service.isValidFieldName('');
    Boolean invalidNull = service.isValidFieldName(null);
    Boolean invalidSpecialChars = service.isValidFieldName('Field@Name');
    Test.stopTest();

    //Assert
    Assert.isTrue(validSimple, 'Simple field name should be valid');
    Assert.isTrue(validWithUnderscore, 'Field with underscore should be valid');
    Assert.isTrue(validWithNumbers, 'Field with numbers should be valid');
    Assert.isFalse(
      invalidStartsWithNumber,
      'Field starting with number should be invalid'
    );
    Assert.isFalse(invalidWithSpaces, 'Field with spaces should be invalid');
    Assert.isFalse(invalidEmpty, 'Empty field name should be invalid');
    Assert.isFalse(invalidNull, 'Null field name should be invalid');
    Assert.isFalse(
      invalidSpecialChars,
      'Field with special chars should be invalid'
    );
  }

  /*********************************************************************************************************
   * @description Tests getNewInstance returns valid instance
   *********************************************************************************************************/
  @IsTest
  private static void test_getNewInstance_returnsValidInstance() {
    //Act
    Test.startTest();
    UMP_FilterEvaluator_Srv service = UMP_FilterEvaluator_Srv.getNewInstance();
    Test.stopTest();

    //Assert
    Assert.isNotNull(service, 'Service instance should not be null');
  }

  /*********************************************************************************************************
   * @description Tests bulk filter evaluation
   *********************************************************************************************************/
  @IsTest
  private static void test_evaluateFilter_bulkRecords_handlesCorrectly() {
    //Arrange
    UMP_FilterEvaluator_Srv service = UMP_FilterEvaluator_Srv.getNewInstance();
    List<Opportunity> opportunities = new List<Opportunity>();
    for (Integer i = 0; i < 200; i++) {
      opportunities.add(
        new Opportunity(
          Name = 'Test Opp ' + i,
          StageName = Math.mod(i, 2) == 0 ? 'Prospecting' : 'Closed Won',
          Amount = i * 1000,
          CloseDate = Date.today().addDays(30)
        )
      );
    }

    //Act
    Test.startTest();
    Integer matchCount = 0;
    for (Opportunity opp : opportunities) {
      if (service.evaluateFilter(opp, 'StageName = Prospecting')) {
        matchCount++;
      }
    }
    Test.stopTest();

    //Assert
    Assert.areEqual(
      100,
      matchCount,
      'Should match 100 records with Prospecting stage'
    );
  }
}
