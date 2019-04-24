#include "common.hpp"

/*
Class: AI.AICommander
AI class for the commander.

Author: Sparker 12.11.2018
*/

#define PLAN_INTERVAL 5
#define pr private

CLASS("AICommander", "AI")

	VARIABLE("side");
	VARIABLE("msgLoop");
	VARIABLE("locationDataWest");
	VARIABLE("locationDataEast");
	VARIABLE("locationDataInd");
	VARIABLE("locationDataThis"); // Points to one of the above arrays depending on its side
	VARIABLE("notificationID");
	VARIABLE("notifications"); // Array with [task name, task creation time]

	// Friendly garrisons we can access
	VARIABLE("garrisons");

	VARIABLE("targets"); // Array of targets known by this Commander
	VARIABLE("targetClusters"); // Array with target clusters
	VARIABLE("nextClusterID"); // A unique cluster ID generator
	
	VARIABLE("targetClusterActions"); // Array with ActionCommanderRespondToTargetCluster

	VARIABLE("lastPlanningTime");
	VARIABLE("cmdrAI");
	VARIABLE("worldModel");

	#ifdef DEBUG_CLUSTERS
	VARIABLE("nextMarkerID");
	VARIABLE("clusterMarkers");
	#endif

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_agent", "", [""]], ["_side", WEST, [WEST]], ["_msgLoop", "", [""]]];
		
		OOP_INFO_1("Initializing Commander for side %1", str(_side));
		
		ASSERT_OBJECT_CLASS(_msgLoop, "MessageLoop");
		T_SETV("side", _side);
		T_SETV("msgLoop", _msgLoop);
		T_SETV("locationDataWest", []);
		T_SETV("locationDataEast", []);
		T_SETV("locationDataInd", []);
		pr _thisLDArray = switch (_side) do {
			case WEST: {T_GETV("locationDataWest")};
			case EAST: {T_GETV("locationDataEast")};
			case INDEPENDENT: {T_GETV("locationDataInd")};
		};
		T_SETV("locationDataThis", _thisLDArray);
		T_SETV("notificationID", 0);
		T_SETV("notifications", []);
		
		T_SETV("garrisons", []);
		
		T_SETV("targets", []);
		T_SETV("targetClusters", []);
		T_SETV("nextClusterID", 0);
		
		#ifdef DEBUG_CLUSTERS
		T_SETV("nextMarkerID", 0);
		T_SETV("clusterMarkers", []);
		#endif
		
		// Array with ActionCommanderRespondToTargetCluster
		T_SETV("targetClusterActions", []);
		
		// Create sensors
		pr _sensorLocation = NEW("SensorCommanderLocation", [_thisObject]);
		CALLM1(_thisObject, "addSensor", _sensorLocation);
		pr _sensorTargets = NEW("SensorCommanderTargets", [_thisObject]);
		CALLM1(_thisObject, "addSensor", _sensorTargets);
		pr _sensorCasualties = NEW("SensorCommanderCasualties", [_thisObject]);
		CALLM(_thisObject, "addSensor", [_sensorCasualties]);
		
		T_SETV("lastPlanningTime", TIME_NOW);
		private _cmdrAI = NEW("CmdrAI", [_side]);
		T_SETV("cmdrAI", _cmdrAI);
		private _worldModel = NEW("WorldModel", []);
		T_SETV("worldModel", _worldModel);

		// Register locations
		private _locations = CALLSM("Location", "getAll", []);
		OOP_INFO_1("Registering %1 locations with Model", count _locations);
		{ NEW("LocationModel", [_worldModel]+[_x]) } forEach _locations;
	} ENDMETHOD;
	
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		OOP_INFO_0(" - - - - - P R O C E S S - - - - -");
		
		// Update sensors
		CALLM0(_thisObject, "updateSensors");
		
		// Check if there are any clusters without assigned actions
		pr _actions = T_GETV("targetClusterActions");
		{
			pr _ID = _x select TARGET_CLUSTER_ID_ID;
			pr _index = _actions findIf {CALLM0(_x, "getTargetClusterID") == _ID};
			
			// If we didn't find any actions assigned to this target cluster
			if (_index == -1) then {
				OOP_INFO_1("Target cluster with ID %1 has no actions assigned!", _ID);
				CALLM1(_thisObject, "onTargetClusterCreated", _x);
			};
		} forEach T_GETV("targetClusters");

		// Process cluster actions
		{
			CALLM0(_x, "process");
		} forEach T_GETV("targetClusterActions");

		// Delete old notifications
		pr _nots = T_GETV("notifications");
		pr _i = 0;
		while {_i < count (_nots)} do {
			(_nots select _i) params ["_task", "_time"];
			// If this notification ahs been here for too long
			if (TIME_NOW - _time > 120) then {
				[_task, T_GETV("side")] call BIS_fnc_deleteTask;
				// Delete this notification from the list				
				_nots deleteAt _i;
			} else {
				_i = _i + 1;
			};
		};


		T_PRVAR(cmdrAI);
		T_PRVAR(worldModel);
		// Sync before update
		CALLM(_worldModel, "sync", []);
		CALLM(_cmdrAI, "update", [_worldModel]);
		// Sync after update
		CALLM(_worldModel, "sync", []);
		
		T_PRVAR(lastPlanningTime);
		if(TIME_NOW - _lastPlanningTime > PLAN_INTERVAL) then {
			CALLM(_worldModel, "updateThreatMaps", []);
			T_SETV("lastPlanningTime", TIME_NOW);
			CALLM(_cmdrAI, "plan", [_worldModel]);

		};
	} ENDMETHOD;
	
	// ----------------------------------------------------------------------
	// |                    G E T   M E S S A G E   L O O P
	// ----------------------------------------------------------------------
	
	METHOD("getMessageLoop") {
		params [["_thisObject", "", [""]]];
		
		T_GETV("msgLoop");
	} ENDMETHOD;
	
	/*
	Method: (static)getCommanderAIOfSide
	Returns AICommander object that commands given side
	
	Parameters: _side
	
	_side - side
	
	Returns: <AICommander>
	*/
	STATIC_METHOD("getCommanderAIOfSide") {
		params [["_thisObject", "", [""]], ["_side", WEST, [WEST]]];
		switch (_side) do {
			case WEST: {
				if(isNil "gAICommanderWest") then { NULL_OBJECT } else { gAICommanderWest }
			};
			case EAST: {
				if(isNil "gAICommanderEast") then { NULL_OBJECT } else { gAICommanderEast }
			};
			case INDEPENDENT: {
				if(isNil "gAICommanderInd") then { NULL_OBJECT } else { gAICommanderInd }
			};
		};
	} ENDMETHOD;
	
	// Location data
	// If you pass any side except EAST, WEST, INDEPENDENT, then this AI object will update its own knowledge about provided locations
	METHOD("updateLocationData") {
		params [["_thisObject", "", [""]], ["_loc", "", [""]], ["_updateType", 0, [0]], ["_side", CIVILIAN]];
		
		pr _thisSide = T_GETV("side");
		
		pr _ld = switch (_side) do {
			case WEST: {T_GETV("locationDataWest")};
			case EAST: {T_GETV("locationDataEast")};
			case INDEPENDENT: {T_GETV("locationDataInd")};
			default { _side = _thisSide; T_GETV("locationDataThis")};
		};
		
		pr _args = [_loc, _updateType];
		pr _ldNew = CALL_STATIC_METHOD("AICommander", "createCLDFromLocation", _args);
	
		if (_ldNew isEqualTo []) then {
			OOP_ERROR_1("Can't update location data: %1", _loc);
		} else {
			// Check if this location already exists
			pr _locPos = _ldNew select CLD_ID_POS;
			pr _locSide = _ldNew select CLD_ID_SIDE;
			pr _entry = _ld findIf {(_x select CLD_ID_POS) isEqualTo _locPos};
			if (_entry == NOT_FOUND) then {
				// Add new entry
				_ld pushBack _ldNew;
				
				systemChat "Discovered new location";
				
				if (_side == _thisSide && _side != _locSide) then {
					CALLM2(_thisObject, "showLocationNotification", _locPos, "DISCOVERED");
				};

				// Register with the World Model
				T_PRVAR(worldModel);
				CALLM(_worldModel, "findOrAddLocationByActual", [_loc]);
			} else {
				pr _ldPrev = _ld select _entry;
				_ldPrev params ["_type", "_side", "_unitAmount", "_pos", "_time"];
				_ldNew params ["_typeNew", "_sideNew", "_unitAmountNew", "_posNew", "_timeNew"];
				
				// Update only specific fields
				
				// Update type
				if (_typeNew != LOCATION_TYPE_UNKNOWN) then {
					_ldPrev set [CLD_ID_TYPE, _typeNew];
				};
				
				// Update side
				if (_sideNew != CLD_SIDE_UNKNOWN) then {
					_ldPrev set [CLD_ID_SIDE, _sideNew];
				};
				
				// Update units
				if (count _unitAmountNew > 0) then {
					_ldPrev set [CLD_ID_UNIT_AMOUNT, _unitAmountNew];
				};
				
				// Update time
				_ldPrev set [CLD_ID_TIME, TIME_NOW];
				
				//systemChat "Location data was updated";
				
				// Show notification if we haven't updated this data for quite some time
				if (_side == _thisSide && _side != _locSide) then {
					if ((TIME_NOW - _time) > 600) then {
						CALLM2(_thisObject, "showLocationNotification", _locPos, "UPDATED");
					};
				};
			};
		};
		
		// Broadcast new data to clients, add it to JIP queue
		pr _JIPID = (_thisObject+"_JIP_"+(str _side)); // We use this object as JIP id because it's a string :D
		pr _args = [_ld, _side];
		REMOTE_EXEC_CALL_STATIC_METHOD("ClientMapUI", "updateLocationData", _args, _thisSide, _JIPID);
	} ENDMETHOD;
	
	
	
	
	// Shows notification and keeps track of it to delete some time later
	METHOD("showLocationNotification") {
		params ["_thisObject", ["_locPos", [], [[]]], ["_state", "", [""]]];
		
		//ade_dumpCallstack;
		
		pr _id = T_GETV("notificationID");
		pr _nots = T_GETV("notifications");
		switch (_state) do {
			case "DISCOVERED": {
				pr _descr = format ["Friendly units have discovered an enemy location at %1", mapGridPosition _locPos];
				_tsk = [T_GETV("side"), _thisObject+"task"+(str _id), [_descr, "Discovered location", ""], _locPos + [0], "CREATED", 0, false, "scout", true] call BIS_fnc_taskCreate;
				[_tsk, "SUCCEEDED", true] call BIS_fnc_taskSetState;
				_nots pushBack [_tsk, TIME_NOW];
			};
			
			case "UPDATED": {
				pr _descr = format ["Updated data on enemy garrisons at %1", mapGridPosition _locPos];
				_tsk = [T_GETV("side"), _thisObject+"task"+(str _id), [_descr, "Updated data on location", ""], _locPos + [0], "CREATED", 0, false, "intel", true] call BIS_fnc_taskCreate;
				[_tsk, "SUCCEEDED", true] call BIS_fnc_taskSetState;
				_nots pushBack [_tsk, TIME_NOW];
			};
		};
		T_SETV("notificationID", _id + 1);
	} ENDMETHOD;
	
	// Creates a LocationData array from Location
	STATIC_METHOD("createCLDFromLocation") {
		params ["_thisClass", ["_loc", "", [""]], ["_updateLevel", 0, [0]]];
		
		ASSERT_OBJECT_CLASS(_loc, "Location");
		
		pr _gar = CALLM0(_loc, "getGarrisons") select 0;
		if (isNil "_gar") then {
			_gar = "";
		};
		
		pr _value = CLD_NEW();
		
		// Set position
		pr _locPos = +(CALLM0(_loc, "getPos"));
		_locPos resize 2;
		_value set [CLD_ID_POS, _locPos];
		
		// Set time
		_value set [CLD_ID_TIME, TIME_NOW];
		
		// Set type
		if (_updateLevel >= CLD_UPDATE_LEVEL_TYPE) then {
			_value set [CLD_ID_TYPE, CALLM0(_loc, "getType")]; // todo add types for locations at some point?
		} else {
			_value set [CLD_ID_TYPE, LOCATION_TYPE_UNKNOWN]; // todo add types for locations at some point?
		};
		
		// Set side
		if (_updateLevel >= CLD_UPDATE_LEVEL_SIDE) then {
			if (_gar != "") then {
				_value set [CLD_ID_SIDE, CALLM0(_gar, "getSide")];
			} else {
				_value set [CLD_ID_SIDE, CLD_SIDE_UNKNOWN];
			};
		} else {
			_value set [CLD_ID_SIDE, CLD_SIDE_UNKNOWN];
		};
		
		// Set unit count
		if (_updateLevel >= CLD_UPDATE_LEVEL_UNITS) then {
			pr _CLD_full = CLD_UNIT_AMOUNT_FULL;
			if (_gar != "") then {
				{
					_x params ["_catID", "_catSize"];
					pr _query = [[_catID, 0]];
					for "_subcatID" from 0 to (_catSize - 1) do {
						(_query select 0) set [1, _subcatID];
						pr _amount = CALLM1(_gar, "countUnits", _query);
						(_CLD_full select _catID) set [_subcatID, _amount];
					};
				} forEach [[T_INF, T_INF_SIZE], [T_VEH, T_VEH_SIZE], [T_DRONE, T_DRONE_SIZE]];
			};
			_value set [CLD_ID_UNIT_AMOUNT, _CLD_full];
		};
		
		// Set ref to location object
		_value set [CLD_ID_LOCATION, _loc];
		
		_value
	} ENDMETHOD;
	
	// Returns known locations which are assumed to be controlled by this AICommander
	METHOD("getFriendlyLocations") {
		params ["_thisObject"];
		
		pr _thisSide = T_GETV("side");
		pr _friendlyLocs = T_GETV("locationDataThis") select {
			_x select CLD_ID_SIDE == _thisSide
		} apply {
			_x select CLD_ID_LOCATION
		};
		
		_friendlyLocs		
	} ENDMETHOD;
	
	// Generates a new target cluster ID
	METHOD("getNewTargetClusterID") {
		params ["_thisObject"];
		pr _nextID = T_GETV("nextClusterID");
		T_SETV("nextClusterID", _nextID + 1);
		_nextID
	} ENDMETHOD;
	
	// Generates a new unique cluster ID
	/*
	METHOD("createNewTargetCluster") {
		params ["_thisObject", "_cluster", "_efficiency"];
		pr _targetClusters = T_GETV("targetClusters");
		pr _nextID = T_GETV("nextClusterID");
		T_SETV("nextClusterID", _nextID + 1);
		_targetClusters pushBack TARGET_CLUSTER_NEW(_nextID, _cluster, _efficiency);
		
		// Create debug markers
		#ifdef DEBUG_CLUSTERS
		
		pr _clusterMarkers = T_GETV("clusterMarkers");
		pr _side = T_GETV("side");
		
		
		pr _colorEnemy = switch (_side) do {
			case WEST: {"ColorWEST"};
			case EAST: {"ColorEAST"};
			case INDEPENDENT: {"ColorGUER"};
			default {"ColorCIV"};
		};
				
		// Create marker for the cluster
		pr _c = _cluster;
		pr _nextMarkerID = T_GETV("nextMarkerID");
		pr _name = format ["%1_mrk_%2", _thisObject, _nextMarkerID]; _nextMarkerID = _nextMarkerID + 1;
		pr _cCenter = _cluster call cluster_fnc_getCenter;
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
			
		} forEach (_cluster select CLUSTER_ID_OBJECTS);
		
		// Add marker with efficiency text
		pr _name = format ["%1_mrk_%2", _thisObject, _nextMarkerID]; _nextMarkerID = _nextMarkerID + 1;
		pr _mrk = createmarker [_name, _cCenter];
		_mrk setMarkerType "mil_dot";
		_mrk setMarkerColor "ColorPink";
		_mrk setMarkerAlpha 1.0;
		_mrk setMarkerText (str _efficiency);
		_clusterMarkers pushBack _mrk;
		
		T_SETV("nextMarkerID", _nextMarkerID);
		
		
		#endif
	} ENDMETHOD;
	*/
	
	/*
	// Deletes all target clusters
	METHOD("deleteAllTargetClusters") {
		params ["_thisObject"];
		pr _targetClusters = T_GETV("targetClusters");
		while {count _targetClusters > 0} do {
			_targetClusters deleteAt 0;
		};
		
		#ifdef DEBUG_CLUSTERS
		
		pr _clusterMarkers = T_GETV("clusterMarkers");
		{
			deleteMarker _x;
		} forEach _clusterMarkers;
		T_SETV("clusterMarkers", []);
		
		#endif
	} ENDMETHOD;
	*/
	
	/*
	Method: onTargetClusterCreated
	Gets called on creation of a totally new target cluster
	
	Parameters: _tc
	
	_tc - the new target cluster
	
	Returns: nil
	*/
	METHOD("onTargetClusterCreated") {
		params ["_thisObject", "_tc"];
		pr _ID = _tc select TARGET_CLUSTER_ID_ID;
		
		OOP_INFO_1("TARGET CLUSTER CREATED, ID: %1", _ID);
		
		// Create a new action to respond to this target cluster
		pr _args = [_thisObject, _ID];
		pr _newAction = NEW("ActionCommanderRespondToTargetCluster", _args);
		T_GETV("targetClusterActions") pushBack _newAction;
		
		OOP_INFO_1("---- Created new action to respond to target cluster %1", _tc);

		T_PRVAR(worldModel);
		NEW("ClusterModel", [_worldModel]+[[_thisObject]+[_ID]]);
	} ENDMETHOD;

	/*
	Method: onTargetClusterSplitted
	Gets called when an already known cluster gets splitted into multiple new clusters.
	
	Parameters: _tcsNew
	
	_tcsNew - array of [_affinity, _newTargetCluster]
	
	Returns: nil
	*/
	METHOD("onTargetClusterSplitted") {
		params ["_thisObject", "_tcOld", "_tcsNew"];
		
		pr _IDOld = _tcOld select TARGET_CLUSTER_ID_ID;
		pr _a = _tcsNew apply {[_x select 0, _x select 1 select TARGET_CLUSTER_ID_ID]};
		OOP_INFO_2("TARGET CLUSTER SPLITTED, old ID: %1, new affinity and IDs: %2", _IDOld, _a);

		// Sort new clusters by affinity
		_tcsNew sort DESCENDING;

		// Relocate all actions assigned to the old cluster to the new cluster with maximum affinity
		pr _newClusterID = _tcsNew select 0 select 1 select TARGET_CLUSTER_ID_ID;

		// Notify the actions assigned to this cluster
		OOP_INFO_1("Redirecting actions to new cluster, ID: %1", _newClusterID);
		{
			if (CALLM0(_x, "getTargetClusterID") == _IDOld) then {
				CALLM1(_x, "setTargetClusterID", _newClusterID);
			};
		} forEach T_GETV("targetClusterActions");

		T_PRVAR(worldModel);
		// Retarget in the model
		CALLM(_worldModel, "retargetClusterByActual", [[_thisObject]+[_IDOld]]+[[_thisObject]+[_newClusterID]]);
	} ENDMETHOD;	

	/*
	Method: onTargetClusterMerged
	Gets called when old clusters get merged into a new one
	
	Parameters: _tc
	
	_tc - the new target cluster
	
	Returns: nil
	*/
	METHOD("onTargetClustersMerged") {
		params ["_thisObject", "_tcsOld", "_tcNew"];

		pr _IDnew = _tcNew select TARGET_CLUSTER_ID_ID;
		pr _IDsOld = []; { _IDsOld pushBack (_x select TARGET_CLUSTER_ID_ID)} forEach _tcsOld;
		OOP_INFO_2("TARGET CLUSTER MERGED, old IDs: %1, new ID: %2", _IDsOld, _IDnew);

		T_PRVAR(worldModel);

		// Assign all actions from old IDs to new IDs
		pr _actions = T_GETV("targetClusterActions");
		{
			pr _IDOld = _x;
			// Retarget in the model
			CALLM(_worldModel, "retargetClusterByActual", [[_thisObject]+[_IDOld]]+[[_thisObject]+[_IDnew]]);
			{
				pr _action = _x;
				if (CALLM0(_action, "getTargetClusterID") == _IDOld) then {
					CALLM1(_action, "setTargetClusterID", _IDnew);
				};
			} forEach T_GETV("targetClusterActions");
		} forEach _IDsOld;

	} ENDMETHOD;
	
	/*
	Method: onTargetClusterDeleted
	Gets called on deletion of a cluster because these enemies are not spotted any more
	
	Parameters: _tc
	
	_tc - the new target cluster
	
	Returns: nil
	*/
	METHOD("onTargetClusterDeleted") {
		params ["_thisObject", "_tc"];
		
		pr _ID = _tc select TARGET_CLUSTER_ID_ID;
		OOP_INFO_1("TARGET CLUSTER DELETED, ID: %1", _ID);
		OOP_INFO_0("Stopping garrisons assigned to this target cluster");
		pr _targetClusterActions = T_GETV("targetClusterActions");
		pr _i = 0;
		while { _i < (count _targetClusterActions)} do{
			pr _action = _targetClusterActions select _i;
			if (CALLM0(_action, "getTargetClusterID") == _ID) then {
				// Terminate and delete the old action
				OOP_INFO_1("Terminating and deleting action: %1", _action);
				CALLM0(_action, "terminate");
				DELETE(_action);
				_targetClusterActions deleteAt _i;
			} else {
				_i = _i + 1;
			};
		};
		
	} ENDMETHOD;
	
	
	/*
	Method: getTargetCluster
	Returns a target cluster with specified ID
	
	Parameters: _ID
	
	_ID - ID of the target cluster
	
	Returns: target cluster structure or [] if nothing was found
	*/
	METHOD("getTargetCluster") {
		params ["_thisObject", ["_ID", 0, [0]]];
		
		pr _targetClusters = T_GETV("targetClusters");
		pr _ret = [];
		{ // foreach _targetClusters
			if (_x select TARGET_CLUSTER_ID_ID == _ID) exitWith {
				_ret = _x;
			};
		} forEach _targetClusters;
		
		_ret
	} ENDMETHOD;
	
	/*
	Method: allocateUnitsGroundQRF
	Tries to find a location to send units from
	
	Parameters: _pos, _requiredEff
	
	_pos - position where to send QRF to
	_requiredEff - efficiency vector
	
	Returns: [_location, _garrison, _units, _groupsAndGroups]
	*/
	METHOD("allocateUnitsGroundQRF") {
		params ["_thisObject", ["_pos", [], [[]]], ["_requiredEff", [], [[]]]];
		
		pr _side = T_GETV("side");
		OOP_INFO_3("Allocating units for side: %1, pos: %2, required eff: %3", _side, _pos, _requiredEff);
		private _allLocations = CALLSM0("Location", "getAll");
		
		// Find locations controled by this side
		private _friendlyLocations = CALLM0(_thisObject, "getFriendlyLocations");
		
		// Select garrisons that are attached to locations
		pr _friendlyDistGar = (T_GETV("garrisons") select { // Select only garrisons attached to locations for now
			CALLM0(_x, "getLocation") != ""
		}) apply {[CALLM0(_x, "getPos") distance2D _pos, _x]};
		_friendlyDistGar sort true; // Ascending
		
		OOP_INFO_1("Friendly garrisons: %1", _friendlyDistGar);
		
		// ignore the nearest place
		//_friendlyDistLoc deleteAt 0;
		
		// Find location that can deal with the threat
		pr _allocatedUnits = []; // Array with units we have allocated
		pr _allocatedGroupsAndUnits = []; // Array with groups we have allocated
		pr _garrison = "";
		pr _location = "";
		
		pr _allocatedVehicles = [];
		pr _allocatedCrew = [];
		pr _effAllocated = +T_EFF_null; // Efficiency of units allocated so far
		pr _allocated = false;
		scopeName "s0";
		{ // forEach _friendlyDistGar;
			scopeName "scopeLocLoop";
			_x params ["_dist", "_gar"];
			
			OOP_INFO_3("Analyzing garrison: %1, pos: %2, distance: %3", _gar, CALLM0(_gar, "getPos"), _dist);
			
			pr _garEff = CALLM0(_gar, "getEfficiencyMobile");
			
			// Return values
			_garrison = _gar;
			_location = CALLM0(_gar, "getLocation");
			
			
			// If units at this garrison can destroy the threat
			if (([_garEff, _requiredEff] call t_fnc_canDestroy) == T_EFF_CAN_DESTROY_ALL) then {
				OOP_INFO_0("  This location can destroy the threat");
				scopeName "s1";
				
				pr _units = CALLM0(_gar, "getUnits") select {! CALLM0(_x, "isStatic")};
				_units = _units apply {pr _eff = CALLM0(_x, "getEfficiency"); [0, _eff, _x]};
				_allocatedUnits = [];
				_allocatedGroupsAndUnits = [];
				_allocatedCrew = [];
				_allocatedVehicles = [];
				_effAllocated = +T_EFF_null;
				
				// Allocate units per each efficiency category
				pr _j = 0;
				for "_i" from T_EFF_ANTI_SOFT to T_EFF_ANTI_AIR do {
					// Exit now if we have allocated enough units to deal with the threat
					if (([_effAllocated, _requiredEff] call t_fnc_canDestroy) == T_EFF_CAN_DESTROY_ALL) then {
						breakTo "s1";
					};
					
					// For every unit, set element 0 to efficiency value with index _i
					{_x set [0, _x select 1 select _i];} forEach _units;
					// Sort units in this efficiency category
					_units sort false; // Descending
					
					// Add units until there are enough of them
					pr _requiredEffCat = _requiredEff select _j; // Required efficiency in this category
					pr _pickUnitID = 0;
					while {(_effAllocated select _i < _requiredEffCat) && (_pickUnitID < count _units)} do {
						pr _unit = _units select _pickUnitID select 2;
						pr _group = CALLM0(_unit, "getGroup");
						pr _groupType = if (_group != "") then {CALLM0(_group, "getType")} else {GROUP_TYPE_IDLE};
						// Try not to take troops from vehicle groups
						pr _ignore = (CALLM0(_unit, "isInfantry") && _groupType in [GROUP_TYPE_VEH_NON_STATIC, GROUP_TYPE_VEH_STATIC]);
						
						if (!_ignore) then {							
							// If it was a vehicle, and it had crew in its group, add the crew as well
							if (CALLM0(_unit, "isVehicle")) then {
								pr _groupUnits = if (_group != "") then {CALLM0(_group, "getUnits");} else {[]};
								// If there are more than one unit in a vehicle's group, then add the whole group
								if (count _groupUnits > 1) then {
									_allocatedGroupsAndUnits pushBackUnique [_group, +CALLM0(_group, "getUnits")];
									// Add allocated crew to array
									{
										if (CALLM0(_x, "isInfantry")) then {
											_allocatedCrew pushBack _x;
										};
									} forEach (CALLM0(_group, "getUnits"));
								} else {
									_allocatedUnits pushBackUnique _unit;
								};
								_allocatedVehicles pushBack _unit;
								OOP_INFO_2("    Added vehicle unit: %1, %2", _unit, CALLM0(_unit, "getClassName"));
							} else {
								OOP_INFO_2("    Added infantry unit: %1, %2", _unit, CALLM0(_unit, "getClassName"));
								_allocatedUnits pushBack _unit;
							};
							pr _unitEff = _units select _pickUnitID select 1;
							// Add to the allocated efficiency vector
							_effAllocated = EFF_ADD(_effAllocated, _unitEff);
							//OOP_INFO_1("     New efficiency value: %1", _effAllocated);
						};
						_pickUnitID = _pickUnitID + 1;
					};
					
					_j = _j + 1;
				};
				
				OOP_INFO_3("   Found units: %1, groups: %2, efficiency: %3", _allocatedUnits, _allocatedGroupsAndUnits, _effAllocated);
				
				// Check if we have allocated enough units
				if ([_effAllocated, _requiredEff] call t_fnc_canDestroy == T_EFF_CAN_DESTROY_ALL) then {
				
					OOP_INFO_0("   Allocated units can destroy the threat");
					
					pr _nCrewRequired = CALLSM1("Unit", "getRequiredCrew", _allocatedVehicles);
					_nCrewRequired params ["_nDrivers", "_nTurrets"];
					pr _nInfAllocated = {CALLM0(_x, "isInfantry")} count _allocatedUnits;
					
					// Do we need to find crew for vehicles?
					if ((_nDrivers + _nTurrets) > (_nInfAllocated + count _allocatedCrew)) then {
						pr _nMoreCrewRequired = _nDrivers + _nTurrets - _nInfAllocated - (count _allocatedCrew);
						OOP_INFO_1("Allocating additional crew: %1 units", _nMoreCrewRequired);
						pr _freeInfUnits = CALLM0(_gar, "getInfantryUnits") select {
							if (_x in _allocatedUnits) then { false } else {
								pr _group = CALLM0(_x, "getGroup");
								if (_group == "") then { false } else {
									if (CALLM0(_group, "getType") in [GROUP_TYPE_IDLE, GROUP_TYPE_PATROL, GROUP_TYPE_BUILDING_SENTRY]) then {
										true
									} else {false};
								};
							};
						};
						
						// Are there enough units left?
						if (count _freeInfUnits < _nMoreCrewRequired) then {
							// Not enough infantry here to equip all the vehicles we have allocated
							// Go check other locations
							OOP_INFO_0("   Failed to allocate additional crew");
							breakTo "scopeLocLoop";
						} else {
							pr _crewToAdd = _freeInfUnits select [0, _nMoreCrewRequired];
							
							OOP_INFO_1("   Successfully allocated additional crew: %1", _crewToAdd);
							// Add the allocated units to the array
							_allocatedUnits append _crewToAdd;
						};
					};
					
					// Do we need to find transport vehicles?
					if (_dist > QRF_NO_TRANSPORT_DISTANCE_MAX) then {
						pr _nCargoSeatsRequired = _nInfAllocated; // - _nDrivers - _nTurrets;
						pr _nCargoSeatsAvailable = CALLSM1("Unit", "getCargoInfantryCapacity", _allocatedVehicles);
						//ade_dumpcallstack;
						OOP_INFO_2("   Finding additional transport vehicles for %1 troops. Currently available cargo seats: %2", _nCargoSeatsRequired, _nCargoSeatsAvailable);
						
						// If we need more vehicles for transport
						if (_nCargoSeatsAvailable < _nCargoSeatsRequired) then {
						
							OOP_INFO_0("   Currently NOT enough cargo seats");
							
							pr _nMoreCargoSeatsRequired = _nCargoSeatsRequired - _nCargoSeatsAvailable;
							// Get all remaining vehicles in this garrison, sort them by their cargo infantry capacity
							pr _availableVehicles = CALLM0(_gar, "getUnits") select {
								CALLM0(_x, "getMainData") params ["_catID", "_subcatID"];
								if (_x in _allocatedVehicles || _catID != T_VEH) then { // Don't consider vehicles we have already taken and non-vehicles
									false
								} else {
									if (_subcatID in T_VEH_ground_infantry_cargo) then {
										true
									} else {
										false
									};
								};						
							}; // select
							pr _availableVehiclesCapacity = _availableVehicles apply {[CALLSM1("Unit", "getCargoInfantryCapacity", [_x]), _x]};
							_availableVehiclesCapacity sort false; // Descending
							
							OOP_INFO_1("   Available additional vehicles with cargo capacity: %1", _availableVehiclesCapacity);
							
							// Add more vehicles while we can
							pr _i = 0;
							while {(_nMoreCargoSeatsRequired > 0) && (_i < count _availableVehiclesCapacity)} do {
								OOP_INFO_2("   Added vehicle: %1, with cargo capacity: %2", _availableVehiclesCapacity select _i select 1, _availableVehiclesCapacity select _i select 0);
								_allocatedUnits pushBack (_availableVehiclesCapacity select _i select 1);
								_nMoreCargoSeatsRequired = _nMoreCargoSeatsRequired - (_availableVehiclesCapacity select _i select 0);
								_i = _i + 1;
							};
							
							// IF we have finally found enough vehicles
							if (_nMoreCargoSeatsRequired <= 0) then {
								
								OOP_INFO_0("   Successfully allocated additional vehicles!");
								
								// Success
								_allocated = true;					
								breakTo "s0";
							} else {
								// Not enough vehicles for everyone!
								// Check other locations then
								OOP_INFO_0("   Failed to allocate additional vehicles!");
								breakTo "scopeLocLoop";
							}; // if (_nMoreCargoSeatsRequired <= 0)
						} else { // if (_nCargoSeatsAvailable < _nCargoSeatsRequired)
							// We don't need more vehicles, it's fine
							OOP_INFO_0("   Currently enough cargo seats");
							_allocated = true;					
							breakTo "s0";			
						}; // if (_nCargoSeatsAvailable < _nCargoSeatsRequired)
						
					} else {
						// No need to find transport vehicles
						// We are done here!
						OOP_INFO_0("   No need to find more transport vehicles");
						_allocated = true;					
						breakTo "s0";					
					}; // (_dist > QRF_NO_TRANSPORT_DISTANCE_MAX) then {

				} else { // if ([_effAllocated, _requiredEff] call t_fnc_canDestroy == T_EFF_CAN_DESTROY_ALL) then {
					// Not enough units to deal with the threat
					OOP_INFO_0("   Allocated units can NOT destroy the threat");
					breakTo "scopeLocLoop";
				};
			} else {
				OOP_INFO_0("  This location can NOT destroy the threat");
			};
		} forEach _friendlyDistGar;
		
		if (_allocated) then {
			// Success!
			OOP_INFO_0("Successfully allocated required units:");
			{
				OOP_INFO_2("   %1, %2", _x, CALLM0(_x, "getClassName"));
			} forEach _allocatedUnits;
			OOP_INFO_0("Allocated groups:");
			{
				OOP_INFO_1("  Group %1", _x);
				{
					OOP_INFO_2("     %1, %2", _x, CALLM0(_x, "getClassName"));
				} forEach CALLM0(_x select 0, "getUnits");
			} forEach _allocatedGroupsAndUnits;
			
			// Return
			[_location, _garrison, _allocatedUnits, _allocatedGroupsAndUnits]
		} else {
			OOP_INFO_0("Couldn't allocate units!");
			// Return
			[]
		};
		
	} ENDMETHOD;
	
	/*
	Method: registerGarrison
	Registers a garrison to be processed by this AICommander
	
	Parameters:
	_gar - <Garrison>
	
	Returns: nil
	*/
	STATIC_METHOD("registerGarrison") {
		params [P_THISCLASS, P_STRING("_gar")];
		ASSERT_OBJECT_CLASS(_gar, "Garrison");
		private _side = GETV(_gar, "side");
		private _thisObject = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [_side]);

		private _newModel = NULL_OBJECT;
		if(!IS_NULL_OBJECT(_thisObject)) then {
			OOP_DEBUG_MSG("Registering garrison %1", [_gar]);
			T_GETV("garrisons") pushBack _gar; // I need you for my army!
			CALLM2(_gar, "postMethodAsync", "ref", []);
			T_PRVAR(worldModel);
			_newModel = NEW("GarrisonModel", [_worldModel]+[_gar]);
		};
		_newModel
	} ENDMETHOD;
	
	/*
	Method: unregisterGarrison
	Unregisters a garrison from this AICommander
	
	Parameters:
	_gar - <Garrison>
	
	Returns: nil
	*/
	STATIC_METHOD("unregisterGarrison") {
		params [P_THISCLASS, P_STRING("_gar")];
		ASSERT_OBJECT_CLASS(_gar, "Garrison");
		private _side = GETV(_gar, "side");
		private _thisObject = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [_side]);
		if(!IS_NULL_OBJECT(_thisObject)) then {
			T_PRVAR(garrisons);
			// Check the garrison is registered
			private _idx = _garrisons find _gar;
			if(_idx != NOT_FOUND) then {
				OOP_DEBUG_MSG("Unregistering garrison %1", [_gar]);
				// Remove from model first
				T_PRVAR(worldModel);
				private _garrisonModel = CALLM(_worldModel, "findGarrisonByActual", [_gar]);
				CALLM(_worldModel, "removeGarrison", [_garrisonModel]);
				_garrisons deleteAt _idx; // Get out of my sight you useless garrison!
				CALLM2(_gar, "postMethodAsync", "unref", []);
			};
		};
		nil
	} ENDMETHOD;
		
ENDCLASS;