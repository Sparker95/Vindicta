#include "common.hpp"

/*
Sensor for a commander to receive spotted enemies from its garrisons and relay them to other garrisons.
Author: Sparker 21.12.2018
*/

#define pr private

// Update interval of this sensor
#define UPDATE_INTERVAL 6

// Maximum age of target before it is deleted
#define TARGET_MAX_AGE 120

// ---- Debugging defines ----

// Will print to the RPT targets received from groups
//#define PRINT_RECEIVED_TARGETS

CLASS("SensorCommanderTargets", "SensorStimulatable")

	VARIABLE("newTargets"); // Targets which were recognized as new will be added to this array on receiving new targets stimulus
	VARIABLE("deletedTargets"); // Targets recognized as deleted will be added to this array on receiving forget targets stimulus

	METHOD("new") {
		params [["_thisObject", "", [""]]];
		
		T_SETV("newTargets", []);
		T_SETV("deletedTargets", []);
		
	} ENDMETHOD;


	// ----------------------------------------------------------------------
	// |                              U P D A T E
	// | Updates the state of this sensor
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD("update") {
		params [["_thisObject", "", [""]]];
		
		pr _AI = T_GETV("AI");
		pr _deletedTargets = T_GETV("deletedTargets");
		pr _newTargets = T_GETV("newTargets");
		pr _knownTargets = GETV(_AI, "targets");
		
		if (count _knownTargets == 0) exitWith {};
		
		OOP_INFO_0("UPDATE");
		
		pr _targetClusters = GETV(_AI, "targetClusters");
		
		// Delete old targets
		pr _AI = GETV(_thisObject, "AI");
		if (count _knownTargets > 0) then {
			pr _t = time;
			_deletedTargets append ( _knownTargets select {(_t - (_x select TARGET_ID_TIME)) > TARGET_MAX_AGE} );
			{
				_knownTargets deleteAt (_knownTargets find _x);
			} forEach _deletedTargets; 
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
			
			for "_oldClusterID" from 0 to (count _targetClusters - 1) do {
				pr _oldObjects = (_targetClusters select _oldClusterID select TARGET_CLUSTER_ID_CLUSTER select CLUSTER_ID_OBJECTS) apply {TARGET_ID_OBJECT_HANDLE};
				pr _newObjects = (_newClusters select _newClusterID select CLUSTER_ID_OBJECTS) apply {TARGET_ID_OBJECT_HANDLE};
				pr _a = count ( _oldObjects arrayIntersect _newObjects ); // Count ammount of the same elements
				_row set [_oldClusterID, _a];
			};
			_affinity set [_newClusterID, _row];
			OOP_INFO_1("  %1", _row);
		};
		OOP_INFO_0("- - - - - - - -");
		
		// Update old clusters
		CALLM0(_AI, "deleteAllTargetClusters");
		{
			CALLM1(_AI, "createNewTargetCluster", _x);
		} forEach _newClusters;
		
		// Reset the new targets and deleted targets array
		T_SETV("newTargets", []);
		T_SETV("deletedTargets", []);
		
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    U P D A T E   I N T E R V A L
	// | Must return the desired update rate of this sensor
	// ----------------------------------------------------------------------
	
	METHOD("getUpdateInterval") {
		UPDATE_INTERVAL
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                   G E T  S T I M U L U S   T Y P E S
	// | Returns the array with stimulus types this sensor can be stimulated by
	// ----------------------------------------------------------------------
	
	/* virtual */ METHOD("getStimulusTypes") {
		[STIMULUS_TYPE_TARGETS]
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                           H A N D L E   S T I M U L U S
	// | Performs sensor-specific actions if doComplexCheck has returned true
	// ----------------------------------------------------------------------
	
	/*virtual*/ METHOD("handleStimulus") {
		params [["_thisObject", "", [""]], ["_stimulus", [], [[]]]];
		
		OOP_INFO_1("Received targets: %1", STIMULUS_GET_VALUE(_stimulus));
		
		// Filter spotted enemies
		pr _AI = GETV(_thisObject, "AI");
		pr _knownTargets = GETV(_AI, "targets");
		//pr _newTargets = T_GETV("newTargets");
		{ // forEach (STIMULUS_GET_VALUE(_stimulus));
			// Check if the target is already known
			pr _hO = _x select TARGET_ID_OBJECT_HANDLE;
			pr _index = _knownTargets findIf {(_x select TARGET_ID_OBJECT_HANDLE) isEqualTo _hO};
			if (_index == -1) then {
				// Didn't find an existing entry
				
				OOP_INFO_1("Added new target: %1", _x);
				
				// Add it to the array
				_knownTargets pushBack _x;
			} else {
			
				OOP_INFO_1("Updated existing target: %1", _x);
				
				// Found an existing entry
				pr _targetExisting = _knownTargets select _index;
				
				// Check time the target was previously spotted
				pr _timeNew = _x select TARGET_ID_TIME;
				pr _timePrev = _targetExisting select TARGET_ID_TIME;
				// Is the new report newer than the old record?
				if (_timeNew > _timePrev) then {
					_targetExisting set [TARGET_ID_POS, _x select TARGET_ID_POS];
					_targetExisting set [TARGET_ID_TIME, _timeNew];
					_targetExisting set [TARGET_ID_KNOWS_ABOUT, TARGET_ID_KNOWS_ABOUT];
				};
			};
		} forEach (STIMULUS_GET_VALUE(_stimulus));
		
	} ENDMETHOD;
	
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