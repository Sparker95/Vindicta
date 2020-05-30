#include "common.hpp"

/*
Sensor for a commander to receive spotted enemies from its garrisons and relay them to other garrisons.
Author: Sparker 21.12.2018
*/

#define pr private

// Update interval of this sensor
#define UPDATE_INTERVAL 6

// Maximum age of target before it is deleted
// Note that it must be below 60
#define TARGET_MAX_AGE_MINUTES 50

// ---- Debugging defines ----

// Will print to the RPT targets received from groups
//#define PRINT_RECEIVED_TARGETS

#ifndef RELEASE_BUILD
#define DEBUG_CLUSTERS
#endif

//#define DEBUG_TARGETS

#define OOP_CLASS_NAME SensorCommanderTargets
CLASS("SensorCommanderTargets", "SensorStimulatable")

	VARIABLE("newTargets"); // Targets which were recognized as new will be added to this array on receiving new targets stimulus
	VARIABLE("deletedTargets"); // Targets recognized as deleted will be added to this array on receiving forget targets stimulus

	#ifdef DEBUG_CLUSTERS
	VARIABLE("debug_nextMarkerID");
	VARIABLE("debug_clusterMarkers");
	#endif

	METHOD(new)
		params [P_THISOBJECT];
		
		T_SETV("newTargets", []);
		T_SETV("deletedTargets", []);
		
		#ifdef DEBUG_CLUSTERS
		T_SETV("debug_nextMarkerID", 0);
		T_SETV("debug_clusterMarkers", []);
		#endif
		
	ENDMETHOD;


	// ----------------------------------------------------------------------
	// |                              U P D A T E
	// | Updates the state of this sensor
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD(update)
		params [P_THISOBJECT];
		
		pr _AI = T_GETV("AI");
		pr _ourSide = GETV(_AI, "side");
		pr _deletedTargets = T_GETV("deletedTargets");
		pr _newTargets = T_GETV("newTargets");
		pr _knownTargets = GETV(_AI, "targets");
		
		// Exit if there are no known targets
		if (count _knownTargets == 0) exitWith {};
		
		OOP_INFO_0("UPDATE");
		
		pr _targetClusters = GETV(_AI, "targetClusters");
		
		// Delete old and destroyed targets
		pr _AI = T_GETV("AI");
		if (count _knownTargets > 0) then {
			pr _dateNumber = dateToNumber date;
			pr _dateNumberThreshold = dateToNumber [date#0,1,1,0,TARGET_MAX_AGE_MINUTES];
			_deletedTargets append (
				// Currently cmdr does not forget destroyed targets
				// We can't call any methods on enemy units because we do not own them
				_knownTargets select {
					((_dateNumber - (_x select TARGET_COMMANDER_ID_DATE_NUMBER)) > _dateNumberThreshold)
				}
			);
			
			_knownTargets = _knownTargets - _deletedTargets;
			SETV(_AI, "targets", _knownTargets);
		};
		
		// Add new targets
		//_knownTargets append _newTargets;
		
		// Build the clusters again
		pr _unitClusters = _knownTargets apply {
			pr _posx = _x select TARGET_ID_POS select 0;
			pr _posy = _x select TARGET_ID_POS select 1;
			CLUSTER_NEW(_posx, _posy, _posx, _posy, [_x])
		};
		pr _newClusters = [_unitClusters, TARGETS_CLUSTER_DISTANCE_MIN] call cluster_fnc_findClusters;
		
		// Calculate the efficiency vector of each cluster
		/*
		pr _clustersEfficiency = [];
		{
			pr _eff = +T_EFF_null; // Empty efficiency vector
			pr _clusterTargets = _x select CLUSTER_ID_OBJECTS;
			{
				_hO = _x select TARGET_ID_UNIT;
				_objEff = _hO getVariable [UNIT_EFFICIENCY_VAR_NAME_STR, T_EFF_default];
				_eff = EFF_ADD(_eff, _objEff);
			} forEach _clusterTargets;
			_clustersEfficiency pushBack _eff;
		} forEach _newClusters;
		*/

		// Calculate max time of each cluster

		
		// Calculate affinity of clusters
		// Affinity shows how many units from every previous cluster are in every new cluster
		OOP_INFO_0("Calculating cluster affinity");
		OOP_INFO_1("Old clusters: %1", _targetClusters);
		OOP_INFO_1("New clusters: %1", _newClusters);
		pr _affinity = [];
		_affinity resize (count _newClusters);
		for "_newClusterID" from 0 to (count _newClusters - 1) do {
			pr _row = [];
			_row resize (count _targetClusters);
			
			pr _newObjects = (_newClusters select _newClusterID select CLUSTER_ID_OBJECTS) apply {_x select TARGET_ID_UNIT};
			for "_oldClusterID" from 0 to (count _targetClusters - 1) do {
				pr _oldObjects = (_targetClusters select _oldClusterID select TARGET_CLUSTER_ID_CLUSTER select CLUSTER_ID_OBJECTS) apply {_x select TARGET_ID_UNIT};
				pr _a = count ( _oldObjects arrayIntersect _newObjects ); // Count ammount of the same elements
				_row set [_oldClusterID, _a];
			};
			_affinity set [_newClusterID, _row];
			OOP_INFO_1("  %1", _row);
		};
		OOP_INFO_0("- - - - - - - -");
		
		// Delete all old map markers
		#ifdef DEBUG_CLUSTERS
		{
			deleteMarker _x;
		} forEach T_GETV("debug_clusterMarkers");
		T_SETV("debug_clusterMarkers", []);
		#endif
		
		// Create new target clusters
		pr _newTargetClusters = [];
		{ // foreach newClusters
			pr _newTargetClusterIndex = _forEachIndex;
			
			// Calculate the efficiency vector of each cluster
			// Calculate max spotted time of each cluster
			// Check who targets in this cluster are observed by
			pr _eff = +T_EFF_null; // Empty efficiency vector
			pr _maxDateNumber = 0;
			pr _observedBy = [];
			pr _clusterTargets = _x select CLUSTER_ID_OBJECTS;
			{
				_unit = _x select TARGET_COMMANDER_ID_UNIT;
				_objEff = _x select TARGET_COMMANDER_ID_EFFICIENCY;
				_eff = EFF_ADD(_eff, _objEff);

				_dateNumber = _x select TARGET_COMMANDER_ID_DATE_NUMBER;
				if (_dateNumber > _maxDateNumber) then { _maxDateNumber = _dateNumber; };
				
				{_observedBy pushBackUnique _x} forEach (_x select TARGET_COMMANDER_ID_OBSERVED_BY);
			} forEach _clusterTargets;
			
			pr _newTC = TARGET_CLUSTER_NEW();
			_newTC set [TARGET_CLUSTER_ID_ID, -1]; // Set invalid ID first
			_newTC set [TARGET_CLUSTER_ID_CLUSTER, _x];
			_newTC set [TARGET_CLUSTER_ID_EFFICIENCY, _eff];
			_newTC set [TARGET_CLUSTER_ID_CAUSED_DAMAGE, +T_EFF_null]; // Not used any more
			_newTC set [TARGET_CLUSTER_ID_OBSERVED_BY, _observedBy];
			_newTC set [TARGET_CLUSTER_ID_MAX_DATE_NUMBER, _maxDateNumber];
			
			// Check affinity of this new cluster, propagate damage from old clusters to new clusters
			pr _affinityRow = _affinity select _newTargetClusterIndex; // This row in affinity matrix shows affinity of this new target cluster with every old target cluster
			pr _sumAffinityRow = 0; { _sumAffinityRow = _sumAffinityRow + _x; } forEach _affinityRow;
			pr _nAffAboveZero = 0; // Amount of elements above zero			
			{ // forEach _affinityRow
				pr _affinityNewOld = _x;
				
				// If this new cluster has some units which were in the old cluster
				if (_affinityNewOld > 0) then {
					// Add IDs from old cluster to the new one
					pr _oldClusterIndex = _forEachIndex;
					pr _oldTargetCluster = _targetClusters select _oldClusterIndex;
					
					// Add caused damage to this cluster from the old one, proportional to the affinity
					pr _c = _affinityNewOld / _sumAffinityRow;
					pr _damageToAdd = (_oldTargetCluster select TARGET_CLUSTER_ID_CAUSED_DAMAGE) apply {_c * _x};
					pr _newTCDamage = _newTC select TARGET_CLUSTER_ID_CAUSED_DAMAGE;
					_newTCDamage = EFF_ADD(_newTCDamage, _damageToAdd);
					_newTC set [TARGET_CLUSTER_ID_CAUSED_DAMAGE, _newTCDamage];
					
					// Increase counter of affinity above zero
					_nAffAboveZero = _nAffAboveZero + 1;
				};
			} forEach _affinityRow;
			
			// If this cluster inherits from >1 clusters, it needs a new unique ID
			if (_nAffAboveZero > 1) then {
				_newTC set [TARGET_CLUSTER_ID_ID, -2]; // Needs a new ID
				OOP_INFO_0("New target cluster inherits from multiple target clusters");
			};
			
			// Add new target cluster to the array of target clusters			
			_newTargetClusters pushBack _newTC;
		} forEach _newClusters;
		
		
		// Check which old clusters generate multiple new clusters so that we generate new IDs for them
		{ // forEach _targetClusters;
			pr _oldTargetCluster = _x;
			pr _oldTargetClusterIndex = _forEachIndex;
			pr _nRowAboveZero = 0; // Sum all values in the column
			{ if ((_x select _oldTargetClusterIndex) > 0) then {_nRowAboveZero = _nRowAboveZero + 1;}; } forEach _affinity;
			
			OOP_INFO_2("Analyzing old cluster. _nRowAboveZero: %1, ID: %2", _nRowAboveZero, _oldTargetCluster select TARGET_CLUSTER_ID_ID);
			
			if (_nRowAboveZero > 1) then { // If this old cluster got separated into multiple new clusters or just into one
				pr _newSplitTCs = []; // Array with new split target clusters and their affinity: [_affinity, _targetCluster]
				{ // The new clusters branched from it need new ID
					pr _newTC = _newTargetClusters select _forEachIndex;
					pr _existingID = _newTC select TARGET_CLUSTER_ID_ID;
					pr _a = _x select _oldTargetClusterIndex;
					// Now existing new target cluster ID is -1 or -2
					// -2 - needs new ID because it was inherited from multiple clusters
					// -1 - either was connected with one or with zero old clusters
					if (_a > 0) then {
						if (_existingID == -1 || _existingID == -2) then { // Make a new ID if it wasn't made yet
							pr _newID = CALLM0(_AI, "getNewTargetClusterID");
							_newTC set [TARGET_CLUSTER_ID_ID, _newID]; // Needs a new ID
							OOP_INFO_1("Assigned new ID to new target cluster: %1", _newID);
						};
						_newSplitTCs pushBack [_a, _newTC];
					};
				} forEach _affinity;
				
				// Notify AICommander that the target cluster got splitted
				CALLM2(_AI, "onTargetClusterSplitted", _oldTargetCluster, _newSplitTCs);
			} else {
				if (_nRowAboveZero == 1) then { // This old target cluster is connected with one new cluster
					
				} else { // This old target cluster is not connected with a new one so it will be deleted
					CALLM1(_AI, "onTargetClusterDeleted", _oldTargetCluster);
				};
			};
		} forEach _targetClusters;
		
		
		{ // forEach _newTargetClusters;
			pr _newTC = _x;
			pr _newTargetClusterIndex = _forEachIndex;
			pr _affinityRow = _affinity select _newTargetClusterIndex; // This row in affinity matrix shows affinity of this new target cluster with every old target cluster
			pr _nAffAboveZero = {_x > 0} count _affinityRow; // Amount of elements above zero
			
			pr _ID = _x select TARGET_CLUSTER_ID_ID;
			
			OOP_INFO_2("Analyzing new cluster. _nAffAboveZero: %1, ID: %2", _nAffAboveZero, _ID);
			
			// By now ID is -1, -2 or already assigned
			// If it's -2 then there was some merging/splitting and it needs a new ID
			// If it's -1 then it's either a totally new cluster or it inherits from some old cluster without any merging
			
			if (_ID == -1) then {
				if (_nAffAboveZero == 0) then {
					// The new cluster is totally unrelated with any old cluster, so it's a new one
					// Generate a new ID for it
					pr _ID = CALLM0(_AI, "getNewTargetClusterID");
					_newTC set [TARGET_CLUSTER_ID_ID, _ID];
					//ade_dumpcallstack;
					// We don't register it here, the commander does it
					CALLM1(_AI, "onTargetClusterCreated", _newTC);
				} else {
					// It inherits from one old cluster, need to find what it inherits from
					pr _i = 0;
					while {_i < (count _affinityRow)} do {
						if (_affinityRow select _i > 0) exitWith { // Found the old cluster this cluster is connected with
							pr _ID = _targetClusters select _i select TARGET_CLUSTER_ID_ID; // Copy the ID fron old one to the new cluster
							_newTC set [TARGET_CLUSTER_ID_ID, _ID];
							pr _intel = _targetClusters select _i select TARGET_CLUSTER_ID_INTEL; // Copy intel from old cluster to new cluster
							_newTC set [TARGET_CLUSTER_ID_INTEL, _intel];
							
							OOP_INFO_1("New target cluster inherits from old cluster with ID: %1", _ID);
							CALLM1(_AI, "onTargetClusterUpdated", _newTC);
						};
						_i = _i + 1;
					};
				};
			} else {
				if (_ID == -2) then {
					// This new cluster is a merge of multiple old clusters
					// Generate a new ID for it
					pr _ID = CALLM0(_AI, "getNewTargetClusterID");
					_newTC set [TARGET_CLUSTER_ID_ID, _ID];
					
					OOP_INFO_1("Generated a new ID for new target cluster: %1", _ID);
					
					// Find clusters that got merged into this one
					pr _oldTCs = [];
					{
						if (_x > 0) then { _oldTCs pushBack (_targetClusters select _forEachIndex); };
					} forEach _affinityRow;
					// Notify AICommander
					CALLM2(_AI, "onTargetClustersMerged", _oldTCs, _newTC);
				};
			};
			
			// Update map markers
			#ifdef DEBUG_CLUSTERS
				T_CALLM1("drawCluster", _newTC);
			#endif
		} forEach _newTargetClusters;
		
		
		
		
		// Overwrite the old cluster array
		SETV(_AI, "targetClusters", _newTargetClusters);
		
		/*
		// Update old clusters
		CALLM0(_AI, "deleteAllTargetClusters");
		{
			CALLM2(_AI, "createNewTargetCluster", _x, _clustersEfficiency select _forEachIndex);
		} forEach _newClusters;
		*/
		
		// Reset the new targets and deleted targets array
		T_SETV("newTargets", []);
		T_SETV("deletedTargets", []);
		
	ENDMETHOD;
	
	METHOD(drawCluster)
		params [P_THISOBJECT, "_tc"];
		
		pr _AI = T_GETV("AI");
		pr _c = _tc select TARGET_CLUSTER_ID_CLUSTER;
		pr _eff = _tc select TARGET_CLUSTER_ID_EFFICIENCY;
		pr _ID = _tc select TARGET_CLUSTER_ID_ID;
		// Get color for markers
		pr _side = GETV(_AI, "side");
		pr _colorEnemy = switch (_side) do {
			case WEST: {"ColorWEST"};
			case EAST: {"ColorEAST"};
			case INDEPENDENT: {"ColorGUER"};
			default {"ColorCIV"};
		};
	
		pr _clusterMarkers = T_GETV("debug_clusterMarkers");
		// Create marker for the cluster
		pr _nextMarkerID = T_GETV("debug_nextMarkerID");
		pr _name = format ["%1_mrk_%2", _thisObject, _nextMarkerID]; _nextMarkerID = _nextMarkerID + 1;
		pr _cCenter = _c call cluster_fnc_getCenter;
		pr _mrk = createMarker [_name, _cCenter];
		pr _width = 10 + 0.5*((_c select 2) - (_c select 0)); //0.5*(x2-x1)
		pr _height = 10 + 0.5*((_c select 3) - (_c select 1)); //0.5*(y2-y1)
		_mrk setMarkerShape "RECTANGLE";
		_mrk setMarkerBrush "SolidFull";
		_mrk setMarkerSize [_width, _height];
		_mrk setMarkerColor _colorEnemy;
		_mrk setMarkerAlpha 0.3;
		_clusterMarkers pushBack _mrk;
		
		// Add markers for spotted units
		{
			pr _name = format ["%1_mrk_%2", _thisObject, _nextMarkerID]; _nextMarkerID = _nextMarkerID + 1;
			pr _mrk = createmarker [_name, _x select TARGET_ID_POS];
			_mrk setMarkerType "mil_box";
			_mrk setMarkerColor _colorEnemy;
			_mrk setMarkerAlpha 0.5;
			_mrk setMarkerText "";
			_clusterMarkers pushBack _mrk;
			//_mrk setMarkerText (format ["%1", round ((_e select 2) select _i)]); //Enemy age
			
		} forEach (_c select CLUSTER_ID_OBJECTS);
		
		// Add marker with some text
		pr _name = format ["%1_mrk_%2", _thisObject, _nextMarkerID]; _nextMarkerID = _nextMarkerID + 1;
		pr _mrk = createmarker [_name, _cCenter];
		_mrk setMarkerType "mil_dot";
		_mrk setMarkerColor "ColorPink";
		_mrk setMarkerAlpha 1.0;
		_mrk setMarkerText format ["id: %1, e: %2, dmg: %3, obsrv: %4", _ID, _tc select TARGET_CLUSTER_ID_EFFICIENCY, _tc select TARGET_CLUSTER_ID_CAUSED_DAMAGE, _tc select TARGET_CLUSTER_ID_OBSERVED_BY];
		_clusterMarkers pushBack _mrk;
		
		T_SETV("debug_nextMarkerID", _nextMarkerID);
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    U P D A T E   I N T E R V A L
	// | Must return the desired update rate of this sensor
	// ----------------------------------------------------------------------
	
	METHOD(getUpdateInterval)
		UPDATE_INTERVAL
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T  S T I M U L U S   T Y P E S
	// | Returns the array with stimulus types this sensor can be stimulated by
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD(getStimulusTypes)
		[STIMULUS_TYPE_TARGETS]
	ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                           H A N D L E   S T I M U L U S
	// | Performs sensor-specific actions if doComplexCheck has returned true
	// ----------------------------------------------------------------------
	
	/*virtual*/ METHOD(handleStimulus)
		params [P_THISOBJECT, P_ARRAY("_stimulus")];
		
		#ifdef DEBUG_TARGETS
		OOP_INFO_1("Received targets: %1", STIMULUS_GET_VALUE(_stimulus));
		#endif
		
		// Filter spotted enemies
		pr _sourceGarrison = STIMULUS_GET_SOURCE(_stimulus);
		pr _AI = T_GETV("AI");
		pr _knownTargets = GETV(_AI, "targets");
		// We only care about known and resolved unit objects
		pr _validStimulus = STIMULUS_GET_VALUE(_stimulus) select {
			IS_OOP_OBJECT(_x select TARGET_ID_UNIT)
		};
		//pr _newTargets = T_GETV("newTargets");
		{// forEach _validStimulus
			// Check if the target is already known
			pr _unit = _x select TARGET_ID_UNIT;
			/*
			#ifdef KEEP_DESTROYED_TARGETS
			if (alive _hO) then {
			#endif
			*/
				pr _index = _knownTargets findIf {(_x select TARGET_ID_UNIT) isEqualTo _unit};
				if (_index == -1) then {
					// Didn't find an existing entry
					// Add a new target record
					pr _newCommanderTarget = TARGET_COMMANDER_NEW(_unit,
												_x select TARGET_ID_KNOWS_ABOUT,
												_x select TARGET_ID_POS,
												_x select TARGET_ID_DATE_NUMBER,
												_x select TARGET_ID_EFFICIENCY,
												[_sourceGarrison]);
					
					#ifdef DEBUG_TARGETS
					OOP_INFO_1("Added new target: %1", _newCommanderTarget);
					#endif
					
					// Add it to the array
					_knownTargets pushBack _newCommanderTarget;

					
				} else {
				
					#ifdef DEBUG_TARGETS
					OOP_INFO_1("Updated existing target: %1", _x);
					#endif
					
					// Found an existing entry
					pr _targetExisting = _knownTargets select _index;
					
					// Check time the target was previously spotted
					pr _timeNew = _x select TARGET_ID_DATE_NUMBER;
					pr _timePrev = _targetExisting select TARGET_ID_DATE_NUMBER;
					// Is the new report newer than the old record?
					if (_timeNew > _timePrev) then {
						// Update the old record
						_targetExisting set [TARGET_COMMANDER_ID_POS, _x select TARGET_ID_POS];
						_targetExisting set [TARGET_COMMANDER_ID_DATE_NUMBER, _timeNew];
						_targetExisting set [TARGET_COMMANDER_ID_KNOWS_ABOUT, _x select TARGET_ID_KNOWS_ABOUT];
						(_targetExisting select TARGET_COMMANDER_ID_OBSERVED_BY) pushBackUnique _sourceGarrison;
					};
				};
			/*
			#ifdef KEEP_DESTROYED_TARGETS
			};
			#endif
			*/
		} forEach _validStimulus;
		
	ENDMETHOD;
	
ENDCLASS;



// Junk
		// Correct existing clusters by deleting the deleted targets
		/*
		{
			pr _target = _x;
			pr _i = 0;
			for "_i" from 0 to (count _targetClusters - 1) do
			{
				pr _targetCluster = _targetClusters select _i;
				pr _cluster = _targetCluster select TARGET_CLUSTER_ID_CLUSTER;
				pr _clusterTargets = _cluster select CLUSTER_ID_OBJECTS;
				// If this deleted target was in this cluster
				if (_target in _clusterTargets) then {
					// Delete this target from cluster
					_clusterTargets = _clusterTargets - [_target];
					if (count _clusterTargets == 0) then { // If there's no more targets in this cluster, delete this cluster
						_targetClusters deleteAt _i;
					} else {
						// Recalculate the border of this cluster
						pr _allx = _clusterTargets apply {_x select TARGET_ID_POS select 0};
						pr _ally = _clusterTargets apply {_x select TARGET_ID_POS select 1};
						_targetCluster set [CLUSTER_ID_X1, selectMin _allx];
						_targetCluster set [CLUSTER_ID_Y1, selectMin _ally];
						_targetCluster set [CLUSTER_ID_Y2, selectMax _allx];
						_targetCluster set [CLUSTER_ID_Y2, selectMax _ally];
						_i = _i + 1;
					};
				};
			};
		} forEach _deletedTargets;
		
		// Correct existing clusters by applying new targets
		pr _i = 0; // Iterate through all new targets
		{		
			pr _target = _x;
			(_target select TARGET_ID_POS) params ["_posX", "_posY"];
			
			// Create a new cluster for this new target
			pr _newCluster = CLUSTER_NEW(_posX, _posY, _posX, _posY, [_target]);
			pr _newClusterMerged = false;
			{ // forEach _targetClusters
				pr _id = _x select TARGET_CLUSTER_ID_ID;
				pr _cluster = _x select TARGET_CLUSTER_ID_CLUSTER;
	
				// Check if this new target can be applied to existing clusters
				if (([_cluster, _newCluster] call cluster_fnc_distance) < TARGETS_CLUSTER_DISTANCE_MIN) exitWith {
					[_cluster, _newCluster] call cluster_fnc_merge;
					_newClusterMerged = true;
				};
			} forEach _targetClusters;
			
			// If the new target was not merged into existing cluster, create a new one
			if (!_newClusterMerged) then {
				CALLM1(_AI, "createNewTargetCluster", _newCluster); // This pushes into the _targetClusters array BTW
			};
		} forEach _newTargets;
		*/