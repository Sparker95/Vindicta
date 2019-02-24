#define TIMER_DATA_ID_INTERVAL			0
#define TIMER_DATA_ID_TIME_NEXT			1
#define TIMER_DATA_ID_MESSAGE			2
#define TIMER_DATA_ID_MESSAGE_RECEIVER	3
#define TIMER_DATA_ID_TIMER_SERVICE		4
// Id of the previously sent message
#define TIMER_DATA_ID_MESSAGE_ID		5
// MessageLoop of this message receiver (so that we don't need to get it every time)
#define TIMER_DATA_ID_MESSAGE_LOOP		6

//							0,      1,  2,  3,  4,  5,  6
#define TIMER_DATA_DEFAULT [1, time+1, [], "", "", -1, ""]