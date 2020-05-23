#include "..\common.hpp"

// Constant for addDamage function, scales damage to activity
#define DAMAGE_SCALE 1.0

/*
Class: AI.CmdrAI.Model.WorldModel
Models either the real world state, or a derivation of it that can be used for simulation.
*/
#define OOP_CLASS_NAME WorldModel
CLASS("WorldModel", "Storable")

	VARIABLE_ATTR("type", [ATTR_SAVE]);
	VARIABLE_ATTR("garrisons", [ATTR_SAVE]);
	VARIABLE_ATTR("locations", [ATTR_SAVE]);
	VARIABLE_ATTR("clusters", [ATTR_SAVE]);

	VARIABLE("gridMutex");

	// Threat is historic enemy forces in the area
	VARIABLE_ATTR("rawThreatGrid", [ATTR_SAVE]);
	// This is the rawThreatGrid with post processing applied
	VARIABLE_ATTR("threatGrid", [ATTR_SAVE]);
	// Activity to general rating of enemy activity in an area, including damage dealt to us, intel reports about them etc.
	VARIABLE_ATTR("rawActivityGrid", [ATTR_SAVE]);
	// This is the rawActivityGrid with post processing applied
	VARIABLE_ATTR("activityGrid", [ATTR_SAVE]);
	// Damage dealt to us only.
	VARIABLE_ATTR("rawDamageGrid", [ATTR_SAVE]);
	// This is the rawDamageGrid with post processing applied
	VARIABLE_ATTR("damageGrid", [ATTR_SAVE]);

	VARIABLE("lastGridUpdate");

	VARIABLE("cachedGlobalEff");
	VARIABLE("cachedGlobalEffDesired");
	// VARIABLE("reinforceRequiredScoreCache");

	METHOD(new)
		params [P_THISOBJECT, P_NUMBER("_type")];
		T_SETV("type", _type);
		T_SETV("garrisons", []);
		T_SETV("locations", []);
		T_SETV("clusters", []);

		if(_type == WORLD_TYPE_REAL) then {
			private _threatGridArgs = [500, +T_EFF_null];
			private _rawThreatGrid = NEW("Grid", _threatGridArgs);
			private _threatGrid = NEW("Grid", _threatGridArgs);
			private _activityGridArgs = [250, 0];
			private _rawActivityGrid = NEW("Grid", _activityGridArgs);
			private _activityGrid = NEW("Grid", _activityGridArgs);
			private _damageGridArgs = [500, 0];
			private _rawDamageGrid = NEW("Grid", _damageGridArgs);
			private _damageGrid = NEW("Grid", _damageGridArgs);

			T_SETV("rawThreatGrid", _rawThreatGrid);
			T_SETV("threatGrid", _threatGrid);
			
			T_SETV("rawActivityGrid", _rawActivityGrid);
			T_SETV("activityGrid", _activityGrid);
			
			T_SETV("rawDamageGrid", _rawDamageGrid);
			T_SETV("damageGrid", _damageGrid);

			T_SETV("lastGridUpdate", GAME_TIME);
			T_SETV("gridMutex", MUTEX_NEW());
		} else {
			T_SETV("rawThreatGrid", NULL_OBJECT);
			T_SETV("threatGrid", NULL_OBJECT);
			T_SETV("rawActivityGrid", NULL_OBJECT);
			T_SETV("activityGrid", NULL_OBJECT);
			T_SETV("rawDamageGrid", NULL_OBJECT);
			T_SETV("damageGrid", NULL_OBJECT);
		};

		//T_SETV("reinforceRequiredScoreCache", []);
	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];
		private _garrisons = T_GETV("garrisons");
		{ UNREF(_x); } forEach _garrisons;
		private _locations = T_GETV("locations");
		{ UNREF(_x); } forEach _locations;
		private _clusters = T_GETV("clusters");
		{ UNREF(_x); } forEach _clusters;
		if(T_CALLM("isReal", [])) then {
			DELETE(T_GETV("rawThreatGrid"));
			DELETE(T_GETV("threatGrid"));
			DELETE(T_GETV("rawActivityGrid"));
			DELETE(T_GETV("activityGrid"));
			DELETE(T_GETV("rawDamageGrid"));
			DELETE(T_GETV("damageGrid"));
		};
	ENDMETHOD;

	METHOD(isReal)
		params [P_THISOBJECT];
		T_GETV("type") == WORLD_TYPE_REAL
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                       C O P Y / U P D A T E                        |
	// ----------------------------------------------------------------------

	METHOD(simCopy)
		params [P_THISOBJECT, P_NUMBER("_type")];
		ASSERT_MSG(_type == WORLD_TYPE_SIM_NOW or _type == WORLD_TYPE_SIM_FUTURE, "_type must be a sim world type.");

		private _worldCopy = NEW("WorldModel", [_type]);

		// Copy garrisons
		private _garrisons = T_GETV("garrisons");
		//OOP_DEBUG_MSG("simCopy %1 garrisons", [count _garrisons]);
		{ CALLM(_x, "simCopy", [_worldCopy]); } forEach _garrisons;

		// Copy locations
		private _locations = T_GETV("locations");
		//OOP_DEBUG_MSG("simCopy %1 locations", [count _locations]);
		{ CALLM(_x, "simCopy", [_worldCopy]); } forEach _locations;

		// Copy clusters
		private _clusters = T_GETV("clusters");
		//OOP_DEBUG_MSG("simCopy %1 clusters", [count _clusters]);
		{ CALLM(_x, "simCopy", [_worldCopy]); } forEach _clusters;

		//OOP_DEBUG_MSG("simCopy threatGrid", []);
		// Can copy the grid ref as we don't write to it, and we don't need the raw ones in the sim
		private _threatGrid = T_GETV("threatGrid");
		SETV(_worldCopy, "threatGrid", _threatGrid);
		private _activityGrid = T_GETV("activityGrid");
		SETV(_worldCopy, "activityGrid", _activityGrid);
		private _damageGrid = T_GETV("damageGrid");
		SETV(_worldCopy, "damageGrid", _damageGrid);

		private _gridMutex = T_GETV("gridMutex");
		SETV(_worldCopy, "gridMutex", _gridMutex);

		_worldCopy
	ENDMETHOD;

	METHOD(sync)
		params [P_THISOBJECT, P_OOP_OBJECT("_AICommander")];

		{ CALLM0(_x, "sync"); } forEach T_CALLM0("getAliveGarrisons");

		// sync existing locations
		{ CALLM(_x, "sync", [_AICommander]); } forEach T_GETV("locations");

		// sync existing clusters
		{ CALLM0(_x, "sync"); } forEach T_CALLM0("getAliveClusters");

	ENDMETHOD;

	METHOD(update)
		params [P_THISOBJECT];

		// Update grids
		private _rawThreatGrid = T_GETV("rawThreatGrid");
		private _rawActivityGrid = T_GETV("rawActivityGrid");
		private _rawDamageGrid = T_GETV("rawDamageGrid");

		// Fade grids over time

		// (Old code was based on this)
		// https://www.desmos.com/calculator/iyesusko7z
		//

		//https://www.desmos.com/calculator/yplowc31cg

		// Decays twice after 30 minutes
		#define THREAT_FADE_PERIOD (30*60)
		// Decays twice after 100 minutes
		#define ACTIVITY_FADE_PERIOD (100*60)
		// Decays twice after 180 minutes
		#define DAMAGE_FADE_PERIOD (180*60)

		private _lastGridUpdate = T_GETV("lastGridUpdate");
		private _dt = GAME_TIME - _lastGridUpdate;
		T_SETV("lastGridUpdate", GAME_TIME);

		private _threatFade = 2 ^ (-_dt / THREAT_FADE_PERIOD);
		CALLM(_rawThreatGrid, "fade", [_threatFade]);
		private _activityFade = 2 ^ (-_dt / ACTIVITY_FADE_PERIOD);
		CALLM(_rawActivityGrid, "fade", [_activityFade]);
		private _damageFade = 2 ^ (-_dt / DAMAGE_FADE_PERIOD);
		CALLM(_rawDamageGrid, "fade", [_damageFade]);

		#define THREAT_GRID_CLUSTER_OVERSIZE 500
		{
			private _pos = GETV(_x, "pos") apply { _x - THREAT_GRID_CLUSTER_OVERSIZE };
			private _size = GETV(_x, "size") apply { _x + 2 * THREAT_GRID_CLUSTER_OVERSIZE };
			private _threat = GETV(_x, "efficiency");
			CALLM(_rawThreatGrid, "maxRect", [_pos ARG _size ARG _threat]);
		} forEach T_CALLM("getAliveClusters", []);

		private _threatGrid = T_GETV("threatGrid");
		private _activityGrid = T_GETV("activityGrid");
		private _damageGrid = T_GETV("damageGrid");

		MUTEX_SCOPED_LOCK(T_GETV("gridMutex")) {
			CALLM(_threatGrid, "copyFrom", [_rawThreatGrid]);
			CALLM(_activityGrid, "copyFrom", [_rawActivityGrid]);
			CALLM(_damageGrid, "copyFrom", [_rawDamageGrid]);
		};

