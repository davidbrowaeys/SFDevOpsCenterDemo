/**
 * @description Test class for Utils!
 *
 * @author David Browaeys
 * @group Tests
 */
@isTest(isParallel=true)
public with sharing class UtilsTest {
  @isTest
  static void testCreateSMSTask() {
    Task result = Utils.createSMSTask(
      new Contact(),
      'Bank account was updated successfully'
    );
    System.assert(result.Type == 'SMS', 'Task type is correct');
  }
  @isTest
  static void testGeneratePassword() {
    String result = Utils.generatePassword(10);
    System.assert(
      result != null && result.length() == 10,
      'Generate password of 10 chaarcters'
    );
  }
  @isTest
  static void testCreateParticipantUser() {
    User result = Utils.createParticipantUser(
      new Contact(
        FirstName = 'John',
        LastName = 'Doe',
        Email = 'johndoe@test.com'
      )
    );
    System.assert(result.LocaleSidKey == 'en_AU', 'Local langage set to en_AU');
  }
  @isTest
  static void testScrambleEmail() {
    String plainEmail = 'john@gmail.com';
    System.assertEquals(
      Utils.scrambleEmail(plainEmail),
      'joh****@g****.com',
      'Srambled Email'
    );
  }
  @isTest
  static void testScramblePhone() {
    String plainPhone = '0123456789';
    System.assertEquals(
      Utils.scramblePhone(plainPhone),
      '*6789',
      'Scramble Phone'
    );
  }
}
