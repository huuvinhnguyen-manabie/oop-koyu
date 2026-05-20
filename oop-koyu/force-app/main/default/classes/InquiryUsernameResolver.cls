public without sharing class InquiryUsernameResolver {
    /**
     * Checks whether the given parent contact's MANAERP__Username__c already exists
     * on another Contact. If so, appends +N before the @ sign to make it unique.
     * Only modifies MANAERP__Username__c — the Email field is left unchanged.
     *
     * @param parentContact The Contact record (not yet inserted) whose username to deduplicate.
     */
    public static void resolveUniqueUsername(Contact parentContact) {
        if (parentContact == null || String.isBlank(parentContact.MANAERP__Username__c)) {
            return;
        }

        String username = parentContact.MANAERP__Username__c;
        Integer atIndex = username.indexOf('@');
        if (atIndex < 0) {
            return;
        }

        String localPart = username.substring(0, atIndex);
        String domain = username.substring(atIndex + 1);
        String plusPattern = localPart + '+%@' + domain;

        List<Contact> existingContacts = [
            SELECT MANAERP__Username__c
            FROM Contact
            WHERE MANAERP__Username__c = :username
               OR MANAERP__Username__c LIKE :plusPattern
        ];

        Set<String> existingUsernames = new Set<String>();
        for (Contact c : existingContacts) {
            existingUsernames.add(c.MANAERP__Username__c.toLowerCase());
        }

        if (existingUsernames.isEmpty()) {
            return;
        }

        Integer i = 1;
        String candidate;
        do {
            candidate = localPart + '+' + i + '@' + domain;
            i++;
        } while (existingUsernames.contains(candidate.toLowerCase()));

        parentContact.MANAERP__Username__c = candidate;
    }
}