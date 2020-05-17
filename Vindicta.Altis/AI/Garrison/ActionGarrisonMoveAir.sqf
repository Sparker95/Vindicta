#include "common.hpp"
FIX_LINE_NUMBERS()

#define DEFAULT_AIR_SPEED_MAX 1000

#define OOP_CLASS_NAME ActionGarrisonMoveAir
CLASS("ActionGarrisonMoveAir", "ActionGarrisonMoveMounted")
	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];
		// Overwriting the default max speed as we want air units to move fast
		private _maxSpeedKmh = CALLSM3("Action", "getParameterValue", _parameters, TAG_MAX_SPEED_KMH, DEFAULT_AIR_SPEED_MAX);
		T_SETV("maxSpeed", _maxSpeedKmh);
	ENDMETHOD;
ENDCLASS;