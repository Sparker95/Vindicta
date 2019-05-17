#include "..\common.hpp"

CLASS("WorldModel", "")

	VARIABLE("type");
	VARIABLE("garrisons");
	VARIABLE("locations");
	VARIABLE("clusters");

	VARIABLE("gridMutex");

	// Threat is historic enemy forces in the area
	VARIABLE("rawThreatGrid");
	// This is the rawThreatGrid with post processing applied
	VARIABLE("threatGrid");
	// Danger is historic friendly casualties. 
	VARIABLE("rawDamageGrid");
	// This is the rawDamageGrid with post processing applied
	VARIABLE("damageGrid");

	VARIABLE("lastGridUpdate");

	VARIABLE("reinforceRequiredScoreCache");

	METHOD("new") {
		params [P_THISOBJECT, P_NUMBER("_type")];
		T_SETV("type", _type);
		T_SETV("garrisons", []);
		T_SETV("locations", []);
		T_SETV("clusters", []);

		if(_type == WORLD_TYPE_REAL) then {
			private _gridArgs = [500, +T_EFF_null];
			private _rawThreatGrid = NEW("Grid", _gridArgs);
			private _threatGrid = NEW("Grid", _gridArgs);
			private _rawDamageGrid = NEW("Grid", _gridArgs);
			private _damageGrid = NEW("Grid", _gridArgs);
			T_SETV("rawThreatGrid", _rawThreatGrid);
			T_SETV("threatGrid", _threatGrid);
			T_SETV("rawDamageGrid", _rawDamageGrid);
			T_SETV("damageGrid", _damageGrid);
			T_SETV("lastGridUpdate", TIME_NOW);
			T_SETV("gridMutex", MUTEX_NEW());
		} else {
			T_SETV("rawThreatGrid", objNull);
			T_SETV("threatGrid", objNull);
			T_SETV("rawDamageGrid", objNull);
			T_SETV("damageGrid", objNull);
		};

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
		if(T_CALLM("isReal", [])) then {
			DELETE(T_GETV("rawThreatGrid"));
			DELETE(T_GETV("threatGrid"));
			DELETE(T_GETV("rawDamageGrid"));
			DELETE(T_GETV("damageGrid"));
		};
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

		{ CALLM(_x, "sync", []); } forEach T_CALLM("getAliveGarrisons", []);

		// sync existing locations
		{ CALLM(_x, "sync", []); } forEach T_GETV("locations");

		// sync existing clusters
		{ CALLM(_x, "sync", []); } forEach T_CALLM("getAliveClusters", []);

	} ENDMETHOD;

	METHOD("simCopy") {
		params [P_THISOBJECT, P_NUMBER("_type")];
		ASSERT_MSG(_type == WORLD_TYPE_SIM_NOW or _type == WORLD_TYPE_SIM_FUTURE, "_type must be a sim world type.");

		private _worldCopy = NEW("WorldModel", [_type]);

		// Copy garrisons
		T_PRVAR(garrisons);
		//OOP_DEBUG_MSG("simCopy %1 garrisons", [count _garrisons]);
		{ CALLM(_x, "simCopy", [_worldCopy]); } forEach _garrisons;

		// Copy locations
		T_PRVAR(locations);
		//OOP_DEBUG_MSG("simCopy %1 locations", [count _locations]);
		{ CALLM(_x, "simCopy", [_worldCopy]); } forEach _locations;

		// Copy clusters
		T_PRVAR(clusters);
		//OOP_DEBUG_MSG("simCopy %1 clusters", [count _clusters]);
		{ CALLM(_x, "simCopy", [_worldCopy]); } forEach _clusters;

		//OOP_DEBUG_MSG("simCopy threatGrid", []);
		// Can copy the grid ref as we don't write to it, and we don't need the raw ones in the sim
		T_PRVAR(threatGrid);
		SETV(_worldCopy, "threatGrid", _threatGrid);
		T_PRVAR(damageGrid);
		SETV(_worldCopy, "damageGrid", _damageGrid);

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

		T_PRVAR(rawThreatGrid);
		T_PRVAR(rawDamageGrid);

		#define THREAT_FADE_RATE 0.8
		#define DAMAGE_FADE_RATE 0.99
		#define FADE_RATE_PERIOD 60
		#define POW(a, b) (exp ((b) * log (a)))

		// Fade grids over time
		T_PRVAR(lastGridUpdate);
		private _dt = TIME_NOW - _lastGridUpdate;
		T_SETV("lastGridUpdate", TIME_NOW);

		private _threatFade = POW(THREAT_FADE_RATE, _dt / FADE_RATE_PERIOD);
		CALLM(_rawThreatGrid, "fade", [_threatFade]);
		private _damageFade = POW(DAMAGE_FADE_RATE, _dt / FADE_RATE_PERIOD);
		CALLM(_rawDamageGrid, "fade", [_damageFade]);

		#define THREAT_GRID_CLUSTER_OVERSIZE 500
		{
			private _pos = GETV(_x, "pos") apply { _x - THREAT_GRID_CLUSTER_OVERSIZE };
			private _size = GETV(_x, "size") apply { _x + 2 * THREAT_GRID_CLUSTER_OVERSIZE };
			private _threat = GETV(_x, "efficiency");
			private _damage = GETV(_x, "damage");
			CALLM(_rawThreatGrid, "maxRect", [_pos ARG _size ARG _threat]);
			// CALLM(_rawDamageGrid, "maxRect", [_pos ARG _size ARG _damage]);
		} forEach T_CALLM("getAliveClusters", []);

		T_PRVAR(threatGrid);
		T_PRVAR(damageGrid);

		MUTEX_SCOPED_LOCK(T_GETV("gridMutex")) {

			CALLM(_threatGrid, "copyFrom", [_rawThreatGrid]);
			CALLM(_damageGrid, "copyFrom", [_rawDamageGrid]);

			//CALLM(_threatGrid, "smooth5x5", []);
			//CALLM(_damageGrid, "smooth5x5", []);
		};

#ifdef DEBUG_CMDRAI
		//CALLM(_threatGrid, "unplot", []);
		CALLM(_threatGrid, "plot", [20 ARG false ARG "SolidFull" ARG ["ColorGreen" ARG "ColorYellow" ARG "ColorBlue"] ARG [0.02 ARG 0.5]]);
		//CALLM(_damageGrid, "unplot", []);
		CALLM(_damageGrid, "plot", [20 ARG false ARG "DiagGrid" ARG ["ColorGreen" ARG "ColorPink" ARG "ColorBlue"] ARG [0.1 ARG 1]]);
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

	METHOD("getThreat") { // thread-safe
		params [P_THISOBJECT, P_ARRAY("_pos")];

		private _threat = +T_EFF_null;

		MUTEX_SCOPED_LOCK(T_GETV("gridMutex")) {
			//T_PRVAR(threatGrid);
			T_PRVAR(damageGrid);

			_threat = +CALLM(_damageGrid, "getValue", [_pos]);

			// CALLM(_threatGrid, "copyFrom", [_rawThreatGrid]);
			// CALLM(_damageGrid, "copyFrom", [_rawDamageGrid]);

			// CALLM(_threatGrid, "smooth5x5", []);
			// CALLM(_damageGrid, "smooth5x5", []);
		};
		_threat
	} ENDMETHOD;

	METHOD("addDamage") {
		params [P_THISOBJECT, P_POSITION("_pos"), P_ARRAY("_effDamage")];
		T_PRVAR(rawDamageGrid);
		CALLM(_rawDamageGrid, "addValue", [_pos ARG _effDamage]);
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
			private _newGarrison = NEW("GarrisonModel", [_thisObject ARG _actual]);
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
		params [P_THISOBJECT, P_ARRAY("_includeFactions"), P_ARRAY("_excludeFactions")];

		private _garrisons = T_GETV("garrisons")
			select { 
				!CALLM(_x, "isDead", []) 
			};

		if((count _includeFactions == 0) and (count _excludeFactions == 0)) then {
			+_garrisons
		} else {
			_garrisons select {
				private _faction = GETV(_x, "faction");
				(count _includeFactions == 0 or {_faction in _includeFactions}) and 
				{(count _excludeFactions == 0) or {!(_faction in _excludeFactions)}} 
			}
		};
	} ENDMETHOD;

	METHOD("getNearestGarrisons") {
		params [P_THISOBJECT, P_ARRAY("_center"), P_NUMBER("_maxDist"), P_ARRAY("_includeFactions"), P_ARRAY("_excludeFactions")];

		// TODO: optimize obviously, use spatial partitioning, probably just a grid? Maybe quad tree..
		private _nearestGarrisons = [];

		{
			private _garrison = _x;
			private _pos = GETV(_garrison, "pos");
			private _dist = _pos distance _center;
			if(_maxDist == 0 or _dist <= _maxDist) then {
				_nearestGarrisons pushBack [_dist, _garrison];
			};
		} forEach T_CALLM("getAliveGarrisons", [_includeFactions ARG _excludeFactions]);
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

	METHOD("getLocations") {
		params [P_THISOBJECT, P_ARRAY("_includeTypes"), P_ARRAY("_excludeTypes")];

		T_PRVAR(locations);
		if((count _includeTypes == 0) and (count _excludeTypes == 0)) then {
			+_locations
		} else {
			_locations select {
				private _type = GETV(_x, "type");
				(count _includeTypes == 0 or {_type in _includeTypes}) and 
				{(count _excludeTypes == 0) or {!(_type in _excludeTypes)}} 
			}
		};
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
			private _newLocation = NEW("LocationModel", [_thisObject ARG _actual]);
			_newLocation
		} else {
			_locations select _idx
		}
	} ENDMETHOD;

	METHOD("getNearestLocations") {
		params [P_THISOBJECT, P_ARRAY("_center"), P_NUMBER("_maxDist"), P_ARRAY("_includeTypes"), P_ARRAY("_excludeTypes")];

		//T_PRVAR(locations);
		// TODO: optimize obviously, use spatial partitioning, probably just a grid? Maybe quad tree..
		// TODO: is select, sort, while faster here?
		private _nearestLocations = 
			T_CALLM("getLocations", [_includeTypes ARG _excludeTypes])
			apply {
				[GETV(_x, "pos") distance _center, _x]
			} select {
				(_maxDist == 0) or (_x#0 <= _maxDist)
			};
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

		OOP_DEBUG_MSG("Cluster %1 (%2) added to world model", [LABEL(_cluster) ARG _cluster]);

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
			private _newCluster = NEW("ClusterModel", [_thisObject ARG _actual]);
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

		OOP_DEBUG_MSG("Cluster %1 retargetted to %2", [LABEL(_cluster) ARG _newActual]);
	} ENDMETHOD;

	METHOD("deleteClusterByActual") {
		params [P_THISOBJECT, P_ARRAY("_actual")];
		ASSERT_CLUSTER_ACTUAL_NOT_NULL(_actual);

		// This call will do our asserting for us
		private _cluster = T_CALLM("findClusterByActual", [_actual]);
		ASSERT_OBJECT(_cluster);
		CALLM(_cluster, "killed", []);
		OOP_DEBUG_MSG("Cluster %1 deleted from world model", [LABEL(_cluster)]);
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

		T_PRVAR(threatGrid);
		if(_threatGrid isEqualTo objNull) exitWith {
			EFF_MIN_EFF
		};
		T_PRVAR(damageGrid);

		private _threatEff = CALLM(_threatGrid, "getValue", [_pos]);
		private _damageEff = CALLM(_damageGrid, "getValue", [_pos]);
		private _dmgSum = EFF_SUM(_damageEff);
		// Efficiency formula to give exponentiating response (https://www.desmos.com/calculator/csjhfdmntd)
		_dmgSum = (0.015 * _dmgSum);
		private _forceMul = 1.5 max (1 + _dmgSum * _dmgSum * _dmgSum * _dmgSum);
		private _compositeEff = EFF_MAX(EFF_MUL_SCALAR(_threatEff, _forceMul), _damageEff);
		private _effMax = EFF_MAX(_threatEff, EFF_MIN_EFF);
		_effMax
		// TODO: This needs to be looking at Clusters not Garrisons!
		// TODO: Implement, grids etc.
		// TODO: Cache it
		// EFF_MUL_SCALAR(EFF_MIN_EFF, 2)

		//T_PRVAR(threatGrid);
		
		//private _threat = CALLM(_threatGrid, "getValue", [_pos]);
		
		// _threat is a float so how
		//EFF_MAX(_threat, EFF_MUL_SCALAR(EFF_MIN_EFF, 2))

		// // max(base, nearest enemy forces * 2, threat map * 2);
		// private _base = EFF_MIN_EFF;

		// // Nearest enemy garrison force * 2
		// private _enemyForces = T_CALLM("getNearestGarrisons", [_pos ARG 2000]) select {
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
		private _overEff = T_CALLM("getOverDesiredEffScaled", [_garr ARG 0.75]);
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
	["Dist test none", count CALLM(_world, "getNearestGarrisons", [_center ARG 1]) == 0] call test_Assert;
	["Dist test some", count CALLM(_world, "getNearestGarrisons", [_center ARG 501]) == 1] call test_Assert;
	["Dist test all", count CALLM(_world, "getNearestGarrisons", [_center ARG 1001]) == 2] call test_Assert;
	CALLM(_garrison2, "killed", []);
	["Excluding dead", count CALLM(_world, "getNearestGarrisons", [_center ARG 1001]) == 1] call test_Assert;
}] call test_AddTest;

["WorldModel.getNearestLocations", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _location1 = NEW("LocationModel", [_world]);
	SETV(_location1, "pos", [500, 0, 0]);
	private _location2 = NEW("LocationModel", [_world]);
	SETV(_location2, "pos", [1000, 0, 0]);
	private _center = [0,0,0];
	["Dist test none", count CALLM(_world, "getNearestLocations", [_center ARG 1]) == 0] call test_Assert;
	["Dist test some", count CALLM(_world, "getNearestLocations", [_center ARG 501]) == 1] call test_Assert;
	["Dist test all", count CALLM(_world, "getNearestLocations", [_center ARG 1001]) == 2] call test_Assert;
}] call test_AddTest;

#endif
