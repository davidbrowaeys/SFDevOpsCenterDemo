/**
 * @author David Browaeys
 * @date 2026-02-09
 * @description Test class for UMP_DynamicQuery_Srv
 * @group Universal Metric Panel
 */
@IsTest
private class UMP_DynamicQuery_Srv_Test {
  /*********************************************************************************************************
   * @description Test data setup
   *********************************************************************************************************/
  @TestSetup
  private static void setup() {
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;

    List<Opportunity> opportunities = new List<Opportunity>();
    for (Integer i = 0; i < 5; i++) {
      opportunities.add(
        new Opportunity(
          Name = 'Test Opp ' + i,
          AccountId = testAccount.Id,
          StageName = 'Prospecting',
          Amount = (i + 1) * 10000,
          CloseDate = Date.today().addDays(30)
        )
      );
    }
    insert opportunities;
  }

  /*********************************************************************************************************
   * @description Tests getNewInstance returns valid instance
   *********************************************************************************************************/
  @IsTest
  private static void test_getNewInstance_returnsValidInstance() {
    //Act
    Test.startTest();
    UMP_DynamicQuery_Srv service = UMP_DynamicQuery_Srv.getNewInstance(
      'Account'
    );
    Test.stopTest();

    //Assert
    Assert.isNotNull(service, 'Service instance should not be null');
  }

  /*********************************************************************************************************
   * @description Tests addField adds single field
   *********************************************************************************************************/
  @IsTest
  private static void test_addField_singleField_addsToQuery() {
    //Arrange
    UMP_DynamicQuery_Srv service = UMP_DynamicQuery_Srv.getNewInstance(
      'Account'
    );

    //Act
    Test.startTest();
    service.addField('Name');
    Set<String> fields = service.getFieldsToQuery();
    Test.stopTest();

    //Assert
    Assert.isTrue(fields.contains('Name'), 'Should contain Name field');
    Assert.isTrue(fields.contains('Id'), 'Should always contain Id field');
  }

  /*********************************************************************************************************
   * @description Tests addField with blank field is ignored
   *********************************************************************************************************/
  @IsTest
  private static void test_addField_blankField_isIgnored() {
    //Arrange
    UMP_DynamicQuery_Srv service = UMP_DynamicQuery_Srv.getNewInstance(
      'Account'
    );

    //Act
    Test.startTest();
    service.addField('');
    service.addField(null);
    service.addField('   ');
    Set<String> fields = service.getFieldsToQuery();
    Test.stopTest();

    //Assert
    Assert.areEqual(1, fields.size(), 'Should only contain Id field');
    Assert.isTrue(fields.contains('Id'), 'Should contain Id field');
  }

  /*********************************************************************************************************
   * @description Tests addFields adds multiple fields
   *********************************************************************************************************/
  @IsTest
  private static void test_addFields_multipleFields_addsAllToQuery() {
    //Arrange
    UMP_DynamicQuery_Srv service = UMP_DynamicQuery_Srv.getNewInstance(
      'Account'
    );
    Set<String> fieldsToAdd = new Set<String>{ 'Name', 'Industry', 'Type' };

    //Act
    Test.startTest();
    service.addFields(fieldsToAdd);
    Set<String> fields = service.getFieldsToQuery();
    Test.stopTest();

    //Assert
    Assert.isTrue(fields.contains('Name'), 'Should contain Name field');
    Assert.isTrue(fields.contains('Industry'), 'Should contain Industry field');
    Assert.isTrue(fields.contains('Type'), 'Should contain Type field');
    Assert.isTrue(fields.contains('Id'), 'Should contain Id field');
  }

  /*********************************************************************************************************
   * @description Tests addFields with null set is handled
   *********************************************************************************************************/
  @IsTest
  private static void test_addFields_nullSet_isHandled() {
    //Arrange
    UMP_DynamicQuery_Srv service = UMP_DynamicQuery_Srv.getNewInstance(
      'Account'
    );

    //Act
    Test.startTest();
    service.addFields(null);
    Set<String> fields = service.getFieldsToQuery();
    Test.stopTest();

    //Assert
    Assert.areEqual(1, fields.size(), 'Should only contain Id field');
  }

  /*********************************************************************************************************
   * @description Tests filterByLookup sets filter correctly
   *********************************************************************************************************/
  @IsTest
  private static void test_filterByLookup_setsFilterCorrectly() {
    //Arrange
    Account testAccount = [SELECT Id FROM Account LIMIT 1];
    UMP_DynamicQuery_Srv service = UMP_DynamicQuery_Srv.getNewInstance(
      'Opportunity'
    );

    //Act
    Test.startTest();
    service.addField('Name')
      .addField('Amount')
      .addField('AccountId')
      .filterByLookup('AccountId', testAccount.Id);
    List<SObject> results = service.execute();
    Test.stopTest();

    //Assert
    Assert.areEqual(5, results.size(), 'Should return 5 opportunities');
    for (SObject record : results) {
      Opportunity opp = (Opportunity) record;
      Assert.areEqual(
        testAccount.Id,
        opp.AccountId,
        'All opportunities should belong to test account'
      );
    }
  }

