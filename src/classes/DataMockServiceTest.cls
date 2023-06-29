@IsTest
private with sharing class DataMockServiceTest {
    @IsTest
    private static void generateId_nullParam_expectArgumentNullException() {
        try {
            Test.startTest();
            DataMockService.Instance.generateId(null);
        } catch (Exception e) {
            TestHelper.assertArgumentNullException(e, DataMockService.SOBJECTTYPE_PARAM);
        } finally {
            Test.stopTest();
        }
    }

    @IsTest
    private static void generateId_contactSObjectType_expectContactRecordIdReturned() {
        Test.startTest();
        Id generatedId = DataMockService.Instance.generateId(Contact.SObjectType);
        Test.stopTest();

        String contactPrefix = Contact.SObjectType.getDescribe().getKeyPrefix();
        String prefix = String.valueOf(generatedId).substring(0, 3);

        System.assertEquals(contactPrefix, prefix, 'Expected a prefix of ' + contactPrefix + '.');
    }
}