public class InquiryConversionResult {
	@AuraEnabled
    public Id inquiryId;
    
    @AuraEnabled
    public String inquiryName;
    
    @AuraEnabled
    public Inquiry__c inquiry;
    
    @AuraEnabled
    public Boolean successful;
    
    @AuraEnabled
    public String errorMessage;
    
    @AuraEnabled
    public Id linkedStudentId;
    @AuraEnabled
    public Contact linkedStudent;
    
    @AuraEnabled
    public Id linkedParentId;
    @AuraEnabled
    public Contact linkedParent;
    
    @AuraEnabled
    public Boolean duplicateDetected;
    
    @AuraEnabled
    public DuplicateDetectedResult duplicatedResult;  

    @AuraEnabled
    public String originalParentUsername;

    @AuraEnabled
    public String resolvedParentUsername;
    
    public InquiryConversionResult() {
        this.successful = false;
        this.duplicateDetected = false;
    }
}