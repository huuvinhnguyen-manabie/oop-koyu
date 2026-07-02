trigger CMAssignmentTrigger on CM_Assignment__c (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        CMAssignmentTriggerHandler.provisionAffiliations(Trigger.new);
    }
}
