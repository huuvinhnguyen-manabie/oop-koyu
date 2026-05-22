// labels
import labelInquiryGuidelineTitle from "@salesforce/label/c.Inquiry_Guideline_Title";
import labelInquiryGuidelineDescription from "@salesforce/label/c.Inquiry_Guideline_Description";
import labelInquiryGuidelineSubjectStudent from "@salesforce/label/c.Inquiry_Guideline_Subject_Student";
import labelInquiryGuidelineSubjectStudentNote from "@salesforce/label/c.Inquiry_Guideline_Subject_Student_Note";
import labelInquiryGuidelineSubjectParent from "@salesforce/label/c.Inquiry_Guideline_Subject_Parent";
import labelInquiryGuidelineSubjectParentDescription from "@salesforce/label/c.Inquiry_Guideline_Subject_Parent_Description";
import labelInquiryGuidelineSubjectParentImportant from "@salesforce/label/c.Inquiry_Guideline_Subject_Parent_Important";
import labelInquiryGuidelineSubjectParentImportantNote from "@salesforce/label/c.Inquiry_Guideline_Subject_Parent_Important_Note";
import labelInquiryGuidelineAllFieldsFulfilled from "@salesforce/label/c.Inquiry_Guideline_All_Fields_Fulfilled";

import labelConfirmation from "@salesforce/label/c.Inquiry_Conversion_Confirmation";
import labelNextAction from "@salesforce/label/c.Inquiry_Conversion_Next_Action";
import labelBackAction from "@salesforce/label/c.Inquiry_Conversion_Back_Action";
import labelCancelAction from "@salesforce/label/c.Inquiry_Conversion_Cancel_Action";
import labelConfirmAction from "@salesforce/label/c.Inquiry_Conversion_Confirm_Action";
import labelConvertAction from "@salesforce/label/c.Inquiry_Conversion_Convert_Action";

import labelConvertSuccessMessage from "@salesforce/label/c.Inquiry_Conversion_Success_Message";
import labelLinkSuccessMessage from "@salesforce/label/c.Inquiry_Conversion_Link_Success_Message";
import labelParentUsernameResolved from "@salesforce/label/c.Inquiry_Conversion_Parent_Username_Resolved";

import labelHitASnag from "@salesforce/label/c.Inquiry_Conversion_Hit_A_Snag";
import labelReviewErrors from "@salesforce/label/c.Inquiry_Conversion_Review_Errors";
import labelSystemError from "@salesforce/label/c.Inquiry_Error_System_Errors";

import labelDuplicatedStudents from "@salesforce/label/c.Inquiry_Conversion_Duplicated_Students";
import labelDuplicatedParents from "@salesforce/label/c.Inquiry_Conversion_Duplicated_Parents";
import labelPhoneticName from "@salesforce/label/c.Inquiry_Conversion_Phonetic_Name";
import labelGrade from "@salesforce/label/c.Inquiry_Conversion_Grade";
import labelMainLocation from "@salesforce/label/c.Inquiry_Conversion_Main_Location";
import labelPostalCode from "@salesforce/label/c.Inquiry_Conversion_Postal_Code";
import labelPhoneNumber from "@salesforce/label/c.Inquiry_Conversion_Phone_Number";
import labelEmail from "@salesforce/label/c.Inquiry_Conversion_Email";
import labelCreateNewStudent from "@salesforce/label/c.Inquiry_Conversion_Create_New_Student";
import labelCreateNewParent from "@salesforce/label/c.Inquiry_Conversion_Create_New_Parent";

export const inquiryTranslations = {
    guideline: {
        title: labelInquiryGuidelineTitle,
        description: labelInquiryGuidelineDescription,
        subject: {
            student: labelInquiryGuidelineSubjectStudent,
            studentNote: labelInquiryGuidelineSubjectStudentNote,
            parent: labelInquiryGuidelineSubjectParent,
            parentDescription: labelInquiryGuidelineSubjectParentDescription,
            parentImportant: labelInquiryGuidelineSubjectParentImportant,
            parentImportantNote: labelInquiryGuidelineSubjectParentImportantNote
        },
        allFieldsFulfilled: labelInquiryGuidelineAllFieldsFulfilled,
    },
    conversion: {
        button: {
            cancel: labelCancelAction,
            next: labelNextAction,
            back: labelBackAction,
            confirm: labelConfirmAction,
            convert: labelConvertAction
        },
        message: {
            confirmation: labelConfirmation,
            convertSuccess: labelConvertSuccessMessage,
            linkSuccess: labelLinkSuccessMessage,
            parentUsernameResolved: labelParentUsernameResolved
        },
        error: {
            requiredFieldError: labelHitASnag,
            reviewErrors: labelReviewErrors,
            unknownError: labelSystemError
        }
    },
    duplicateModal: {
        title: {
            duplicatedStudents: labelDuplicatedStudents,
            duplicatedParents: labelDuplicatedParents
        },
        field: {
            phoneticName: labelPhoneticName,
            grade: labelGrade,
            mainLocation: labelMainLocation,
            postalCode: labelPostalCode,
            phoneNumber: labelPhoneNumber,
            email: labelEmail,
        },
        option: {
            createNewStudent: labelCreateNewStudent,
            createNewParent: labelCreateNewParent
        }
    }
};

const InquiryTranslationMixin = (BaseClass) => {
    return class extends BaseClass {
        get label() {
            return inquiryTranslations;
        }

        /**
         * Replaces placeholders in a label with provided values.
         * @param {string} label - The label containing placeholders.
         * @param {object} params - The object containing values to substitute.
         * @returns {string} - The label with substituted values.
         */
        replaceLabelPlaceholders(label, params) {
            if (label && params) {
                Object.keys(params).forEach((key) => {
                    const placeholder = `\\{${key}\\}`;
                    label = label.replace(new RegExp(placeholder, "g"), String(params[key]));
                });

                return label;
            }
            return label || "";
        }
    };
};

export default InquiryTranslationMixin;