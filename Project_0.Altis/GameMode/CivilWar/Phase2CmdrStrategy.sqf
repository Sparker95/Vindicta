#include "common.hpp"

CLASS("Phase2CmdrStrategy", "PassiveCmdrStrategy")
	METHOD("new") {
		params [P_THISOBJECT];

		T_SETV("takeLocOutpostPriority", 0);
		T_SETV("takeLocOutpostPriorityActivityCoeff", 0);
		T_SETV("takeLocBasePriority", 0);
		T_SETV("takeLocBasePriorityActivityCoeff", 0);
		T_SETV("takeLocRoadBlockPriority", 0);
		T_SETV("takeLocRoadBlockPriorityActivityCoeff", 0);
		T_SETV("takeLocCityPriority", 1);
		T_SETV("takeLocCityPriorityActivityCoeff", 1);
	} ENDMETHOD;

	METHOD("getLocationDesirability") {
		params [P_THISOBJECT, P_OOP_OBJECT("_worldNow"), P_OOP_OBJECT("_loc"), P_SIDE("_side")];

		if(_side == ENEMY_SIDE and {GETV(_loc, "type") == LOCATION_TYPE_CITY}) then {
			private _actual = GETV(_loc, "actual");
			private _cityData = GETV(_actual, "gameModeData");
			if(GETV(_cityData, "state") == CITY_STATE_IN_REVOLT) then {
				1
			} else {
				0
			}
		} else {
			T_CALLCM("CmdrStrategy", "getLocationDesirability", [_worldNow ARG _loc ARG _side]);
		}
	} ENDMETHOD;
	
	/* virtual */ METHOD("getTakeLocationScore") {
		params [P_THISOBJECT,
			P_OOP_OBJECT("_action"), 
			P_ARRAY("_defaultScore"),
			P_OOP_OBJECT("_worldNow"),
			P_OOP_OBJECT("_worldFuture"),
			P_OOP_OBJECT("_srcGarr"),
			P_OOP_OBJECT("_tgtLoc"),
			P_ARRAY("_detachEff")];
		// Take no locations!
		APPLY_SCORE_STRATEGY(_defaultScore, 1)
	} ENDMETHOD;

ENDCLASS;
