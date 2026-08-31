/**
 * @author David Browaeys
 * @date 2026-02-04
 * @description Test class for UMP_MetricPanel_Srv and UMP_MetricPanel_Ctrl
 * @group Universal Metric Panel
 */
@IsTest
private class UMP_MetricPanel_Srv_Test 
{
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Creates test data for all test methods
    *********************************************************************************************************/
    @TestSetup
    static void setup() 
    {
        //Create test Account
        Account testAccount = new Account(
            Name = 'Test Account for Metrics'
        );
        insert testAccount;
        
        //Create test Opportunities with various stages and amounts - bulk insert
        List<Opportunity> opportunities = new List<Opportunity>();
        
        //Open opportunities in different stages
        opportunities.add(new Opportunity(
            Name = 'Opp Prospecting 1',
            AccountId = testAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 50000
        ));
        
        opportunities.add(new Opportunity(
            Name = 'Opp Qualification 1',
            AccountId = testAccount.Id,
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(45),
            Amount = 75000
        ));
        
        opportunities.add(new Opportunity(
            Name = 'Opp Qualification 2',
            AccountId = testAccount.Id,
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(60),
            Amount = 100000
        ));
        
        opportunities.add(new Opportunity(
            Name = 'Opp Negotiation 1',
            AccountId = testAccount.Id,
            StageName = 'Negotiation/Review',
            CloseDate = Date.today().addDays(15),
            Amount = 200000
        ));
        
        //Closed Won opportunity (for win rate calculation)
        opportunities.add(new Opportunity(
            Name = 'Opp Closed Won 1',
            AccountId = testAccount.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today().addDays(-10),
            Amount = 150000
        ));
        
        //Closed Lost opportunity (for win rate calculation)
        opportunities.add(new Opportunity(
            Name = 'Opp Closed Lost 1',
            AccountId = testAccount.Id,
            StageName = 'Closed Lost',
            CloseDate = Date.today().addDays(-5),
            Amount = 80000
        ));
        
        insert opportunities;
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Creates mock config metadata for testing
    * @return           UMP_Metric_Config__mdt: The mock configuration
    *********************************************************************************************************/
    private static UMP_Metric_Config__mdt createMockConfig() 
    {
        UMP_Metric_Config__mdt mockConfig = new UMP_Metric_Config__mdt(
            DeveloperName = 'Account_Opportunities',
            MasterLabel = 'Account Opportunities',
            Parent_Object__c = 'Account',
            Child_Object__c = 'Opportunity',
            Relationship_Field__c = 'AccountId',
            Donut_Group_Field__c = 'StageName',
            Donut_Filter__c = 'IsClosed = false',
            Donut_Title__c = 'Open Opportunities by Stage',
            Chart_Colors__c = '{"Prospecting":"#10B981","Qualification":"#06B6D4"}',
            Active__c = true
        );
        return mockConfig;
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Creates mock metric definitions for testing
    * @return           List<UMP_Metric_Definition__mdt>: The mock definitions
    *********************************************************************************************************/
    private static List<UMP_Metric_Definition__mdt> createMockDefinitions() 
    {
        List<UMP_Metric_Definition__mdt> definitions = new List<UMP_Metric_Definition__mdt>();
        
        //Revenue metric
        definitions.add(new UMP_Metric_Definition__mdt(
            DeveloperName = 'Account_Opps_Revenue',
            MasterLabel = 'Pipeline Revenue',
            Metric_Label__c = 'Pipeline Revenue',
            Aggregation_Type__c = 'SUM',
            Aggregation_Field__c = 'Amount',
            Filter_Criteria__c = 'IsClosed = false',
            Format_Type__c = 'CURRENCY',
            Show_Quarters__c = false,
            Display_Order__c = 1,
            Active__c = true
        ));
        
        //Win Rate metric
        definitions.add(new UMP_Metric_Definition__mdt(
            DeveloperName = 'Account_Opps_WinRate',
            MasterLabel = 'Win Rate',
            Metric_Label__c = 'Win Rate',
            Aggregation_Type__c = 'WIN_RATE',
            Win_Numerator_Filter__c = 'StageName = \'Closed Won\'',
            Win_Denominator_Filter__c = 'IsClosed = true',
            Format_Type__c = 'PERCENT',
            Show_Quarters__c = false,
            Display_Order__c = 2,
            Active__c = true
        ));
        
        return definitions;
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Sets up mocked selectors for custom metadata
    *********************************************************************************************************/
    private static void setupMockedSelectors() 
    {
        //Create mock data
        UMP_Metric_Config__mdt mockConfig = createMockConfig();
        List<UMP_Metric_Definition__mdt> mockDefinitions = createMockDefinitions();
        
        //Mock the config selector
        UMP_MetricConfig_Sel mockConfigSel = (UMP_MetricConfig_Sel) UTT_LightMock.mock(UMP_MetricConfig_Sel.class);
        UTT_LightMock.stubbing(true);
        UTT_LightMock.when(mockConfigSel.selectByDeveloperName('Account_Opportunities')).thenReturn(mockConfig);
        UTT_LightMock.when(mockConfigSel.selectByParentObject('Account')).thenReturn(new List<UMP_Metric_Config__mdt>{ mockConfig });
        UTT_LightMock.when(mockConfigSel.selectByParentObject('Lead')).thenReturn(new List<UMP_Metric_Config__mdt>());
        UTT_LightMock.when(mockConfigSel.selectAllActive()).thenReturn(new List<UMP_Metric_Config__mdt>{ mockConfig });
        UTT_LightMock.stubbing(false);
        TRG_sObjectSelector.setMock(UMP_MetricConfig_Sel.class, mockConfigSel);
        
        //Mock the definition selector
        UMP_MetricDefinition_Sel mockDefSel = (UMP_MetricDefinition_Sel) UTT_LightMock.mock(UMP_MetricDefinition_Sel.class);
        UTT_LightMock.stubbing(true);
        UTT_LightMock.when(mockDefSel.selectByConfigDeveloperName('Account_Opportunities')).thenReturn(mockDefinitions);
        UTT_LightMock.when(mockDefSel.selectAllActive()).thenReturn(mockDefinitions);
        UTT_LightMock.stubbing(false);
        TRG_sObjectSelector.setMock(UMP_MetricDefinition_Sel.class, mockDefSel);
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Test getPanelData with valid configuration - verifies panel data structure
    *********************************************************************************************************/
    @IsTest
    private static void test_getPanelData_validConfig_returnsPanelData() 
    {
        //Arrange
        Account testAccount = [SELECT Id, Name FROM Account WHERE Name = 'Test Account for Metrics' LIMIT 1];
        setupMockedSelectors();
        
        //Act
        Test.startTest();
        UMP_MetricPanel_Srv.PanelData result = UMP_MetricPanel_Srv.getNewInstance(
            testAccount.Id, 
            'Account_Opportunities'
        ).getPanelData();
        Test.stopTest();
        
        //Assert
        Assert.isNotNull(result, 'PanelData should not be null');
        Assert.areEqual(testAccount.Name, result.parentName, 'Parent name should match account name');
        Assert.areEqual('Opportunity', result.childObjectApiName, 'Child object should be Opportunity');
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Test getPanelData returns correct donut segments - verifies grouping by stage
    *********************************************************************************************************/
    @IsTest
    private static void test_getPanelData_validConfig_returnsDonutSegments() 
    {
        //Arrange
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account for Metrics' LIMIT 1];
        setupMockedSelectors();
        
        //Act
        Test.startTest();
        UMP_MetricPanel_Srv.PanelData result = UMP_MetricPanel_Srv.getNewInstance(
            testAccount.Id, 
            'Account_Opportunities'
        ).getPanelData();
        Test.stopTest();
        
        //Assert
        Assert.isNotNull(result.donutSegments, 'Donut segments should not be null');
        //We created 4 open opportunities (IsClosed = false)
        Integer totalOpenOpps = 0;
        for (UMP_MetricPanel_Srv.DonutSegment segment : result.donutSegments) 
        {
            totalOpenOpps += segment.count;
        }
        Assert.areEqual(4, totalOpenOpps, 'Should have 4 open opportunities in donut');
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Test getPanelData returns metrics - verifies metrics are calculated
    *********************************************************************************************************/
    @IsTest
    private static void test_getPanelData_validConfig_returnsMetrics() 
    {
        //Arrange
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account for Metrics' LIMIT 1];
        setupMockedSelectors();
        
        //Act
        Test.startTest();
        UMP_MetricPanel_Srv.PanelData result = UMP_MetricPanel_Srv.getNewInstance(
            testAccount.Id, 
            'Account_Opportunities'
        ).getPanelData();
        Test.stopTest();
        
        //Assert
        Assert.isNotNull(result.metrics, 'Metrics should not be null');
        //We have 2 metric definitions: Revenue and Win Rate
        Assert.areEqual(2, result.metrics.size(), 'Should have 2 metrics configured');
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Test getPanelData with invalid config - verifies exception is thrown
    *********************************************************************************************************/
    @IsTest
    private static void test_getPanelData_invalidConfig_throwsException() 
    {
        //Arrange
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account for Metrics' LIMIT 1];
        
        //Mock selector to return null for invalid config
        UMP_MetricConfig_Sel mockConfigSel = (UMP_MetricConfig_Sel) UTT_LightMock.mock(UMP_MetricConfig_Sel.class);
        UTT_LightMock.stubbing(true);
        UTT_LightMock.when(mockConfigSel.selectByDeveloperName('NonExistent_Config')).thenReturn(null);
        UTT_LightMock.stubbing(false);
        TRG_sObjectSelector.setMock(UMP_MetricConfig_Sel.class, mockConfigSel);
        
        Boolean exceptionThrown = false;
        String exceptionMessage = '';
        
        //Act
        Test.startTest();
        try 
        {
            UMP_MetricPanel_Srv.getNewInstance(testAccount.Id, 'NonExistent_Config').getPanelData();
        } 
        catch (Exception e) 
        {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        
        //Assert
        Assert.isTrue(exceptionThrown, 'Exception should be thrown for invalid config');
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Test Controller getPanelData method - verifies controller delegates to service
    *********************************************************************************************************/
    @IsTest
    private static void test_controller_getPanelData_returnsPanelData() 
    {
        //Arrange
        Account testAccount = [SELECT Id, Name FROM Account WHERE Name = 'Test Account for Metrics' LIMIT 1];
        setupMockedSelectors();
        
        //Act
        Test.startTest();
        UMP_MetricPanel_Srv.PanelData result = UMP_MetricPanel_Ctrl.getPanelData(
            testAccount.Id, 
            'Account_Opportunities'
        );
        Test.stopTest();
        
        //Assert
        Assert.isNotNull(result, 'Controller should return PanelData');
        Assert.areEqual(testAccount.Name, result.parentName, 'Parent name should match');
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Test Controller getAvailableConfigs method - verifies configs are returned
    *********************************************************************************************************/
    @IsTest
    private static void test_controller_getAvailableConfigs_returnsConfigs() 
    {
        //Arrange
        setupMockedSelectors();
        
        //Act
        Test.startTest();
        List<UMP_MetricPanel_Ctrl.ConfigOption> result = UMP_MetricPanel_Ctrl.getAvailableConfigs('Account');
        Test.stopTest();
        
        //Assert
        Assert.isNotNull(result, 'Config options should not be null');
        Assert.isTrue(result.size() > 0, 'Should have at least one config for Account');
        
        //Verify the Account_Opportunities config is in the list
        Boolean foundConfig = false;
        for (UMP_MetricPanel_Ctrl.ConfigOption opt : result) 
        {
            if (opt.value == 'Account_Opportunities') 
            {
                foundConfig = true;
                break;
            }
        }
        Assert.isTrue(foundConfig, 'Account_Opportunities config should be in the list');
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Test Controller getAvailableConfigs with no matching configs - verifies empty list
    *********************************************************************************************************/
    @IsTest
    private static void test_controller_getAvailableConfigs_noConfigs_returnsEmpty() 
    {
        //Arrange
        setupMockedSelectors();
        
        //Act
        Test.startTest();
        List<UMP_MetricPanel_Ctrl.ConfigOption> result = UMP_MetricPanel_Ctrl.getAvailableConfigs('Lead');
        Test.stopTest();
        
        //Assert
        Assert.isNotNull(result, 'Config options should not be null');
        Assert.areEqual(0, result.size(), 'Should have no configs for Lead');
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Test Selector selectAllActive method - verifies active configs are returned
    *********************************************************************************************************/
    @IsTest
    private static void test_selector_selectAllActive_returnsActiveConfigs() 
    {
        //Arrange
        setupMockedSelectors();
        
        //Act
        Test.startTest();
        List<UMP_Metric_Config__mdt> result = UMP_MetricConfig_Sel.getNewInstance().selectAllActive();
        Test.stopTest();
        
        //Assert
        Assert.isNotNull(result, 'Result should not be null');
        Assert.isTrue(result.size() > 0, 'Should have at least one active config');
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Test Selector selectByDeveloperName method - verifies config is returned by name
    *********************************************************************************************************/
    @IsTest
    private static void test_selector_selectByDeveloperName_returnsConfig() 
    {
        //Arrange
        setupMockedSelectors();
        
        //Act
        Test.startTest();
        UMP_Metric_Config__mdt result = UMP_MetricConfig_Sel.getNewInstance().selectByDeveloperName('Account_Opportunities');
        Test.stopTest();
        
        //Assert
        Assert.isNotNull(result, 'Config should be found');
        Assert.areEqual('Account', result.Parent_Object__c, 'Parent object should be Account');
        Assert.areEqual('Opportunity', result.Child_Object__c, 'Child object should be Opportunity');
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Test Definition Selector selectByConfigDeveloperName - verifies definitions returned
    *********************************************************************************************************/
    @IsTest
    private static void test_definitionSelector_selectByConfig_returnsDefinitions() 
    {
        //Arrange
        setupMockedSelectors();
        
        //Act
        Test.startTest();
        List<UMP_Metric_Definition__mdt> result = UMP_MetricDefinition_Sel.getNewInstance().selectByConfigDeveloperName('Account_Opportunities');
        Test.stopTest();
        
        //Assert
        Assert.isNotNull(result, 'Definitions should not be null');
        Assert.areEqual(2, result.size(), 'Should have 2 metric definitions');
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Test bulk scenario with 200+ opportunities - verifies service handles bulk data
    *********************************************************************************************************/
    @IsTest
    private static void test_getPanelData_bulkOpportunities_handlesCorrectly() 
    {
        //Arrange
        Account bulkAccount = new Account(Name = 'Bulk Test Account');
        insert bulkAccount;
        
        //Create 200 opportunities in bulk (single insert)
        List<Opportunity> bulkOpps = new List<Opportunity>();
        for (Integer i = 0; i < 200; i++) 
        {
            bulkOpps.add(new Opportunity(
                Name = 'Bulk Opp ' + i,
                AccountId = bulkAccount.Id,
                StageName = Math.mod(i, 2) == 0 ? 'Prospecting' : 'Qualification',
                CloseDate = Date.today().addDays(30),
                Amount = 10000 + (i * 100)
            ));
        }
        insert bulkOpps;
        
        setupMockedSelectors();
        
        //Act
        Test.startTest();
        UMP_MetricPanel_Srv.PanelData result = UMP_MetricPanel_Srv.getNewInstance(
            bulkAccount.Id, 
            'Account_Opportunities'
        ).getPanelData();
        Test.stopTest();
        
        //Assert
        Assert.isNotNull(result, 'PanelData should not be null for bulk data');
        Assert.areEqual(200, result.totalCount, 'Should count all 200 opportunities');
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Test FilterEvaluator service - verifies filter evaluation works correctly
    *********************************************************************************************************/
    @IsTest
    private static void test_filterEvaluator_evaluateFilter_returnsCorrectResult() 
    {
        //Arrange - Use StageName which is set directly on the record
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            Amount = 50000
        );
        
        UMP_FilterEvaluator_Srv filterEvaluator = UMP_FilterEvaluator_Srv.getNewInstance();
        
        //Act
        Test.startTest();
        //Test with StageName which is directly set on the record
        Boolean resultStageMatch = filterEvaluator.evaluateFilter(testOpp, 'StageName = Prospecting');
        Boolean resultStageNoMatch = filterEvaluator.evaluateFilter(testOpp, 'StageName = Closed Won');
        Boolean resultEmpty = filterEvaluator.evaluateFilter(testOpp, '');
        Boolean resultNull = filterEvaluator.evaluateFilter(testOpp, null);
        //Test with Amount
        Boolean resultAmountMatch = filterEvaluator.evaluateFilter(testOpp, 'Amount = 50000');
        Test.stopTest();
        
        //Assert
        Assert.isTrue(resultStageMatch, 'Filter StageName = Prospecting should match');
        Assert.isFalse(resultStageNoMatch, 'Filter StageName = Closed Won should not match');
        Assert.isTrue(resultEmpty, 'Empty filter should return true');
        Assert.isTrue(resultNull, 'Null filter should return true');
        Assert.isTrue(resultAmountMatch, 'Filter Amount = 50000 should match');
    }
    
    /*********************************************************************************************************
    * @author           David Browaeys
    * @date             2026-02-04
    * @description      Test FilterEvaluator extractFieldsFromFilter - verifies field extraction
    *********************************************************************************************************/
    @IsTest
    private static void test_filterEvaluator_extractFieldsFromFilter_returnsFields() 
    {
        //Arrange
        UMP_FilterEvaluator_Srv filterEvaluator = UMP_FilterEvaluator_Srv.getNewInstance();
        
        //Act
        Test.startTest();
        Set<String> fields1 = filterEvaluator.extractFieldsFromFilter('IsClosed = true');
        Set<String> fields2 = filterEvaluator.extractFieldsFromFilter('Amount >= 50000');
        Set<String> fieldsEmpty = filterEvaluator.extractFieldsFromFilter('');
        Test.stopTest();
        
        //Assert
        Assert.isTrue(fields1.contains('IsClosed'), 'Should extract IsClosed field');
        Assert.isTrue(fields2.contains('Amount'), 'Should extract Amount field');
        Assert.areEqual(0, fieldsEmpty.size(), 'Empty filter should return empty set');
    }
}
