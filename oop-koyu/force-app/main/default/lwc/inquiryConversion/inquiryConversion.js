import { LightningElement, api, track } from 'lwc';
import convertInquiry from "@salesforce/apex/InquiryConversionController.convertInquiry";
import linkInquiry from "@salesforce/apex/InquiryConversionController.linkInquiry";
import { FlowNavigationFinishEvent } from "lightning/flowSupport";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import InquiryTranslationMixin from "c/inquiryTranslationMixin";


const CONVERSION_STEP = {
    CONVERTING: 'CONVERTING',
    CONVERSION_RESULT: 'CONVERSION_RESULT',
    DUPLICATE_DETECTED: 'DUPLICATE_DETECTED',
    LINK_CONFIRMATION: 'LINK_CONFIRMATION',
    LINK_RESULT: 'LINK_RESULT',
    COMPLETED: 'COMPLETED'
};

export default class InquiryConversion extends InquiryTranslationMixin(LightningElement) {
    @api inquiryId;

    isLoading = true;
    conversionStep = CONVERSION_STEP.CONVERTING;
    
    conversionResult;
    linkResult;
    duplicatedResult;

    get duplicatedStudentIds() {
        return this.duplicatedStudents.map(student => student.Id);
    }

    get isDuplicateDetectedStep() {
        return this.conversionStep == CONVERSION_STEP.DUPLICATE_DETECTED;
    }

    get isLinkConfirmationStep() {
        return this.conversionStep == CONVERSION_STEP.LINK_CONFIRMATION;
    }

    async connectedCallback() {
        if (this.inquiryId) {
            try {
                const result = await convertInquiry({
                    inquiryId: this.inquiryId
                });

                this.doPostConversion(result);
            } catch (e) {
                console.error("Something wrong! Cannot convert inquiry", e);
                this.handleUnknownError();
            } finally {
                this.isLoading = false;
            }
        }
    }

    doPostConversion(result) {
        const isDuplicateDetected = !!result.duplicateDetected;

        if (isDuplicateDetected) {
            this.duplicatedResult = {
                ...result.duplicatedResult,
                selectedDuplicatedStudentId: result.duplicatedResult.duplicatedStudents[0]?.Id,
                selectedDuplicatedParentId: result.duplicatedResult.duplicatedParents[0]?.Id,
            };

            this.conversionStep = CONVERSION_STEP.DUPLICATE_DETECTED;
            return;
        }

        if (result.successful) {
            this.handleConvertInquirySuccess(result);

            return;
        }

        if (result.errorMessage) {
            this.handleCloseFlowWithError(result.errorMessage);

            return;
        }
    }

    handleSelectedDuplicatedStudent(event) {
        const { selectedStudentId } = event.detail;

        this.duplicatedResult = { 
            ...this.duplicatedResult,
            selectedDuplicatedStudentId: selectedStudentId
        };
    }

    handleSelectedDuplicatedParent(event) {
        const { selectedParentId } = event.detail;

        this.duplicatedResult = { 
            ...this.duplicatedResult,
            selectedDuplicatedParentId: selectedParentId
        };
    }

    async handleLinkInquiry() {
        try {
            this.isLoading = true;
            
            const result = await linkInquiry({
                inquiryId: this.duplicatedResult.inquiryId,
                studentId: this.duplicatedResult.selectedDuplicatedStudentId ? this.duplicatedResult.selectedDuplicatedStudentId : null,
                parentId: this.duplicatedResult.selectedDuplicatedParentId ? this.duplicatedResult.selectedDuplicatedParentId : null
            });

            console.log("Link inquiry result: ", result);

            this.doPostLinkInquiry(result);
        } catch(e) {
            console.error("Something wrong! Cannot link inquiry", e);
            this.handleUnknownError();
        } finally {
            this.isLoading = false;
        }
        
    }

    doPostLinkInquiry(result) {
        if (result.successful) {
            this.handleLinkInquirySuccess(result);
        }

        if (result.errorMessage) {
            this.handleActionError(result.errorMessage);
        }
    }

