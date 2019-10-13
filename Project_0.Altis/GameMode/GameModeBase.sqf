#include "common.hpp"

// Base class for Game Modes. A Game Mode is a set of customizations to 
// scenario initialization and ongoing gameplay mechanics.
CLASS("GameModeBase", "")
	VARIABLE("name");
	// If we want to spawn in enemy reinforcements automatically at bases
	VARIABLE("spawningEnabled");
	// How often we should spawn in reinforcements for the enemy
	VARIABLE("spawningInterval");
	// When we last spawned in reinforcements for the enemy
	VARIABLE("lastSpawn");

	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("name", "unnamed");
		T_SETV("spawningEnabled", false);
		#ifdef RELEASE_BUILD
		T_SETV("spawningInterval", 3600);
		#else
		// Faster spawning when we are testing
		T_SETV("spawningInterval", 120);
		#endif
		T_SETV("lastSpawn", TIME_NOW);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	// Called in init.sqf. Do NOT override this, implement the various specialized virtual functions
	// below it instead.
	METHOD("init") {
		params [P_THISOBJECT];

		PROFILE_SCOPE_START(GameModeInit);

		// Global flags
		gFlagAllCommanders = true; //false;
		// Main timer service
		gTimerServiceMain = NEW("TimerService", [0.45]); // timer resolution

		T_CALLM("preInitAll", []);

		if(IS_SERVER || IS_HEADLESSCLIENT) then {
			// Main message loop for garrisons
			gMessageLoopMain = NEW("MessageLoop", ["Main thread" ARG 16]);
			CALLM(gMessageLoopMain, "addProcessCategory", ["AIGarrisonSpawned"		ARG 20 ARG 3  ARG 15]); // Tag, priority, min interval, max interval
			CALLM(gMessageLoopMain, "addProcessCategory", ["AIGarrisonDespawned"	ARG 10 ARG 10 ARG 30]);

			gMessageLoopMainManager = NEW("MessageLoopMainManager", []);

			// Global debug printer for tests
			private _args = ["TestDebugPrinter", gMessageLoopMain];
			gDebugPrinter = NEW("DebugPrinter", _args);

			// Message loop for group AI
			gMessageLoopGroupAI = NEW("MessageLoop", ["Group AI thread"]);
			CALLM(gMessageLoopGroupAI, "addProcessCategory", ["AIGroupLow" ARG 10 ARG 2]); // Tag, priority, min interval

			// Message loop for Stimulus Manager
			gMessageLoopStimulusManager = NEW("MessageLoop", ["Stimulus Manager thread"]);

			// Global Stimulus Manager
			gStimulusManager = NEW("StimulusManager", []);

			// Location unit array provider
			gLUAP = NEW("LocationUnitArrayProvider", []);

			// Garbage Collector
			gGarbageCollector = NEW("GarbageCollector", []);

			// Personal Inventory
			gPersonalInventory = NEW("PersonalInventory", []);

			T_CALLM("initServerOrHC", []);
		};
		if(IS_SERVER) then {

			// Create the garrison server
			gGarrisonServer = NEW_PUBLIC("GarrisonServer", []);
			PUBLIC_VARIABLE "gGarrisonServer";

			T_CALLM("initCommanders", []);
			#ifndef _SQF_VM
			T_CALLM("initLocations", []);
			T_CALLM("initSideStats", []);
			T_CALLM("initMissionEventHandlers", []);
			T_CALLM("startCommanders", []);
			#endif
			T_CALLM("populateLocations", []);

			T_CALLM("initServerOnly", []);

			// Call our first process event immediately, to help things "settle" before we show them to the player.
			T_CALLM("process", []);

			// Add message loop for game mode
			gMessageLoopGameMode = NEW("MessageLoop", ["Game mode thread"]);
			// Add processing for the game mode on the server once we initialized everything else
			CALLM(gMessageLoopGameMode, "addProcessCategory", ["GameModeProcess" ARG 10 ARG 60 ARG 120]);
			CALLM2(gMessageLoopGameMode, "addProcessCategoryObject", "GameModeProcess", _thisObject);

			// Don't remove spawn{}! For some reason without spawning it doesn't apply the values.
			// Probably it's because we currently have this executed inside isNil {} block
			_thisObject spawn { CALLM(_this, "initDynamicSimulation", []); };

			// Initialize player database
			gPlayerDatabaseServer = NEW("PlayerDatabaseServer", []);
			// todo load it from profile namespace or whatever
		};
		if (HAS_INTERFACE || IS_HEADLESSCLIENT) then {
			T_CALLM("initClientOrHCOnly", []);
		};
		if (IS_HEADLESSCLIENT) then {
			private _str = format ["Mission: I am a headless client! My player object is: %1. I have just connected! My owner ID is: %2", player, clientOwner];
			OOP_INFO_0(_str);
			systemChat _str;

			// Test: ask the server to create an object and pass it to this computer
			[clientOwner, {
				private _remoteOwner = _this;
				diag_log format ["---- Connected headless client with owner ID: %1. RemoteExecutedOwner: %2, isRemoteExecuted: %3", _remoteOwner, remoteExecutedOwner, isRemoteExecuted];
				diag_log format ["all players: %1, all headless clients: %2", allPlayers, entities "HeadlessClient_F"];
				diag_log format ["Owners of headless clients: %1", (entities "HeadlessClient_F") apply {owner _x}];

				private _args = ["Remote DebugPrinter test", gMessageLoopMain];
				remoteDebugPrinter = NEW("DebugPrinter", _args);
				CALLM(remoteDebugPrinter, "setOwner", [_remoteOwner]); // Transfer it to the machine that has connected
				diag_log format ["---- Created a debug printer for the headless client: %1", remoteDebugPrinter];

			}] remoteExec ["spawn", 2, false];

			T_CALLM("initHCOnly", []);
		};
		if(HAS_INTERFACE) then {
			diag_log "----- Player detected!";
			0 spawn {
				waitUntil {!(isNull (finddisplay 12)) && !(isNull (findDisplay 46))};
				call compile preprocessfilelinenumbers "UI\initPlayerUI.sqf";
			};

			#ifndef RELEASE_BUILD
			[] call pr0_fnc_initDebugMenu;
			#endif

			// Message loop for client side checks: undercover, location visibility, etc
			gMsgLoopPlayerChecks = NEW("MessageLoop", ["Player checks"]);

			// Create PlayerDatabaseClient
			gPlayerDatabaseClient = NEW("PlayerDatabaseClient", []);

			T_CALLM("initClientOnly", []);
		};
		T_CALLM("postInitAll", []);
		
		PROFILE_SCOPE_START(GameModeEnd);
	} ENDMETHOD;

	// Called regularly in its own thread to update gameplay
	// states, mechanics etc. implemented by the Game Mode.
	/* private */ METHOD("process") {
		params [P_THISOBJECT];
		// Do spawning if it is enabled.
		if(T_GETV("spawningEnabled")) then {
			PROFILE_SCOPE_START(GameModeSpawning);
			T_CALLM("doSpawning", []);
			PROFILE_SCOPE_END(GameModeSpawning, 1);
		};
		// Call the update implementation.
		PROFILE_SCOPE_START(GameModeUpdate);
		T_CALLM("update", []);
		PROFILE_SCOPE_END(GameModeUpdate, 1);
	} ENDMETHOD;

	// Add garrisons to locations based where specified.
	// Behaviour is controlled by virtual functions "getLocationOwner" and "initGarrison",
	// or you can override the entire function.
	/* protected virtual */METHOD("populateLocations") {
		params [P_THISOBJECT];

		// Create initial garrisons
		{
			private _loc = _x;
			private _side = T_CALLM("getLocationOwner", [_loc]);
			CALLM(_loc, "setSide", [_side]);
			OOP_DEBUG_MSG("init loc %1 to side %2", [_loc ARG _side]);

			private _cmdr = CALL_STATIC_METHOD("AICommander", "getCommanderAIOfSide", [_side]);
			if(!IS_NULL_OBJECT(_cmdr)) then {
				CALLM(_cmdr, "registerLocation", [_loc]);

				private _gar = T_CALLM("initGarrison", [_loc ARG _side]);
				if(!IS_NULL_OBJECT(_gar)) then {
					OOP_DEBUG_MSG("Creating garrison %1 for location %2 (%3)", [_gar ARG _loc ARG _side]);

					CALLM1(_gar, "setLocation", _loc);
					CALLM1(_loc, "registerGarrison", _gar);
					CALLM0(_gar, "activate");
				};
			};

			private _type = GETV(_loc, "type");
			private _radius = GETV(_loc, "boundingRadius");

			// Create vehicles in civilian area for player to steal
			if(_type == LOCATION_TYPE_CITY) then {
				private _args = [CIVILIAN, [], "", "tCIVILIAN"];
				private _gar = NEW("Garrison", _args);
				private _maxCars = 3 max (25 min (0.03 * _radius));
				for "_i" from 0 to _maxCars do {
					private _newUnit = NEW("Unit", [tCIVILIAN ARG T_VEH ARG T_VEH_DEFAULT ARG -1 ARG ""]);
					CALLM(_gar, "addUnit", [_newUnit]);
				};
				CALLM1(_gar, "setLocation", _loc);
				CALLM1(_loc, "registerGarrison", _gar);
				// CALLM0(_gar, "activate");
			};

			// Send intel to commanders
			{
				private _sideCommander = GETV(_x, "side");
				if (_sideCommander != WEST) then { // Enemies are smart
					if (CALLM0(_loc, "isBuilt")) then {
						private _updateLevel = [CLD_UPDATE_LEVEL_TYPE, CLD_UPDATE_LEVEL_UNITS] select (_sideCommander == _side);
						CALLM2(_x, "postMethodAsync", "updateLocationData", [_loc ARG _updateLevel ARG sideUnknown ARG false]);
					};
				} else {
					// If it's player side, let it only know about cities
					if (_type == LOCATION_TYPE_CITY) then {
						CALLM2(_x, "postMethodAsync", "updateLocationData", [_loc ARG CLD_UPDATE_LEVEL_TYPE ARG sideUnknown ARG false ARG false]);
					};
				};
			} forEach gCommanders;
		} forEach GET_STATIC_VAR("Location", "all");
	} ENDMETHOD;

	// -------------------------------------------------------------------------
	// |                  V I R T U A L   F U N C T I O N S                    |
	// -------------------------------------------------------------------------
	// These are the customization points for game mode setups, implement them
	// in derived classes.
	/* protected virtual */ METHOD("preInitAll") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected virtual */ METHOD("initServerOrHC") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected virtual */ METHOD("initServerOnly") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected virtual */ METHOD("initClientOrHCOnly") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected virtual */ METHOD("initHCOnly") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected virtual */ METHOD("initClientOnly") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected virtual */ METHOD("postInitAll") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	/* protected virtual */ METHOD("getLocationOwner") {
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];
		GETV(_loc, "side")
	} ENDMETHOD;

	/* protected virtual */ METHOD("initGarrison") {
		params [P_THISOBJECT, P_OOP_OBJECT("_loc"), P_SIDE("_side")];

		private _type = GETV(_loc, "type");
		OOP_INFO_MSG("%1 %2", [_loc ARG _side]);

		switch (_type) do {
			case LOCATION_TYPE_BASE;
			case LOCATION_TYPE_OUTPOST: {
				private _cInf = CALLM(_loc, "getUnitCapacity", [T_INF ARG [GROUP_TYPE_IDLE]]);
				private _cVehGround = CALLM(_loc, "getUnitCapacity", [T_PL_tracked_wheeled ARG GROUP_TYPE_ALL]);
				private _cHMGGMG = CALLM(_loc, "getUnitCapacity", [T_PL_HMG_GMG_high ARG GROUP_TYPE_ALL]);
				private _cBuildingSentry = 0;
				private _cCargoBoxes = 2;
				// [P_THISOBJECT, P_STRING("_faction"), P_SIDE("_side"), P_NUMBER("_cInf"), P_NUMBER("_cVehGround"), P_NUMBER("_cHMGGMG"), P_NUMBER("_cBuildingSentry"), P_NUMBER("_cCargoBoxes")];
				CALL_STATIC_METHOD("GameModeBase", "createGarrison", ["military" ARG _side ARG _cInf ARG _cVehGround ARG _cHMGGMG ARG _cBuildingSentry ARG _cCargoBoxes])
			};
			case LOCATION_TYPE_POLICE_STATION: {
				private _cInf = CALLM(_loc, "getUnitCapacity", [T_INF ARG [GROUP_TYPE_IDLE]]);
				private _cVehGround = CALLM(_loc, "getUnitCapacity", [T_PL_tracked_wheeled ARG GROUP_TYPE_ALL]);
				// [P_THISOBJECT, P_STRING("_faction"), P_SIDE("_side"), P_NUMBER("_cInf"), P_NUMBER("_cVehGround"), P_NUMBER("_cHMGGMG"), P_NUMBER("_cBuildingSentry"), P_NUMBER("_cCargoBoxes")];
				CALL_STATIC_METHOD("GameModeBase", "createGarrison", ["police" ARG _side ARG _cInf ARG _cVehGround ARG 0 ARG 0 ARG 2])
			};
			default { NULL_OBJECT };
		};
	} ENDMETHOD;

	// Override this to do stuff when player spawns
	/* protected virtual */METHOD("playerSpawn") {
		params [P_THISOBJECT, P_OBJECT("_newUnit"), P_OBJECT("_oldUnit"), "_respawn", "_respawnDelay"];
	} ENDMETHOD;

	// Override this to perform periodic game mode updates
	/* protected virtual */METHOD("update") {
		params [P_THISOBJECT];
	} ENDMETHOD;

	// Override this to perform actions when a location spawns
	/* protected virtual */METHOD("locationSpawned") {
		params [P_THISOBJECT, P_OOP_OBJECT("_location")];
	} ENDMETHOD;

	// Override this to perform actions when a location despawns
	/* protected virtual */METHOD("locationDespawned") {
		params [P_THISOBJECT, P_OOP_OBJECT("_location")];
	} ENDMETHOD;

	// -------------------------------------------------------------------------
	// |                        S E R V E R   O N L Y                          |
	// -------------------------------------------------------------------------
	/* private */ METHOD("initCommanders") {
		params [P_THISOBJECT];

		// Garrison objects to track players and player owned vehicles
		gGarrisonPlayersWest = NEW("Garrison", [WEST]);
		gGarrisonPlayersEast = NEW("Garrison", [EAST]);
		gGarrisonPlayersInd = NEW("Garrison", [INDEPENDENT]);
		gGarrisonPlayersCiv = NEW("Garrison", [CIVILIAN]);
		gGarrisonAmbient = NEW("Garrison", [CIVILIAN]);
		gGarrisonAbandonedVehicles = NEW("Garrison", [CIVILIAN]);

		gSpecialGarrisons = [gGarrisonPlayersWest, gGarrisonPlayersEast, gGarrisonPlayersInd, gGarrisonPlayersCiv, gGarrisonAmbient, gGarrisonAbandonedVehicles];
		{
			CALLM2(_x, "postMethodAsync", "spawn", []);
		} forEach gSpecialGarrisons;

		// Message loops for commander AI
		gMessageLoopCommanderInd = NEW("MessageLoop", ["IND Commander Thread"]);

		// Commander AIs
		gCommanders = [];

		// Independent
		gCommanderInd = NEW("Commander", []); // all commanders are equal
		private _args = [gCommanderInd, INDEPENDENT, gMessageLoopCommanderInd];
		gAICommanderInd = NEW_PUBLIC("AICommander", _args);
		PUBLIC_VARIABLE "gAICommanderInd";
		gCommanders pushBack gAICommanderInd;

		if(gFlagAllCommanders) then { // but some are more equal
			gMessageLoopCommanderWest = NEW("MessageLoop", ["WEST Commander Thread"]);
			gMessageLoopCommanderEast = NEW("MessageLoop", ["EAST Commander Thread"]);

			// West
			gCommanderWest = NEW("Commander", []);
			private _args = [gCommanderWest, WEST, gMessageLoopCommanderWest];
			gAICommanderWest = NEW_PUBLIC("AICommander", _args);
			PUBLIC_VARIABLE "gAICommanderWest";
			gCommanders pushBack gAICommanderWest;

			// East
			gCommanderEast = NEW("Commander", []);
			private _args = [gCommanderEast, EAST, gMessageLoopCommanderEast];
			gAICommanderEast = NEW_PUBLIC("AICommander", _args);
			PUBLIC_VARIABLE "gAICommanderEast";
			gCommanders pushBack gAICommanderEast;
		};
	} ENDMETHOD;

	METHOD("startCommanders") {
		params [P_THISOBJECT];
		{
			// We postMethodAsync them, because we don't want to start processing right after mission start
			CALLM2(_x, "postMethodAsync", "setProcessInterval", [10]);
			CALLM2(_x, "postMethodAsync", "start", []);
		} forEach gCommanders;
	} ENDMETHOD;

	fnc_getLocName = {
		params["_name"];
		private _names = "getText( _x >> 'name') == _name" configClasses ( configFile >> "CfgWorlds" >> worldName >> "Names" );
		if(count _names == 0) then { "" } else { configName (_names#0) };
	};

	METHOD("createMissingCityLocations") {
		params [P_THISOBJECT];

		// private _existingCityLocations = (entities "Project_0_LocationSector") select { (_x getVariable ["Type", ""]) == LOCATION_TYPE_CITY } apply { getPos _x };
		// private _moduleGroup = createGroup sideLogic;
		// {
		// 	private _pos = getPos _x;
		// 	// See if one already exists
		// 	if(_existingCityLocations findIf { _x distance _pos < 500 } == NOT_FOUND) then {
		// 		// private _name = [text _x] call fnc_getLocName;
		// 		private _sizeX = 100 max (getNumber (configFile >> "CfgWorlds" >> worldName >> "Names" >> (text _x) >> "radiusA"));
		// 		private _sizeY = 100 max (getNumber (configFile >> "CfgWorlds" >> worldName >> "Names" >> (text _x) >> "radiusB"));
		// 		OOP_INFO_MSG("Creating missing City Location for %1 at %2, size %3m x %4m", [_name ARG _pos ARG _sizeX ARG _sizeY]);
				
		// 		// TODO: calculate civ presence by area
		// 		"Project_0_LocationSector" createUnit [ _pos, _moduleGroup,
		// 			(format ["this setVariable ['Name', '%1'];", text _x]) +
		// 			        "this setVariable ['Type', 'city'];" +
		// 			        "this setVariable ['Side', 'civilian'];" +
		// 			(format ["this setVariable ['objectArea', [%1, %2, 0, true]];", _sizeX, _sizeY]) +
		// 			        "this setVariable ['CapacityInfantry', 0];" +
		// 			        "this setVariable ['CivPresUnitCount', 10];"
		// 		];
		// 		private _mrk = createmarker [text _x, _pos];
		// 		_mrk setMarkerSize [_sizeX, _sizeY];
		// 		_mrk setMarkerShape "ELLIPSE";
		// 		_mrk setMarkerBrush "SOLID";
		// 		_mrk setMarkerColor "ColorWhite";
		// 		_mrk setMarkerText (text _x);
		// 		_mrk setMarkerAlpha 0.4;
		// 	};
		// } forEach (nearestLocations [getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition"), ["NameCityCapital", "NameCity", "NameVillage", "CityCenter"], 25000]);
	} ENDMETHOD;
	
	// Create locations
	METHOD("initLocations") {
		params [P_THISOBJECT];

		// First generate location modules for any cities/towns etc that don't have them manually placed
		T_CALLM("createMissingCityLocations", []);

		private _allRoadBlocks = [];
		private _locationsForRoadblocks = [];
		{
			private _locSector = _x;
			private _locSectorPos = getPos _locSector;
			private _locSectorDir = getDir _locSector;
			private _locName = _locSector getVariable ["Name", ""];
			private _locType = _locSector getVariable ["Type", ""];
			private _locSide = _locSector getVariable ["Side", ""];
			private _locBorder = _locSector getVariable ["objectArea", [50, 50, 0, true]];
			private _locBorderType = ["circle", "rectangle"] select _locBorder#3;
			private _locCapacityInf = _locSector getVariable ["CapacityInfantry", ""];
			private _locCapacityCiv = _locSector getVariable ["CivPresUnitCount", ""];

			if(_locType == LOCATION_TYPE_CITY) then {
				private _baseRadius = 300; // Radius at which it 

				_locBorder params ["_a", "_b"];
				private _area = 4*_a*_b;
				private _density_km2 = 60;	// Amount of civilians per square km
				private _max = 35;			// Max amount of civilians
				_locCapacityCiv = ((_density_km2/1e6) * _area) min 35;
				_locCapacityCiv = ceil _locCapacityCiv;

				// https://www.desmos.com/calculator/nahw1lso9f
				/*
				_locCapacityCiv = ceil (30 * log (0.0001 * _locBorder#0 * _locBorder#1 + 1));
				OOP_INFO_MSG("%1 civ count set to %2", [_locName ARG _locCapacityCiv]);
				//private _houses = _locSectorPos nearObjects ["House", _locBorder#0 max _locBorder#1];
				//diag_log format["%1 houses at %2", count _houses, _locName];
				*/

				// https://www.desmos.com/calculator/nahw1lso9f
				_locCapacityInf = ceil (40 * log (0.00001 * _locBorder#0 * _locBorder#1 + 1));
				OOP_INFO_MSG("%1 inf count set to %1", [_locCapacityInf]);
			} else {
				_locCapacityCiv = 0;
			};

			private _template = "";
			private _side = "";
			
			private _side = switch (_locSide) do{
				case "civilian": { CIVILIAN };//might not need this
				case "west": { WEST };
				case "east": { EAST };
				case "independant": { INDEPENDENT };
				default { INDEPENDENT };
			};

			// Create a new location
			private _loc = NEW_PUBLIC("Location", [_locSectorPos]);
			CALLM1(_loc, "initFromEditor", _locSector);
			CALLM1(_loc, "setName", _locName);
			CALLM1(_loc, "setSide", _side);
			CALLM1(_loc, "setType", _locType);
			CALLM2(_loc, "setBorder", _locBorderType, _locBorder);
			CALLM1(_loc, "setCapacityInf", _locCapacityInf);
			CALLM1(_loc, "setCapacityCiv", _locCapacityCiv);

			// Create police stations in cities
			if (_locType == LOCATION_TYPE_CITY and _locCapacityCiv >= 10) then {
				// TODO: Add some visual/designs to this
				private _posPolice = +GETV(_loc, "pos");
				_posPolice = _posPolice vectorAdd [-200 + random 400, -200 + random 400, 0];
				// Find first building which is one of the police building types
				private _possiblePoliceBuildings = (_posPolice nearObjects 200) select {_x isKindOf "House"} select {(typeOf _x) in location_bt_police};

				if ((count _possiblePoliceBuildings) > 0) then {
					private _policeStationBuilding = selectRandom _possiblePoliceBuildings;
					private _policeStation = NEW_PUBLIC("Location", [getPos _policeStationBuilding]);
					CALLM2(_policeStation, "setBorder", "circle", 10);
					CALLM0(_policeStation, "processBuildings"); // We must add buildings to the array
					CALLM0(_policeStation, "addSpawnPosFromBuildings");
					CALLM1(_policeStation, "setSide", _side);
					CALLM1(_policeStation, "setName", format ["%1 police station" ARG _locName] );
					CALLM1(_policeStation, "setType", LOCATION_TYPE_POLICE_STATION);

					// TODO: Get city size or building count and scale police capacity from that ?
					CALLM1(_policeStation, "setCapacityInf", floor (8 + random 6));
					CALLM(_loc, "addChild", [_policeStation]);
					SETV(_policeStation, "useParentPatrolWaypoints", true);
					// add special gun shot sensor to police garrisons that will launch investigate->arrest goal ?
				};
			};

			if(_locType == LOCATION_TYPE_ROADBLOCK) then {
				_allRoadBlocks pushBack [_locSectorPos, _locSectorDir];
			} else {
				if(_locType in [LOCATION_TYPE_BASE, LOCATION_TYPE_CITY]) then {
					_locationsForRoadblocks pushBack [_locSectorPos, _side];
				};
			};
		} forEach (entities "Project_0_LocationSector");

		{
			_x params ["_pos", "_side"];
			// TODO: improve this later
			private _roadBlocks = CALL_STATIC_METHOD("Location", "findRoadblocks", [_pos]) select {
				private _newRoadBlock = _x;
				_allRoadBlocks findIf { _x#0 distance _newRoadBlock#0 < 400 } == NOT_FOUND
			};

			_allRoadBlocks = _allRoadBlocks + _roadBlocks;
			{	
				_x params ["_roadblockPos", "_roadblockDir"];
				private _roadblockLoc = NEW_PUBLIC("Location", [_roadblockPos]);
				CALLM1(_roadblockLoc, "setName", _roadblockLoc);
				CALLM1(_roadblockLoc, "setSide", _side);
				CALLM2(_roadblockLoc, "setBorder", "rectangle", [10 ARG 10 ARG _roadblockDir]);
				CALLM1(_roadblockLoc, "setCapacityInf", 20);
				CALLM1(_roadblockLoc, "setCapacityCiv", 0);
				// Do setType last cos it will update the debug marker for us
				CALLM1(_roadblockLoc, "setType", LOCATION_TYPE_ROADBLOCK);
			} forEach _roadBlocks;
		} forEach _locationsForRoadblocks;
	} ENDMETHOD;

	#define ADD_TRUCKS
	#define ADD_UNARMED_MRAPS
	#define ADD_ARMED_MRAPS
	#define ADD_TANKS
	//#define ADD_APCS_IFVS
	#define ADD_STATICS
	STATIC_METHOD("createGarrison") {
		params [P_THISOBJECT, P_STRING("_faction"), P_SIDE("_side"), P_NUMBER("_cInf"), P_NUMBER("_cVehGround"), P_NUMBER("_cHMGGMG"), P_NUMBER("_cBuildingSentry"), P_NUMBER("_cCargoBoxes")];
		
		if (_faction == "police") exitWith {
			
			private _templateName = "tPolice";
			private _template = [_templateName] call t_fnc_getTemplate;

			private _args = [_side, [], _faction, _templateName]; // [P_THISOBJECT, P_SIDE("_side"), P_ARRAY("_pos"), P_STRING("_faction"), P_STRING("_templateName")];
			private _gar = NEW("Garrison", _args);

			OOP_INFO_MSG("Creating garrison %1 for faction %2 for side %3, %4 inf, %5 veh, %6 hmg/gmg, %7 sentries", [_gar ARG _faction ARG _side ARG _cInf ARG _cVehGround ARG _cHMGGMG ARG _cBuildingSentry]);
			

			// 75% out on patrol
			private _patrolGroups = 1 max (_cInf * 0.75 * 0.5);
			for "_i" from 1 to _patrolGroups do {
				private _patrolGroup = NEW("Group", [_side ARG GROUP_TYPE_PATROL]);
				for "_i" from 0 to 1 do {
					private _variants = [T_INF_SL, T_INF_officer, T_INF_DEFAULT];
					NEW("Unit", [_template ARG 0 ARG selectrandom _variants ARG -1 ARG _patrolGroup]);
				};
				OOP_INFO_MSG("%1: Created police patrol group %2", [_gar ARG _patrolGroup]);
				if(canSuspend) then {
					CALLM2(_gar, "postMethodSync", "addGroup", [_patrolGroup]);
				} else {
					CALLM(_gar, "addGroup", [_patrolGroup]);
				};
			};

			// Remainder back at station
			private _sentryGroup = NEW("Group", [_side ARG GROUP_TYPE_IDLE]);
			private _remainder = 1 max (_cInf * 0.25);
			for "_i" from 1 to _remainder do {
				private _variants = [T_INF_SL, T_INF_officer, T_INF_DEFAULT];
				NEW("Unit", [_template ARG 0 ARG selectrandom _variants ARG -1 ARG _sentryGroup]);
			};
			OOP_INFO_MSG("%1: Created police sentry group %2", [_gar ARG _sentryGroup]);
			if(canSuspend) then {
				CALLM2(_gar, "postMethodSync", "addGroup", [_sentryGroup]);
			} else {
				CALLM(_gar, "addGroup", [_sentryGroup]);
			};

			// Patrol vehicles
			for "_i" from 1 to (2 max _cVehGround) do {
				// Add a car in front of police station
				private _newUnit = NEW("Unit", [_template ARG T_VEH ARG T_VEH_personal ARG -1 ARG ""]);
				if(canSuspend) then {
					CALLM2(_gar, "postMethodSync", "addUnit", [_newUnit]);
				} else {
					CALLM(_gar, "addUnit", [_newUnit]);
				};
				OOP_INFO_MSG("%1: Added police car %2", [_gar ARG _newUnit]);
			};

			// Cargo boxes
			private _i = 0;
			while {_i < _cCargoBoxes} do {
				private _subcatid = selectRandom [T_CARGO_box_small, T_CARGO_box_medium];
				private _newUnit = NEW("Unit", [_template ARG T_CARGO ARG _subcatid ARG -1 ARG ""]);
				CALLM1(_newUnit, "setBuildResources", 40);
				//CALLM1(_newUnit, "limitedArsenalEnable", true); // Make them all limited arsenals
				if (CALL_METHOD(_newUnit, "isValid", [])) then {
					if(canSuspend) then {
						CALLM2(_gar, "postMethodSync", "addUnit", [_newUnit]);
					} else {
						CALLM(_gar, "addUnit", [_newUnit]);
					};
					OOP_INFO_MSG("%1: Added cargo box %2", [_gar ARG _newUnit]);
				} else {
					DELETE(_newUnit);
				};
				_i = _i + 1;
			};

			_gar
		};

		private _templateName = GET_TEMPLATE_NAME(_side);
		private _template = [_templateName] call t_fnc_getTemplate;

		private _args = [_side, [], _faction, _templateName]; // [P_THISOBJECT, P_SIDE("_side"), P_ARRAY("_pos"), P_STRING("_faction"), P_STRING("_templateName")];
		private _gar = NEW("Garrison", _args);

		OOP_INFO_MSG("Creating garrison %1 for faction %2 for side %3, %4 inf, %5 veh, %6 hmg/gmg, %7 sentries", [_gar ARG _faction ARG _side ARG _cInf ARG _cVehGround ARG _cHMGGMG ARG _cBuildingSentry]);
		

		// Add default units to the garrison

		// Specification for groups to add to the garrison
		private _infSpec = [
			//|Min groups of this type
			//|    |Max groups of this type
			//|    |    |Group template
			//|	   |    |                          |Group behaviour
			[  0,   3,   T_GROUP_inf_sentry,   		GROUP_TYPE_PATROL],
			[  0,  -1,   T_GROUP_inf_rifle_squad,   GROUP_TYPE_IDLE]
		];

		private _vehGroupSpec = [
			//|Chance to spawn
			//|      |Min veh of this type
			//|      |    |Max veh of this type
			//|      |    |            |Veh type                          
			[  0.5,   0,  3,           T_VEH_MRAP_HMG],
			[  0.5,   0,  3,           T_VEH_MRAP_GMG],
			[  0.3,   0,  2,           T_VEH_APC],
			[  0.1,   0,  1,           T_VEH_MBT]
		];

		{
			_x params ["_min", "_max", "_groupTemplate", "_groupBehaviour"];
			private _i = 0;
			while{(_cInf > 0 or _i < _min) and (_max == -1 or _i < _max)} do {
				CALLM(_gar, "createAddInfGroup", [_side ARG _groupTemplate ARG _groupBehaviour])
					params ["_newGroup", "_unitCount"];
				OOP_INFO_MSG("%1: Created inf group %2 with %3 units", [_gar ARG _newGroup ARG _unitCount]);
				_cInf = _cInf - _unitCount;
				_i = _i + 1;
			};
		} forEach _infSpec;

		// Add building sentries
		if (_cBuildingSentry > 0) then {
			private _sentryGroup = NEW("Group", [_side ARG GROUP_TYPE_IDLE]);
			while {_cBuildingSentry > 0} do {
				private _variants = [T_INF_marksman, T_INF_marksman, T_INF_LMG, T_INF_LAT, T_INF_LMG];
				private _newUnit = NEW("Unit", [_template ARG 0 ARG selectrandom _variants ARG -1 ARG _sentryGroup]);
				_cBuildingSentry = _cBuildingSentry - 1;
			};
			OOP_INFO_MSG("%1: Created sentry group %2", [_gar ARG _sentryGroup]);
			if(canSuspend) then {
				CALLM2(_gar, "postMethodSync", "addGroup", [_sentryGroup]);
			} else {
				CALLM(_gar, "addGroup", [_sentryGroup]);
			};
		};

		// Add default vehicles
		// Some trucks
		private _i = 0;
		#ifdef ADD_TRUCKS
		while {_cVehGround > 0 && _i < 4} do {
			private _newUnit = NEW("Unit", [_template ARG T_VEH ARG T_VEH_truck_inf ARG -1 ARG ""]);
			if (CALL_METHOD(_newUnit, "isValid", [])) then {
				if(canSuspend) then {
					CALLM2(_gar, "postMethodSync", "addUnit", [_newUnit]);
				} else {
					CALLM(_gar, "addUnit", [_newUnit]);
				};
				OOP_INFO_MSG("%1: Added truck %2", [_gar ARG _newUnit]);
				_cVehGround = _cVehGround - 1;
			} else {
				DELETE(_newUnit);
			};
			_i = _i + 1;
		};
		#endif

		// Unarmed MRAPs
		_i = 0;
		#ifdef ADD_UNARMED_MRAPS
		while {(_cVehGround > 0) && _i < 1} do  {
			private _newUnit = NEW("Unit", [_template ARG T_VEH ARG T_VEH_MRAP_unarmed ARG -1 ARG ""]);
			if (CALL_METHOD(_newUnit, "isValid", [])) then {
				if(canSuspend) then {
					CALLM2(_gar, "postMethodSync", "addUnit", [_newUnit]);
				} else {
					CALLM(_gar, "addUnit", [_newUnit]);
				};
				OOP_INFO_MSG("%1: Added unarmed mrap %2", [_gar ARG _newUnit]);
				_cVehGround = _cVehGround - 1;
			} else {
				DELETE(_newUnit);
			};
			_i = _i + 1;
		};
		#endif

		// APCs
		#ifdef ADD_APCS_IFVS
		{
			_x params ["_chance", "_min", "_max", "_type"];
			if(random 1 <= _chance) then {
				private _i = 0;
				while{(_cVehGround > 0 or _i < _min) and (_max == -1 or _i < _max)} do {
					private _newGroup = CALLM(_gar, "createAddVehGroup", [_side ARG T_VEH ARG T_VEH_APC ARG -1]);
					OOP_INFO_MSG("%1: Created veh group %2", [_gar ARG _newGroup]);
					_cVehGround = _cVehGround - 1;
					_i = _i + 1;
				};
			};
		} forEach _vehGroupSpec;
		#endif

		// Static weapons
		if (_cHMGGMG > 0) then {
			// temp cap of amount of static guns
			_cHMGGMG = (4 + random 5) min _cHMGGMG;
			
			private _staticGroup = NEW("Group", [_side ARG GROUP_TYPE_VEH_STATIC]);
			while {_cHMGGMG > 0} do {
				private _variants = [T_VEH_stat_HMG_high, T_VEH_stat_GMG_high];
				private _newUnit = NEW("Unit", [_template ARG T_VEH ARG selectrandom _variants ARG -1 ARG _staticGroup]);
				CALL_METHOD(_newUnit, "createDefaultCrew", [_template]);
				_cHMGGMG = _cHMGGMG - 1;
			};
			OOP_INFO_MSG("%1: Added static group %2", [_gar ARG _staticGroup]);
			if(canSuspend) then {
				CALLM2(_gar, "postMethodSync", "addGroup", [_staticGroup]);
			} else {
				CALLM(_gar, "addGroup", [_staticGroup]);
			};
		};

		// Cargo boxes
		_i = 0;
		while {_cCargoBoxes > 0 && _i < 3} do {
			private _newUnit = NEW("Unit", [_template ARG T_CARGO ARG T_CARGO_box_medium ARG -1 ARG ""]);
			CALLM1(_newUnit, "setBuildResources", 110);
			//CALLM1(_newUnit, "limitedArsenalEnable", true); // Make them all limited arsenals
			if (CALL_METHOD(_newUnit, "isValid", [])) then {
				if(canSuspend) then {
					CALLM2(_gar, "postMethodSync", "addUnit", [_newUnit]);
				} else {
					CALLM(_gar, "addUnit", [_newUnit]);
				};
				OOP_INFO_MSG("%1: Added cargo box %2", [_gar ARG _newUnit]);
				_cCargoBoxes = _cCargoBoxes - 1;
			} else {
				DELETE(_newUnit);
			};
			_i = _i + 1;
		};

		_gar
	} ENDMETHOD;


	// Create SideStats
	/* private */ METHOD("initSideStats") {
		params [P_THISOBJECT];
		
		private _args = [EAST, 5];
		SideStatWest = NEW("SideStat", _args);
		gSideStatWestHR = CALLM0(SideStatWest, "getHumanResources");
		PUBLIC_VARIABLE "gSideStatWestHR";
	} ENDMETHOD;

	// create MissionEventHandlers
	/* private */ METHOD("initMissionEventHandlers") {
		params [P_THISOBJECT];
		call compile preprocessFileLineNumbers "Init\initMissionEH.sqf";
	} ENDMETHOD;

	/* private */ METHOD("fn") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	// Initialize dynamic simulation
	METHOD("initDynamicSimulation") {
		#ifndef _SQF_VM
		params [P_THISOBJECT];

		// Enables or disables the whole Arma_3_Dynamic_Simulation system
		enableDynamicSimulationSystem true;

		// Infantry units.
		"Group" setDynamicSimulationDistance 40000; // We don't dynamicly disable units with this thing
		// Vehicles with crew.
		"Vehicle" setDynamicSimulationDistance 40000; // We don't want to dynamicly disable vehicles with crew
		//  All vehicles without crew.
		"EmptyVehicle" setDynamicSimulationDistance 1500;
		// Static objects. Anything from a small tin can to a building.
		"Prop" setDynamicSimulationDistance 50;

		// Sets activation distance multiplier of Arma_3_Dynamic_Simulation for the given class
		"IsMoving" setDynamicSimulationDistanceCoef 2.0; // Multiplies the entity activation distance by set value if the entity is moving.
		#endif
	} ENDMETHOD;

	// Returns the side of player faction
	/* public virtual */ METHOD("getPlayerSide") {
		WEST
	} ENDMETHOD;

	METHOD("doSpawning") {
		params [P_THISOBJECT];

		if(T_GETV("lastSpawn") + T_GETV("spawningInterval") > TIME_NOW) exitWith {};
		T_SETV("lastSpawn", TIME_NOW);

		{
			private _loc = _x;
			private _side = GETV(_loc, "side");
			private _templateName = GET_TEMPLATE_NAME(_side);
			private _template = [_templateName] call t_fnc_getTemplate;

			private _targetCInf = CALLM(_loc, "getUnitCapacity", [T_INF ARG [GROUP_TYPE_IDLE]]);

			private _garrisons = CALLM(_loc, "getGarrisons", [_side]);
			if (count _garrisons == 0) exitWith {};
			private _garrison = _garrisons#0;
			if(not CALLM(_garrison, "isSpawned", [])) then {
				private _infCount = count CALLM(_garrison, "getInfantryUnits", []);
				if(_infCount < _targetCInf) then {
					private _remaining = _targetCInf - _infCount;
					systemChat format["Spawning %1 units at %2", _remaining, _loc];
					while {_remaining > 0} do {
						CALLM2(_garrison, "postMethodSync", "createAddInfGroup", [_side ARG T_GROUP_inf_sentry ARG GROUP_TYPE_PATROL])
							params ["_newGroup", "_unitCount"];
						_remaining = _remaining - _unitCount;
					};
				};

				private _cVehGround = CALLM(_loc, "getUnitCapacity", [T_PL_tracked_wheeled ARG GROUP_TYPE_ALL]);
				private _vehCount = count CALLM(_garrison, "getVehicleUnits", []);
				
				if(_vehCount < _cVehGround) then {
					systemChat format["Spawning %1 trucks at %2", _cVehGround - _vehCount, _loc];
				};

				while {_vehCount < _cVehGround} do {
					private _newUnit = NEW("Unit", [_template ARG T_VEH ARG T_VEH_truck_inf ARG -1 ARG ""]);
					if (CALL_METHOD(_newUnit, "isValid", [])) then {
						CALLM2(_garrison, "postMethodSync", "addUnit", [_newUnit]);
						_vehCount = _vehCount + 1;
					} else {
						DELETE(_newUnit);
					};
				};
			};
		} forEach (GET_STATIC_VAR("Location", "all") select { GETV(_x, "type") in [LOCATION_TYPE_BASE] });
	} ENDMETHOD;
ENDCLASS;