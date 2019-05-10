#include "common.hpp"

/*
In this preset there are only a few garrisons created with limited resources to test how AI works in different specific conditions quickly.
Author: Sparker
*/

#define pr private

CLASS("AITestBenchGameMode", "GameModeBase")

	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("name", "AI test bench");

	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected override */ METHOD("initServerOnly") {
		params [P_THISOBJECT];

		// Create initial garrisons at bases.
		{ // forEach GET_STATIC_VAR("Location", "all");
			private _loc = _x;
			private _side = GETV(_loc, "side");
			private _cmdr = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [_side]);

			if(!IS_NULL_OBJECT(_cmdr)) then {
				CALLM(_cmdr, "registerLocation", [_loc]);
				if(_loc == "o_Location_N_37") then {
					private _cInf = 0; //CALLM(_loc, "getUnitCapacity", [T_INF ARG [GROUP_TYPE_IDLE]]);
					private _cVehGround = 0; //CALLM(_loc, "getUnitCapacity", [T_PL_tracked_wheeled ARG GROUP_TYPE_ALL]);
					private _cHMGGMG = 0; //CALLM(_loc, "getUnitCapacity", [T_PL_HMG_GMG_high ARG GROUP_TYPE_ALL]);
					private _cBuildingSentry = 0; //CALLM(_loc, "getUnitCapacity", [T_INF ARG [GROUP_TYPE_BUILDING_SENTRY]]);
					
					private _gar = CALL_STATIC_METHOD("GameModeBase", "createGarrison", [_side ARG _cInf ARG _cVehGround ARG _cHMGGMG ARG _cBuildingSentry]);

					// Add an APC
					_x params ["_chance", "_min", "_max", "_type"];
					private _i = 0;
					while{(_i < 1)} do {
						private _newGroup = CALLM(_gar, "createAddVehGroup", [_side ARG T_VEH ARG T_VEH_APC ARG -1]);
						OOP_INFO_MSG("%1: Created veh group %2", [_gar ARG _newGroup]);
						_i = _i + 1;
					};



					CALLM1(_gar, "setLocation", _loc);
					CALLM1(_loc, "registerGarrison", _gar);
					CALLM0(_gar, "activate");
				};

				// Send intel to commanders
				{
					pr _sideCommander = GETV(_x, "side");
					pr _updateLevel = [CLD_UPDATE_LEVEL_TYPE_UNKNOWN, CLD_UPDATE_LEVEL_UNITS] select (_sideCommander == _side);
					CALLM2(_x, "postMethodAsync", "updateLocationData", [_loc ARG CLD_UPDATE_LEVEL_UNITS ARG sideUnknown ARG false]);
				} forEach gCommanders;
			};

		} forEach GET_STATIC_VAR("Location", "all");

	} ENDMETHOD;

ENDCLASS;
