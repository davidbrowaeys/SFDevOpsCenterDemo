// Create test Case records for Account 001gL00000Uioe9QAB
String accountId = '001gL00000Uioe9QAB';

List<Case> cases = new List<Case>();

// This Quarter - Open Cases (various priorities)
cases.add(
  new Case(
    AccountId = accountId,
    Subject = 'Login Issue - Critical',
    Priority = 'High',
    Status = 'New',
    Origin = 'Web'
  )
);
cases.add(
  new Case(
    AccountId = accountId,
    Subject = 'Password Reset Request',
    Priority = 'High',
    Status = 'Working',
    Origin = 'Phone'
  )
);
cases.add(
  new Case(
    AccountId = accountId,
    Subject = 'Feature Request - Dashboard',
    Priority = 'Medium',
    Status = 'New',
    Origin = 'Email'
  )
);
cases.add(
  new Case(
    AccountId = accountId,
    Subject = 'Report Export Issue',
    Priority = 'Medium',
    Status = 'Working',
    Origin = 'Web'
  )
);
cases.add(
  new Case(
    AccountId = accountId,
    Subject = 'UI Enhancement Request',
    Priority = 'Medium',
    Status = 'New',
    Origin = 'Phone'
  )
);
cases.add(
  new Case(
    AccountId = accountId,
    Subject = 'Documentation Question',
    Priority = 'Low',
    Status = 'New',
    Origin = 'Email'
  )
);
cases.add(
  new Case(
    AccountId = accountId,
    Subject = 'Training Request',
    Priority = 'Low',
    Status = 'Working',
    Origin = 'Web'
  )
);

// This Quarter - Closed Cases
cases.add(
  new Case(
    AccountId = accountId,
    Subject = 'Billing Inquiry - Resolved',
    Priority = 'High',
    Status = 'Closed',
    Origin = 'Phone'
  )
);
cases.add(
  new Case(
    AccountId = accountId,
    Subject = 'Integration Error - Fixed',
    Priority = 'High',
    Status = 'Closed',
    Origin = 'Email'
  )
);
cases.add(
  new Case(
    AccountId = accountId,
    Subject = 'Performance Issue - Resolved',
    Priority = 'Medium',
    Status = 'Closed',
    Origin = 'Web'
  )
);
cases.add(
  new Case(
    AccountId = accountId,
    Subject = 'Data Import Help - Completed',
    Priority = 'Medium',
    Status = 'Closed',
    Origin = 'Phone'
  )
);
cases.add(
  new Case(
    AccountId = accountId,
    Subject = 'General Question - Answered',
    Priority = 'Low',
    Status = 'Closed',
    Origin = 'Email'
  )
);
cases.add(
  new Case(
    AccountId = accountId,
    Subject = 'Setup Assistance - Done',
    Priority = 'Low',
    Status = 'Closed',
    Origin = 'Web'
  )
);

insert cases;

System.debug(
  'Created ' + cases.size() + ' Case records for Account ' + accountId
);
System.debug('Open Cases: 7, Closed Cases: 6');
System.debug('High Priority: 4, Medium Priority: 5, Low Priority: 4');
