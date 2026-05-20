@isTest
private class InquiryConversionDuplicatedTest {
private static final String DUPLICATE_FIRST_NAME_SAMPLE = 'First Name';
    private static final String DUPLICATE_LAST_NAME_SAMPLE = 'Duplicated';
    private static final String DUPLICATE_EMAIL_SAMPLE = 'student.duplicate@example.com';
    private static final String DUPLICATE_PHONE_SAMPLE = '0987654321';
    private static final String DUPLICATE_POSTAL_CODE_SAMPLE = '1234567';

    private static MANAERP__Grade__c grade;
    private static Account location;

    private static Inquiry__c sampleInquiry;

    @testSetup
    static void setup() {
        MANAERP__Grade__c grade = InquiryDataTest.createGrades(1)[0];

        Map<String, Object> overrideInfo = new Map<String, Object>{
            'Student_First_Name__c' => DUPLICATE_FIRST_NAME_SAMPLE,
            'Student_Last_Name__c' => DUPLICATE_LAST_NAME_SAMPLE,
            'Grade__c' => grade.Id,
            'Parent_First_Name__c' => DUPLICATE_FIRST_NAME_SAMPLE,
            'Parent_Last_Name__c' => DUPLICATE_LAST_NAME_SAMPLE,
            'Email__c' => DUPLICATE_EMAIL_SAMPLE,
            'Phone__c' => DUPLICATE_PHONE_SAMPLE,
            'Address__PostalCode__s' => DUPLICATE_POSTAL_CODE_SAMPLE
        };

        Inquiry__c inquiry = InquiryDataTest.createInquiry(overrideInfo, true);

        Test.startTest();
        InquiryConversionResult convertResult = InquiryConversion.convertInquiry(inquiry.Id);
        Test.stopTest();

        System.assert(convertResult.successful == true, 'Inquiry conversion should be successful');
    }

    private static void getSetupData() {
        grade = [
            SELECT Id, Name
            FROM MANAERP__Grade__c
            LIMIT 1
        ];

        sampleInquiry = [
            SELECT Id, Student__c, Student_2__c, Student_3__c
            FROM Inquiry__c
            LIMIT 1
        ];
    }

    @isTest
    private static void testConvertInquiryWithDuplicateStudent() {
        getSetupData();

        Inquiry__c inquiry = InquiryDataTest.createInquiry(
            new Map<String, Object>{
                'Student_First_Name__c' => DUPLICATE_FIRST_NAME_SAMPLE,
                'Student_Last_Name__c' => DUPLICATE_LAST_NAME_SAMPLE,
                'Grade__c' => grade.Id,
                'Email__c' => DUPLICATE_EMAIL_SAMPLE,
                'Phone__c' => DUPLICATE_PHONE_SAMPLE,
                'Address__PostalCode__s' => DUPLICATE_POSTAL_CODE_SAMPLE
            }
        );

        Test.startTest();
        InquiryConversionResult convertResult = InquiryConversion.convertInquiry(
            inquiry.Id
        );
        Test.stopTest();

        System.assert(convertResult.successful == false, 'Inqiury conversation should be failed');
        System.assert(convertResult.duplicateDetected == true, 'Contact duplications should be detected');

        DuplicateDetectedResult duplicatedResult = convertResult.duplicatedResult;

        System.assert(duplicatedResult != null, 'Duplicated Result should be detected');
        System.assert(duplicatedResult.duplicatedStudents.size() == 1, 'Duplicated Students should be detected');
        System.assert(duplicatedResult.duplicatedParents.size() == 0, 'Duplicated Parents should NOT be detected');
    }

    @isTest
    private static void testConvertInquiryWithDuplicateParent() {
        getSetupData();

        Inquiry__c inquiry = InquiryDataTest.createInquiry(
            new Map<String, Object>{
                'Parent_First_Name__c' => DUPLICATE_FIRST_NAME_SAMPLE,
                'Parent_Last_Name__c' => DUPLICATE_LAST_NAME_SAMPLE,
                'Email__c' => DUPLICATE_EMAIL_SAMPLE,
                'Phone__c' => DUPLICATE_PHONE_SAMPLE,
                'Address__PostalCode__s' => DUPLICATE_POSTAL_CODE_SAMPLE
            }
        );

        Test.startTest();
        InquiryConversionResult convertResult = InquiryConversion.convertInquiry(
            inquiry.Id
        );
        Test.stopTest();

        System.assert(convertResult.successful == false, 'Inqiury conversation should be failed');
        System.assert(convertResult.duplicateDetected == true, 'Contact duplications should be detected');

        DuplicateDetectedResult duplicatedResult = convertResult.duplicatedResult;

        System.assert(duplicatedResult != null, 'Duplicated Result should be detected');
        System.assert(duplicatedResult.duplicatedParents.size() == 1, 'Duplicated Parents should be detected');
        System.assert(duplicatedResult.duplicatedStudents.size() == 0, 'Duplicated Students should NOT be detected');
    }

