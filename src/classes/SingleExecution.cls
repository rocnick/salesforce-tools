/**
 * @description Provides a management pattern to avoid recursion in contextually split
 *              tasks; e.g., Triggers and Batches.
 */
public class SingleExecution {
    private static Map<String, Boolean> processExecutionMap;

    /**
     * @description Checks the map of stored executions for the provided class name or
     *              key and returns true if it's already been registered and executed,
     *              else false.
     * @param ClassNameOrExecutionName The class or key to check for prior execution.
     * @return True if the class or key has executed already, else false.
     */
    public static Boolean hasAlreadyExecuted(String ClassNameOrExecutionName) {
        if (processExecutionMap != null) {
            Boolean alreadyExecuted = processExecutionMap.get(ClassNameOrExecutionName);
            if (alreadyExecuted != null) {
                return alreadyExecuted;
            }
        }

        //By default return false
        return false;
    }

    /**
     * @description Marks a class name or key as executed, storing it for later validation.
     * @param ClassNameOrExecutionName The class name or key to mark as already executed.
     */
    public static void setAlreadyExecuted(String ClassNameOrExecutionName) {
        if (processExecutionMap == null) {
            processExecutionMap = new Map<String, Boolean>();
        }

        processExecutionMap.put(ClassNameOrExecutionName, true);
    }

    /**
     * @description Sets the execution status of a class name or key to false.
     * @param ClassNameOrExecutionName The class name or key to reset execution status.
     */
    public static void resetAlreadyExecuted(String ClassNameOrExecutionName) {
        if (processExecutionMap == null) {
            processExecutionMap = new Map<String, Boolean>();
        }

        processExecutionMap.put(ClassNameOrExecutionName, false);
    }

    /**
     * @description Resets the execution state entirely.
     */
    public static void forceResetOfAlreadyExecuted() {
        processExecutionMap = null;
    }
}