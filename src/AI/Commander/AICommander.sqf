#include "common.hpp"
FIX_LINE_NUMBERS()
// Class: AI.AICommander
// AI class for the commander.

// Author: Bill 2018 (CmdrAI logic, planning, world model, action generation, etc)
// Sparker 12.11.2018 (initial file)

// Ported from CmdrAI
#define ACTION_SCORE_CUTOFF 0.001
#define REINF_MAX_DIST 4000

#define PROCESS_INTERVAL 10

#define pr private

#define OOP_CLASS_NAME AICommander
CLASS("AICommander", "AI")

	/* save */	VARIABLE_ATTR("side", [ATTR_SAVE]);
	/* save */	VARIABLE_ATTR("msgLoop", [ATTR_SAVE]); // Message loops are restored on load as well
	/* save */	VARIABLE_ATTR("intelDB", [ATTR_SAVE]); // Intel database

	// Friendly garrisons we can access
	/* save */	VARIABLE_ATTR("garrisons", [ATTR_SAVE]);

	// Used by SensorCommanderTargets
	/* save */	VARIABLE_ATTR("targets", [ATTR_SAVE]);			// Array of targets known by this Commander
	/* save */	VARIABLE_ATTR("targetClusters", [ATTR_SAVE]);	// Array with target clusters
	/* save */	VARIABLE_ATTR("nextClusterID", [ATTR_SAVE]);	// A unique cluster ID generator
	
	VARIABLE_ATTR("cmdrStrategy", [ATTR_REFCOUNTED]);
	/* save */	VARIABLE_ATTR("cmdrStrategyClassSave", [ATTR_SAVE]);
	/* save */	VARIABLE_ATTR("worldModel", [ATTR_SAVE]);

	// External reinforcements
	/* save */ VARIABLE_ATTR("datePrevExtReinf", [ATTR_SAVE]);

	// Potential positions for new locations
	/* save */ VARIABLE_ATTR("newRoadblockPositions", [ATTR_SAVE]);

	// Will enable intel interception all the time
	VARIABLE("cheatIntelInterception");

	#ifdef DEBUG_CLUSTERS
	VARIABLE("nextMarkerID");
	VARIABLE("clusterMarkers");
	#endif

	#ifdef DEBUG_COMMANDER
	VARIABLE("state");
	VARIABLE("stateStart");
	#endif

	// Radio
	/* save */	VARIABLE_ATTR("radioKeyGrid", [ATTR_SAVE]); 	// Grid object which stores our own radio keys
	/* save */	VARIABLE_ATTR("enemyRadioKeys", [ATTR_SAVE]);	// Enemy radio keys we have found
	/* save */	VARIABLE_ATTR("enemyRadioKeysAddedBy", [ATTR_SAVE]); // List of player names who have added the radio keys

	// Ported from CmdrAI
	/* save */	VARIABLE_ATTR("activeActions", [ATTR_SAVE]);
	VARIABLE("planActionGenerators");	// Array of method name strings to generate actions
	VARIABLE("planPhase");				// Number, 0 to (count planningGenerators - 1), increases on every plan and overflows
	VARIABLE("planActionGeneratorIDs");	// Array of numbers, IDs of next generator to be run in each array of planGenerators
	VARIABLE("planningEnabled");		// Bool, true enables planning

	METHOD(new)
		params [P_THISOBJECT, P_OOP_OBJECT("_agent"), ["_side", WEST, [WEST]], P_OOP_OBJECT("_msgLoop")];
		
		OOP_INFO_1("Initializing Commander for side %1", str(_side));
		
		ASSERT_OBJECT_CLASS(_msgLoop, "MessageLoop");
		T_SETV("side", _side);
		T_SETV("msgLoop", _msgLoop);
		T_SETV("planningEnabled", false);
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
			scriptName "Commander Debug";
			params [P_THISOBJECT, "_side"];
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
				_mrk setMarkerText (format ["Cmdr %1: %2 (%3s)", _thisObject, T_GETV("state"), GAME_TIME - T_GETV("stateStart")]);
			};
		};
		#endif
		
		// Create sensors
		T_CALLM0("_initSensors");

		// Initialize the plan generator arrays
		T_CALLM0("_initPlanActionGenerators");
		
		T_SETV_REF("cmdrStrategy", gCmdrStrategyDefault);
		
		private _worldModel = NEW("WorldModel", []);
		T_SETV("worldModel", _worldModel);

		// Ported from CmdrAI
		T_SETV("activeActions", []);

		// Initialize the radio keys
		//T_SETV("enemyRadioKeys", ["123" ARG "abc"]);
		//T_SETV("enemyRadioKeysAddedBy", ["Potato" ARG "Tomato"]);
		T_SETV("enemyRadioKeys", []);
		T_SETV("enemyRadioKeysAddedBy", []);
		T_CALLM0("initRadioKeys"); // Will set the radioKeyGrid variable

		// Set process interval
		T_CALLM1("setProcessInterval", PROCESS_INTERVAL);

		T_SETV("datePrevExtReinf", DATE_NOW);

		// Roadblock positions
		T_SETV("newRoadblockPositions", []);

		//
		T_SETV("cheatIntelInterception", false);
	ENDMETHOD;
	
	METHOD(_initSensors)
		params [P_THISOBJECT];

		pr _sensorLocation = NEW("SensorCommanderLocation", [_thisObject]);
		T_CALLM1("addSensor", _sensorLocation);
		pr _sensorTargets = NEW("SensorCommanderTargets", [_thisObject]);
		T_CALLM1("addSensor", _sensorTargets);
		pr _sensorCasualties = NEW("SensorCommanderCasualties", [_thisObject]);
		T_CALLM("addSensor", [_sensorCasualties]);
	ENDMETHOD;

	METHOD(_initPlanActionGenerators)
		params [P_THISOBJECT];

		pr _value = [
			// High priority
			[
			"generateAttackActions"
			],
			// Low priority
			[
			"generateConstructRoadblockActions",
			"generatePatrolActions",
			"generateReinforceActions",
			"generateOfficerAssignmentActions",
			"generateTakeOutpostActions",
			"generateSupplyActions"
			]
		];

		T_SETV("planActionGenerators", _value);
		T_SETV("planActionGeneratorIDs", [0 ARG 0]);
		T_SETV("planPhase", 0);
	ENDMETHOD;

	// Initializes strategic nav grid
	// It is used by all commanders, so we create it with a static function
	STATIC_METHOD(initStrategicNavGrid)
		params [P_THISCLASS];

		// You can override these values for specific map
		#ifdef _SQF_VM
		pr _worldName = "altis";
		#else
		pr _worldName = toLower worldName;
		#endif
		pr _resolution = switch (_worldName) do {
			case "altis": { 500 };
			case "malden": { 500 };
			case "tanoa": { 500 };
			default {
				pr _value = WORLD_SIZE / 25;
				_value = 100 * (ceil (_resolution / 100));
				_value;
			};
		};

		gStrategicNavGrid = NEW("StrategicNavGrid", [_resolution]);
	ENDMETHOD;
	

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
	public override METHOD(process)
		params [P_THISOBJECT];

		OOP_INFO_0(" - - - - - P R O C E S S - - - - -");

		// U P D A T E   S E N S O R S
		#ifdef DEBUG_COMMANDER
		T_SETV("state", "update sensors");
		T_SETV("stateStart", GAME_TIME);
		#endif
		FIX_LINE_NUMBERS()

		// Update sensors
		T_CALLM0("updateSensors");

		// U P D A T E   C L U S T E R S
		#ifdef DEBUG_COMMANDER
		T_SETV("state", "update clusters");
		T_SETV("stateStart", GAME_TIME);
		#endif
		FIX_LINE_NUMBERS()

		// TODO: we should just respond to new cluster creation explicitly instead?
		// Register for new clusters		
		private _worldModel = T_GETV("worldModel");
		{
			private _ID = _x select TARGET_CLUSTER_ID_ID;
			private _cluster = [_thisObject ARG _ID];
			if(IS_NULL_OBJECT(CALLM(_worldModel, "findClusterByActual", [_cluster]))) then {
				OOP_INFO_1("Target cluster with ID %1 is new", _ID);
				NEW("ClusterModel", [_worldModel ARG _cluster]);
			};
		} forEach T_GETV("targetClusters");

		// C M D R A I   P L A N N I N G
		private _worldModel = T_GETV("worldModel");

		#ifdef DEBUG_COMMANDER
		T_SETV("state", "action update");
		T_SETV("stateStart", GAME_TIME);
		#endif
		FIX_LINE_NUMBERS()

		T_CALLM("update", [_worldModel]);

		#ifdef DEBUG_COMMANDER
		T_SETV("state", "model planning");
		T_SETV("stateStart", GAME_TIME);
		#endif
		FIX_LINE_NUMBERS()

		#ifndef CMDR_AI_NO_PLAN
		if(T_GETV("planningEnabled")) then {
			T_CALLM("plan", [_worldModel]);
		};
		#endif
		FIX_LINE_NUMBERS()

		// Consider bringing more units into the map
		if(T_GETV("planningEnabled")) then {
			T_CALLM0("updateExternalReinforcement");
			T_CALLM0("updateRecruitment");
		};

		// C L E A N U P
		#ifdef DEBUG_COMMANDER
		T_SETV("state", "cleanup");
		T_SETV("stateStart", GAME_TIME);
		#endif
		FIX_LINE_NUMBERS()
		{
			// Unregister from ourselves straight away
			T_CALLM("_unregisterGarrison", [_x]);
			CALLM2(_x, "postMethodAsync", "destroy", [false]); // false = don't unregister from owning cmdr (as we just did it above!)
		} forEach (T_GETV("garrisons") select { CALLM0(_x, "isEmpty") && {IS_NULL_OBJECT(CALLM0(_x, "getLocation"))} });

		// Reassign abandoned AI units to commander
		private _side = T_GETV("side");
		private _playerGarrison = CALLSM1("GameModeBase", "getPlayerGarrisonForSide", _side);

		// Find all arma groups without players in them
		private _abandonedUnits = CALLM0(_playerGarrison, "getInfantryUnits") apply {
			CALLM0(_x, "getObjectHandle")
		} select {
			// Unit has valid handle
			private _unitHandle = _x;

			/*
			pr _isPlayer = isPlayer _unitHandle;
			pr _units = units (group _unitHandle);
			pr _findPlayer = (units (group _unitHandle)) findIf { isPlayer _x };
			pr _args = [_x, group _x, _isPlayer, _findPlayer, _units];
			OOP_INFO_1("Select abandoned units: %1", _args);
			*/

			!isNull _unitHandle
			&& { alive _unitHandle }
			&& { !isPlayer _unitHandle }
			// Group has no player in it
			&& { (units (group _unitHandle)) findIf { isPlayer _x } == NOT_FOUND }
		};

		OOP_INFO_1("Abandoned units: %1", _abandonedUnits);

		if(count _abandonedUnits > 0) then {
			// Cluster these units into reasonable groups based on proximity
			pr _tempClusters = _abandonedUnits apply {
				pr _pos = getPosASL _x;
				CLUSTER_NEW(_pos select 0, _pos select 1, _pos select 0, _pos select 1, [_x]);
			};
			private _unitClusters = [_tempClusters, 250] call cluster_fnc_findClusters;

			// Return the units to this commander
			{// forEach _abandonedGroups;
				pr _units = _x select CLUSTER_ID_OBJECTS;
				CALLM2(_playerGarrison, "postMethodSync", "makeGarrisonFromUnits", [+_units]);
			} forEach _unitClusters;
		};

		#ifdef DEBUG_COMMANDER
		T_SETV("state", "inactive");
		T_SETV("stateStart", GAME_TIME);
		#endif
		FIX_LINE_NUMBERS()
	ENDMETHOD;

	// ----------------------------------------------------------------------
	// |                    G E T   M E S S A G E   L O O P
	// ----------------------------------------------------------------------

	public override METHOD(getMessageLoop)
		params [P_THISOBJECT];
		
		T_GETV("msgLoop");
	ENDMETHOD;

	// Sets message loop
	METHOD(setMessageLoop)
		params [P_THISOBJECT, P_OOP_OBJECT("_msgLoop")];
		T_SETV("msgLoop", _msgLoop);
	ENDMETHOD;

	public METHOD(getSide)
		params [P_THISOBJECT];
		T_GETV("side")
	ENDMETHOD;
	
	/*
	Method: (static)getAICommander
	Returns AICommander object that commands given side
	
	Parameters: _side
	
	_side - side
	
	Returns: <AICommander>
	*/
	public STATIC_METHOD(getAICommander)
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
			default {
				// Its fine, return null
			};
		};
		_cmdr
	ENDMETHOD;

	/*
	Method: (static)getCmdrStrategy
	Returns Strategy the cmdr of the specified side is using.
	
	Parameters: _side
	
	_side - side
	
	Returns: <CmdrStrategy>
	*/
	public STATIC_METHOD(getCmdrStrategy)
		params [P_THISCLASS, P_SIDE("_side")];
		private _thisObject = CALLSM("AICommander", "getAICommander", [_side]);
		if(!IS_NULL_OBJECT(_thisObject)) then {
			ASSERT_THREAD(_thisObject);
			T_GETV("cmdrStrategy")
		} else {
			gCmdrStrategyDefault
		}
	ENDMETHOD;

	/*
	Method: setCmdrStrategy
	Set Strategy the cmdr should use.

	Parameters: _strategy

	_strategy - CmdrStrategy
	*/
	public METHOD(setCmdrStrategy)
		params [P_THISOBJECT, P_OOP_OBJECT("_strategy")];
		ASSERT_OBJECT_CLASS(_strategy, "CmdrStrategy");
		ASSERT_THREAD(_thisObject);
		T_SETV_REF("cmdrStrategy", _strategy)
	ENDMETHOD;

	/*
	Method: (static)setCmdrStrategyForSide
	Set Strategy the cmdr should use.

	Parameters: _side, _strategy

	_side - side
	_strategy - CmdrStrategy
	*/
	public STATIC_METHOD(setCmdrStrategyForSide)
		params [P_THISCLASS, P_SIDE("_side"), P_OOP_OBJECT("_strategy")];
		private _thisObject = CALLSM("AICommander", "getAICommander", [_side]);
		if(!IS_NULL_OBJECT(_thisObject)) then {
			T_CALLM2("postMethodAsync", "setCmdrStrategy", [_strategy]);
		} else {
			OOP_WARNING_MSG("Can't set cmdr strategy %1, no AICommander found for side %2", [_strategy ARG _side]);
		};
	ENDMETHOD;

	// Location data
	// If you pass any side except EAST, WEST, INDEPENDENT, then this AI object will update its own knowledge about provided locations
	// _updateIfFound - if true, will update an existing item. if false, will not update it
	// !!! _side parameter seems to be not used any more, need to delete it. We obviously update intel for our own side in this method.
	// !!! _showNotifications also seems to not work any more
	public METHOD(updateLocationData)
		params [P_THISOBJECT, P_OOP_OBJECT("_loc"), ["_updateLevel", CLD_UPDATE_LEVEL_UNITS, [0]], ["_side", CIVILIAN], ["_showNotification", true], ["_updateIfFound", true], ["_accuracyRadius", 0]];
		
		// OOP_INFO_1("UPDATE LOCATION DATA: %1", _this);
		// OOP_INFO_1("  Location type: %1", CALLM0(_loc, "getType"));
	
		// Check if we have intel about such location already
		pr _intelResult = T_CALLM1("getIntelAboutLocation", _loc);
		pr _intelDB = T_GETV("intelDB");

		FIX_LINE_NUMBERS()

		if (!IS_NULL_OBJECT(_intelResult)) then {
			//OOP_INFO_1("Intel query result: %1;", _intelResult);

			// There is an intel item with this location

			if (_updateIfFound) then {
				//OOP_INFO_1("Intel was found in existing database: %1", _loc);
				// Update only if incoming accuracy is more or equal to existing one
				if (_updateLevel >= GETV(_intelResult, "accuracy")) then {
					// Create intel item from location, update the old item
					pr _args = [_loc, _updateLevel, _accuracyRadius];
					pr _intel = T_CALLM("createIntelFromLocation", _args);

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
			
			//OOP_INFO_1("Intel was NOT found in existing database: %1", _loc);

			// Create intel from location, add it
			pr _args = [_loc, _updateLevel, _accuracyRadius];
			pr _intel = T_CALLM("createIntelFromLocation", _args);
			
			//OOP_INFO_1("Created intel item from location: %1", _intel);
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
			private _worldModel = T_GETV("worldModel");
			CALLM(_worldModel, "findOrAddLocationByActual", [_loc]);
		};
		
	ENDMETHOD;
	
	// Returns intel we have about specified location
	public METHOD(getIntelAboutLocation)
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
	ENDMETHOD;

	// Creates a LocationData array from Location
	METHOD(createIntelFromLocation)
		params ["_thisObject", P_OOP_OBJECT("_loc"), P_NUMBER("_updateLevel"), P_NUMBER("_accuracyRadius")];
		
		CALLM0(gMessageLoopMain, "lock");

		ASSERT_OBJECT_CLASS(_loc, "Location");

		// Try to find friendly garrisons there first
		// Otherwise try to find any garrisons there
		pr _isFriendly = false;
		pr _garFriendly = CALLM1(_loc, "getGarrisons", T_GETV("side")) select {_x in T_GETV("garrisons")};
		pr _gar = if (count _garFriendly != 0) then {
			_isFriendly = true;
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
		//SETV(_value, "", set [CLD_ID_TIME, GAME_TIME];
		
		// Set type
		if (_updateLevel >= CLD_UPDATE_LEVEL_TYPE) then {
			SETV(_value, "type", CALLM0(_loc, "getType")); // todo add types for locations at some point?
		} else {
			SETV(_value, "type", LOCATION_TYPE_UNKNOWN);
		};
		
		// Set side
		if (_updateLevel >= CLD_UPDATE_LEVEL_SIDE) then {
			if (!IS_NULL_OBJECT(_gar)) then {
				SETV(_value, "side", CALLM0(_gar, "getSide"));
			} else {
				SETV(_value, "side", CLD_SIDE_UNKNOWN);
			};
		} else {
			SETV(_value, "side", CLD_SIDE_UNKNOWN);
		};
		
		// Set efficiency
		if (!_isFriendly) then {
			// Set these fields if it's enemy location
			if (_updateLevel >= CLD_UPDATE_LEVEL_UNITS) then {
				if (!IS_NULL_OBJECT(_gar)) then {
					pr _comp = CALLM0(_gar, "getCompositionNumbers");
					pr _eff = CALLM0(_gar, "getEfficiencyTotal");
					SETV(_value, "unitData", _comp);
					SETV(_value, "efficiency", _eff);
				} else {
					SETV(_value, "unitData", +T_comp_null);
					SETV(_value, "efficiency", +T_eff_null);
				};
			} else {
				SETV(_value, "unitData", []);
				SETV(_value, "efficiency", +T_eff_null);
			};
		} else {
			// For friendly locations it makes no sense
			SETV(_value, "unitData", +T_comp_null);
			SETV(_value, "efficiency", +T_eff_null);
		};
		
		// Set ref to location object
		SETV(_value, "location", _loc);
		
		CALLM0(gMessageLoopMain, "unlock");

		_value
	ENDMETHOD;
	
	// Gets a random intel item from an enemy commander.
	// It's quite a temporary action for now.
	// Later we needto redo it.
	public METHOD(getRandomIntelFromEnemy)
		params [P_THISOBJECT, ["_clientOwner", 0]];

		pr _commandersEnemy = [gAICommanderWest, gAICommanderEast, gAICommanderInd] - [_thisObject];

		OOP_INFO_1("Stealing intel from commanders: %1", _commandersEnemy);

		pr _intelAdded = false;
		pr _thisDB = T_GETV("intelDB");
		{
			OOP_INFO_1("Stealing intel from enemy commander: %1", _x);

			pr _enemyDB = GETV(_x, "intelDB");
			// Select intel items of the classes we are interested in
			pr _classes = ["IntelCommanderActionReinforce", "IntelCommanderActionBuild", "IntelCommanderActionAttack", "IntelCommanderActionRecon", "IntelCommanderActionSupply"];
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

	ENDMETHOD;

	// Thread safe
	// Remove all intel from _items that is known to _side, returning only that which is unknown
	public STATIC_METHOD(filterOutKnownIntel)
		params [P_THISCLASS, P_ARRAY("_items"), P_SIDE("_side")];
		pr _ai = CALLSM1("AICommander", "getAICommander", _side);
		pr _intelDb = GETV(_ai, "intelDB");
		_items select {
			!CALLM1(_intelDb, "isIntelAddedFromSource", _x)
		}
	ENDMETHOD;

	// Thread safe
	// Call it from a non-player-commander thread to reveal intel to the AICommander of player side
	public STATIC_METHOD(revealIntelToPlayerSide)
		params ["_thisClass", P_OOP_OBJECT("_item")];

		// Make a clone of this intel item in our thread
		pr _itemClone = CLONE(_item);
		SETV(_itemClone, "source", _item); // Link it with the source

		pr _playerSide = CALLM0(gGameMode, "getPlayerSide");
		pr _ai = CALLSM1("AICommander", "getAICommander", _playerSide);
		CALLM2(_ai, "postMethodAsync", "stealIntel", [_item ARG _itemClone]);
	ENDMETHOD;

	// Handles stealing intel item which this commander doesn't own
	// Temporary function to reveal stuff to players
	METHOD(stealIntel)
		 params [P_THISOBJECT, P_OOP_OBJECT("_item"), P_OOP_OBJECT("_itemClone")];

		// Bail if object is wrong
		//if (!IS_OOP_OBJECT(_item)) exitWith { };

		pr _thisDB = T_GETV("intelDB");
		CALLM1(_thisDB, "addIntel", _itemClone);
	ENDMETHOD;

	// Gets called when enemy has produced some intel and sends it to some place
	// Enemies might have a chance to intercept it
	// Thread-safe function, it will postMethodAsync to other commanders
	public STATIC_METHOD(interceptIntelAt)
		params [P_THISCLASS, P_OOP_OBJECT("_intel"), P_POSITION("_pos")];

		pr _thisSide = GETV(_intel, "side");
		pr _thisAI = CALLSM1("AICommander", "getAICommander", _side);
		pr _radioKey = CALLM1(_thisAI, "getRadioKey", _pos); // Enemies must have the radio key to intercept this data
		{
			pr _ai = CALLSM1("AICommander", "getAICommander", _x);
			CALLM2(_ai, "postMethodAsync", "_interceptIntelAt", [_intel ARG _pos ARG _radioKey]);
		} forEach ([WEST, EAST, INDEPENDENT] - [_thisSide]);
	ENDMETHOD;

	// Local function, called in thread, on the commander which is tryint to intercept the enemy intel
	METHOD(_interceptIntelAt)
		params [P_THISOBJECT, P_OOP_OBJECT("_intel"), P_POSITION("_pos"), P_STRING("_radioKey")];

		OOP_INFO_1("INTERCEPT INTEL AT: %1", _this);

		if (T_GETV("cheatIntelInterception")) exitWith {
			T_CALLM2("inspectIntel", _intel, INTEL_METHOD_RADIO);
			OOP_INFO_0("  cheated intel inter interception");
		};

		// Check if we have the radio key
		pr _ourKnownEnemyKeys = T_GETV("enemyRadioKeys");
		pr _weHaveRadioKey = _radioKey in _ourKnownEnemyKeys;

		// Check if we have friendly locations nearby which have the radio
		pr _side = T_GETV("side");
		pr _friendlyLocs = CALLSM0("Location", "getAll") select {
			(CALLM0(_x, "getPos") distance _pos) < 4500 &&
			CALLM0(_x, "hasRadio")
		} select {
			pr _gars = CALLM1(_x, "getGarrisons", _side);
			(count _gars) > 0
		};

		// Do we have friendly locations nearby?
		pr _intelIntercepted = false;
		if (count _friendlyLocs > 0) then {
			if (_weHaveRadioKey) then {
				T_CALLM2("inspectIntel", _intel, INTEL_METHOD_RADIO);
				OOP_INFO_0("  successfull interception");
				_intelIntercepted = true;
			} else {
				// Todo Mark an unknown radio transmission on the map??
				OOP_INFO_0("  we don't have this radio key");
			};
		} else {
			OOP_INFO_0("  no friendly locations with radio nearby...");
		};

		// Iterate nearby cities, our influence of these cities affects the chance of interception
		if (!_intelIntercepted && (T_GETV("side") == CALLM0(gGameMode, "getPlayerSide")) ) then { // Only works for rebels
			pr _nearCities = CALLSM2("Location", "nearLocations", _pos, 2000) select {CALLM0(_x, "getType") == LOCATION_TYPE_CITY;};
			OOP_INFO_1("Nearby cities: %1", _nearCities);
			if (count _nearCities > 0) then {
				pr _avgInfluence = 0;
				{
					pr _gmData = CALLM0(_x, "getGameModeData");
					if (!IS_NULL_OBJECT(_gmData)) then {
						if (GET_OBJECT_CLASS(_gmData) == "CivilWarCityData") then {
							pr _influence = CALLM0(_gmData, "getInfluence"); // Within 0..1 range
							OOP_INFO_2("   City %1: influence %2", CALLM0(_x, "getName"), _influence);
							_influence = _influence max 0; // Ignore negative values
							_avgInfluence = _avgInfluence + _influence;
						};
					};
				} forEach _nearCities;
				_avgInfluence = _avgInfluence / (count _nearCities); // Within 0..1 range
				OOP_INFO_1("  Average influence: %1", _avgInfluence);
				if (random 1 < _avgInfluence) then {
					OOP_INFO_0("  Intel intercepted through city");
					T_CALLM2("inspectIntel", _intel, INTEL_METHOD_CITY);
				} else {
					OOP_INFO_0("  Intel not intercepted");
				};
			};
		};

		// TEST delete this!
		// Uncomment to intercept all enemy intel from everywhere
		//T_CALLM2("inspectIntel", _intel, INTEL_METHOD_RADIO);
	ENDMETHOD;

	// Checks intel in some other cmdr's database
	// Makes a copy of that intel and takes it to this commander
	METHOD(inspectIntel)
		params [P_THISOBJECT, P_OOP_OBJECT("_intel"), P_NUMBER("_method")];

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
			SETV(_ourIntel, "method", _method); // Set the method of how we have discovered this
			OOP_INFO_2("  Intel with source %1 NOT found in DB, made a clone: %2", _intel, _ourIntel);
			SETV(_ourIntel, "source", _intel); // We must mark the external intel item as as source of this intel, for future updates
			CALLM1(_db, "addIntel", _ourIntel);
		};
	ENDMETHOD;

	// Gets called after player has analyzed up an inventory item with intel
	public thread METHOD(getIntelFromInventoryItem)
		params [P_THISOBJECT, P_OOP_OBJECT("_baseClass"), P_NUMBER("_ID"), P_NUMBER("_clientOwner")];

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
						REMOTE_EXEC_CALL_STATIC_METHOD("NotificationFactory", "createRadioCryptokey", [_radioKey], _clientOwner, NO_JIP);

						// Copy stuff into player's notes
						pr _text = format [_endl + "%1 Found enemy radio cryptokey: %2" + _endl, date call misc_fnc_dateToISO8601, _radioKey];
						REMOTE_EXEC_CALL_STATIC_METHOD("InGameMenuTabNotes", "staticAppendText", [_text], _clientOwner, NO_JIP);
					};
				};

				// Send data to tablet
				pr _text = format [_endl + "  Radio cryptokey: %1" + _endl, _radioKey];
				REMOTE_EXEC_CALL_STATIC_METHOD("TacticalTablet", "staticAppendTextDelay", [_text ARG 0.1], _clientOwner, NO_JIP);
			} else {
				// Send data to tablet
				pr _text = _endl + "  Radio cryptokey: only in military tablets" + _endl;
				REMOTE_EXEC_CALL_STATIC_METHOD("TacticalTablet", "staticAppendTextDelay", [_text ARG 0.1], _clientOwner, NO_JIP);
			};
		};

		// Process the intel about this garrison's action
		if (!IS_NULL_OBJECT(_intelPersonal)) then {
			if (IS_OOP_OBJECT(_intelPersonal)) then {

				// Add to our db if needed
				if (_itemSide != _side) then {
					T_CALLM2("inspectIntel", _intelPersonal, INTEL_METHOD_INVENTORY_ITEM);
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
	ENDMETHOD;
	
	// Generates a new target cluster ID
	public METHOD(getNewTargetClusterID)
		params [P_THISOBJECT];
		pr _nextID = -1;
		CRITICAL_SECTION {
			_nextID = T_GETV("nextClusterID");
			T_SETV("nextClusterID", _nextID + 1);
		};
		_nextID
	ENDMETHOD;
		
	/*
	Method: onTargetClusterCreated
	Gets called on creation of a totally new target cluster
	Parameters: _tc
	
	_ID - the new target cluster ID (must already exist in the cluster array)
	
	Returns: nil
	*/
	public METHOD(onTargetClusterCreated)
		params [P_THISOBJECT, "_tcNew"];
		OOP_INFO_1("TARGET CLUSTER CREATED, ID: %1", _tcNew#TARGET_CLUSTER_ID_ID);

		// Create intel for the new cluster, add it to intel db
		pr _intel = _tcNew select TARGET_CLUSTER_ID_INTEL;
		if (IS_NULL_OBJECT(_intel)) then {
			_intel = NEW("IntelCluster", []);
			CALLSM2("AICommander", "setIntelClusterProperties", _intel, _tcNew);
			pr _inteldb = T_GETV("intelDB");
			CALLM1(_inteldb, "addIntel", _intel);
			_tcNew set [TARGET_CLUSTER_ID_INTEL, _intel];
		};

		//private _worldModel = T_GETV("worldModel");
		//NEW("ClusterModel", [_worldModel ARG [_thisObject ARG _ID]]);
	ENDMETHOD;

	/*
	Method: onTargetClusterSplitted
	Gets called when an already known cluster gets splitted into multiple new clusters.
	
	Parameters: _tcsNew
	
	_tcsNew - array of [_affinity, _newTargetCluster]
	
	Returns: nil
	*/
	public METHOD(onTargetClusterSplitted)
		params [P_THISOBJECT, "_tcOld", "_tcsNew"];
		
		pr _IDOld = _tcOld select TARGET_CLUSTER_ID_ID;
		pr _a = _tcsNew apply {[_x select 0, _x select 1 select TARGET_CLUSTER_ID_ID]};
		OOP_INFO_2("TARGET CLUSTER SPLITTED, old ID: %1, new affinity and IDs: %2", _IDOld, _a);

		// Sort new clusters by affinity
		_tcsNew sort DESCENDING;

		// Relocate all actions assigned to the old cluster to the new cluster with maximum affinity
		pr _newClusterID = _tcsNew select 0 select 1 select TARGET_CLUSTER_ID_ID;

		private _worldModel = T_GETV("worldModel");
		// Retarget in the model
		CALLM(_worldModel, "retargetClusterByActual", [[_thisObject ARG _IDOld] ARG [_thisObject ARG _newClusterID]]);

		// Delete intel assigned to old target cluster
		pr _inteldb = T_GETV("intelDB");
		pr _intel = _tcOld select TARGET_CLUSTER_ID_INTEL;
		if (!IS_NULL_OBJECT(_intel)) then {
			CALLM1(_inteldb, "removeIntel", _intel);
			DELETE(_intel);
			_tcOld set [TARGET_CLUSTER_ID_INTEL, NULL_OBJECT];
		};

		// Create intel for new target clusters
		{
			_x params ["_affinity", "_tcNew"];
			pr _intel = _tcNew select TARGET_CLUSTER_ID_INTEL;
			if (IS_NULL_OBJECT(_intel)) then {
				_intel = NEW("IntelCluster", []);
				CALLSM2("AICommander", "setIntelClusterProperties", _intel, _tcNew);
				CALLM1(_inteldb, "addIntel", _intel);
				_tcNew set [TARGET_CLUSTER_ID_INTEL, _intel];
			};
		} forEach _tcsNew;
	ENDMETHOD;

	/*
	Method: onTargetClusterMerged
	Gets called when old clusters get merged into a new one
	
	Parameters: _tcsOld, _tcNew
	
	_tcsOld - array with old target clusters
	_tcNew - the new target cluster
	
	Returns: nil
	*/
	public METHOD(onTargetClustersMerged)
		params [P_THISOBJECT, "_tcsOld", "_tcNew"];

		pr _IDnew = _tcNew select TARGET_CLUSTER_ID_ID;
		pr _IDsOld = []; { _IDsOld pushBack (_x select TARGET_CLUSTER_ID_ID)} forEach _tcsOld;
		OOP_INFO_2("TARGET CLUSTER MERGED, old IDs: %1, new ID: %2", _IDsOld, _IDnew);

		private _worldModel = T_GETV("worldModel");

		// Assign all actions from old IDs to new IDs
		{
			pr _IDOld = _x;
			// Retarget in the model
			CALLM(_worldModel, "retargetClusterByActual", [[_thisObject ARG _IDOld] ARG [_thisObject ARG _IDnew]]);
		} forEach _IDsOld;

		// Delete intel at old clusters
		pr _inteldb = T_GETV("intelDB");
		{
			pr _intel = _x select TARGET_CLUSTER_ID_INTEL;
			if (!IS_NULL_OBJECT(_intel)) then {
				CALLM1(_inteldb, "removeIntel", _intel);
				DELETE(_intel);
				_x set [TARGET_CLUSTER_ID_INTEL, NULL_OBJECT];
			};
		} forEach _tcsOld;

		// Create intel for the new cluster
		pr _intel = NEW("IntelCluster", []);
		if (IS_NULL_OBJECT(_intel)) then {
			CALLSM2("AICommander", "setIntelClusterProperties", _intel, _tcNew);
			CALLM1(_inteldb, "addIntel", _intel);
			_tcNew set [TARGET_CLUSTER_ID_INTEL, _intel];
		};

	ENDMETHOD;
	
	/*
	Method: onTargetClusterDeleted
	Gets called on deletion of a cluster because these enemies are not spotted any more
	
	Parameters: _tc
	
	_tc - the new target cluster
	
	Returns: nil
	*/
	public METHOD(onTargetClusterDeleted)
		params [P_THISOBJECT, "_tc"];
		
		pr _ID = _tc select TARGET_CLUSTER_ID_ID;
		OOP_INFO_1("TARGET CLUSTER DELETED, ID: %1", _ID);
		
		// Delete intel
		pr _intel = _tc select TARGET_CLUSTER_ID_INTEL;
		if(!IS_NULL_OBJECT(_intel)) then {
			pr _inteldb = T_GETV("intelDB");
			CALLM1(_inteldb, "removeIntel", _intel);
			DELETE(_intel);
			_tc set [TARGET_CLUSTER_ID_INTEL, NULL_OBJECT];
		};
	ENDMETHOD;

	/*
	Method: onTargetClusterUpdated
	Gets called on update of a target cluster.
	*/
	public METHOD(onTargetClusterUpdated)
		params [P_THISOBJECT, "_tc"];
		
		OOP_INFO_1("ON TARGET CLUSTER UPDATED: ID: %1", _tc select TARGET_CLUSTER_ID_ID);

		// Update intel
		pr _intel = _tc select TARGET_CLUSTER_ID_INTEL;
		if (!IS_NULL_OBJECT(_intel)) then {
			pr _inteldb = T_GETV("intelDB");
			pr _intelNew = NEW("IntelCluster", []);
			CALLSM2("AICommander", "setIntelClusterProperties", _intelNew, _tc);
			OOP_INFO_2("  updating cluster intel %1 from %2", _intel, _intelNew);
			CALLM2(_inteldb, "updateIntel", _intel, _intelNew);
			DELETE(_intelNew);
		};
	ENDMETHOD;
	
	/*
	Method: getTargetCluster
	Returns a target cluster with specified ID
	
	Parameters: _ID
	
	_ID - ID of the target cluster
	
	Returns: target cluster structure or [] if nothing was found
	*/
	public METHOD(getTargetCluster)
		params [P_THISOBJECT, P_NUMBER("_ID")];
		
		pr _targetClusters = T_GETV("targetClusters");
		pr _ret = [];
		{ // foreach _targetClusters
			if (_x select TARGET_CLUSTER_ID_ID == _ID) exitWith {
				_ret = _x;
			};
		} forEach _targetClusters;
		
		_ret
	ENDMETHOD;

	// Sets properties of IntelCluster from an actual TARGET_CLUSTER
	STATIC_METHOD(setIntelClusterProperties)
		PARAMS[P_THISCLASS, P_OOP_OBJECT("_intel"), P_DYNAMIC("_targetCluster")];

		SETV(_intel, "efficiency", +(_targetCluster#TARGET_CLUSTER_ID_EFFICIENCY));
		SETV(_intel, "dateNumberLastSpotted", _targetCluster#TARGET_CLUSTER_ID_MAX_DATE_NUMBER);
		SETV(_intel, "pos1", [_targetCluster#TARGET_CLUSTER_ID_CLUSTER#CLUSTER_ID_X1 ARG _targetCluster#TARGET_CLUSTER_ID_CLUSTER#CLUSTER_ID_Y1]);
		SETV(_intel, "pos2", [_targetCluster#TARGET_CLUSTER_ID_CLUSTER#CLUSTER_ID_X2 ARG _targetCluster#TARGET_CLUSTER_ID_CLUSTER#CLUSTER_ID_Y2]);
	ENDMETHOD;
	
	/*
	Method: getThreat
	Get estimated threat at a particular position
	
	Parameters:
	_pos - <position>
	
	Returns: Number - threat at _pos
	*/
	public METHOD(getThreat) // thread-safe
		params [P_THISOBJECT, P_ARRAY("_pos")];
		private _worldModel = T_GETV("worldModel");
		CALLM(_worldModel, "getThreat", [_pos])
	ENDMETHOD;

	public METHOD(getDamage) // thread-safe
		params [P_THISOBJECT, P_ARRAY("_pos")];
		private _worldModel = T_GETV("worldModel");
		CALLM(_worldModel, "getDamage", [_pos])
	ENDMETHOD;

	// Thread unsafe
	METHOD(_addActivity)
		params [P_THISOBJECT, P_POSITION("_pos"), P_NUMBER("_activity")];
		OOP_DEBUG_MSG("Adding %1 activity at %2 for side %3", [_activity ARG _pos ARG T_GETV("side")]);
		private _worldModel = T_GETV("worldModel");
		CALLM(_worldModel, "addActivity", [_pos ARG _activity])
	ENDMETHOD;

	METHOD(_addDamage)
		params [P_THISOBJECT, P_POSITION("_pos"), P_NUMBER("_activity")];
		OOP_DEBUG_MSG("Adding %1 activity at %2 for side %3", [_activity ARG _pos ARG T_GETV("side")]);
		private _worldModel = T_GETV("worldModel");
		CALLM(_worldModel, "addDamage", [_pos ARG _activity])
	ENDMETHOD;

	// Thread safe
	public STATIC_METHOD(addActivity)
		params [P_THISCLASS, P_SIDE("_side"), P_POSITION("_pos"), P_NUMBER("_activity")];

		private _thisObject = CALLSM("AICommander", "getAICommander", [_side]);
		if(!IS_NULL_OBJECT(_thisObject)) then {
			T_CALLM2("postMethodAsync", "_addActivity", [_pos ARG _activity]);
		};
	ENDMETHOD;

	/*
	Method: getActivity
	Get enemy (to this cmdr) activity in an area
	
	Parameters:
	_pos - <position>
	_radius - <number>
	
	Returns: Number - max activity in radius2
	*/
	public METHOD(getActivity) // thread-safe
		params [P_THISOBJECT, P_ARRAY("_pos"), P_NUMBER("_radius")];
		private _worldModel = T_GETV("worldModel");
		CALLM(_worldModel, "getActivity", [_pos ARG _radius])
	ENDMETHOD;

	/*
	Method: _registerGarrison
	Registers a garrison to be processed by this AICommander
	
	Parameters:
	_gar - <Garrison>
	
	Returns: GarrisonModel
	*/
	thread METHOD(_registerGarrison)
		params [P_THISOBJECT, P_OOP_OBJECT("_gar")];
		ASSERT_OBJECT_CLASS(_gar, "Garrison");
		ASSERT_THREAD(_thisObject);

		OOP_DEBUG_MSG("Registering garrison %1", [_gar]);
		T_GETV("garrisons") pushBack _gar; // I need you for my army!
		REF(_gar);
		private _worldModel = T_GETV("worldModel");
		NEW("GarrisonModel", [_worldModel ARG _gar])
	ENDMETHOD;

	/*
	Method: registerGarrisonCmdrThread
	Registers a garrison to be processed by this AICommander

	Parameters:
	_gar - <Garrison>

	Returns: GarrisonModel
	*/
	public STATIC_METHOD(registerGarrisonCmdrThread)
		params [P_THISCLASS, P_OOP_OBJECT("_gar")];
		ASSERT_OBJECT_CLASS(_gar, "Garrison");
		private _side = CALLM0(_gar, "getSide");
		private _thisObject = CALLSM("AICommander", "getAICommander", [_side]);

		if(!IS_NULL_OBJECT(_thisObject)) then {
			T_CALLM1("_registerGarrison", _gar);
		} else {
			OOP_ERROR_MSG("No AICommander found for side %1 to register %2", [_side ARG _gar]);
			NULL_OBJECT
		}
	ENDMETHOD;

	/*
	Method: registerGarrison
	Registers a garrison to be processed by a AICommander.
	Call this version if you are outside of the commander thread.
	
	Parameters:
	_gar - <Garrison>
	_continuation - see <MessageReceiverEx.postMethodAsync>

	Returns: nil
	*/
	public STATIC_METHOD(registerGarrison)
		params [P_THISCLASS, P_OOP_OBJECT("_gar"), ["_continuation", false, [false, []]]];
		ASSERT_OBJECT_CLASS(_gar, "Garrison");

		private _side = CALLM0(_gar, "getSide");
		private _thisObject = CALLSM("AICommander", "getAICommander", [_side]);

		if(!IS_NULL_OBJECT(_thisObject)) then {
			return T_CALLM3("postMethodAsync", "_registerGarrison", [_gar], _continuation)
		} else {
			OOP_ERROR_MSG("No AICommander found for side %1 to register %2", [_side ARG _gar]);
			return nil
		};
	ENDMETHOD;

	/*
	Method: registerLocation
	Registers a location to be known by this AICommander
	
	Parameters:
	_loc - <Location>
	
	Returns: nil
	*/
	public METHOD(registerLocation)
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];
		ASSERT_OBJECT_CLASS(_loc, "Location");
		ASSERT_THREAD(_thisObject);

		private _newModel = NULL_OBJECT;
		OOP_DEBUG_MSG("Registering location %1", [_loc]);
		//T_GETV("locations") pushBack _loc; // I need you for my army!
		private _worldModel = T_GETV("worldModel");
		// Just creating the location model is registering it with CmdrAI
		NEW("LocationModel", [_worldModel ARG _loc]);
	ENDMETHOD;

	/*
	Method: unregisterGarrison
	Unregisters a garrison from this AICommander
	
	Parameters:
	_gar - <Garrison>
	_destroy - will destroy the garrison after unregistering, default false
	
	Returns: nil
	*/
	public STATIC_METHOD(unregisterGarrison)
		params [P_THISCLASS, P_OOP_OBJECT("_gar"), ["_destroy", false, [false]]];
		ASSERT_OBJECT_CLASS(_gar, "Garrison");

		private _side = CALLM0(_gar, "getSide");
		private _thisObject = CALLSM("AICommander", "getAICommander", [_side]);
		if(!IS_NULL_OBJECT(_thisObject)) then {
			T_CALLM2("postMethodAsync", "_unregisterGarrison", [_gar ARG _destroy]);
		} else {
			OOP_WARNING_MSG("Can't unregisterGarrison %1, no AICommander found for side %2", [_gar ARG _side]);
		};
	ENDMETHOD;

	METHOD(_unregisterGarrison)
		params [P_THISOBJECT, P_STRING("_gar"), ["_destroy", false, [false]]];
		ASSERT_THREAD(_thisObject);

		private _garrisons = T_GETV("garrisons");
		// Check the garrison is registered
		private _idx = _garrisons find _gar;
		if(_idx != NOT_FOUND) then {
			OOP_DEBUG_MSG("Unregistering garrison %1", [_gar]);
			// Remove from model first
			private _worldModel = T_GETV("worldModel");
			private _garrisonModel = CALLM(_worldModel, "findGarrisonByActual", [_gar]);
			CALLM(_worldModel, "removeGarrison", [_garrisonModel]);
			_garrisons deleteAt _idx; // Get out of my sight you useless garrison!
			UNREF(_gar);

			// Send msg to garrison to destroy it
			if (_destroy) then {
				CALLM2(_gar, "postMethodAsync", "destroy", [false]); // Dont unregister from cmdr
			};
		} else {
			OOP_WARNING_MSG("Garrison %1 not registered so can't _unregisterGarrison", [_gar]);
		};
	ENDMETHOD;
		
	/*
	Method: registerIntelCommanderAction
	Registers a piece of intel on an action that this Commander owns.
	Parameters:
	_intel - <IntelCommanderAction>
	
	Returns: clone of _intel item that can be used in further updateIntelFromClone operations.
	*/
	public STATIC_METHOD(registerIntelCommanderAction)
		params [P_THISCLASS, P_OOP_OBJECT("_intel")];
		ASSERT_OBJECT_CLASS(_intel, "IntelCommanderAction");
		private _side = GETV(_intel, "side");
		private _thisObject = CALLSM("AICommander", "getAICommander", [_side]);

		private _intelDB = T_GETV("intelDB");
		private _intelClone = CALLM(_intelDB, "addIntelClone", [_intel]);
		_intelClone
	ENDMETHOD;

	/*
	Method: unregisterIntelCommanderAction
	
	*/
	public STATIC_METHOD(unregisterIntelCommanderAction)
		params [P_THISCLASS, P_OOP_OBJECT("_intel"), P_OOP_OBJECT("_intelClone")];

		OOP_INFO_2("UNREGISTER INTEL COMMANDER ACTION: intel: %1, intel clone: %2", _intel, _intelClone);

		ASSERT_OBJECT_CLASS(_intel, "IntelCommanderAction");
		private _side = GETV(_intel, "side");
		private _thisObject = CALLSM("AICommander", "getAICommander", [_side]);
		// Notify enemy commanders that this intel has been destroyed
		private _enemySides = [WEST, EAST, INDEPENDENT] - [_side];
		{
			pr _enemySide = _x;
			private _AI = CALLSM("AICommander", "getAICommander", [_enemySide]);
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
	ENDMETHOD;

	// Some intel about our own action has changed, so we are going to notify enemies which have such intel about an update
	public STATIC_METHOD(updateIntelCommanderActionForEnemies)
		params [P_THISCLASS, P_OOP_OBJECT("_intel"), P_OOP_OBJECT("_intelClone")];

		OOP_INFO_2("UPDATE INTEL COMMANDER ACTION FOR ENEMIES: intel: %1, intel clone: %2", _intel, _intelClone);

		ASSERT_OBJECT_CLASS(_intel, "IntelCommanderAction");
		private _side = GETV(_intel, "side");
		private _thisObject = CALLSM("AICommander", "getAICommander", [_side]);
		// Notify enemy commanders that this intel has been destroyed
		private _enemySides = [WEST, EAST, INDEPENDENT] - [_side];
		{
			pr _enemySide = _x;
			private _AI = CALLSM("AICommander", "getAICommander", [_enemySide]);
			private _db = GETV(_AI, "intelDB");
			// Check if this DB has an intel which has _intel as source
			if (CALLM1(_db, "isIntelAddedFromSource", _intel)) then {
				// The enemy commander has updated intel about some task
				// Update it for everyone at this side _enemySide
				CALLM1(_db, "updateIntelFromSource", _intel);
			};
		} forEach _enemySides;
	ENDMETHOD;

	// Temporary function that adds infantry to some location
	public METHOD(debugCreateGarrison)
		params [P_THISOBJECT, P_POSITION("_pos")];
		pr _side = T_GETV("side");

		// Create a new garrison and register it
		pr _gar = NEW("Garrison", [GARRISON_TYPE_GENERAL ARG _side ARG _pos]);
		// Create some infantry group
		pr _group = NEW("Group", [_side ARG GROUP_TYPE_INF]);

		// Try to spawn more units at the selected locations
		pr _t = CALLM2(gGameMode, "getTemplate", _side, "military");
		//[_templateName] call t_fnc_getTemplate;

		CALLM2(_group, "createUnitsFromTemplate", _t, T_GROUP_inf_rifle_squad);
		CALLM2(_gar, "postMethodAsync", "addGroup", [_group]);

		CALLM0(_gar, "activateCmdrThread");
	ENDMETHOD;
 
	// Temporary function that adds infantry to some location
	public METHOD(debugAddGroupToLocation)
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];

		pr _side = T_GETV("side");

		// Check if there is already a garrison at this location
		pr _gars = CALLM1(_loc, "getGarrisons", _side);
		pr _gar = if ((count _gars) > 0) then {
			_gars#0
		} else {
			pr _locPos = CALLM0(_loc, "getPos");
			// Create a new garrison and register it
			pr _gar = NEW("Garrison", [GARRISON_TYPE_GENERAL ARG _side ARG _locPos]);
			CALLM2(_gar, "postMethodAsync", "setLocation", [_loc]);

			CALLM0(_gar, "activateCmdrThread");
			_gar
		};

		// Create some infantry group
		pr _group = NEW("Group", [_side ARG GROUP_TYPE_INF]);
		// Try to spawn more units at the selected locations
		pr _t = CALLM2(gGameMode, "getTemplate", _side, "military");

		CALLM2(_group, "createUnitsFromTemplate", _t, T_GROUP_inf_rifle_squad);
		CALLM2(_gar, "postMethodAsync", "addGroup", [_group]);

		// That's all!
	ENDMETHOD;

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
	public METHOD(resolveTarget)
		params [P_THISOBJECT, P_NUMBER("_targetType"), ["_target", [], [[], ""] ]];

		private _worldModel = T_GETV("worldModel");

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

	ENDMETHOD;

	// Call it through postMethodAsync !
	public server thread METHOD(clientCreateMoveAction)
		params [P_THISOBJECT, P_OOP_OBJECT("_garRef"), P_NUMBER("_targetType"), ["_target", [], [[], ""] ] ];

		ASSERT_THREAD(_thisObject); // Respect my threading!

		T_CALLM4("_clientCreateGarrisonAction", _garRef, _targetType, _target, "DirectMoveCmdrAction");
	ENDMETHOD;

	public server thread METHOD(clientCreateReinforceAction)
		params [P_THISOBJECT, P_OOP_OBJECT("_garRef"), P_NUMBER("_targetType"), ["_target", [], [[], ""] ] ];

		ASSERT_THREAD(_thisObject); // Respect my threading!

		T_CALLM4("_clientCreateGarrisonAction", _garRef, _targetType, _target, "DirectReinforceCmdrAction");
	ENDMETHOD;

	public server thread METHOD(clientCreateAttackAction)
		params [P_THISOBJECT, P_OOP_OBJECT("_garRef"), P_NUMBER("_targetType"), ["_target", [], [[], ""] ] ];

		ASSERT_THREAD(_thisObject); // Respect my threading!

		T_CALLM4("_clientCreateGarrisonAction", _garRef, _targetType, _target, "DirectAttackCmdrAction");
	ENDMETHOD;

	// Thread unsafe, private
	server METHOD(_clientCreateGarrisonAction)
		params [P_THISOBJECT, P_OOP_OBJECT("_garRef"), P_NUMBER("_targetType"), ["_target", [], [[], ""] ], P_STRING("_actionName")];

		OOP_INFO_1("CLIENT CREATE GARRISON ACTION: %1", _this);

		// Verify the garrison is valid, it could have been destroyed since the player gave the order
		if(!IS_OOP_OBJECT(_garRef)) exitWith {};

		// First split us off a new garrison if the specified one is at a location, we never want to abandon a location entirely
		// like this
		private _loc = CALLM0(_garRef, "getLocation");
		private _finalGar = if(!IS_NULL_OBJECT(_loc)) then {
			T_CALLM1("splitGarrisonFromLocation", _garRef)
		} else {
			_garRef
		};

		if(IS_NULL_OBJECT(_finalGar)) exitWith {
			OOP_ERROR_1("_clientCreateGarrisonAction: Could not split any usable garrison from location of %1", _garRef);
		};

		// Get the garrison model associated with this _garRef
		private _worldModel = T_GETV("worldModel");
		pr _garModel = CALLM1(_worldModel, "findGarrisonByActual", _finalGar);
		if (IS_NULL_OBJECT(_garModel)) exitWith {
			OOP_ERROR_1("_clientCreateGarrisonAction: No model of garrison %1", _finalGar);
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
	ENDMETHOD;

	// Gets called from client to cancel the current order this garrison is doing
	public server METHOD(cancelCurrentAction)
		params [P_THISOBJECT, P_STRING("_garRef") ];

		ASSERT_THREAD(_thisObject); // Respect my threading!

		// Get the garrison model associated with this _garRef
		private _worldModel = T_GETV("worldModel");
		pr _garModel = CALLM1(_worldModel, "findGarrisonByActual", _garRef);
		if (IS_NULL_OBJECT(_garModel)) exitWith {
			OOP_ERROR_1("createMoveAction: No model of garrison %1", _garRef);
		};

		// Cancel previously given action
		T_CALLM1("clearAndCancelGarrisonAction", _garModel);
	ENDMETHOD;

	// Gets called if player moves a garrison attached to a location to instead create
	// a new garrison split from the location, taking only non static vehicles and inf
	METHOD(splitGarrisonFromLocation)
		PARAMS[P_THISOBJECT, P_STRING("_garSrcRef")];

		ASSERT_THREAD(_thisObject);


		// Get all the units except statics and cargo
		private _combatUnits = (CALLM0(_garSrcRef, "getUnits") select { !CALLM0(_x, "isStatic") && {!CALLM0(_x, "isCargo")} });

		// Take the units
		if(count _combatUnits > 0) then {
			// Create a new garrison
			// We don't want them to be too much clustered at the same place (if they are already spawned it will update this value automatically anyway)
			private _posNew = CALLM0(_garSrcRef, "getPos") getPos [50, random 360];
			private _newGarr = CALLSM2("Garrison", "newFrom", _garSrcRef, _posNew);

			CALLM2(_newGarr, "postMethodSync", "takeUnits", [_combatUnits]);

			// Activate the new garrison
			// it will register itself here as well
			CALLM0(_newGarr, "activateCmdrThread");
			// Return the new garrison
			_newGarr
		} else {
			// Failed
			NULL_OBJECT
		}
	ENDMETHOD;

	// Gets called remotely from player's 'split garrison' dialog
	public server METHOD(splitGarrisonFromComposition)
		PARAMS[P_THISOBJECT, P_STRING("_garSrcRef"), P_ARRAY("_comp"), P_NUMBER("_clientOwner")];

		ASSERT_THREAD(_thisObject);

		// Get the garrison model associated with this _garSrcRef
		private _worldModel = T_GETV("worldModel");
		private _garModel = CALLM1(_worldModel, "findGarrisonByActual", _garSrcRef);
		if (IS_NULL_OBJECT(_garModel)) exitWith {
			OOP_ERROR_1("splitGarrisonFromComposition: No model of garrison %1", _garSrcRef);
			// send data back to client owner...
			REMOTE_EXEC_CALL_STATIC_METHOD("GarrisonSplitDialog", "sendServerResponse", [11], _clientOwner, false); // REMOTE_EXEC_CALL_STATIC_METHOD(classNameStr, methodNameStr, extraParams, targets, JIP)
		};

		// Create a new garrison
		// We don't want them to be too much clustered at the same place (if they are already spawned it will update this value automatically anyway)
		private _posNew = CALLM0(_garSrcRef, "getPos") getPos [50, random 360];
		private _newGarr = CALLSM2("Garrison", "newFrom", _garSrcRef, _posNew);

		// Move units
		private _numUnfoundUnits = CALLM2(_newGarr, "postMethodSync", "addUnitsFromCompositionClassNames", [_garSrcRef ARG _comp]);

		// Activate the new garrison
		// it will register itself here as well
		CALLM0(_newGarr, "activateCmdrThread");

		// Send data back to client
		REMOTE_EXEC_CALL_STATIC_METHOD("GarrisonSplitDialog", "sendServerResponse", [22], _clientOwner, false);

	ENDMETHOD;

	public server METHOD(clientCreateLocation)
		params [P_THISOBJECT, P_NUMBER("_clientOwner"), P_POSITION("_posWorld"), P_STRING("_locType"), P_STRING("_locName"), P_OBJECT("_hBuildResSrc"), P_NUMBER("_buildResAmount")];

		ASSERT_THREAD(_thisObject);

		pr _radius = CALLSM1("Location", "getDefaultRadius", _locType);

		// Nullify vertical component, we use position ATL for locations anyway
		pr _pos = +_posWorld;
		_pos set [2, 0];

		// Make sure the position is not very close to an existing location
		pr _locsNear = CALLSM2("Location", "overlappingLocations", _pos, 2*_radius);
		pr _index = _locsNear findIf {
			!IS_NULL_OBJECT(T_CALLM1("getIntelAboutLocation", _x))
		};
		if (_index != -1) exitWith {
			pr _args = ["We can't create a location so close to another location!"];
			REMOTE_EXEC_CALL_STATIC_METHOD("InGameMenuTabCommander", "showServerResponse", _args, _clientOwner, false);
		};

		// Check if there are any locations directly at this place
		pr _locsAtPos = CALLSM1("Location", "getLocationsAtPos", _pos);
		//pr _indexCity = _locsAtPos findIf {CALLM0(_x, "getType") == LOCATION_TYPE_CITY};
		if (count _locsAtPos > 0) exitWith {
			//pr _args = ["We can't create a location inside a city!"];
			pr _args = ["We can't create a location inside another location!"];
			REMOTE_EXEC_CALL_STATIC_METHOD("InGameMenuTabCommander", "showServerResponse", _args, _clientOwner, false);
		};

		// Remove build resources from player or vehicle
		if (_hBuildResSrc isKindOf "man") then {
			// Remove resources from player
			REMOTE_EXEC_CALL_STATIC_METHOD("Unit", "removeInfantryBuildResources", [_hBuildResSrc ARG _buildResAmount], _clientOwner, false);
		} else {
			// Remove resources from vehicle
			REMOTE_EXEC_CALL_STATIC_METHOD("Unit", "removeVehicleBuildResources", [_hBuildResSrc ARG _buildResAmount], _clientOwner, false);
		};

		// Create a little composition at this place
		// We don't want to create this composition for roadblocks though
		if (_locType in [LOCATION_TYPE_OUTPOST, LOCATION_TYPE_CAMP]) then {
			[_posWorld] call misc_fnc_createCampComposition;
		};

		// Create the location
		pr _args = [_pos, T_GETV("side")]; // Our side is creating this location
		pr _loc = NEW_PUBLIC("Location", _args);
		CALLM1(_loc, "setBorderCircle", _radius);
		CALLM1(_loc, "setType", _locType);
		CALLM1(_loc, "setName", _locName);
		CALLM2(_loc, "processObjectsInArea", "House", true);
		CALLM1(gGameMode, "initLocationGameModeData", _loc);

		// Create the garrisons, player one for our stuff, general one for recruited fighters
		// TODO add the player garrison, it requires some way to move vehicles between player and general garrison etc.
		// pr _gar = NEW("Garrison", [GARRISON_TYPE_PLAYER ARG T_GETV("side") ARG _pos]);
		// CALLM2(_gar, "postMethodSync", "setLocation", [_loc]);
		// CALLM0(_gar, "activate");

		pr _gar = NEW("Garrison", [GARRISON_TYPE_GENERAL ARG T_GETV("side") ARG _pos]);
		CALLM2(_gar, "postMethodSync", "setLocation", [_loc]);
		CALLM0(_gar, "activateCmdrThread");

		// Update intel about the location
		//T_CALLM1("updateLocationData", _loc);

		// Send a success message to player
		pr _args = ["We have successfully created a location here!"];
		REMOTE_EXEC_CALL_STATIC_METHOD("InGameMenuTabCommander", "showServerResponse", _args, _clientOwner, false);
		
	ENDMETHOD;

	public server METHOD(clientClaimLocation)
		params [P_THISOBJECT, P_NUMBER("_clientOwner"), P_OOP_OBJECT("_loc"), P_OBJECT("_hBuildResSrc"), P_NUMBER("_buildResAmount")];

		ASSERT_THREAD(_thisObject);

		// Check if we already own it
		private _garsFriendly = CALLM1(_loc, "getGarrisons", T_GETV("side")) select {_x in T_GETV("garrisons")};
		if (count _garsFriendly > 0) exitWith {
			private _args = ["We already own this place!"];
			REMOTE_EXEC_CALL_STATIC_METHOD("InGameMenuTabCommander", "showServerResponse", _args, _clientOwner, false);
		};

		// Check if there are still much enemy forces here
		private _thisSide = T_GETV("side");
		CALLM0(gMessageLoopMain, "lock");

		private _enemyGarrisons = CALLM0(_loc, "getGarrisons") select {
			!(CALLM0(_x, "getSide") in [_thisSide, CIVILIAN])
		};
		private _spawned = _enemyGarrisons findIf {
			!(CALLM0(_x, "getSide") in [_thisSide, CIVILIAN])
		};
		private _enemies = 0;
		{
			_enemies = _enemies + _x;
		} forEach (_enemyGarrisons apply {
			CALLM0(_x, "countConsciousInfantryUnits")
		});
		CALLM0(gMessageLoopMain, "unlock");

		// Bail if this place is still occupied by too many enemy
		if (_enemies > 4) exitWith {
			private _args = ["We can't capture this place because too many enemies still remain alive in the area!"];
			REMOTE_EXEC_CALL_STATIC_METHOD("InGameMenuTabCommander", "showServerResponse", _args, _clientOwner, false);
		};

		// Create new empty garrison for the location
		private _pos = CALLM0(_loc, "getPos");

		// Make a new garrison
		private _faction = "";
		private _templateName = "";
		private _spawned = true; // Start spawned always, client can't claim location unless player is there anyway...
		private _home = _loc;
		private _args = [GARRISON_TYPE_GENERAL, _thisSide, _pos, _faction, _templateName, _spawned, _home];
		private _gar = NEW("Garrison", _args);

		// Kick out the enemy garrisons (and claim their empty vehicles and cargo)
		{
			private _enemyGar = _x;
			// Get all the empty vehicles and cargo
			private _spoils = (CALLM1(_enemyGar, "findUnits", [[T_VEH ARG -1] ARG [T_CARGO ARG -1]]) select {
				// (isEmpty returns true for non vehicles always)
				CALLM0(_x, "isEmpty")
			});
			// Take the spoils
			if(count _spoils > 0) then {
				CALLM2(_gar, "postMethodSync", "takeUnits", [_spoils]);
			};
			CALLM2(_enemyGar, "postMethodSync", "setLocation", [NULL_OBJECT]);
		} forEach _enemyGarrisons;

		// Remove build resources from player or vehicle
		if (_hBuildResSrc isKindOf "man") then {
			// Remove resources from player
			REMOTE_EXEC_CALL_STATIC_METHOD("Unit", "removeInfantryBuildResources", [_hBuildResSrc ARG _buildResAmount], _clientOwner, false);
		} else {
			// Remove resources from vehicle
			REMOTE_EXEC_CALL_STATIC_METHOD("Unit", "removeVehicleBuildResources", [_hBuildResSrc ARG _buildResAmount], _clientOwner, false);
		};

		CALLM2(_gar, "postMethodSync", "setLocation", [_loc]);

		// Need to do this *after* assigning a location as we don't want it to get destroyed
		CALLM0(_gar, "activateCmdrThread");

		// Update intel about the location
		//T_CALLM1("updateLocationData", _loc);

		// Send a success message to player
		private _args = ["Now we own this place!"];
		REMOTE_EXEC_CALL_STATIC_METHOD("InGameMenuTabCommander", "showServerResponse", _args, _clientOwner, false);

	ENDMETHOD;

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
	METHOD(plan)
		params [P_THISOBJECT, P_OOP_OBJECT("_world")];
		
		pr _phase = T_GETV("planPhase");
		pr _generators = T_GETV("planActionGenerators");	// Array of arrays of method names
		pr _generatorIDs = T_GETV("planActionGeneratorIDs");// Array of IDs
		
		pr _ID = _generatorIDs select _phase;				// ID of next method name in the array of current phase
		pr _generatorsArray = _generators select _phase;	// Array of method names
		pr _generator = _generatorsArray select _ID;		// String, method name

		T_CALLM("_plan", [_world ARG _generator]);

		// Increase generator phase
		_ID = (_ID + 1) mod (count _generatorsArray);
		_generatorIDs set [_phase, _ID];
		_phase = (_phase + 1) mod (count _generators);
		T_SETV("planPhase", _phase);


	ENDMETHOD;

	/*
	Method: enablePlanning
	nalbes planning on a commander AI which is started.
	*/
	public METHOD(enablePlanning)
		params [P_THISOBJECT, P_BOOL("_enable")];
		T_SETV("planningEnabled", _enable);
	ENDMETHOD;
	
	/*
	Method: update
	Update active actions.
	
	Parameters:
		_world - <Model.WorldModel>, real world model the actions are being performed in.
	*/
	METHOD(update)
		params [P_THISOBJECT, P_OOP_OBJECT("_world")];

		// Sync before update
		CALLM1(_world, "sync", _thisObject);

		private _side = T_GETV("side");
		private _activeActions = T_GETV("activeActions");

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
		} forEach (_activeActions select { CALLM0(_x, "isComplete") });

		OOP_DEBUG_MSG("- - - - - U P D A T I N G   D O N E - - - - -", []);

		#ifdef OOP_INFO
		private _str = format ["{""cmdrai"": {""side"": ""%1"", ""active_actions"": %2}}", _side, count _activeActions];
		OOP_INFO_MSG(_str, []);
		#endif
	ENDMETHOD;
	
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
	/* private */ METHOD(generateAttackActions)
		params [P_THISOBJECT, P_OOP_OBJECT("_worldNow"), P_OOP_OBJECT("_worldFuture")];
		private _side = T_GETV("side");

		// Limit amount of concurrent actions
		private _activeActions = T_GETV("activeActions");
		pr _count = {GET_OBJECT_CLASS(_x) == "QRFCmdrAction"} count _activeActions;
		if (_count >= CMDR_MAX_ATTACK_ACTIONS) exitWith {[]};

		private _srcGarrisons = CALLM0(_worldNow, "getAliveGarrisons") select { 
			// Must be on our side and not involved in another action
			(GETV(_x, "side") == _side) and
			{ !CALLM0(_x, "isBusy") } and 
			{
				(
					GETV(_x, "type") == GARRISON_TYPE_GENERAL and 
					// General garrison needs officers for offensive actions
					{ CALLM0(_x, "countOfficers") >= 1 } and 
					{
						// Must have at least a minimum strength
						private _overDesiredEff = CALLM(_worldNow, "getOverDesiredEff", [_x]);
						EFF_GTE(_overDesiredEff, EFF_MIN_EFF)
					}
				) or {
					// Consider all air garrisons
					GETV(_x, "type") == GARRISON_TYPE_AIR
				}
			}
		};

		// Candidates are clusters that are still alive in the future.
		private _tgtClusters = CALLM0(_worldFuture, "getAliveClusters");

		private _actions = [];
		{
			private _srcId = GETV(_x, "id");
			{
				private _params = [_srcId, GETV(_x, "id")];
				_actions pushBack (NEW("QRFCmdrAction", _params));
			} forEach _tgtClusters;
		} forEach _srcGarrisons;

		OOP_INFO_MSG("Considering %1 QRF actions from %2 garrisons to %3 clusters", [count _actions ARG count _srcGarrisons ARG count _tgtClusters]);
		#ifdef OOP_INFO
		private _str = format ["{""cmdrai"": {""side"": ""%1"", ""action_name"": ""QRF"", ""potential_action_count"": %2, ""src_garrisons"": %3, ""tgt_clusters"": %4}}", _side, count _actions, count _srcGarrisons, count _tgtClusters];
		OOP_INFO_MSG(_str, []);
		#endif

		_actions
	ENDMETHOD;

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
	/* private */ METHOD(generateReinforceActions)
		params [P_THISOBJECT, P_OOP_OBJECT("_worldNow"), P_OOP_OBJECT("_worldFuture")];
		private _side = T_GETV("side");

		// Limit amount of concurrent actions
		private _activeActions = T_GETV("activeActions");
		pr _count = {GET_OBJECT_CLASS(_x) == "ReinforceCmdrAction"} count _activeActions;
		if (_count >= CMDR_MAX_REINFORCE_ACTIONS) exitWith {[]};

		// Take src garrisons from now, we don't want to consider future resource availability, only current.
		private _srcGarrisons = CALLM0(_worldNow, "getAliveGarrisons") select { 
			// Must be on our side and not involved in another action
			GETV(_x, "side") == _side and 
			{ !CALLM0(_x, "isBusy") } and
			{
				// Must have at least a minimum strength of twice min efficiency
				private _overDesiredEff = CALLM(_worldNow, "getOverDesiredEff", [_x]);
				EFF_GTE(_overDesiredEff, EFF_MIN_EFF)
			}
		};

		// Take tgt garrisons from future, so we take into account all in progress reinforcement actions.
		private _tgtGarrisons = CALLM0(_worldFuture, "getAliveGarrisons") select { 
			// Must be on our side
			GETV(_x, "side") == _side and 
			{
				// Not involved in another reinforce action
				private _action = CALLM0(_x, "getAction");
				IS_NULL_OBJECT(_action) or { OBJECT_PARENT_CLASS_STR(_action) != "ReinforceCmdrAction" }
			} and 
			{
				// Must be under desired efficiency by at least min reinforcement size
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
	ENDMETHOD;


	/*
	Method: (private) generateOfficerAssignmentActions
	Generate a list of officer assignments required (from airfields to bases/outposts without officers)
	
	Parameters:
		_worldNow - <Model.WorldModel>, now sim world (see <Model.WorldModel> for details)
		_worldFuture - <Model.WorldModel>, now sim world (see <Model.WorldModel> for details)

	Returns: Array of <CmdrAction.Actions.ReinforceCmdrAction>
	*/
	/* private */ METHOD(generateOfficerAssignmentActions)
		params [P_THISOBJECT, P_OOP_OBJECT("_worldNow"), P_OOP_OBJECT("_worldFuture")];
		private _side = T_GETV("side");

		// Limit amount of concurrent actions
		private _activeActions = T_GETV("activeActions");
		pr _count = {GET_OBJECT_CLASS(_x) == "ReinforceCmdrAction"} count _activeActions;
		//if (_count >= CMDR_MAX_REINFORCE_ACTIONS) exitWith {[]};

		// Take src garrisons from now, we don't want to consider future resource availability, only current.
		private _srcGarrisons = CALLM0(_worldNow, "getAliveGarrisons") select { 
			// Must be on our side and not involved in another action
			(GETV(_x, "side") == _side) and 
			{ !CALLM0(_x, "isBusy") } and
			// Has a spare officer
			{ CALLM0(_x, "countOfficers") > 1 } and
			// At a fixed location
			{ CALLM0(_x, "getLocation") != NULL_OBJECT } and
			// Has some forces to spare for escort
			{
				// Must have at least a minimum strength of twice min efficiency
				private _overDesiredEff = CALLM(_worldNow, "getOverDesiredEff", [_x]);
				EFF_GTE(_overDesiredEff, EFF_MIN_EFF)
			};
		};

		// Take tgt garrisons from future, so we take into account all in progress reinforcement actions.
		private _tgtGarrisons = CALLM0(_worldFuture, "getAliveGarrisons") select { 
			// Must be on our side
			(GETV(_x, "side") == _side) and 
			// At a fixed outpost location
			{ 
				private _loc = CALLM0(_x, "getLocation");
				(_loc != NULL_OBJECT) and 
				{
					GETV(_loc, "type") in [LOCATION_TYPE_BASE, LOCATION_TYPE_AIRPORT, LOCATION_TYPE_OUTPOST]
				}
			} and
			// And have no officers
			{ CALLM0(_x, "countOfficers") == 0 }
		};

		private _actions = [];
		{
			private _srcId = GETV(_x, "id");
			private _srcFac = GETV(_x, "faction");
			{
				private _tgtId = GETV(_x, "id");
				private _tgtFac = GETV(_x, "faction");
				if(_srcId != _tgtId and {_srcFac == _tgtFac}) then {
					private _params = [_srcId, _tgtId];
					_actions pushBack (NEW("ReinforceCmdrAction", _params));
				};
			} forEach _tgtGarrisons;
		} forEach _srcGarrisons;

		OOP_INFO_MSG("Considering %1 Officer Assignment actions from %2 garrisons to %3 garrisons", [count _actions ARG count _srcGarrisons ARG count _tgtGarrisons]);

		#ifdef OOP_INFO
		private _str = format ["{""cmdrai"": {""side"": ""%1"", ""action_name"": ""Officer Assignment"", ""potential_action_count"": %2, ""src_garrisons"": %3, ""tgt_garrisons"": %4}}", _side, count _actions, count _srcGarrisons, count _tgtGarrisons];
		OOP_INFO_MSG(_str, []);
		#endif

		_actions
	ENDMETHOD;

	/*
	Method: (private) generateSupplyActions
	Generate a list of supply missions (from airfields to bases and outposts with officers)
	
	Parameters:
		_worldNow - <Model.WorldModel>, now sim world (see <Model.WorldModel> for details)
		_worldFuture - <Model.WorldModel>, now sim world (see <Model.WorldModel> for details)

	Returns: Array of <CmdrAction.Actions.SupplyConvoyCmdrAction>
	*/
	/* private */ METHOD(generateSupplyActions)
		params [P_THISOBJECT, P_OOP_OBJECT("_worldNow"), P_OOP_OBJECT("_worldFuture")];
		private _side = T_GETV("side");

		// Limit amount of concurrent actions
		private _activeActions = T_GETV("activeActions");
		pr _count = {GET_OBJECT_CLASS(_x) == "SupplyConvoyCmdrAction"} count _activeActions;
		if (_count >= CMDR_MAX_SUPPLY_ACTIONS) exitWith {[]};

		// Take src garrisons from now, we don't want to consider future resource availability, only current.
		private _srcGarrisons = CALLM0(_worldNow, "getAliveGarrisons") select { 
			// Must be on our side and not involved in another action
			(GETV(_x, "side") == _side) and 
			{ !CALLM0(_x, "isBusy") } and
			// Has a cargo truck
			{ CALLM1(_x, "countUnits", [[T_VEH ARG T_VEH_truck_ammo]]) > 0 } and
			// At a fixed location
			{ CALLM0(_x, "getLocation") != NULL_OBJECT } and
			// Has an officer
			{ CALLM0(_x, "countOfficers") > 0 } and
			// Has some forces to spare for escort
			{
				// Must have at least a minimum strength of twice min efficiency
				private _overDesiredEff = CALLM(_worldNow, "getOverDesiredEff", [_x]);
				EFF_GTE(_overDesiredEff, EFF_MIN_EFF)
			};
		};

		// Take tgt garrisons from future, so we take into account all in progress reinforcement actions.
		private _tgtGarrisons = CALLM0(_worldFuture, "getAliveGarrisons") select { 
			// Must be on our side
			(GETV(_x, "side") == _side) and 
			// At a fixed base or outpost location
			{ 
				private _loc = CALLM0(_x, "getLocation");
				(_loc != NULL_OBJECT) and 
				{
					GETV(_loc, "type") in [LOCATION_TYPE_BASE, LOCATION_TYPE_OUTPOST]
				}
			}
			// And have an officer (we only want to set supplies )
			&& { CALLM0(_x, "countOfficers") > 0 }
		};

		private _actions = [];
		private _allCities = CALLM1(_worldNow, "getLocations", [LOCATION_TYPE_CITY]);
		{
			private _srcId = GETV(_x, "id");
			private _srcFac = GETV(_x, "faction");
			private _srcPos = GETV(_x, "pos");
			{
				private _tgtId = GETV(_x, "id");
				private _tgtFac = GETV(_x, "faction");
				private _tgtPos = GETV(_x, "pos");
				if(_srcId != _tgtId and {_srcFac == _tgtFac}) then {
					private _type = selectRandomWeighted [
						ACTION_SUPPLY_TYPE_BUILDING,	10,
						ACTION_SUPPLY_TYPE_AMMO,		5,
						ACTION_SUPPLY_TYPE_EXPLOSIVES,	1,
						ACTION_SUPPLY_TYPE_MEDICAL,		1,
						ACTION_SUPPLY_TYPE_MISC,		1
					];
					private _progress = CALLM0(gGameMode, "getAggression") + 0.4; // 0..1 + 0.4
					private _amount = 0 max random [_progress * 0.5, _progress, _progress * 1.5] min 1;
					// Find intermediate city targets
					// How many do we want?
					private _routeLen = _srcPos distance2D _tgtPos;
					private _desiredWaypoints = CLAMP(_routeLen / 1200, 1, 4);
					// Sum of distance of all cities from src -> city and city -> tgt, giving a rough value for "on routeness"
					private _cityDistSum = _allCities apply {
						private _pos = GETV(_x, "pos");
						private _srcDist = _srcPos distance2D _pos;
						private _tgtDist = _tgtPos distance2D _pos;
						// Randomize the items so we don't get the same route every time
						[_srcDist + _tgtDist + random (_routeLen / 3), _srcDist, _x]
					};
					// Sort by summed distance
					_cityDistSum sort ASCENDING;
					private _cityDistSrc = (_cityDistSum select [0, _desiredWaypoints]) apply { 
						// Remove the sum distance leaving just the dist from src
						[_x#1, _x#2] 
					};
					// Sort by distance from source
					_cityDistSrc sort ASCENDING;
					// Make targets array
					private _waypoints = _cityDistSrc apply {
						[TARGET_TYPE_LOCATION, GETV(_x#1, "id")]
					};
					private _params = [_srcId, _tgtId, _waypoints, _type, _amount];
					_actions pushBack (NEW("SupplyConvoyCmdrAction", _params));
				};
			} forEach _tgtGarrisons;
		} forEach _srcGarrisons;

		OOP_INFO_MSG("Considering %1 Supply actions from %2 garrisons to %3 garrisons", [count _actions ARG count _srcGarrisons ARG count _tgtGarrisons]);

		#ifdef OOP_INFO
		private _str = format ["{""cmdrai"": {""side"": ""%1"", ""action_name"": ""Supply"", ""potential_action_count"": %2, ""src_garrisons"": %3, ""tgt_garrisons"": %4}}", _side, count _actions, count _srcGarrisons, count _tgtGarrisons];
		OOP_INFO_MSG(_str, []);
		#endif

		_actions
	ENDMETHOD;

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
	/* private */ METHOD(generateTakeOutpostActions)
		params [P_THISOBJECT, P_OOP_OBJECT("_worldNow"), P_OOP_OBJECT("_worldFuture")];
		private _activeActions = T_GETV("activeActions");
		private _side = T_GETV("side");

		// Limit amount of concurrent actions
		private _activeActions = T_GETV("activeActions");
		pr _count = {GET_OBJECT_CLASS(_x) == "TakeLocationCmdrAction"} count _activeActions;
		if (_count >= CMDR_MAX_TAKE_OUTPOST_ACTIONS) exitWith {[]};

		// Take src garrisons from now, we don't want to consider future resource availability, only current.
		private _srcGarrisons = CALLM(_worldNow, "getAliveGarrisons", [["military"]]) select { 
			// Must be not already busy 
			!CALLM0(_x, "isBusy") and 
			// Must have an officer for an offensive action
			{ CALLM0(_x, "countOfficers") >= 1 } and 
			// Must be at a location
			{ !IS_NULL_OBJECT(CALLM0(_x, "getLocation")) } and 
			// Must not be source of another inprogress take location mission
			{ 
				private _potentialSrcGarr = _x;
				private _activeActions = T_GETV("activeActions");
				_activeActions findIf {
					GET_OBJECT_CLASS(_x) == "TakeLocationCmdrAction" and
					{ GETV(_x, "srcGarrId") == GETV(_potentialSrcGarr, "id") }
				} == NOT_FOUND
			} and
			// Must have minimum efficiency available
			{
				// Must have at least a minimum available eff
				private _overDesiredEff = CALLM(_worldNow, "getOverDesiredEff", [_x]);
				EFF_GTE(_overDesiredEff, EFF_MIN_EFF)
			}
		};

		// Take tgt locations from future, so we take into account all in progress actions.
		private _tgtLocations = CALLM0(_worldFuture, "getLocations") select { 
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
				if(_dist < 10000) then {
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
	ENDMETHOD;

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
	/* private */ METHOD(generatePatrolActions)
		params [P_THISOBJECT, P_OOP_OBJECT("_worldNow"), P_OOP_OBJECT("_worldFuture")];
		private _activeActions = T_GETV("activeActions");
		private _side = T_GETV("side");

		// Already patrolling source garrisons
		private _garrisonsAlreadyPatrolling = _activeActions select {
			GET_OBJECT_CLASS(_x) == "PatrolCmdrAction"
		} apply {
			private _srcGarrId = GETV(_x, "srcGarrId");
			CALLM1(_worldNow, "getGarrison", _srcGarrId)
		};

		// List of garrisons big enough to send out a patrol
		private _srcGarrisons = CALLM(_worldNow, "getAliveGarrisons", [["military" ARG "police"]]) select { 
			private _potentialSrcGarr = _x;

			// Must be not already busy 
			!CALLM0(_potentialSrcGarr, "isBusy")
			// Must be at a location
			&& { 
				private _loc = CALLM0(_potentialSrcGarr, "getLocation");
				!IS_NULL_OBJECT(_loc)
				&& {
					GETV(_loc, "type") in [LOCATION_TYPE_OUTPOST, LOCATION_TYPE_BASE, LOCATION_TYPE_AIRPORT]
				}
			}
			// Must have minimum patrol available
			&& {
				private _garEff = GETV(_potentialSrcGarr, "efficiency");
				private _overEff = EFF_DIFF(_garEff, EFF_MIN_EFF);
				// CALLM(_worldNow, "getOverDesiredEff", [_potentialSrcGarr]);
				// Must have at least a minimum available eff
				EFF_GTE(_overEff, EFF_MIN_EFF)
			}
		};
		if(count _srcGarrisons == 0) exitWith { [] };

		// Determine list of cities to patrol, excluding those in enemy hands, or already being patrolled
		private _citiesToPatrol = CALLM(_worldNow, "getLocations", [[LOCATION_TYPE_CITY]]) select {
			private _pos = GETV(_x, "pos");
			// Damage score is negative if we don't want to attack it any more
			CALLM2(_worldNow, "getDamageScore", _pos, 1000) > 0
		};
		if(count _citiesToPatrol == 0) exitWith { [] };

		// Divide cities between locations
		private _garrisonAssignments = _srcGarrisons apply { [_x, []] };
		{
			private _cityPos = GETV(_x, "pos");
			private _garrDist = _garrisonAssignments apply { 
				private _garr = _x#0;
				private _loc = CALLM0(_garr, "getLocation");
				// Scale distance so we give different area of influence based on location types
				private _distMul = switch (GETV(_loc, "type")) do {
					case LOCATION_TYPE_AIRPORT: { 1 };
					case LOCATION_TYPE_BASE: { 1.2 };
					case LOCATION_TYPE_OUTPOST: { 2 };
					default { 1000 };
				};
				[
					(GETV(_garr, "pos") distance _cityPos) * _distMul,
					_x
				]
			};
			_garrDist sort ASCENDING;
			(_garrDist#0#1#1) pushBackUnique _x;
		} forEach _citiesToPatrol;

		// Generate new patrol actions for each locations set of cities

		private _actions = [];
		{
			_x params ["_srcGarrison", "_cities"];
			private _srcPos = GETV(_srcGarrison, "pos");

			private _orderedCities = _cities apply {
				[_srcPos getDir GETV(_x, "pos"), GETV(_x, "id")]
			};
			_orderedCities sort ASCENDING;
			private _routeTargets = _orderedCities apply {
				_x params ["_dir", "_locId"];
				[TARGET_TYPE_LOCATION, _locId]
			};
			private _params = [GETV(_srcGarrison, "id"), _routeTargets];
			_actions pushBack (NEW("PatrolCmdrAction", _params));
		} forEach (_garrisonAssignments select {
			// Must not be already doing a patrol
			_x params ["_srcGarrison", "_cities"];
			!(_srcGarrison in _garrisonsAlreadyPatrolling) && {count _cities > 0}
		});

		OOP_INFO_MSG("Considering %1 Patrol actions from %2 garrisons", [count _actions ARG count _srcGarrisons]);

		#ifdef OOP_INFO
		private _str = format ["{""cmdrai"": {""side"": ""%1"", ""action_name"": ""Patrol"", ""potential_action_count"": %2, ""src_garrisons"": %3}}", _side, count _actions, count _srcGarrisons];
		OOP_INFO_MSG(_str, []);
		#endif

		_actions
	ENDMETHOD;

	METHOD(generateConstructRoadblockActions)
		params [P_THISOBJECT, P_OOP_OBJECT("_worldNow"), P_OOP_OBJECT("_worldFuture")];

		// Limit amount of concurrent actions
		private _activeActions = T_GETV("activeActions");
		pr _count = {GET_OBJECT_CLASS(_x) == "ConstructLocationCmdrAction"} count _activeActions;
		//OOP_INFO_1("  Existing patrol actions: %1", _count);
		if (_count > CMDR_MAX_CONSTRUCT_ACTIONS) exitWith {[]};

		OOP_INFO_0("GENERATE CONSTRUCT ROADBLOCK ACTIONS: start. Searching source garrisons.");

		// Take src garrisons from now, we don't want to consider future resource availability, only current.
		private _srcGarrisons = CALLM(_worldNow, "getAliveGarrisons", [["military"]]) select { 
			private _potentialSrcGarr = _x;
			// Must be not already busy 
			!CALLM0(_potentialSrcGarr, "isBusy") and 
			// Must have an officer
			{ CALLM0(_x, "countOfficers") >= 1 } and 
			// Must be at a location
			{ !IS_NULL_OBJECT(CALLM0(_potentialSrcGarr, "getLocation")) } and 
			// Must not be source of another mission
			{ 
				private _activeActions = T_GETV("activeActions");
				_activeActions findIf {
					GET_OBJECT_CLASS(_x) == "ConstructLocationCmdrAction" and
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

		OOP_INFO_0("GENERATE CONSTRUCT ROADBLOCK ACTIONS: selecting potential positions");

		// Take potential location positions from the future
		// In the future there must be no location around these places
		pr _potentialPositions = T_GETV("newRoadblockPositions");
		_potentialPositions = _potentialPositions select {
			pr _locs = CALLM4(_worldFuture, "getNearestLocations", _x, 200, [], []);
			count _locs == 0 // There are no locations nearby in the future
		};

		OOP_INFO_0("GENERATE CONSTRUCT ROADBLOCK ACTIONS: iterating positions and source garrisons");

		private _strategy = T_GETV("cmdrStrategy");
		private _actions = [];
		private _side = T_GETV("side");
		{
			private _srcId = GETV(_x, "id");
			private _srcPos = GETV(_x, "pos");
			{
				private _locPos = _x;
				OOP_INFO_2("  Analyzing construct location: %1 -> %2", _srcID, _locPos);
				private _locType = LOCATION_TYPE_ROADBLOCK;
				// Check strategy
				// We only want to create those where it makes sense to create them
				// We check desireability first to limit the amount of potential actions early in our evaluations
				if (CALLM4(_strategy, "getConstructLocationDesirability", _worldNow, _locPos, _locType, _side) > 0) then {
					private _dist = _srcPos distance _locPos;
					if(_dist < 2200) then { // Only consider deploying roadblocks within some distance
						private _params = [_srcId, _locPos, _locType];
						_actions pushBack (NEW("ConstructLocationCmdrAction", _params));
					};
				};
			} forEach _potentialPositions;
		} forEach _srcGarrisons;

		OOP_INFO_MSG("Considering %1 ConstructLocation roadblock actions from %2 garrisons to %3 positions", [count _actions ARG count _srcGarrisons ARG count _potentialPositions]);

		#ifdef OOP_INFO
		private _str = format ["{""cmdrai"": {""side"": ""%1"", ""action_name"": ""ConstructLocation"", ""potential_action_count"": %2, ""src_garrisons"": %3, ""tgt_positions"": %4}}", _side, count _actions, count _srcGarrisons, count _potentialPositions];
		OOP_INFO_MSG(_str, []);
		#endif

		_actions
	ENDMETHOD;
	
	#define VEHICLE_STOCK_FN(_progress, _rate) (0 max (_rate * (_progress ^ _rate)))

	/*
	Method: updateRecruitment
	Should be called on each process;
	*/
	METHOD(updateRecruitment)
		params [P_THISOBJECT];

		OOP_INFO_0("UPDATE RECRUITMENT");

		pr _side = T_GETV("side");
		pr _model = T_GETV("worldModel");
		pr _strategy = T_GETV("cmdrStrategy");

		pr _garrisonsAtLocations = T_GETV("garrisons") select {
			pr _loc = CALLM0(_x, "getLocation");

			if (!IS_NULL_OBJECT(_loc)) then {
				CALLM0(_loc, "getType") in LOCATIONS_RECRUIT;
			} else {
				false;
			};
		};

		pr _reinfData = [];
		pr _recruitCities = [];

		
		{ // forEach CALLM0(_model, "getLocations");
			private _locType = GETV(_x, "type");

			OOP_INFO_2("  Checking location: %1 at %2", CALLM0(GETV(_x, "actual"), "getName"), GETV(_x, "pos"));

			// One of location types where we can recruit at (outpost, airfield, etc)
			if (_locType in LOCATIONS_RECRUIT) then {
				private _garModel = CALLM1(_x, "getGarrison", _side);
				if (!IS_NULL_OBJECT(_garModel)) then {					// There is a friendly garrison there
					private _garActual = GETV(_garModel, "actual");
					if	(												// Friendly garrison is not spawned
							#ifndef REINFORCEMENT_TESTING
							!CALLM0(_garActual, "isSpawned")
							#else
							true
							#endif
							FIX_LINE_NUMBERS()
						) then {
						if ( (GETV(_garModel, "type") == GARRISON_TYPE_GENERAL)) then {	// Friendly garrison is of general type
							private _comp = GETV(_garModel, "composition");
							private _nInf = [_comp] call comp_fnc_countInfantry;
							private _locPos = GETV(_x, "pos");
							private _locMaxInf = GETV(_x, "capacityInf");
							if (_nInf < _locMaxInf) then {					// It's not overcrowded
																			// If there is a city with some recruits nearby
								private _nearestRecruitCity = CALLM3(gGameMode, "getNearestRecruitCity", +_locPos, _side, 6);
								if (!IS_NULL_OBJECT(_nearestRecruitCity) && {!(_nearestRecruitCity in _recruitCities)}) then {
									pr _availRecruits = CALLM2(gGameMode, "getRecruitCount", [_nearestRecruitCity], _side);

									OOP_INFO_3("   Nearest recruit city: %1 %2 at %3", _nearestRecruitCity, CALLM0(_nearestRecruitCity, "getName"), CALLM0(_nearestRecruitCity, "getPos"));

									private _locActual = GETV(_x, "actual");
									private _activity = CALLM1(_model, "getActivity", _locPos);
									_reinfData pushBack [_activity, _garActual, _locActual, _nearestRecruitCity, _nInf, _locMaxInf, _availRecruits];
									_recruitCities pushBack _nearestRecruitCity;
								} else {
									OOP_INFO_0("   No nearest recruit city nearby or it was used already");
								};
							} else {
								OOP_INFO_2("   Inf capacity reached (%1 / %2)", _nInf, _locMaxInf);
							};
						} else {
							OOP_INFO_0("   Not general type garrison");
						};
					} else {
						OOP_INFO_0("   Is spawned");
					};
				} else {
					OOP_INFO_0("   No friendly garrison here");
				};
			//} else {
			//	OOP_INFO_0("   Not a recruitment location");
			};
		} forEach CALLM0(_model, "getLocations");

		_reinfData sort ASCENDING;
		#ifdef OOP_INFO
		OOP_INFO_0("Potential recruitments:");
		{
			_x params ["_activity", "_garActual", "_locActual", "_nearestRecruitCity", "_nInf", "_locMaxInf", "_availRecruits"];
			OOP_INFO_4("    %1 at %2     <--       %3 (%4 recruits)", CALLM0(_locActual, "getName"), GETV(_locActual, "pos"), CALLM0(_nearestRecruitCity, "getName"), _availRecruits);
		} forEach _reinfData;
		#endif

		// Estimate infantry requirements
		private _desiredLocations = [];
		{
			private _locModel = _x;
			if (!IS_NULL_OBJECT(_locModel)) then { // Sanity check
				private _actual = GETV(_locModel, "actual");
				private _desirability = CALLM3(_strategy, "getLocationDesirability", _model, _locModel, _side);
				if (_desirability > 0) then {
					_desiredLocations pushBack _actual;
				};
			};
		} forEach CALLM0(_model, "getLocations");

		// Sum up all the required efficiency
		private _effRequiredAll = +T_EFF_null;
		{
			private _pos = CALLM0(_x, "getPos");
			private _effDesiredHere = +CALLM1(_model, "getDesiredEff", _pos);

			[_effRequiredAll, _effDesiredHere] call eff_fnc_acc_add;
		} foreach _desiredLocations;

		// Make some reasonable limits to the desired amount of units
		private _maxInfOnMap = (count _desiredLocations) * CALLSM1("Location", "getCapacityInfForType", LOCATION_TYPE_OUTPOST) + 100;
		OOP_INFO_1("  max inf on map: %1", _maxInfOnMap);
		if ((_effRequiredAll#T_EFF_crew) > _maxInfOnMap) then {
			OOP_INFO_1("  limited the maximum amount of desired infantry! Calculated: %1", _effRequiredAll#T_EFF_crew);
			_effRequiredAll set [T_EFF_crew, _maxInfOnMap];
		};

		// Sum up efficiency of all garrisons and guess how many officers we want
		private _effAll = CALLM0(_model, "getGlobalEff");

		OOP_INFO_1("  All required eff: %1", _effRequiredAll);
		OOP_INFO_1("  All current  eff: %1", _effAll);

		// Amount of infantry we want to have
		private _infMoreRequired = (_effRequiredAll select T_EFF_crew) - (_effAll select T_EFF_crew);

		OOP_INFO_1("  More infantry required: %1", _infMoreRequired);

		private _squadTypes = [T_GROUP_inf_assault_squad, T_GROUP_inf_rifle_squad];
		OOP_INFO_1("  Trying to add %1 more infantry...", _infMoreRequired);

		// Try to add recruits
		private _t = CALLM2(gGameMode, "getTemplate", T_GETV("side"), "military");
		while {_infMoreRequired > 0 && count _reinfData > 0} do {

			pr _reinfDataThis = _reinfData#0;
			_reinfDataThis params ["_activity", "_garActual", "_locActual", "_nearestRecruitCity", "_nInf", "_locMaxInf", "_availRecruits"];

			// Select a random group type
			private _subcatID = selectRandom _squadTypes;
			private _countInfInGroup = count (_t#T_GROUP#_subcatID#0); // Amount of units

			private _nGroups = floor (_availRecruits / _countInfInGroup);

			for "_groupID" from 0 to (_nGroups - 1) do {
				// Create a group
				private _group = NEW("Group", [_side ARG GROUP_TYPE_INF]);
				CALLM2(_group, "createUnitsFromTemplate", _t, _subcatID);
				CALLM2(_garActual, "postMethodAsync", "addGroup", [_group]);
				OOP_INFO_1("   Added group: %1", _group);

				// Decrease the counter
				_infMoreRequired = _infMoreRequired - _countInfInGroup;

				OOP_INFO_4("  Added group %1 of %2 units to %3 at %4", _group, _countInfInGroup, _garActual, CALLM0(_locActual, "getName"));
			};

			_reinfData deleteAt 0;
		};

		if(_infMoreRequired > 0) then {
			OOP_INFO_1("  Could not add all infantry required, %1 remain", _infMoreRequired);
		};

	ENDMETHOD;

	/*
	Method: updateExternalReinforcement
	Should be called on each process. Updates external reinforcements.
	*/
	METHOD(updateExternalReinforcement)
		params [P_THISOBJECT];

		// Bail if it's not time to consider reinforcement yet...
		private _datePrevReinf = T_GETV("datePrevExtReinf");
		private _dateNextReinf = +_datePrevReinf;
		// How ofter commander will consider to import external reinforcements
		private _reinfInterval = MAP_LINEAR_SET_POINT(1 - vin_diff_global, 15, 60, 180);
		_dateNextReinf set [4, _dateNextReinf#4 + _reinfInterval];

		#ifndef REINFORCEMENT_TESTING
		if ( (dateToNumber date) < (dateToNumber _dateNextReinf) ) exitWith {
		};
		#endif
		FIX_LINE_NUMBERS()

		OOP_INFO_0("UPDATE EXTERNAL REINFORCEMENT");

		private _t = CALLM2(gGameMode, "getTemplate", T_GETV("side"), "military");

		// Pick an airfield we own
		private _side = T_GETV("side");
		private _model = T_GETV("worldModel");

		private _reinfLocations = CALLM0(_model, "getLocations") select {
			private _garModel = CALLM1(_x, "getGarrison", _side);
			(GETV(_x, "type") == LOCATION_TYPE_AIRPORT)
			&& {!IS_NULL_OBJECT(_garModel)}
			#ifndef REINFORCEMENT_TESTING
			&& {private _actual = GETV(_garModel, "actual"); !CALLM0(_actual, "isSpawned")}
			#endif
			FIX_LINE_NUMBERS()
		};

		// Bail if we can't bring reinforcements anywhere
		if (count _reinfLocations == 0) exitWith {
			OOP_INFO_0("  Can't bring reinforcements anywhere: no suitable owned locations found!");
		};

		// Get all desired locations
		private _strategy = T_GETV("cmdrStrategy");
		private _locations = CALLM0(_model, "getLocations");
		private _desiredLocations = [];
		{
			private _locModel = _x;
			if (!IS_NULL_OBJECT(_locModel)) then { // Sanity check
				private _actual = GETV(_locModel, "actual");
				private _desirability = CALLM3(_strategy, "getLocationDesirability", _model, _locModel, _side);
				if (_desirability > 0) then {
					_desiredLocations pushBack _actual;
				};
			};
		} forEach _locations;

		OOP_INFO_1("  All desired locations: %1", _desiredLocations);

		// Sum up all the required efficiency
		private _effRequiredAll = +T_EFF_null;
		{
			private _pos = CALLM0(_x, "getPos");
			private _effDesiredHere = +CALLM1(_model, "getDesiredEff", _pos);

			[_effRequiredAll, _effDesiredHere] call eff_fnc_acc_add;
		} foreach _desiredLocations;

		// Make some reasonable limits to the desired amount of units
		private _maxInfOnMap = (count _desiredLocations) * CALLSM1("Location", "getCapacityInfForType", LOCATION_TYPE_OUTPOST) + 100;
		OOP_INFO_1("  max inf on map: %1", _maxInfOnMap);
		if ((_effRequiredAll#T_EFF_crew) > _maxInfOnMap) then {
			OOP_INFO_1("  limited the maximum amount of desired infantry! Calculated: %1", _effRequiredAll#T_EFF_crew);
			_effRequiredAll set [T_EFF_crew, _maxInfOnMap];
		};

		// Sum up efficiency of all garrisons and guess how many officers we want
		private _effAll = CALLM0(_model, "getGlobalEff");

		OOP_INFO_1("  All required eff: %1", _effRequiredAll);
		OOP_INFO_1("  All current  eff: %1", _effAll);

		// Amount of infantry and transport we want to have
		private _infMoreRequired = (_effRequiredAll select T_EFF_crew) - (_effAll select T_EFF_crew);
		private _transportMoreRequired = (_effAll select T_EFF_reqTransport) - (_effAll select T_EFF_transport);

		OOP_INFO_2("  More inf required: %1, more transport required: %2", _infMoreRequired, _transportMoreRequired);

		// Amount of armor we want to have overall
		private _armorAll = (_effAll#T_EFF_medium) + (_effAll#T_EFF_armor);
		private _armorRequiredAll = 0;
		
		#ifdef REINFORCEMENT_TESTING
		if(isNil "gDebugReinfProgress") then { gDebugReinfProgress = 0; };
		private _progress = gDebugReinfProgress;
		gDebugReinfProgress = gDebugReinfProgress + 0.1;
		systemChat format ["Reinforcing %1 now at %2 progress", _side, _progress];
		#else
		private _progress = CALLM0(gGameMode, "getAggression"); // 0..1
		#endif
		FIX_LINE_NUMBERS()

		private _progressScaled = MAP_GAMMA(vin_diff_global, _progress);
		OOP_INFO_2("  Campaign progess: %1, scaled by difficulty setting: %2", _progress, _progressScaled);
		{
			private _type = CALLM0(_x, "getType");
			private _add = 0;
			if (_type == LOCATION_TYPE_AIRPORT) then { _add = 6 + 10 * _progressScaled; };
			if (_type == LOCATION_TYPE_OUTPOST) then { _add = 1 + 3 * _progressScaled; };
			if (_type == LOCATION_TYPE_BASE) 	then { _add = 4 + 5 * _progressScaled; };
			if (_type == LOCATION_TYPE_CITY) 	then { _add = 1 + 1 * _progressScaled; };
			_armorRequiredAll = _armorRequiredAll + _add;
		} forEach _desiredLocations;

		private _armorMoreRequired = _armorRequiredAll - _armorAll;

		OOP_INFO_1("  All armor (MRAPs and Armor) we have: %1", _armorAll);
		OOP_INFO_1("  Desired amount of all armor: %1", _armorRequiredAll);
		OOP_INFO_1("  More armor required: %1", _armorMoreRequired);

		// Max amount of vehicles at airfields
		private _nVehMax = MAP_LINEAR(_progressScaled, 0.25, 1) * CMDR_MAX_VEH_AIRFIELD;

		// if (_progressScaled < 0.25) then {
		// 	round 0.5*CMDR_MAX_VEH_AIRFIELD
		// } else {
		// 	CMDR_MAX_VEH_AIRFIELD
		// };

		// [_name, _loc, _garrison, _infSpace, _vicSpace]
		// Locations that we can reinforce with ground units
		private _reinfInfo = _reinfLocations apply {
			private _locModel = _x;
			private _loc = GETV(_locModel, "actual");
			private _generalGarrisons = CALLM2(_loc, "getGarrisons", _side, GARRISON_TYPE_GENERAL);
			if(count _generalGarrisons > 0) then {
				private _nInf = 0; 
				private _nVeh = 0;
				// We want to include all garrisons that consider this location home, not just the one at the location currently
				// (i.e. QRFs, attacks, convoys etc, that may return again)
				{
					_nInf = _nInf + CALLM0(_x, "countInfantryUnits");
					_nVeh = _nVeh + CALLM1(_x, "countUnits", T_PL_tracked_wheeled); // All tracked and wheeled vehicles
				} forEach CALLM2(_loc, "getHomeGarrisons", _side, GARRISON_TYPE_GENERAL);
				[
					CALLM0(_loc, "getDisplayName"),
					_loc,
					_generalGarrisons # 0,
					CALLSM1("Location", "getCapacityInfForType", LOCATION_TYPE_AIRPORT) - _nInf,
					(_nVehMax - _nVeh) min CMDR_MAX_GROUND_VEH_EACH_EXTERNAL_REINFORCEMENT
				]
			} else {
				[]
			};
		} select {
			!(_x isEqualTo [])
		};

		// Locations that we can reinforce with air units
		private _airReinfInfo = _reinfLocations select {
			GETV(_x, "type") == LOCATION_TYPE_AIRPORT
		} apply {
			private _loc = GETV(_x, "actual");

			private _airGarrisons = CALLM2(_loc, "getGarrisons", _side, GARRISON_TYPE_AIR);

			// Create air garrison if it doesn't exist, we already have a 
			private _airGarr = if(count _airGarrisons == 0) then {
				private _templateName = CALLM2(gGameMode, "getTemplateName", _side, "military");
				private _args = [GARRISON_TYPE_AIR, _side, [], "military", _templateName];
				private _gar = NEW("Garrison", _args);
				CALLM2(_gar, "postMethodSync", "setLocation", [_loc]);
				CALLM0(_gar, "activateCmdrThread");
				_gar
			} else {
				_airGarrisons # 0
			};

			private _nHeli = 0;
			private _nPlane = 0;

			// We want to include all garrisons that consider this location home, not just the one at the location currently
			// (i.e. QRFs, attacks, convoys etc, that may return again)
			{
				_nHeli = _nHeli + CALLM1(_x, "countUnits", T_PL_helicopters);
				_nPlane = _nPlane + CALLM1(_x, "countUnits", T_PL_planes);
			} forEach CALLM2(_loc, "getHomeGarrisons", _side, GARRISON_TYPE_AIR);

			private _nHeliSpace = CALLM0(_loc, "getCapacityHeli");
			private _nPlaneSpace = CALLM0(_loc, "getCapacityPlane");
			private _nHeliMax = ceil (_nHeliSpace * VEHICLE_STOCK_FN(_progressScaled, 1) * 1.3);
			private _nPlaneMax = ceil (_nPlaneSpace * VEHICLE_STOCK_FN(_progressScaled, 1) * 1.3);
			[
				_airGarr,
				(CLAMP(_nHeliMax, 0, _nHeliSpace) - _nHeli) min 1,
				(CLAMP(_nPlaneMax, 0, _nPlaneSpace) - _nPlane) min 1
			]
		};

		// Add air
		if (_progressScaled > 0.3 && ([_t, T_VEH, T_VEH_heli_attack, 0] call t_fnc_isValid)) then {
			{
				_x params ["_airGar", "_nHelisRequired", "_mPlanesRequired"];
				for "_i" from 0 to _nHelisRequired - 1 do {
					private _type = T_VEH_heli_attack;
					// selectRandomWeighted [
					// 	T_VEH_heli_light,	1,
					// 	T_VEH_heli_heavy,	1,
					// 	T_VEH_heli_attack,	1
					// ];
					private _newGroup = CALLM2(_airGar, "postMethodAsync", "createAddVehGroup", [_side ARG T_VEH ARG _type ARG -1]);
					OOP_INFO_MSG("%1: Created heli group %2", [_airGar ARG _newGroup]);
				};
			} forEach _airReinfInfo;
		};

		// Try to spawn more units at the selected locations
		// Inf spawning at airfields is disabled now
		/*
		if (_infMoreRequired > 0) then {
			private _infReinfLocations = _reinfInfo select {
				_x#3 > 0
			};

			private _squadTypes = [T_GROUP_inf_assault_squad, T_GROUP_inf_rifle_squad];
			OOP_INFO_1("  Trying to add %1 more infantry...", _infMoreRequired);

			while {_infMoreRequired > 0 && count _infReinfLocations > 0} do {
				// Select random airfield
				//  0      1     2          3          4
				// [_name, _loc, _garrison, _infSpace, _vicSpace]
				private _targetLoc = selectRandom _infReinfLocations;
				_targetLoc params ["_name", "_loc", "_garrison", "_infSpace", "_vicSpace"];

				// Select a random group type
				private _subcatID = selectRandom _squadTypes;
				private _countInfInGroup = count (_t#T_GROUP#_subcatID#0); // Amount of units

				// Create a group
				private _group = NEW("Group", [_side ARG GROUP_TYPE_INF]);
				CALLM2(_group, "createUnitsFromTemplate", _t, _subcatID);
				CALLM2(_garrison, "postMethodAsync", "addGroup", [_group]);
				OOP_INFO_1("   Added group: %1", _group);

				// Decrease the counter
				_infMoreRequired = _infMoreRequired - _countInfInGroup;
				private _roomLeft = _infSpace - _countInfInGroup;
				if(_roomLeft <= 0) then {
					_infReinfLocations = _infReinfLocations - [_targetLoc];
				} else {
					_targetLoc set [3, _roomLeft];
				};
			};

			if(_infMoreRequired > 0) then {
				OOP_INFO_1("  Could not add all infantry required, %1 remain", _infMoreRequired);
			}
		};
		*/

		// Spawn in more officers
		{
			_x params ["_name", "_loc", "_garrison", "_infSpace", "_vicSpace"];
			private _nOfficersRequired = 3 - CALLM0(_garrison, "countOfficers");

			OOP_INFO_2("  Adding %1 officers at %2", _nOfficersRequired, _name);
			while { _nOfficersRequired > 0 } do {
				// Create an officer group
				private _group = NEW("Group", [_side ARG GROUP_TYPE_INF]);
				CALLM2(_group, "createUnitsFromTemplate", _t, T_GROUP_inf_officer);
				CALLM2(_garrison, "postMethodAsync", "addGroup", [_group]);
				_nOfficersRequired = _nOfficersRequired - 1;
			};
		} forEach _reinfInfo;

		private _fn_spawnNUnits = {
			params ["_cat", "_subcat", "_desired", "_t", "_unitDebugName", "_reinfInfoThis"];
			if ([_t, T_VEH, _subcat, 0] call t_fnc_isValid) then {
				_reinfInfoThis params ["_name", "_loc", "_garrison", "_infSpace", "_vicSpace"];
				private _nRequired = _desired - CALLM1(_garrison, "countUnits", [[_cat ARG _subcat]]);

				OOP_INFO_3("  Adding %1 %2 at %3", _nRequired, _unitDebugName, _name);
				while { _nRequired > 0 } do {
					private _args = [_t, _cat, _subcat, -1];
					private _vehUnit = NEW("Unit", _args);

					CALLM2(_garrison, "postMethodAsync", "addUnit", [_vehUnit]);
					_nRequired = _nRequired - 1;
				};
			};
		};

		// Create some utility vehicles
		pr _utilitySpec = [];
		#define __ADD_UTIL_SPEC_SAFE(array, amount, subcat, name) if ([_t, T_VEH, subcat, 0] call t_fnc_isValid) then { \
			array pushback [amount, subcat, name]; \
		}
		__ADD_UTIL_SPEC_SAFE(_utilitySpec, 2, T_VEH_truck_ammo, "supply trucks");
		//__ADD_UTIL_SPEC_SAFE(_utilitySpec, 3, T_VEH_truck_inf, "infantry trucks");
		__ADD_UTIL_SPEC_SAFE(_utilitySpec, 2, T_VEH_car_unarmed, "unarmed cars");

		{
			pr _reinfInfo0 = _x;
			{
				_x params ["_amount", "_subcatID", "_name"];
				[T_VEH, _subcatID, _amount, _t, _name, _reinfInfo0] call _fn_spawnNUnits;
			} forEach _utilitySpec;
		} forEach _reinfInfo;

		// Spawn in more vehicles

		// Construct a pool of vehicles we could add and shuffle them up then add some of them

		// // If campaign progress is big enough, give them more armored transport
		// // https://www.desmos.com/calculator/hhw3uxcjds
		// // If it's low, just give trucks
		// private _transportRatios = [
		// 	T_VEH_truck_inf, 	1,
		// 	T_VEH_APC, 			0 max (2 * (_progressScaled ^ 2)),
		// 	T_VEH_IFV, 			0 max (3 * (_progressScaled ^ 3))
		// ];

		// // Armor types depend on progress
		// private _armorRatios = [
		// 	T_VEH_MRAP_HMG, 	1,
		// 	T_VEH_MRAP_GMG, 	0 max (1 * (_progressScaled ^ 1)) min 1,
		// 	T_VEH_APC, 			0 max (2 * (_progressScaled ^ 2)),
		// 	T_VEH_IFV, 			0 max (3 * (_progressScaled ^ 3)),
		// 	T_VEH_MBT, 			0 max (5 * (_progressScaled ^ 5))
		// ];

		private _vehRatios = [
			[T_VEH_truck_inf, 	0.2],
			[T_VEH_car_armed, 	0.05],
			//T_VEH_APC, 			0 max (2 * (_progressScaled ^ 2)),
			//T_VEH_IFV, 			0 max (3 * (_progressScaled ^ 3))
			[T_VEH_MRAP_HMG, 	0.1],
			[T_VEH_MRAP_GMG, 	0.1 max (0.3 * (_progressScaled ^ 0.8)) min 1],
			[T_VEH_APC, 		0 max (2 * (_progressScaled ^ 2))],
			[T_VEH_IFV, 		0 max (3 * (_progressScaled ^ 3))],
			[T_VEH_MBT, 		0 max (4 * (_progressScaled ^ 4))]
		];
		// Select only those which are present in template
		_vehRatios = _vehRatios select {
			pr _subcatid = _x#0;
			[_t, T_VEH, _subcatid, 0] call t_fnc_isValid;
		};
		private _vehThatNeedGroups = [T_VEH_APC, T_VEH_IFV, T_VEH_MBT, T_VEH_car_armed];

		private _ratioSum = 0;
		{ _ratioSum = _ratioSum + _x#1 } forEach _vehRatios;
		_vehRatios = _vehRatios apply { [_x#0, _x#1 / _ratioSum] };

		private _vicReinfLocations = _reinfInfo select {
			_x#4 > 0
		};

		{// forEach collection
			_x params ["_name", "_loc", "_garrison", "_infSpace", "_vicSpace"];
			while {_vicSpace > 0} do {
				private _currRatios = _vehRatios apply { [_x#0, _x#1, CALLM1(_garrison, "countUnits", [[T_VEH ARG _x#0]])] };
				private _bestVeh = -1;
				private _bestDiff = 0;
				{
					// Difference in desired ratio and current ratio
					private _ratioDiff = _x#1 - _x#2;
					if(_ratioDiff >= _bestDiff) then {
						_bestDiff = _ratioDiff;
						_bestVeh = _x#0;
					};
				} forEach _currRatios;

				if(_bestVeh != -1) then {
					if(_bestVeh in _vehThatNeedGroups) then {
						// Create a group
						// It's better to add combat vehicles with a group, so that AIs can use them instantly
						private _group = NEW("Group", [_side ARG GROUP_TYPE_VEH]);
						private _args = [_t, T_VEH, _bestVeh, -1, _group];
						private _vehUnit = NEW("Unit", _args);
						CALLM1(_group, "addUnit", _vehUnit);
						CALLM1(_vehUnit, "createDefaultCrew", _t);

						CALLM2(_garrison, "postMethodAsync", "addGroup", [_group]);
					} else {
						private _args = [_t, T_VEH, _bestVeh, -1];
						private _vehUnit = NEW("Unit", _args);

						CALLM2(_garrison, "postMethodAsync", "addUnit", [_vehUnit]);
					};
				};
				_vicSpace = _vicSpace - 1;
			};
		} forEach _vicReinfLocations;

		T_SETV("datePrevExtReinf", date);
	ENDMETHOD;

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
	/* private */ METHOD(selectActions)
		params [P_THISOBJECT, P_ARRAY("_actionFuncs"), P_NUMBER("_maxNewActions"), P_OOP_OBJECT("_world"), P_OOP_OBJECT("_simWorldNow"), P_OOP_OBJECT("_simWorldFuture")];

		CALLM0(_simWorldNow, "resetScoringCache");
		CALLM0(_simWorldFuture, "resetScoringCache");

		private _newActions = [];

		{
			_newActions = _newActions + T_CALLM(_x, [_simWorldNow ARG _simWorldFuture]);
		} forEach _actionFuncs;

		OOP_INFO_2("SELECT ACTIONS: generated %1 actions from generators: %2", count _newActions, _actionFuncs);

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
				private _finalScore = CALLM0(_x, "getFinalScore");
				[_finalScore, _x] 
			};

			_scoresAndActions sort DESCENDING;

			OOP_DEBUG_MSG("Scores of all actions:", []);
			for "_i" from 0 to ((count _scoresAndActions) - 1) do {
				private _scoreAndAction = _scoresAndActions select _i;
				OOP_DEBUG_MSG(" %1", [_scoreAndAction]);
			};

			// _newActions = [_newActions, [], { CALLM0(_x, "getFinalScore") }, "DECEND"] call BIS_fnc_sortBy;

			// Get the best scoring action
			(_scoresAndActions select 0) params ["_bestActionScore", "_bestAction"];

			// private _bestActionScore = // CALLM0(_bestAction, "getFinalScore");
			
			// Some sort of cut off needed here, probably needs tweaking, or should be strategy based?
			// TODO: Should we maybe be normalizing scores between 0 and 1?
			if(_bestActionScore <= ACTION_SCORE_CUTOFF) exitWith {};

			OOP_DEBUG_MSG("Selected new action %1 (score %2), applying it to the simworlds", [_bestAction ARG _bestActionScore]);

			// Add the best action to our active actions list
			REF(_bestAction);

			private _activeActions = T_GETV("activeActions");
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
	ENDMETHOD;

	/*
	Method: (private) _plan
	Planning implementation, once priority to plan at has been determined.
	
	Parameters:
		_world - <Model.WorldModel>, real world model (see <Model.WorldModel> or <WORLD_TYPE> for details) the actions should apply to.
		_generatorMethodName - string, method name of the generator which will generate actions
	*/
	/* private */ METHOD(_plan)
		params [P_THISOBJECT, P_OOP_OBJECT("_world"), P_STRING("_generatorMethodName")];

		OOP_DEBUG_MSG("- - - - - P L A N N I N G (generator %1) - - - - -", [_generatorMethodName]);

		// Sync before planning
		CALLM1(_world, "sync", _thisObject);
		// Update grids etc.
		CALLM0(_world, "update");

		private _activeActions = T_GETV("activeActions");

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
		
		T_CALLM("selectActions", [[_generatorMethodName] ARG _maxNewActions ARG _world ARG _simWorldNow ARG _simWorldFuture]);

		DELETE(_simWorldNow);
		DELETE(_simWorldFuture);

		OOP_DEBUG_MSG("- - - - - P L A N N I N G   D O N E - - - - -", []);
	ENDMETHOD;

	/*
	Method: clearAndCancelGarrisonAction
	Clears action at the garrison model, terminates and deletes the action as well.

	Parameters: _garModel

	_garModel - the garrison model

	Returns: nil
	*/
	METHOD(clearAndCancelGarrisonAction)
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
			private _activeActions = T_GETV("activeActions");
			_activeActions deleteAt (_activeActions find _action);
		};
	ENDMETHOD;


	// = = = = = = = = = = = Radio = = = = = = = = = = = = =

	// Initializes the radio key grid
	METHOD(initRadioKeys)
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
	ENDMETHOD;

	// Generates a random radio key for given position
	public STATIC_METHOD(generateRadioKey)
		params [P_THISCLASS, P_SIDE("_side"), P_POSITION("_pos"), P_NUMBER("_cellSize")];

		private _numdigits = 12;		// Amount of digits in the key code

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
	ENDMETHOD;

	// Returns the radio key for given position
	public METHOD(getRadioKey)
		params [P_THISOBJECT, P_POSITION("_pos")];
		pr _grid = T_GETV("radioKeyGrid");
		CALLM1(_grid, "getValueSafe", _pos);
	ENDMETHOD;

	server thread METHOD(clientAddRadioKey)
		params [P_THISOBJECT, P_SIDE("_side"), P_NUMBER("_clientOwner"), P_STRING("_key"), P_STRING("_playerName")];

		// Check if we have this radio key
		if (_key in T_GETV("enemyRadioKeys")) exitWith {
			// Show response for player
			pr _text = "We already have this key!";
			pr _args = [_text];
			REMOTE_EXEC_CALL_STATIC_METHOD("RadioKeyTab", "staticServerShowResponse", _args, _clientOwner, false);
		};

		// Check if it's a valid key at all, we don't want to store trash...

		// Check if it's our own key
		pr _radioKeyGrid = T_GETV("radioKeyGrid");
		pr _foundInOurGrid = CALLM1(_radioKeyGrid, "findValue", _key);
		if (_foundInOurGrid) exitWith {
			pr _text = format ["Key %1 belongs to our side!", _key];
			pr _args = [_text];
			REMOTE_EXEC_CALL_STATIC_METHOD("RadioKeyTab", "staticServerShowResponse", _args, _clientOwner, false);
		};

		// Check if it's one of enemy radio keys
		pr _keyFoundInEnemy = false;
		{
			pr _enemyAI = CALLSM1("AICommander", "getAICommander", _x);
			pr _radioKeyGrid = GETV(_enemyAI, "radioKeyGrid");
			pr _valueFound = CALLM1(_radioKeyGrid, "findValue", _key);
			if (_valueFound) exitWith {
				_keyFoundInEnemy = true;
			}; // No need to check other commanders
		} forEach ([WEST, EAST, INDEPENDENT] - [_side]);

		// Bail if player has entered some unknown key
		if (!_keyFoundInEnemy) exitWith {
			pr _text = format ["Key %1 is invalid!", _key];
			pr _args = [_text];
			REMOTE_EXEC_CALL_STATIC_METHOD("RadioKeyTab", "staticServerShowResponse", _args, _clientOwner, false);
		};

		// Add key
		T_GETV("enemyRadioKeys") pushBack _key;
		T_GETV("enemyRadioKeysAddedBy") pushBack _playerName;

		// Show response for player
		pr _text = format ["Key %1 was added!", _key];
		pr _args = [_text];
		REMOTE_EXEC_CALL_STATIC_METHOD("RadioKeyTab", "staticServerShowResponse", _args, _clientOwner, false);

		// Todo notify other players that someone has found a valid radio key?

		// Send new list of keys back to player
		CALLSM2("AICommander", "staticClientRequestRadioKeys", _side, _clientOwner);
	ENDMETHOD;

	public server STATIC_METHOD(staticClientAddRadioKey)
		params [P_THISCLASS, P_SIDE("_side"), P_NUMBER("_clientOwner"), P_STRING("_key"), P_STRING("_playerName")];

		OOP_INFO_1("STATIC CLIENT ADD RADIO KEY: %1", _this);

		pr _AI = CALLSM1("AICommander", "getAICommander", _side);

		if (IS_NULL_OBJECT(_AI)) exitWith {	};

		CALLM4(_AI, "clientAddRadioKey", _side, _clientOwner, _key, _playerName);
	ENDMETHOD;

	// Called REMOTELY by client to get radio keys
	// Thread unsafe, but getting radio keys is quite safe and trivial so we don't care about thread safety
	public server STATIC_METHOD(staticClientRequestRadioKeys)
		params [P_THISCLASS, P_SIDE("_side"), P_NUMBER("_clientOwner")];

		OOP_INFO_1("STATIC CLIENT REQUEST RADIO KEYS: %1", _this);

		pr _AI = CALLSM1("AICommander", "getAICommander", _side);

		if (IS_NULL_OBJECT(_AI)) exitWith {	};

		pr _args = [+GETV(_AI, "enemyRadiokeys"), +GETV(_AI, "enemyRadiokeysAddedBy")];
		REMOTE_EXEC_CALL_STATIC_METHOD("RadioKeyTab", "staticServerShowKeys", _args, _clientOwner, false);
	ENDMETHOD;

	// = = = = = = = = = = = = = = Roadblocks and dynamic locations = = = = = = = = = = = = = =

	// Adds a position for commander to consider create a roadblock at
	public METHOD(addRoadblockPosition)
		params [P_THISOBJECT, P_POSITION("_pos")];

		T_GETV("newRoadblockPositions") pushBack (+_pos);
	ENDMETHOD;

	// - - - - - - - STORAGE - - - - - - -

	public override METHOD(preSerialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		// Save intel database
		pr _db = T_GETV("intelDB");
		CALLM1(_storage, "save", _db);

		// Save strategy class name only
		T_SETV("cmdrStrategyClassSave", OBJECT_PARENT_CLASS_STR(T_GETV("cmdrStrategy")));

		// Save world model
		pr _model = T_GETV("worldModel");
		CALLM1(_storage, "save", _model);

		// Save our garrisons
		{
			pr _gar = _x;
			diag_log format ["Saving garrison: %1", _gar];
			CALLM1(_storage, "save", _gar);
		} forEach T_GETV("garrisons");

		// Save our actions
		{
			pr _action = _x;
			diag_log format ["Saving action: %1", _action];
			CALLM1(_storage, "save", _action);
		} forEach T_GETV("activeActions");

		// Save radio key grid
		pr _radioKeyGrid = T_GETV("radioKeyGrid");
		CALLM1(_storage, "save", _radioKeyGrid);

		true
	ENDMETHOD;

	public override METHOD(postDeserialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];
		FIX_LINE_NUMBERS()

		// Call method of all base classes
		CALLCM("AI", _thisObject, "postDeserialize", [_storage]);

		// GameMode must re-enable it
		T_SETV("planningEnabled", false);

		// Initialize variables
		#ifdef DEBUG_CLUSTERS
		T_SETV("nextMarkerID", 0);
		T_SETV("clusterMarkers", []);
		#endif
		FIX_LINE_NUMBERS()

		// Restore sensors
		T_CALLM0("_initSensors");

		// Initialize the plan generator arrays
		T_CALLM0("_initPlanActionGenerators");

		#ifdef DEBUG_COMMANDER
		T_SETV("state", "none");
		T_SETV("stateStart", 0);
		[_thisObject, T_GETV("side")] spawn {
			params [P_THISOBJECT, "_side"];
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
				_mrk setMarkerText (format ["Cmdr %1: %2 (%3s)", _thisObject, T_GETV("state"), GAME_TIME - T_GETV("stateStart")]);
			};
		};
		#endif
		FIX_LINE_NUMBERS()

		// Set process interval
		T_CALLM1("setProcessInterval", PROCESS_INTERVAL);

		// Load our garrisons
		{
			pr _gar = _x;
			CALLM1(_storage, "load", _gar);
		} forEach T_GETV("garrisons");

		// Load world model
		pr _model = T_GETV("worldModel");
		CALLM1(_storage, "load", _model);

		// Recreate the cmdr strategy object
		private _strategy = NEW(T_GETV("cmdrStrategyClassSave"), []);
		T_SETV_REF("cmdrStrategy", _strategy);

		// Load actions
		{
			pr _action = _x;
			diag_log format ["Loading action: %1", _action];
			CALLM1(_storage, "load", _action);
		} forEach T_GETV("activeActions");

		// Load the intel database
		pr _db = T_GETV("intelDB");
		CALLM1(_storage, "load", _db);

		// Load radio key grid
		pr _radioKeyGrid = T_GETV("radioKeyGrid");
		CALLM1(_storage, "load", _radioKeyGrid);

		T_SETV("cheatIntelInterception", false);

		true
	ENDMETHOD;

ENDCLASS;

AI_fnc_addActivity = {
	CALLSM("AICommander", "addActivity", _this);
};