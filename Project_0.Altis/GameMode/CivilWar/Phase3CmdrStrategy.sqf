#include "common.hpp"

CLASS("Phase3CmdrStrategy", "CmdrStrategy")
	METHOD("new") {
		params [P_THISOBJECT];

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
					T_CALLCM("CmdrStrategy", "getLocationDesirability", [_worldNow ARG _loc ARG _side]);
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
					T_CALLCM("CmdrStrategy", "getLocationDesirability", [_worldNow ARG _loc ARG _side]);
				}
			};
			default { 
				T_CALLCM("CmdrStrategy", "getLocationDesirability", [_worldNow ARG _loc ARG _side]);
			};
		};
	} ENDMETHOD;
ENDCLASS;
