/**
 * @description Useful Base Class for creating and inserting SObject records.
 **/
public abstract class SObjectTestData {
    private Map<Schema.SObjectField, Object> customValueMap;
    private Map<Schema.SObjectField, Object> defaultValueMap;

    private Boolean withMockId = false;

    /**
     * @description Subclasses of SObjectTestData should call super()
     *              from within constructors to invoke the setup() method.
     */
    public SObjectTestData() {
        reset();
    }

    /**
     * @description Retrieves the value set for the specified field.
     * @param field The Schema.SObjectField whos value we are retrieving.
     * @return An Object used when constructing SObjects for the specified field.
     */
    protected Object currentValueFor(Schema.SObjectField field) {
        Object val = customValueMap.get(field);
        if (val == null) {
            return getDefaultValueMapWithCaching().get(field);
        }
        return val;
    }

    /**
     * @description Generates a map of default values for this SObjectType.
     * @return The Map of SObjectFields to their corresponding default values.
     */
    protected abstract Map<Schema.SObjectField, Object> getDefaultValueMap();

    /**
     * @description Dynamically sets the Schema.SObjectField noted by field to value for
     *              SObjects being built.
     * @param field The Schema.SObjectField to map the value to and cannot be null.
     * @param value The value for the field and can be set to null.
     * @return The instance of SObjectTestData.
     */
    public SObjectTestData with(Schema.SObjectField field, Object value) {
        customValueMap.put(field, value);
        return this;
    }

    /**
     * @description Set the withMockId boolean to true, triggering the creation of
     *              records to generate a fake, mocked, record Id.
     * @return The instance of SObjectTestData.
     */
    public SObjectTestData withMockId() {
        withMockId = true;
        return this;
    }

    /**
     * @description Builds an instance of SObject dynamically and sets the instance's
     *              fields from the values in the customValueMap and defaultValueMap.
     * @return An instance of SObject.
     */
    private SObject build() {
        beforeBuild();
        SObject instance = getSObjectType().newSObject(null, true);
        Set<Schema.SObjectField> defaultFields = getDefaultValueMapWithCaching().keySet().clone();
        defaultFields.removeAll(customValueMap.keySet());

        for (Schema.SObjectField field : defaultFields) {
            instance.put(field, getDefaultValueMapWithCaching().get(field));
        }

        for (Schema.SObjectField field : customValueMap.keySet()) {
            instance.put(field, customValueMap.get(field));
        }
        afterBuild(instance);

        return instance;
    }

    /**
     * @description Builds an instance of SObject dynamically and sets the instance's
     *              fields from the values in the defaultValueMap.
     * @return An instance of SObject.
     */
    protected SObject buildDefault() {
        beforeBuild();
        SObject instance = getSObjectType().newSObject(null, true);

        for (Schema.SObjectField field : getDefaultValueMapWithCaching().keySet()) {
            instance.put(field, getDefaultValueMapWithCaching().get(field));
        }
        afterBuild(instance);

        return instance;
    }

    /**
     * @description Builds an instance of SObject dynamically and sets the instance's
     *              fields from the values in the customValueMap. Also clears
     *              the customValueMap.
     * @return An instance of SObject.
     */
    protected SObject buildWithReset() {
        SObject instance = build();
        reset();
        return instance;
    }

    /**
     * @description Builds an instance of SObject dynamically and sets the instance's
     *              fields from the values in the customValueMap map. This method does not
     *              clear the customValueMap.
     * @return An instance of SObject.
     */
    protected SObject buildWithoutReset() {
        return build();
    }

    /**
     * @description Resets the customValueMap.
     */
    protected void reset() {
        customValueMap = new Map<Schema.SObjectField, Object>();
    }

    /**
     * @description Inserts the built SObject.
     * @return The inserted SObject.
     */
    protected SObject insertRecord() {
        SObject instance = buildWithReset();
        beforeInsert(instance);
        insertIgnoringDupesAssertSuccess(instance);
        afterInsert(instance);
        return instance;
    }

    /**
     * @description Inserts the SObject built from only the defaults.
     * @return The inserted SObject.
     */
    protected SObject insertDefaultRecord() {
        SObject instance = buildDefault();
        beforeInsert(instance);
        insertIgnoringDupesAssertSuccess(instance);
        afterInsert(instance);
        return instance;
    }

    /**
     * @description Creates a list of SObject records.
     * @param numToCreate the number of SObject records to create.
     * @return The created SObject records.
     */
    protected List<SObject> createRecords(Integer numToCreate) {
        List<SObject> records = new List<SObject>();

        for (Integer i = 0; i < numToCreate; i++) {
            SObject record = buildWithoutReset();

            if (withMockId == true) {
                record.Id = DataMockService.Instance.generateId(getSObjectType());
            }

            records.add(record);
        }

        return records;
    }

