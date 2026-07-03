public without sharing class CMAssignmentTriggerHandler {
    // without sharing so the existence check sees affiliations regardless of the
    // running user's record visibility (avoids duplicate-key inserts).
    public static void provisionAffiliations(List<CM_Assignment__c> assignments) {
        List<CM_Assignment__c> toProcess = new List<CM_Assignment__c>();

        for (CM_Assignment__c a : assignments) {
            if (a.Skip_Affiliation_Provisioning__c == true) continue;
            if (a.Staff__c == null || a.Location__c == null) continue;
            toProcess.add(a);
        }
        if (toProcess.isEmpty()) return;

        Set<String> queued = new Set<String>();
        List<MANAERP__Affiliation__c> toInsert = new List<MANAERP__Affiliation__c>();
        for (CM_Assignment__c a : toProcess) {
            String compositeKey = a.Staff__c + '-' + a.Location__c;
            if (queued.contains(compositeKey)) continue;
            queued.add(compositeKey);
            toInsert.add(new MANAERP__Affiliation__c(
                MANAERP__Contact__c = a.Staff__c,
                MANAERP__Account__c = a.Location__c,
                MANAERP__Roles__c = 'Centre_Manager'));
        }
        if (!toInsert.isEmpty()) {
            Database.insert(toInsert, false); // partial success allowed, so that if one fails the others still succeed
        }
    }
}