    @isTest
    private static void testConvertInquiryWithDuplicateStudentAndParent() {
        getSetupData();

        Inquiry__c inquiry = InquiryDataTest.createInquiry(
            new Map<String, Object>{
                'Student_First_Name__c' => DUPLICATE_FIRST_NAME_SAMPLE,
                'Student_Last_Name__c' => DUPLICATE_LAST_NAME_SAMPLE,
                'Grade__c' => grade.Id,
                'Parent_First_Name__c' => DUPLICATE_FIRST_NAME_SAMPLE,
                'Parent_Last_Name__c' => DUPLICATE_LAST_NAME_SAMPLE,
                'Email__c' => DUPLICATE_EMAIL_SAMPLE,
                'Phone__c' => DUPLICATE_PHONE_SAMPLE,
                'Address__PostalCode__s' => DUPLICATE_POSTAL_CODE_SAMPLE
            }
        );

        Test.startTest();
        InquiryConversionResult convertResult = InquiryConversion.convertInquiry(
            inquiry.Id
        );
        Test.stopTest();

        System.assert(convertResult.successful == false, 'Inqiury conversation should be failed');
        System.assert(convertResult.duplicateDetected == true, 'Contact duplications should be detected');

        DuplicateDetectedResult duplicatedResult = convertResult.duplicatedResult;

        System.assert(duplicatedResult != null, 'Duplicated Result should be detected');
        System.assert(duplicatedResult.duplicatedStudents.size() == 1, 'Duplicated Students should be detected');
        System.assert(duplicatedResult.duplicatedParents.size() == 1, 'Duplicated Parents should be detected');
    }

    @isTest
    private static void testLinkInquiryWithDuplicateStudentAndParent() {
        getSetupData();

        Inquiry__c inquiry = InquiryDataTest.createInquiry(
            new Map<String, Object>{
                'Student_First_Name__c' => DUPLICATE_FIRST_NAME_SAMPLE,
                'Student_Last_Name__c' => DUPLICATE_LAST_NAME_SAMPLE,
                'Grade__c' => grade.Id,
                'Parent_First_Name__c' => DUPLICATE_FIRST_NAME_SAMPLE,
                'Parent_Last_Name__c' => DUPLICATE_LAST_NAME_SAMPLE,
                'Email__c' => DUPLICATE_EMAIL_SAMPLE,
                'Phone__c' => DUPLICATE_PHONE_SAMPLE,
                'Address__PostalCode__s' => DUPLICATE_POSTAL_CODE_SAMPLE
            }
        );

        InquiryConversionResult convertResult = InquiryConversion.convertInquiry(
            inquiry.Id
        );

        System.assert(convertResult.successful == false, 'Inqiury conversation should be failed');
        System.assert(convertResult.duplicateDetected == true, 'Contact duplications should be detected');

        DuplicateDetectedResult duplicatedResult = convertResult.duplicatedResult;

        System.assert(duplicatedResult != null, 'Duplicated Result should be detected');
        System.assert(duplicatedResult.duplicatedStudents.size() == 1, 'Duplicated Students should be detected');
        System.assert(duplicatedResult.duplicatedParents.size() == 1, 'Duplicated Parents should be detected');

        Id duplicatedStudentId = duplicatedResult.duplicatedStudents[0].Id;
        Id duplicatedParentId = duplicatedResult.duplicatedParents[0].Id;

        Test.startTest();
        LinkInquiryResult result = InquiryConversion.linkInquiryToStudentParent(
            inquiry.Id,
            duplicatedStudentId,
            duplicatedParentId
        );
        Test.stopTest();

        System.assert(result.successful == true, 'Linking Inqiury to existing Student & Parent should be successful');
        System.assertEquals(duplicatedStudentId, result.linkedStudentId, 'Linked Student ID should be correctly');
        System.assertEquals(duplicatedParentId, result.linkedParentId, 'Linked Parent ID should be correctly');

        Inquiry__c inquiryAfterLinked = InquirySelector.getInquiry(inquiry.Id);
        System.assert(inquiryAfterLinked.Converted__c == true, 'Inquiry should be CONVERTED');
        System.assertEquals(
            duplicatedStudentId,
            inquiryAfterLinked.Student__c,
            'Student should be linked to the inquiry correctly'
        );
        System.assertEquals(
            duplicatedParentId,
            inquiryAfterLinked.Parent__c,
            'Parent should be linked to the inquiry correctly'
        );
    }