    handleUnknownError() {
        const toastEvent = new ShowToastEvent({
            title: this.label.conversion.error.unknownError,
            variant: 'error'
        });

        this.dispatchEvent(toastEvent);
        this.dispatchEvent(new FlowNavigationFinishEvent());
    }

    handleCloseFlowWithError(errorMessage) {
        const toastEvent = new ShowToastEvent({
            message: errorMessage,
            variant: 'error'
        });

        this.dispatchEvent(toastEvent);
        this.dispatchEvent(new FlowNavigationFinishEvent());
    }

    handleConvertInquirySuccess(result) {
        this.conversionStep = CONVERSION_STEP.COMPLETED;

        const toastEvent = new ShowToastEvent({
            title: this.label.conversion.message.convertSuccess,
            variant: 'success'
        });

        this.dispatchEvent(toastEvent);
        this.handleParentUsernameResolvedToast(result);
        this.dispatchEvent(new FlowNavigationFinishEvent());
    }

    handleLinkInquirySuccess(result) {
        this.conversionStep = CONVERSION_STEP.COMPLETED;

        const linkedStudentName = result.linkedStudent.Name || '--';

        const toastEvent = new ShowToastEvent({
            title: this.label.conversion.message.linkSuccess.replace('{{STUDENT_NAME}}', linkedStudentName),
            variant: 'success'
        });

        this.dispatchEvent(toastEvent);
        this.handleParentUsernameResolvedToast(result);
        this.dispatchEvent(new FlowNavigationFinishEvent());
    }

    handleParentUsernameResolvedToast(result) {
        if (result && result.originalParentUsername && result.resolvedParentUsername) {
            const message = this.replaceLabelPlaceholders(
                this.label.conversion.message.parentUsernameResolved,
                {
                    ORIGINAL_USERNAME: result.originalParentUsername,
                    RESOLVED_USERNAME: result.resolvedParentUsername
                }
            );
            const toastEvent = new ShowToastEvent({
                message: message,
                variant: 'info',
                mode: 'sticky'
            });
            this.dispatchEvent(toastEvent);
        }
    }

    /* ================================================== */
    // footer action logics

    isErrorModalOpen = false;
    errorMessage;
    handleActionError(errorMessage) {
        this.errorMessage = errorMessage;
        this.openErrorModal();
    }
    openErrorModal() {
        this.isErrorModalOpen = true;
    }

    closeErrorModal() {
        this.isErrorModalOpen = false;
    }

    get shouldShowActionBar() {
        return [
            CONVERSION_STEP.CONVERSION_RESULT, 
            CONVERSION_STEP.DUPLICATE_DETECTED, 
            CONVERSION_STEP.LINK_CONFIRMATION, 
            CONVERSION_STEP.LINK_RESULT
        ].includes(this.conversionStep);
    }

    get primaryActionLabel() {
        switch (this.conversionStep) {
            case CONVERSION_STEP.DUPLICATE_DETECTED: {
                return this.label.conversion.button.next;
            }
            case CONVERSION_STEP.LINK_CONFIRMATION: {
                return this.label.conversion.button.convert;
            }
            default: {
                return this.label.conversion.button.confirm;
            }
        }
    }

    get secondaryActionLabel() {
        switch (this.conversionStep) {
            case CONVERSION_STEP.LINK_CONFIRMATION: {
                return this.label.conversion.button.back;
            }
            default: {
                return this.label.conversion.button.cancel;
            }
        }
    }

    handleSecondaryActionClick() {
        switch (this.conversionStep) {
            case CONVERSION_STEP.LINK_CONFIRMATION: {
                this.conversionStep = CONVERSION_STEP.DUPLICATE_DETECTED;
                break;
            }
            default: {
                this.dispatchEvent(new FlowNavigationFinishEvent());
            }
        }
    }

    handlePrimaryActionClick() {
        switch (this.conversionStep) {
            case CONVERSION_STEP.DUPLICATE_DETECTED: {
                this.conversionStep = CONVERSION_STEP.LINK_CONFIRMATION;
                break;
            }
            case CONVERSION_STEP.LINK_CONFIRMATION: {
                this.handleLinkInquiry();
                break;
            }
            default: {
                break;
            }
        }
    }
}