#include "common.hpp"

CLASS("BasesGameMode", "GameModeBase")
	VARIABLE("name");

	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("name", "bases");

	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected virtual */ METHOD("getLocationInitialForces") {
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];
		if(GETV(_loc, "type") == "base") then {
			_cInf = CALLM(_loc, "getUnitCapacity", [T_INF]+[[GROUP_TYPE_IDLE]]);
			_cVehGround = CALLM(_loc, "getUnitCapacity", [T_PL_tracked_wheeled]+[GROUP_TYPE_ALL]);
			_cHMGGMG = CALLM(_loc, "getUnitCapacity", [T_PL_HMG_GMG_high]+[GROUP_TYPE_ALL]);
			_cBuildingSentry = CALLM(_loc, "getUnitCapacity", [T_INF]+[[GROUP_TYPE_BUILDING_SENTRY]]);

			[_cInf, _cVehGround, _cHMGGMG, _cBuildingSentry]
		} else {
			[0, 0, 0, 0]
		};
	} ENDMETHOD;

	/* protected override */ METHOD("initServerOnly") {
		params [P_THISOBJECT];

		// TODO: fix this to correctly spawn at selected bases contingent on the critera we decide.
		[_loc, _side, _cInf, _template] spawn {
			params ["_loc", "_side", "_targetCInf", "_template"];
			while{true} do {
				sleep 120;
				private _unitCount = CALLM(_loc, "countAvailableUnits", [_side]);
				if(_unitCount >= 6 and _unitCount < _targetCInf) then {
					private _garrisons = CALLM(_loc, "getGarrisons", [_side]);
					private _garrison = _garrisons#0;
					private _remaining = _targetCInf - _unitCount;
					systemChat format["Spawning %1 units at %2", _remaining, _loc];
					while {_remaining > 0} do {
						private _args = [_template, _garrison, T_GROUP_inf_sentry, _remaining, GROUP_TYPE_PATROL];
						_remaining = CALLM2(_garrison, "postMethodSync", fnc_addInfGroup, _args);
						//[_template, _garrison, T_GROUP_inf_sentry, _remaining, GROUP_TYPE_PATROL] call fnc_addInfGroup;
					};
				};
			};
		};
	} ENDMETHOD;
ENDCLASS;