    /**
     * @description Inserts a list of SObjects and ties into the before and after hooks.
     * @param numToInsert the number of SObjects to insert.
     * @return The inserted SObjects.
     */
    protected List<SObject> insertRecords(Integer numToInsert) {
        List<SObject> sobjectsToInsert = new List<SObject>();
        for (Integer i = 0; i < numToInsert; i++) {
            SObject sObj = buildWithoutReset();
            sobjectsToInsert.add(sObj);
            beforeInsert(sObj);
        }

        insertIgnoringDupesAssertSuccess(sobjectsToInsert);

        for (SObject sObj : sobjectsToInsert) {
            afterInsert(sObj);
        }

        return sobjectsToInsert;
    }

    /**
     * @description Get the Id of the desired RecordType name.
     * @param recordTypeName the name of the RecordType to get
     *        the Id of.
     * @return The Id of the desired RecordType name.
     */
    protected Id getRecordTypeId(String recordTypeName) {
        if (recordTypeName == null) {
            return null;
        }

        Map<String, RecordTypeInfo> infos = getSObjectType().getDescribe().getRecordTypeInfosByName();

        return (infos.containsKey(recordTypeName)) ? infos.get(recordTypeName).getRecordTypeId() : null;
    }

    /**
     * @description This method allows subclasses to invoke any action before
     *              the SObject is built.
     */
    protected virtual void beforeBuild() {}

    /**
     * @description This method allows subclasses to handle the SObject after
     *              it is built.
     * @param sObj The SObject that has been built.
     */
    protected virtual void afterBuild(SObject sObj) {}

    /**
     * @description This method allows subclasses to handle the SObject before
     *              it is inserted.
     * @param sObj The SObject that is going to be inserted.
     */
    protected virtual void beforeInsert(SObject sObj) {}

    /**
     * @description This method allows subclasses to handle the SObject after
     *              it is inserted.
     * @param sObj The SObject that has been inserted.
     */
    protected virtual void afterInsert(SObject sObj) {}

    /**
     * @description Returns the SObject type for this TestData builder.
     * @return A Schema.SObjectType.
     */
    protected abstract Schema.SObjectType getSObjectType();

    /**
     * @description Creates a random string with a default length of 10.
     * @return A randomly generated string.
     */
    protected String generateRandomString() {
        return generateRandomString(10);
    }

    /**
     * @description Creates a random string using the requested length. If length
     *              is null it will default to 10.
     * @param length The length of the string to be randomly generated. If this is
     *        null a length of 10 will be used as default.
     * @return A randomly generated string.
     */
    protected String generateRandomString(Integer length) {
        length = (length == null) ? 10 : length;

        String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz ';
        String randStr = '';

        while (randStr.length() < length) {
            Integer index = Math.mod(Math.abs( Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(index, index+1);
        }

        return randStr;
    }

    protected Boolean setMockEmail = false;

    protected void setMockEmail(SObject record) {
        if (!setMockEmail) {
            return;
        }

        String orgId = UserInfo.getOrganizationId();
        String currentDateTimeStamp = String.valueOf(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomNumber = Integer.valueOf(Math.rint(Math.random() * 1000000));
        String uniqueName = orgId + currentDateTimeStamp + randomNumber;
        String mockEmailAddress = uniqueName + '@test' + orgId + '.org';
        record.put('Email', mockEmailAddress);
    }

    protected void insertIgnoringDupesAssertSuccess(SObject record) {
        insertIgnoringDupesAssertSuccess(new List<SObject> { record });
    }

    protected void insertIgnoringDupesAssertSuccess(List<SObject> records) {
        Database.DMLOptions options = new Database.DMLOptions();
        options.duplicateRuleHeader.allowSave = true;
        options.duplicateRuleHeader.runAsCurrentUser = false;
        List<Database.SaveResult> results = Database.insert(records, options);

        for (Database.SaveResult result : results) {
            if (result.isSuccess()) {
                continue;
            }

            String errorMessages = '';

            for (Database.Error error : result.getErrors()) {
                errorMessages += error.getMessage() + '\n';
            }

            System.assert(false, 'Error occurred while inserting test record(s): ' + errorMessages);
        }
    }

    private Map<Schema.SObjectField, Object> getDefaultValueMapWithCaching() {
        if (this.defaultValueMap != null) {
            return this.defaultValueMap;
        }

        this.defaultValueMap = getDefaultValueMap();
        return this.defaultValueMap;
    }
}