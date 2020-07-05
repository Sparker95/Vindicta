// /*
// Struct: Stimulus
// File: AI\Stimulus\Stimulus.hpp
// */

// /* Field: TYPE
// Integer, stimulus type. See <STIMULUS_TYPE>*/
#define STIMULUS_ID_TYPE			0

// /* Field: SOURCE
// source of the stimulus*/
#define STIMULUS_ID_SOURCE			1

// /* Field: POS
// position of stimulus source*/
#define STIMULUS_ID_POS				2

// /* Field: RANGE
// How far it can be sensed*/
#define STIMULUS_ID_RANGE			3

// /* Field: VALUE
// Can be anything*/
#define STIMULUS_ID_VALUE			4

// /* Field: EXPIRATION_TIME
// NYI
// */
#define STIMULUS_ID_EXPIRATION_TIME	5

// /* Field: SIDES_INCLUDE
// Array of sides which can sense this stimulus. By default an empty array and every side can sense this.*/
#define STIMULUS_ID_SIDES_INCLUDE	6

// Macro: STIMULUS_NEW()
//                      0  1          2       3  4     5
#define STIMULUS_NEW() [0, 0, [0, 0, 0], 666666, 0, GAME_TIME, []]

// Macros for getting values
// Macro: STIMULUS_GET_TYPE(s)
#define STIMULUS_GET_TYPE(s) (s select STIMULUS_ID_TYPE)
// Macro: STIMULUS_GET_SOURCE(s)
#define STIMULUS_GET_SOURCE(s) (s select STIMULUS_ID_SOURCE)
// Macro: STIMULUS_GET_POS(s)
#define STIMULUS_GET_POS(s) (s select STIMULUS_ID_POS)
// Macro: STIMULUS_GET_RANGE(s)
#define STIMULUS_GET_RANGE(s) (s select STIMULUS_ID_RANGE)
// Macro: STIMULUS_GET_VALUE(s)
#define STIMULUS_GET_VALUE(s) (s select STIMULUS_ID_VALUE)
// Macro: STIMULUS_GET_EXPIRATION_TIME(s)
#define STIMULUS_GET_EXPIRATION_TIME(s) (s select STIMULUS_ID_EXPIRATION_TIME)


// Macros for setting values
// Macro: STIMULUS_SET_TYPE(s, val)
#define STIMULUS_SET_TYPE(s, val) s set [STIMULUS_ID_TYPE, val]
// Macro: STIMULUS_SET_SOURCE(s, val)
#define STIMULUS_SET_SOURCE(s, val) s set [STIMULUS_ID_SOURCE, val]
// Macro: STIMULUS_SET_POS(s, val)
#define STIMULUS_SET_POS(s, val) s set [STIMULUS_ID_POS, val]
// Macro: STIMULUS_SET_RANGE(s, val)
#define STIMULUS_SET_RANGE(s, val) s set [STIMULUS_ID_RANGE, val]
// Macro: STIMULUS_SET_VALUE(s, val)
#define STIMULUS_SET_VALUE(s, val) s set [STIMULUS_ID_VALUE, val]
// Macro: STIMULUS_SET_EXPIRATION_TIME(s, val)
#define STIMULUS_SET_EXPIRATION_TIME(s, val) s set [STIMULUS_ID_EXPIRATION_TIME, val]
// Macro: STIMULUS_SET_SIDES_INCLUDE(s, val)
#define STIMULUS_SET_SIDES_INCLUDE(s, val) s set [STIMULUS_ID_SIDES_INCLUDE, val]