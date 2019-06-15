#include "common.hpp"

/*
Class: AI.AICommander
AI class for the commander.

Author: Sparker 12.11.2018
*/

#ifndef RELEASE_BUILD
#define DEBUG_COMMANDER
#endif


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
	VARIABLE("intelDB"); // Intel database

	// Friendly garrisons we can access
	VARIABLE("garrisons");

	VARIABLE("targets"); // Array of targets known by this Commander
	VARIABLE("targetClusters"); // Array with target clusters
	VARIABLE("nextClusterID"); // A unique cluster ID generator

	//VARIABLE("lastPlanningTime");
	
	VARIABLE_ATTR("cmdrStrategy", [ATTR_REFCOUNTED]);
	VARIABLE("cmdrAI");
	VARIABLE("worldModel");

	#ifdef DEBUG_CLUSTERS
	VARIABLE("nextMarkerID");
	VARIABLE("clusterMarkers");
	#endif

	#ifdef DEBUG_COMMANDER
	VARIABLE("state");
	VARIABLE("stateStart");
	#endif

	METHOD("new") {
		params [P_THISOBJECT, ["_agent", "", [""]], ["_side", WEST, [WEST]], ["_msgLoop", "", [""]]];
		
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

		// Create intel database
		pr _intelDB = NEW("IntelDatabaseServer", [_side]);
		T_SETV("intelDB", _intelDB);

		#ifdef DEBUG_CLUSTERS
		T_SETV("nextMarkerID", 0);
		T_SETV("clusterMarkers", []);
		#endif

		#ifdef DEBUG_COMMANDER
		T_SETV("state", "none");
		T_SETV("stateStart", 0);
		[_thisObject, _side] spawn {
			params ["_thisObject", "_side"];
			private _pos = switch (_side) do {
				case WEST: { [0, -1000, 0 ] };
				case EAST: { [0, -1500, 0 ] };
				case INDEPENDENT: { [0, -500, 0 ] };
			};
			private _mrk = createmarker [_thisObject + "_label", _pos];
			_mrk setMarkerType "mil_objective";
			_mrk setMarkerColor (switch (_side) do {
				case WEST: {"ColorWEST"};
				case EAST: {"ColorEAST"};
				case INDEPENDENT: {"ColorGUER"};
				default {"ColorCIV"};
			});
			_mrk setMarkerAlpha 1;
			while{true} do {
				sleep 5;
				_mrk setMarkerText (format ["Cmdr %1: %2 (%3s)", _thisObject, T_GETV("state"), TIME_NOW - T_GETV("stateStart")]);
			};
		};
		#endif
		
		// Create sensors
		pr _sensorLocation = NEW("SensorCommanderLocation", [_thisObject]);
		CALLM1(_thisObject, "addSensor", _sensorLocation);
		pr _sensorTargets = NEW("SensorCommanderTargets", [_thisObject]);
		CALLM1(_thisObject, "addSensor", _sensorTargets);
		pr _sensorCasualties = NEW("SensorCommanderCasualties", [_thisObject]);
		CALLM(_thisObject, "addSensor", [_sensorCasualties]);
		
		T_SETV_REF("cmdrStrategy", gCmdrStrategyDefault);
		
		private _cmdrAI = NEW("CmdrAI", [_side]);
		T_SETV("cmdrAI", _cmdrAI);
		private _worldModel = NEW("WorldModel", []);
		T_SETV("worldModel", _worldModel);
	} ENDMETHOD;
	
	METHOD("process") {
		params [P_THISOBJECT];
		
		OOP_INFO_0(" - - - - - P R O C E S S - - - - -");
		
		// U P D A T E   S E N S O R S
		#ifdef DEBUG_COMMANDER
		T_SETV("state", "update sensors");
		T_SETV("stateStart", TIME_NOW);
		#endif

		// Update sensors
		CALLM0(_thisObject, "updateSensors");
		
		// U P D A T E   C L U S T E R S
		#ifdef DEBUG_COMMANDER
		T_SETV("state", "update clusters");
		T_SETV("stateStart", TIME_NOW);
		#endif

		// TODO: we should just respond to new cluster creation explicitly instead?
		// Register for new clusters		
		T_PRVAR(worldModel);
		{
			private _ID = _x select TARGET_CLUSTER_ID_ID;
			private _cluster = [_thisObject ARG _ID];
			if(IS_NULL_OBJECT(CALLM(_worldModel, "findClusterByActual", [_cluster]))) then {
				OOP_INFO_1("Target cluster with ID %1 is new", _ID);
				NEW("ClusterModel", [_worldModel ARG _cluster]);
			};
		} forEach T_GETV("targetClusters");

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

		// C M D R A I   P L A N N I N G
		T_PRVAR(cmdrAI);
		T_PRVAR(worldModel);

		#ifdef DEBUG_COMMANDER
		T_SETV("state", "action update");
		T_SETV("stateStart", TIME_NOW);
		#endif
		CALLM(_cmdrAI, "update", [_worldModel]);

		#ifdef DEBUG_COMMANDER
		T_SETV("state", "model planning");
		T_SETV("stateStart", TIME_NOW);
		#endif
		CALLM(_cmdrAI, "plan", [_worldModel]);

		// C L E A N U P
		#ifdef DEBUG_COMMANDER
		T_SETV("state", "cleanup");
		T_SETV("stateStart", TIME_NOW);
		#endif
		{
			// Unregister from ourselves straight away
			T_CALLM("_unregisterGarrison", [_x]);
			CALLM2(_x, "postMethodAsync", "destroy", [false]); // false = don't unregister from owning cmdr (as we just did it above!)
		} forEach (T_GETV("garrisons") select { CALLM(_x, "isEmpty", []) });

		#ifdef DEBUG_COMMANDER
		T_SETV("state", "inactive");
		T_SETV("stateStart", TIME_NOW);
		#endif
	} ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                    G E T   M E S S A G E   L O O P
	// ----------------------------------------------------------------------
	
	METHOD("getMessageLoop") {
		params [P_THISOBJECT];
		
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
		params [P_THISCLASS, P_SIDE("_side")];
		private _cmdr = NULL_OBJECT;
		switch (_side) do {
			case WEST: {
				if(!isNil "gAICommanderWest") then { _cmdr = gAICommanderWest };
			};
			case EAST: {
				if(!isNil "gAICommanderEast") then { _cmdr = gAICommanderEast };
			};
			case INDEPENDENT: {
				if(!isNil "gAICommanderInd") then { _cmdr = gAICommanderInd };
			};
		};
		_cmdr
	} ENDMETHOD;

	/*
	Method: (static)getCmdrStrategy
	Returns Strategy the cmdr of the specified side is using.
	
	Parameters: _side
	
	_side - side
	
	Returns: <CmdrStrategy>
	*/
	STATIC_METHOD("getCmdrStrategy") {
		params [P_THISCLASS, P_SIDE("_side")];
		private _thisObject = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [_side]);
		if(!IS_NULL_OBJECT(_thisObject)) then {
			ASSERT_THREAD;
			GETV(_thisObject, "cmdrStrategy")
		} else {
			gCmdrStrategyDefault
		}
	} ENDMETHOD;

	/*
	Method: setCmdrStrategy
	Set Strategy the cmdr should use.

	Parameters: _strategy

	_strategy - CmdrStrategy
	*/
	METHOD("setCmdrStrategy") {
		params [P_THISOBJECT, P_OOP_OBJECT("_strategy")];
		ASSERT_OBJECT_CLASS(_strategy, "CmdrStrategy");
		ASSERT_THREAD;
		T_SETV_REF("cmdrStrategy", _strategy)
	} ENDMETHOD;

	/*
	Method: (static)setCmdrStrategyForSide
	Set Strategy the cmdr should use.

	Parameters: _side, _strategy

	_side - side
	_strategy - CmdrStrategy
	*/
	STATIC_METHOD("setCmdrStrategyForSide") {
		params [P_THISCLASS, P_SIDE("_side"), P_OOP_OBJECT("_strategy")];
		private _thisObject = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [_side]);
		if(!IS_NULL_OBJECT(_thisObject)) then {
			T_CALLM2("postMethodAsync", "setCmdrStrategy", [_strategy]);
		} else {
			OOP_WARNING_MSG("Can't set cmdr strategy %1, no AICommander found for side %2", [_strategy ARG _side]);
		};
	} ENDMETHOD;

	// Location data
	// If you pass any side except EAST, WEST, INDEPENDENT, then this AI object will update its own knowledge about provided locations
	// _updateIfFound - if true, will update an existing item. if false, will not update it
	METHOD("updateLocationData") {
		params [["_thisObject", "", [""]], ["_loc", "", [""]], ["_updateType", 0, [0]], ["_side", CIVILIAN], ["_showNotification", true], ["_updateIfFound", true], ["_accuracyRadius", 0]];
		
		OOP_INFO_1("UPDATE LOCATION DATA: %1", _this);

		pr _thisSide = T_GETV("side");
		
		pr _ld = switch (_side) do {
			case WEST: {T_GETV("locationDataWest")};
			case EAST: {T_GETV("locationDataEast")};
			case INDEPENDENT: {T_GETV("locationDataInd")};
			default { _side = _thisSide; T_GETV("locationDataThis")};
		};
				
		// Check if we have intel about such location already
		pr _intelDB = T_GETV("intelDB");
		pr _result0 = CALLM2(_intelDB, "getFromIndex", "location", _loc);
		pr _result1 = CALLM2(_intelDB, "getFromIndex", OOP_PARENT_STR, "IntelLocation");
		pr _intelResult = (_result0 arrayIntersect _result1) select 0;

		if (! isNil "_intelResult") then {

			OOP_INFO_1("Intel query result: %1;", _intelResult);

			// There is an intel item with this location

			if (_updateIfFound) then {
				OOP_INFO_1("Intel was found in existing database: %1", _loc);

				// Create intel item from location, update the old item
				pr _args = [_loc, _updateType, _accuracyRadius];
				pr _intel = CALL_STATIC_METHOD("AICommander", "createIntelFromLocation", _args);

				// Check if the created intel and the existing one are the same
				pr _serialOld = SERIALIZE(_intelResult);
				SERIALIZED_SET_OBJECT_NAME(_serialOld, nil);
				_serialOld = _serialOld apply {if (isNil "_x") then {-123.45678} else {_x}};
				pr _serialNew = SERIALIZE(_intel);
				SERIALIZED_SET_OBJECT_NAME(_serialNew, nil);
				_serialNew = _serialNew apply {if (isNil "_x") then {-123.45678} else {_x}};

				/*
				OOP_INFO_1("   old: %1", _serialOld);
				OOP_INFO_1("   new: %1", _serialNew);
				*/

				if (!(_serialOld isEqualTo _serialNew)) then {
					CALLM2(_intelDB, "updateIntel", _intelResult, _intel);

					// Delete the intel object that we have created temporary
					DELETE(_intel);
				};
			};
		} else {
			// There is no intel item with this location
			
			OOP_INFO_1("Intel was NOT found in existing database: %1", _loc);

			// Create intel from location, add it
			pr _args = [_loc, _updateType, _accuracyRadius];
			pr _intel = CALL_STATIC_METHOD("AICommander", "createIntelFromLocation", _args);
			
			OOP_INFO_1("Created intel item from location: %1", _intel);
			//[_intel] call OOP_dumpAllVariables;

			CALLM1(_intelDB, "addIntel", _intel);
			// Don't delete the intel object now! It's in the database from now.

			// Register with the World Model
			T_PRVAR(worldModel);
			CALLM(_worldModel, "findOrAddLocationByActual", [_loc]);
		};
		
	} ENDMETHOD;
	
	// Creates a LocationData array from Location
	STATIC_METHOD("createIntelFromLocation") {
		params ["_thisClass", ["_loc", "", [""]], ["_updateLevel", 0, [0]], ["_accuracyRadius", 0, [0]]];
		
		ASSERT_OBJECT_CLASS(_loc, "Location");
		
		pr _gar = CALLM0(_loc, "getGarrisons") select 0;
		if (isNil "_gar") then {
			_gar = "";
		};
		
		pr _value = NEW("IntelLocation", []);
		
		// Set position and accuracy radius
		pr _locPos = +(CALLM0(_loc, "getPos"));
		_locPos resize 2;
		if (_accuracyRadius > 0) then {
			_locPos params ["_x", "_y"];
			private _r = _accuracyRadius/(sqrt(2));
			_locPos set [0, _x - _r + random(2*_r)];
			_locPos set [1, _y - _r + random(2*_r)];
		};
		SETV(_value, "accuracyRadius", _accuracyRadius);
		SETV(_value, "pos", _locPos);


		
		// Set time
		//SETV(_value, "", set [CLD_ID_TIME, TIME_NOW];
		
		// Set type
		if (_updateLevel >= CLD_UPDATE_LEVEL_TYPE) then {
			SETV(_value, "type", CALLM0(_loc, "getType")); // todo add types for locations at some point?
		} else {
			SETV(_value, "type", LOCATION_TYPE_UNKNOWN);
		};
		
		// Set side
		if (_updateLevel >= CLD_UPDATE_LEVEL_SIDE) then {
			if (_gar != "") then {
				SETV(_value, "side", CALLM0(_gar, "getSide"));
			} else {
				SETV(_value, "side", CLD_SIDE_UNKNOWN);
			};
		} else {
			SETV(_value, "side", CLD_SIDE_UNKNOWN);
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
			SETV(_value, "unitData", _CLD_full);
		} else {
			SETV(_value, "unitData", CLD_UNIT_AMOUNT_UNKNOWN);
		};
		
		// Set ref to location object
		SETV(_value, "location", _loc);
		
		_value
	} ENDMETHOD;
	
	// Gets a random intel item from an enemy commander.
	// It's quite a temporary action for now.
	// Later we needto redo it.
	METHOD("getRandomIntelFromEnemy") {
		params ["_thisObject", ["_clientOwner", 0]];

		pr _commandersEnemy = [gAICommanderWest, gAICommanderEast, gAICommanderInd] - [_thisObject];

		OOP_INFO_1("Stealing intel from commanders: %1", _commandersEnemy);

		pr _intelAdded = false;
		pr _thisDB = T_GETV("intelDB");
		{
			OOP_INFO_1("Stealing intel from enemy commander: %1", _x);

			pr _enemyDB = GETV(_x, "intelDB");
			// Select intel items of the classes we are interested in
			pr _classes = ["IntelCommanderActionReinforce", "IntelCommanderActionBuild", "IntelCommanderActionAttack", "IntelCommanderActionRecon"];
			pr _potentialIntel = CALLM0(_enemyDB, "getAllIntel") select {
				if (!CALLM1(_thisDB, "isIntelAddedFromSource", _x)) then { // We only care to steal it if we don't have it yet!
					GET_OBJECT_CLASS(_x) in _classes; // Make sure the intel item is one of the interesting classes
				} else {
					false
				};
			};
			
			OOP_INFO_1("   Amount of potential intel items: %1", count _potentialIntel);

			if (count _potentialIntel > 0) then {
				// Chose a random item
				pr _item = selectRandom _potentialIntel;

				OOP_INFO_1("   Stealing intel item: %1", _item);

				// Clone it and it to our database
				pr _itemClone = CLONE(_item);
				SETV(_itemClone, "source", _item); // Link it with the source
				CALLM1(_thisDB, "addIntel", _itemClone);

				_intelAdded = true;
			};
		} forEach _commandersEnemy;

		// Show some text on client's computer
		if (_intelAdded) then {
			"You have found some new intel!" remoteExecCall ["systemChat", _clientOwner];
		} else {
			"We already know this intel!" remoteExecCall ["systemChat", _clientOwner];
		};

	} ENDMETHOD;

	METHOD("getIntelFromInventoryItem") {
		params ["_thisObject", ["_baseClass", "", [""]], ["_ID", 0, [0]], ["_clientOwner", 0, [0]]];

		// Get data from the inventory item
		pr _ret = CALLM2(gPersonalInventory, "getInventoryData", _baseClass, _ID);
		_ret params ["_data", "_dataIsNotNil"];

		// Make sure _data is valid
		pr _foundSomething = false;
		if (_dataIsNotNil) then {
			if (count _data > 0) then {
				_foundSomething = true;
			};
		};

		pr _thisDB = T_GETV("intelDB");
		if (_foundSomething) then {
			{
				pr _item = _x;
				OOP_INFO_1("   Stealing intel item: %1", _item);

				// Make sure the intel object is valid
				if (IS_OOP_OBJECT(_item)) then {
					if (CALLM1(_thisDB, "isIntelAddedFromSource", _item)) then {
						// Update it from source
						CALLM1(_thisDB, "updateIntelFromSource", _item);
					} else {
						// Clone it and it to our database
						pr _itemClone = CLONE(_item);
						SETV(_itemClone, "source", _item); // Link it with the source
						CALLM1(_thisDB, "addIntel", _itemClone);
					};
				} else {
					OOP_INFO_1("Intel object is invalid: %1", _item);
				};
			} forEach _data;
		} else {
			"You have found nothing here!" remoteExecCall ["systemChat", _clientOwner];
		};

		// Reset this inventory item data
		CALLM3(gPersonalInventory, "setInventoryData", _baseClass, _ID, nil);
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
		
	// // /*
	// // Method: onTargetClusterCreated
	// // Gets called on creation of a totally new target cluster
	
	// // Parameters: _tc
	
	// // _ID - the new target cluster ID (must already exist in the cluster array)
	
	// // Returns: nil
	// // */
	// METHOD("onTargetClusterCreated") {
	// 	params ["_thisObject", "_ID"];
	// 	OOP_INFO_1("TARGET CLUSTER CREATED, ID: %1", _ID);
	// 	T_PRVAR(worldModel);
	// 	NEW("ClusterModel", [_worldModel ARG [_thisObject ARG _ID]]);
	// } ENDMETHOD;

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

		T_PRVAR(worldModel);
		// Retarget in the model
		CALLM(_worldModel, "retargetClusterByActual", [[_thisObject ARG _IDOld] ARG [_thisObject ARG _newClusterID]]);
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
		{
			pr _IDOld = _x;
			// Retarget in the model
			CALLM(_worldModel, "retargetClusterByActual", [[_thisObject ARG _IDOld] ARG [_thisObject ARG _IDnew]]);
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
	Method: getThreat
	Get estimated threat at a particular position
	
	Parameters:
	_pos - <position>
	
	Returns: Number - threat at _pos
	*/
	METHOD("getThreat") { // thread-safe
		params [P_THISOBJECT, P_ARRAY("_pos")];
		T_PRVAR(worldModel);
		CALLM(_worldModel, "getThreat", [_pos])
	} ENDMETHOD;
		
	// Thread safe
	METHOD("_addActivity") {
		params [P_THISCLASS, P_SIDE("_side"), P_POSITION("_pos"), P_NUMBER("_activity")];
		OOP_DEBUG_MSG("Adding %1 activity at %2 for side %3", [_activity ARG _pos ARG _side]);
		T_PRVAR(worldModel);
		CALLM(_worldModel, "addActivity", [_pos ARG _activity])
	} ENDMETHOD;

	// Thread safe
	STATIC_METHOD("addActivity") {
		params [P_THISCLASS, P_SIDE("_side"), P_POSITION("_pos"), P_NUMBER("_activity")];

		private _thisObject = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [_side]);
		if(!IS_NULL_OBJECT(_thisObject)) then {
			T_CALLM2("postMethodAsync", "_addActivity", [_side ARG _pos ARG _activity]);
		};
	} ENDMETHOD;

	/*
	Method: getActivity
	Get enemy (to this cmdr) activity in an area
	
	Parameters:
	_pos - <position>
	_radius - <number>
	
	Returns: Number - max activity in radius2
	*/
	METHOD("getActivity") { // thread-safe
		params [P_THISOBJECT, P_ARRAY("_pos"), P_NUMBER("_radius")];
		T_PRVAR(worldModel);
		CALLM(_worldModel, "getActivity", [_pos ARG _radius])
	} ENDMETHOD;

	/*
	Method: _registerGarrison
	Registers a garrison to be processed by this AICommander
	
	Parameters:
	_gar - <Garrison>
	
	Returns: GarrisonModel
	*/
	METHOD("_registerGarrison") {
		params [P_THISOBJECT, P_OOP_OBJECT("_gar")];
		ASSERT_OBJECT_CLASS(_gar, "Garrison");
		ASSERT_THREAD(_thisObject);

		OOP_DEBUG_MSG("Registering garrison %1", [_gar]);
		T_GETV("garrisons") pushBack _gar; // I need you for my army!
		CALLM(_gar, "ref", []);
		T_PRVAR(worldModel);
		NEW("GarrisonModel", [_worldModel ARG _gar])
	} ENDMETHOD;

	/*
	Method: registerGarrison
	Registers a garrison to be processed by this AICommander
	
	Parameters:
	_gar - <Garrison>
	
	Returns: GarrisonModel
	*/
	STATIC_METHOD("registerGarrison") {
		params [P_THISCLASS, P_OOP_OBJECT("_gar")];
		ASSERT_OBJECT_CLASS(_gar, "Garrison");
		private _side = CALLM(_gar, "getSide", []);
		private _thisObject = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [_side]);

		if(!IS_NULL_OBJECT(_thisObject)) then {
			T_CALLM("_registerGarrison", [_gar]);
		} else {
			OOP_ERROR_MSG("No AICommander found for side %1 to register %2", [_side ARG _gar]);
			NULL_OBJECT
		}
	} ENDMETHOD;

	/*
	Method: registerGarrisonOutOfThread
	Registers a garrison to be processed by this AICommander.
	Call this version if you are outside of the commander thread.
	
	Parameters:
	_gar - <Garrison>
	
	Returns: nil
	*/
	STATIC_METHOD("registerGarrisonOutOfThread") {
		params [P_THISCLASS, P_OOP_OBJECT("_gar")];
		ASSERT_OBJECT_CLASS(_gar, "Garrison");
		private _side = CALLM(_gar, "getSide", []);
		private _thisObject = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [_side]);

		if(!IS_NULL_OBJECT(_thisObject)) then {
			CALLM2(_thisObject, "postMethodAsync", "_registerGarrison", [_gar]);
		} else {
			OOP_ERROR_MSG("No AICommander found for side %1 to register %2", [_side ARG _gar]);
		};
	} ENDMETHOD;

	/*
	Method: registerLocation
	Registers a location to be known by this AICommander
	
	Parameters:
	_loc - <Location>
	
	Returns: nil
	*/
	METHOD("registerLocation") {
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];
		ASSERT_OBJECT_CLASS(_loc, "Location");

		private _newModel = NULL_OBJECT;
		OOP_DEBUG_MSG("Registering location %1", [_loc]);
		//T_GETV("locations") pushBack _loc; // I need you for my army!
		// CALLM2(_loc, "postMethodAsync", "ref", []);
		T_PRVAR(worldModel);
		// Just creating the location model is registering it with CmdrAI
		NEW("LocationModel", [_worldModel ARG _loc]);
	} ENDMETHOD;

	/*
	Method: unregisterGarrison
	Unregisters a garrison from this AICommander
	
	Parameters:
	_gar - <Garrison>
	
	Returns: nil
	*/
	STATIC_METHOD("unregisterGarrison") {
		params [P_THISCLASS, P_OOP_OBJECT("_gar")];
		ASSERT_OBJECT_CLASS(_gar, "Garrison");
		private _side = CALLM(_gar, "getSide", []);
		private _thisObject = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [_side]);
		if(!IS_NULL_OBJECT(_thisObject)) then {
			T_CALLM2("postMethodAsync", "_unregisterGarrison", [_gar]);
		} else {
			OOP_WARNING_MSG("Can't unregisterGarrison %1, no AICommander found for side %2", [_gar ARG _side]);
		};
	} ENDMETHOD;

	METHOD("_unregisterGarrison") {
		params [P_THISOBJECT, P_STRING("_gar")];
		ASSERT_THREAD(_thisObject);

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
			CALLM(_gar, "unref", []);
		} else {
			OOP_WARNING_MSG("Garrison %1 not registered so can't _unregisterGarrison", [_gar]);
		};
	} ENDMETHOD;
		
	/*
	Method: registerIntelCommanderAction
	Registers a piece of intel on an action that this Commander owns.
	Parameters:
	_intel - <IntelCommanderAction>
	
	Returns: nil
	*/
	STATIC_METHOD("registerIntelCommanderAction") {
		params [P_THISCLASS, P_OOP_OBJECT("_intel")];
		ASSERT_OBJECT_CLASS(_intel, "IntelCommanderAction");
		private _side = GETV(_intel, "side");
		private _thisObject = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [_side]);

		T_PRVAR(intelDB);
		CALLM(_intelDB, "addIntelClone", [_intel])
	} ENDMETHOD;

	// Temporary function that adds infantry to some location
	METHOD("addGroupToLocation") {
		params [P_THISCLASS, P_OOP_OBJECT("_loc"), P_NUMBER("_nTroops")];

		pr _side = T_GETV("side");

		// Check if there is already a garrison at this location
		pr _gars = CALLM1(_loc, "getGarrisons", _side);
		pr _gar = if ((count _gars) > 0) then {
			_gars#0
		} else {
			pr _locPos = CALLM0(_loc, "getPos");
			// Create a new garrison and register it
			_gar = NEW("Garrison", [_side ARG _locPos]);
			CALLM2(_gar, "postMethodAsync", "setLocation", [_loc]);
			CALLM2(_gar, "postMethodAsync", "activate", []);
			_gar
		};

		// Create some infantry group
		pr _group = NEW("Group", [_side ARG GROUP_TYPE_IDLE]);
		CALLM2(_group, "createUnitsFromTemplate", tGUERILLA, T_GROUP_inf_rifle_squad);
		CALLM2(_gar, "postMethodAsync", "addGroup", [_group]);

		// That's all!
	} ENDMETHOD;
ENDCLASS;
