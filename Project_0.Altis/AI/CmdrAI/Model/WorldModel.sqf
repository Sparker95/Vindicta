#include "..\common.hpp"

CLASS("WorldModel", "")

	VARIABLE("type");
	VARIABLE("garrisons");
	VARIABLE("locations");
	VARIABLE("clusters");
	VARIABLE("threatGrid");

	VARIABLE("reinforceRequiredScoreCache");

	METHOD("new") {
		params [P_THISOBJECT, P_NUMBER("_type")];
		T_SETV("type", _type);
		T_SETV("garrisons", []);
		T_SETV("locations", []);
		T_SETV("clusters", []);
		private _threatGrid = NEW("Grid", []);
		T_SETV("threatGrid", _threatGrid);

		T_SETV("reinforceRequiredScoreCache", []);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];
		T_PRVAR(garrisons);
		{ UNREF(_x); } forEach _garrisons;
		T_PRVAR(locations);
		{ UNREF(_x); } forEach _locations;
		T_PRVAR(clusters);
		{ UNREF(_x); } forEach _clusters;
	} ENDMETHOD;

	METHOD("isReal") {
		params [P_THISOBJECT];
		T_GETV("type") == WORLD_TYPE_REAL
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                       C O P Y / U P D A T E                        |
	// ----------------------------------------------------------------------

	METHOD("sync") {
		params [P_THISOBJECT];

		// sync existing garrisons
		//T_PRVAR(garrisons);

		// Is this too long a critical section?
		//CRITICAL_SECTION {
			{ CALLM(_x, "sync", []); } forEach T_CALLM("getAliveGarrisons", []);

			// sync existing locations
			T_PRVAR(locations);
			{ CALLM(_x, "sync", []); } forEach _locations;

			// sync existing clusters
			//T_PRVAR(clusters);
			{ CALLM(_x, "sync", []); } forEach T_CALLM("getAliveClusters", []);
		//};

	} ENDMETHOD;

	METHOD("simCopy") {
		params [P_THISOBJECT, P_NUMBER("_type")];
		ASSERT_MSG(_type == WORLD_TYPE_SIM_NOW or _type == WORLD_TYPE_SIM_FUTURE, "_type must be a sim world type.");

		private _worldCopy = NEW("WorldModel", [_type]);

		// Copy garrisons
		T_PRVAR(garrisons);
		OOP_DEBUG_MSG("simCopy %1 garrisons", [count _garrisons]);
		{ CALLM(_x, "simCopy", [_worldCopy]); } forEach _garrisons;

		// Copy locations
		T_PRVAR(locations);
		OOP_DEBUG_MSG("simCopy %1 locations", [count _locations]);
		{ CALLM(_x, "simCopy", [_worldCopy]); } forEach _locations;

		// Copy clusters
		T_PRVAR(clusters);
		OOP_DEBUG_MSG("simCopy %1 clusters", [count _clusters]);
		{ CALLM(_x, "simCopy", [_worldCopy]); } forEach _clusters;

		OOP_DEBUG_MSG("simCopy threatGrid", []);
		// Can copy the grid ref as we don't write to it
		T_PRVAR(threatGrid);
		SETV(_worldCopy, "threatGrid", _threatGrid);

		_worldCopy
	} ENDMETHOD;

	METHOD("updateThreatMaps") {
		params [P_THISOBJECT];

		// private _new_grid = [] call ws_fnc_newGridArray;
		// [] call ws_fnc_unplotGrid;

		// for "_i" from 0 to 5 + random(20) do {
		// 	private _pos = [] call BIS_fnc_randomPos;

		// 	for "_j" from 0 to 5 + random(20) do {
		// 		private _pos2 = [[[_pos, 1000]]] call BIS_fnc_randomPos;
		// 		[_new_grid, _pos2 select 0, _pos2 select 1, 10 * (sqrt (1 + random(100)))] call ws_fnc_setValue; 
		// 	};
		// };

		T_PRVAR(threatGrid);

		// Clear grid
		CALLM(_threatGrid, "setValueAll", [0]);

		{
			private _pos = GETV(_x, "pos") apply { _x - 1000 };
			private _size = GETV(_x, "size") apply { _x + 2000 };
			private _strength = EFF_SUM(GETV(_x, "efficiency"));
			CALLM(_threatGrid, "maxRect", [_pos]+[_size]+[_strength])
		} forEach T_CALLM("getAliveClusters", []);

#ifdef DEBUG_CMDRAI
		CALLM(_threatGrid, "unplot", []);
		CALLM(_threatGrid, "plot", [30]);
#endif
		// private _aliveGarrisons = T_CALLM("getAliveGarrisons", []);

		// private _threatGridOpfCopy = [] call ws_fnc_newGridArray;
		// [_threatGridOpfCopy, _threatGridOpf] call ws_fnc_copyGrid;
		// {
		// 	private _pos = CALLM0(_x, "getPos");
		// 	private _strength = CALLM0(_x, "getStrength");
		// 	[_threatGridOpfCopy, _pos#0, _pos#1, _strength] call ws_fnc_setValue;
		// } forEach (_aliveGarrisons select { CALLM0(_x, "getSide") == side_guer });

		// [_threatGridOpfCopy, _threatGridOpf] call ws_fnc_filterSmooth;
		// [_threatGridOpf, 100] call ws_fnc_plotGrid;
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                G A R R I S O N   F U N C T I O N S                 |
	// ----------------------------------------------------------------------

	METHOD("addGarrison") {
		params [P_THISOBJECT, P_STRING("_garrison")];

		ASSERT_OBJECT_CLASS(_garrison, "GarrisonModel");
		ASSERT_MSG(GETV(_garrison, "id") == MODEL_HANDLE_INVALID, "GarrisonModel is already attached to a WorldModel");

		T_PRVAR(garrisons);

		//#ifdef OOP_ASSERT
		//private _existingId = GETV(_garrison, "id");
		//#endif

		//OOP_DEBUG_MSG("Adding GarrisonModel %1 to WorldModel", [_garrison]);

		REF(_garrison);
		private _idx = _garrisons pushBack _garrison;
		SETV(_garrison, "id", _idx);
		_idx
	} ENDMETHOD;

	METHOD("removeGarrison") {
		params [P_THISOBJECT, P_STRING("_garrison")];

		ASSERT_OBJECT_CLASS(_garrison, "GarrisonModel");
		ASSERT_MSG(GETV(_garrison, "id") != MODEL_HANDLE_INVALID, "GarrisonModel is not attached to a WorldModel");

		// We don't really remove it at the moment, just mark it dead.
		// TODO: removing garrisons properly? That means refactor of whole ID system tho.. Maybe faster though if we can use hash table lookup.
		OOP_DEBUG_MSG("Removing GarrisonModel %1 from WorldModel", [_garrison]);
		CALLM(_garrison, "killed", []);

		//T_PRVAR(garrisons);

		// REF(_garrison);
		// private _idx = _garrisons pushBack _garrison;
		// SETV(_garrison, "id", _idx);
		// _idx
	} ENDMETHOD;

	METHOD("getGarrison") {
		params [P_THISOBJECT, P_NUMBER("_id")];
		T_PRVAR(garrisons);
		_garrisons select _id
	} ENDMETHOD;

	METHOD("findGarrisonByActual") {
		params [P_THISOBJECT, P_STRING("_actual")];

		ASSERT_OBJECT_CLASS(_actual, "Garrison");
		ASSERT_MSG(T_GETV("type") == WORLD_TYPE_REAL, "Trying to find Garrison by Actual in a Sim Model");

		T_PRVAR(garrisons);
		private _idx = _garrisons findIf { GETV(_x, "actual") == _actual };
		if(_idx == NOT_FOUND) exitWith { NULL_OBJECT };
		_garrisons select _idx
	} ENDMETHOD;

	METHOD("findOrAddGarrisonByActual") {
		params [P_THISOBJECT, P_STRING("_actual")];

		ASSERT_OBJECT_CLASS(_actual, "Garrison");
		ASSERT_MSG(T_GETV("type") == WORLD_TYPE_REAL, "Trying to find Garrison by Actual in a Sim Model");

		T_PRVAR(garrisons);
		private _idx = _garrisons findIf { GETV(_x, "actual") == _actual };
		if(_idx == NOT_FOUND) then { 
			private _newGarrison = NEW("GarrisonModel", [_thisObject]+[_actual]);
			_newGarrison
		} else {
			_garrisons select _idx
		}
	} ENDMETHOD;

	METHOD("garrisonKilled") {
		params [P_THISOBJECT, P_STRING("_garrison")];
		// If we are a sim world then we need to perform updates that would otherwise be
		// handled externally, in this case detaching a dead garrison from its outpost
		// if(T_GETV("type") != WORLD_TYPE_REAL) then {
		// 	T_CALLM("detachGarrison", [_garrison]);
		// };
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
			private _dist = _pos distance _center;
			if(_maxDist == 0 or _dist <= _maxDist) then {
				_nearestGarrisons pushBack [_dist, _garrison];
			};
		} forEach T_CALLM("getAliveGarrisons", []);
		_nearestGarrisons sort ASCENDING;
		_nearestGarrisons
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                L O C A T I O N   F U N C T I O N S                 |
	// ----------------------------------------------------------------------

	METHOD("addLocation") {
		params [P_THISOBJECT, P_STRING("_location")];
		ASSERT_OBJECT_CLASS(_location, "LocationModel");

		ASSERT_MSG(GETV(_location, "id") == MODEL_HANDLE_INVALID, "LocationModel is already attached to a WorldModel");

		T_PRVAR(locations);

		REF(_location);
		private _idx = _locations pushBack _location;
		SETV(_location, "id", _idx);
		_idx
	} ENDMETHOD;

	METHOD("getLocation") {
		params [P_THISOBJECT, P_NUMBER("_id")];

		T_PRVAR(locations);
		_locations select _id
	} ENDMETHOD;

	METHOD("findLocationByActual") {
		params [P_THISOBJECT, P_STRING("_actual")];
		ASSERT_OBJECT_CLASS(_actual, "Location");

		ASSERT_MSG(T_GETV("type") == WORLD_TYPE_REAL, "Trying to find Location by Actual in a Sim Model");
		
		T_PRVAR(locations);
		private _idx = _locations findIf { GETV(_x, "actual") == _actual };
		if(_idx == NOT_FOUND) exitWith { NULL_OBJECT };
		_locations select _idx
	} ENDMETHOD;

	METHOD("findOrAddLocationByActual") {
		params [P_THISOBJECT, P_STRING("_actual")];
		ASSERT_OBJECT_CLASS(_actual, "Location");

		ASSERT_MSG(T_GETV("type") == WORLD_TYPE_REAL, "Trying to find Location by Actual in a Sim Model");

		T_PRVAR(locations);
		private _idx = _locations findIf { GETV(_x, "actual") == _actual };
		if(_idx == NOT_FOUND) then { 
			private _newLocation = NEW("LocationModel", [_thisObject]+[_actual]);
			_newLocation
		} else {
			_locations select _idx
		}
	} ENDMETHOD;

	METHOD("getNearestLocations") {
		params [P_THISOBJECT, P_ARRAY("_center"), P_NUMBER("_maxDist")];

		T_PRVAR(locations);

		// TODO: optimize obviously, use spatial partitioning, probably just a grid? Maybe quad tree..
		private _nearestLocations = [];
		{
			private _location = _x;
			private _pos = GETV(_location, "pos");
			private _dist = _pos distance _center;
			if(_maxDist == 0 or _dist <= _maxDist) then {
				_nearestLocations pushBack [_dist, _location];
			};
		} forEach _locations;
		_nearestLocations sort ASCENDING;
		_nearestLocations
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |               C L U S T E R   F U ... N C T I O N S                |
	// ----------------------------------------------------------------------

	METHOD("addCluster") {
		params [P_THISOBJECT, P_STRING("_cluster")];
		ASSERT_OBJECT_CLASS(_cluster, "ClusterModel");

		ASSERT_MSG(GETV(_cluster, "id") == MODEL_HANDLE_INVALID, "ClusterModel is already attached to a WorldModel");
		
		T_PRVAR(clusters);

		REF(_cluster);
		private _idx = _clusters pushBack _cluster;
		SETV(_cluster, "id", _idx);
		_idx
	} ENDMETHOD;

	METHOD("getCluster") {
		params [P_THISOBJECT, P_NUMBER("_id")];
		T_PRVAR(clusters);
		_clusters select _id
	} ENDMETHOD;

	METHOD("findClusterByActual") {
		params [P_THISOBJECT, P_ARRAY("_actual")];
		ASSERT_CLUSTER_ACTUAL_NOT_NULL(_actual);

		ASSERT_MSG(T_GETV("type") == WORLD_TYPE_REAL, "Trying to find Cluster by Actual in a Sim Model");

		T_PRVAR(clusters);
		private _idx = _clusters findIf { GETV(_x, "actual") isEqualTo _actual };
		if(_idx == NOT_FOUND) exitWith { NULL_OBJECT };
		_clusters select _idx
	} ENDMETHOD;

	METHOD("findOrAddClusterByActual") {
		params [P_THISOBJECT, P_ARRAY("_actual")];
		ASSERT_CLUSTER_ACTUAL_NOT_NULL(_actual);

		ASSERT_MSG(T_GETV("type") == WORLD_TYPE_REAL, "Trying to find Cluster by Actual in a Sim Model");

		T_PRVAR(clusters);
		private _idx = _clusters findIf { GETV(_x, "actual") isEqualTo _actual };
		if(_idx == NOT_FOUND) then { 
			private _newCluster = NEW("ClusterModel", [_thisObject]+[_actual]);
			_newLocation
		} else {
			_clusters select _idx
		}
	} ENDMETHOD;

	METHOD("getAliveClusters") {
		params [P_THISOBJECT];
		T_PRVAR(clusters);
		_clusters select { !CALLM(_x, "isDead", []) }
	} ENDMETHOD;

	METHOD("getNearestClusters") {
		params [P_THISOBJECT, P_ARRAY("_center"), P_NUMBER("_maxDist")];

		T_PRVAR(clusters);

		// TODO: optimize obviously, use spatial partitioning, probably just a grid? Maybe quad tree..
		private _nearestClusters = [];
		{
			private _cluster = _x;
			private _pos = GETV(_cluster, "pos");
			private _radius = GETV(_cluster, "radius");
			private _dist = _pos distance _center;
			if(_dist <= (_maxDist + _radius)) then {
				_nearestClusters pushBack [_dist, _cluster];
			};
		} forEach T_CALLM("getAliveClusters", []);
		_nearestClusters sort ASCENDING;
		_nearestClusters
	} ENDMETHOD;

	// This updates a ClusterModel to point directly to a new Actual cluster.
	// This allows us to retarget actions onto new clusters when they merge or split.
	METHOD("retargetClusterByActual") {
		params [P_THISOBJECT, P_ARRAY("_origActual"), P_ARRAY("_newActual")];
		ASSERT_CLUSTER_ACTUAL_NOT_NULL(_origActual);
		ASSERT_CLUSTER_ACTUAL_NOT_NULL(_newActual);

		// This call will do our asserting for us
		private _cluster = T_CALLM("findClusterByActual", [_origActual]);
		ASSERT_OBJECT(_cluster);
		SETV(_cluster, "actual", +_newActual);
	} ENDMETHOD;

	METHOD("deleteClusterByActual") {
		params [P_THISOBJECT, P_ARRAY("_actual")];
		ASSERT_CLUSTER_ACTUAL_NOT_NULL(_actual);

		// This call will do our asserting for us
		private _cluster = T_CALLM("findClusterByActual", [_actual]);
		ASSERT_OBJECT(_cluster);
		CALLM(_cluster, "killed", +_newActual);
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                   S C O R I N G   T O O L K I T                    |
	// ----------------------------------------------------------------------

	METHOD("resetScoringCache") {
		params [P_THISOBJECT];
		T_PRVAR(garrisons);
		private _cache = [];
		_cache resize (count _garrisons);
		T_SETV("reinforceRequiredScoreCache", _cache);
	} ENDMETHOD;
	
	// METHOD("clearScoringCacheForGarrison") {
	// 	params [P_THISOBJECT, P_STRING("_garrison")];
	// 	T_PRVAR("garrisonsReinf")
	// 	T_SETV("reinforceRequiredScoreCache", []);
	// } ENDMETHOD;

	// Get desired efficiency of forces at a particular location.
	METHOD("getDesiredEff") {
		params [P_THISOBJECT, P_ARRAY("_pos")];

		// TODO: This needs to be looking at Clusters not Garrisons!
		// TODO: Implement, grids etc.
		// TODO: Cache it
		EFF_MUL_SCALAR(EFF_MIN_EFF, 2)

		//T_PRVAR(threatGrid);
		
		//private _threat = CALLM(_threatGrid, "getValue", [_pos]);
		
		// _threat is a float so how
		//EFF_MAX(_threat, EFF_MUL_SCALAR(EFF_MIN_EFF, 2))

		// // max(base, nearest enemy forces * 2, threat map * 2);
		// private _base = EFF_MIN_EFF;

		// // Nearest enemy garrison force * 2
		// private _enemyForces = T_CALLM("getNearestGarrisons", [_pos]+[2000]) select {
		// 	_x params ["_dist", "_garr"];
		// 	GETV(_garr, "side") != _side
		// } apply {
		// 	_x params ["_dist", "_garr"];
		// 	EFF_MUL_SCALAR(GETV(_garr, "efficiency"), 2)
		// };

		// // TODO: Maybe should have outpost specific force requirements based on strategy?
		// private _nearEnemyEff = EFF_ZERO;
		// {
		// 	_nearEnemyEff = EFF_MAX(_nearEnemyEff, _x);
		// } forEach _enemyForces;

		// // private _nearEnemyEff = if(count _enemyForces > 0) then {
		// // 	_enemyForces#0
		// // } else { 
		// // 	[0,0] 
		// // };
		
		// // // Threat map converted from strength into a composition of the same strength
		// // private _threatGridForce = if(_side == side_opf) then {
		// // 	T_PRVAR(threatGridOpf);
		// // 	private _strength = [_threatGridOpf, _pos#0, _pos#1] call ws_fnc_getValue;
		// // 	[
		// // 		_strength * 0.7 / UNIT_STRENGTH,
		// // 		_strength * 0.3 / VEHICLE_STRENGTH
		// // 	]
		// // } else {
		// // 	[0,0]
		// // };

		// // [
		// // 	ceil (_base#0 max (_nearEnemyEff#0 max _threatGridForce#0)),
		// // 	ceil (_base#1 max (_nearEnemyEff#1 max _threatGridForce#1))
		// // ]
		// EFF_CEIL(EFF_MAX(_base, _nearEnemyEff))
	} ENDMETHOD;

	// How much over desired efficiency is the garrison? Negative for under.
	METHOD("getOverDesiredEff") {
		params [P_THISOBJECT, P_STRING("_garr")];
		ASSERT_OBJECT_CLASS(_garr, "GarrisonModel");

		private _pos = GETV(_garr, "pos");
		private _eff = GETV(_garr, "efficiency");
		private _desiredEff = T_CALLM("getDesiredEff", [_pos]);
		
		EFF_DIFF(_eff, _desiredEff)
	} ENDMETHOD;

	// How much over desired efficiency is the garrison, scaled. Negative for under.
	METHOD("getOverDesiredEffScaled") {
		params [P_THISOBJECT, P_STRING("_garr"), P_NUMBER("_scalar")];
		ASSERT_OBJECT_CLASS(_garr, "GarrisonModel");

		private _pos = GETV(_garr, "pos");
		private _eff = GETV(_garr, "efficiency");
		private _desiredEff = T_CALLM("getDesiredEff", [_pos]);

		// TODO: is this right, or should it be scaling the final result? 
		// How it is now will (under)exaggerate the desired composition

		EFF_MUL_SCALAR(EFF_DIFF(_eff, _desiredEff), _scalar)
	} ENDMETHOD;

	// A scoring factor for how much a garrison desires reinforcement
	METHOD("getReinforceRequiredScore") {
		params [P_THISOBJECT, P_STRING("_garr")];
		ASSERT_OBJECT_CLASS(_garr, "GarrisonModel");
		//T_PRVAR(reinforceRequiredScoreCache);
		
		//private _garrId = GETV(_garr, "id");
		//private _cacheVal = _reinforceRequiredScoreCache#_garrId;

		//if !(isNil "_cacheVal") exitWith { _cacheVal };

		// How much garr is *under* desired efficiency (so over comp * -1) with a non-linear function applied.
		// i.e. How much more efficiency tgt needs.
		private _overEff = T_CALLM("getOverDesiredEffScaled", [_garr]+[0.75]);
		private _score = EFF_SUM(EFF_MAX_SCALAR(EFF_MUL_SCALAR(_overEff, -1), 0));
	 
		// apply non linear function to threat (https://www.desmos.com/calculator/wnlyulwf7m)
		// This models reinforcement desireability as relative to absolute power of 
		// missing comp rather than relative to ratio of missing comp/desired comp.
		// 
		_score = 0.1 * _score;
		_score = 0 max ( _score * _score * _score );
		//_reinforceRequiredScoreCache set [_garrId, _score];
		_score
	} ENDMETHOD;
ENDCLASS;

// Unit test
#ifdef _SQF_VM

["WorldModel.new", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _class = OBJECT_PARENT_CLASS_STR(_world);
	["Object exists", !(isNil "_class")] call test_Assert;
	["World type correct", GETV(_world, "type") == WORLD_TYPE_SIM_NOW] call test_Assert;
}] call test_AddTest;

["WorldModel.delete", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	DELETE(_world);
	isNil { OBJECT_PARENT_CLASS_STR(_world) }
}] call test_AddTest;

["WorldModel.addGarrison", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _garrison = NEW("GarrisonModel", [_world]);
	// This is called in the GarrisonModel constructor
	//private _id = CALLM(_world, "addGarrison", [_garrison]);
	["Added", count GETV(_world, "garrisons") == 1] call test_Assert;
	["Id correct", GETV(_garrison, "id") == 0] call test_Assert;
}] call test_AddTest;

["WorldModel.getGarrison", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _garrison = NEW("GarrisonModel", [_world]);
	private _id = GETV(_garrison, "id");
	private _got = CALLM(_world, "getGarrison", [_id]);
	_got == _garrison
}] call test_AddTest;

