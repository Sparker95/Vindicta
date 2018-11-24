// Integer, stimulus type
#define STIMULUS_ID_TYPE			0

// Source of the stimulus
#define STIMULUS_ID_SOURCE			1


#define STIMULUS_ID_POS				2


// How far it can be sensed
#define STIMULUS_ID_RANGE			3


#define STIMULUS_ID_VALUE			4


#define STIMULUS_ID_EXPIRATION_TIME	5

//                      0  1          2       3  4     5
#define STIMULUS_NEW() [0, 0, [0, 0, 0], 666666, 0, time]

// Macros for getting values

#define STIMULUS_GET_TYPE(s) (s select STIMULUS_ID_TYPE)

#define STIMULUS_GET_SOURCE(s) (s select STIMULUS_ID_SOURCE)

#define STIMULUS_GET_POS(s) (s select STIMULUS_ID_POS)

#define STIMULUS_GET_RANGE(s) (s select STIMULUS_ID_RANGE)

#define STIMULUS_GET_VALUE(s) (s select STIMULUS_ID_VALUE)

#define STIMULUS_GET_EXPIRATION_TIME(s) (s select STIMULUS_ID_EXPIRATION_TIME)



// Macros for setting values
#define STIMULUS_SET_TYPE(s, val) s set [STIMULUS_ID_TYPE, val]

#define STIMULUS_SET_SOURCE(s, val) s set [STIMULUS_ID_SOURCE, val]

#define STIMULUS_SET_POS(s, val) s set [STIMULUS_ID_POS, val]

#define STIMULUS_SET_RANGE(s, val) s set [STIMULUS_ID_RANGE, val]

#define STIMULUS_SET_VALUE(s, val) s set [STIMULUS_ID_VALUE, val]

#define STIMULUS_SET_EXPIRATION_TIME(s, val) s set [STIMULUS_ID_EXPIRATION_TIME, val]