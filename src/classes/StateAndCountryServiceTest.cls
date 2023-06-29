@IsTest
private class StateAndCountryServiceTest {
    @IsTest
    private static void getAllCountries_expectAllCountriesReturned() {
        List<StateAndCountryService.Country> countries;
        Boolean stateAndCountryPicklistsEnabled = true;

        try {
            Test.startTest();
            countries = StateAndCountryService.Instance.getAllCountries();
        } catch (Exception e) {
            TestHelper.assertConfigurationException(e, StateAndCountryService.STATE_COUNTRY_PICKLIST_NOT_ENABLED_ERROR);
            stateAndCountryPicklistsEnabled = false;
        } finally {
            Test.stopTest();
        }

        if (!stateAndCountryPicklistsEnabled) {
            return;
        }

        // Build an easy to access map for assertions
        Map<String, StateAndCountryService.Country> countriesByCountryCode =
                new Map<String, StateAndCountryService.Country>();
        for (StateAndCountryService.Country country : countries) {
            countriesByCountryCode.put(country.CountryCode, country);
        }

        // Assert that every country in the picklist is returned
        SObjectField countryCodeField = Schema.getGlobalDescribe()
                .get('User').getDescribe().fields.getMap().get('CountryCode');
        List<Schema.PicklistEntry> picklistEntries = countryCodeField.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry picklistEntry : picklistEntries) {
            StateAndCountryService.Country country = countriesByCountryCode.get(picklistEntry.getValue());

            System.assertNotEquals(null, country, 'Expected a country returned.');
            System.assertEquals(picklistEntry.getLabel(), country.CountryName, 'Expected the Country Names to match.');
        }
    }

    @IsTest
    private static void getAllCountriesWithStates_expectMockedCountriesWithStatesReturned() {
        Test.setMock(HttpCalloutMock.class, new StateAndCountryServiceMock());

        List<StateAndCountryService.Country> countriesWithStates;
        Boolean stateAndCountryPicklistsEnabled = true;

        try {
            Test.startTest();
            countriesWithStates = StateAndCountryService.Instance.getAllCountriesWithStates();
        } catch (Exception e) {
            TestHelper.assertConfigurationException(e, StateAndCountryService.STATE_COUNTRY_PICKLIST_NOT_ENABLED_ERROR);
            stateAndCountryPicklistsEnabled = false;
        } finally {
            Test.stopTest();
        }

        if (!stateAndCountryPicklistsEnabled) {
            return;
        }

        Set<String> countryNames = new Set<String> {
                'United States',
                'Canada',
                'Brazil'
        };

        Set<String> stateNames = new Set<String> {
                'AA',
                'AB',
                'Acre'
        };

        SObjectField countryCodeField = Schema.getGlobalDescribe()
                .get('User').getDescribe().fields.getMap().get('CountryCode');
        List<Schema.PicklistEntry> countryPicklistEntries = countryCodeField.getDescribe().getPicklistValues();

        // The results are mocked, so just assert that what was mocked exists
        // All countries will return from the picklist, so assert against that size
        System.assertEquals(countryPicklistEntries.size(), countriesWithStates.size(),
                'Expected ' + countryPicklistEntries.size() + ' countries returned.');
        for (StateAndCountryService.Country country : countriesWithStates) {
            if (countryNames.contains(country.CountryName)) {
                System.assertEquals(1, country.States.size(), 'Expected 1 State returned');
                System.assert(stateNames.contains((new List<StateAndCountryService.State>(country.States)[0]).StateName),
                        'Expected the returned State to be in the pre-defined set.');
            }
        }
    }
}