["WorldModel.findGarrisonByActual", {
	private _actual = NEW("Garrison", [WEST]);
	private _world = NEW("WorldModel", [WORLD_TYPE_REAL]);
	private _garrison = NEW("GarrisonModel", [_world] + [_actual]);
	private _got = CALLM(_world, "findGarrisonByActual", [_actual]);
	_got == _garrison
}] call test_AddTest;

["WorldModel.addLocation", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _location = NEW("LocationModel", [_world]);
	// This is called in the LocationModel constructor
	//private _id = CALLM(_world, "addLocation", [_location]);
	["Added", count GETV(_world, "locations") == 1] call test_Assert;
	["Id correct", GETV(_location, "id") == 0] call test_Assert;
}] call test_AddTest;

["WorldModel.getLocation", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _location = NEW("LocationModel", [_world]);
	private _id = GETV(_location, "id");
	private _got = CALLM(_world, "getLocation", [_id]);
	_got == _location
}] call test_AddTest;

["WorldModel.findLocationByActual", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _location = NEW("LocationModel", [_world]);
	private _id = GETV(_location, "id");
	private _got = CALLM(_world, "getLocation", [_id]);
	_got == _location
}] call test_AddTest;

["WorldModel.simCopy", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);

	private _location = NEW("LocationModel", [_world]);
	private _garrison = NEW("GarrisonModel", [_world]);

	private _copy = CALLM(_world, "simCopy", [WORLD_TYPE_SIM_NOW]);
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

