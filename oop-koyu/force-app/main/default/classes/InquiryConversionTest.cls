@isTest
private class InquiryConversionTest {
    private static void assertStudentFieldsMapping(Inquiry__c inquiry, Id studentId) {
        Contact student = InquirySelector.getLinkedStudentInfo(studentId);
        
        if (student == null) {
            return;
        }
        
        System.assert(inquiry.Student_Last_Name__c == student.LastName, 'Student LastName should mapping correctly');
        System.assert(inquiry.Student_First_Name__c == student.FirstName, 'Student FistName should mapping correctly');
        System.assert(inquiry.Student_Last_Name_Phonetic__c == student.MANAERP__Last_Name_Phonetic__c, 'Student LastName Phonetic should mapping correctly');
        System.assert(inquiry.Student_First_Name_Phonetic__c == student.MANAERP__First_Name_Phonetic__c, 'Student FirstName Phonetic should mapping correctly');
        System.assert(inquiry.Grade__c == student.MANAERP__Grade__c, 'Student Grade should mapping correctly');
        // System.assert(inquiry.Gender__c == student.GenderIdentity, 'Student Gender should mapping correctly');
        System.assert(inquiry.Birthday__c == student.Birthdate, 'Student Birthdate should mapping correctly');
        System.assert(inquiry.Email__c == student.Email, 'Student Email should mapping correctly');
        System.assert(inquiry.Phone__c == student.Phone, 'Student Phone should mapping correctly');
        // System.assert(inquiry.Address__StateCode__s == student.MANAERP__Prefecture__c, 'Student Address Prefecture should mapping correctly');
        System.assert(inquiry.Address__PostalCode__s == student.MANAERP__Postal_Code__c, 'Student Address PostalCode should mapping correctly');
        System.assert(inquiry.Address__City__s == student.MANAERP__City__c, 'Student Address City should mapping correctly');
        System.assert(inquiry.Address__Street__s == student.MANAERP__Street_1__c, 'Student Address Street should mapping correctly');
        System.assert(inquiry.Street_2__c == student.MANAERP__Street_2__c, 'Student Address Street 2 should mapping correctly');
    }
    
    private static void assertStudentEnrollmentAndRelationship(Inquiry__c inquiry, Id studentId, Id parentId) {
        List<MANAERP__Enrollment__c> studentEnrollments = [SELECT Id, MANAERP__Enrollment_Status__c, MANAERP__Enrollment_Start_Date__c FROM MANAERP__Enrollment__c WHERE MANAERP__Student__c = :studentId AND MANAERP__Location__c = :inquiry.Location_Preference__c];
        
        System.assert(studentEnrollments.size() == 1, 'Student Enrollments should be create successful');
        
        MANAERP__Enrollment__c enrollment = studentEnrollments[0];
        
        System.assert(enrollment.MANAERP__Enrollment_Status__c == 'Temporary', 'Student Enrollment Status should be TEMPORARY');
        System.assert(enrollment.MANAERP__Enrollment_Start_Date__c.date() == Date.today(), 'Student Enrollment StartDate should be today');
        
        if (parentId == null) {
            return;
        }
        
        List<MANAERP__Relationship__c> relationships = [SELECT Id, MANAERP__Relationship__c FROM MANAERP__Relationship__c WHERE MANAERP__From__c = :studentId AND MANAERP__To__c = :parentId];
        
        System.assert(relationships.size() == 1, 'Student Enrollments should be create successful');
        
        MANAERP__Relationship__c rel = relationships[0];
        
        System.assert(rel.MANAERP__Relationship__c == 'Other', 'Relationship value should be OTHER');
    }
    
    private static void assertParentFieldsMapping(Inquiry__c inquiry, Id parentId) {
        if (parentId == null) {
            return;
        }
        
        Contact parent = InquirySelector.getLinkedParentInfo(parentId);
        
        if (parent == null) {
            return;
        }
        
        System.assert(inquiry.Parent_Last_Name__c == parent.LastName, 'Parent LastName should mapping correctly');
        System.assert(inquiry.Parent_First_Name__c == parent.FirstName, 'Parent FistName should mapping correctly');
        System.assert(inquiry.Parent_Last_Name_Phonetic__c == parent.MANAERP__Last_Name_Phonetic__c, 'Parent LastName Phonetic should mapping correctly');
        System.assert(inquiry.Parent_First_Name_Phonetic__c == parent.MANAERP__First_Name_Phonetic__c, 'Parent FirstName Phonetic should mapping correctly');
        System.assert(inquiry.Email__c == parent.Email, 'Parent Email should mapping correctly');
        System.assert(inquiry.Phone__c == parent.Phone, 'Parent Phone should mapping correctly');
        // System.assert(inquiry.Address__StateCode__s == parent.Address__StateCode__s, 'Parent Address Prefecture should mapping correctly');
        System.assert(inquiry.Address__PostalCode__s == parent.MANAERP__Postal_Code__c, 'Parent Address PostalCode should mapping correctly');
        System.assert(inquiry.Address__City__s == parent.MANAERP__City__c, 'Parent Address City should mapping correctly');
        System.assert(inquiry.Address__Street__s == parent.MANAERP__Street_1__c, 'Parent Address Street should mapping correctly');
        System.assert(inquiry.Street_2__c == parent.MANAERP__Street_2__c, 'Parent Address Street 2 should mapping correctly');
    }
    
    @isTest
    static void testConvertInquiryWithAllFields() {
        Inquiry__c inquiry = InquiryDataTest.createInquiry();
        
        Test.startTest();
       	InquiryConversionResult convertResult = InquiryConversion.convertInquiry(inquiry.Id);
        System.assert(convertResult.successful == true, 'Inqiury conversion should be successful');
        System.assert(convertResult.linkedStudentId != null, 'New student should be create & linked to the inquiry');
        System.assert(convertResult.linkedParentId != null, 'New parent should be create & linked to the inquiry');
        
        assertStudentFieldsMapping(convertResult.inquiry, convertResult.linkedStudentId);
        assertParentFieldsMapping(convertResult.inquiry, convertResult.linkedParentId);
        assertStudentEnrollmentAndRelationship(convertResult.inquiry, convertResult.linkedStudentId, convertResult.linkedParentId);
        Test.stopTest();
    }
    
    @isTest
    static void testConvertInquiryWithMissingMandatoryFields() {
        Inquiry__c inquiry = InquiryDataTest.createInquiry(
            new Map<String, Object>{
            	'Location_Preference__c' => null
            }
        );
        
        Test.startTest();
        // Missing Location_Preference__c
       	InquiryConversionResult convertResult = InquiryConversion.convertInquiry(inquiry.Id);
        
        System.assert(convertResult.successful == false, 'Inqiury conversion should be failed');
        System.assertEquals(InquiryValidator.CONVERSION_ERROR_MISSING_REQUIRED_FIELDS, convertResult.errorMessage, 'Validation message should be correctly');
    }
    
    @isTest
    static void testConvertInquiryDoubleTimes() {
        Inquiry__c inquiry = InquiryDataTest.createInquiry();
        
        InquiryConversion.convertInquiry(inquiry.Id);
        
        Test.startTest();
        // Trying to convert the inquiry 1 more time
       	InquiryConversionResult convertResult = InquiryConversion.convertInquiry(inquiry.Id);
        
        System.assert(convertResult.successful == false, 'Inqiury conversion should be failed');
        System.assertEquals(InquiryValidator.CONVERSION_ERROR_ALREADY_CONVERTED, convertResult.errorMessage, 'Validation message should be correctly');
        
        Test.stopTest();
    }
}