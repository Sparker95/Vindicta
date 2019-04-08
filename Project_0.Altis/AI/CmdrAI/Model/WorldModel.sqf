#define OOP_INFO
#define OOP_DEBUG
#define OOP_WARNING
#define OOP_ERROR
#define OOP_ASSERT
#include "..\..\..\OOP_Light\OOP_Light.h"

CLASS("WorldModel", "")

	VARIABLE("isSim");
	VARIABLE("garrisons");
	VARIABLE("locations");
	VARIABLE("threatMaps");

	METHOD("new") {
		params [P_THISOBJECT, P_BOOL("_isSim")];
		T_SETV("isSim", _isSim);
		T_SETV("garrisons", []);
		T_SETV("locations", []);
		//T_SETV("lastSpawnT", simtime);
		//T_SETV("threatMaps", [] call ws_fnc_newGridArray);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];
		T_PRVAR(garrisons);
		T_PRVAR(locations);
		{ UNREF(_x) } forEach _garrisons;
		{ UNREF(_x) } forEach _locations;
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                       M E T H O D  N A M E                         |
	// ----------------------------------------------------------------------
	METHOD("simCopy") {
		params [P_THISOBJECT];

		T_PRVAR(garrisons);
		T_PRVAR(locations);

		private _copy = NEW("WorldModel", [true]);
		private _simGarrisons = _garrisons apply { 
			private _copy = CALLM(_x, "simCopy", [_copy]);
			REF(_copy);
			_copy
		};

		SETV(_copy, "garrisons", _simGarrisons);
		private _simLocations = _locations apply { 
			private _copy = CALLM(_x, "simCopy", [_copy]);
			REF(_copy);
			_copy
		};
		SETV(_copy, "locations", _simLocations);
		// Can copy it cos we don't write to it
		//T_PRVAR(threatMapOpf);
		//SETV(_copy, "threatMapOpf", _threatMapOpf);

		_copy
	} ENDMETHOD;
	
	// METHOD("updateThreatMaps") {
	// 	params [P_THISOBJECT];

	// 	// private _new_grid = [] call ws_fnc_newGridArray;
	// 	// [] call ws_fnc_unplotGrid;

	// 	// for "_i" from 0 to 5 + random(20) do {
	// 	// 	private _pos = [] call BIS_fnc_randomPos;

	// 	// 	for "_j" from 0 to 5 + random(20) do {
	// 	// 		private _pos2 = [[[_pos, 1000]]] call BIS_fnc_randomPos;
	// 	// 		[_new_grid, _pos2 select 0, _pos2 select 1, 10 * (sqrt (1 + random(100)))] call ws_fnc_setValue; 
	// 	// 	};
	// 	// };

	// 	T_PRVAR(threatMapOpf);
	// 	private _aliveGarrisons = T_CALLM0("getAliveGarrisons");

	// 	private _threatMapOpfCopy = [] call ws_fnc_newGridArray;
	// 	[_threatMapOpfCopy, _threatMapOpf] call ws_fnc_copyGrid;
	// 	{
	// 		private _pos = CALLM0(_x, "getPos");
	// 		private _strength = CALLM0(_x, "getStrength");
	// 		[_threatMapOpfCopy, _pos#0, _pos#1, _strength] call ws_fnc_setValue;
	// 	} forEach (_aliveGarrisons select { CALLM0(_x, "getSide") == side_guer });

	// 	[_threatMapOpfCopy, _threatMapOpf] call ws_fnc_filterSmooth;
	// 	[_threatMapOpf, 100] call ws_fnc_plotGrid;
	// } ENDMETHOD;

	METHOD("addGarrison") {
		params [P_THISOBJECT, P_STRING("_garrison")];
		T_PRVAR(garrisons);
		REF(_garrison);
		private _idx = _garrisons pushBack _garrison;
		CALLM(_garrison, "setId", [_idx]);
		_idx
	} ENDMETHOD;

	METHOD("getGarrison") {
		params [P_THISOBJECT, P_NUMBER("_id")];
		T_PRVAR(garrisons);
		_garrisons select _id
	} ENDMETHOD;

	METHOD("findGarrisonByActual") {
		params [P_THISOBJECT, P_STRING("_actual")];
		ASSERT_MSG(!T_GETV("isSim"), "Trying to find Garrison by Actual in a Sim Model");
		T_PRVAR(garrisons);
		private _idx = _garrisons findIf { GETV(_x, "actual") == _actual };
		if(_idx == -1) exitWith { objNull };
		_garrisons select _idx
	} ENDMETHOD;

	METHOD("addLocation") {
		params [P_THISOBJECT, P_STRING("_location")];
		T_PRVAR(locations);
		REF(_location);
		private _idx = _locations pushBack _location;
		CALLM(_location, "setId", [_idx]);
		_idx
	} ENDMETHOD;

	METHOD("getLocation") {
		params [P_THISOBJECT, P_NUMBER("_id")];
		T_PRVAR(locations);
		_locations select _id
	} ENDMETHOD;

	METHOD("findLocationByActual") {
		params [P_THISOBJECT, P_STRING("_actual")];
		ASSERT_MSG(!T_GETV("isSim"), "Trying to find Location by Actual in a Sim Model");
		T_PRVAR(locations);
		private _idx = _locations findIf { GETV(_x, "actual") == _actual };
		if(_idx == -1) exitWith { objNull };
		_locations select _idx
	} ENDMETHOD;

	METHOD("garrisonKilled") {
		params [P_THISOBJECT, P_STRING("_garrison")];
		//T_CALLM("detachGarrison", [_garrison]);
	} ENDMETHOD;

	// TODO: Optimize this
	METHOD("getAliveGarrisons") {
		params [P_THISOBJECT];
		T_PRVAR(garrisons);
		_garrisons select { !CALLM(_x, "isDead", []) }
	} ENDMETHOD;
	
	METHOD("getNearestGarrisons") {
		params [P_THISOBJECT, P_ARRAY("_center"), P_NUMBER("_maxDist")];

		// TODO: optimize obviously, use spatial partitioning, probably just a grid? Maybe quad tree..
		private _nearestGarrisons = [];

		{
			private _garrison = _x;
			private _pos = GETV(_garrison, "pos");
			private _dist = _pos distance2D _center;
			if(_dist <= _maxDist) then {
				_nearestGarrisons pushBack [_dist, _garrison];
			};
		} forEach T_CALLM("getAliveGarrisons", []);
		_nearestGarrisons sort true;
		_nearestGarrisons
	} ENDMETHOD;

	METHOD("getNearestLocations") {
		params [P_THISOBJECT, P_ARRAY("_center"), P_NUMBER("_maxDist")];

		T_PRVAR(locations);

		// TODO: optimize obviously, use spatial partitioning, probably just a grid? Maybe quad tree..
		private _nearestLocations = [];
		{
			private _location = _x;
			private _pos = GETV(_location, "pos");
			private _dist = _pos distance2D _center;
			if(_dist <= _maxDist) then {
				_nearestLocations pushBack [_dist, _location];
			};
		} forEach _locations;
		_nearestLocations sort true;
		_nearestLocations
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                   S C O R I N G   T O O L K I T                    |
	// ----------------------------------------------------------------------

	// Get desired efficiency of forces at a particular location.
	METHOD("getDesiredEff") {
		params [P_THISOBJECT, P_ARRAY("_pos"), P_STRING("_side")];
		
		// // max(base, nearest enemy forces * 2, threat map * 2);
		// private _base = MIN_COMP;

		// // Nearest enemy garrison force * 2
		// private _enemyForces = T_CALLM2("getNearestGarrisons", _pos, 2000) select {
		// 	_x params ["_dist", "_garr"];
		// 	CALLM0(_garr, "getSide") != _side
		// } apply {
		// 	_x params ["_dist", "_garr"];
		// 	CALLM0(_garr, "getComp") apply { _x * 2 }
		// };

		// // TODO: Maybe should have outpost specific force requirements based on strategy?
		// private _nearEnemyComp = [0, 0];
		// {
		// 	_nearEnemyComp = [
		// 		_nearEnemyComp#0 max _x#0,
		// 		_nearEnemyComp#1 max _x#1
		// 	];
		// } forEach _enemyForces;

		// // private _nearEnemyComp = if(count _enemyForces > 0) then {
		// // 	_enemyForces#0
		// // } else { 
		// // 	[0,0] 
		// // };
		
		// // Threat map converted from strength into a composition of the same strength
		// private _threatMapForce = if(_side == side_opf) then {
		// 	T_PRVAR(threatMapOpf);
		// 	private _strength = [_threatMapOpf, _pos#0, _pos#1] call ws_fnc_getValue;
		// 	[
		// 		_strength * 0.7 / UNIT_STRENGTH,
		// 		_strength * 0.3 / VEHICLE_STRENGTH
		// 	]
		// } else {
		// 	[0,0]
		// };

		// [
		// 	ceil (_base#0 max (_nearEnemyComp#0 max _threatMapForce#0)),
		// 	ceil (_base#1 max (_nearEnemyComp#1 max _threatMapForce#1))
		// ]

		// TODO Return desired efficiency vector at this location
		T_EFF_null
	} ENDMETHOD;

	// How much over desired efficiency is the garrison? Negative for under.
	METHOD("getOverDesiredEff") {
		params [P_THISOBJECT, P_STRING("_garr")];
		
		// private _pos = CALLM0(_garr, "getPos");
		// private _garrSide = CALLM0(_garr, "getSide");
		// private _comp = CALLM0(_garr, "getComp");
		// private _desiredComp = T_CALLM2("getDesiredEff", _pos, _garrSide);
		// [
		// 	// units
		// 	_comp#0 - _desiredComp#0,
		// 	// vehicles
		// 	_comp#1 - _desiredComp#1
		// ]
		
		// TODO Return much over desired efficiency at this location
		T_EFF_null
	} ENDMETHOD;

	// How much over desired efficiency is the garrison, scaled. Negative for under.
	METHOD("getOverDesiredEffScaled") {
		params [P_THISOBJECT, P_STRING("_garr"), P_NUMBER("_compScalar")];
		
		// private _pos = CALLM0(_garr, "getPos");
		// private _garrSide = CALLM0(_garr, "getSide");
		// private _comp = [GETV(_garr, "unitCount"), GETV(_garr, "vehCount")];
		// private _desiredComp = T_CALLM2("getDesiredEff", _pos, _garrSide);
		// [
		// 	// units
		// 	_comp#0 - _compScalar * _desiredComp#0,
		// 	// vehicles
		// 	_comp#1 - _compScalar * _desiredComp#1
		// ]

		// TODO Return much over desired efficiency at this location scaled
		T_EFF_null
	} ENDMETHOD;

	// A scoring factor for how much a garrison desires reinforcement
	METHOD("getReinforceRequiredScore") {
		params [P_THISOBJECT, P_STRING("_garr")];

		// // How much garr is *under* composition (so over comp * -1) with a non-linear function applied.
		// // i.e. How much units/vehicles tgt needs.
		// private _overComp = T_CALLM2("getOverDesiredEffScaled", _garr, 0.75);
		// private _score = 
		// 	// units
		// 	(0 max (_overComp#0 * -1)) * UNIT_STRENGTH +
		// 	// vehicles
		// 	(0 max (_overComp#1 * -1)) * VEHICLE_STRENGTH;

		// // apply non linear function to threat (https://www.desmos.com/calculator/wnlyulwf7m)
		// // This models reinforcement desireability as relative to absolute power of 
		// // missing comp rather than relative to ratio of missing comp/desired comp.
		// // 
		// _score = 0.1 * _score;
		// _score = 0 max ( _score * _score * _score );
		// _score
		
		// TODO Return a scoring factor for how much a garrison desires reinforcement
		0
	} ENDMETHOD;
ENDCLASS;

// Unit test
#ifdef _SQF_VM

["WorldModel.new", {
	private _world = NEW("WorldModel", [true]);
	private _class = OBJECT_PARENT_CLASS_STR(_world);
	["Object exists", !(isNil "_class")] call test_Assert;
	["isSim", GETV(_world, "isSim")] call test_Assert;
}] call test_AddTest;

["WorldModel.delete", {
	private _world = NEW("WorldModel", [true]);
	DELETE(_world);
	isNil { OBJECT_PARENT_CLASS_STR(_world) }
}] call test_AddTest;

["WorldModel.addGarrison", {
	private _world = NEW("WorldModel", [true]);
	private _garrison = NEW("GarrisonModel", [_world]+[""]);
	private _id = CALLM(_world, "addGarrison", [_garrison]);
	["Added", count GETV(_world, "garrisons") == 1] call test_Assert;
	["Id correct", _id == 0] call test_Assert;
}] call test_AddTest;

["WorldModel.getGarrison", {
	private _world = NEW("WorldModel", [true]);
	private _garrison = NEW("GarrisonModel", [_world]+[""]);
	private _id = CALLM(_world, "addGarrison", [_garrison]);
	private _got = CALLM(_world, "getGarrison", [_id]);
	_got == _garrison
}] call test_AddTest;

["WorldModel.findGarrisonByActual", {
	private _actual = NEW("Garrison", [WEST]);
	private _world = NEW("WorldModel", [false]);
	private _garrison = NEW("GarrisonModel", [_world] + [_actual]);
	CALLM(_world, "addGarrison", [_garrison]);
	private _got = CALLM(_world, "findGarrisonByActual", [_actual]);
	_got == _garrison
}] call test_AddTest;

["WorldModel.addLocation", {
	private _world = NEW("WorldModel", [true]);
	private _location = NEW("LocationModel", [_world]+[""]);
	private _id = CALLM(_world, "addLocation", [_location]);
	["Added", count GETV(_world, "locations") == 1] call test_Assert;
	["Id correct", _id == 0] call test_Assert;
}] call test_AddTest;

["WorldModel.getLocation", {
	private _world = NEW("WorldModel", [true]);
	private _location = NEW("LocationModel", [_world]+[""]);
	private _id = CALLM(_world, "addLocation", [_location]);
	private _got = CALLM(_world, "getLocation", [_id]);
	_got == _location
}] call test_AddTest;

["WorldModel.findLocationByActual", {
	private _world = NEW("WorldModel", [true]);
	private _location = NEW("LocationModel", [_world]+[""]);
	private _id = CALLM(_world, "addLocation", [_location]);
	private _got = CALLM(_world, "getLocation", [_id]);
	_got == _location
}] call test_AddTest;

["WorldModel.simCopy", {
	private _world = NEW("WorldModel", [true]);

	private _location = NEW("LocationModel", [_world]+[""]);
	CALLM(_world, "addLocation", [_location]);
	private _garrison = NEW("GarrisonModel", [_world]+[""]);
	CALLM(_world, "addGarrison", [_garrison]);

	private _copy = CALLM(_world, "simCopy", []);
	["Created", !(isNil { OBJECT_PARENT_CLASS_STR(_copy) })] call test_Assert;
	["Garrisons copied", {
		private _w = GETV(_world, "garrisons");
		private _c = GETV(_copy, "garrisons");
		(_w apply { GETV(_x, "id") }) isEqualTo (_c apply { GETV(_x, "id") })
	}] call test_Assert;
	["Locations copied", {
		private _w = GETV(_world, "locations");
		private _c = GETV(_copy, "locations");
		(_w apply { GETV(_x, "id") }) isEqualTo (_c apply { GETV(_x, "id") })
	}] call test_Assert;
}] call test_AddTest;

#endif