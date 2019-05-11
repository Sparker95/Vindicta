#include "common.hpp"

CLASS("BasesGameMode", "GameModeBase")

	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("name", "bases");

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
				if(GETV(_loc, "type") == "base") then {
					private _cInf = CALLM(_loc, "getUnitCapacity", [T_INF ARG [GROUP_TYPE_IDLE]]);
					private _cVehGround = CALLM(_loc, "getUnitCapacity", [T_PL_tracked_wheeled ARG GROUP_TYPE_ALL]);
					private _cHMGGMG = CALLM(_loc, "getUnitCapacity", [T_PL_HMG_GMG_high ARG GROUP_TYPE_ALL]);
					private _cBuildingSentry = CALLM(_loc, "getUnitCapacity", [T_INF ARG [GROUP_TYPE_BUILDING_SENTRY]]);
					
					private _gar = CALL_STATIC_METHOD("GameModeBase", "createGarrison", [_side ARG _cInf ARG _cVehGround ARG _cHMGGMG ARG _cBuildingSentry]);
					CALLM1(_gar, "setLocation", _loc);
					CALLM1(_loc, "registerGarrison", _gar);
					CALLM0(_gar, "activate");
				};

				// Send intel to commanders
				{
					private _sideCommander = GETV(_x, "side");
					private _updateLevel = [CLD_UPDATE_LEVEL_TYPE_UNKNOWN, CLD_UPDATE_LEVEL_UNITS] select (_sideCommander == _side);
					CALLM2(_x, "postMethodAsync", "updateLocationData", [_loc ARG _updateLevel ARG sideUnknown ARG false]);
				} forEach gCommanders;
			};

		} forEach GET_STATIC_VAR("Location", "all");

		// TODO: fix this to correctly spawn at selected bases contingent on the critera we decide.
		// Move this to an existing thread?
		[] spawn {
			while{true} do {
				sleep 120;
				{
					private _loc = _x;
					private _side = GETV(_loc, "side");
					private _template = GET_TEMPLATE(_side);
					private _targetCInf = CALLM(_loc, "getUnitCapacity", [T_INF ARG [GROUP_TYPE_IDLE]]);
					private _unitCount = CALLM(_loc, "countAvailableUnits", [_side]);
					if(_unitCount >= 6 and _unitCount < _targetCInf) then {
						private _garrisons = CALLM(_loc, "getGarrisons", [_side]);
						private _garrison = _garrisons#0;
						private _remaining = _targetCInf - _unitCount;
						systemChat format["Spawning %1 units at %2", _remaining, _loc];
						while {_remaining > 0} do {
							CALLM2(_garrison, "postMethodSync", "createAddInfGroup", [_side ARG T_GROUP_inf_sentry ARG GROUP_TYPE_PATROL])
								params ["_newGroup", "_unitCount"];
							_remaining = _remaining - _unitCount;
						};
					};
				} forEach (GET_STATIC_VAR("Location", "all") select { GETV(_x, "type") == "base" });
			};
		};

	} ENDMETHOD;

ENDCLASS;
