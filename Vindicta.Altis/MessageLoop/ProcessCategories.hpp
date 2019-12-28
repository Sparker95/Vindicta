// Coefficient for exponential moving average
// out = alpha*in + (1-alpha)*out
#define MOVING_AVERAGE_ALPHA 0.05

// The timer we use to measure time
#define PROCESS_CATEGORY_TIME diag_tickTime

#define __PC_ID_TAG 0
#define __PC_ID_PRIORITY 1
// Average time this thread has spent processing objects of this category
#define __PC_ID_EXECUTION_TIME_AVERAGE 2
#define __PC_ID_UPDATE_INTERVAL_MIN 3
#define __PD_ID_UPDATE_INTERVAL_MAX 4
#define __PC_ID_NEXT_OBJECT_ID 5
#define __PC_ID_UPDATE_INTERVAL_LAST 6
#define __PC_ID_UPDATE_INTERVAL_AVERAGE 7
#define __PC_ID_LAST_OBJECT_PROCESS_TIMESTAMP 8
#define __PC_ID_OBJECTS 9
#define __PC_ID_ALL_PROCESS_LAST_TIMESTAMP 10
#define __PC_ID_ALL_PROCESS_INTERVAL 11

#define __PC_NEW(tag, priority, minInterval, maxInterval) [tag, priority, -1, minInterval, maxInterval, 0, 1.1*maxInterval, 1.1*maxInterval, PROCESS_CATEGORY_TIME, [], PROCESS_CATEGORY_TIME, -1]

#define __PC_OBJECT_NEW(object) [object, PROCESS_CATEGORY_TIME]