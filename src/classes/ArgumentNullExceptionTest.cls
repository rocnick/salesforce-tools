@IsTest
private class ArgumentNullExceptionTest {
    private static final String TEST_VAR = 'testVar';

    @IsTest
    private static void throwIfNull_objIsNull_expectException() {
        try {
            Test.startTest();
            ArgumentNullException.throwIfNull(null, TEST_VAR);
            TestHelper.expectedArgumentNullException();
        } catch (Exception e) {
            TestHelper.assertArgumentNullException(e, TEST_VAR);
        } finally {
            Test.stopTest();
        }
    }

    @IsTest
    private static void throwIfNull_objIsNotNull_expectNoException() {
        try {
            Test.startTest();
            ArgumentNullException.throwIfNull('Not Null', TEST_VAR);
        } catch (Exception e) {
            System.assert(false, 'Expected there to be no exception thrown.');
        } finally {
            Test.stopTest();
        }
    }
}