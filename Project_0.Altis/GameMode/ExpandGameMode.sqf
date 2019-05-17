#include "common.hpp"

CLASS("ExpandGameMode", "GameModeBase")

	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("name", "expand");

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
					
					private _gar = CALL_STATIC_METHOD("GameModeBase", "createGarrison", ["military" ARG _side ARG _cInf ARG _cVehGround ARG _cHMGGMG ARG _cBuildingSentry]);
					CALLM1(_gar, "setLocation", _loc);
					CALLM1(_loc, "registerGarrison", _gar);
					CALLM0(_gar, "activate");
				};

				// Probably we can move this to Base, we always have police right?
				if(GETV(_loc, "type") == "policeStation") then {
					private _gar = CALL_STATIC_METHOD("GameModeBase", "createGarrison", ["police" ARG _side ARG 5]);
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
				#ifdef RELEASE_BUILD
				sleep 3600;
				#else
				sleep 120;
				#endif
				{
					private _loc = _x;
					private _side = GETV(_loc, "side");
					private _template = GET_TEMPLATE(_side);
					private _targetCInf = CALLM(_loc, "getUnitCapacity", [T_INF ARG [GROUP_TYPE_IDLE]]);

					private _garrisons = CALLM(_loc, "getGarrisons", [_side]);
					if (count _garrisons == 0) exitWith {};
					private _garrison = _garrisons#0;
					if(not CALLM(_garrison, "isSpawned", [])) then {
						private _infCount = count CALLM(_garrison, "getInfantryUnits", []);
						if(_infCount < _targetCInf) then {
							private _remaining = _targetCInf - _infCount;
							systemChat format["Spawning %1 units at %2", _remaining, _loc];
							while {_remaining > 0} do {
								CALLM2(_garrison, "postMethodSync", "createAddInfGroup", [_side ARG T_GROUP_inf_sentry ARG GROUP_TYPE_PATROL])
									params ["_newGroup", "_unitCount"];
								_remaining = _remaining - _unitCount;
							};
						};

						private _cVehGround = CALLM(_loc, "getUnitCapacity", [T_PL_tracked_wheeled ARG GROUP_TYPE_ALL]);
						private _vehCount = count CALLM(_garrison, "getVehicleUnits", []);
						
						if(_vehCount < _cVehGround) then {
							systemChat format["Spawning %1 trucks at %2", _cVehGround - _vehCount, _loc];
						};

						while {_vehCount < _cVehGround} do {
							private _newUnit = NEW("Unit", [_template ARG T_VEH ARG T_VEH_truck_inf ARG -1 ARG ""]);
							if (CALL_METHOD(_newUnit, "isValid", [])) then {
								CALLM2(_garrison, "postMethodSync", "addUnit", [_newUnit]);
								_vehCount = _vehCount + 1;
							} else {
								DELETE(_newUnit);
							};
						};
					};
				} forEach (GET_STATIC_VAR("Location", "all") select { GETV(_x, "type") == "base" });
				// TODO: Do this for policeStations as well, we need getTemplate for side + faction
				// || GETV(_x, "type") == "policeStation" 
			};
		};

	} ENDMETHOD;

ENDCLASS;