#ifdef DEBUG_WORLD_MODEL
		CALLM(_threatGrid, "plot", [20 ARG false ARG "Horizontal" ARG ["ColorGreen" ARG "ColorYellow" ARG "ColorBlue"] ARG [0.02 ARG 0.5]]);
		CALLM(_activityGrid, "plot", [20 ARG false ARG "Vertical" ARG ["ColorGreen" ARG "ColorPink" ARG "ColorBlue"] ARG [0.1 ARG 1]]);
		CALLM(_damageGrid, "plot", [20 ARG false ARG "FDiagonal" ARG ["ColorGreen" ARG "ColorRed" ARG "ColorBlue"] ARG [0.1 ARG 1]]);
#endif

		// Update location desireability
	ENDMETHOD;

	METHOD(getThreat) // thread-safe
		params [P_THISOBJECT, P_ARRAY("_pos")];

		private _threat = 0;

		MUTEX_SCOPED_LOCK(T_GETV("gridMutex")) {
			private _threatGrid = T_GETV("threatGrid");
			private _activityGrid = T_GETV("activityGrid");

			_threat = EFF_SUM(CALLM(_threatGrid, "getValue", [_pos])) + CALLM(_activityGrid, "getValue", [_pos]);
		};
		_threat
	ENDMETHOD;


	METHOD(addDamage)
		params [P_THISOBJECT, P_POSITION("_pos"), P_ARRAY("_effDamage")];
		private _rawActivityGrid = T_GETV("rawActivityGrid");

		// We just sum up all the fields for now, with some scaling
		private _value = (_effDamage#T_EFF_soft) + 8*(_effDamage#T_EFF_medium) + 16*(_effDamage#T_EFF_armor) + 32*(_effDamage#T_EFF_air);
		CALLM(_rawActivityGrid, "addValue", [_pos ARG DAMAGE_SCALE*_value]);

		// Add the damage to the damage grid as well
		private _rawDamageGrid = T_GETV("rawDamageGrid");
		CALLM(_rawDamageGrid, "addValue", [_pos ARG DAMAGE_SCALE*_value]);
	ENDMETHOD;

	METHOD(getDamage) // thread-safe
		params [P_THISOBJECT, P_ARRAY("_pos"), P_NUMBER("_radius")];

		private _damage = 0;
		MUTEX_SCOPED_LOCK(T_GETV("gridMutex")) {
			private _damageGrid = T_GETV("damageGrid");
			//_damage = CALLM(_damageGrid, "getMaxValueCircle", [_pos ARG _radius]); // Takes too long
			_damage = CALLM2(_damageGrid, "getValueSquareSum", _pos, _radius);
		};
		_damage
	ENDMETHOD;

	METHOD(getDamageScore)
		params [P_THISOBJECT, P_POSITION("_pos"), P_NUMBER("_radius")];
		private _rawDamage = T_CALLM("getDamage", [_pos ARG _radius]);
		private _campaignProgress = CALLM0(gGameMode, "getCampaignProgress"); // 0..1
		__DAMAGE_FUNCTION(_rawDamage, _campaignProgress)
	ENDMETHOD;

	METHOD(addActivity)
		params [P_THISOBJECT, P_POSITION("_pos"), P_NUMBER("_activity")];
		private _rawActivityGrid = T_GETV("rawActivityGrid");
		CALLM(_rawActivityGrid, "addValue", [_pos ARG _activity]);
	ENDMETHOD;

	METHOD(getActivity) // thread-safe
		params [P_THISOBJECT, P_ARRAY("_pos"), P_NUMBER("_radius")];

		private _activity = 0;
		MUTEX_SCOPED_LOCK(T_GETV("gridMutex")) {
			private _activityGrid = T_GETV("activityGrid");
			//_activity = CALLM(_activityGrid, "getMaxValueCircle", [_pos ARG _radius]); // Takes too long
			_activity = CALLM2(_activityGrid, "getValueSquareSum", _pos, _radius);
		};
		_activity
	ENDMETHOD;

	// METHOD(getActivityTotal) // thread-safe
	// 	params [P_THISOBJECT, P_ARRAY("_pos"), P_NUMBER("_radius")];

	// 	private _activity = 0;
	// 	MUTEX_SCOPED_LOCK(T_GETV("gridMutex")) {
	// 		private _activityGrid = T_GETV("activityGrid");
	// 		_activity = CALLM(_activityGrid, "getMaxValueCircle", [_pos ARG _radius]);
	// 	};
	// 	_activity
	// ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                G A R R I S O N   F U N C T I O N S                 |
	// ----------------------------------------------------------------------

	METHOD(addGarrison)
		params [P_THISOBJECT, P_STRING("_garrison")];

		ASSERT_OBJECT_CLASS(_garrison, "GarrisonModel");
		ASSERT_MSG(GETV(_garrison, "id") == MODEL_HANDLE_INVALID, "GarrisonModel is already attached to a WorldModel");

		private _garrisons = T_GETV("garrisons");

		//#ifdef OOP_ASSERT
		//private _existingId = GETV(_garrison, "id");
		//#endif

		//OOP_DEBUG_MSG("Adding GarrisonModel %1 to WorldModel", [_garrison]);

		REF(_garrison);
		private _idx = _garrisons pushBack _garrison;
		SETV(_garrison, "id", _idx);
		_idx
	ENDMETHOD;

	METHOD(removeGarrison)
		params [P_THISOBJECT, P_STRING("_garrison")];

		ASSERT_OBJECT_CLASS(_garrison, "GarrisonModel");
		ASSERT_MSG(GETV(_garrison, "id") != MODEL_HANDLE_INVALID, "GarrisonModel is not attached to a WorldModel");

		// We don't really remove it at the moment, just mark it dead.
		// TODO: removing garrisons properly? That means refactor of whole ID system tho.. Maybe faster though if we can use hash table lookup.
		OOP_DEBUG_MSG("Removing GarrisonModel %1 from WorldModel", [_garrison]);
		CALLM0(_garrison, "killed");

		//private _garrisons = T_GETV("garrisons");

		// REF(_garrison);
		// private _idx = _garrisons pushBack _garrison;
		// SETV(_garrison, "id", _idx);
		// _idx
	ENDMETHOD;

	METHOD(getGarrison)
		params [P_THISOBJECT, P_NUMBER("_id")];
		private _garrisons = T_GETV("garrisons");
		_garrisons select _id
	ENDMETHOD;

	METHOD(findGarrisonByActual)
		params [P_THISOBJECT, P_STRING("_actual")];

		ASSERT_OBJECT_CLASS(_actual, "Garrison");
		ASSERT_MSG(T_GETV("type") == WORLD_TYPE_REAL, "Trying to find Garrison by Actual in a Sim Model");

		private _garrisons = T_GETV("garrisons");
		private _idx = _garrisons findIf { GETV(_x, "actual") == _actual };
		if(_idx == NOT_FOUND) exitWith { NULL_OBJECT };
		_garrisons select _idx
	ENDMETHOD;

	METHOD(findOrAddGarrisonByActual)
		params [P_THISOBJECT, P_STRING("_actual")];

		ASSERT_OBJECT_CLASS(_actual, "Garrison");
		ASSERT_MSG(T_GETV("type") == WORLD_TYPE_REAL, "Trying to find Garrison by Actual in a Sim Model");

		private _garrisons = T_GETV("garrisons");
		private _idx = _garrisons findIf { GETV(_x, "actual") == _actual };
		if(_idx == NOT_FOUND) then { 
			private _newGarrison = NEW("GarrisonModel", [_thisObject ARG _actual]);
			_newGarrison
		} else {
			_garrisons select _idx
		}
	ENDMETHOD;

	METHOD(garrisonKilled)
		params [P_THISOBJECT, P_STRING("_garrison")];
		// If we are a sim world then we need to perform updates that would otherwise be
		// handled externally, in this case detaching a dead garrison from its outpost
		// if(T_GETV("type") != WORLD_TYPE_REAL) then {
		// 	T_CALLM("detachGarrison", [_garrison]);
		// };
	ENDMETHOD;

	// TODO: Optimize this
	METHOD(getAliveGarrisons)
		params [P_THISOBJECT, P_ARRAY("_includeFactions"), P_ARRAY("_excludeFactions")];

		private _garrisons = T_GETV("garrisons")
			select { 
				!CALLM0(_x, "isDead") 
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
	ENDMETHOD;

	METHOD(getNearestGarrisons)
		params [P_THISOBJECT, P_POSITION("_center"), P_NUMBER("_maxDist"), P_ARRAY("_includeFactions"), P_ARRAY("_excludeFactions")];

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
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                L O C A T I O N   F U N C T I O N S                 |
	// ----------------------------------------------------------------------

	METHOD(addLocation)
		params [P_THISOBJECT, P_STRING("_location")];
		ASSERT_OBJECT_CLASS(_location, "LocationModel");

		ASSERT_MSG(GETV(_location, "id") == MODEL_HANDLE_INVALID, "LocationModel is already attached to a WorldModel");

		private _locations = T_GETV("locations");

		REF(_location);
		private _idx = _locations pushBack _location;
		SETV(_location, "id", _idx);
		_idx
	ENDMETHOD;

	METHOD(getLocation)
		params [P_THISOBJECT, P_NUMBER("_id")];

		private _locations = T_GETV("locations");
		_locations select _id
	ENDMETHOD;

	METHOD(getLocations)
		params [P_THISOBJECT, P_ARRAY("_includeTypes"), P_ARRAY("_excludeTypes")];

		private _locations = T_GETV("locations");
		if((count _includeTypes == 0) and (count _excludeTypes == 0)) then {
			+_locations
		} else {
			_locations select {
				private _type = GETV(_x, "type");
				(count _includeTypes == 0 or {_type in _includeTypes}) and 
				{(count _excludeTypes == 0) or {!(_type in _excludeTypes)}} 
			}
		};
	ENDMETHOD;

	METHOD(findLocationByActual)
		params [P_THISOBJECT, P_STRING("_actual")];
		ASSERT_OBJECT_CLASS(_actual, "Location");

		ASSERT_MSG(T_GETV("type") == WORLD_TYPE_REAL, "Trying to find Location by Actual in a Sim Model");
		
		private _locations = T_GETV("locations");
		private _idx = _locations findIf { GETV(_x, "actual") == _actual };
		if(_idx == NOT_FOUND) exitWith { NULL_OBJECT };
		_locations select _idx
	ENDMETHOD;

	METHOD(findOrAddLocationByActual)
		params [P_THISOBJECT, P_STRING("_actual")];
		ASSERT_OBJECT_CLASS(_actual, "Location");

		ASSERT_MSG(T_GETV("type") == WORLD_TYPE_REAL, "Trying to find Location by Actual in a Sim Model");

		private _locations = T_GETV("locations");
		private _idx = _locations findIf { GETV(_x, "actual") == _actual };
		if(_idx == NOT_FOUND) then { 
			private _newLocation = NEW("LocationModel", [_thisObject ARG _actual]);
			_newLocation
		} else {
			_locations select _idx
		}
	ENDMETHOD;

	METHOD(getNearestLocations)
		params [P_THISOBJECT, P_POSITION("_center"), P_NUMBER("_maxDist"), P_ARRAY("_includeTypes"), P_ARRAY("_excludeTypes")];

		//private _locations = T_GETV("locations");
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
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |               C L U S T E R   F U ... N C T I O N S                |
	// ----------------------------------------------------------------------

	METHOD(addCluster)
		params [P_THISOBJECT, P_STRING("_cluster")];
		ASSERT_OBJECT_CLASS(_cluster, "ClusterModel");

		ASSERT_MSG(GETV(_cluster, "id") == MODEL_HANDLE_INVALID, "ClusterModel is already attached to a WorldModel");
		

		private _clusters = T_GETV("clusters");

		REF(_cluster);
		private _idx = _clusters pushBack _cluster;
		SETV(_cluster, "id", _idx);

		OOP_DEBUG_MSG("Cluster %1 (%2) added to world model", [LABEL(_cluster) ARG _cluster]);

		_idx
	ENDMETHOD;

	METHOD(getCluster)
		params [P_THISOBJECT, P_NUMBER("_id")];
		private _clusters = T_GETV("clusters");
		_clusters select _id
	ENDMETHOD;

	METHOD(findClusterByActual)
		params [P_THISOBJECT, P_ARRAY("_actual")];
		ASSERT_CLUSTER_ACTUAL_NOT_NULL(_actual);

		ASSERT_MSG(T_GETV("type") == WORLD_TYPE_REAL, "Trying to find Cluster by Actual in a Sim Model");

		private _clusters = T_GETV("clusters");
		private _idx = _clusters findIf { GETV(_x, "actual") isEqualTo _actual };
		if(_idx == NOT_FOUND) exitWith { NULL_OBJECT };
		_clusters select _idx
	ENDMETHOD;

	METHOD(findOrAddClusterByActual)
		params [P_THISOBJECT, P_ARRAY("_actual")];
		ASSERT_CLUSTER_ACTUAL_NOT_NULL(_actual);

		ASSERT_MSG(T_GETV("type") == WORLD_TYPE_REAL, "Trying to find Cluster by Actual in a Sim Model");

		private _clusters = T_GETV("clusters");
		private _idx = _clusters findIf { GETV(_x, "actual") isEqualTo _actual };
		if(_idx == NOT_FOUND) then { 
			private _newCluster = NEW("ClusterModel", [_thisObject ARG _actual]);
			_newLocation
		} else {
			_clusters select _idx
		}
	ENDMETHOD;

	METHOD(getAliveClusters)
		params [P_THISOBJECT];
		private _clusters = T_GETV("clusters");
		_clusters select { !CALLM0(_x, "isDead") }
	ENDMETHOD;

	METHOD(getNearestClusters)
		params [P_THISOBJECT, P_ARRAY("_center"), P_NUMBER("_maxDist")];

		private _clusters = T_GETV("clusters");

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
	ENDMETHOD;

	// This updates a ClusterModel to point directly to a new Actual cluster.
	// This allows us to retarget actions onto new clusters when they merge or split.
	METHOD(retargetClusterByActual)
		params [P_THISOBJECT, P_ARRAY("_origActual"), P_ARRAY("_newActual")];
		ASSERT_CLUSTER_ACTUAL_NOT_NULL(_origActual);
		ASSERT_CLUSTER_ACTUAL_NOT_NULL(_newActual);


		// This call will do our asserting for us
		private _cluster = T_CALLM("findClusterByActual", [_origActual]);
		ASSERT_OBJECT(_cluster);
		SETV(_cluster, "actual", +_newActual);

		OOP_DEBUG_MSG("Cluster %1 retargetted to %2", [LABEL(_cluster) ARG _newActual]);
	ENDMETHOD;

	METHOD(deleteClusterByActual)
		params [P_THISOBJECT, P_ARRAY("_actual")];
		ASSERT_CLUSTER_ACTUAL_NOT_NULL(_actual);

		// This call will do our asserting for us
		private _cluster = T_CALLM("findClusterByActual", [_actual]);
		ASSERT_OBJECT(_cluster);
		CALLM0(_cluster, "killed");
		OOP_DEBUG_MSG("Cluster %1 deleted from world model", [LABEL(_cluster)]);
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                   S C O R I N G   T O O L K I T                    |
	// ----------------------------------------------------------------------

	METHOD(resetScoringCache)
		params [P_THISOBJECT];
		private _garrisons = T_GETV("garrisons");
		//private _cache = [];
		//_cache resize (count _garrisons);
		T_SETV("cachedGlobalEff", nil);
		T_SETV("cachedGlobalEffDesired", nil);
		//T_SETV("reinforceRequiredScoreCache", _cache);
	ENDMETHOD;
	
	METHOD(getGlobalEff)
		params [P_THISOBJECT];
		private _cachedGlobalEff = T_GETV("cachedGlobalEff");
		if(isNil "_cachedGlobalEff") exitWith {
			private _cachedGlobalEff = EFF_ZERO;
			{
				_cachedGlobalEff = EFF_ADD(_cachedGlobalEff, _x);
			} forEach (T_CALLM("getAliveGarrisons", [["military"]]) apply { GETV(_x, "efficiency") });
			T_SETV("cachedGlobalEff", _cachedGlobalEff);
			_cachedGlobalEff
		};
		_cachedGlobalEff
	ENDMETHOD;
	
	METHOD(getGlobalEffDesired)
		params [P_THISOBJECT];
		private _cachedGlobalEffDesired = T_GETV("cachedGlobalEffDesired");
		if(isNil "_cachedGlobalEffDesired") exitWith {
			private _cachedGlobalEffDesired = EFF_ZERO;
			{
				private _effRequiredAtPos = T_CALLM("getDesiredEff", [_x]);
				_cachedGlobalEffDesired = EFF_ADD(_cachedGlobalEffDesired, _effRequiredAtPos);
			} forEach (T_CALLM("getAliveGarrisons", [["military"]]) apply { GETV(_x, "pos") });
			T_SETV("cachedGlobalEffDesired", _cachedGlobalEffDesired);
			_cachedGlobalEffDesired
		};
		_cachedGlobalEffDesired
	ENDMETHOD;
	
	METHOD(getGlobalEffDeficit)
		params [P_THISOBJECT];
		private _total = T_CALLM("getGlobalEff", []);
		private _desired = T_CALLM("getGlobalEffDesired", []);
		EFF_DIFF(_desired, _total)
	ENDMETHOD;


	// Force multiplier common for many functions
	// https://www.desmos.com/calculator/2mfk9ka5pi
	// Other valuable formulas:
	// https://www.desmos.com/calculator/csjhfdmntd - exponential response
	// https://www.desmos.com/calculator/ezdykpdcqx - log response
	#define __FORCE_MUL(act) (ln (0.005 * (act) + 1) + 1.003^((act) - 40))

	// Returns same multiplier as in getDesiredEff 
	METHOD(calcActivityMultiplier)
		params [P_THISOBJECT, P_ARRAY("_pos")];
		private _activity = T_CALLM("getActivity", [_pos ARG 750]);
		private _forceMul = __FORCE_MUL(_activity); // 
		_forceMul
	ENDMETHOD;

	// Get desired efficiency of forces at a particular location.
	METHOD(getDesiredEff)
		params [P_THISOBJECT, P_ARRAY("_pos")];

		private _threatGrid = T_GETV("threatGrid");
		if(IS_NULL_OBJECT(_threatGrid)) exitWith {
			EFF_GARRISON_MIN_EFF
		};

		private _threatEff = CALLM(_threatGrid, "getValue", [_pos]);
		private _activity = T_CALLM("getActivity", [_pos ARG 750]);
		private _forceMul = __FORCE_MUL(_activity);
		private _compositeEff = EFF_MUL_SCALAR(_threatEff, _forceMul);
		private _effMax = EFF_MAX(_threatEff, EFF_GARRISON_MIN_EFF);
		//OOP_DEBUG_MSG("_threatEff = %1, _damageEff = %2, _activity = %3, _forceMul = %4, _compositeEff = %5, _effMax = %6", [_threatEff ARG _damageEff ARG _activity ARG _forceMul ARG _compositeEff ARG _effMax]);
		_effMax

		// TODO: This needs to be looking at Clusters not Garrisons!
		// TODO: Implement, grids etc.
		// TODO: Cache it
		// EFF_MUL_SCALAR(EFF_MIN_EFF, 2)

		//private _threatGrid = T_GETV("threatGrid");
		
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
		// // 	private _threatGridOpf = T_GETV("threatGridOpf");
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
	ENDMETHOD;

	// How much over desired efficiency is the garrison? Negative for under.
	METHOD(getOverDesiredEff)
		params [P_THISOBJECT, P_STRING("_garr")];
		ASSERT_OBJECT_CLASS(_garr, "GarrisonModel");

		private _pos = GETV(_garr, "pos");
		private _eff = GETV(_garr, "efficiency");
		private _desiredEff = T_CALLM("getDesiredEff", [_pos]);
		
		EFF_DIFF(_eff, _desiredEff)
	ENDMETHOD;

	// How much over desired efficiency is the garrison, scaled. Negative for under.
	METHOD(getOverDesiredEffScaled)
		params [P_THISOBJECT, P_STRING("_garr"), P_NUMBER("_scalar")];
		ASSERT_OBJECT_CLASS(_garr, "GarrisonModel");

		private _pos = GETV(_garr, "pos");
		private _eff = GETV(_garr, "efficiency");
		private _desiredEff = T_CALLM("getDesiredEff", [_pos]);

		// TODO: is this right, or should it be scaling the final result? 
		// How it is now will (under)exaggerate the desired composition

		EFF_MUL_SCALAR(EFF_DIFF(_eff, _desiredEff), _scalar)
	ENDMETHOD;

	// A scoring factor for how much a garrison desires reinforcement
	METHOD(getReinforceRequiredScore)
		params [P_THISOBJECT, P_STRING("_garr")];
		ASSERT_OBJECT_CLASS(_garr, "GarrisonModel");
		//private _reinforceRequiredScoreCache = T_GETV("reinforceRequiredScoreCache");
		
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
	ENDMETHOD;


	// - - - - - - - STORAGE - - - - - - - - -
	/* override */ METHOD(preSerialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];
		
		// Save our models
		{
			CALLM1(_storage, "save", _x);
		} forEach T_GETV("garrisons");
		{
			CALLM1(_storage, "save", _x);
		} forEach T_GETV("locations");
		{
			CALLM1(_storage, "save", _x);
		} forEach T_GETV("clusters");

		// Save grids
		{
			private _grid = T_GETV(_x);
			if(!IS_NULL_OBJECT(_grid)) then {
				CALLM1(_storage, "save", _grid);
			};
		} forEach ["rawThreatGrid", "threatGrid", "rawActivityGrid", "activityGrid", "rawDamageGrid", "damageGrid"];

		true
	ENDMETHOD;

	/* override */ METHOD(postDeserialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		// Load our models
		{
			CALLM1(_storage, "load", _x);
		} forEach T_GETV("garrisons");
		{
			CALLM1(_storage, "load", _x);
		} forEach T_GETV("locations");
		{
			CALLM1(_storage, "load", _x);
		} forEach T_GETV("clusters");

		// Load grids
		{
			private _grid = T_GETV(_x);
			if(!IS_NULL_OBJECT(_grid)) then {
				CALLM1(_storage, "load", _grid);
			};
		} forEach ["rawThreatGrid", "threatGrid", "rawActivityGrid", "activityGrid", "rawDamageGrid", "damageGrid"];

		// Set up other variables
		T_SETV("gridMutex", MUTEX_NEW());
		T_SETV("lastGridUpdate", GAME_TIME);

		true
	ENDMETHOD;

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
	private _garrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	// This is called in the GarrisonModel constructor
	//private _id = CALLM(_world, "addGarrison", [_garrison]);
	["Added", count GETV(_world, "garrisons") == 1] call test_Assert;
	["Id correct", GETV(_garrison, "id") == 0] call test_Assert;
}] call test_AddTest;

["WorldModel.getGarrison", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _garrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	private _id = GETV(_garrison, "id");
	private _got = CALLM(_world, "getGarrison", [_id]);
	_got == _garrison
}] call test_AddTest;

