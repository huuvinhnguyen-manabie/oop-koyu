@isTest
private class InquiryUsernameResolverTest {
    @isTest
    static void test_resolveUniqueUsername_noConflict_usernameUnchanged() {
        String originalUsername = 'unique.user@example.com';
        Contact parentContact = new Contact(
            LastName = 'Test',
            MANAERP__Username__c = originalUsername
        );

        Test.startTest();
        InquiryUsernameResolver.resolveUniqueUsername(parentContact);
        Test.stopTest();

        Assert.areEqual(
            originalUsername,
            parentContact.MANAERP__Username__c,
            'Username should remain unchanged when no conflict exists'
        );
    }

    @isTest
    static void test_resolveUniqueUsername_singleDuplicate_appendsPlusOne() {
        String duplicateUsername = 'existing@example.com';
        Id parentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
            .get('Parent')
            .getRecordTypeId();
        insert new Contact(
            FirstName = 'Existing',
            LastName = 'Contact',
            RecordTypeId = parentRecordTypeId,
            Email = duplicateUsername,
            MANAERP__Username__c = duplicateUsername
        );

        Contact parentContact = new Contact(
            LastName = 'New',
            MANAERP__Username__c = duplicateUsername
        );

        Test.startTest();
        InquiryUsernameResolver.resolveUniqueUsername(parentContact);
        Test.stopTest();

        Assert.areEqual(
            'existing+1@example.com',
            parentContact.MANAERP__Username__c,
            'Username should have +1 suffix when original is taken'
        );
    }

    @isTest
    static void test_resolveUniqueUsername_multipleDuplicates_appendsNextAvailable() {
        String baseUsername = 'multi@example.com';
        Id parentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
            .get('Parent')
            .getRecordTypeId();
        insert new List<Contact>{
            new Contact(FirstName = 'Existing', LastName = 'E1', RecordTypeId = parentRecordTypeId, Email = baseUsername, MANAERP__Username__c = baseUsername),
            new Contact(FirstName = 'Existing', LastName = 'E2', RecordTypeId = parentRecordTypeId, Email = 'multi+1@example.com', MANAERP__Username__c = 'multi+1@example.com')
        };

        Contact parentContact = new Contact(
            LastName = 'New',
            MANAERP__Username__c = baseUsername
        );

        Test.startTest();
        InquiryUsernameResolver.resolveUniqueUsername(parentContact);
        Test.stopTest();

        Assert.areEqual(
            'multi+2@example.com',
            parentContact.MANAERP__Username__c,
            'Username should have +2 suffix when +1 is also taken'
        );
    }

    @isTest
    static void test_resolveUniqueUsername_gapInSequence_fillsGap() {
        String baseUsername = 'gap@example.com';
        Id parentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
            .get('Parent')
            .getRecordTypeId();
        insert new List<Contact>{
            new Contact(FirstName = 'Existing', LastName = 'E1', RecordTypeId = parentRecordTypeId, Email = baseUsername, MANAERP__Username__c = baseUsername),
            new Contact(FirstName = 'Existing', LastName = 'E2', RecordTypeId = parentRecordTypeId, Email = 'gap+2@example.com', MANAERP__Username__c = 'gap+2@example.com')
        };

        Contact parentContact = new Contact(
            LastName = 'New',
            MANAERP__Username__c = baseUsername
        );

        Test.startTest();
        InquiryUsernameResolver.resolveUniqueUsername(parentContact);
        Test.stopTest();

        Assert.areEqual(
            'gap+1@example.com',
            parentContact.MANAERP__Username__c,
            'Username should fill the gap and use +1 suffix'
        );
    }

    @isTest
    static void test_resolveUniqueUsername_nullContact_noException() {
        Test.startTest();
        InquiryUsernameResolver.resolveUniqueUsername(null);
        Test.stopTest();

        Assert.isTrue(true, 'No exception should be thrown for null contact');
    }

    @isTest
    static void test_resolveUniqueUsername_blankUsername_noChange() {
        Contact parentContact = new Contact(
            LastName = 'Test',
            MANAERP__Username__c = ''
        );

        Test.startTest();
        InquiryUsernameResolver.resolveUniqueUsername(parentContact);
        Test.stopTest();

        Assert.areEqual(
            '',
            parentContact.MANAERP__Username__c,
            'Blank username should remain unchanged'
        );
    }

    @isTest
    static void test_resolveUniqueUsername_caseInsensitive_detectsConflict() {
        Id parentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
            .get('Parent')
            .getRecordTypeId();
        insert new Contact(
            FirstName = 'Existing',
            LastName = 'Contact',
            RecordTypeId = parentRecordTypeId,
            Email = 'ABC@gmail.com',
            MANAERP__Username__c = 'ABC@gmail.com'
        );

        Contact parentContact = new Contact(
            LastName = 'New',
            MANAERP__Username__c = 'abc@gmail.com'
        );

        Test.startTest();
        InquiryUsernameResolver.resolveUniqueUsername(parentContact);
        Test.stopTest();

        Assert.areEqual(
            'abc+1@gmail.com',
            parentContact.MANAERP__Username__c,
            'Username should detect case-insensitive conflict and append +1'
        );
    }
}