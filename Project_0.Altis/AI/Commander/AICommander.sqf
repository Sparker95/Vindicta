#include "common.hpp"

/*
Class: AI.AICommander
AI class for the commander.

Author: Bill 2018 (CmdrAI logic, planning, world model, action generation, etc)
Sparker 12.11.2018 (initial file)
*/

#ifndef RELEASE_BUILD
#define DEBUG_COMMANDER
#endif

// Ported from CmdrAI
#define ACTION_SCORE_CUTOFF 0.001
#define REINF_MAX_DIST 4000

#define pr private

CLASS("AICommander", "AI")

	VARIABLE("side");
	VARIABLE("msgLoop");
	VARIABLE("intelDB"); // Intel database

	// Friendly garrisons we can access
	VARIABLE("garrisons");

	// Used by SensorCommanderTargets
	VARIABLE("targets"); // Array of targets known by this Commander
	VARIABLE("targetClusters"); // Array with target clusters
	VARIABLE("nextClusterID"); // A unique cluster ID generator
	
	VARIABLE_ATTR("cmdrStrategy", [ATTR_REFCOUNTED]);
	VARIABLE("worldModel");

	#ifdef DEBUG_CLUSTERS
	VARIABLE("nextMarkerID");
	VARIABLE("clusterMarkers");
	#endif

	#ifdef DEBUG_COMMANDER
	VARIABLE("state");
	VARIABLE("stateStart");
	#endif

	// Radio
	VARIABLE("radioKeyGrid"); 	// Grid object which stores our own radio keys
	VARIABLE("enemyRadioKeys");	// Enemy radio keys we have found

	// Ported from CmdrAI
	VARIABLE("activeActions");
	VARIABLE("planningCycle");

	METHOD("new") {
		params [P_THISOBJECT, ["_agent", "", [""]], ["_side", WEST, [WEST]], ["_msgLoop", "", [""]]];
		
		OOP_INFO_1("Initializing Commander for side %1", str(_side));
		
		ASSERT_OBJECT_CLASS(_msgLoop, "MessageLoop");
		T_SETV("side", _side);
		T_SETV("msgLoop", _msgLoop);
		
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
		
		private _worldModel = NEW("WorldModel", []);
		T_SETV("worldModel", _worldModel);

		// Ported from CmdrAI
		T_SETV("activeActions", []);
		T_SETV("planningCycle", 0);

		// Initialize the radio keys
		T_SETV("enemyRadioKeys", []);
		T_CALLM0("initRadioKeys"); // Will set the radioKeyGrid variable

	} ENDMETHOD;
	

