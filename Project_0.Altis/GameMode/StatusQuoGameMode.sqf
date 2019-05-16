#include "common.hpp"

CLASS("StatusQuoGameMode", "GameModeBase")

	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("name", "status-quo");

	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected override */ METHOD("initServerOnly") {
		params [P_THISOBJECT];

		// Create initial garrisons at bases.
		{
			private _loc = _x;
			private _side = GETV(_loc, "side");
			private _cmdr = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [_side]);

			if(!IS_NULL_OBJECT(_cmdr)) then {
				CALLM(_cmdr, "registerLocation", [_loc]);
				private _cInf = CALLM(_loc, "getUnitCapacity", [T_INF ARG [GROUP_TYPE_IDLE]]);
				private _cVehGround = CALLM(_loc, "getUnitCapacity", [T_PL_tracked_wheeled ARG GROUP_TYPE_ALL]);
				private _cHMGGMG = CALLM(_loc, "getUnitCapacity", [T_PL_HMG_GMG_high ARG GROUP_TYPE_ALL]);
				private _cBuildingSentry = CALLM(_loc, "getUnitCapacity", [T_INF ARG [GROUP_TYPE_BUILDING_SENTRY]]);
				
				private _gar = CALL_STATIC_METHOD("GameModeBase", "createGarrison", [_side ARG _cInf ARG _cVehGround ARG _cHMGGMG ARG _cBuildingSentry]);
				CALLM1(_gar, "setLocation", _loc);
				CALLM1(_loc, "registerGarrison", _gar);
				CALLM0(_gar, "activate");

				// Send intel to commanders
				{
					pr _sideCommander = GETV(_x, "side");
					pr _updateLevel = [CLD_UPDATE_LEVEL_TYPE_UNKNOWN, CLD_UPDATE_LEVEL_UNITS] select (_sideCommander == _side);
					CALLM2(_x, "postMethodAsync", "updateLocationData", [_loc ARG _updateLevel ARG sideUnknown ARG false]);
				} forEach gCommanders;
			};
		} forEach GET_STATIC_VAR("Location", "all");
	} ENDMETHOD;

ENDCLASS;
