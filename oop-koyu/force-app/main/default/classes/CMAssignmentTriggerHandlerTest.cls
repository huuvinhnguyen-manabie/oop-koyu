@IsTest
private class CMAssignmentTriggerHandlerTest {

    // Center-Location Account via the repo's local data factory (sets Location
    // record type + MANAERP__Location_Type__c = 'Center', satisfying the Location__c
    // lookup filter).
    private static Account makeLocation() {
        return AccountDataTest.createCenterLocations(1)[0];
    }

    // Staff Contact(s) via the local factory ('Staff' record type satisfies the
    // Staff__c lookup filter; final flag inserts the records).
    private static List<Contact> makeStaff(Integer count) {
        return UserTestDataFactory.createContacts(count, 'Staff', true);
    }

    @IsTest
    static void createsAffiliationWhenNoneExists() {
        Account loc = makeLocation();
        Contact staff = makeStaff(1)[0];

        Test.startTest();
        insert new CM_Assignment__c(Location__c = loc.Id, Staff__c = staff.Id,
                                    Start_Date__c = Date.today());
        Test.stopTest();

        List<MANAERP__Affiliation__c> affs = [
            SELECT MANAERP__Roles__c FROM MANAERP__Affiliation__c
            WHERE MANAERP__Contact__c = :staff.Id AND MANAERP__Account__c = :loc.Id];
        System.assertEquals(1, affs.size(), 'One affiliation should be created');
        System.assert(affs[0].MANAERP__Roles__c.contains('Centre_Manager'),
                      'Role should be Centre_Manager');
    }

    @IsTest
    static void doesNotDuplicateExistingAffiliation() {
        Account loc = makeLocation();
        Contact staff = makeStaff(1)[0];
        insert new MANAERP__Affiliation__c(MANAERP__Contact__c = staff.Id,
            MANAERP__Account__c = loc.Id, MANAERP__Roles__c = 'Centre_Staff');

        Test.startTest();
        insert new CM_Assignment__c(Location__c = loc.Id, Staff__c = staff.Id,
                                    Start_Date__c = Date.today());
        Test.stopTest();

        Integer count = [SELECT COUNT() FROM MANAERP__Affiliation__c
                         WHERE MANAERP__Contact__c = :staff.Id AND MANAERP__Account__c = :loc.Id];
        System.assertEquals(1, count, 'No duplicate affiliation should be created');
    }

    @IsTest
    static void skipsProvisioningWhenFlagged() {
        Account loc = makeLocation();
        Contact staff = makeStaff(1)[0];

        Test.startTest();
        insert new CM_Assignment__c(Location__c = loc.Id, Staff__c = staff.Id,
                                    Start_Date__c = Date.today(),
                                    Skip_Affiliation_Provisioning__c = true);
        Test.stopTest();

        Integer count = [SELECT COUNT() FROM MANAERP__Affiliation__c
                         WHERE MANAERP__Contact__c = :staff.Id AND MANAERP__Account__c = :loc.Id];
        System.assertEquals(0, count, 'Skip-flagged rows must not provision');
    }

    @IsTest
    static void bulkInsertProvisionsUniquely() {
        Account loc = makeLocation();
        List<Contact> staff = makeStaff(200);

        List<CM_Assignment__c> rows = new List<CM_Assignment__c>();
        for (Contact c : staff) {
            rows.add(new CM_Assignment__c(Location__c = loc.Id, Staff__c = c.Id,
                                          Start_Date__c = Date.today()));
        }

        Test.startTest();
        insert rows;
        Test.stopTest();

        Integer count = [SELECT COUNT() FROM MANAERP__Affiliation__c
                         WHERE MANAERP__Account__c = :loc.Id];
        System.assertEquals(200, count, 'One affiliation per unique staff');
    }
}