/*
88888888ba   88888888ba     ,ad8888ba,      ,ad8888ba,   88888888888  ad88888ba    ad88888ba   
88      "8b  88      "8b   d8"'    `"8b    d8"'    `"8b  88          d8"     "8b  d8"     "8b  
88      ,8P  88      ,8P  d8'        `8b  d8'            88          Y8,          Y8,          
88aaaaaa8P'  88aaaaaa8P'  88          88  88             88aaaaa     `Y8aaaaa,    `Y8aaaaa,    
88""""""'    88""""88'    88          88  88             88"""""       `"""""8b,    `"""""8b,  
88           88    `8b    Y8,        ,8P  Y8,            88                  `8b          `8b  
88           88     `8b    Y8a.    .a8P    Y8a.    .a8P  88          Y8a     a8P  Y8a     a8P  
88           88      `8b    `"Y8888Y"'      `"Y8888Y"'   88888888888  "Y88888P"    "Y88888P"   
*/
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

		// C M D R A I   P L A N N I N G
		T_PRVAR(worldModel);

		#ifdef DEBUG_COMMANDER
		T_SETV("state", "action update");
		T_SETV("stateStart", TIME_NOW);
		#endif
		T_CALLM("update", [_worldModel]);

		#ifdef DEBUG_COMMANDER
		T_SETV("state", "model planning");
		T_SETV("stateStart", TIME_NOW);
		#endif
		#ifndef CMDR_AI_NO_PLAN
		T_CALLM("plan", [_worldModel]);
		#endif

		// C L E A N U P
		#ifdef DEBUG_COMMANDER
		T_SETV("state", "cleanup");
		T_SETV("stateStart", TIME_NOW);
		#endif
		{
			// Unregister from ourselves straight away
			T_CALLM("_unregisterGarrison", [_x]);
			CALLM2(_x, "postMethodAsync", "destroy", [false]); // false = don't unregister from owning cmdr (as we just did it above!)
		} forEach (T_GETV("garrisons") select { CALLM(_x, "isEmpty", []) && {CALLM0(_x, "getLocation") == ""} });

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
	// !!! _side parameter seems to be not used any more, need to delete it. We obviously update intel for our own side in this method.
	// !!! _showNotifications also seems to not work any more
	METHOD("updateLocationData") {
		params [["_thisObject", "", [""]], ["_loc", "", [""]], ["_updateLevel", CLD_UPDATE_LEVEL_UNITS, [0]], ["_side", CIVILIAN], ["_showNotification", true], ["_updateIfFound", true], ["_accuracyRadius", 0]];
		
		OOP_INFO_1("UPDATE LOCATION DATA: %1", _this);
	
		// Check if we have intel about such location already
		pr _intelResult = T_CALLM1("getIntelAboutLocation", _loc);
		pr _intelDB = T_GETV("intelDB");

		if (!IS_NULL_OBJECT(_intelResult)) then {
			OOP_INFO_1("Intel query result: %1;", _intelResult);

			// There is an intel item with this location

			if (_updateIfFound) then {
				OOP_INFO_1("Intel was found in existing database: %1", _loc);
				// Update only if incoming accuracy is more or equal to existing one
				if (_updateLevel >= GETV(_intelResult, "accuracy")) then {
					// Create intel item from location, update the old item
					pr _args = [_loc, _updateLevel, _accuracyRadius];
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
					
						// Enable or disable player respawn here
						// Now it was moved to game mode
						/*
						pr _locRealType = CALLM0(_loc, "getType");
						if (_locRealType != LOCATION_TYPE_CITY) then {
							pr _locSide = GETV(_intel, "side");
							pr _thisSide = T_GETV("side");
							pr _locRealType = CALLM0(_loc, "getType");
							pr _enable = (_locSide == _thisSide);
							CALLM2(_loc, "enablePlayerRespawn", _thisSide, _enable);
						};
						*/
					};

					// Delete the intel object that we have created temporary
					DELETE(_intel);
				};
			};
		} else {
			// There is no intel item with this location
			
			OOP_INFO_1("Intel was NOT found in existing database: %1", _loc);

			// Create intel from location, add it
			pr _args = [_loc, _updateLevel, _accuracyRadius];
			pr _intel = CALL_STATIC_METHOD("AICommander", "createIntelFromLocation", _args);
			
			OOP_INFO_1("Created intel item from location: %1", _intel);
			//[_intel] call OOP_dumpAllVariables;

			CALLM1(_intelDB, "addIntel", _intel);
			// Don't delete the intel object now! It's in the database from now.

			// Enable or disable player respawn here
			// Was moved to game mode
			/*
			pr _locRealType = CALLM0(_loc, "getType");
			if (_locRealType != LOCATION_TYPE_CITY) then {
				pr _locSide = GETV(_intel, "side");
				pr _thisSide = T_GETV("side");
				pr _enable = (_locSide == _thisSide);
				CALLM2(_loc, "enablePlayerRespawn", _thisSide, _enable);
			};
			*/

			// Register with the World Model
			T_PRVAR(worldModel);
			CALLM(_worldModel, "findOrAddLocationByActual", [_loc]);
		};
		
	} ENDMETHOD;
	
	// Returns intel we have about specified location
	METHOD("getIntelAboutLocation") {
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];
		pr _intelDB = T_GETV("intelDB");
		pr _result0 = CALLM2(_intelDB, "getFromIndex", "location", _loc);
		if (count _result0 == 0) then {
			""
		} else {
			pr _result1 = CALLM2(_intelDB, "getFromIndex", OOP_PARENT_STR, "IntelLocation");
			pr _intelResult = (_result0 arrayIntersect _result1);
			if (count _intelResult > 0) then {
				_intelResult#0
			} else {
				""
			};
		};
	} ENDMETHOD;

	// Creates a LocationData array from Location
	METHOD("createIntelFromLocation") {
		params ["_thisClass", ["_loc", "", [""]], ["_updateLevel", 0, [0]], ["_accuracyRadius", 0, [0]]];
		
		ASSERT_OBJECT_CLASS(_loc, "Location");
		
		// Try to find friendly garrisons there first
		// Otherwise try to find any garrisons there
		pr _garFriendly = CALLM1(_loc, "getGarrisons", T_GETV("side"));
		pr _gar = if (count _garFriendly != 0) then {
			_garFriendly#0
		} else {
			pr _allGars = CALLM0(_loc, "getGarrisons");
			if (count _allGars != 0) then { _allGars#0 } else { "" };
		};
		
		pr _value = NEW("IntelLocation", []);

		// Set accuracy
		SETV(_value, "accuracy", _updateLevel);
		
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

	// Thread safe
	// Call it from a non-player-commander thread to reveal intel to the AICommander of player side
	STATIC_METHOD("revealIntelToPlayerSide") {
		params ["_thisClass", ["_item", "", [""]]];

		if (true) exitWith {
			OOP_WARNING_0("revealIntelToPlayerSide is currently disabled!");
		};

		// Make a clone of this intel item in our thread
		pr _itemClone = CLONE(_item);
		SETV(_itemClone, "source", _item); // Link it with the source

		pr _playerSide = CALLM0(gGameMode, "getPlayerSide");
		pr _ai = CALLSM1("AICommander", "getCommanderAIOfSide", _playerSide);
		CALLM2(_ai, "postMethodAsync", "stealIntel", [_item ARG _itemClone]);
	} ENDMETHOD;

	// Handles stealing intel item which this commander doesn't own
	// Temporary function to reveal stuff to players
	METHOD("stealIntel") {
		 params ["_thisObject", ["_item", "", [""]], P_OOP_OBJECT("_itemClone")];

		// Bail if object is wrong
		//if (!IS_OOP_OBJECT(_item)) exitWith { };

		pr _thisDB = T_GETV("intelDB");
		CALLM1(_thisDB, "addIntel", _itemClone);
	} ENDMETHOD;

	// Gets called when enemy has produced some intel and sends it to some place
	// Enemies might have a chance to intercept it
	// Thread-safe function, it will postMethodAsync to other commanders
	STATIC_METHOD("interceptIntelAt") {
		params [P_THISCLASS, P_OOP_OBJECT("_intel"), P_POSITION("_pos")];

		pr _thisSide = GETV(_intel, "side");
		pr _thisAI = CALLSM1("AICommander", "getCommanderAIOfSide", _side);
		pr _radioKey = CALLM1(_thisAI, "getRadioKey", _pos); // Enemies must have the radio key to intercept this data
		{
			pr _ai = CALLSM1("AICommander", "getCommanderAIOfSide", _x);
			CALLM2(_ai, "postMethodAsync", "_interceptIntelAt", [_intel ARG _pos ARG _radioKey]);
		} forEach ([WEST, EAST, INDEPENDENT] - [_thisSide]);
	} ENDMETHOD;

	// Local function, called in thread, on the commander which is tryint to intercept the enemy intel
	METHOD("_interceptIntelAt") {
		params [P_THISOBJECT, P_OOP_OBJECT("_intel"), P_POSITION("_pos"), P_STRING("_radioKey")];

		// Check if we have the radio key
		pr _ourKnownEnemyKeys = T_GETV("enemyRadioKeys");
		pr _weHaveRadioKey = _radioKey in _ourKnownRadioKeys;

		// Check if we have friendly locations nearby
		pr _side = T_GETV("side");
		pr _friendlyLocs = CALLSM0("Location", "getAll") select {
			(CALLM0(_x, "getPos") distance _pos) < 3500
			// Todo also check if there is necessary radio equipment
		} select {
			pr _gars = CALLM1(_x, "getGarrisons", _side);
			(count _gars) > 0
		};

		// Do we have friendly locations nearby?
		if (count _friendlyLocs > 0) then {
			if (_weHaveRadioKey) then {
				T_CALLM1("inspectIntel", _intel);
			} else {
				// Todo Mark an unknown radio transmission on the map??
			};
		};
	} ENDMETHOD;

	// Checks intel in some other cmdr's database
	// Makes a copy of that intel and takes it to this commander
	METHOD("inspectIntel") {
		params [P_THISOBJECT, P_OOP_OBJECT("_intel")];

		OOP_INFO_1("INSPECT INTEL: %1", _intel);

		// Bail if null object for some reason
		if (IS_NULL_OBJECT(_intel)) exitWith {
			OOP_ERROR_0("INSPECT INTEL: null object was passed");
		};

		pr _srcSide = GETV(_intel, "side");
		if (_srcSide == T_GETV("side")) exitWith {
			OOP_INFO_0("  it's our own intel!");
		};

		// Check if we have an intel from this source already
		pr _db = T_GETV("intelDB");
		if (CALLM1(_db, "isIntelAddedFromSource", _intel)) then { // If it's not our own intel, then this intel item might be a source of our intel item 
			// Update the intel
			OOP_INFO_1("  Intel with source %1 found in DB, updating from source...", _intel);
			CALLM1(_db, "updateIntelFromSource", _intel);
		} else {
			// Make a clone for ourselves and add it to our database
			pr _ourIntel = CLONE(_intel);
			OOP_INFO_2("  Intel with source %1 NOT found in DB, made a clone: %2", _intel, _ourIntel);
			SETV(_ourIntel, "source", _intel); // We must mark the external intel item as as source of this intel, for future updates
			CALLM1(_db, "addIntel", _ourIntel);
		};
	} ENDMETHOD;

	// Gets called after player has analyzed up an inventory item with intel
	METHOD("getIntelFromInventoryItem") {
		params ["_thisObject", ["_baseClass", "", [""]], ["_ID", 0, [0]], ["_clientOwner", 0, [0]]];

		private _endl = toString [13,10];

		OOP_INFO_1("GET INTEL FROM INTENTORY ITEM: %1", [_baseClass ARG _ID]);

		// Get data from the inventory item
		pr _ret = CALLM2(gPersonalInventory, "getInventoryData", _baseClass, _ID);
		_ret params ["_data", "_dataIsNotNil"];

		if (!_dataIsNotNil) exitWith {
			pr _text = "No data registered for this device in TactiCommNetWork!" + _endl;
			REMOTE_EXEC_CALL_STATIC_METHOD("TacticalTablet", "staticAppendTextDelay", [_text ARG 0], _clientOwner, false);

			pr _text = "Retinal scan identity mismatch!" + _endl + "Device will be locked." + _endl;
			REMOTE_EXEC_CALL_STATIC_METHOD("TacticalTablet", "staticAppendTextDelay", [_text ARG 0], _clientOwner, false);
		};

		OOP_INFO_1("  data from pers. inv.: %1", _data);

		// Unpack the data
		pr _temp = NEW("UnitIntelData", []);
		DESERIALIZE(_temp, _data);
		pr _intelGeneral = GETV(_temp, "intelGeneral");
		pr _intelPersonal = GETV(_temp, "intelPersonal");
		pr _locs = GETV(_temp, "knownFriendlyLocations");
		pr _radioKey = GETV(_temp, "radioKey");
		pr _itemSide = GETV(_temp, "side");
		DELETE(_temp);

		pr _side = T_GETV("side");

		// Process the radioKey value
		if (!isNil "_radioKey") then {
			if (count _radioKey > 0) then {
				// Check if we have this radio key
				if (_itemSide != _side) then {
					if (_radioKey in T_GETV("enemyRadioKeys")) then {
						"We have this cryptokey already..." remoteExecCall ["systemChat", _clientOwner];
					} else {
						"We don't have this cryptokey! I should add it to notes and return it back to base!" remoteExecCall ["systemChat", _clientOwner];

						// Copy stuff into player's notes
						pr _text = format [_endl + "%1 Found enemy radio cryptokey: %2" + _endl, date call misc_fnc_dateToISO8601, _radioKey];
						REMOTE_EXEC_CALL_STATIC_METHOD("InGameMenuTabNotes", "staticAppendText", [_text], _clientOwner, false);
					};
				};

				// Send data to tablet
				pr _text = format [_endl + "  Radio cryptokey: %1" + _endl, _radioKey];
				REMOTE_EXEC_CALL_STATIC_METHOD("TacticalTablet", "staticAppendTextDelay", [_text ARG 0.1], _clientOwner, false);
			};
		};

		// Process the intel about this garrison's action
		if (!IS_NULL_OBJECT(_intelPersonal)) then {
			if (IS_OOP_OBJECT(_intelPersonal)) then {

				// Add to our db if needed
				if (_itemSide != _side) then {
					T_CALLM1("inspectIntel", _intelPersonal);
				};

				// Process what to show on the remote player's tablet
				pr _actionName = CALLM0(_intelPersonal, "getShortName");
				pr _dateDeparture = GETV(_intelPersonal, "dateDeparture");
				pr _posSrc = GETV(_intelPersonal, "posSrc");
				pr _posTgt = GETV(_intelPersonal, "posTgt");

				if (!isNil "_posTgt") then {
					pr _text = format ["  Current order: %1 at grid %2" + _endl, _actionName, mapGridPosition _posTgt];
					REMOTE_EXEC_CALL_STATIC_METHOD("TacticalTablet", "staticAppendTextDelay", [_text ARG 0.1], _clientOwner, false);
				} else {
					pr _text = format ["  Current order: %1" + _endl, _actionName];
					REMOTE_EXEC_CALL_STATIC_METHOD("TacticalTablet", "staticAppendTextDelay", [_text ARG 0.1], _clientOwner, false);
				};

				if (!isNil "_posSrc") then {
					pr _text = format ["Departure from %1, at date %2" + _endl, mapGridPosition _posSrc, _dateDeparture call misc_fnc_dateToISO8601];
					REMOTE_EXEC_CALL_STATIC_METHOD("TacticalTablet", "staticAppendTextDelay", [_text ARG 0.1], _clientOwner, false);
				};
			} else {
				OOP_ERROR_1("Invalid personal intel ref: %1", _intelPersonal);
			};
		} else {
			pr _text = format [_endl + "  Current order: none" + _endl];
			REMOTE_EXEC_CALL_STATIC_METHOD("TacticalTablet", "staticAppendTextDelay", [_text ARG 0.1], _clientOwner, false);
		};

		// Process the intel about other intel items known to the garrison
		pr _intelGeneralUnique = _intelGeneral - [_intelPersonal]; // We don't want to process known intel
		if (count _intelGeneralUnique > 0) then {

			pr _text = "  Friendly squad orders:" + _endl;
			REMOTE_EXEC_CALL_STATIC_METHOD("TacticalTablet", "staticAppendTextDelay", [_text ARG 0], _clientOwner, false);

			{
				pr _intel = _x;
				if (!IS_NULL_OBJECT(_intel)) then {
					if (IS_OOP_OBJECT(_intel)) then {

						// Add to our db if needed
						if (_itemSide != _side) then {
							T_CALLM1("inspectIntel", _intel);
						};

						// Process what to show on the remote player's tablet
						pr _actionName = CALLM0(_intel, "getShortName");
						pr _dateDeparture = GETV(_intel, "dateDeparture");
						pr _posSrc = GETV(_intel, "posSrc");
						pr _posTgt = GETV(_intel, "posTgt");

						pr _text = _actionName;
						if (!isNil "_posSrc") then {
							_text = _text + format [" from %1", mapGridPosition _posSrc];
						};

						if (!isNil "_posTgt") then {
							_text = _text + format [" to %1", mapGridPosition _posTgt];
						};

						if (!isNil "_dateDeparture") then {
							_text = _text + format [" at date %1", _dateDeparture call misc_fnc_dateToISO8601];
						};

						_text = _text + _endl;
						REMOTE_EXEC_CALL_STATIC_METHOD("TacticalTablet", "staticAppendTextDelay", [_text ARG 0.1 + (random 0.1)], _clientOwner, false);

					} else {
						OOP_ERROR_1("Invalid general intel ref: %1", _intelPersonal);
					};
				}
			} forEach (_intelGeneral - [_intelPersonal]);
		};

		// Process locations known by this garrison
		if (count _locs > 0) then {
			pr _text = "  Friendly stationary forces:" + _endl;
			REMOTE_EXEC_CALL_STATIC_METHOD("TacticalTablet", "staticAppendTextDelay", [_text ARG 0.2], _clientOwner, false);
			{
				pr _loc = _x;

				// Update location data, maximum precision
				if (_itemSide != _side) then {
					T_CALLM2("updateLocationData", _x, CLD_UPDATE_LEVEL_UNITS);
				};

				// Show stuff on the tablet
				pr _type = CALLM0(_loc, "getType");
				pr _typeStr = CALLSM1("Location", "getTypeString", _type);
				pr _pos = CALLM0(_loc, "getPos");
				pr _text = format ["Grid %1: %2 %3" + _endl, mapGridPosition _pos, _typeStr, CALLM0(_loc, "getName")];
				REMOTE_EXEC_CALL_STATIC_METHOD("TacticalTablet", "staticAppendTextDelay", [_text ARG 0.1 + (random 0.1)], _clientOwner, false);
			} forEach _locs;
		};

		if (_itemSide != _side) then {
			pr _text = _endl + "Retinal scan identity mismatch! Device is locked." + _endl;
			REMOTE_EXEC_CALL_STATIC_METHOD("TacticalTablet", "staticAppendTextDelay", [_text ARG 0], _clientOwner, false);
		};

		// =========== Bail out for now =========
		// ! ! ! ! Some legacy code below ! ! ! !
		if (true) exitWith {};

		// Make sure _data is valid
		pr _foundSomething = false;
		if (_dataIsNotNil) then {
			if (count _data > 0) then {
				_foundSomething = true;
			};
		};

		OOP_INFO_1("   found something: %1", _foundSomething);

		pr _thisDB = T_GETV("intelDB");
		pr _addedSomething = false;
		if (_foundSomething) then {
			{
				pr _item = _x;
				OOP_INFO_1("   Stealing intel item: %1", _item);

				// Make sure the intel object is valid
				if (IS_OOP_OBJECT(_item)) then {
					if (CALLM1(_thisDB, "isIntelAddedFromSource", _item)) then {
						// Update it from source
						CALLM1(_thisDB, "updateIntelFromSource", _item);
						OOP_INFO_0("   updated intel from source");
					} else {
						// Clone it and it to our database
						pr _itemClone = CLONE(_item);
						SETV(_itemClone, "source", _item); // Link it with the source
						CALLM1(_thisDB, "addIntel", _itemClone);
						OOP_INFO_0("   added intel");
						_foundSomething = true;
					};
				} else {
					OOP_INFO_1("   Intel object is invalid: %1", _item);
				};
			} forEach _data;
		};

		if (_foundSomething) then {
			if (_addedSomething) then {
				"Some intel has been added!" remoteExecCall ["systemChat", _clientOwner];
			} else {
				"Some intel has been updated!" remoteExecCall ["systemChat", _clientOwner];
			};
		} else {
			"You have found nothing here!" remoteExecCall ["systemChat", _clientOwner];
		};

		// Reset this inventory item data
		CALLM3(gPersonalInventory, "setInventoryData", _baseClass, _ID, nil);
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
		
	// Thread unsafe
	METHOD("_addActivity") {
		params [P_THISOBJECT, P_POSITION("_pos"), P_NUMBER("_activity")];
		OOP_DEBUG_MSG("Adding %1 activity at %2 for side %3", [_activity ARG _pos ARG T_GETV("side")]);
		T_PRVAR(worldModel);
		CALLM(_worldModel, "addActivity", [_pos ARG _activity])
	} ENDMETHOD;

	METHOD("_addDamage") {
		params [P_THISOBJECT, P_POSITION("_pos"), P_NUMBER("_activity")];
		OOP_DEBUG_MSG("Adding %1 activity at %2 for side %3", [_activity ARG _pos ARG T_GETV("side")]);
		T_PRVAR(worldModel);
		CALLM(_worldModel, "addDamage", [_pos ARG _activity])
	} ENDMETHOD;

	// Thread safe
	STATIC_METHOD("addActivity") {
		params [P_THISCLASS, P_SIDE("_side"), P_POSITION("_pos"), P_NUMBER("_activity")];

		private _thisObject = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [_side]);
		if(!IS_NULL_OBJECT(_thisObject)) then {
			T_CALLM2("postMethodAsync", "_addActivity", [_pos ARG _activity]);
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
		REF(_gar);
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
			UNREF(_gar);
		} else {
			OOP_WARNING_MSG("Garrison %1 not registered so can't _unregisterGarrison", [_gar]);
		};
	} ENDMETHOD;
		
	/*
	Method: registerIntelCommanderAction
	Registers a piece of intel on an action that this Commander owns.
	Parameters:
	_intel - <IntelCommanderAction>
	
	Returns: clone of _intel item that can be used in further updateIntelFromClone operations.
	*/
	STATIC_METHOD("registerIntelCommanderAction") {
		params [P_THISCLASS, P_OOP_OBJECT("_intel")];
		ASSERT_OBJECT_CLASS(_intel, "IntelCommanderAction");
		private _side = GETV(_intel, "side");
		private _thisObject = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [_side]);

		T_PRVAR(intelDB);
		private _intelClone = CALLM(_intelDB, "addIntelClone", [_intel]);
		_intelClone
	} ENDMETHOD;

	/*
	Method: unregisterIntelCommanderAction
	
	*/
	STATIC_METHOD("unregisterIntelCommanderAction") {
		params [P_THISCLASS, P_OOP_OBJECT("_intel"), P_OOP_OBJECT("_intelClone")];

		OOP_INFO_2("UNREGISTER INTEL COMMANDER ACTION: intel: %1, intel clone: %2", _intel, _intelClone);

		ASSERT_OBJECT_CLASS(_intel, "IntelCommanderAction");
		private _side = GETV(_intel, "side");
		private _thisObject = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [_side]);
		// Notify enemy commanders that this intel has been destroyed
		private _enemySides = [WEST, EAST, INDEPENDENT] - [_side];
		{
			pr _enemySide = _x;
			private _AI = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [_enemySide]);
			private _db = GETV(_AI, "intelDB");
			// Check if this DB has an intel which has _intel as source
			if (CALLM1(_db, "isIntelAddedFromSource", _intel)) then {
				// The enemy commander has finished or aborted some task
				// Mark the intel in our database as END state
				// Then update it for everyone at this side _enemySide
				CALLM1(_db, "updateIntelFromSource", _intel);

				/*
				// Remove intel from source directly
				// We can do this without caring about thread safety because intelDB operations are atomic and thread safe
				CALLM1(_db, "removeIntel", _intelInDB);
				DELETE(_intelInDB);
				*/
			};
		} forEach _enemySides;
	} ENDMETHOD;

	// Some intel about our own action has changed, so we are going to notify enemies which have such intel about an update
	STATIC_METHOD("updateIntelCommanderActionForEnemies") {
		params [P_THISCLASS, P_OOP_OBJECT("_intel"), P_OOP_OBJECT("_intelClone")];

		OOP_INFO_2("UPDATE INTEL COMMANDER ACTION FOR ENEMIES: intel: %1, intel clone: %2", _intel, _intelClone);

		ASSERT_OBJECT_CLASS(_intel, "IntelCommanderAction");
		private _side = GETV(_intel, "side");
		private _thisObject = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [_side]);
		// Notify enemy commanders that this intel has been destroyed
		private _enemySides = [WEST, EAST, INDEPENDENT] - [_side];
		{
			pr _enemySide = _x;
			private _AI = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [_enemySide]);
			private _db = GETV(_AI, "intelDB");
			// Check if this DB has an intel which has _intel as source
			if (CALLM1(_db, "isIntelAddedFromSource", _intel)) then {
				// The enemy commander has updated intel about some task
				// Update it for everyone at this side _enemySide
				CALLM1(_db, "updateIntelFromSource", _intel);
			};
		} forEach _enemySides;
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
			CALLM0(_gar, "activate");
			CALLM2(_gar, "postMethodAsync", "setLocation", [_loc]);
			_activate = true;
			_gar
		};

		// Create some infantry group
		pr _group = NEW("Group", [_side ARG GROUP_TYPE_IDLE]);
		CALLM2(_group, "createUnitsFromTemplate", tGUERILLA, T_GROUP_inf_rifle_squad);
		CALLM2(_gar, "postMethodAsync", "addGroup", [_group]);

		// That's all!
	} ENDMETHOD;