["WorldModel.findGarrisonByActual", {
	private _actual = NEW("Garrison", [GARRISON_TYPE_GENERAL ARG WEST]);
	private _world = NEW("WorldModel", [WORLD_TYPE_REAL]);
	private _garrison = NEW("GarrisonModel", [_world ARG _actual]);
	private _got = CALLM(_world, "findGarrisonByActual", [_actual]);
	_got == _garrison
}] call test_AddTest;

["WorldModel.addLocation", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _location = NEW("LocationModel", [_world ARG "<undefined>"]);
	// This is called in the LocationModel constructor
	//private _id = CALLM(_world, "addLocation", [_location]);
	["Added", count GETV(_world, "locations") == 1] call test_Assert;
	["Id correct", GETV(_location, "id") == 0] call test_Assert;
}] call test_AddTest;

["WorldModel.getLocation", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _location = NEW("LocationModel", [_world ARG "<undefined>"]);
	private _id = GETV(_location, "id");
	private _got = CALLM(_world, "getLocation", [_id]);
	_got == _location
}] call test_AddTest;

["WorldModel.findLocationByActual", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _location = NEW("LocationModel", [_world ARG "<undefined>"]);
	private _id = GETV(_location, "id");
	private _got = CALLM(_world, "getLocation", [_id]);
	_got == _location
}] call test_AddTest;

