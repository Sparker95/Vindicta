#include "common.hpp"
FIX_LINE_NUMBERS()
/*
Class: ActionGroup.ActionGroupAirLand
The aircraft will land somewhere appropriate
*/

#define OOP_CLASS_NAME ActionGroupAirLand
CLASS("ActionGroupAirLand", "ActionGroup")

	VARIABLE("pos");
	VARIABLE("radius");
	VARIABLE("vehicle");

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_AI"), P_ARRAY("_parameters")];

		private _pos = CALLSM3("Action", "getParameterValue", _parameters, TAG_POS, []);
		if(_pos isEqualTo []) then {
			_pos = CALLM0(GETV(_AI, "agent"), "getPos");
		};
		T_SETV("pos", _pos);
		private _radius = CALLSM3("Action", "getParameterValue", _parameters, TAG_MOVE_RADIUS, 250);
		T_SETV("radius", _radius);

		T_SETV("vehicle", NULL_OBJECT);
	ENDMETHOD;

	protected override METHOD(activate)
		params [P_THISOBJECT, P_BOOL("_instant")];

		private _AI = T_GETV("AI");
		private _group = GETV(_AI, "agent");
		private _airUnits = CALLM0(_group, "getAirUnits");
		private _state = if(count _airUnits > 0) then {
			private _airUnit = _airUnits#0;
			T_SETV("vehicle", _airUnit);
			private _loc = CALLM0(CALLM0(_group, "getGarrison"), "getLocation");
			private _landingPos = if(_loc != NULL_OBJECT) then {
				// If we are in a garrison at a location then land at a free helipad if possible
				private _groupType = CALLM0(_group, "getType");
				CALLM0(_airUnit, "getMainData") params ["_catID", "_subcatID", "_className"];
				CALLM4(_loc, "getSpawnPos", _catID, _subcatID, _className, _groupType) select 0
			} else {
				// Find the nearest good landing position
				// Prefer helipads
				private _pos = T_GETV("pos");
				private _radius = T_GETV("radius");
				private _terrainObjects = nearestTerrainObjects [_pos, [], _radius] select {
					typeOf _x in location_bt_helipad && { count nearestObjects [_x, ["AllVehicles"], 10] == 0 }
				};
				private _objects = nearestObjects [_pos, [], _radius] select {
					typeOf _x in location_bt_helipad && { count nearestObjects [_x, ["AllVehicles"], 10] == 0 }
				};
				{
					_objects pushBackUnique _x;
				} forEach _terrainObjects;
				if(count _objects > 0) then {
					// If we found a seemingly unoccupied helipad
					position selectRandom _objects
				} else {
					// Just find an open area
					[_pos, 0, _radius, 15, 0, 0.15, 0, [], [_pos, _pos]] call BIS_fnc_findSafePos
				};
			};
			private _hG = T_GETV("hG");
			// Needs to be a 3D vector not 2D, or both AGLToASL and wpLand throw errors...
			_landingPos = VECTOR3(_landingPos); 
			private _landWP = _hG addWaypoint [AGLToASL _landingPos, -1];
			_hG setCurrentWaypoint _landWP;
			[_hG, _landingPos] spawn BIS_fnc_wpLand;
			//_landWP setWaypointType "LAND"; Doesn't work...
			ACTION_STATE_ACTIVE
		} else {
			ACTION_STATE_FAILED
		};

		// Return ACTIVE state
		T_SETV("state", _state);
		_state
	ENDMETHOD;

	// logic to run each update-step
	public override METHOD(process)
		params [P_THISOBJECT];

		T_CALLM0("failIfEmpty");
		T_CALLM0("activateIfInactive");

		if (CALLM0(T_GETV("AI"), "isLanded")) then {
			private _h0 = CALLM0(T_GETV("vehicle"), "getObjectHandle");
			_h0 engineOn false;
			T_SETV("state", ACTION_STATE_COMPLETED);
		} else {
			private _hG = T_GETV("hG");
			if(count waypoints _hG == 0) then {
				// Force reactivation to try again
				T_SETV("state", ACTION_STATE_INACTIVE);
			};
		};

		// Return the current state
		T_GETV("state")
	ENDMETHOD;

	// logic to run when the action is satisfied
	public override METHOD(terminate)
		params [P_THISOBJECT];

		T_CALLM0("clearWaypoints");
		T_CALLCM0("ActionGroup", "terminate");

		if (CALLM0(T_GETV("AI"), "isLanded")) then {
			private _h0 = CALLM0(T_GETV("vehicle"), "getObjectHandle");
			_h0 engineOn false;
			_h0 setFuel 1;
			_h0 setDamage 0;
			_h0 setVehicleAmmo 1;
		};
	ENDMETHOD;

ENDCLASS;