/*


                                                                                           
       db         ,ad8888ba,  888888888888  88    ,ad8888ba,    888b      88   ad88888ba   
      d88b       d8"'    `"8b      88       88   d8"'    `"8b   8888b     88  d8"     "8b  
     d8'`8b     d8'                88       88  d8'        `8b  88 `8b    88  Y8,          
    d8'  `8b    88                 88       88  88          88  88  `8b   88  `Y8aaaaa,    
   d8YaaaaY8b   88                 88       88  88          88  88   `8b  88    `"""""8b,  
  d8""""""""8b  Y8,                88       88  Y8,        ,8P  88    `8b 88          `8b  
 d8'        `8b  Y8a.    .a8P      88       88   Y8a.    .a8P   88     `8888  Y8a     a8P  
d8'          `8b  `"Y8888Y"'       88       88    `"Y8888Y"'    88      `888   "Y88888P"   
                                                                                           
Methods for player commander to create new actions for garrisons

http://patorjk.com/software/taag/#p=display&f=Univers&t=ACTIONS
*/

	/*
	Method: resolveTarget
	Returns a <CmdrAITarget>

	Parameters: _targetType, _target

	_targetType - one of <AI.​CmdrAI.​CmdrAITarget.TARGET_TYPE>
	_target - position, garrison ref, location ref

	Returns: [TARGET_TYPE_POSITION, _pos], [TARGET_TYPE_LOCATION, _locID], [TARGET_TYPE_GARRISON, _garrID]
	*/
	METHOD("resolveTarget") {
		params [P_THISOBJECT, P_NUMBER("_targetType"), ["_target", [], [[], ""] ]];

		T_PRVAR(worldModel);

		pr _allResolved = true;
		pr _targetOut = switch (_targetType) do {
			case TARGET_TYPE_GARRISON: {
				// Resolve the target garrison model
				pr _garModel = CALLM1(_worldModel, "findGarrisonByActual", _target);
				if (IS_NULL_OBJECT(_garModel)) then {
					OOP_ERROR_1("No model of location %1", _target);
					_allResolved = false;
				} else {
					GETV(_garModel, "id")
				};
			};
			case TARGET_TYPE_LOCATION: {
				// Resolve the location model
				pr _locModel = CALLM1(_worldModel, "findLocationByActual", _target);
				if (IS_NULL_OBJECT(_locModel)) then {
					OOP_ERROR_1("No model of location %1", _target);
					_allResolved = false;
				} else {
					GETV(_locModel, "id")
				};
			};
			case TARGET_TYPE_POSITION: {
				// Make sure it at least has two elements inside
				if (count _target < 2) then {
					OOP_ERROR_1("Wrong target position: %1", _target);
					_allResolved = false;
				} else {	
					_target // It's position already
				};
			};
			case TARGET_TYPE_CLUSTER: {
				// Not supported (yet?)
				_allResolved = false;
				0
			};
			default {
				// What the hell is this??
				OOP_ERROR_1("Wrong target type: %1", _targetType);
				_allResolved = false;
				0
			};
		};

		if (_allResolved) then {
			[_targetType, _targetOut]
		} else {
			[]
		};

	} ENDMETHOD;

	// Call it through postMethodAsync !
	METHOD("clientCreateMoveAction") {
		params [P_THISOBJECT, P_STRING("_garRef"), P_NUMBER("_targetType"), ["_target", [], [[], ""] ] ];

		ASSERT_THREAD(_thisObject); // Respect my threading!

		T_CALLM4("_clientCreateGarrisonAction", _garRef, _targetType, _target, "DirectMoveCmdrAction");
	} ENDMETHOD;

	METHOD("clientCreateReinforceAction") {
		params [P_THISOBJECT, P_STRING("_garRef"), P_NUMBER("_targetType"), ["_target", [], [[], ""] ] ];

		ASSERT_THREAD(_thisObject); // Respect my threading!

		T_CALLM4("_clientCreateGarrisonAction", _garRef, _targetType, _target, "DirectReinforceCmdrAction");
	} ENDMETHOD;

	METHOD("clientCreateAttackAction") {
		params [P_THISOBJECT, P_STRING("_garRef"), P_NUMBER("_targetType"), ["_target", [], [[], ""] ] ];

		ASSERT_THREAD(_thisObject); // Respect my threading!

		T_CALLM4("_clientCreateGarrisonAction", _garRef, _targetType, _target, "DirectAttackCmdrAction");
	} ENDMETHOD;

	// Thread unsafe, private
	METHOD("_clientCreateGarrisonAction") {
		params [P_THISOBJECT, P_STRING("_garRef"), P_NUMBER("_targetType"), ["_target", [], [[], ""] ], ["_actionName", "", [""]]];

		OOP_INFO_1("CLIENT CREATE GARRISON ACTION: %1", _this);

		// Get the garrison model associated with this _garRef
		T_PRVAR(worldModel);
		pr _garModel = CALLM1(_worldModel, "findGarrisonByActual", _garRef);
		if (IS_NULL_OBJECT(_garModel)) exitWith {
			OOP_ERROR_1("createMoveAction: No model of garrison %1", _garRef);
		};

		// Resolve the destination position
		pr _cmdrTarget = T_CALLM2("resolveTarget", _targetType, _target);

		// Bail if we couldn't resolve something
		if (_cmdrTarget isEqualTo []) exitWith {
			OOP_ERROR_1("Couldn't resolve target: %1", _this);
		};

		// So far all parameters are good, let's go on ...

		// Cancel previously given action
		T_CALLM1("clearAndCancelGarrisonAction", _garModel);

		// Create a new action
		pr _args = [GETV(_garModel, "id"), _cmdrTarget]; // id, target, radius
		pr _action = NEW(_actionName, _args);
		T_GETV("activeActions") pushBack _action;

		// Don't waste time, update the action ASAP!
		CALLM1(_action, "update", _worldModel);
	} ENDMETHOD;

	// Gets called from client to cancel the current order this garrison is doing
	METHOD("cancelCurrentAction") {
		params [P_THISOBJECT, P_STRING("_garRef") ];

		ASSERT_THREAD(_thisObject); // Respect my threading!

		// Get the garrison model associated with this _garRef
		T_PRVAR(worldModel);
		pr _garModel = CALLM1(_worldModel, "findGarrisonByActual", _garRef);
		if (IS_NULL_OBJECT(_garModel)) exitWith {
			OOP_ERROR_1("createMoveAction: No model of garrison %1", _garRef);
		};

		// Cancel previously given action
		T_CALLM1("clearAndCancelGarrisonAction", _garModel);
	} ENDMETHOD;


	// Gets called remotely from player's 'split garrison' dialog
	METHOD("splitGarrisonFromComposition") {
		PARAMS[P_THISOBJECT, P_STRING("_garSrcRef"), P_ARRAY("_comp"), P_NUMBER("_clientOwner")];

		ASSERT_THREAD(_thisObject);

		// Get the garrison model associated with this _garSrcRef
		T_PRVAR(worldModel);
		pr _garModel = CALLM1(_worldModel, "findGarrisonByActual", _garSrcRef);
		if (IS_NULL_OBJECT(_garModel)) exitWith {
			OOP_ERROR_1("splitGarrisonFromComposition: No model of garrison %1", _garSrcRef);
			// send data back to client owner...
			REMOTE_EXEC_CALL_STATIC_METHOD("GarrisonSplitDialog", "sendServerResponse", [11], _clientOwner, false); // REMOTE_EXEC_CALL_STATIC_METHOD(classNameStr, methodNameStr, extraParams, targets, JIP)
		};

		// Create a new garrison
		pr _pos = CALLM0(_garSrcRef, "getPos");
		pr _faction = CALLM(_garSrcRef, "getFaction", []);
		pr _posNew = _pos getPos [50, random 360]; // We don't want them to be too much clustered at teh same place
		pr _newGarr = NEW("Garrison", [T_GETV("side") ARG _posNew ARG _faction]);

		// Move units
		pr _numUnfoundUnits = CALLM2(_newGarr, "postMethodSync", "addUnitsFromComposition", [_garSrcRef ARG _comp]);

		// Activate the new garrison
		// it will register itself here as well
		CALLM0(_newGarr, "activate");

		// Send data back to client
		REMOTE_EXEC_CALL_STATIC_METHOD("GarrisonSplitDialog", "sendServerResponse", [22], _clientOwner, false);

	} ENDMETHOD;

	METHOD("clientCreateLocation") {
		params [P_THISOBJECT, P_NUMBER("_clientOwner"), P_POSITION("_posWorld"), P_STRING("_locType"), P_STRING("_locName")];

		// Nullify vertical component, we use position ATL for locations anyway
		pr _pos = +_posWorld;
		_pos set [2, 0];

		// Make sure the position is not very close to an existing location
		pr _locsNear = CALLSM2("Location", "nearLocations", _pos, 50);
		pr _index = _locsNear findIf {
			T_CALLM1("getIntelAboutLocation", _x) != ""
		};
		if (_index != -1) exitWith {
			pr _args = ["We can't create a location so close to another location!"];
			REMOTE_EXEC_CALL_STATIC_METHOD("InGameMenuTabCommander", "showServerResponse", _args, _clientOwner, false);
		};

		// Create a little composition at this place
		[_posWorld] call misc_fnc_createCampComposition;

		// Create the location
		pr _loc = NEW_PUBLIC("Location", [_pos]);
		CALLM2(_loc, "setBorder", "circle", 50);
		CALLM1(_loc, "setType", _locType);
		CALLM1(_loc, "setName", _locName);
		CALLM2(_loc, "processObjectsInArea", "House", true);
		CALLM1(gGameMode, "initLocationGameModeData", _loc);


		// Create the garrison
		pr _gar = NEW("Garrison", [T_GETV("side") ARG _pos]);
		CALLM2(_gar, "postMethodSync", "setLocation", [_loc]);
		CALLM0(_gar, "activate");

		// Update intel about the location
		T_CALLM1("updateLocationData", _loc);

		pr _args = ["We have successfully created a location here!"];
		REMOTE_EXEC_CALL_STATIC_METHOD("InGameMenuTabCommander", "showServerResponse", _args, _clientOwner, false);
		
	} ENDMETHOD;

