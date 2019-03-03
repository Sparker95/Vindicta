#include "common.hpp"
#include "LocationData.hpp"

/*
Class: AI.AICommander
AI class for the commander.

Author: Sparker 12.11.2018
*/

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

	VARIABLE("targets"); // Array of targets known by this Commander
	VARIABLE("targetClusters"); // Array with target clusters
	VARIABLE("nextClusterID"); // A unique cluster ID generator
	
	#ifdef DEBUG_CLUSTERS
	VARIABLE("nextMarkerID");
	VARIABLE("clusterMarkers");
	#endif

	METHOD("new") {
		params [["_thisObject", "", [""]], ["_agent", "", [""]], ["_side", WEST, [WEST]], ["_msgLoop", "", [""]]];
		
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
		T_SETV("targets", []);
		T_SETV("targetClusters", []);
		T_SETV("nextClusterID", 0);
		
		#ifdef DEBUG_CLUSTERS
		T_SETV("nextMarkerID", 0);
		T_SETV("clusterMarkers", []);
		#endif
		
		// Create sensors
		pr _sensorLocation = NEW("SensorCommanderLocation", [_thisObject]);
		CALLM1(_thisObject, "addSensor", _sensorLocation);
		pr _sensorTargets = NEW("SensorCommanderTargets", [_thisObject]);
		CALLM1(_thisObject, "addSensor", _sensorTargets);
		pr _sensorCasualties = NEW("SensorCommanderCasualties", [_thisObject]);
		CALLM(_thisObject, "addSensor", [_sensorCasualties]);
		
		
	} ENDMETHOD;
	
	METHOD("process") {
		params [["_thisObject", "", [""]]];
		
		// Update sensors
		CALLM0(_thisObject, "updateSensors");
		
		// Delete old notifications
		pr _nots = T_GETV("notifications");
		pr _i = 0;
		while {_i < count (_nots)} do {
			(_nots select _i) params ["_task", "_time"];
			// If this notification ahs been here for too long
			if (time - _time > 120) then {
				[_task, T_GETV("side")] call BIS_fnc_deleteTask;
				// Delete this notification from the list				
				_nots deleteAt _i;
			} else {
				_i = _i + 1;
			};
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
				gAICommanderWest
			};
			
			case EAST: {
				gAICommanderEast
			};
			
			case INDEPENDENT: {
				gAICommanderInd
			};
		};
	} ENDMETHOD;
	
	// Location data
	// Any side except EAST, WEST, INDEPENDENT means AI object will update its own knowledge about locations
	METHOD("updateLocationData") {
		params [["_thisObject", "", [""]], ["_locs", "", ["", []]], ["_side", CIVILIAN]];
		
		pr _thisSide = T_GETV("side");
		
		pr _ld = switch (_side) do {
			case WEST: {T_GETV("locationDataWest")};
			case EAST: {T_GETV("locationDataEast")};
			case INDEPENDENT: {T_GETV("locationDataInd")};
			default { _side = _thisSide; T_GETV("locationDataThis")};
		};
		
		// It accepts array of locations or one location
		// So convert parameter types here
		if (_locs isEqualType "") then {_locs = [_locs]};
		
		{ // foreach _locs
			pr _loc = _x;
			
			pr _CLD = CALL_STATIC_METHOD("AICommander", "createCLDFromLocation", [_loc]);
		
			if (_CLD isEqualTo []) then {
				OOP_ERROR_1("Can't update location data: %1", _loc);
			} else {		
				// Check this location already exists
				pr _locPos = _CLD select CLD_ID_POS;
				pr _locSide = _CLD select CLD_ID_SIDE;
				pr _entry = _ld findIf {(_x select CLD_ID_POS) isEqualTo _locPos};
				if (_entry == -1) then {
					// Add new entry
					_ld pushBack _CLD;
					
					systemChat "Discovered new location";
					
					if (_side == _thisSide && _side != _locSide) then {
						CALLM2(_thisObject, "showLocationNotification", _locPos, "DISCOVERED");
					};
					
				} else {
					pr _prevUpdateTime = (_ld select _entry select CLD_ID_TIME);
					_ld set [_entry, _CLD];
					
					systemChat "Location data was updated";
					
					// Show notification if we haven't updated this data for quite some time
					if (_side == _thisSide && _side != _locSide) then {
						if ((time - _prevUpdateTime) > 600) then {
							CALLM2(_thisObject, "showLocationNotification", _locPos, "UPDATED");
						};
					};
				};			
			};
				
		} forEach _locs;
		
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
				_nots pushBack [_tsk, time];
			};
			
			case "UPDATED": {
				pr _descr = format ["Updated data on enemy garrisons at %1", mapGridPosition _locPos];
				_tsk = [T_GETV("side"), _thisObject+"task"+(str _id), [_descr, "Updated data on location", ""], _locPos + [0], "CREATED", 0, false, "intel", true] call BIS_fnc_taskCreate;
				[_tsk, "SUCCEEDED", true] call BIS_fnc_taskSetState;
				_nots pushBack [_tsk, time];
			};
		};
		T_SETV("notificationID", _id + 1);
	} ENDMETHOD;
	
	// Updates knowledge about friendly locations
	METHOD("updateFriendlyLocationsData") {
		params [["_thisObject", "", [""]]];
		
		pr _thisSide = T_GETV("side");
		
		// Now find all locations that are of this side
		pr _friendlyLocs = [];
		pr _allLocs = CALL_STATIC_METHOD("Location", "getAll", []);
		{
			pr _loc = _x;
			pr _gar = CALLM0(_loc, "getGarrisonMilitaryMain");
			pr _garSide = CALLM0(_gar, "getSide");
			if (_garSide == _thisSide) then {
				_friendlyLocs pushBack _loc;
			};
		} forEach _allLocs;
		
		OOP_INFO_1("Adding locations to database: %1", _friendlyLocs);
		
		// Update data on these locations
		if (count _friendlyLocs > 0) then {
			CALLM1(_thisObject, "updateLocationData", _friendlyLocs);
		};
	} ENDMETHOD;
	
	// Creates a LocationData array from Location
	STATIC_METHOD("createCLDFromLocation") {
		params ["_thisClass", ["_loc", "", [""]]];
		
		ASSERT_OBJECT_CLASS(_loc, "Location");
		
		pr _gar = CALLM0(_loc, "getGarrisonMilitaryMain");
		
		if (_gar == "") exitWith {[]};
		
		pr _value = CLD_NEW();
		_value set [CLD_ID_TYPE, 1]; // todo add types for locations at some point?
		_value set [CLD_ID_SIDE, CALLM0(_gar, "getSide")];
		pr _locPos = +(CALLM0(_loc, "getPos"));
		_locPos resize 2;
		_value set [CLD_ID_POS, _locPos];
		_value set [CLD_ID_TIME, time];
		// Now count all the units
		{
			_x params ["_catID", "_catSize"];
			pr _query = [[_catID, 0]];
			for "_subcatID" from 0 to (_catSize - 1) do {
				(_query select 0) set [1, _subcatID];
				pr _amount = CALLM1(_gar, "countUnits", _query);
				(_value select CLD_ID_UNIT_AMOUNT select _catID) set [_subcatID, _amount];
			};
			
		} forEach [[T_INF, T_INF_SIZE], [T_VEH, T_VEH_SIZE], [T_DRONE, T_DRONE_SIZE]];
		
		_value
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
	Method: allocateUnits
	Tries to find a location to send units from
	
	Parameters: _a, _b, _c
	
	_a - 
	_b - 
	_c -
	
	Returns: nil
	*/
	METHOD("allocateUnitsGroundQRF") {
		params ["_thisObject", ["_pos", [], [[]]], ["_requiredEff", [], [[]]]];
		
		pr _side = T_GETV("side");
		OOP_INFO_3("Allocating units for side: %1, pos: %2, required eff: %3", _side, _pos, _requiredEff);
		private _allLocations = CALLSM0("Location", "getAll");
		
		// Find locations controled by this side
		private _friendlyLocations = _allLocations select {
			pr _gar = CALLM0(_x, "getGarrisonMilitaryMain");
			pr _garSide = CALLM0(_gar, "getSide");
			_garSide == _side
		};
		
		// Sort friendly locations by distance
		_friendlyDistLoc = _friendlyLocations apply {
			pr _locPos = CALLM0(_x, "getPos");
			[_locPos distance2D _pos, _x]
		};
		_friendlyDistLoc sort true; // Ascending
		
		OOP_INFO_1("Friendly locations sorted: %1", _friendlyDistLoc);
		
		// Find location that can deal with the threat
		pr _allocatedUnits = []; // Array with units we have allocated
		pr _allocatedGroups = []; // Array with groups we have allocated
		
		pr _allocatedVehicles = [];
		pr _allocatedCrew = [];
		pr _effAllocated = +T_EFF_null; // Efficiency of units allocated so far
		pr _allocated = false;
		scopeName "s0";
		{ // forEach _friendlyDistLoc;
			scopeName "scopeLocLoop";
			_x params ["_dist", "_loc"];
			
			OOP_INFO_3("Analyzing location: %1, pos: %2, distance: %2", _loc, CALLM0(_loc, "getPos"), _dist);
			
			pr _gar = CALLM0(_loc, "getGarrisonMilitaryMain");
			pr _garEff = CALLM0(_gar, "getEfficiencyMobile");
			// If units at this garrison can destroy the threat
			if (([_garEff, _requiredEff] call t_fnc_canDestroy) == T_EFF_CAN_DESTROY_ALL) then {
				scopeName "s1";
				
				pr _units = CALLM0(_gar, "getUnits") select {! CALLM0(_x, "isStatic")};
				_units = _units apply {pr _eff = CALLM0(_x, "getEfficiency"); [0, _eff, _x]};
				_allocatedUnits = [];
				_allocatedGroups = [];
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
					while {(_effAllocated select _j < _requiredEffCat) && (_pickUnitID < count _units)} do {
						pr _unit = _units select _pickUnitID select 2;
						pr _group = CALLM0(_unit, "getGroup");
						pr _groupType = if (_group != "") then {CALLM0(_group, "getType") else {GROUP_TYPE_IDLE};
						// Try not to take troops from vehicle groups
						pr _ignore = (CALLM0(_unit, "isInfantry") && _groupType in [GROUP_TYPE_VEH_NON_STATIC, GROUP_TYPE_VEH_STATIC]);
						
						if (!_ignore) then {							
							// If it was a vehicle, and it had crew in its group, add the crew as well
							if (CALLM0(_unit, "isVehicle")) then {
								pr _groupUnits = CALLM0(_group, "getUnits");
								// If there are more than one unit in a vehicle's group, then add the whole group
								if (count _groupUnits > 1) then {
									_allocatedGroups pushBackUnique _group;
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
							} else {
								_allocatedUnits pushBack _unit;
							};
							pr _unitEff = _units select _pickUnitID select 1;
							// Add to the allocated efficiency vector
							_effAllocated = VECTOR_ADD_9(_effAllocated, _unitEff);
						};
						_pickUnitID = _pickUnitID + 1;
					};
					
					_j = _j + 1;
				};
				
				// Check if we have allocated enough units
				if ([_effAllocated, _requiredEff] call t_fnc_canDestroy == T_EFF_CAN_DESTROY_ALL) then {
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
						if (_freeInfUnits < _nMoreCrewRequired) then {
							// Not enough infantry here to equip all the vehicles we have allocated
							// Go check other locations
							breakTo "scopeLocLoop";
						} else {
							// Add the allocated units to the array
							_allocatedUnits append (_freeInfUnits select [0, _nMoreCrewRequired]);
						};
					};
					
					// Do we need to find transport vehicles?
					if (_dist > QRF_NO_TRANSPORT_DISTANCE_MAX) then {
						pr _nCargoSeatsRequired = _nInfAllocated - _nDrivers - _nTurrets;
						pr _nCargoSeatsAvailable = CALLSM1("Unit", "getCargoInfantryCapacity", _allocatedVehicles);
						
						// If we need more vehicles for transport
						if (_nCargoSeatsAvailable < _nCargoSeatsRequired) then {
							pr _nMoreCargoSeatsRequired = _nCargoSeatsRequired - _nCargoSeatsAvailable;
							// Get all remaining vehicles in this garrison, sort them by their cargo infantry capacity
							pr _availableVehicles = CALLM1(_gar, "getUnits") select {
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
							
							// Add more vehicles while we can
							pr _i = 0;
							while {(_nMoreCargoSeatsRequired > 0) && (_i < count _availableVehiclesCapacity)} do {
								_allocatedUnits pushBack (_availableVehiclesCapacity select _i select 1);
								_nMoreCargoSeatsRequired = _nMoreCargoSeatsRequired - (_availableVehiclesCapacity select _i select 0);
								_i = _i + 1;
							};
							
							// IF we have finally found enough vehicles
							if (_nMoreCargoSeatsRequired <= 0) then {
								// Success
								_allocated = true;					
								breakTo "s0";
							} else {
								// Not enough vehicles for everyone!
								// Check other locations then
								breakTo "scopeLocLoop";
							}; // if (_nMoreCargoSeatsRequired <= 0)
						} else { // if (_nCargoSeatsAvailable < _nCargoSeatsRequired)
							// We don't need more vehicles, it's fine
							_allocated = true;					
							breakTo "s0";			
						}; // if (_nCargoSeatsAvailable < _nCargoSeatsRequired)
						
					} else {
						// No need to find transport vehicles
						// We are done here!
						_allocated = true;					
						breakTo "s0";					
					}; // (_dist > QRF_NO_TRANSPORT_DISTANCE_MAX) then {

				} else { // if ([_effAllocated, _requiredEff] call t_fnc_canDestroy == T_EFF_CAN_DESTROY_ALL) then {
					// Not enough units to deal with the threat
					breakTo "scopeLocLoop";
				};
			};
		} forEach _friendlyDistLoc;
		
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
				} forEach CALLM0(_x, "getUnits");
			} forEach _allocatedGroups;
		} else {
			OOP_INFO_0("Couldn't allocate units!");
		};
		
	} ENDMETHOD;
	
	
ENDCLASS;