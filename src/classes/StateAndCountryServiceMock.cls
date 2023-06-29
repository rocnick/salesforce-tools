/**
 * @description Mocks the Http Response that gets returned in the
 *              StateAndCountryService for Apex Unit Tests.
 */
@IsTest
public without sharing class StateAndCountryServiceMock implements HttpCalloutMock {
    /**
     * @description Mocks an HttpResponse for unit test purposes.
     * @param req The HttpRequest to process and respond to.
     * @return An HttpResponse with the example set to the body.
     */
    public HttpResponse respond(HttpRequest req) {
        System.assertEquals('GET', req.getMethod(), 'This service is only intended for GET purposes.');

        // A paired down example response from the State/Country endpoint
        String response = '{\n' +
                '  "values" : [ {\n' +
                '    "value" : "AA",\n' +
                '    "validFor" : [ 235 ],\n' +
                '    "label" : "AA",\n' +
                '    "attributes" : null\n' +
                '  }, {\n' +
                '    "value" : "AB",\n' +
                '    "validFor" : [ 39 ],\n' +
                '    "label" : "AB",\n' +
                '    "attributes" : null\n' +
                '  }, {\n' +
                '    "value" : "AC",\n' +
                '    "validFor" : [ 31 ],\n' +
                '    "label" : "Acre",\n' +
                '    "attributes" : null\n' +
                '  } ],\n' +
                '  "url" : "/services/data/v52.0/ui-api/object-info/Contact/picklist-values/012000000000000AAA/MailingStateCode",\n' +
                '  "eTag" : "d6ebe40781f1454166a308a7012354ef",\n' +
                '  "defaultValue" : null,\n' +
                '  "controllerValues" : {\n' +
                '    "US" : 235,\n' +
                '    "CA" : 39,\n' +
                '    "BR" : 31\n' +
                '  }\n' +
                '}';

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(response);
        res.setStatusCode(200);
        return res;
    }
}