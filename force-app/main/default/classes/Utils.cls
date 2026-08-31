/**
 * @description Utils classes that include a varity of random methods for PP portal!!!!
 * @author David Browaeys
 * @group Utils
 */
public inherited sharing class Utils {
  /**
   * @description create a new completed task to audit SMS notification
   *
   * @param participant (Account): participant to create the task against
   * @param message (String): message sent by SMS for bank account update
   * @param subject (String): subject for the tack
   *
   * @return Task: New instance of a class for the SMS notification
   */
  public static Task createSMSTask(
    Contact participant,
    String message,
    String subject
  ) {
    return new Task(
      WhoId = participant.Id,
      WhatId = participant.AccountId,
      ActivityDate = Date.today(),
      Subject = subject,
      Description = message,
      Type = 'SMS',
      Status = 'Completed'
    );
  }

  /**
   * @description create a new completed task to audit SMS notification
   *
   * @param participant (Account): participant to create the task against
   * @param message (String): message sent by SMS for bank account update
   *
   * @return Task: New instance of a class for the SMS notification
   */
  public static Task createSMSTask(Contact participant, String message) {
    return createSMSTask(participant, message, 'MyTask');
  }
  /**
   * @description Generate a random password of any size.
   *
   * @param len (Integer): Length of the password
   *
   * @return String: Random alphanumeric password
   *
   * @example PPUtils.generatePassword(10);
   */
  public static String generatePassword(Integer len) {
    return EncodingUtil.convertToHex(Crypto.generateAesKey(128))
      .substring(0, len);
  }
  /**
   * @description Create user from participant account information
   *
   * @param account (Account): Participant who want to register to portal
   *
   * @return User: New instance of User
   */
  public static User createParticipantUser(Contact account) {
    User u = new user();
    u.FirstName = account.FirstName;
    u.LastName = account.LastName;
    u.Email = account.Email;
    u.Alias = account.Email.substring(0, 8);
    u.MobilePhone = account.MobilePhone;
    u.CommunityNickname = 'User' + generatePassword(8);
    u.ContactId = account.Id;
    u.Username = account.Email;
    u.LocaleSidKey = 'en_AU';
    u.TimeZoneSidKey = 'Australia/Sydney';
    u.LanguageLocaleKey = 'en_US';
    u.EmailEncodingKey = 'UTF-8';
    u.IsActive = true;
    return u;
  }
  public static String scrambleEmail(String plainEmail) {
    if (plainEmail == null) {
      return null;
    }
    String emailDomain = plainEmail.substring(plainEmail.indexOf('@') + 1);
    return plainEmail.substring(0, 3) +
      '****@' +
      emailDomain.substring(0, 1) +
      '****' +
      emailDomain.substring(emailDomain.indexOf('.'));
  }
  public static String scramblePhone(String plainPhone) {
    if (plainPhone == null) {
      return null;
    }
    return '*' + plainPhone.substring(plainPhone.length() - 4);
  }
}

