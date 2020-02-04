#include "common.hpp"

// Default resolution of our timer service
#define TIMER_SERVICE_RESOLUTION 0.45

// Debug flag, will limit generation or locations to a small area
#ifndef RELEASE_BUILD
//#define __SMALL_MAP
#endif


#define MESSAGE_LOOP_MAIN_MAX_MESSAGES_IN_SERIES 16

// Base class for Game Modes. A Game Mode is a set of customizations to 
// scenario initialization and ongoing gameplay mechanics.
CLASS("GameModeBase", "MessageReceiverEx")

	VARIABLE_ATTR("name", [ATTR_SAVE]);
	// If we want to spawn in enemy reinforcements automatically at bases
	VARIABLE_ATTR("spawningEnabled", [ATTR_SAVE]);
	// How often we should spawn in reinforcements for the enemy
	VARIABLE_ATTR("spawningInterval", [ATTR_SAVE]);
	// When we last spawned in reinforcements for the enemy
	VARIABLE("lastSpawn");

	// Message loops
	// Must keep references to them to help with saving
	VARIABLE_ATTR("messageLoopMain", [ATTR_SAVE]);
	VARIABLE_ATTR("messageLoopGroupAI", [ATTR_SAVE]);
	VARIABLE_ATTR("messageLoopGameMode", [ATTR_SAVE]);
	VARIABLE_ATTR("messageLoopCommanderInd", [ATTR_SAVE]);
	VARIABLE_ATTR("messageLoopCommanderWest", [ATTR_SAVE]);
	VARIABLE_ATTR("messageLoopCommanderEast", [ATTR_SAVE]);

	// Commanders AI objects
	VARIABLE_ATTR("AICommanderInd", [ATTR_SAVE]);
	VARIABLE_ATTR("AICommanderWest", [ATTR_SAVE]);
	VARIABLE_ATTR("AICommanderEast", [ATTR_SAVE]);

	// Locations
	VARIABLE_ATTR("locations", [ATTR_SAVE]);

	// Template names
	VARIABLE_ATTR("tNameMilWest", [ATTR_SAVE]);
	VARIABLE_ATTR("tNameMilInd", [ATTR_SAVE]);
	VARIABLE_ATTR("tNameMilEast", [ATTR_SAVE]);
	VARIABLE_ATTR("tNamePolice", [ATTR_SAVE]);

	// Other values
	VARIABLE_ATTR("enemyForceMultiplier", [ATTR_SAVE]);

	VARIABLE_ATTR("playerInfoArray", [ATTR_SAVE_VER(11)]);
	VARIABLE_ATTR("savedSpecialGarrisons", [ATTR_SAVE_VER(11)]);

	METHOD("new") {
		params [P_THISOBJECT,	P_STRING("_tNameEnemy"), P_STRING("_tNamePolice"),
								P_NUMBER("_enemyForcePercent")];
		T_SETV("name", "unnamed");
		T_SETV("spawningEnabled", false);

		#ifdef RELEASE_BUILD
		T_SETV("spawningInterval", 3600);
		#else
		// Faster spawning when we are testing
		T_SETV("spawningInterval", 120);
		#endif
		T_SETV("lastSpawn", TIME_NOW);

		T_SETV("messageLoopMain", NULL_OBJECT);
		T_SETV("messageLoopGroupAI", NULL_OBJECT);
		T_SETV("messageLoopGameMode", NULL_OBJECT);
		T_SETV("messageLoopCommanderInd", NULL_OBJECT);
		T_SETV("messageLoopCommanderWest", NULL_OBJECT);
		T_SETV("messageLoopCommanderEast", NULL_OBJECT);
		T_SETV("AICommanderInd", NULL_OBJECT);
		T_SETV("AICommanderWest", NULL_OBJECT);
		T_SETV("AICommanderEast", NULL_OBJECT);

		// Default template names
		T_SETV("tNameMilWest", "tNATO");
		T_SETV("tNameMilInd", "tAAF");
		T_SETV("tNameMilEast", "tCSAT");
		T_SETV("tNamePolice", "tPOLICE");

		// Apply values from arguments
		T_SETV("enemyForceMultiplier", 1);
		if (_tNameEnemy != "") then {
			T_SETV("tNameMilInd", _tNameEnemy);
		};
		if (_tNamePolice != "tNamePolice") then {
			T_SETV("tNamePolice", _tNamePolice);
		};
		T_SETV("enemyForceMultiplier", _enemyForcePercent/100);

		T_SETV("locations", []);

		T_SETV("playerInfoArray", []);

		T_SETV("savedSpecialGarrisons", []);
	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	// Called in init.sqf. Do NOT override this, implement the various specialized virtual functions
	// below it instead.
	METHOD("init") {
		params [P_THISOBJECT, P_ARRAY("_extraParams")];

		PROFILE_SCOPE_START(GameModeInit);

		// Global flags
		gFlagAllCommanders = true; //false;
		// Main timer service
		gTimerServiceMain = NEW("TimerService", [TIMER_SERVICE_RESOLUTION]); // timer resolution

		// Create and init message loops
		T_CALLM0("_createMessageLoops");	// Creates message loops
		T_CALLM0("_setupMessageLoops");		// Sets their properties

		T_CALLM("preInitAll", []);

		if(IS_SERVER || IS_HEADLESSCLIENT) then {
			// Main message loop manager
			gMessageLoopMainManager = NEW("MessageLoopMainManager", []);

			// Group message loop manager
			gMessageLoopGroupManager = NEW("MessageLoopGroupManager", []);

			// Global debug printer for tests
			private _args = ["TestDebugPrinter", gMessageLoopMain];
			gDebugPrinter = NEW("DebugPrinter", _args);

			// Location unit array provider
			gLUAP = NEW("LocationUnitArrayProvider", []);

			// Garbage Collector
			gGarbageCollector = NEW("GarbageCollector", []);

			// Personal Inventory
			gPersonalInventory = NEW("PersonalInventory", []);

			T_CALLM("initServerOrHC", []);
		};
		if(IS_SERVER) then {

			// Global Garrison Stimulus Manager
			gStimulusManagerGarrison = NEW_PUBLIC("StimulusManager", [gMessageLoopMain]); // Can postMethodAsync stimulus to it to annoy garrisons
			PUBLIC_VARIABLE "gStimulusManagerGarrison";

			// Create the garrison server
			gGarrisonServer = NEW_PUBLIC("GarrisonServer", []);
			PUBLIC_VARIABLE "gGarrisonServer";

			T_CALLM0("_createSpecialGarrisons");
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

			// Init dynamic simulation
			T_CALLM0("initDynamicSimulation");

			// todo load it from profile namespace or whatever

			// Add mission event handler to destroy vehicles in destroyed houses, gets triggered when house is destroyed
			T_CALLM0("_initMissionEventHandlers");

			missionNamespace setVariable["ACE_maxWeightDrag", 10000, true]; // fix loot crates being undraggable
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

			// Hide the allowed area markers
			//#ifdef RELEASE_BUILD
			CALLSM0("Location", "deleteEditorAllowedAreaMarkers");
			//#endif

			T_CALLM("initClientOnly", []);

			CALLSM0("undercoverMonitor", "staticInit");
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
			OOP_INFO_2("Populating location: %1, type: %2", _x, CALLM0(_x, "getType"));

			private _loc = _x;
			private _side = T_CALLM("getLocationOwner", [_loc]);
			CALLM(_loc, "setSide", [_side]);
			OOP_DEBUG_MSG("init loc %1 to side %2", [_loc ARG _side]);

			private _cmdr = CALL_STATIC_METHOD("AICommander", "getAICommander", [_side]);
			if(!IS_NULL_OBJECT(_cmdr)) then {
				CALLM(_cmdr, "registerLocation", [_loc]);

				private _gar = T_CALLM("initGarrison", [_loc ARG _side]);
				if(!IS_NULL_OBJECT(_gar)) then {
					OOP_DEBUG_MSG("Creating garrison %1 for location %2 (%3)", [_gar ARG _loc ARG _side]);

					CALLM1(_gar, "setLocation", _loc);
					// CALLM1(_loc, "registerGarrison", _gar); // I think it's not needed? setLocation should register it as well
					CALLM0(_gar, "activate");
				};
			};

			private _type = GETV(_loc, "type");
			private _radius = GETV(_loc, "boundingRadius");

			// Create vehicles in civilian area for player to steal
			if(_type == LOCATION_TYPE_CITY && (_side isEqualTo CIVILIAN)) then {
				T_CALLM1("populateCity", _loc);
				// CALLM0(_gar, "activate");
			};

			// Send intel to commanders
			private _playerSide = T_CALLM0("getPlayerSide");
			{
				if (!IS_NULL_OBJECT(_x)) then {
					private _sideCommander = GETV(_x, "side");
					if (_sideCommander != _playerSide) then { // Enemies are smart
						if (CALLM0(_loc, "isBuilt")) then {
							// This part determines commander's knowledge about enemy locations at game init
							// Only relevant for One AI vs Another AI Commander game mode I think
							//private _updateLevel = [CLD_UPDATE_LEVEL_TYPE, CLD_UPDATE_LEVEL_UNITS] select (_sideCommander == _side);
							OOP_INFO_1("  revealing to commander: %1", _sideCommander);
							private _updateLevel = CLD_UPDATE_LEVEL_UNITS;
							CALLM2(_x, "postMethodAsync", "updateLocationData", [_loc ARG _updateLevel ARG sideUnknown ARG false]);
						};
					} else {
						// If it's player side, let it only know about cities
						if (_type == LOCATION_TYPE_CITY) then {
							OOP_INFO_1("  revealing to commander: %1", _sideCommander);
							CALLM2(_x, "postMethodAsync", "updateLocationData", [_loc ARG CLD_UPDATE_LEVEL_TYPE ARG sideUnknown ARG false ARG false]);
						};
					};
				};
			} forEach [T_GETV("AICommanderWest"), T_GETV("AICommanderEast"), T_GETV("AICommanderInd")];
		} forEach GET_STATIC_VAR("Location", "all");
	} ENDMETHOD;

	// Creates a civilian garrison at a city location
	METHOD("populateCity") {
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];

		private _templateName = T_CALLM2("getTemplateName", CIVILIAN, "");
		private _template = [_templateName] call t_fnc_getTemplate;
		private _args = [CIVILIAN, [], "civilian", _templateName];
		private _gar = NEW("Garrison", _args);
		private _radius = GETV(_loc, "boundingRadius");
		private _maxCars = 3 max (25 min (0.03 * _radius));
		for "_i" from 0 to _maxCars do {
			private _newUnit = NEW("Unit", [_template ARG T_VEH ARG T_VEH_DEFAULT ARG -1 ARG ""]);
			CALLM(_gar, "addUnit", [_newUnit]);
		};
		CALLM1(_gar, "setLocation", _loc);
		CALLM1(_loc, "registerGarrison", _gar);
		CALLM1(_gar, "enableAutoSpawn", true);
	} ENDMETHOD;

	// Creates message loops
	METHOD("_createMessageLoops") {
		params [P_THISOBJECT];

		if(IS_SERVER || IS_HEADLESSCLIENT) then {
			// Main message loop for garrisons
			if (isNil "gMessageLoopMain") then {
				gMessageLoopMain = NEW("MessageLoop", ["Main thread"]);
				T_SETV("messageLoopMain", gMessageLoopMain);
			};

			// Message loop for group AI
			if (isNil "gMessageLoopGroupAI") then {
				gMessageLoopGroupAI = NEW("MessageLoop", ["Group AI thread"]);
				T_SETV("messageLoopGroupAI", gMessageLoopGroupAI);
			};
		};

		if(IS_SERVER) then {
			if (isNil "gMessageLoopGameMode") then {
				gMessageLoopGameMode = NEW("MessageLoop", ["Game mode thread"]);
				T_SETV("messageLoopGameMode", gMessageLoopGameMode);
			};

			if (isNil "gMessageLoopCommanderInd") then {
				gMessageLoopCommanderInd = NEW("MessageLoop", ["IND Commander Thread"]);
				T_SETV("messageLoopCommanderInd", gMessageLoopCommanderInd);
			};

			if (isNil "gMessageLoopCommanderWest") then {
				gMessageLoopCommanderWest = NEW("MessageLoop", ["WEST Commander Thread"]);
				T_SETV("messageLoopCommanderWest", gMessageLoopCommanderWest);
			};

			if (isNil "gMessageLoopCommanderEast") then {
				gMessageLoopCommanderEast = NEW("MessageLoop", ["EAST Commander Thread"]);
				T_SETV("messageLoopCommanderEast", gMessageLoopCommanderEast);
			};
		};

		if(HAS_INTERFACE) then {
			// Message loop for client side checks: undercover, location visibility, etc
			if (isNil "gMsgLoopPlayerChecks") then {
				gMsgLoopPlayerChecks = NEW("MessageLoop", ["Player checks"]);
			};
		};


	} ENDMETHOD;

	// Initializes properties of message loops, which should be created by now
	METHOD("_setupMessageLoops") {
		params [P_THISOBJECT];

		if (!IS_NULL_OBJECT(T_GETV("messageLoopMain"))) then {
			CALLM(gMessageLoopMain, "addProcessCategory", ["AIGarrisonSpawned"		ARG 20 ARG 3  ARG 15]); // Tag, priority, min interval, max interval
			CALLM(gMessageLoopMain, "addProcessCategory", ["AIGarrisonDespawned"	ARG 10 ARG 10 ARG 30]);
			CALLM1(gMessageLoopMain, "setMaxMessagesInSeries", MESSAGE_LOOP_MAIN_MAX_MESSAGES_IN_SERIES);
		};

		if (!IS_NULL_OBJECT(T_GETV("messageLoopGroupAI"))) then {
			CALLM(gMessageLoopGroupAI, "addProcessCategory", ["AIGroupLow" ARG 10 ARG 2 ARG 8]); // Tag, priority, min interval
		};

		if(!IS_NULL_OBJECT(T_GETV("messageLoopGameMode"))) then {
			CALLM(gMessageLoopGameMode, "addProcessCategory", ["GameModeProcess" ARG 10 ARG 60 ARG 120]);
			CALLM2(gMessageLoopGameMode, "addProcessCategoryObject", "GameModeProcess", _thisObject);
		};

#ifndef _SQF_VM
		// Start a periodic check which will restart message loops if needed
		[{CALLM0(_this#0, "_checkMessageLoops")}, [_thisObject], 2] call CBA_fnc_waitAndExecute;
#endif

	} ENDMETHOD;

	METHOD("_checkMessageLoops") {
		params [P_THISOBJECT];

		private _recovery = false;
		private _crashedMsgLoops = [];

		{													// Check all message loops created
			private _msgLoop = T_GETV(_x);
			if (!IS_NULL_OBJECT(_msgLoop)) then {
				if(CALLM0(_msgLoop, "isNotRunning")) then {	// If it is not running, something bad has happened
					CALLM0(_msgLoop, "unlock");				// Unlock it by force, it cant unlock itself anyway
					_crashedMsgLoops pushBack _msgLoop;
					OOP_ERROR_0("");
					OOP_ERROR_0("! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !");
					OOP_ERROR_1("! ! ! THREAD IS NOT RUNNING: %1", GETV(_msgLoop, "name"));
					OOP_ERROR_0("! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !");
					OOP_ERROR_0("");

					// Make a recursive dump of the last processed object
					private _lastObject = GETV(_msgLoop, "lastObject");
					if (IS_NULL_OBJECT(_lastObject)) then {
						OOP_ERROR_0("Last processed object is null");
					} else {
						OOP_ERROR_1("Last processed object: %1", _lastObject);
						if (!IS_OOP_OBJECT(_lastObject)) then {
							OOP_ERROR_1("  %1 is not an OOP object", _lastObject);
						} else {
							OOP_ERROR_1("  Initiating a memory dump of %1", _lastObject);
							[_lastObject, 6] call OOP_objectCrashDump;	// 6 is max depth
						};
					};

					_recovery = true;
				};
			};
		} forEach ["messageLoopMain", "messageLoopGroupAI", "messageLoopGameMode",
					"messageLoopCommanderInd", "messageLoopCommanderWest", "messageLoopCommanderEast"];

		if (!_recovery) then {
#ifndef _SQF_VM
			// If we have not initiated recovery, then it's fine, check same message loops after a few more seconds
			[{CALLM0(_this#0, "_checkMessageLoops")}, [_thisObject], 0.5] call CBA_fnc_waitAndExecute;
#endif
		} else {
			// Broadcast notification
			T_CALLM1("_broadcastCrashNotification", _crashedMsgLoops);

#ifdef RELEASE_BUILD
			// Send msg to game manager to perform emergency saving
			CALLM2(gGameManager, "postMethodAsync", "serverSaveGameRecovery", []);
#endif
		};
	} ENDMETHOD;

	METHOD("_broadcastCrashNotification") {
		params [P_THISOBJECT, P_ARRAY("_crashedMsgLoops")];

		// Report crashed threads, initiate emergency save

		// Format text
		private _text = "Threads have crashed: ";
		{ _text = _text + GETV(_x, "name") + " "; } forEach _crashedMsgLoops;
		_text = _text + ". Restart the mission after saving is over, send the .RPT to devs";

		// Broadcast notification
		REMOTE_EXEC_CALL_STATIC_METHOD("NotificationFactory", "createCritical", [_text], 0, false);

		// Broadcast it to system chat too
		["CRITICAL MISSION ERROR:"] remoteExec ["systemChat"];
		[_text] remoteExec ["systemChat"];

		// todo: send emails, deploy pigeons

#ifndef _SQF_VM
		// Do it once in a while
		[{CALLM1(_this#0, "_broadcastCrashNotification", _this#1)}, [_thisObject, _crashedMsgLoops], 20] call CBA_fnc_waitAndExecute;
#endif

	} ENDMETHOD;

	METHOD("_initMissionEventHandlers") {
		params [P_THISOBJECT];

		// Add mission event handler to destroy vehicles in destroyed houses, gets triggered when house is destroyed
		// todo we can also notify the nearby location about that event, because the building might belong to the location?
		#ifndef _SQF_VM
		addMissionEventHandler ["BuildingChanged", { 
			params ["_previousObject", "_newObject", "_isRuin"];
			diag_log format ["BuildingChanged EH: %1", _this];
			if (_isRuin) then {
				// Iterate all vehicles within the building, destroy them
				private _vehicles = _previousObject call misc_fnc_getVehiclesInBuilding;
				{
					if ((getMass _x) < 1000) then {
						diag_log format ["Building was destroyed. Destroying behicle: %1", _x];
						_x setDamage 1;
					};
				} forEach _vehicles;
			};
		}];
		addMissionEventHandler ["HandleDisconnect", {
			params ["_unit", "_id", "_uid", "_name"];
			CALLM3(gGameMode, "savePlayerInfo", _uid, _unit, _name);
			false;
		}];
		#endif
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

	// Returns template name for given side and faction
	/* protected virtual */ METHOD("getTemplateName") {
		params [P_THISOBJECT, P_SIDE("_side"), P_STRING("_faction")];

		switch(_faction) do {
			case "police":				{ T_GETV("tNamePolice") };  //{ "tRHS_AAF_police" }; // { "tPOLICE" };
			
			default { // "military"
				switch(_side) do {
					case WEST:			{ T_GETV("tNameMilWest") };
					case EAST:			{ T_GETV("tNameMilEast") };
					case INDEPENDENT:	{ T_GETV("tNameMilInd") }; //{"tRHS_AAF_2020"}; // { "tAAF" };
					case CIVILIAN:		{ "tCIVILIAN" };
					default				{ "tDEFAULT" };
				}
			};
		};
	} ENDMETHOD;

	/* protected virtual */ METHOD("initGarrison") {
		params [P_THISOBJECT, P_OOP_OBJECT("_loc"), P_SIDE("_side")];

		private _type = GETV(_loc, "type");
		OOP_INFO_MSG("%1 %2", [_loc ARG _side]);

		switch (_type) do {
			case LOCATION_TYPE_AIRPORT;
			case LOCATION_TYPE_BASE;
			case LOCATION_TYPE_OUTPOST: {
				private _cInf = (T_GETV("enemyForceMultiplier") * (CALLM0(_loc, "getCapacityInf") min 45)) max 6; // We must return some sane infantry, because airfields and bases can have too much infantry
				private _cVehGround = CALLM(_loc, "getUnitCapacity", [T_PL_tracked_wheeled ARG GROUP_TYPE_ALL]) min 10;
				private _cHMGGMG = CALLM(_loc, "getUnitCapacity", [T_PL_HMG_GMG_high ARG GROUP_TYPE_ALL]);
				private _cBuildingSentry = 0;
				private _cCargoBoxes = 2;
				// [P_THISOBJECT, P_STRING("_faction"), P_SIDE("_side"), P_NUMBER("_cInf"), P_NUMBER("_cVehGround"), P_NUMBER("_cHMGGMG"), P_NUMBER("_cBuildingSentry"), P_NUMBER("_cCargoBoxes")];
				T_CALLM("createGarrison", ["military" ARG _type ARG _side ARG _cInf ARG _cVehGround ARG _cHMGGMG ARG _cBuildingSentry ARG _cCargoBoxes])
			};
			case LOCATION_TYPE_POLICE_STATION: {
				private _cInf = (T_GETV("enemyForceMultiplier")*(CALLM0(_loc, "getCapacityInf") min 16)) max 6;
				private _cVehGround = CALLM(_loc, "getUnitCapacity", [T_PL_tracked_wheeled ARG GROUP_TYPE_ALL]);
				// [P_THISOBJECT, P_STRING("_faction"), P_SIDE("_side"), P_NUMBER("_cInf"), P_NUMBER("_cVehGround"), P_NUMBER("_cHMGGMG"), P_NUMBER("_cBuildingSentry"), P_NUMBER("_cCargoBoxes")];
				T_CALLM("createGarrison", ["police" ARG _type ARG _side ARG _cInf ARG _cVehGround ARG 0 ARG 0 ARG 2])
			};
			default { NULL_OBJECT };
		};
	} ENDMETHOD;

	// Override this to do stuff when player spawns
	// Call the method of base class(that is, this class)
	/* protected virtual */METHOD("playerSpawn") {
		params [P_THISOBJECT, P_OBJECT("_newUnit"), P_OBJECT("_oldUnit"), "_respawn", "_respawnDelay", P_ARRAY("_restoreData"), P_BOOL("_restorePosition")];

		OOP_INFO_1("PLAYER SPAWN: %1", _this);

		// Single player specific setup
		if(!IS_MULTIPLAYER) then {
			// We need to catch player death so we can "respawn" them fakely
			OOP_INFO_1("Added killed EH to %1", _newUnit);
			_newUnit addEventHandler ["Killed", { CALLM(gGameMode, "singlePlayerKilled", [_this select 0]) }];
		};

		// Create a suspiciousness monitor for player
		NEW("UndercoverMonitor", [_newUnit]);

		// Create scroll menu to talk to civilians
		pr0_fnc_talkCond = { // I know I overwrite it every time but who cares now :/
			private _civ = cursorObject;
			(!isNil {_civ getVariable CIVILIAN_PRESENCE_CIVILIAN_VAR_NAME}) && {(_target distance _civ) < 3}
			&& {alive _civ} && {!(_civ getVariable [CP_VAR_IS_TALKING, false])}
		};

		_newUnit addAction [(("<img image='a3\ui_f\data\IGUI\Cfg\simpleTasks\types\talk_ca.paa' size='1' color = '#FFFFFF'/>") + ("<t size='1' color = '#FFFFFF'> Talk</t>")), // title
						"[cursorObject, 'talk'] spawn CivPresence_fnc_talkTo", // Script
						0, // Arguments
						9000, // Priority
						true, // ShowWindow
						false, //hideOnUse
						"", //shortcut
						"call pr0_fnc_talkCond", //condition
						2, //radius
						false, //unconscious
						"", //selection
						""]; //memoryPoint

		_newUnit addAction [(("<img image='a3\ui_f\data\Map\Markers\Military\unknown_CA.paa' size='1' color = '#FFA300'/>") + ("<t size='1' color = '#FFA300'> Ask about intel</t>")), // title
						"[cursorObject, 'intel'] spawn CivPresence_fnc_talkTo", // Script
						0, // Arguments
						8999, // Priority
						true, // ShowWindow
						false, //hideOnUse
						"", //shortcut
						"call pr0_fnc_talkCond", //condition
						2, //radius
						false, //unconscious
						"", //selection
						""]; //memoryPoint

		_newUnit addAction [(("<img image='a3\ui_f\data\GUI\Rsc\RscDisplayMain\profile_player_ca.paa' size='1' color = '#FFFFFF'/>") + ("<t size='1' color = '#FFFFFF'> Recruit</t>")), // title
						"[cursorObject, 'agitate'] spawn CivPresence_fnc_talkTo", // Script
						0, // Arguments
						8998, // Priority
						true, // ShowWindow
						false, //hideOnUse
						"", //shortcut
						"call pr0_fnc_talkCond", //condition
						2, //radius
						false, //unconscious
						"", //selection
						""]; //memoryPoint

		// Init the UnitIntel on player
		CALLSM0("UnitIntel", "initPlayer");

		// Init the Location Visibility Monitor on player
		gPlayerMonitor = NEW("PlayerMonitor", [_newUnit]);
		NEW("LocationVisibilityMonitor", [_newUnit ARG gPlayerMonitor]); // When this self-deletes, it will unref the player monitor

		// Init the Sound Monitor on player
		NEW("SoundMonitor", [_newUnit]);

		// Action to start building stuff
		_newUnit addAction [format ["<img size='1.5' image='\A3\ui_f\data\GUI\Rsc\RscDisplayMain\menu_options_ca.paa' />  %1", "Open Build Menu from location"], // title
						{isNil {CALLSM1("BuildUI", "getInstanceOpenUI", 0);}}, // 0 - build from location's resources
						0, // Arguments
						0, // Priority
						false, // ShowWindow
						false, //hideOnUse
						"", //shortcut
						"(vehicle player == player) && (['', player] call PlayerMonitor_fnc_canUnitBuildAtLocation)", //condition
						2, //radius
						false, //unconscious
						"", //selection
						""]; //memoryPoint


		// Action to start building stuff
		_newUnit addAction [format ["<img size='1.5' image='\A3\ui_f\data\GUI\Rsc\RscDisplayMain\menu_options_ca.paa' />  %1", "Open Build Menu from inventory"], // title
						{isNil {CALLSM1("BuildUI", "getInstanceOpenUI", 1);}}, // 1 - build from our own inventory
						0, // Arguments
						-1, // Priority
						false, // ShowWindow
						false, //hideOnUse
						"", //shortcut
						"(vehicle player == player) && (((['', player] call unit_fnc_getInfantryBuildResources) > 0) && (['', player] call PlayerMonitor_fnc_canUnitBuildAtLocation))", //condition
						2, //radius
						false, //unconscious
						"", //selection
						""]; //memoryPoint


		// Action to attach units to garrison
		pr0_fnc_attachUnitCond = {
			_co = cursorObject;
			(vehicle player == player)                                              // Player must be on foot
			&& {_co distance player < 7}                                            // Player must be close to object
			&& {! (_co isKindOf "Man")}                                               // Object must not be infantry
			&& {['', player] call PlayerMonitor_fnc_isUnitAtFriendlyLocation}       // Player must be at a friendly location
			&& {(['', cursorObject] call unit_fnc_getUnitFromObjectHandle) != ''}   // Object must be a valid unit OOP object (no shit spawned by zeus for now)
			&& {alive cursorObject}                                                 // Object must be alive
		};
		_newUnit addAction [format ["<img size='1.5' image='\A3\ui_f\data\GUI\Rsc\RscDisplayMain\infodlcsowned_ca.paa' />  %1", "Attach to garrison"], // title // pic: arrow pointing down
						{isNil {NEW("AttachToGarrisonDialog", [cursorObject])}}, // Open the UI dialog
						0, // Arguments
						0.1, // Priority
						false, // ShowWindow
						false, //hideOnUse
						"", //shortcut
						"call pr0_fnc_attachUnitCond", //condition
						2, //radius
						false, //unconscious
						"", //selection
						""]; //memoryPoint

		if(!(_restoreData isEqualTo [])) then {
			[player, _restoreData, _restorePosition] call GameMode_fnc_restorePlayerInfo;
			REMOTE_EXEC_CALL_METHOD(gGameMode, "clearPlayerInfo", [player], ON_SERVER);
			true
		} else {
			false
		}
	} ENDMETHOD;

	// Player death event handler in SP
	// SP is special in this regard, because there is no respawn, so we must make it ourselves, yay \o/
	/* protected virtual */ METHOD("singlePlayerKilled") {
		params [P_THISOBJECT, P_OBJECT("_oldUnit")];

		OOP_INFO_1("SINGLE PLAYER KILLED: %1", _this);

		// Bail if this has already been handled for this unit
		// I have no idea why, killed event handler gets called twice if player dies after laying on the ground after taking too much ACE damage
		private _handledPreviously = _oldUnit getVariable ["vin_killed_handled", false];
		OOP_INFO_1("  handled previously: %1", _handledPreviously);
		if (_handledPreviously) exitWith {
			OOP_INFO_0("  handled previously, ignoring this call");
		};
		_oldUnit setVariable ["vin_killed_handled", true];

		// Create a unit and give player control of it.
		private _tmpGroup = createGroup (side group _oldUnit);
		private _newUnit = _tmpGroup createUnit [typeOf _oldUnit, [0,0,0], [], 0, "NONE"];
		[_newUnit] joinSilent (group _oldUnit);
		deleteGroup _tmpGroup;
		_newUnit setName (name _oldUnit);
		selectPlayer _newUnit;
		//unassignCurator zeus1;		zeus1 is nil anyway? I think we can use ACE now to add zeus
		//player assignCurator zeus1;

		// Standard player respawn handler script like in MP
		[player, _oldUnit, "", 0, "GameModeBase singlePlayerKilled"] call compile preprocessFileLineNumbers "onPlayerRespawn.sqf";
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

	// Override this to perform actions when a unit is killed
	/* protected virtual */METHOD("unitDestroyed") {
		params [P_THISOBJECT, P_NUMBER("_catID"), P_NUMBER("_subcatID"), P_SIDE("_side"), P_STRING("_faction")];
	} ENDMETHOD;

	// Override this to create gameModeData of a location
	/* protected virtual */	METHOD("initLocationGameModeData") {
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];
	} ENDMETHOD;

	// Game-mode specific functions
	// Must be here for common interface
	// Returns an array of cities where we can recruit from
	/* protected virtual */ METHOD("getRecruitCities") {
		params [P_THISOBJECT, P_POSITION("_pos")];
		[]
	} ENDMETHOD;

	// Returns how many recruits we can get at a certain place from nearby cities
	/* protected virtual */ METHOD("getRecruitCount") {
		params [P_THISOBJECT, P_ARRAY("_cities")];
		0
	} ENDMETHOD;

	/* protected virtual */ METHOD("getRecruitmentRadius") {
		params [P_THISCLASS];
		0
	} ENDMETHOD;

	// Must return a value 0...1 to drive some AICommander logic
	/* protected virtual */ METHOD("getCampaignProgress") {
		0.5
	} ENDMETHOD;

	// Not all game modes need all commanders
	// By default all commanders are started and perform planning
	// This can be overriden in this method
	/* virtual */ METHOD("startCommanders") {
		_this spawn {
			params [P_THISOBJECT];
			// Add some delay so that we don't start processing instantly, because we might want to synchronize intel with players
			sleep 10;
			{
				CALLM1(T_GETV(_x), "enablePlanning", true);
				// We postMethodAsync them, because we don't want to start processing right after mission start
				CALLM2(T_GETV(_x), "postMethodAsync", "start", []);
			} forEach ["AICommanderInd", "AICommanderWest", "AICommanderEast"];
		};
	} ENDMETHOD;

	// -------------------------------------------------------------------------
	// |                        S E R V E R   O N L Y                          |
	// -------------------------------------------------------------------------
	/* private */ METHOD("initCommanders") {
		params [P_THISOBJECT];

		// Independent
		gCommanderInd = NEW("Commander", []); // all commanders are equal
		private _args = [gCommanderInd, INDEPENDENT, gMessageLoopCommanderInd];
		gAICommanderInd = NEW_PUBLIC("AICommander", _args);
		T_SETV("AICommanderInd", gAICommanderInd);
		PUBLIC_VARIABLE "gAICommanderInd";

		// West
		gCommanderWest = NEW("Commander", []);
		private _args = [gCommanderWest, WEST, gMessageLoopCommanderWest];
		gAICommanderWest = NEW_PUBLIC("AICommander", _args);
		T_SETV("AICommanderWest", gAICommanderWest);
		PUBLIC_VARIABLE "gAICommanderWest";

		// East
		gCommanderEast = NEW("Commander", []);
		private _args = [gCommanderEast, EAST, gMessageLoopCommanderEast];
		gAICommanderEast = NEW_PUBLIC("AICommander", _args);
		T_SETV("AICommanderEast", gAICommanderEast);
		PUBLIC_VARIABLE "gAICommanderEast";
	} ENDMETHOD;

	METHOD("_saveSpecialGarrisons") {
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];
		diag_log "Saving special garrisons";
		// Save the loaded data to the garrisons
		T_SETV("savedSpecialGarrisons", gSpecialGarrisons);
		{
			CALLM1(_storage, "save", _x);
		} forEach gSpecialGarrisons;
		diag_log "Special garrisons saved";
	} ENDMETHOD;

	METHOD("_loadSpecialGarrisons") {
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		// SAVEBREAK
		if(GETV(_storage, "version") >= 11) then {
			diag_log "Loading special garrisons";
			gSpecialGarrisons = +T_GETV("savedSpecialGarrisons");

			// Add the loaded data back to the garrisons
			{
				CALLM1(_storage, "load", _x);
			} forEach gSpecialGarrisons;

			// Garrison objects to track players and player owned vehicles
			gGarrisonPlayersWest 		= gSpecialGarrisons#0;
			gGarrisonPlayersEast 		= gSpecialGarrisons#1;
			gGarrisonPlayersInd 		= gSpecialGarrisons#2;
			gGarrisonPlayersCiv 		= gSpecialGarrisons#3;
			gGarrisonAmbient 			= gSpecialGarrisons#4;
			gGarrisonAbandonedVehicles 	= gSpecialGarrisons#5;

			{
				CALLM2(_x, "postMethodAsync", "spawn", [true]); // true == global spawn
			} forEach gSpecialGarrisons;

		} else {
			diag_log "Creating special garrisons";
			T_CALLM0("_createSpecialGarrisons");
		};
		diag_log "Special garrisons done";
	} ENDMETHOD;

	METHOD("_createSpecialGarrisons") {
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
	} ENDMETHOD;

	fnc_getLocName = {
		params["_name"];
		private _names = "getText( _x >> 'name') == _name" configClasses ( configFile >> "CfgWorlds" >> worldName >> "Names" );
		if(count _names == 0) then { "" } else { configName (_names#0) };
	};

	METHOD("createMissingCityLocations") {
		params [P_THISOBJECT];

		// private _existingCityLocations = (entities "Vindicta_LocationSector") select { (_x getVariable ["Type", ""]) == LOCATION_TYPE_CITY } apply { getPos _x };
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
		// 		"Vindicta_LocationSector" createUnit [ _pos, _moduleGroup,
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

		// Array of positions
		// These positions have very high priority if map maker has placed them. We will not delete them.
		private _predefinedRoadblockPositions = [];

		// Locations which will be processed for potential roadblock positions around them
		private _locationsForRoadblocks = [];

		{ // forEach (entities "Vindicta_LocationSector");
			private _locSector = _x;
			private _locSectorPos = getPos _locSector;

			#ifdef __SMALL_MAP
			_locSectorPos params ["_posX", "_posY"];
			if (_posX > 20000 && _posY > 16000) then {
			#endif

			private _locSectorDir = getDir _locSector;
			private _locName = _locSector getVariable ["Name", ""];
			private _locType = _locSector getVariable ["Type", ""];
			private _locSide = _locSector getVariable ["Side", ""];
			private _locBorder = _locSector getVariable ["objectArea", [50, 50, 0, true]];
			private _locBorderType = ["circle", "rectangle"] select _locBorder#3;
			//private _locCapacityInf = _locSector getVariable ["CapacityInfantry", ""]; // capacityInf is calculated from actual buildings
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
				//_locCapacityInf = ceil (40 * log (0.00001 * _locBorder#0 * _locBorder#1 + 1));
				//OOP_INFO_MSG("%1 inf count set to %1", [_locCapacityInf]);
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
			private _args = [_locSectorPos, CIVILIAN]; // Location created by noone
			private _loc = NEW_PUBLIC("Location", _args);
			CALLM1(_loc, "initFromEditor", _locSector);
			CALLM1(_loc, "setName", _locName);
			CALLM1(_loc, "setSide", _side);
			CALLM1(_loc, "setType", _locType);
			CALLM2(_loc, "setBorder", _locBorderType, _locBorder);
			//CALLM1(_loc, "setCapacityInf", _locCapacityInf); // capacityInf is calculated from actual buildings
			CALLM1(_loc, "setCapacityCiv", _locCapacityCiv); // capacityCiv is calculated based on civ density (see above)

			// Create police stations in cities
			if (_locType == LOCATION_TYPE_CITY and (random 10 < 4) /*(_locCapacityCiv >= 10)*/) then {
				// TODO: Add some visual/designs to this
				private _posPolice = +GETV(_loc, "pos");
				_posPolice = _posPolice vectorAdd [-200 + random 400, -200 + random 400, 0];
				// Find first building which is one of the police building types
				private _possiblePoliceBuildings = (_posPolice nearObjects 200) select {_x isKindOf "House"} select {(typeOf _x) in location_bt_police};

				if ((count _possiblePoliceBuildings) > 0) then {
					private _policeStationBuilding = selectRandom _possiblePoliceBuildings;
					private _args = [getPos _policeStationBuilding, CIVILIAN]; // Location created by noone
					private _policeStation = NEW_PUBLIC("Location", _args);
					CALLM2(_policeStation, "setBorder", "circle", 10);
					CALLM1(_policeStation, "processObjectsInArea", "House"); // We must add buildings to the array
					CALLM0(_policeStation, "addSpawnPosFromBuildings");
					CALLM1(_policeStation, "setSide", _side);
					CALLM1(_policeStation, "setName", format ["%1 police station" ARG _locName] );
					CALLM1(_policeStation, "setType", LOCATION_TYPE_POLICE_STATION);

					// TODO: Get city size or building count and scale police capacity from that ?
					CALLM1(_policeStation, "setCapacityInf", floor (8 + random 6));
					CALLM(_loc, "addChild", [_policeStation]);
					SETV(_policeStation, "useParentPatrolWaypoints", true);
					// add special gun shot sensor to police garrisons that will launch investigate->arrest goal ?

					// Decorate the police station building
					// todo maybe move it to another place?
					private _type = typeOf _policeStationBuilding;
					private _index = location_decorations_police findIf {_type in (_x#0)};
					if (_index != -1) then {
						private _arrayExport = location_decorations_police#_index#1;
						{
							_x params ["_offset", "_vDirAndUp"];
							private _texObj = createSimpleObject ["UserTexture1m_F", [0, 0, 0], false];
							_texObj setObjectTextureGlobal [0, "z\vindicta\addons\ui\pictures\policeSign.paa"];
							_texObj setPosWorld (_policeStationBuilding modelToWorldWorld _offset);
							_texObj setVectorDir (_policeStationBuilding vectorModelToWorld (_vDirAndUp#0));
							_texObj setVectorUp (_policeStationBuilding vectorModelToWorld (_vDirAndUp#1));
						} forEach _arrayExport;
					};
				};
			};

			if(_locType == LOCATION_TYPE_ROADBLOCK) then {
				_predefinedRoadblockPositions pushBack _locSectorPos;
			} else {
				if(_locType in [LOCATION_TYPE_BASE, LOCATION_TYPE_OUTPOST, LOCATION_TYPE_AIRPORT, LOCATION_TYPE_CITY]) then {
					_locationsForRoadblocks pushBack [_locSectorPos, _side];
				};
			};

			#ifdef __SMALL_MAP
			};
			#endif
		} forEach (entities "Vindicta_LocationSector");

		// Process locations for roadblocks
		private _roadblockPositionsAroundLocations = [];
		{ // forEach _locationsForRoadblocks;
			_x params ["_pos", "_side"];
			// TODO: improve this later
			private _positionsAroundLocation = CALL_STATIC_METHOD("Location", "findRoadblocks", [_pos]);
			_roadblockPositionsAroundLocations append _positionsAroundLocation;
			OOP_INFO_2("Roadblock positions around %1 : %2", _pos, _positionsAroundLocation);
			// Iterate all positions and remove those which are very close to each other
			private _i = 0;
		} forEach _locationsForRoadblocks;

		// Iterate created positions
		// Delete those which are too close to our _predefinedRoadblockPositions
		// Or too close to other positions
		private _i = 0;
		while {_i < (count _roadblockPositionsAroundLocations)} do {
			private _newPos = _roadblockPositionsAroundLocations select _i;

			// Check if this position is far enough from other positions
			OOP_INFO_1("Checking roadblock position: %1", _newPos);
			private _id0 = _roadblockPositionsAroundLocations findIf { !(_x isEqualTo _newPos) && (_x distance _newPos < 700)};
			private _id1 = _predefinedRoadblockPositions findIf { !(_x isEqualTo _newPos) && (_x distance _newPos < 700) };
			if ( (_id0 == NOT_FOUND) && (_id1 == NOT_FOUND) ) then {
				_i = _i + 1;
				OOP_INFO_0("  OK");
			} else {
				// Too close, delete it
				_roadblockPositionsAroundLocations deleteAt _i;
				OOP_INFO_0("  Too close to something else, deleting");
			};
		};

		// Final array of roadblock positions
		private _roadblockPositionsFinal = _roadblockPositionsAroundLocations + _predefinedRoadblockPositions;
		
		// Iterate all final positions
		private _commanders = [];
		{
			if (!IS_NULL_OBJECT(T_GETV(_x))) then {_commanders pushBack T_GETV(_x)};
		} forEach ["AICommanderWest", "AICommanderEast", "AICommanderInd"];
		
		{ // foreach _roadblockPositionsFinal			
			private _pos = _x;

			// Reveal positions to commanders
			{
				CALLM1(_x, "addRoadblockPosition", _pos);
			} forEach _commanders;

			// Create markers for debug
			#ifndef RELEASE_BUILD
			private _mrk = createMarker [format ["roadblock_%1", _pos apply {round _x}], _pos];
			_mrk setMarkerType "mil_triangle";
			_mrk setMarkerColor "ColorWhite";
			_mrk setMarkerPos _pos;
			_mrk setMarkerAlpha 1;
			_mrk setMarkerText "<Future roadblock>";
			#endif;
		} forEach _roadblockPositionsFinal;

	} ENDMETHOD;

	#define ADD_TRUCKS
	#define ADD_UNARMED_MRAPS
	//#define ADD_ARMED_MRAPS
	//#define ADD_ARMOR
	#define ADD_STATICS
	METHOD("createGarrison") {
		params [P_THISOBJECT, P_STRING("_locationType"), P_STRING("_faction"), P_SIDE("_side"), P_NUMBER("_cInf"), P_NUMBER("_cVehGround"), P_NUMBER("_cHMGGMG"), P_NUMBER("_cBuildingSentry"), P_NUMBER("_cCargoBoxes")];

		if (_faction == "police") exitWith {
			
			private _templateName = CALLM2(gGameMode, "getTemplateName", _side, "police");
			private _template = [_templateName] call t_fnc_getTemplate;

			private _args = [_side, [], _faction, _templateName]; // [P_THISOBJECT, P_SIDE("_side"), P_ARRAY("_pos"), P_STRING("_faction"), P_STRING("_templateName")];
			private _gar = NEW("Garrison", _args);

			OOP_INFO_MSG("Creating garrison %1 for faction %2 for side %3, %4 inf, %5 veh, %6 hmg/gmg, %7 sentries", [_gar ARG _faction ARG _side ARG _cInf ARG _cVehGround ARG _cHMGGMG ARG _cBuildingSentry]);
			

			// 75% out on patrol
			private _patrolGroups = 1 max (_cInf * 0.75 * 0.5);
			for "_i" from 1 to _patrolGroups do {
				private _patrolGroup = NEW("Group", [_side ARG GROUP_TYPE_PATROL]);
				for "_i" from 0 to 1 do {
					private _variants = [T_INF_SL, T_INF_officer, T_INF_officer];
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
				private _variants = [T_INF_SL, T_INF_officer, T_INF_officer];
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
				private _newUnit = NEW("Unit", [_template ARG T_VEH ARG T_VEH_car_unarmed ARG -1 ARG ""]);
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

		private _templateName = CALLM2(gGameMode, "getTemplateName", _side, _faction);
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
			[  0,   3,   T_GROUP_inf_sentry,        GROUP_TYPE_PATROL],
			[  0,  -1,   T_GROUP_inf_rifle_squad,   GROUP_TYPE_IDLE]
		];
		// Officers at airports and bases only
		if(_locationType == LOCATION_TYPE_AIRPORT) then {
			_infSpec =
				  [  3,  -3,   T_GROUP_inf_officer,       GROUP_TYPE_BUILDING_SENTRY]
				+ [  2,  -2,   T_GROUP_inf_recon_patrol,  GROUP_TYPE_IDLE]
				+ _infSpec;
		};
		// Officers at airports and bases only
		if(_locationType == LOCATION_TYPE_BASE) then {
			_infSpec =
				  [  1,  -1,   T_GROUP_inf_officer,       GROUP_TYPE_BUILDING_SENTRY]
				+ [  1,  -1,   T_GROUP_inf_recon_patrol,  GROUP_TYPE_IDLE]
				+ _infSpec;
		};

		private _vehGroupSpec = [
			//|Chance to spawn
			//|      |Min veh of this type
			//|      |    |Max veh of this type
			//|      |    |            |Veh type                          
			[  0.5,   0,  3,           T_VEH_MRAP_HMG],
			[  0.5,   0,  3,           T_VEH_MRAP_GMG],
			[  0.3,   0,  2,           T_VEH_APC],
			[  0.3,   0,  2,           T_VEH_IFV],
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

		// APCs, IFVs, tanks, MRAPs
		#ifdef ADD_ARMOR
		{
			_x params ["_chance", "_min", "_max", "_type"];
			if(random 1 <= _chance) then {
				private _i = 0;
				while{(_cVehGround > 0 or _i < _min) and (_max == -1 or _i < _max)} do {
					private _newGroup = CALLM(_gar, "createAddVehGroup", [_side ARG T_VEH ARG _type ARG -1]);
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

	// Initialize dynamic simulation
	METHOD("initDynamicSimulation") {
		#ifndef _SQF_VM
		params [P_THISOBJECT];

		// Don't remove spawn{}! For some reason without spawning it doesn't apply the values.
		// Probably it's because we currently have this executed inside isNil {} block

		0 spawn {
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
		};
		#endif
	} ENDMETHOD;

	// Returns the side of player faction
	/* public virtual */ METHOD("getPlayerSide") {
		WEST
	} ENDMETHOD;

	/* public virtual */ METHOD("getEnemySide") {
		independent
	} ENDMETHOD;

	METHOD("doSpawning") {
		params [P_THISOBJECT];

		if(T_GETV("lastSpawn") + T_GETV("spawningInterval") > TIME_NOW) exitWith {};
		T_SETV("lastSpawn", TIME_NOW);

		{
			private _loc = _x;
			private _side = GETV(_loc, "side");
			private _templateName = CALLM2(gGameMode, "getTemplateName", _side, "");
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

	// Registers location here
	// All locations must be registered at game mode so that it can save/load them
	METHOD("registerLocation") {
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];
		T_GETV("locations") pushBackUnique _loc;
	} ENDMETHOD;

	METHOD("getMessageLoop") {
		gMessageLoopGameMode;
	} ENDMETHOD;

	// -------------------------------------------------------------------------
	// |                         P L A Y E R  S A V E                          |
	// -------------------------------------------------------------------------

	GameMode_fnc_getPlayerInfo = {
		params [P_STRING("_uid"), P_OBJECT("_unit"), P_STRING("_name")];

		private _inventoryObj = ["new", _unit] call OO_INVENTORY;
		private _inv = "getInventory" call _inventoryObj;
		["delete", _inventoryObj] call OO_INVENTORY;

		[
			_uid,
			_name,
			getPosASL _unit,
			_inv
		]
	};

	GameMode_fnc_restorePlayerInfo = {
		params [P_OBJECT("_player"), P_ARRAY("_arr"), P_BOOL("_positionAsWell")];

		//_player setName _arr#1;
		if(_positionAsWell) then {
			_player setPosASL _arr#2;
		};

		private _inventoryObj = ["new", _player] call OO_INVENTORY;
		["setInventory", _arr#3] call _inventoryObj;
		["delete", _inventoryObj] call OO_INVENTORY;
	};
	
	METHOD("savePlayerInfo") {
		params [P_THISOBJECT, P_STRING("_uid"), P_OBJECT("_unit"), P_STRING("_name")];
		T_PRVAR(playerInfoArray);
		private _obj = [_uid, _unit, _name] call GameMode_fnc_getPlayerInfo;
		private _existing = _playerInfoArray findIf {
			_x#0 isEqualTo _uid
		};
		if(_existing == NOT_FOUND) then {
			_playerInfoArray pushBack _obj;
		} else {
			_playerInfoArray set [_existing, _obj];
		};
		diag_log format["Saving player info for %1: %2", name _unit, _obj];
		REMOTE_EXEC_CALL_STATIC_METHOD("ClientMapUI", "setPlayerRestoreData", [_obj], owner _unit, false);
	} ENDMETHOD;


	METHOD("syncPlayerInfo") {
		params [P_THISOBJECT, P_OBJECT("_player")];
		T_PRVAR(playerInfoArray);
		private _uid = getPlayerUID _player;
		private _existing = _playerInfoArray findIf {
			_x#0 isEqualTo _uid
		};
		private _playerInfo = if(_existing != NOT_FOUND) then {
			_playerInfoArray#_existing;
		} else {
			[]
		};
		diag_log format["Syncing player info for %1: %2", name _player, _playerInfo];
		REMOTE_EXEC_CALL_STATIC_METHOD("ClientMapUI", "setPlayerRestoreData", [_playerInfo], owner _player, NO_JIP);
	} ENDMETHOD;

	METHOD("clearPlayerInfo") {
		params [P_THISOBJECT, P_OBJECT("_player")];
		T_PRVAR(playerInfoArray);
		private _uid = getPlayerUID _player;
		private _existing = _playerInfoArray findIf {
			_x#0 isEqualTo _uid
		};
		if(_existing != NOT_FOUND) then {
			_playerInfoArray deleteAt _existing;
		};
		REMOTE_EXEC_CALL_STATIC_METHOD("ClientMapUI", "setPlayerRestoreData", [[]], owner _player, false);
	} ENDMETHOD;

	METHOD("getPlayerInfo") {
		params [P_THISOBJECT, P_OBJECT("_player")];
		T_PRVAR(playerInfoArray);
		private _uid = getPlayerUID _player;
		private _existing = _playerInfoArray findIf {
			_x#0 isEqualTo _uid
		};
		if(_existing != NOT_FOUND) then {
			_playerInfoArray#_existing
		} else {
			[]
		}
	} ENDMETHOD;

	// -------------------------------------------------------------------------
	// |                             S T O R A G E                             |
	// -------------------------------------------------------------------------

	/* override */ METHOD("preSerialize") {
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		diag_log format [" - - - - - - - - - - - - - - - - - - - - - - - - - -"];		
		diag_log format [" SAVING GAME MODE: %1", _thisObject];
		diag_log format [" - - - - - - - - - - - - - - - - - - - - - - - - - -"];

		// Start loading screen??

		// Disable all timers??

		// Save static variables of classes
		CALLSM1("Garrison", "saveStaticVariables", _storage);
		CALLSM1("Location", "saveStaticVariables", _storage);
		CALLSM1("Unit", "saveStaticVariables", _storage);
		CALLSM1("MessageReceiver", "saveStaticVariables", _storage);

		// Update player info for alive players
		{
			T_CALLM3("savePlayerInfo", getPlayerUID _x, _x, name _x);
		} forEach (allPlayers select { alive _x });

		// Lock all message loops in specific order
		private _msgLoops = [
								["messageLoopGameMode", 10],
								["messageLoopCommanderEast", 150],
								["messageLoopCommanderWest", 150],
								["messageLoopCommanderInd", 150],
								["messageLoopMain", 30],
								["messageLoopGroupAI", 10]
							];
		{
			_x params ["_loopName", "_timeout"];
			private _msgLoop = T_GETV(_loopName);
			private _text = format ["Locking thread %1, this could take up to %2 seconds -- be patient", _loopName, _timeout];
			diag_log _text;
			[_text] remoteExec ["systemChat"];
			if(!CALLM1(_msgLoop, "tryLockTimeout", _timeout)) then {
				private _text = format ["Warning: failed to lock message loop %1 in reasonable time, saving anyway.", _loopName];
				diag_log _text;
				[_text] remoteExec ["systemChat"];
			};
		} forEach _msgLoops; //(_msgLoops - ["messageLoopGameMode"]); // If this is run in the game mode loop, then it's locked already

		// Start loading screen
#ifdef RELEASE_BUILD
		startLoadingScreen ["Saving mission"];
#endif

		// Save message loops
		{
			_x params ["_loopName", "_timeout"];
			private _msgLoop = T_GETV(_loopName);
			diag_log format ["Saving thread: %1", _loopName];
			CALLM1(_storage, "save", _msgLoop);
		} forEach _msgLoops;

		// Save commanders
		// They will also save their garrisons
		{
			private _ai = T_GETV(_x);
			diag_log format ["Saving Commander AI: %1", _x];
			CALLM1(_storage, "save", _ai);
		} forEach ["AICommanderInd", "AICommanderWest", "AICommanderEast"];

		// Save locations
		{
			private _loc = _x;
			diag_log format ["Saving location: %1", _loc];
			CALLM1(_storage, "save", _loc);
		} forEach T_GETV("locations");

		T_CALLM1("_saveSpecialGarrisons", _storage);

		true
	} ENDMETHOD;

	/* override */ METHOD("postSerialize") {
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];
		
		// Call method of all base classes
		CALL_CLASS_METHOD("MessageReceiverEx", _thisObject, "postSerialize", [_storage]);

		private _msgLoops = [
								"messageLoopGameMode",
								"messageLoopCommanderEast",
								"messageLoopCommanderWest",
								"messageLoopCommanderInd",
								"messageLoopMain",
								"messageLoopGroupAI"
							];

		// Unlock all message loops
		{
			private _msgLoop = T_GETV(_x);
			diag_log format ["Unlocking message loop: %1", _x];
			CALLM0(_msgLoop, "unlock");
		} forEach _msgLoops; //(_msgLoops - ["messageLoopGameMode"]);

		diag_log format [" - - - - - - - - - - - - - - - - - - - - - - - - - -"];		
		diag_log format [" FINISHED SAVING GAME MODE: %1", _thisObject];
		diag_log format [" - - - - - - - - - - - - - - - - - - - - - - - - - -"];

		// End loading screen
		endLoadingScreen;

		true
	} ENDMETHOD;

	/* override */ METHOD("postDeserialize") {
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		if(!isServer) exitWith { // What the fuck?
			OOP_ERROR_0("Game mode must be loaded on server only!");
		};

		// Delete editor's special objects
		CALLSM0("Location", "deleteEditorAllowedAreaMarkers");
		CALLSM0("Location", "deleteEditorObjects");

		// Start loading screen
#ifdef RELEASE_BUILD
		startLoadingScreen ["Loading the mission"];
#endif

		diag_log format [" - - - - - - - - - - - - - - - - - - - - - - - - - -"];		
		diag_log format [" LOADING GAME MODE: %1", _thisObject];
		diag_log format [" - - - - - - - - - - - - - - - - - - - - - - - - - -"];

		// Call method of all base classes
		CALL_CLASS_METHOD("MessageReceiverEx", _thisObject, "postDeserialize", [_storage]);

		// Set default values if they weren't loaded due to older save version
		if(isNil{T_GETV("playerInfoArray")}) then {
			T_SETV("playerInfoArray", []);
		};
		if(isNil{T_GETV("savedSpecialGarrisons")}) then {
			T_SETV("savedSpecialGarrisons", []);
		};

		// Send players their restore points from this save, if they have any
		{
			T_CALLM1("syncPlayerInfo", _x);
		} forEach allPlayers;

		// Create timer service
		gTimerServiceMain = NEW("TimerService", [TIMER_SERVICE_RESOLUTION]); // timer resolution

		// Restore static variables of classes
		CALLSM1("Garrison", "loadStaticVariables", _storage);
		CALLSM1("Location", "loadStaticVariables", _storage);
		CALLSM1("Unit", "loadStaticVariables", _storage);
		CALLSM1("MessageReceiver", "loadStaticVariables", _storage);

		// Restore some variables
		T_SETV("lastSpawn", TIME_NOW);

		private _msgLoops = [
						"messageLoopGameMode",
						"messageLoopCommanderEast",
						"messageLoopCommanderWest",
						"messageLoopCommanderInd",
						"messageLoopMain",
						"messageLoopGroupAI"
					];

		// Load message loops
		{
			private _msgLoop = T_GETV(_x);
			diag_log format ["Loading message loop: %1", _x];
			CALLM1(_storage, "load", _msgLoop);
			CALLM0(_msgLoop, "lock"); // We lock the message loops during the game load process
		} forEach	_msgLoops;

		// Set global variables
		gMessageLoopMain = T_GETV("messageLoopMain");
		gMessageLoopGroupAI = T_GETV("messageLoopGroupAI");
		gMessageLoopGameMode = T_GETV("messageLoopGameMode");
		gMessageLoopCommanderInd = T_GETV("messageLoopCommanderInd");
		gMessageLoopCommanderWest = T_GETV("messageLoopCommanderWest");
		gMessageLoopCommanderEast = T_GETV("messageLoopCommanderWest");

		// Create message loops we have not created yet
		// It will not create message loops which we have loaded before
		T_CALLM0("_createMessageLoops");

		// Finish message loop setup
		T_CALLM0("_setupMessageLoops");

		// Initialize mission event handlers
		T_CALLM0("_initMissionEventHandlers");

		// Create other global objects

		// Garrison stimulus manager
		gStimulusManagerGarrison = NEW_PUBLIC("StimulusManager", [gMessageLoopMain]); // Can postMethodAsync stimulus to it to annoy garrisons
		PUBLIC_VARIABLE "gStimulusManagerGarrison";

		// Garbage Collector
		gGarbageCollector = NEW("GarbageCollector", []);

		// Personal Inventory
		gPersonalInventory = NEW("PersonalInventory", []);

		// Create the garrison server
		gGarrisonServer = NEW_PUBLIC("GarrisonServer", []);
		PUBLIC_VARIABLE "gGarrisonServer";

		// Location unit array provider
		gLUAP = NEW("LocationUnitArrayProvider", []);

		// Main message loop manager
		gMessageLoopMainManager = NEW("MessageLoopMainManager", []);

		// Group message loop manager
		gMessageLoopGroupManager = NEW("MessageLoopGroupManager", []);

		// Special garrisons
		T_CALLM1("_loadSpecialGarrisons", _storage);

		// Load locations
		{
			private _loc = _x;
			diag_log format ["Loading location: %1", _loc];
			CALLM1(_storage, "load", _loc);
		} forEach T_GETV("locations");

		// Load commanders
		{
			private _ai = T_GETV(_x);
			diag_log format ["Loading Commander AI: %1", _x];
			CALLM1(_storage, "load", _ai);
		} forEach ["AICommanderInd", "AICommanderWest", "AICommanderEast"];

		// Set global variables
		gAICommanderInd = T_GETV("AICommanderInd");
		PUBLIC_VARIABLE("gAICommanderInd");
		gAICommanderWest = T_GETV("AICommanderWest");
		PUBLIC_VARIABLE("gAICommanderWest");
		gAICommanderEast = T_GETV("AICommanderEast");
		PUBLIC_VARIABLE("gAICommanderEast");

		// Unlock all message loops
		{
			private _msgLoop = T_GETV(_x);
			diag_log format ["Unlocking message loop: %1", _x];
			CALLM0(_msgLoop, "unlock");
		} forEach _msgLoops;

		// Start commanders
		T_CALLM0("startCommanders");

		// Init dynamic simulation
		T_CALLM0("initDynamicSimulation");

		diag_log format [" - - - - - - - - - - - - - - - - - - - - - - - - - -"];		
		diag_log format [" FINISHED LOADING GAME MODE: %1", _thisObject];
		diag_log format [" - - - - - - - - - - - - - - - - - - - - - - - - - -"];

		// End loading screen
		endLoadingScreen;

		true
	} ENDMETHOD;

ENDCLASS;