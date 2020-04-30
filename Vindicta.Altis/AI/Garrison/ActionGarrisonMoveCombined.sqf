#include "common.hpp"

#define DEFAULT_COMBINED_SPEED_MAX 12

#define OOP_CLASS_NAME ActionGarrisonMoveCombined
CLASS("ActionGarrisonMoveCombined", "ActionGarrisonMoveBase")
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		// Overwriting the default max speed as we have infantry units following
		private _maxSpeedKmh = CALLSM3("Action", "getParameterValue", _parameters, TAG_MAX_SPEED_KMH, DEFAULT_COMBINED_SPEED_MAX);
		T_SETV("maxSpeed", _maxSpeedKmh);
	ENDMETHOD;
ENDCLASS;