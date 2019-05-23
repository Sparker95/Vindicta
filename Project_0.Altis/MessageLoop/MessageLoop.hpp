// Coefficient for exponential moving average
// out = alpha*in + (1-alpha)*out
#define MOVING_AVERAGE_ALPHA 0.1

#define PROCESS_CATEGORY_ID_TAG 0
#define PROCESS_CATEGORY_ID_PRIORITY 1
#define PROCESS_CATEGORY_ID_EXECUTION_TIME_AVERAGE 2
#define PROCESS_CATEGORY_ID_MINIMUM_INTERVAL 3
#define PROCESS_CATEGORY_ID_OBJECTS 4
#define PROCESS_CATEGORY_ID_NEXT_OBJECT_ID 5

#define PROCESS_CATEGORY_NEW(tag, priority) [tag, priority, 1, 1, [], 0]

#define PROCESS_CATEGORY_OBJECT_NEW(object) [object, time]