    @isTest
    private static void testLinkInquiryWithDuplicateStudentAndCreateNewParent() {
        getSetupData();

        Inquiry__c inquiry = InquiryDataTest.createInquiry(
            new Map<String, Object>{
                'Student_First_Name__c' => DUPLICATE_FIRST_NAME_SAMPLE,
                'Student_Last_Name__c' => DUPLICATE_LAST_NAME_SAMPLE,
                'Grade__c' => grade.Id,
                'Parent_First_Name__c' => DUPLICATE_FIRST_NAME_SAMPLE,
                'Parent_Last_Name__c' => DUPLICATE_LAST_NAME_SAMPLE,
                'Email__c' => DUPLICATE_EMAIL_SAMPLE + 'random',
                'Phone__c' => DUPLICATE_PHONE_SAMPLE,
                'Address__PostalCode__s' => DUPLICATE_POSTAL_CODE_SAMPLE
            }
        );

        InquiryConversionResult convertResult = InquiryConversion.convertInquiry(
            inquiry.Id
        );

        System.assert(convertResult.successful == false, 'Inqiury conversation should be failed');
        System.assert(convertResult.duplicateDetected == true, 'Contact duplications should be detected');

        DuplicateDetectedResult duplicatedResult = convertResult.duplicatedResult;

        System.assert(duplicatedResult != null, 'Duplicated Result should be detected');
        System.assert(duplicatedResult.duplicatedStudents.size() == 1, 'Duplicated Students should be detected');
        System.assert(duplicatedResult.duplicatedParents.size() == 1, 'Duplicated Parents should be detected');

        Id duplicatedStudentId = duplicatedResult.duplicatedStudents[0].Id;
        Id duplicatedParentId = null; // simulate the Create New Parent option

        Test.startTest();
        LinkInquiryRequest request = new LinkInquiryRequest();
        request.inquiryId = inquiry.Id;
        request.studentId = duplicatedStudentId;
        request.parentId = duplicatedParentId;
        LinkInquiryResult result = InquiryConversion.linkInquiryToStudentParent(
            request
        );
        Test.stopTest();

        System.assert(result.successful == true, 'Linking Inqiury to existing Student & Parent should be successful');
        System.assertEquals(duplicatedStudentId, result.linkedStudentId, 'Linked Student ID should be correctly');
        System.assert(result.linkedParentId != null, 'Linked Parent ID should be correctly');

        Id newCreatedParentId = result.linkedParentId;

        Inquiry__c inquiryAfterLinked = InquirySelector.getInquiry(inquiry.Id);
        System.assert(inquiryAfterLinked.Converted__c == true, 'Inquiry should be CONVERTED');
        System.assertEquals(
            duplicatedStudentId,
            inquiryAfterLinked.Student__c,
            'Student should be linked to the inquiry correctly'
        );
        System.assertEquals(
            newCreatedParentId,
            inquiryAfterLinked.Parent__c,
            'Parent should be linked to the inquiry correctly'
        );
    }