["WorldModel.simCopy", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);

	private _location = NEW("LocationModel", [_world ARG "<undefined>"]);
	private _garrison = NEW("GarrisonModel", [_world ARG "<undefined>"]);

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
	private _garrison1 = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	SETV(_garrison1, "efficiency", EFF_MIN_EFF);
	private _garrison2 = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	SETV(_garrison2, "efficiency", EFF_MIN_EFF);
	
	["Initial", count CALLM0(_world, "getAliveGarrisons") == 2] call test_Assert;
	CALLM0(_garrison1, "killed");
	["Updates correctly 1", count CALLM0(_world, "getAliveGarrisons") == 1] call test_Assert;
	CALLM0(_garrison2, "killed");
	["Updates correctly 2", count CALLM0(_world, "getAliveGarrisons") == 0] call test_Assert;
}] call test_AddTest;

["WorldModel.getNearestGarrisons", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _garrison1 = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	SETV(_garrison1, "pos", [500 ARG 0 ARG 0]);
	SETV(_garrison1, "efficiency", EFF_MIN_EFF);
	private _garrison2 = NEW("GarrisonModel", [_world ARG "<undefined>"]);
	SETV(_garrison2, "pos", [1000 ARG 0 ARG 0]);
	SETV(_garrison2, "efficiency", EFF_MIN_EFF);
	private _center = [0,0,0];
	["Dist test none", count CALLM(_world, "getNearestGarrisons", [_center ARG 1]) == 0] call test_Assert;
	["Dist test some", count CALLM(_world, "getNearestGarrisons", [_center ARG 501]) == 1] call test_Assert;
	["Dist test all", count CALLM(_world, "getNearestGarrisons", [_center ARG 1001]) == 2] call test_Assert;
	CALLM0(_garrison2, "killed");
	["Excluding dead", count CALLM(_world, "getNearestGarrisons", [_center ARG 1001]) == 1] call test_Assert;
}] call test_AddTest;

