/**
 * @description A collection of helpers for unit tests.
 */
@IsTest
public class TestHelper {
    private static final String EXCEPTION_NAME_PARAM = 'exceptionName';
    private static final String PARAM_PARAM = 'param';
    private static final String MESSAGE_PARAM = 'message';
    private static final String E_PARAM = 'e';

    private static final String EXPECTED_EXCEPTION_ERROR = 'Expected a(n) {0} to be thrown.';
    private static final String EXPECTED_MESSAGE_ERROR = 'The exception thrown does not match the expected message.';

    /**
     * @description Asserts that the test was expecting an ArgumentNullException to be thrown.
     */
    public static void expectedArgumentNullException() {
        expectedException(ArgumentNullException.class.getName());
    }

    /**
     * @description Asserts that the test was expecting an ConfigurationException to be thrown.
     */
    public static void expectedConfigurationException() {
        expectedException(ConfigurationException.class.getName());
    }

    /**
     * @description Asserts that the test was expecting a given exception to be thrown, as passed
     *              in using the exceptionName parameter.
     * @param exceptionName The name of the expected exception.
     * @throws ArgumentNullException if exceptionName is null.
     */
    public static void expectedException(String exceptionName) {
        ArgumentNullException.throwIfNull(exceptionName, EXCEPTION_NAME_PARAM);

        System.assert(false, String.format(EXPECTED_EXCEPTION_ERROR, new List<String> { exceptionName }));
    }

    /**
     * @description Validates that the test threw a given exception to be thrown, as passed in
     *              using the exceptionName parameter.
     * @param e The thrown exception.
     * @param exceptionName The name of the expected exception.
     * @throws ArgumentNullException if e or exceptionName is null.
     */
    public static void assertExpectedException(Exception e, String exceptionName) {
        ArgumentNullException.throwIfNull(e, E_PARAM);
        ArgumentNullException.throwIfNull(exceptionName, EXCEPTION_NAME_PARAM);

        System.assertEquals(exceptionName, e.getTypeName(), 'Expected an exception of type: ' + exceptionName +
                '. Received Exception of type: ' + e.getTypeName() + '.');
    }

    /**
     * @description Asserts that the given exception is an ArgumentNullException and that the message
     *              matches the expected message.
     * @param e The thrown exception.
     * @param param The parameter that was checked, and is expected to be named in the message.
     * @throws ArgumentNullException if either of the parameters are null.
     */
    public static void assertArgumentNullException(Exception e, String param) {
        ArgumentNullException.throwIfNull(e, E_PARAM);
        ArgumentNullException.throwIfNull(param, PARAM_PARAM);

        if (!(e instanceof ArgumentNullException)) {
            System.assert(false, String.format(EXPECTED_EXCEPTION_ERROR,
                    new List<String> { ArgumentNullException.class.getName() }));
        }

        String expectedMessage = String.format(ArgumentNullException.ARGUMENT_NULL_EXCEPTION_ERROR,
                new List<String> { param });
        System.assertEquals(expectedMessage, e.getMessage(), EXPECTED_MESSAGE_ERROR);
    }

    /**
     * @description Asserts that the given exception is a ConfigurationException and that the message
     *              matches the expected message.
     * @param e The thrown exception.
     * @param message The message that was checked, and is expected to be named in the message.
     * @throws ArgumentNullException if either of the parameters are null.
     */
    public static void assertConfigurationException(Exception e, String message) {
        ArgumentNullException.throwIfNull(e, E_PARAM);
        ArgumentNullException.throwIfNull(message, MESSAGE_PARAM);

        if (!(e instanceof ConfigurationException)) {
            System.assert(false, String.format(EXPECTED_EXCEPTION_ERROR,
                    new List<String> { ArgumentNullException.class.getName() }));
        }

        System.assertEquals(message, e.getMessage(), 'The expected exception message: "' + message +
                '" not thrown. Instead: "' + e.getMessage() + '" thrown.');
    }
}