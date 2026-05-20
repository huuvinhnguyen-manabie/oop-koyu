public without sharing class InquiryConversion {
	public static final String CONVERSION_ERROR_INTERNAL_ERROR = 'Internal Error';
    public static final String CONVERSION_ERROR_DUPLICATE_PARENT_EMAIL = 'Duplicate Parent Email';

    public static InquiryConversionResult convertInquiry(Id inquiryId) {
        Inquiry__c inquiry = InquirySelector.getInquiry(inquiryId);
        
        ContactDuplicateDetector contactDuplicatedDetector = new ContactDuplicateDetector(new List<Inquiry__c>{inquiry});
        
        InquiryConversionResult convertResult = new InquiryConversionResult();
        
        convertResult.inquiryId = inquiry.Id;
        convertResult.inquiry = inquiry;
        
        // validate inquiry data before convert
        String validateError = InquiryValidator.validateInquiryBeforeConvert(inquiry);
        if (validateError != null) {
            convertResult.successful = false;
            convertResult.errorMessage = validateError;
            
            return convertResult;
        }
        
        // if duplicate student/parent detected
        List<Contact> duplicatedStudents = contactDuplicatedDetector.getPotentialDuplicatedStudents(inquiry);
        List<Contact> duplicatedParents = contactDuplicatedDetector.getPotentialDuplicatedParents(inquiry);
        
        Boolean isDuplicateDetected = !duplicatedStudents.isEmpty() || !duplicatedParents.isEmpty();
        
        if (isDuplicateDetected) {
            DuplicateDetectedResult ddr = new DuplicateDetectedResult();
            ddr.inquiryId = inquiry.Id;
            ddr.duplicatedStudents = duplicatedStudents;
            ddr.duplicatedParents = duplicatedParents;
            
            convertResult.duplicateDetected = true;
            convertResult.duplicatedResult = ddr;
            
            return convertResult;
        }
        
        Savepoint sp = Database.setSavepoint();
        
        try {
            Contact studentToCreate = InquiryConversionHandler.convertInquiryToStudentContact(inquiry);
            Contact parentToCreate = InquiryConversionHandler.convertInquiryToParentContact(inquiry);
            
            List<Contact> contactsToCreate = new List<Contact>{studentToCreate};
                
            if (parentToCreate != null) {
                InquiryUsernameResolver.resolveUniqueUsername(parentToCreate);
                contactsToCreate.add(parentToCreate);
            }
            
            insert contactsToCreate;
            
            Id createdParentId;
            
            if (parentToCreate != null) {
                createdParentId = parentToCreate.Id;
            }
            
            LinkInquiryResult linkResult = linkInquiryToStudentParent(inquiry.Id, studentToCreate.Id, createdParentId);
            convertResult.successful = linkResult.successful;
            convertResult.linkedStudentId = linkResult.linkedStudentId;
            convertResult.linkedStudent = linkResult.linkedStudent;
            convertResult.linkedParentId = linkResult.linkedParentId;
            convertResult.linkedParent = linkResult.linkedParent;
            
            return convertResult;
            
        } catch (Exception e) {
            String errorMessagePrefix;
            // check if DML error and include DUPLICATE_VALUE
            if (e.getMessage().contains('DUPLICATE_VALUE')) {
                errorMessagePrefix = CONVERSION_ERROR_DUPLICATE_PARENT_EMAIL;
            } else {
                errorMessagePrefix = CONVERSION_ERROR_INTERNAL_ERROR;
            }
            
            System.debug('Failed to convert inquiry: ' + inquiry.Id + ' => ' + e.getMessage());
            convertResult.successful = false;
            convertResult.errorMessage = errorMessagePrefix + ' \n ' + e.getMessage();
            Database.rollback(sp);
        
        	return convertResult;
        }
    } 
    
    public static LinkInquiryResult linkInquiryToStudentParent(Id inquiryId, Id studentId, Id parentId) {
        LinkInquiryResult result = new LinkInquiryResult();
        
        Savepoint sp = Database.setSavepoint();
        try {
            Inquiry__c inquiry = InquirySelector.getInquiry(inquiryId);
            
            if (studentId == null) {
                Contact studentToCreate = InquiryConversionHandler.convertInquiryToStudentContact(inquiry);
                insert studentToCreate;
                studentId = studentToCreate.Id;     
            }
            
            if (parentId == null) {
                Contact parentToCreate = InquiryConversionHandler.convertInquiryToParentContact(inquiry);
                if (parentToCreate != null) {
                    InquiryUsernameResolver.resolveUniqueUsername(parentToCreate);
                    insert parentToCreate;
                    parentId = parentToCreate.Id;   
                }
            }
            
            Inquiry__c inquiryToUpdate = new Inquiry__c(
                Id = inquiryId,
                Student__c = studentId,
                Parent__c = parentId,
				Converted__c = true
            );   
            
            // Do DMLs
            Database.update(inquiryToUpdate);

            fireInquiryConvertedEvent(inquiryId);
            Contact student = InquirySelector.getLinkedStudentInfo(studentId);
            Contact parent;
            if (parentId != null) {
                parent = InquirySelector.getLinkedParentInfo(parentId);
            }
            result.inquiryId = inquiryId;
            result.linkedStudentId = studentId;
            result.linkedStudent = student;
            result.linkedParentId = parentId;
            result.linkedParent = parent;
            result.successful = true;            
        } catch (Exception e) {
            String errorMessagePrefix;
            // check if DML error and include DUPLICATE_VALUE
            if (e.getMessage().contains('DUPLICATE_VALUE')) {
                errorMessagePrefix = CONVERSION_ERROR_DUPLICATE_PARENT_EMAIL;
            } else {
                errorMessagePrefix = CONVERSION_ERROR_INTERNAL_ERROR;
            }
            
            System.debug('Failed to link Inquiry: ' + inquiryId + 'to Student: ' + studentId + ' => ' + e.getMessage());
            result.successful = false;
            result.errorMessage = errorMessagePrefix + ' \n ' + e.getMessage();
            Database.rollback(sp);
        }
        
        return result;
    }
    
    public static LinkInquiryResult linkInquiryToStudentParent(LinkInquiryRequest request) {
        return linkInquiryToStudentParent(request.inquiryId, request.studentId, request.parentId);
    }
    
    public static List<LinkInquiryResult> linkInquiries(List<LinkInquiryRequest> requests) {
        List<LinkInquiryResult> linkResults = new List<LinkInquiryResult>();
        for (LinkInquiryRequest req : requests) {
            
            LinkInquiryResult linkResult = linkInquiryToStudentParent(req);
            
            linkResults.add(linkResult);
        }
        
        return linkResults;
    }

    private static void fireInquiryConvertedEvent(Id inquiryId) {
        if (Test.isRunningTest()) {
            doPostInquiryConverted(inquiryId);
            return;
        }

        Post_Inquiry_Conversion_Event__e event = new Post_Inquiry_Conversion_Event__e(
            Inquiry_ID__c = inquiryId
        );

        EventBus.publish(event);
    }

    public static void doPostInquiryConverted(Id inquiryId) {
        handleStudentStuffsAfterConvert(inquiryId);
    }

    private static void handleStudentStuffsAfterConvert(Id inquiryId) {
        Inquiry__c inquiry = InquirySelector.getInquiry(inquiryId);

        InquiryConversionHandler.handleStudentEnrollments(inquiry);
        InquiryConversionHandler.handleFamilyRelationships(inquiry);
        InquiryConversionHandler.handleUpdateContactNullInfos(inquiry);
    }
}