["WorldModel.getNearestLocations", {
	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _location1 = NEW("LocationModel", [_world ARG "<undefined>"]);
	SETV(_location1, "pos", [500 ARG 0 ARG 0]);
	private _location2 = NEW("LocationModel", [_world ARG "<undefined>"]);
	SETV(_location2, "pos", [1000 ARG 0 ARG 0]);
	private _center = [0,0,0];
	["Dist test none", count CALLM(_world, "getNearestLocations", [_center ARG 1]) == 0] call test_Assert;
	["Dist test some", count CALLM(_world, "getNearestLocations", [_center ARG 501]) == 1] call test_Assert;
	["Dist test all", count CALLM(_world, "getNearestLocations", [_center ARG 1001]) == 2] call test_Assert;
}] call test_AddTest;

["WorldModel.save and load", {

	private _world = NEW("WorldModel", [WORLD_TYPE_SIM_NOW]);
	private _garrison = NEW("GarrisonModel", [_world ARG "actualGarrison"]);
	private _location = NEW("LocationModel", [_world ARG "actualLocation"]);

	private _storage = NEW("StorageProfileNamespace", []);
	CALLM1(_storage, "open", "testRecordWorldModel");
	CALLM1(_storage, "save", _world);

	DELETE(_world);

	CALLM1(_storage, "load", _world);

	["Garrison model loaded", GETV(_garrison, "actual") == "actualGarrison"] call test_Assert;
	["Location model loaded", GETV(_location, "actual") == "actualLocation"] call test_Assert;


}] call test_AddTest;

#endif
