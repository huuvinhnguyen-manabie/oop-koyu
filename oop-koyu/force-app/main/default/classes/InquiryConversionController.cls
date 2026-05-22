public class InquiryConversionController {
	@AuraEnabled
    public static InquiryConversionResult convertInquiry(Id inquiryId) {
        InquiryConversionResult result = InquiryConversion.convertInquiry(inquiryId);
        
        return result;
    }
    
    @AuraEnabled
    public static LinkInquiryResult linkInquiry(Id inquiryId, Id studentId, Id parentId) {
        LinkInquiryRequest request = new LinkInquiryRequest();
        request.inquiryId = inquiryId;
        request.studentId = studentId;
        request.parentId = parentId;
       
        return InquiryConversion.linkInquiryToStudentParent(request);
    }
}