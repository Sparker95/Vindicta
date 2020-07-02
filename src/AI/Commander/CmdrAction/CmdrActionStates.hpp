

// /*
// Enum: AI.CmdrAI.CmdrAction.CMDR_ACTION_STATE

// <ActionStateTransitions> are used by <CmdrAction> to transition between these states.

// CMDR_ACTION_STATE_NONE - Indicates no change to the current state, return from 
// <ActionStateTransition.update> when the update didn't cause a state change, e.g. on a long running
// AST that is currently in progress but not yet finished, like a garrison move or wait.

// CMDR_ACTION_STATE_START - Indicates the final state of a CmdrAction, once it is completed 
// (successfully or not). The any final ASTs should transition TO this state.

// CMDR_ACTION_STATE_END - Indicates the final state of a CmdrAction, once it is completed 
// (successfully or not). The any final ASTs should transition TO this state.

// CMDR_ACTION_STATE_ALL - Used in places to indicate that ALL states are being considered 
// (in whatever context that makes sense).

// CMDR_ACTION_STATE_CUSTOM - Lowest value for custom states, as seen below.
// CMDR_ACTION_STATE_SPLIT - After a garrison is split into tw
// CMDR_ACTION_STATE_READY_TO_MOVE - When a garrison is ready toove
// CMDR_ACTION_STATE_MOVED - After a garrison has completed a mo
// CMDR_ACTION_STATE_TARGET_DEAD - When a target is dead, could beuccess or failure state depending on the context (e.g. kill or join)
// CMDR_ACTION_STATE_ARRIVED - When a garrison has arrived somwher
// CMDR_ACTION_STATE_ASSIGNED - When a garrison has been assigd an action
// CMDR_ACTION_STATE_RTB - When a garrison should return to ba
// CMDR_ACTION_STATE_RTB_SUCCESS - After a garrison has successfully returned to ba
// CMDR_ACTION_STATE_RTB_SELECT_TARGET - When a garrison needs to select a target for R
// CMDR_ACTION_STATE_FAILED_OUT_OF_RANGE - When an AST fails due to an out of rnge errorof some kind
// CMDR_ACTION_STATE_FAILED_GARRISON_DEAD - When as AST fails due to a garrisoneing dead
// CMDR_ACTION_STATE_FAILED_TIMEOUT - When an AST fails due to a generic time o
// CMDR_ACTION_STATE_NEXT_WAYPOINT - When the next waypoint in a route should be selcted
// CMDR_ACTION_STATE_FINISHED_WAYPOINTS - When there are no more waypoints in a route
// */


// It is perfectly fine to add new values here, you don't have to use these ones, except for:
#define CMDR_ACTION_STATE_NONE		-1000
#define CMDR_ACTION_STATE_START 	0
#define CMDR_ACTION_STATE_END 		1
#define CMDR_ACTION_STATE_ALL 		-1
#define CMDR_ACTION_STATE_CUSTOM	1000

#define CMDR_ACTION_STATE_SPLIT								(CMDR_ACTION_STATE_CUSTOM+1)
// When a garrison is ready to move
#define CMDR_ACTION_STATE_READY_TO_MOVE						(CMDR_ACTION_STATE_CUSTOM+2)
// After a garrison has completed a move
#define CMDR_ACTION_STATE_MOVED								(CMDR_ACTION_STATE_CUSTOM+3)
// When a target is dead, could be success or failure state depending on the context (e.g. kill or join)
#define CMDR_ACTION_STATE_TARGET_DEAD						(CMDR_ACTION_STATE_CUSTOM+4)
// When a garrison has arrived somewhere
#define CMDR_ACTION_STATE_ARRIVED 							(CMDR_ACTION_STATE_CUSTOM+5)
// When a garrison has been assigned an action
#define CMDR_ACTION_STATE_ASSIGNED							(CMDR_ACTION_STATE_CUSTOM+6)
// When a garrison should return to base
#define CMDR_ACTION_STATE_RTB								(CMDR_ACTION_STATE_CUSTOM+7)
// After a garrison has successfully returned to base
#define CMDR_ACTION_STATE_RTB_SUCCESS						(CMDR_ACTION_STATE_CUSTOM+8)
// When a garrison needs to select a target for RTB
#define CMDR_ACTION_STATE_RTB_SELECT_TARGET					(CMDR_ACTION_STATE_CUSTOM+9)

