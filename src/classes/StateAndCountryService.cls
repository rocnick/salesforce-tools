/**
 * @description Handles interaction with State and Country picklists via the SFDC REST API.
 */
public with sharing class StateAndCountryService {
    @TestVisible private static final String MAILING_STATE_REST_ENDPOINT_URL =
            '{0}/services/data/v52.0/ui-api/object-info/Contact/picklist-values/{1}/MailingStateCode';
    @TestVisible private static final String MASTER_CONTACT_RECORD_TYPE_NAME = 'Master';

    @TestVisible private static final String NO_MASTER_CONTACT_RECORD_TYPE_ERROR =
            'There was no Record Type named \'Master\' found on the Contact object.';

    @TestVisible private static final String STATE_COUNTRY_PICKLIST_NOT_ENABLED_ERROR =
            'State and Country Picklists are not enabled in this org. Please check your configuration.';

    /**
     * @description Use the singleton below.
     */
    private StateAndCountryService() { }

    /**
     * @description Singleton for interacting with StateAndCountryService.
     */
    public static StateAndCountryService Instance {
        get {
            if (Instance == null) {
                Instance = new StateAndCountryService();
            }

            return Instance;
        }

        private set;
    }

    /**
     * @description Queries the Salesforce Schema and collects the State and Country
     *              Picklist values of Country and Country Codes, wrapping them in the
     *              Country custom type in this class.
     * @return A list of Countries with Country Codes based on State and Country Picklist
     *         definitions.
     */
    public List<Country> getAllCountries() {
        List<Country> countries = new List<Country>();

        SObjectField countryCodeField = Schema.getGlobalDescribe()
                .get('User').getDescribe().fields.getMap().get('CountryCode');
        if (countryCodeField == null) {
            throw new ConfigurationException(STATE_COUNTRY_PICKLIST_NOT_ENABLED_ERROR);
        }

        List<Schema.PicklistEntry> picklistEntries = countryCodeField.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry picklistEntry : picklistEntries) {
            Country country = new Country();

            country.CountryCode = picklistEntry.getValue();
            country.CountryName = picklistEntry.getLabel();

            countries.add(country);
        }

        return countries;
    }

    /**
     * @description Queries the Salesforce REST API for State and Country Picklist dependencies,
     *              building out a relationship for use throughout the system.
     * @return A list of Countries with their associated State/Provinces.
     * @throws ConfigurationException if no Master Contact RecordType is found.
     */
    public List<Country> getAllCountriesWithStates() {
        // Get the Master Contact Record Type to use when querying for picklist values
        RecordTypeInfo contactMasterRecordTypeInfo = Contact.getSObjectType()
                .getDescribe().getRecordTypeInfosByName().get(MASTER_CONTACT_RECORD_TYPE_NAME);
        if (contactMasterRecordTypeInfo == null) {
            throw new ConfigurationException(NO_MASTER_CONTACT_RECORD_TYPE_ERROR);
        }

        // Build out the REST endpoint
        String contactUrl = String.format(MAILING_STATE_REST_ENDPOINT_URL, new List<String> {
                Url.getOrgDomainUrl().toExternalForm(),
                contactMasterRecordTypeInfo.getRecordTypeId() });

        // Generate Header info
        String oAuthHeader = 'OAuth ' + UserInfo.getSessionId();
        String bearerHeader = 'Bearer ' + UserInfo.getSessionId();

        // Build out the Http Request
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('GET');
        httpRequest.setHeader('Authorization', oAuthHeader);
        httpRequest.setHeader('Authorization', bearerHeader);
        httpRequest.setEndpoint(contactUrl);
        String response = '';

        // Actually execute the request and clean up the response
        try {
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);

            if (httpResponse.getStatusCode() != 200) {
                throw new CalloutException(httpResponse.getBody());
            }

            response = JSON.serializePretty(JSON.deserializeUntyped(httpResponse.getBody()));
        } catch (System.Exception e) {
            System.debug(e);
        }

        // Parse the JSON response into Apex wrappers
        StateCountryResponse scr = (StateCountryResponse) JSON.deserializeStrict(response, StateCountryResponse.class);
        Map<Integer, Set<State>> statesByCountryMappingId = getStatesByCountryMappingId(scr);

        return getCountriesWithStates(scr, statesByCountryMappingId);
    }

    /**
     * @description Country and Country Code custom type for use throughout the system.
     *              Typically populated by State and Country Picklist outputs.
     */
    public class Country {
        /**
         * @description The name of the Country.
         */
        public String CountryName { get; set; }

        /**
         * @description The Country Code for the Country.
         */
        public String CountryCode { get; set; }

        /**
         * @description The State/Provinces that fall within this Country based on the
         *              configuration of State and Country Picklists.
         */
        public Set<State> States { get; set; }
    }

    /**
     * @description State/Province Name and State Code custom type for use throughout
     *              the system. Typically populated by State and Country picklist outputs.
     */
    public class State {
        /**
         * @description The name of the State/Province.
         */
        public String StateName { get; set; }

        /**
         * @description The State Code for the State.
         */
        public String StateCode { get; set; }
    }

    private List<Country> getCountriesWithStates(StateCountryResponse scr, Map<Integer, Set<State>> statesByCountryMappingId) {
        List<Country> countries = new List<Country>();

        // Build out the country and state mappings
        SObjectField countryCodeField = Schema.getGlobalDescribe()
                .get('User').getDescribe().fields.getMap().get('CountryCode');
        if (countryCodeField == null) {
            throw new ConfigurationException(STATE_COUNTRY_PICKLIST_NOT_ENABLED_ERROR);
        }

        List<Schema.PicklistEntry> picklistEntries = countryCodeField.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry picklistEntry : picklistEntries) {
            Country country = new Country();
            country.CountryCode = picklistEntry.getValue();
            country.CountryName = picklistEntry.getLabel();

            // This shouldn't happen, but just in case we're going to safeguard it
            Integer countryMappingId = scr.controllerValues.get(country.CountryCode);
            if (countryMappingId == null) {
                countries.add(country);
                continue;
            }

            country.States = statesByCountryMappingId.get(countryMappingId);
            countries.add(country);
        }

        return countries;
    }

    private Map<Integer, Set<State>> getStatesByCountryMappingId(StateCountryResponse scr) {
        Map<Integer, Set<State>> statesByCountryMappingId = new Map<Integer, Set<State>>();

        // Build out a map of Country Mapping Ids to correlated States
        SObjectField stateCodeField = Schema.getGlobalDescribe()
                .get('User').getDescribe().fields.getMap().get('StateCode');
        if (stateCodeField == null) {
            throw new ConfigurationException(STATE_COUNTRY_PICKLIST_NOT_ENABLED_ERROR);
        }

        List<Schema.PicklistEntry> statePicklistEntries = stateCodeField.getDescribe().getPicklistValues();
        Map<String, String> stateNameByCode = new Map<String, String>();
        for (Schema.PicklistEntry statePicklistEntry : statePicklistEntries) {
            stateNameByCode.put(statePicklistEntry.getValue(), statePicklistEntry.getLabel());
        }

        for (StateValue stateValue : scr.values) {
            State state = new State();
            state.StateCode = stateValue.value;
            state.StateName = stateNameByCode.get(state.StateCode);

            for (Integer validFor : stateValue.validFor) {
                Set<State> states = statesByCountryMappingId.get(validFor);
                if (states == null) {
                    states = new Set<State>();
                }

                states.add(state);
                statesByCountryMappingId.put(validFor, states);
            }
        }

        return statesByCountryMappingId;
    }

    /**
     * @description The custom type used to deserialize the REST API response.
     */
    private class StateCountryResponse {
        private List<StateValue> values { get; set; }
        private Map<String, Integer> controllerValues { get; set; }
        private String url { get; set; }
        private String eTag { get; set; }
        private String defaultValue { get; set; }
    }

    /**
     * @description The custom type used to deserialize the REST API response.
     */
    private class StateValue {
        private String value { get; set; }
        private Set<Integer> validFor { get; set; }
        private String label { get; set; }
        private String attributes { get; set; }
    }
}