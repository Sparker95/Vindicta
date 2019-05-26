#define CMDR_ACTION_STATE_NONE		-1000
#define CMDR_ACTION_STATE_START 	0
#define CMDR_ACTION_STATE_END 		1
#define CMDR_ACTION_STATE_ALL 		-1
#define CMDR_ACTION_STATE_CUSTOM	1000

#define CMDR_ACTION_PRIOR_TOP 		0
#define CMDR_ACTION_PRIOR_HIGH 		1
#define CMDR_ACTION_PRIOR_LOW 		10

#define CMDR_ACTION_STATE_SPLIT								(CMDR_ACTION_STATE_CUSTOM+1)
#define CMDR_ACTION_STATE_READY_TO_MOVE						(CMDR_ACTION_STATE_CUSTOM+2)
#define CMDR_ACTION_STATE_MOVED								(CMDR_ACTION_STATE_CUSTOM+3)
#define CMDR_ACTION_STATE_TARGET_DEAD						(CMDR_ACTION_STATE_CUSTOM+4)
#define CMDR_ACTION_STATE_ARRIVED 							(CMDR_ACTION_STATE_CUSTOM+5)
#define CMDR_ACTION_STATE_ASSIGNED							(CMDR_ACTION_STATE_CUSTOM+6)
#define CMDR_ACTION_STATE_RTB								(CMDR_ACTION_STATE_CUSTOM+7)
#define CMDR_ACTION_STATE_RTB_SUCCESS						(CMDR_ACTION_STATE_CUSTOM+8)
#define CMDR_ACTION_STATE_RTB_SELECT_TARGET					(CMDR_ACTION_STATE_CUSTOM+9)

#define CMDR_ACTION_STATE_FAILED_OUT_OF_RANGE 				(CMDR_ACTION_STATE_CUSTOM+10)
#define CMDR_ACTION_STATE_FAILED_GARRISON_DEAD 				(CMDR_ACTION_STATE_CUSTOM+11)
#define CMDR_ACTION_STATE_FAILED_TIMEOUT 					(CMDR_ACTION_STATE_CUSTOM+12)

#define CMDR_ACTION_STATE_NEXT_WAYPOINT 					(CMDR_ACTION_STATE_CUSTOM+13)
#define CMDR_ACTION_STATE_FINISHED_WAYPOINTS				(CMDR_ACTION_STATE_CUSTOM+14)

// ActionStateTransition variables, these are wrappers of variables so the value can be shared between multiple
// classes. They also allow the CmdrAction state to be pushed/popped.
#define MAKE_AST_VAR(value) [value]
#define GET_AST_VAR(wrapper) (if((wrapper select 0) isEqualType {}) then { call (wrapper select 0) } else { (wrapper select 0) })
#define SET_AST_VAR(wrapper, value) (wrapper set [0, value])
#define T_GET_AST_VAR(property) (T_GETV(property) select 0)
#define T_SET_AST_VAR(property, value) (T_GETV(property) set [0, value])

#define P_AST_VAR(paramNameStr) P_ARRAY(paramNameStr)
#define P_AST_STATE(paramNameStr) P_NUMBER(paramNameStr)

// MoveGarrison target types
#define TARGET_TYPE_GARRISON 0
#define TARGET_TYPE_LOCATION 1
#define TARGET_TYPE_POSITION 2
#define TARGET_TYPE_CLUSTER  3
#define NULL_TARGET []
#define IS_NULL_TARGET(target) (target isEqualTo [])