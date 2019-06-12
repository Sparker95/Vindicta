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

		private _locPos = GETV(_loc, "pos");
		switch(GETV(_loc, "type")) do {
			// Occupy city when it is revolting or suppressed
			case LOCATION_TYPE_CITY: {
				private _actual = GETV(_loc, "actual");
				private _cityData = GETV(_actual, "gameModeData");
				if(!IS_NULL_OBJECT(_cityData) and {GETV(_cityData, "state") in [CITY_STATE_IN_REVOLT, CITY_STATE_SUPPRESSED]}) then {
					100
				} else {
					0
				}
			};
			// Occupy roadblocks near cities that are revolting or suppressed
			case LOCATION_TYPE_ROADBLOCK: {
				// Occupy if a nearby city is revolting
				if(CALLM(_worldNow, "getNearestLocations", [_locPos ARG 1000 ARG [LOCATION_TYPE_CITY]]) findIf {
					_x params ["_dist", "_nearLoc"];
					private _actual = GETV(_nearLoc, "actual");
					private _cityData = GETV(_actual, "gameModeData");
					!IS_NULL_OBJECT(_cityData) and { GETV(_cityData, "state") in [CITY_STATE_IN_REVOLT, CITY_STATE_SUPPRESSED] }
				} != NOT_FOUND) then {
					1
				} else {
					0
				}
			};
			default { 
				T_CALLCM("CmdrStrategy", "getLocationDesirability", [_worldNow ARG _loc ARG _side]);
			};
		};

		// if(_side == ENEMY_SIDE and {GETV(_loc, "type") == LOCATION_TYPE_CITY}) then {
		// 	private _cityData = GETV(_actual, "gameModeData");
		// 	if(GETV(_cityData, "state") == CITY_STATE_IN_REVOLT) then {
		// 		1
		// 	} else {
		// 		0
		// 	}
		// } else {
		// 	T_CALLCM("CmdrStrategy", "getLocationDesirability", [_worldNow ARG _loc ARG _side]);
		// }
	} ENDMETHOD;

	/* virtual */ METHOD("getQRFScore") {
		params [P_THISOBJECT,
			P_OOP_OBJECT("_action"), 
			P_ARRAY("_defaultScore"),
			P_OOP_OBJECT("_worldNow"),
			P_OOP_OBJECT("_worldFuture"),
			P_OOP_OBJECT("_srcGarr"),
			P_OOP_OBJECT("_tgtCluster"),
			P_ARRAY("_detachEff")];
		// Default QRFs
		_defaultScore
	} ENDMETHOD;

	/* virtual */ METHOD("getReinforceScore") {
		params [P_THISOBJECT,
			P_OOP_OBJECT("_action"), 
			P_ARRAY("_defaultScore"),
			P_OOP_OBJECT("_worldNow"),
			P_OOP_OBJECT("_worldFuture"),
			P_OOP_OBJECT("_srcGarr"),
			P_OOP_OBJECT("_tgtGarr"),
			P_ARRAY("_detachEff")];
		// Default reinforcing! 
		_defaultScore
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
		APPLY_SCORE_STRATEGY(_defaultScore, 1)
	} ENDMETHOD;

ENDCLASS;
