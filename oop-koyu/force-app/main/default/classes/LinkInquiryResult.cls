public class LinkInquiryResult {
	@AuraEnabled
    public Id inquiryId;
    
    @AuraEnabled
    public Id linkedStudentId;
    @AuraEnabled
    public Contact linkedStudent;
    
    @AuraEnabled
    public Id linkedParentId;
    @AuraEnabled
    public Contact linkedParent;

    @AuraEnabled
    public Boolean successful;
    
    @AuraEnabled
    public String errorMessage;

    @AuraEnabled
    public String originalParentUsername;

    @AuraEnabled
    public String resolvedParentUsername;
    
    public LinkInquiryResult() {
        this.successful = false;
    }
}