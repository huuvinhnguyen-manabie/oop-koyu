public without sharing class CMAssignmentTriggerHandler {
    // without sharing so the existence check sees affiliations regardless of the
    // running user's record visibility (avoids duplicate-key inserts).
    public static void provisionAffiliations(List<CM_Assignment__c> assignments) {
        Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        List<CM_Assignment__c> toProcess = new List<CM_Assignment__c>();

        for (CM_Assignment__c a : assignments) {
            if (a.Skip_Affiliation_Provisioning__c == true) continue;
            if (a.Staff__c == null || a.Location__c == null) continue;
            toProcess.add(a);
            contactIds.add(a.Staff__c);
            accountIds.add(a.Location__c);
        }
        if (toProcess.isEmpty()) return;

        Set<String> existing = new Set<String>();
        for (MANAERP__Affiliation__c aff : [
                SELECT MANAERP__Contact__c, MANAERP__Account__c
                FROM MANAERP__Affiliation__c
                WHERE MANAERP__Contact__c IN :contactIds
                  AND MANAERP__Account__c IN :accountIds]) {
            existing.add(aff.MANAERP__Contact__c + '|' + aff.MANAERP__Account__c);
        }

        Set<String> queued = new Set<String>();
        List<MANAERP__Affiliation__c> toInsert = new List<MANAERP__Affiliation__c>();
        for (CM_Assignment__c a : toProcess) {
            String key = a.Staff__c + '|' + a.Location__c;
            if (existing.contains(key) || queued.contains(key)) continue;
            queued.add(key);
            toInsert.add(new MANAERP__Affiliation__c(
                MANAERP__Contact__c = a.Staff__c,
                MANAERP__Account__c = a.Location__c,
                MANAERP__Roles__c = 'Centre_Manager'));
        }
        if (!toInsert.isEmpty()) insert toInsert;
    }
}
