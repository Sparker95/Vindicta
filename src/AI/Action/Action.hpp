// Class: Action
// /*
// Enum: ACTION_STATE
// These are possible action states

// ACTION_STATE_ACTIVE - 
// ACTION_STATE_INACTIVE -
// ACTION_STATE_COMPLETED -
// ACTION_STATE_FAILED -
// */

// States of a goal
#define ACTION_STATE_ACTIVE		0
#define ACTION_STATE_INACTIVE	1
#define ACTION_STATE_COMPLETED	2
#define ACTION_STATE_FAILED		3
#define ACTION_STATE_REPLAN		4

#define ACTION_STATE_TEXT_ARRAY ["ACTIVE", "INACTIVE", "COMPLETED", "FAILED", "REPLAN"]

gDebugActionStateText = [
	"ACTIVE",
	"INACTIVE",
	"COMPLETED",
	"FAILED",
	"REPLAN"
];

#define GET_PARAMETER_VALUE(array, tag) CALLSM2("Action", "getParameterValue", array, tag)
#define GET_PARAMETER_VALUE_DEFAULT(array, tag, defaultValue) CALLSM3("Action", "getParameterValue", array, tag, defaultValue)