  /*********************************************************************************************************
   * @description Tests setLimit limits results
   *********************************************************************************************************/
  @IsTest
  private static void test_setLimit_limitsResults() {
    //Arrange
    Account testAccount = [SELECT Id FROM Account LIMIT 1];
    UMP_DynamicQuery_Srv service = UMP_DynamicQuery_Srv.getNewInstance(
      'Opportunity'
    );

    //Act
    Test.startTest();
    service.addField('Name')
      .filterByLookup('AccountId', testAccount.Id)
      .setLimit(2);
    List<SObject> results = service.execute();
    Test.stopTest();

    //Assert
    Assert.areEqual(2, results.size(), 'Should return only 2 opportunities');
  }

  /*********************************************************************************************************
   * @description Tests execute without filter returns all records
   *********************************************************************************************************/
  @IsTest
  private static void test_execute_withoutFilter_returnsAllRecords() {
    //Arrange
    UMP_DynamicQuery_Srv service = UMP_DynamicQuery_Srv.getNewInstance(
      'Account'
    );

    //Act
    Test.startTest();
    service.addField('Name');
    List<SObject> results = service.execute();
    Test.stopTest();

    //Assert
    Assert.areEqual(1, results.size(), 'Should return 1 account');
  }

  /*********************************************************************************************************
   * @description Tests execute validates fields
   *********************************************************************************************************/
  @IsTest
  private static void test_execute_invalidFields_areFiltered() {
    //Arrange
    Account testAccount = [SELECT Id FROM Account LIMIT 1];
    UMP_DynamicQuery_Srv service = UMP_DynamicQuery_Srv.getNewInstance(
      'Opportunity'
    );

    //Act
    Test.startTest();
    service.addField('Name')
      .addField('InvalidField__c')
      .addField('Amount')
      .filterByLookup('AccountId', testAccount.Id);
    List<SObject> results = service.execute();
    Test.stopTest();

    //Assert
    Assert.areEqual(
      5,
      results.size(),
      'Should return 5 opportunities despite invalid field'
    );
  }

  /*********************************************************************************************************
   * @description Tests fluent API chaining
   *********************************************************************************************************/
  @IsTest
  private static void test_fluentApi_chainingWorks() {
    //Arrange
    Account testAccount = [SELECT Id FROM Account LIMIT 1];

    //Act
    Test.startTest();
    List<SObject> results = UMP_DynamicQuery_Srv.getNewInstance('Opportunity')
      .addField('Name')
      .addField('Amount')
      .addField('StageName')
      .filterByLookup('AccountId', testAccount.Id)
      .setLimit(3)
      .execute();
    Test.stopTest();

    //Assert
    Assert.areEqual(3, results.size(), 'Should return 3 opportunities');
  }

  /*********************************************************************************************************
   * @description Tests getFieldsToQuery returns current fields
   *********************************************************************************************************/
  @IsTest
  private static void test_getFieldsToQuery_returnsCurrentFields() {
    //Arrange
    UMP_DynamicQuery_Srv service = UMP_DynamicQuery_Srv.getNewInstance(
      'Account'
    );

    //Act
    Test.startTest();
    Set<String> initialFields = service.getFieldsToQuery();
    Integer initialCount = initialFields.size();
    service.addField('Name').addField('Industry');
    Set<String> updatedFields = service.getFieldsToQuery();
    Test.stopTest();

    //Assert
    Assert.isTrue(initialFields.contains('Id'), 'Initial should contain Id');
    Assert.isTrue(updatedFields.contains('Id'), 'Updated should contain Id');
    Assert.isTrue(
      updatedFields.contains('Name'),
      'Updated should contain Name'
    );
    Assert.isTrue(
      updatedFields.contains('Industry'),
      'Updated should contain Industry'
    );
    Assert.areEqual(
      initialCount + 2,
      updatedFields.size(),
      'Updated should have 2 more fields than initial'
    );
  }

  /*********************************************************************************************************
   * @description Tests bulk query execution
   *********************************************************************************************************/
  @IsTest
  private static void test_execute_bulkRecords_handlesCorrectly() {
    //Arrange - Create more test data
    Account testAccount = [SELECT Id FROM Account LIMIT 1];
    List<Opportunity> moreOpps = new List<Opportunity>();
    for (Integer i = 0; i < 195; i++) {
      moreOpps.add(
        new Opportunity(
          Name = 'Bulk Opp ' + i,
          AccountId = testAccount.Id,
          StageName = 'Prospecting',
          Amount = 1000,
          CloseDate = Date.today().addDays(30)
        )
      );
    }
    insert moreOpps;

    //Act
    Test.startTest();
    List<SObject> results = UMP_DynamicQuery_Srv.getNewInstance('Opportunity')
      .addField('Name')
      .filterByLookup('AccountId', testAccount.Id)
      .execute();
    Test.stopTest();

    //Assert
    Assert.areEqual(200, results.size(), 'Should return all 200 opportunities');
  }
}
