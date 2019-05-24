// Coefficient for exponential moving average
// out = alpha*in + (1-alpha)*out
#define MOVING_AVERAGE_ALPHA 0.05

// The timer we use to measure time
#define PROCESS_CATEGORY_TIME diag_tickTime

#define PROCESS_CATEGORY_ID_TAG 0
#define PROCESS_CATEGORY_ID_PRIORITY 1
// Average time this thread has spent processing objects of this category
#define PROCESS_CATEGORY_ID_EXECUTION_TIME_AVERAGE 2
#define PROCESS_CATEGORY_ID_MINIMUM_INTERVAL 3
#define PROCESS_CATEGORY_ID_OBJECTS 4
#define PROCESS_CATEGORY_ID_NEXT_OBJECT_ID 5

// Below are fields which are used only when thread debug is enabled

// Last time we processed object with index 0, we use this timer to calculate how often we can process objects
#define PROCESS_CATEGORY_ID_FIRST_OBJECT_PROCESS_TIME 6
// Total time of process calls of objects, we reset it periodycally, used for debug
#define PROCESS_CATEGORY_ID_OBJECT_CALL_TIME_TOTAL 7
// Average time of process calls to objects
#define PROCESS_CATEGORY_ID_OBJECT_CALL_TIME_AVERAGE 8
// Update interval of all objects (measured from PROCESS_CATEGORY_ID_FIRST_OBJECT_PROCESS_TIME)
#define PROCESS_CATEGORY_ID_UPDATE_INTERVAL 9

#define PROCESS_CATEGORY_NEW(tag, priority, minInterval) [tag, priority, 1, minInterval, [], 0, PROCESS_CATEGORY_TIME, 0, 0.666, 0.666]

#define PROCESS_CATEGORY_OBJECT_NEW(object) [object, PROCESS_CATEGORY_TIME]