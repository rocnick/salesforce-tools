/**
 * @description Provides mocking services for unit tests.
 */
public with sharing class DataMockService {
    @TestVisible private static final String SOBJECTTYPE_PARAM = 'sObjectType';

    private static final String PATTERN = '000000000000';

    private Map<Schema.SObjectType, Integer> sObjectTypeRecordCount = new Map<Schema.SObjectType, Integer>();

    /**
     * @description Generate a mock Id for a given SObjectType for use in Unit Tests.
     * @param sObjectType The SObject Type to generate an Id for.
     * @return A generated Id with the SObject's key prefix.
     * @throws ArgumentNullException if sObjectType is null.
     */
    public Id generateId(Schema.SObjectType sObjectType) {
        ArgumentNullException.throwIfNull(sObjectType, SOBJECTTYPE_PARAM);

        String prefix = sObjectType.getDescribe().getKeyPrefix();

        Integer recordCount = sObjectTypeRecordCount.get(sObjectType);
        recordCount = (recordCount == null) ? 0 : recordCount;
        recordCount++;
        sObjectTypeRecordCount.put(sObjectType, recordCount);

        return (Id) (prefix + (PATTERN.substring(0, PATTERN.length() - recordCount.format().length())) + recordCount);
    }

    /**
     * @description Singleton Instance property.
     */
    public static DataMockService Instance {
        get {
            if (Instance == null) {
                Instance = new DataMockService();
            }

            return Instance;
        }
        private set;
    }

    /**
     * @description Private constructor to protect the Singleton Instance.
     */
    private DataMockService() {}
}