// When an AST fails due to an out of range error of some kind
#define CMDR_ACTION_STATE_FAILED_OUT_OF_RANGE 				(CMDR_ACTION_STATE_CUSTOM+10)
// When as AST fails due to a garrison being dead
#define CMDR_ACTION_STATE_FAILED_GARRISON_DEAD 				(CMDR_ACTION_STATE_CUSTOM+11)
// When an AST fails due to a generic time out
#define CMDR_ACTION_STATE_FAILED_TIMEOUT 					(CMDR_ACTION_STATE_CUSTOM+12)

// When the next waypoint in a route should be selected
#define CMDR_ACTION_STATE_NEXT_WAYPOINT 					(CMDR_ACTION_STATE_CUSTOM+13)
// When there are no more waypoints in a route
#define CMDR_ACTION_STATE_FINISHED_WAYPOINTS				(CMDR_ACTION_STATE_CUSTOM+14)

// Once a split garrison is prepared
#define CMDR_ACTION_STATE_PREPARED							(CMDR_ACTION_STATE_CUSTOM+15)

// Just before a garrison will merge with a target
#define CMDR_ACTION_STATE_PREMERGE							(CMDR_ACTION_STATE_CUSTOM+16)
// When a garrison should merge with the target
#define CMDR_ACTION_STATE_MERGE								(CMDR_ACTION_STATE_CUSTOM+17)

// Wait for next depart time
#define CMDR_ACTION_STATE_WAIT_TO_DEPART					(CMDR_ACTION_STATE_CUSTOM+18)
// ActionStateTransition priority values. Potential ASTs are sorted by the priority levels in 
// ascending order and the first valid one is used. You can use any value for priority
// these just define some reasonable defaults.
#define CMDR_ACTION_PRIOR_TOP 		0
#define CMDR_ACTION_PRIOR_HIGH 		1
#define CMDR_ACTION_PRIOR_LOW 		10

// Class: AI.CmdrAI.CmdrAction.AST_VAR
// ActionStateTransition variables.
// These are wrappers for variables so the value can be shared between multiple ActionStateTransitions.
// e.g. An output of one AST can be the input of another (such as the first AST selecting a target and the next 
// AST giving a move order to the target), so the same AST_VAR can be assigned to both. When the first AST
// writes a value to the AST_VAR the other AST sees that change to its input immediately as they 
// both refer to the same underlying value. 
// They also allow the CmdrAction state to be pushed/popped during simulation so that real world actions 
// are not effected.

// Function: SET_AST_VAR
// Set value of AST var of certain cmd action
#define SET_AST_VAR(action, index, value) (GETV(action, "variables") set [index, value])

// Function: GET_AST_VAR
// Get value of AST var of certain cmdr action
#define GET_AST_VAR(action, index) (GETV(action, "variables") select index)

// Function: P_AST_VAR
// Function variable definition for an AST_VAR
#define P_AST_VAR(paramNameStr) P_NUMBER(paramNameStr)
// Function: P_AST_STATE
// Function variable definition for a CMDR_ACTION_STATE
#define P_AST_STATE(paramNameStr) P_NUMBER(paramNameStr)

// Section: Globals

// Enum: AI.​CmdrAI.​CmdrAITarget.TARGET_TYPE
// Supported <CmdrAITarget> types.
//
// TARGET_TYPE_INVALID - just to identify an invalid target
// TARGET_TYPE_GARRISON - <Model.GarrisonModel> Id
// TARGET_TYPE_LOCATION - <Model.LocationModel> Id
// TARGET_TYPE_POSITION - position vector (3 element array of Number)
// TARGET_TYPE_CLUSTER  -  <Model.ClusterModel> Id
#define TARGET_TYPE_INVALID -1
#define TARGET_TYPE_GARRISON 0
#define TARGET_TYPE_LOCATION 1
#define TARGET_TYPE_POSITION 2
#define TARGET_TYPE_CLUSTER  3
#define NULL_TARGET []
#define IS_NULL_TARGET(target) (target isEqualTo [])

// Supply types for SupplyConvoyCmdrAction
#define ACTION_SUPPLY_TYPE_BUILDING 0
#define ACTION_SUPPLY_TYPE_AMMO 1
#define ACTION_SUPPLY_TYPE_EXPLOSIVES 2
#define ACTION_SUPPLY_TYPE_MEDICAL 3
#define ACTION_SUPPLY_TYPE_MISC 4