/*
  ,ad8888ba,   88b           d88  88888888ba,    88888888ba             db         88  
 d8"'    `"8b  888b         d888  88      `"8b   88      "8b           d88b        88  
d8'            88`8b       d8'88  88        `8b  88      ,8P          d8'`8b       88  
88             88 `8b     d8' 88  88         88  88aaaaaa8P'         d8'  `8b      88  
88             88  `8b   d8'  88  88         88  88""""88'          d8YaaaaY8b     88  
Y8,            88   `8b d8'   88  88         8P  88    `8b         d8""""""""8b    88  
 Y8a.    .a8P  88    `888'    88  88      .a8P   88     `8b       d8'        `8b   88  
  `"Y8888Y"'   88     `8'     88  88888888Y"'    88      `8b     d8'          `8b  88  

Methods ported from CmdrAI made by Bill
and methods associated with actions, planning, ASTs, etc...

http://patorjk.com/software/taag/#p=display&f=Univers&t=CMDR%20AI                                               
*/


	/*
	Method: plan
	Do a planning cycle. What action types are considered at each cycle depends on priorities and rates defined.
	
	Parameters:
		_world - <Model.WorldModel>, real world model (see <Model.WorldModel> or <WORLD_TYPE> for details) the actions should apply to.
	*/
	METHOD("plan") {
		params [P_THISOBJECT, P_OOP_OBJECT("_world")];
		
		T_PRVAR(planningCycle);
		T_SETV("planningCycle", _planningCycle + 1);

		private _priority = switch true do {
			case (round (_planningCycle mod CMDR_PLANNING_RATIO_HIGH) == 0): { CMDR_PLANNING_PRIORITY_HIGH };
			case (round (_planningCycle mod CMDR_PLANNING_RATIO_NORMAL) == 0): { CMDR_PLANNING_PRIORITY_NORMAL };
			case (round (_planningCycle mod CMDR_PLANNING_RATIO_LOW) == 0): { CMDR_PLANNING_PRIORITY_LOW };
			default { -1 };
		};

		if(_priority != -1) then {
			T_CALLM("_plan", [_world ARG _priority]);
		};
	} ENDMETHOD;
	
	/*
	Method: update
	Update active actions.
	
	Parameters:
		_world - <Model.WorldModel>, real world model the actions are being performed in.
	*/
	METHOD("update") {
		params [P_THISOBJECT, P_OOP_OBJECT("_world")];

		// Sync before update
		CALLM(_world, "sync", []);

		T_PRVAR(side);
		T_PRVAR(activeActions);

		OOP_DEBUG_MSG("- - - - - U P D A T I N G - - - - -   on %1 active actions", [count _activeActions]);

		// Update actions in real world
		{ 
			OOP_DEBUG_MSG("Updating action %1", [_x]);
			CALLM(_x, "update", [_world]);
		} forEach _activeActions;

		// Remove complete actions
		{ 
			OOP_DEBUG_MSG("Completed action %1, removing", [_x]);
			_activeActions deleteAt (_activeActions find _x);
			UNREF(_x);
		} forEach (_activeActions select { CALLM(_x, "isComplete", []) });

		OOP_DEBUG_MSG("- - - - - U P D A T I N G   D O N E - - - - -", []);

		#ifdef OOP_INFO
		private _str = format ["{""cmdrai"": {""side"": ""%1"", ""active_actions"": %2}}", _side, count _activeActions];
		OOP_INFO_MSG(_str, []);
		#endif
	} ENDMETHOD;
	
	/*
	Method: (private) generateAttackActions
	Generate a list of possible/reasonable attack actions that could be performed. It will exclude ones that 
	are impossible or impractical. Otherwise scoring of the actions should be used to determine if they should
	be used.
	
	Parameters:
		_worldNow - <Model.WorldModel>, now sim world (see <Model.WorldModel> for details)
		_worldFuture - <Model.WorldModel>, now sim world (see <Model.WorldModel> for details)

	Returns: Array of <CmdrAction.Actions.QRFCmdrAction>
	*/
	/* private */ METHOD("generateAttackActions") {
		params [P_THISOBJECT, P_OOP_OBJECT("_worldNow"), P_OOP_OBJECT("_worldFuture")];
		T_PRVAR(side);

		private _srcGarrisons = CALLM(_worldNow, "getAliveGarrisons", []) select { 
			// Must be on our side and not involved in another action
			// TODO: We should be able to redirect for QRFs. Perhaps it 
			if((GETV(_x, "side") != _side) or { CALLM(_x, "isBusy", []) }) then {
				false
			} else {
				// Not involved in another reinforce action
				//private _action = CALLM(_x, "getAction", []);
				//if(!IS_NULL_OBJECT(_action) and { OBJECT_PARENT_CLASS_STR(_action) == "ReinforceCmdrAction" }) exitWith {false};

				private _overDesiredEff = CALLM(_worldNow, "getOverDesiredEff", [_x]);

				// Must have at least a minimum strength of twice min efficiency
				//private _eff = GETV(_x, "efficiency");
				// !CALLM(_x, "isDepleted", []) and 
				EFF_GTE(_overDesiredEff, EFF_MIN_EFF)
			}
		};

		// Candidates are clusters that are still alive in the future.
		private _tgtClusters = CALLM(_worldFuture, "getAliveClusters", []);

		private _actions = [];
		{
			private _srcId = GETV(_x, "id");
			{
				private _params = [_srcId, GETV(_x, "id")];
				_actions pushBack (NEW("QRFCmdrAction", _params));
			} forEach _tgtClusters;
		} forEach _srcGarrisons;

		//OOP_INFO_MSG("Considering %1 QRF actions from %2 garrisons to %3 clusters", [count _actions ARG count _srcGarrisons ARG count _tgtClusters]);
		#ifdef OOP_INFO
		private _str = format ["{""cmdrai"": {""side"": ""%1"", ""action_name"": ""QRF"", ""potential_action_count"": %2, ""src_garrisons"": %3, ""tgt_clusters"": %4}}", _side, count _actions, count _srcGarrisons, count _tgtClusters];
		OOP_INFO_MSG(_str, []);
		#endif

		_actions
	} ENDMETHOD;

	/*
	Method: (private) generateReinforceActions
	Generate a list of possible/reasonable reinforcement actions that could be performed. It will exclude ones that 
	are impossible or impractical. Otherwise scoring of the actions should be used to determine if they should
	be used.
	
	Parameters:
		_worldNow - <Model.WorldModel>, now sim world (see <Model.WorldModel> for details)
		_worldFuture - <Model.WorldModel>, now sim world (see <Model.WorldModel> for details)

	Returns: Array of <CmdrAction.Actions.ReinforceCmdrAction>
	*/
	/* private */ METHOD("generateReinforceActions") {
		params [P_THISOBJECT, P_OOP_OBJECT("_worldNow"), P_OOP_OBJECT("_worldFuture")];
		T_PRVAR(side);

		// Limit amount of concurrent actions
		T_PRVAR(activeActions);
		pr _count = {GET_OBJECT_CLASS(_x) == "ReinforceCmdrAction"} count _activeActions;
		if (_count > 2) exitWith {[]};

		// Take src garrisons from now, we don't want to consider future resource availability, only current.
		private _srcGarrisons = CALLM(_worldNow, "getAliveGarrisons", []) select { 
			// Must be on our side and not involved in another action
			GETV(_x, "side") == _side and 
			{ !CALLM(_x, "isBusy", []) } and
			{
				// Not involved in another reinforce action
				//private _action = CALLM(_x, "getAction", []);
				//if(!IS_NULL_OBJECT(_action) and { OBJECT_PARENT_CLASS_STR(_action) == "ReinforceCmdrAction" }) exitWith {false};

				private _overDesiredEff = CALLM(_worldNow, "getOverDesiredEff", [_x]);

				// Must have at least a minimum strength of twice min efficiency
				//private _eff = GETV(_x, "efficiency");
				// !CALLM(_x, "isDepleted", []) and 
				EFF_GTE(_overDesiredEff, EFF_MIN_EFF)
			}
		};

		// Take tgt garrisons from future, so we take into account all in progress reinforcement actions.
		private _tgtGarrisons = CALLM(_worldFuture, "getAliveGarrisons", []) select { 
			// Must be on our side
			GETV(_x, "side") == _side and 
			{
				// Not involved in another reinforce action
				private _action = CALLM(_x, "getAction", []);
				IS_NULL_OBJECT(_action) or { OBJECT_PARENT_CLASS_STR(_action) != "ReinforceCmdrAction" }
			} and 
			{
				// Must be under desired efficiency by at least min reinforcement size
				// private _eff = GETV(_x, "efficiency");
				private _overDesiredEff = CALLM(_worldFuture, "getOverDesiredEff", [_x]);
				!EFF_GT(_overDesiredEff, EFF_MUL_SCALAR(EFF_MIN_EFF, -1))
			}
		};

		private _actions = [];
		{
			private _srcId = GETV(_x, "id");
			private _srcFac = GETV(_x, "faction");
			//private _srcPos = GETV(_x, "pos");
			{
				private _tgtId = GETV(_x, "id");
				private _tgtFac = GETV(_x, "faction");
				//private _tgtPos = GETV(_x, "pos");
				if(_srcId != _tgtId 
					and {_srcFac == _tgtFac}
					// and {_srcPos distance _tgtPos < REINF_MAX_DIST}
					) then {
					private _params = [_srcId, _tgtId];
					_actions pushBack (NEW("ReinforceCmdrAction", _params));
				};
			} forEach _tgtGarrisons;
		} forEach _srcGarrisons;

		OOP_INFO_MSG("Considering %1 Reinforce actions from %2 garrisons to %3 garrisons", [count _actions ARG count _srcGarrisons ARG count _tgtGarrisons]);

		#ifdef OOP_INFO
		private _str = format ["{""cmdrai"": {""side"": ""%1"", ""action_name"": ""Reinforce"", ""potential_action_count"": %2, ""src_garrisons"": %3, ""tgt_garrisons"": %4}}", _side, count _actions, count _srcGarrisons, count _tgtGarrisons];
		OOP_INFO_MSG(_str, []);
		#endif

		_actions
	} ENDMETHOD;

	/*
	Method: (private) generateTakeOutpostActions
	Generate a list of possible/reasonable take outpost actions that could be performed. It will exclude ones that 
	are impossible or impractical. Otherwise scoring of the actions should be used to determine if they should
	be used.
	
	Parameters:
		_worldNow - <Model.WorldModel>, now sim world (see <Model.WorldModel> for details)
		_worldFuture - <Model.WorldModel>, now sim world (see <Model.WorldModel> for details)

	Returns: Array of <CmdrAction.Actions.TakeLocationCmdrAction>
	*/
	/* private */ METHOD("generateTakeOutpostActions") {
		params [P_THISOBJECT, P_OOP_OBJECT("_worldNow"), P_OOP_OBJECT("_worldFuture")];
		T_PRVAR(activeActions);
		T_PRVAR(side);

		// Limit amount of concurrent actions
		T_PRVAR(activeActions);
		pr _count = {GET_OBJECT_CLASS(_x) == "TakeLocationCmdrAction"} count _activeActions;
		if (_count > 2) exitWith {[]};

		// Take src garrisons from now, we don't want to consider future resource availability, only current.
		private _srcGarrisons = CALLM(_worldNow, "getAliveGarrisons", [["military"]]) select { 
			private _potentialSrcGarr = _x;
			// Must be not already busy 
			!CALLM(_potentialSrcGarr, "isBusy", []) and 
			// Must be at a location
			{ !IS_NULL_OBJECT(CALLM(_potentialSrcGarr, "getLocation", [])) } and 
			// Must not be source of another inprogress take location mission
			{ 
				T_PRVAR(activeActions);
				_activeActions findIf {
					GET_OBJECT_CLASS(_x) == "TakeLocationCmdrAction" and
					{ GETV(_x, "srcGarrId") == GETV(_potentialSrcGarr, "id") }
				} == NOT_FOUND
			} and
			// Must have minimum efficiency available
			{
				private _overDesiredEff = CALLM(_worldNow, "getOverDesiredEff", [_potentialSrcGarr]);
				// Must have at least a minimum available eff
				EFF_GTE(_overDesiredEff, EFF_MIN_EFF)
			}
		};

		// Take tgt locations from future, so we take into account all in progress actions.
		private _tgtLocations = CALLM(_worldFuture, "getLocations", []) select { 
			// Must not have any of our garrisons already present (or this would be reinforcement action)
			IS_NULL_OBJECT(CALLM(_x, "getGarrison", [_side]))
		};

		private _actions = [];
		{
			private _srcId = GETV(_x, "id");
			private _srcPos = GETV(_x, "pos");
			{
				private _tgtId = GETV(_x, "id");
				private _tgtPos = GETV(_x, "pos");
				private _tgtType = GETV(_x, "type");
				private _dist = _srcPos distance _tgtPos;
				if((_tgtType == LOCATION_TYPE_ROADBLOCK and _dist < 3000) or (_tgtType != LOCATION_TYPE_ROADBLOCK and _dist < 10000)) then {
					private _params = [_srcId, _tgtId];
					_actions pushBack (NEW("TakeLocationCmdrAction", _params));
				};
			} forEach _tgtLocations;
		} forEach _srcGarrisons;

		OOP_INFO_MSG("Considering %1 TakeOutpost actions from %2 garrisons to %3 locations", [count _actions ARG count _srcGarrisons ARG count _tgtLocations]);

		#ifdef OOP_INFO
		private _str = format ["{""cmdrai"": {""side"": ""%1"", ""action_name"": ""TakeOutpost"", ""potential_action_count"": %2, ""src_garrisons"": %3, ""tgt_locations"": %4}}", _side, count _actions, count _srcGarrisons, count _tgtLocations];
		OOP_INFO_MSG(_str, []);
		#endif

		_actions
	} ENDMETHOD;

	/*
	Method: (private) generatePatrolActions
	Generate a list of possible/reasonable patrol actions that could be performed. It will exclude ones that 
	are impossible or impractical. Otherwise scoring of the actions should be used to determine if they should
	be used.
	
	Parameters:
		_worldNow - <Model.WorldModel>, now sim world (see <Model.WorldModel> for details)
		_worldFuture - <Model.WorldModel>, now sim world (see <Model.WorldModel> for details)

	Returns: Array of <CmdrAction.Actions.PatrolCmdrAction>
	*/
	/* private */ METHOD("generatePatrolActions") {
		params [P_THISOBJECT, P_OOP_OBJECT("_worldNow"), P_OOP_OBJECT("_worldFuture")];
		T_PRVAR(activeActions);
		T_PRVAR(side);

		//OOP_INFO_0("GENERATE PATROL ACTIONS");

		// Limit amount of concurrent actions
		T_PRVAR(activeActions);
		pr _count = {GET_OBJECT_CLASS(_x) == "PatrolCmdrAction"} count _activeActions;
		//OOP_INFO_1("  Existing patrol actions: %1", _count);
		if (_count > 6) exitWith {[]};

		// Take src garrisons from now, we don't want to consider future resource availability, only current.
		private _srcGarrisons = CALLM(_worldNow, "getAliveGarrisons", [["military" ARG "police"]]) select { 
			private _potentialSrcGarr = _x;

			// Must be not already busy 
			!CALLM(_potentialSrcGarr, "isBusy", []) and 
			// Must be at a location
			{ 
				private _loc = CALLM(_potentialSrcGarr, "getLocation", []);
				!IS_NULL_OBJECT(_loc) and 
				{
					GETV(_loc, "type") in [LOCATION_TYPE_OUTPOST, LOCATION_TYPE_BASE]
				}
			} and 
			// Must not be source of another inprogress patrol mission
			{ 
				T_PRVAR(activeActions);
				_activeActions findIf {
					GET_OBJECT_CLASS(_x) == "PatrolCmdrAction" and
					{ GETV(_x, "srcGarrId") == GETV(_potentialSrcGarr, "id") }
				} == NOT_FOUND
			} and
			// Must have minimum patrol available
			{
				private _overEff = GETV(_potentialSrcGarr, "efficiency") - EFF_MIN_EFF;
				// CALLM(_worldNow, "getOverDesiredEff", [_potentialSrcGarr]);
				// Must have at least a minimum available eff
				EFF_GTE(_overEff, EFF_MIN_EFF)
			}
		};

		private _actions = [];
		{
			private _srcId = GETV(_x, "id");
			private _srcPos = GETV(_x, "pos");

			// Take tgt locations from future, so we take into account all in progress actions.
			private _tgtLocations = CALLM(_worldNow, "getNearestLocations", [_srcPos ARG 2000 ARG [LOCATION_TYPE_CITY]]) apply { 
				_x params ["_dist", "_loc"];
				[_srcPos getDir GETV(_loc, "pos"), GETV(_loc, "id")]
			};
			if(count _tgtLocations > 0) then {
				_tgtLocations sort ASCENDING;
				private _routeTargets = _tgtLocations apply {
					_x params ["_dir", "_locId"];
					[TARGET_TYPE_LOCATION, _locId]
				};
				private _params = [_srcId, _routeTargets];
				_actions pushBack (NEW("PatrolCmdrAction", _params));
			};
		} forEach _srcGarrisons;

		OOP_INFO_MSG("Considering %1 Patrol actions from %2 garrisons", [count _actions ARG count _srcGarrisons]);

		#ifdef OOP_INFO
		private _str = format ["{""cmdrai"": {""side"": ""%1"", ""action_name"": ""Patrol"", ""potential_action_count"": %2, ""src_garrisons"": %3}}", _side, count _actions, count _srcGarrisons];
		OOP_INFO_MSG(_str, []);
		#endif

		_actions
	} ENDMETHOD;

	/*
	Method: (private) selectActions
	Generate and select new actions to add to the plan.
	
	Parameters:
		_actionFuncs - Array of strings, member functions of <CmdrAI> that generate actions that should be used.
		_maxNewActions - Number, max new actions to add to the plan.
		_world - <Model.WorldModel>, real world model (see <Model.WorldModel> or <WORLD_TYPE> for details).
		_simWorldNow - <Model.WorldModel>, now world model (see <Model.WorldModel> or <WORLD_TYPE> for details).
		_simWorldFuture - <Model.WorldModel>, future world model (see <Model.WorldModel> or <WORLD_TYPE> for details).
	*/
	/* private */ METHOD("selectActions") {
		params [P_THISOBJECT, P_ARRAY("_actionFuncs"), P_NUMBER("_maxNewActions"), P_OOP_OBJECT("_world"), P_OOP_OBJECT("_simWorldNow"), P_OOP_OBJECT("_simWorldFuture")];

		CALLM(_simWorldNow, "resetScoringCache", []);
		CALLM(_simWorldFuture, "resetScoringCache", []);

		private _newActions = [];

		{
			_newActions = _newActions + T_CALLM(_x, [_simWorldNow ARG _simWorldFuture]);
		} forEach _actionFuncs;

		private _newActionCount = 0;
		while {(count _newActions > 0) and _newActionCount < _maxNewActions} do {

			OOP_DEBUG_MSG("Updating scoring for %1 new actions", [count _newActions]);
			PROFILE_SCOPE_START(UpdateScores)

			// Update scores of potential actions against the simworld state
			{
				CALLM(_x, "updateScore", [_simWorldNow ARG _simWorldFuture]);
			} forEach _newActions;

			PROFILE_SCOPE_END(UpdateScores, 0.1);

			// Sort the actions by their scores
			private _scoresAndActions = _newActions apply { 
				private _finalScore = CALLM(_x, "getFinalScore", []);
				[_finalScore, _x] 
			};

			_scoresAndActions sort DESCENDING;

			// _newActions = [_newActions, [], { CALLM(_x, "getFinalScore", []) }, "DECEND"] call BIS_fnc_sortBy;

			// Get the best scoring action
			(_scoresAndActions select 0) params ["_bestActionScore", "_bestAction"];

			// private _bestActionScore = // CALLM(_bestAction, "getFinalScore", []);
			
			// Some sort of cut off needed here, probably needs tweaking, or should be strategy based?
			// TODO: Should we maybe be normalizing scores between 0 and 1?
			if(_bestActionScore <= ACTION_SCORE_CUTOFF) exitWith {};

			OOP_DEBUG_MSG("Selected new action %1 (score %2), applying it to the simworlds", [_bestAction ARG _bestActionScore]);

			// Add the best action to our active actions list
			REF(_bestAction);

			T_PRVAR(activeActions);
			_activeActions pushBack _bestAction;

			// Remove it from the possible actions list
			_newActions deleteAt (_newActions find _bestAction);

			PROFILE_SCOPE_START(ApplyNewActionToSim);

			// Apply the new action effects to simworld, so next loop scores update appropriately
			// (e.g. if we just accepted a new reinforce action, we should update the source and target garrison
			// models in the sim so that other reinforce actions will take it into account in their scoring.
			// Probably other reinforce actions with the same source or target would have lower scores now).
			CALLM(_bestAction, "applyToSim", [_simWorldNow]);
			CALLM(_bestAction, "applyToSim", [_simWorldFuture]);

			PROFILE_SCOPE_END(ApplyNewActionToSim, 0.1);

			_newActionCount = _newActionCount + 1;
		};

		// Delete any remaining discarded actions
		{
			DELETE(_x);
		} forEach _newActions;
	} ENDMETHOD;

	/*
	Method: (private) _plan
	Planning implementation, once priority to plan at has been determined.
	
	Parameters:
		_world - <Model.WorldModel>, real world model (see <Model.WorldModel> or <WORLD_TYPE> for details) the actions should apply to.
		_priority - Number, the priority of action types that should be considered.
	*/
	/* private */ METHOD("_plan") {
		params [P_THISOBJECT, P_OOP_OBJECT("_world"), P_NUMBER("_priority")];

		OOP_DEBUG_MSG("- - - - - P L A N N I N G (priority %1) - - - - -", [_priority]);

		// Sync before planning
		CALLM(_world, "sync", []);
		// Update grids etc.
		CALLM(_world, "update", []);

		T_PRVAR(activeActions);

		OOP_DEBUG_MSG("Creating new simworlds from %1", [_world]);

		// Copy world to simworld, now and future
		private _simWorldNow = CALLM(_world, "simCopy", [WORLD_TYPE_SIM_NOW]);
		private _simWorldFuture = CALLM(_world, "simCopy", [WORLD_TYPE_SIM_FUTURE]);

		OOP_DEBUG_MSG("Applying %1 active actions to simworlds", [count _activeActions]);

		// Apply effects of active actions to the simworld
		PROFILE_SCOPE_START(ApplyActive);
		{
			CALLM(_x, "applyToSim", [_simWorldNow]);
			CALLM(_x, "applyToSim", [_simWorldFuture]);
		} forEach _activeActions;
		PROFILE_SCOPE_END(ApplyActive, 0.1);

		OOP_DEBUG_MSG("Generating new actions", []);

		private _maxNewActions = 2;
		#ifndef CMDR_AI_TESTING
		private _generators = switch(_priority) do {
			case CMDR_PLANNING_PRIORITY_HIGH: {
				["generateAttackActions"]
			};
			case CMDR_PLANNING_PRIORITY_NORMAL: {
				["generateReinforceActions", "generatePatrolActions"]
			};
			case CMDR_PLANNING_PRIORITY_LOW: {
				["generateTakeOutpostActions"]
			};
		};
		#else
		// We will plan the shit ouf of this world model
		private _generators = ["generateAttackActions", "generateReinforceActions", "generatePatrolActions", "generateTakeOutpostActions"];
		#endif

		T_CALLM("selectActions", [_generators ARG _maxNewActions ARG _world ARG _simWorldNow ARG _simWorldFuture]);

		DELETE(_simWorldNow);
		DELETE(_simWorldFuture);

		OOP_DEBUG_MSG("- - - - - P L A N N I N G   D O N E - - - - -", []);
	} ENDMETHOD;

	/*
	Method: clearAndCancelGarrisonAction
	Clears action at the garrison model, terminates and deletes the action as well.

	Parameters: _garModel

	_garModel - the garrison model

	Returns: nil
	*/
	METHOD("clearAndCancelGarrisonAction") {
		params [P_THISOBJECT, P_OOP_OBJECT("_garModel")];

		pr _action = CALLM0(_garModel, "getAction");

		// Clear previously given action from the garrison
		// It doesn't termiante the actual action
		CALLM0(_garModel, "clearAction");
		
		if (!IS_NULL_OBJECT(_action)) then {
			// Cancel the action
			CALLM1(_action, "cancel", T_GETV("worldModel"));

			// Delete the action
			UNREF(_action);

			// Delete the action from our array of actions
			T_PRVAR(activeActions);
			_activeActions deleteAt (_activeActions find _action);
		};
	} ENDMETHOD;




	// = = = = = = = = = = = Radio = = = = = = = = = = = = =

	// Initializes the radio key grid
	METHOD("initRadioKeys") {
		params [P_THISOBJECT];

		if (!isNil {T_GETV("radioKeyGrid")}) exitWith {
			OOP_ERROR_0("Radio key grid is already initialized!");
		};

		// Create new grid object
		pr _cellSize = 5000;
		pr _grid = NEW("Grid", [_cellSize ARG "_error_"]);
		pr _gridSize = CALLM0(_grid, "getGridSize"); // Amount of cells in the grid
		
		// Initialize the grid with values
		for "_x" from 0 to (_gridSize - 1) do {
			for "_y" from 0 to (_gridSize - 1) do {
				pr _pos = [_x*_cellSize, _y*_cellSize];
				pr _key = CALLSM3("AICommander", "generateRadioKey", T_GETV("side"), _pos, _cellSize);
				CALLM2(_grid, "setValue", _pos, _key);
			};
		};

		T_SETV("radioKeyGrid", _grid);
	} ENDMETHOD;

	// Generates a random radio key for given position
	STATIC_METHOD("generateRadioKey") {
		params [P_THISCLASS, P_SIDE("_side"), P_POSITION("_pos"), P_NUMBER("_cellSize")];

		private _numdigits = 6;		// Amount of digits in the key code

		_pos params ["_px", "_py"];
		private _ix = floor (_px / _cellSize);
		private _iy = floor (_py / _cellSize);

		__numToStrZeroPad = {
			if (_this < 10) then {
				"0" + (str (floor _this))
			} else {
				str (floor _this)
			};
		};

		private _sideStr = switch (_side) do {
			case WEST: {"BLU"};
			case EAST: {"RED"};
			case INDEPENDENT: {"GREEN"};
			default {"CIV"};
		};

		private _str = format ["%1-%2-%3-", (_ix*_cellSize/1000) call __numToStrZeroPad, (_iy*_cellSize/1000) call __numToStrZeroPad, _sideStr];

		private _acc = 0;
		for "_i" from 0 to ((_numDigits-1)) do {
			_str = _str + str(floor random 10);
			_acc = _acc + 1;
			if (_acc == 3 && (_i != (_numDigits-1))) then {
				_str = _str + "-";
				_acc = 0;
			};
		};

		_str
	} ENDMETHOD;

	// Returns the radio key for given position
	METHOD("getRadioKey") {
		params [P_THISOBJECT, P_POSITION("_pos")];
		pr _grid = T_GETV("radioKeyGrid");
		CALLM1(_grid, "getValueSafe", _pos);
	} ENDMETHOD;

ENDCLASS;


#ifdef _SQF_VM

private _plans = [0,0,0,0];
for "_planningCycle" from 0 to 1000 do {
	private _priority = 0;
	switch true do {
		case (round (_planningCycle mod CMDR_PLANNING_RATIO_HIGH) == 0): { _priority = CMDR_PLANNING_PRIORITY_HIGH; };
		case (round (_planningCycle mod CMDR_PLANNING_RATIO_NORMAL) == 0): { _priority = CMDR_PLANNING_PRIORITY_NORMAL; };
		case (round (_planningCycle mod CMDR_PLANNING_RATIO_LOW) == 0): { _priority = CMDR_PLANNING_PRIORITY_LOW;  };
		default { _priority = 3; };
	};
	
	_plans set [_priority, (_plans#_priority) + 1];
};

// diag_log str _plans;
diag_log format (["Planning ratios: [%1 high, %2 normal, %3 low, %4 none]"] + (_plans apply { _x / 1000 }));
diag_log format (["Predicted planning intervals [%1s high, %2s normal, %3s low, %4s none]"] + (_plans apply { 10000 / _x }));

#endif