["WorldModel.getAliveGarrisons", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _garrison1 = NEW("GarrisonModel", [_world]);
	SETV(_garrison1, "efficiency", EFF_MIN_EFF);
	private _garrison2 = NEW("GarrisonModel", [_world]);
	SETV(_garrison2, "efficiency", EFF_MIN_EFF);
	
	["Initial", count CALLM(_world, "getAliveGarrisons", []) == 2] call test_Assert;
	CALLM(_garrison1, "killed", []);
	["Updates correctly 1", count CALLM(_world, "getAliveGarrisons", []) == 1] call test_Assert;
	CALLM(_garrison2, "killed", []);
	["Updates correctly 2", count CALLM(_world, "getAliveGarrisons", []) == 0] call test_Assert;
}] call test_AddTest;

["WorldModel.getNearestGarrisons", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _garrison1 = NEW("GarrisonModel", [_world]);
	SETV(_garrison1, "pos", [500, 0, 0]);
	SETV(_garrison1, "efficiency", EFF_MIN_EFF);
	private _garrison2 = NEW("GarrisonModel", [_world]);
	SETV(_garrison2, "pos", [1000, 0, 0]);
	SETV(_garrison2, "efficiency", EFF_MIN_EFF);
	private _center = [0,0,0];
	["Dist test none", count CALLM(_world, "getNearestGarrisons", [_center]+[1]) == 0] call test_Assert;
	["Dist test some", count CALLM(_world, "getNearestGarrisons", [_center]+[501]) == 1] call test_Assert;
	["Dist test all", count CALLM(_world, "getNearestGarrisons", [_center]+[1001]) == 2] call test_Assert;
	CALLM(_garrison2, "killed", []);
	["Excluding dead", count CALLM(_world, "getNearestGarrisons", [_center]+[1001]) == 1] call test_Assert;
}] call test_AddTest;

["WorldModel.getNearestLocations", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _location1 = NEW("LocationModel", [_world]);
	SETV(_location1, "pos", [500, 0, 0]);
	private _location2 = NEW("LocationModel", [_world]);
	SETV(_location2, "pos", [1000, 0, 0]);
	private _center = [0,0,0];
	["Dist test none", count CALLM(_world, "getNearestLocations", [_center]+[1]) == 0] call test_Assert;
	["Dist test some", count CALLM(_world, "getNearestLocations", [_center]+[501]) == 1] call test_Assert;
	["Dist test all", count CALLM(_world, "getNearestLocations", [_center]+[1001]) == 2] call test_Assert;
}] call test_AddTest;

#endif