    @isTest
    private static void testLinkInquiryWithCreateNewStudentAndDuplicateParent() {
        getSetupData();

        Inquiry__c inquiry = InquiryDataTest.createInquiry(
            new Map<String, Object>{
                'Student_First_Name__c' => DUPLICATE_FIRST_NAME_SAMPLE,
                'Student_Last_Name__c' => DUPLICATE_LAST_NAME_SAMPLE,
                'Grade__c' => grade.Id,
                'Parent_First_Name__c' => DUPLICATE_FIRST_NAME_SAMPLE,
                'Parent_Last_Name__c' => DUPLICATE_LAST_NAME_SAMPLE,
                'Email__c' => DUPLICATE_EMAIL_SAMPLE,
                'Phone__c' => DUPLICATE_PHONE_SAMPLE,
                'Address__PostalCode__s' => DUPLICATE_POSTAL_CODE_SAMPLE
            }
        );

        InquiryConversionResult convertResult = InquiryConversion.convertInquiry(
            inquiry.Id
        );

        System.assert(convertResult.successful == false, 'Inqiury conversation should be failed');
        System.assert(convertResult.duplicateDetected == true, 'Contact duplications should be detected');

        DuplicateDetectedResult duplicatedResult = convertResult.duplicatedResult;

        System.assert(duplicatedResult != null, 'Duplicated Result should be detected');
        System.assert(duplicatedResult.duplicatedStudents.size() == 1, 'Duplicated Students should be detected');

        System.assert(duplicatedResult.duplicatedParents.size() == 1, 'Duplicated Parents should be detected');

        Id duplicatedStudentId = null; // simulate the Create New Student option
        Id duplicatedParentId = duplicatedResult.duplicatedParents[0].Id;

        Test.startTest();
        LinkInquiryRequest request = new LinkInquiryRequest();
        request.inquiryId = inquiry.Id;
        request.studentId = duplicatedStudentId;
        request.parentId = duplicatedParentId;
        LinkInquiryResult result = InquiryConversion.linkInquiries(
            new List<LinkInquiryRequest>{request}
        )[0];
        System.assert(result.successful == true, 'Linking Inqiury to existing Student & Parent should be successful');
        System.assertEquals(duplicatedParentId, result.linkedParentId, 'Linked Parent ID should be correctly');
        System.assert(result.linkedStudentId != null, 'Linked Student ID should be correctly');

        Id newCreateStudentId = result.linkedStudentId;

        Inquiry__c inquiryAfterLinked = InquirySelector.getInquiry(inquiry.Id);
        System.assert(inquiryAfterLinked.Converted__c == true, 'Inquiry should be CONVERTED');
        System.assertEquals(
            newCreateStudentId,
            inquiryAfterLinked.Student__c,
            'Student should be linked to the inquiry correctly'
        );
        System.assertEquals(
            duplicatedParentId,
            inquiryAfterLinked.Parent__c,
            'Parent should be linked to the inquiry correctly'
        );
        Test.stopTest();
    }

    @isTest
    private static void testLinkInquiryWithCreateNewStudentAndParent() {
        getSetupData();

        Inquiry__c inquiry = InquiryDataTest.createInquiry(
            new Map<String, Object>{
                'Student_First_Name__c' => DUPLICATE_FIRST_NAME_SAMPLE,
                'Student_Last_Name__c' => DUPLICATE_LAST_NAME_SAMPLE,
                'Grade__c' => grade.Id,
                'Parent_First_Name__c' => DUPLICATE_FIRST_NAME_SAMPLE,
                'Parent_Last_Name__c' => DUPLICATE_LAST_NAME_SAMPLE,
                'Phone__c' => DUPLICATE_PHONE_SAMPLE,
                'Address__PostalCode__s' => DUPLICATE_POSTAL_CODE_SAMPLE
            }
        );

        InquiryConversionResult convertResult = InquiryConversion.convertInquiry(
            inquiry.Id
        );

        System.assert(convertResult.successful == false, 'Inqiury conversation should be failed');
        System.assert(convertResult.duplicateDetected == true, 'Contact duplications should be detected');

        DuplicateDetectedResult duplicatedResult = convertResult.duplicatedResult;

        System.assert(duplicatedResult != null, 'Duplicated Result should be detected');
        System.assert(duplicatedResult.duplicatedStudents.size() == 1, 'Duplicated Students should be detected');
        System.assert(duplicatedResult.duplicatedParents.size() == 1, 'Duplicated Parents should be detected');

        Id duplicatedStudentId = null; // simulate the Create New Student option
        Id duplicatedParentId = null; // simulate the Create New Parent option

        Test.startTest();
        LinkInquiryResult result = InquiryConversion.linkInquiryToStudentParent(
            inquiry.Id,
            duplicatedStudentId,
            duplicatedParentId
        );
        Test.stopTest();

        System.assert(result.successful == true, 'Linking Inqiury to new Student & Parent should be successful');
        System.assert(result.linkedStudentId != null, 'Linked Student ID should be correctly');
        System.assert(result.linkedParentId != null, 'Linked Parent ID should be correctly');

        Id newCreateStudentId = result.linkedStudentId;
        Id newCreateParentId = result.linkedParentId;

        Inquiry__c inquiryAfterLinked = InquirySelector.getInquiry(inquiry.Id);
        System.assert(inquiryAfterLinked.Converted__c == true, 'Inquiry should be CONVERTED');
        System.assertEquals(
            newCreateStudentId,
            inquiryAfterLinked.Student__c,
            'Student should be linked to the inquiry correctly'
        );
        System.assertEquals(
            newCreateParentId,
            inquiryAfterLinked.Parent__c,
            'Parent should be linked to the inquiry correctly'
        );
    }
}