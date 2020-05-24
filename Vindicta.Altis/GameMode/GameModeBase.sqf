#include "common.hpp"

// Default resolution of our timer service
// !! Now it's set to 0, which will result in evaluation on each frame
// This way we can process data more often instead of processing it less often and in larget batches
#define TIMER_SERVICE_RESOLUTION 0.0

#define MESSAGE_LOOP_MAIN_MAX_MESSAGES_IN_SERIES 16

#define ALL_MESSAGE_LOOPS_AND_TIMEOUTS ([["messageLoopGameMode", 10], ["messageLoopCommanderEast", 150], ["messageLoopCommanderWest", 150], ["messageLoopCommanderInd", 150], ["messageLoopMain", 30], ["messageLoopGroupAI", 10]])
#define ALL_MESSAGE_LOOPS (["messageLoopGameMode", "messageLoopCommanderEast", "messageLoopCommanderWest", "messageLoopCommanderInd", "messageLoopMain", "messageLoopGroupAI"])

#ifndef _SQF_VM
#define CHAT_MSG(msg) [msg] remoteExec ["systemChat", ON_CLIENTS, NO_JIP]; diag_log msg
#define CHAT_MSG_FMT(fmt, args) [format ([fmt] + args)] remoteExec ["systemChat", ON_CLIENTS, NO_JIP]; diag_log format ([fmt] + args)
#else
#define CHAT_MSG(msg)
#define CHAT_MSG_FMT(fmt, args)
#endif
FIX_LINE_NUMBERS()

// Base class for Game Modes. A Game Mode is a set of customizations to 
// scenario initialization and ongoing gameplay mechanics.
#define OOP_CLASS_NAME GameModeBase
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
	VARIABLE_ATTR("tNameCivilian", [ATTR_SAVE]);

	// Other values
	VARIABLE_ATTR("enemyForceMultiplier", [ATTR_SAVE]);

	VARIABLE_ATTR("savedPlayerInfoArray", [ATTR_SAVE]);
	VARIABLE_ATTR("savedSpecialGarrisons", [ATTR_SAVE]);

	VARIABLE_ATTR("savedMarkers", [ATTR_SAVE_VER(21)]);

	VARIABLE("playerInfoArray");
	VARIABLE("startSuspendTime");

	METHOD(new)
		params [P_THISOBJECT, P_STRING("_tNameEnemy"), P_STRING("_tNamePolice"), P_STRING("_tNameCivilian"), P_NUMBER("_enemyForcePercent")];
		T_SETV("name", "unnamed");
		T_SETV("spawningEnabled", false);

		#ifdef RELEASE_BUILD
		T_SETV("spawningInterval", 3600);
		#else
		// Faster spawning when we are testing
		T_SETV("spawningInterval", 120);
		#endif
		FIX_LINE_NUMBERS()
		T_SETV("lastSpawn", GAME_TIME);

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
		T_SETV_PUBLIC("tNameCivilian", "tCivilian"); // Required on client

		// Apply values from arguments
		T_SETV("enemyForceMultiplier", 1);
		if (_tNameEnemy != "") then {
			T_SETV("tNameMilInd", _tNameEnemy);
		};
		if (_tNamePolice != "") then {
			T_SETV("tNamePolice", _tNamePolice);
		};
		if (_tNameCivilian != "") then {
			T_SETV_PUBLIC("tNameCivilian", _tNameCivilian); // Required on client
		};
		
		T_SETV("enemyForceMultiplier", _enemyForcePercent/100);

		T_SETV("locations", []);

		T_SETV("playerInfoArray", []);

		T_SETV("savedSpecialGarrisons", []);
		T_SETV("savedMarkers", []);

	ENDMETHOD;

	METHOD(delete)
		params [P_THISOBJECT];

	ENDMETHOD;

	// Called in init.sqf. Do NOT override this, implement the various specialized virtual functions
	// below it instead.
	METHOD(init)
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

		#ifndef _SQF_VM
		if(IS_SERVER) then {
			REMOTE_EXEC_CALL_STATIC_METHOD("GameModeBase", "startLoadingScreen", ["init" ARG "Initializing..."], ON_ALL, NO_JIP);
		};
		#endif

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

			CRITICAL_SECTION {
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
				FIX_LINE_NUMBERS()
				T_CALLM("populateLocations", []);
				T_CALLM("initServerOnly", []);

				// Call our first process event immediately, to help things "settle" before we show them to the player.
				T_CALLM("process", []);
			};

			// Init dynamic simulation
			T_CALLM0("initDynamicSimulation");

			// todo load it from profile namespace or whatever

			// Add mission event handler to destroy vehicles in destroyed houses, gets triggered when house is destroyed
			T_CALLM0("_initMissionEventHandlers");

		};
		if (HAS_INTERFACE || IS_HEADLESSCLIENT) then {
			T_CALLM("initClientOrHCOnly", []);
		};
		if (IS_HEADLESSCLIENT) then {
			OOP_INFO_2("Mission: I am a headless client! My player object is: %1. I have just connected! My owner ID is: %2", player, clientOwner);

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
		};
		T_CALLM("postInitAll", []);

		#ifndef _SQF_VM
		if(IS_SERVER) then {
			REMOTE_EXEC_CALL_STATIC_METHOD("GameModeBase", "endLoadingScreen", ["init"], ON_ALL, NO_JIP);
		};
		#endif

		PROFILE_SCOPE_START(GameModeEnd);
	ENDMETHOD;
	
	// Called regularly in its own thread to update gameplay
	// states, mechanics etc. implemented by the Game Mode.
	/* private */ METHOD(process)
		params [P_THISOBJECT];

		// Suspend/resume the game on dedicated
		#ifndef _SQF_VM
		if(IS_DEDICATED) then {
			if(vin_server_suspendWhenEmpty && count HUMAN_PLAYERS == 0) then {
				T_CALLM1("suspend", "Game suspended while no players connected");
				// Wait for a player to connect again. Saving on empty server is delayed 5 minutes from when the 
				// last player disconnected to avoid churning.
				private _saveTime = time + 5 * 60;
				waitUntil {
					if(_saveTime > 0 && _saveTime < time) then {
						CALLM0(gGameManager, "checkEmptyAutoSave");
						_saveTime = -1; // disable further auto saves
					};
					count HUMAN_PLAYERS > 0
				};
				T_CALLM0("resume");
			};
		};
		if(IS_SERVER) then {
			CALLM0(gGameManager, "checkPeriodicAutoSave");

			if(timeMultiplier != vin_server_gameSpeed) then {
				setTimeMultiplier vin_server_gameSpeed;
			};
		};
		#endif
		FIX_LINE_NUMBERS()


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
	ENDMETHOD;

	// Add garrisons to locations based where specified.
	// Behaviour is controlled by virtual functions "getLocationOwner" and "initGarrison",
	// or you can override the entire function.
	/* protected virtual */METHOD(populateLocations)
		params [P_THISOBJECT];

		// Create initial garrisons
		{
			OOP_INFO_2("Populating location: %1, type: %2", _x, CALLM0(_x, "getType"));

			private _loc = _x;
			private _side = T_CALLM1("getLocationOwner", _loc);

			OOP_DEBUG_MSG("init loc %1 to side %2", [_loc ARG _side]);

			private _cmdr = CALL_STATIC_METHOD("AICommander", "getAICommander", [_side]);
			if(!IS_NULL_OBJECT(_cmdr)) then {
				CALLM1(_cmdr, "registerLocation", _loc);

				//private _gars = T_CALLM("initGarrisons", [_loc ARG _side]);
				{
					private _gar = _x;
					OOP_DEBUG_MSG("Creating garrison %1 for location %2 (%3)", [_gar ARG _loc ARG _side]);
					CALLM1(_gar, "setLocation", _loc);
					// CALLM1(_loc, "registerGarrison", _gar); // I think it's not needed? setLocation should register it as well
					CALLM0(_gar, "activate");
				} forEach T_CALLM2("initGarrisons", _loc, _side);
				// if(!IS_NULL_OBJECT(_gar)) then {
				// 	OOP_DEBUG_MSG("Creating garrison %1 for location %2 (%3)", [_gar ARG _loc ARG _side]);

				// 	CALLM1(_gar, "setLocation", _loc);
				// 	// CALLM1(_loc, "registerGarrison", _gar); // I think it's not needed? setLocation should register it as well
				// 	CALLM0(_gar, "activate");
				// };
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
					// If it's player side, let it only know about cities
					if (_type == LOCATION_TYPE_CITY) then {
						OOP_INFO_1("  revealing to commander: %1", _sideCommander);
						CALLM2(_x, "postMethodAsync", "updateLocationData", [_loc ARG CLD_UPDATE_LEVEL_TYPE ARG sideUnknown ARG false ARG false]);
					} else {
						if (_sideCommander != _playerSide && {CALLM0(_loc, "isBuilt")}) then { // Enemies are smart
							// This part determines commander's knowledge about enemy locations at game init
							// Only relevant for One AI vs Another AI Commander game mode I think
							//private _updateLevel = [CLD_UPDATE_LEVEL_TYPE, CLD_UPDATE_LEVEL_UNITS] select (_sideCommander == _side);
							OOP_INFO_1("  revealing to commander: %1", _sideCommander);
							private _updateLevel = CLD_UPDATE_LEVEL_UNITS;
							CALLM2(_x, "postMethodAsync", "updateLocationData", [_loc ARG _updateLevel ARG sideUnknown ARG false]);
						};
					};
				};
			} forEach [T_GETV("AICommanderWest"), T_GETV("AICommanderEast"), T_GETV("AICommanderInd")];

			CALLM0(_loc, "initBuildProgress");
		} forEach GET_STATIC_VAR("Location", "all");
	ENDMETHOD;

	// Creates a civilian garrison at a city location
	METHOD(populateCity)
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];

		private _templateName = T_CALLM1("getTemplateName", CIVILIAN);
		private _template = [_templateName] call t_fnc_getTemplate;
		private _args = [GARRISON_TYPE_GENERAL, CIVILIAN, [], "civilian", _templateName];
		private _gar = NEW("Garrison", _args);
		private _maxCars = CALLM0(_loc, "getMaxCivilianVehicles");
		for "_i" from 0 to _maxCars do {
			private _newUnit = NEW("Unit", [_template ARG T_VEH ARG T_VEH_DEFAULT ARG -1 ARG ""]);
			CALLM(_gar, "addUnit", [_newUnit]);
		};
		CALLM1(_gar, "setLocation", _loc);
		CALLM1(_loc, "registerGarrison", _gar);
		CALLM1(_gar, "enableAutoSpawn", true);
	ENDMETHOD;

	// Creates message loops
	METHOD(_createMessageLoops)
		params [P_THISOBJECT];

		if(IS_SERVER || IS_HEADLESSCLIENT) then {
			// Main message loop for garrisons
			if (isNil "gMessageLoopMain") then {
				gMessageLoopMain = NEW("MessageLoop", ["Main thread"]);
				T_SETV("messageLoopMain", gMessageLoopMain);
			};

			// Message loop for group AI
			if (isNil "gMessageLoopGroupAI") then {
				private _args = ["Group AI", 128, 0, true]; // Unscheduled!
				gMessageLoopGroupAI = NEW("MessageLoop", _args);
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


	ENDMETHOD;

	// Initializes properties of message loops, which should be created by now
	METHOD(_setupMessageLoops)
		params [P_THISOBJECT];

		if (!IS_NULL_OBJECT(T_GETV("messageLoopMain"))) then {
			CALLM(gMessageLoopMain, "addProcessCategory", ["AIGarrisonSpawned"		ARG 20 ARG 3  ARG 15]); // Tag, priority, min interval, max interval
			CALLM(gMessageLoopMain, "addProcessCategory", ["AIGarrisonDespawned"	ARG 10 ARG 10 ARG 30]);
			CALLM1(gMessageLoopMain, "setMaxMessagesInSeries", MESSAGE_LOOP_MAIN_MAX_MESSAGES_IN_SERIES);
		};

		if (!IS_NULL_OBJECT(T_GETV("messageLoopGroupAI"))) then {
			CALLM(gMessageLoopGroupAI, "addProcessCategoryUnscheduled", ["AIGroup" ARG 1 ARG 0 ARG 4]); // Interval, minObjPerFrame, maxObjPerFrame
			CALLM(gMessageLoopGroupAI, "addProcessCategoryUnscheduled", ["AIInfantry" ARG 0.2 ARG 1 ARG 2]); // Interval, minObjPerFrame, maxObjPerFrame
			CALLM(gMessageLoopGroupAI, "addProcessCategoryUnscheduled", ["AILow" ARG 3 ARG 0 ARG 1]); // Interval, minObjPerFrame, maxObjPerFrame
		};

		if(!IS_NULL_OBJECT(T_GETV("messageLoopGameMode"))) then {
			CALLM(gMessageLoopGameMode, "addProcessCategory", ["GameModeProcess" ARG 10 ARG 60 ARG 120]);
			CALLM2(gMessageLoopGameMode, "addProcessCategoryObject", "GameModeProcess", _thisObject);
		};

		#ifndef _SQF_VM
		// Start a periodic check which will restart message loops if needed
		[{CALLM0(_this#0, "_checkMessageLoops")}, [_thisObject], 2] call CBA_fnc_waitAndExecute;
		#endif
		FIX_LINE_NUMBERS()
	ENDMETHOD;

	METHOD(_checkMessageLoops)
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

					#ifdef RELEASE_BUILD
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
					#endif
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
			FIX_LINE_NUMBERS()
		} else {
			// Broadcast notification
			T_CALLM1("_broadcastCrashNotification", _crashedMsgLoops);

			#ifdef RELEASE_BUILD
			// Send msg to game manager to perform emergency saving
			CALLM2(gGameManager, "postMethodAsync", "serverSaveGameRecovery", []);
			#endif
			FIX_LINE_NUMBERS()
		};
	ENDMETHOD;

	METHOD(_broadcastCrashNotification)
		params [P_THISOBJECT, P_ARRAY("_crashedMsgLoops")];

		// Report crashed threads, initiate emergency save

		// Format text
		private _text = "Threads have crashed: ";
		{ _text = _text + GETV(_x, "name") + " "; } forEach _crashedMsgLoops;
		_text = _text + ". Restart the mission after saving is over, send the .RPT to devs";

		// Broadcast notification
		REMOTE_EXEC_CALL_STATIC_METHOD("NotificationFactory", "createCritical", [_text], ON_CLIENTS, NO_JIP);

		// Broadcast it to system chat too
		CHAT_MSG("CRITICAL MISSION ERROR:");
		CHAT_MSG(_text);

		// todo: send emails, deploy pigeons

		#ifndef _SQF_VM
		// Do it once in a while
		[{CALLM1(_this#0, "_broadcastCrashNotification", _this#1)}, [_thisObject, _crashedMsgLoops], 20] call CBA_fnc_waitAndExecute;
		#endif
		FIX_LINE_NUMBERS()
	ENDMETHOD;

	METHOD(_initMissionEventHandlers)
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
			if(alive _unit) then {
				CALLM3(gGameMode, "savePlayerInfo", _uid, _unit, _name);
			};
			false;
		}];
		#endif
		FIX_LINE_NUMBERS()
	ENDMETHOD;

	// -------------------------------------------------------------------------
	// |                  V I R T U A L   F U N C T I O N S                    |
	// -------------------------------------------------------------------------
	// These are the customization points for game mode setups, implement them
	// in derived classes.
	/* protected virtual */ METHOD(preInitAll)
		params [P_THISOBJECT];

	ENDMETHOD;

	/* protected virtual */ METHOD(initServerOrHC)
		params [P_THISOBJECT];

	ENDMETHOD;

	/* protected virtual */ METHOD(initServerOnly)
		params [P_THISOBJECT];

		T_CALLM0("postLoadServerOnly");
	ENDMETHOD;

	/* protected virtual */ METHOD(initClientOrHCOnly)
		params [P_THISOBJECT];

	ENDMETHOD;

	/* protected virtual */ METHOD(initHCOnly)
		params [P_THISOBJECT];

	ENDMETHOD;

	/* protected virtual */ METHOD(initClientOnly)
		params [P_THISOBJECT];
		// Request saved inventory
		#ifndef _SQF_VM
		if(!isNil "gGameModeServer") then {
			REMOTE_EXEC_CALL_METHOD(gGameModeServer, "syncPlayerInfo", [player], ON_SERVER);
		};
		#endif
		FIX_LINE_NUMBERS()

		CALLSM0("undercoverMonitor", "staticInit");
	ENDMETHOD;

	/* protected virtual */ METHOD(postInitAll)
		params [P_THISOBJECT];

	ENDMETHOD;

	/* protected virtual */ METHOD(postLoadServerOnly)
		params [P_THISOBJECT];

		// Add undercover items from Civ faction
		private _civTemplate = T_CALLM1("getTemplate", civilian);
		_civTemplate call t_fnc_addUndercoverItems;

		missionNamespace setVariable["ACE_maxWeightDrag", 10000, true]; // fix loot crates being undraggable
	ENDMETHOD;

	/* protected virtual */ METHOD(getLocationOwner)
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];
		CIVILIAN
	ENDMETHOD;

	// Returns template name for given side and faction
	/* public virtual */ METHOD(getTemplateName)
		params [P_THISOBJECT, P_SIDE("_side"), P_STRING("_faction")];

		switch(_faction) do {
			case "police":				{ T_GETV("tNamePolice") };  //{ "tRHS_AAF_police" }; // { "tPOLICE" };
			
			default { // "military"
				switch(_side) do {
					case WEST:			{ T_GETV("tNameMilWest") };
					case EAST:			{ T_GETV("tNameMilEast") };
					case INDEPENDENT:	{ T_GETV("tNameMilInd") }; //{"tRHS_AAF_2020"}; // { "tAAF" };
					case CIVILIAN:		{ T_GETV("tNameCivilian") };
					default				{ "tDEFAULT" };
				}
			};
		};
	ENDMETHOD;

	// Returns template for given side and faction
	/* public virtual */METHOD(getTemplate)
		params [P_THISOBJECT, P_SIDE("_side"), P_STRING("_faction")];
		private _templateName = T_CALLM2("getTemplateName", _side, _faction);
		[_templateName] call t_fnc_getTemplate
	ENDMETHOD;

	/* protected virtual */ METHOD(initGarrisons)
		params [P_THISOBJECT, P_OOP_OBJECT("_loc"), P_SIDE("_side")];

		private _locationType = GETV(_loc, "type");

		private _garrisons = [];
		if(_locationType in [LOCATION_TYPE_AIRPORT, LOCATION_TYPE_BASE, LOCATION_TYPE_OUTPOST]) then {
			private _cInf = (T_GETV("enemyForceMultiplier") * (CALLM0(_loc, "getCapacityInf") min 45)) max 6; // We must return some sane infantry, because airfields and bases can have too much infantry
			private _cVehGround = CALLM(_loc, "getUnitCapacity", [T_PL_tracked_wheeled ARG GROUP_TYPE_ALL]) min 10;
			private _cHMGGMG = CALLM(_loc, "getUnitCapacity", [T_PL_HMG_GMG_high ARG GROUP_TYPE_ALL]);
			private _cCargoBoxes = 2;
			private _args = [_locationType, _side, _cInf, _cVehGround, _cHMGGMG, _cCargoBoxes, 80];
			_garrisons pushBack T_CALLM("createMilitaryGarrison", _args);
		};
		if(_locationType == LOCATION_TYPE_POLICE_STATION) then {
			private _cInf = (T_GETV("enemyForceMultiplier")*(CALLM0(_loc, "getCapacityInf") min 16)) max 6;
			private _cVehGround = CALLM(_loc, "getUnitCapacity", [T_PL_tracked_wheeled ARG GROUP_TYPE_ALL]);
			private _args = [_side, _cInf, _cVehGround, 2, 50];
			_garrisons pushBack T_CALLM("createPoliceGarrison", _args);
		};
		if(_locationType == LOCATION_TYPE_AIRPORT) then {
			// TODO: control this via difficulty setting?
			private _cVehHeli = 0; //CALLM0(_loc, "getCapacityHeli");
			private _cVehPlanes = 0; //CALLM0(_loc, "getCapacityPlane");
			private _args = [_side, _cVehHeli, _cVehPlanes];
			_garrisons pushBack T_CALLM("createAirGarrison", _args);
		};
		_garrisons
	ENDMETHOD;

	// Override this to do stuff when player spawns
	// Call the method of base class(that is, this class)
	/* protected virtual */METHOD(playerSpawn)
		params [P_THISOBJECT, P_OBJECT("_newUnit"), P_OBJECT("_oldUnit"), "_respawn", "_respawnDelay", P_ARRAY("_restoreData"), P_BOOL("_restorePosition")];

		OOP_INFO_1("PLAYER SPAWN: %1", _this);

		// Single player specific setup
		if(!IS_MULTIPLAYER) then {
			// We need to catch player death so we can "respawn" them fakely
			OOP_INFO_1("Added killed EH to %1", _newUnit);
			if(isNil {_newUnit getVariable "_player_respawn_eh"}) then {
				private _eh = [_newUnit, "Killed", {
					params ["_unit"];
					CALLM1(gGameMode, "singlePlayerKilled", _unit);
				}] call CBA_fnc_addBISEventHandler;
				_newUnit setVariable ["_player_respawn_eh", _eh];
			};
		};

		// Give player good score to avoid renegade possibilities
		_newUnit setUnitRank "COLONEL";

		// Create a suspiciousness monitor for player
		NEW("UndercoverMonitor", [_newUnit]);

		// Create scroll menu to talk to civilians
		pr0_fnc_talkCond = { // I know I overwrite it every time but who cares now :/
			private _civ = [7] call pr0_fnc_coneTarget;
			!isNull _civ
			&& {!isNil {_civ getVariable CIVILIAN_PRESENCE_CIVILIAN_VAR_NAME}}
			//&& {(_target distance _civ) < 7}
			&& {alive _civ}
			&& {!(_civ getVariable ["#arrested", false])}
			&& {!(_civ getVariable [CP_VAR_IS_TALKING, false])}
		};

		_newUnit addAction [(("<img image='a3\ui_f\data\IGUI\Cfg\simpleTasks\types\talk_ca.paa' size='1' color = '#FFFFFF'/>") + ("<t size='1' color = '#FFFFFF'> Talk</t>")), // title
						{
							private _civ = [7] call pr0_fnc_coneTarget;
							if(!isNull _civ) then {
								[_civ, 'talk'] spawn CivPresence_fnc_talkTo;
							};
						}, // Script
						0, // Arguments
						9000, // Priority
						true, // ShowWindow
						false, //hideOnUse
						"", //shortcut
						"call pr0_fnc_talkCond", //condition
						7, //radius
						false, //unconscious
						"", //selection
						""]; //memoryPoint

		_newUnit addAction [(("<img image='a3\ui_f\data\Map\Markers\Military\unknown_CA.paa' size='1' color = '#FFA300'/>") + ("<t size='1' color = '#FFA300'> Ask about intel</t>")), // title
						{
							private _civ = [7] call pr0_fnc_coneTarget;
							if(!isNull _civ) then {
								[_civ, 'intel'] spawn CivPresence_fnc_talkTo;
							};
						}, // Script
						0, // Arguments
						8999, // Priority
						true, // ShowWindow
						false, //hideOnUse
						"", //shortcut
						"call pr0_fnc_talkCond", //condition
						7, //radius
						false, //unconscious
						"", //selection
						""]; //memoryPoint

		_newUnit addAction [(("<img image='a3\ui_f\data\GUI\Rsc\RscDisplayMain\profile_player_ca.paa' size='1' color = '#FFFFFF'/>") + ("<t size='1' color = '#FFFFFF'> Incite</t>")), // title
						"[cursorTarget, 'agitate'] spawn CivPresence_fnc_talkTo", // Script
						0, // Arguments
						8998, // Priority
						true, // ShowWindow
						false, //hideOnUse
						"", //shortcut
						"call pr0_fnc_talkCond", //condition
						7, //radius
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
			private _co = cursorObject;
			!isNull _co 
			&& {vehicle player == player}										// Player must be on foot
			&& {_co distance player < 7}										// Player must be close to object
			&& {! (_co isKindOf "Man")}											// Object must not be infantry
			&& {['', player] call PlayerMonitor_fnc_isUnitAtFriendlyLocation}	// Player must be at a friendly location
			&& {(['', _co] call unit_fnc_getUnitFromObjectHandle) != ''}		// Object must be a valid unit OOP object (no shit spawned by zeus for now)
			&& {alive _co}														// Object must be alive
		};
		_newUnit addAction [format ["<img size='1.5' image='\A3\ui_f\data\GUI\Rsc\RscDisplayMain\infodlcsowned_ca.paa' />  %1", "Attach to garrison"], // title // pic: arrow pointing down
						{
							isNil {
								private _co = cursorObject;
								if(!isNull _co) then {
									NEW("AttachToGarrisonDialog", [_co])
								};
							}
						}, // Open the UI dialog
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

		// Action to add unit to player squad
		pr0_fnc_groupUnitCond = {
			private _co = [7] call pr0_fnc_coneTarget;
			!isNull _co
			&& {vehicle player == player}											// Player must be on foot
			&& {!isPlayer _co}														// Object must not be player
			&& {_co isKindOf "Man"}													// Object must be infantry
			&& {side group _co isEqualTo side group player}							// Object must be on real player side
			&& {!(group _co isEqualTo group player)}								// Object must not already be in player group
			&& {!isPlayer leader _co}												// Object must not be already led by a player
			&& {(['', _co] call unit_fnc_getUnitFromObjectHandle) != NULL_OBJECT}	// Object must be a valid unit OOP object (no shit spawned by zeus for now)
			&& {alive _co}															// Object must be alive
		};
		_newUnit addAction [format ["<img size='1.5' image='\A3\ui_f\data\GUI\Rsc\RscDisplayMain\infodlcsowned_ca.paa' /><img size='1.5' image='\A3\ui_f\data\GUI\Rsc\RscDisplayMain\menu_singleplayer_ca.paa' />  %1", "Take unit"], // title // pic: arrow pointing down and single man
						{
							isNil {
								private _co = [7] call pr0_fnc_coneTarget;
								if(!isNull _co) then {
									private _args = [player, [_co]];
									// Steal the unit to players group
									REMOTE_EXEC_CALL_STATIC_METHOD("Garrison", "addUnitsToPlayerGroup", _args, ON_SERVER, NO_JIP);
								};
							}
						},
						0, // Arguments
						0.1, // Priority
						false, // ShowWindow
						false, //hideOnUse
						"", //shortcut
						"call pr0_fnc_groupUnitCond", //condition
						5, //radius
						false, //unconscious
						"", //selection
						""]; //memoryPoint

		// Action to add units group to player group
		_newUnit addAction [format ["<img size='1.5' image='\A3\ui_f\data\GUI\Rsc\RscDisplayMain\infodlcsowned_ca.paa' /><img size='1.5' image='\A3\ui_f\data\GUI\Rsc\RscDisplayMain\menu_multiplayer_ca.paa' />  %1", "Take group"], // title // pic: arrow pointing down and three men
						{
							isNil {
								private _co = [7] call pr0_fnc_coneTarget;
								if(!isNull _co) then {
									private _args = [player, units group _co];
									// Steal the unit to players group
									REMOTE_EXEC_CALL_STATIC_METHOD("Garrison", "addUnitsToPlayerGroup", _args, ON_SERVER, NO_JIP);
								};
							}
						},
						0, // Arguments
						0.1, // Priority
						false, // ShowWindow
						false, //hideOnUse
						"", //shortcut
						"call pr0_fnc_groupUnitCond", //condition
						5, //radius
						false, //unconscious
						"", //selection
						""]; //memoryPoint

		// Action to disable alarm in police stations
		pr0_fnc_canDisableAlarm = {
			private _loc = CALL_STATIC_METHOD("Location", "getLocationAtPos", [position player]);
			_loc != NULL_OBJECT && { CALLM0(_loc, "getType") == LOCATION_TYPE_POLICE_STATION } && { !CALLM0(_loc, "isAlarmDisabled") }
		};
		pr0_fnc_disableAlarm = {
			private _loc = CALL_STATIC_METHOD("Location", "getLocationAtPos", [position player]);
			if(_loc != NULL_OBJECT) then {
				CALLM1(_loc, "setAlarmDisabled", true);
			};
		};
		_newUnit addAction [format ["<img size='1.5' image='\A3\ui_f\data\igui\rscingameui\rscunitinfoairrtdfull\ico_cpt_sound_off_ca.paa' />  %1", "Disable alarm"], // title
						{call pr0_fnc_disableAlarm}, // disable alarm
						0, // Arguments
						-1, // Priority
						false, // ShowWindow
						false, //hideOnUse
						"", //shortcut
						"call pr0_fnc_canDisableAlarm", //condition
						2, //radius
						false, //unconscious
						"", //selection
						""]; //memoryPoint

		// Give player a lockpick
		_newUnit addItemToUniform "ACE_key_lockpick";

		// Restore data
		private _dataWasRestored = if(!(_restoreData isEqualTo [])) then {
			[_newUnit, _restoreData, _restorePosition] call GameMode_fnc_restorePlayerInfo;
			// Clear player gear immediately on this client
			CALL_STATIC_METHOD("ClientMapUI", "setPlayerRestoreData", [[]]);
			// Tell the server to clear it as well, which will also update the client (just to make sure)
			REMOTE_EXEC_CALL_METHOD(gGameModeServer, "clearPlayerInfo", [_newUnit], ON_SERVER);
			true
		} else {
			false
		};

		_dataWasRestored
	ENDMETHOD;

	// Player death event handler in SP
	// SP is special in this regard, because there is no respawn, so we must make it ourselves, yay \o/
	/* protected virtual */ METHOD(singlePlayerKilled)
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
		private _newGroup = createGroup (side group _oldUnit);
		private _newUnit = _newGroup createUnit [typeOf _oldUnit, [0,0,0], [], 0, "NONE"];
		selectPlayer _newUnit;
		deleteGroup group _oldUnit;
		_newUnit spawn {
			waitUntil {
				player setName profileName;
				sleep 0.01;
				name _this == profileName
			};
		};

		//unassignCurator zeus1;		zeus1 is nil anyway? I think we can use ACE now to add zeus
		//player assignCurator zeus1;

		// Standard player respawn handler script like in MP
		[player, _oldUnit, "", 0, "GameModeBase singlePlayerKilled"] call compile preprocessFileLineNumbers "onPlayerRespawn.sqf";
	ENDMETHOD;

	// Override this to perform periodic game mode updates
	/* protected virtual */METHOD(update)
		params [P_THISOBJECT];
	ENDMETHOD;

	// Override this to perform actions when a location spawns
	/* protected virtual */METHOD(locationSpawned)
		params [P_THISOBJECT, P_OOP_OBJECT("_location")];
	ENDMETHOD;

	// Override this to perform actions when a location despawns
	/* protected virtual */METHOD(locationDespawned)
		params [P_THISOBJECT, P_OOP_OBJECT("_location")];
	ENDMETHOD;

	// Override this to perform actions when a unit is killed
	/* protected virtual */METHOD(unitDestroyed)
		params [P_THISOBJECT, P_NUMBER("_catID"), P_NUMBER("_subcatID"), P_SIDE("_side"), P_STRING("_faction")];
	ENDMETHOD;

	// Override this to create gameModeData of a location
	/* protected virtual */	METHOD(initLocationGameModeData)
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];
	ENDMETHOD;

	// Game-mode specific functions
	// Must be here for common interface
	// Returns an array of cities where we can recruit from
	/* protected virtual */ METHOD(getRecruitCities)
		params [P_THISOBJECT, P_POSITION("_pos")];
		[]
	ENDMETHOD;

	// Returns how many recruits we can get at a certain place from nearby cities
	/* protected virtual */ METHOD(getRecruitCount)
		params [P_THISOBJECT, P_ARRAY("_cities")];
		0
	ENDMETHOD;

	/* protected virtual */ METHOD(getRecruitmentRadius)
		params [P_THISCLASS];
		0
	ENDMETHOD;

	// Must return a value 0...1 to drive some AICommander logic
	/* protected virtual */ METHOD(getCampaignProgress)
		0.5
	ENDMETHOD;

	// Not all game modes need all commanders
	// By default all commanders are started and perform planning
	// This can be overriden in this method
	/* virtual */ METHOD(startCommanders)
		_this spawn {
			params [P_THISOBJECT];
			// Add some delay so that we don't start processing instantly, because we might want to synchronize intel with players
			UI_SLEEP(10);
			{
				CALLM1(T_GETV(_x), "enablePlanning", true);
				// We postMethodAsync them, because we don't want to start processing right after mission start
				CALLM2(T_GETV(_x), "postMethodAsync", "start", []);
			} forEach ["AICommanderInd", "AICommanderWest", "AICommanderEast"];
		};
	ENDMETHOD;

	// -------------------------------------------------------------------------
	// |                        S E R V E R   O N L Y                          |
	// -------------------------------------------------------------------------
	/* private */ METHOD(initCommanders)
		params [P_THISOBJECT];

		// Independent
		private _cmdr = NEW("Commander", []); // all commanders are equal
		private _args = [_cmdr, INDEPENDENT, gMessageLoopCommanderInd];
		gAICommanderInd = NEW_PUBLIC("AICommander", _args);
		T_SETV("AICommanderInd", gAICommanderInd);
		PUBLIC_VARIABLE "gAICommanderInd";

		// West
		private _cmdr = NEW("Commander", []);
		private _args = [_cmdr, WEST, gMessageLoopCommanderWest];
		gAICommanderWest = NEW_PUBLIC("AICommander", _args);
		T_SETV("AICommanderWest", gAICommanderWest);
		PUBLIC_VARIABLE "gAICommanderWest";

		// East
		private _cmdr = NEW("Commander", []);
		private _args = [_cmdr, EAST, gMessageLoopCommanderEast];
		gAICommanderEast = NEW_PUBLIC("AICommander", _args);
		T_SETV("AICommanderEast", gAICommanderEast);
		PUBLIC_VARIABLE "gAICommanderEast";
	ENDMETHOD;

	METHOD(_saveSpecialGarrisons)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];
		diag_log "Saving special garrisons";
		// Save the loaded data to the garrisons
		T_SETV("savedSpecialGarrisons", gSpecialGarrisons);
		{
			CALLM1(_storage, "save", _x);
		} forEach gSpecialGarrisons;
		diag_log "Special garrisons saved";
	ENDMETHOD;

	METHOD(_loadSpecialGarrisons)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

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

		diag_log "Special garrisons done";
	ENDMETHOD;

	METHOD(_createSpecialGarrisons)
		params [P_THISOBJECT];

		// Garrison objects to track players and player owned vehicles
		gGarrisonPlayersWest 		= NEW("Garrison", [GARRISON_TYPE_AMBIENT ARG WEST]);
		gGarrisonPlayersEast 		= NEW("Garrison", [GARRISON_TYPE_AMBIENT ARG EAST]);
		gGarrisonPlayersInd 		= NEW("Garrison", [GARRISON_TYPE_AMBIENT ARG INDEPENDENT]);
		gGarrisonPlayersCiv 		= NEW("Garrison", [GARRISON_TYPE_AMBIENT ARG CIVILIAN]);
		gGarrisonAmbient 			= NEW("Garrison", [GARRISON_TYPE_AMBIENT ARG CIVILIAN]);
		gGarrisonAbandonedVehicles 	= NEW("Garrison", [GARRISON_TYPE_AMBIENT ARG CIVILIAN]);

		gSpecialGarrisons = [
			gGarrisonPlayersWest,
			gGarrisonPlayersEast,
			gGarrisonPlayersInd,
			gGarrisonPlayersCiv,
			gGarrisonAmbient,
			gGarrisonAbandonedVehicles
		];
	ENDMETHOD;

	STATIC_METHOD(getPlayerGarrisonForSide)
		params [P_THISCLASS, P_SIDE("_side")];
		switch(_side) do {
			case WEST: { gGarrisonPlayersWest };
			case EAST: { gGarrisonPlayersEast };
			case INDEPENDENT: { gGarrisonPlayersInd };
			default { gGarrisonPlayersCiv }; // what?!
		}
	ENDMETHOD;

	fnc_getLocName = {
		params["_name"];
		private _names = "getText( _x >> 'name') == _name" configClasses ( configFile >> "CfgWorlds" >> worldName >> "Names" );
		if(count _names == 0) then { "" } else { configName (_names#0) };
	};

	METHOD(createMissingCityLocations)
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
	ENDMETHOD;
	
	// Create locations
	METHOD(initLocations)
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
			_locSectorPos set [2, 0];	// Nullify Z coordinate

			#ifdef PARTIAL_MAP_POPULATION
			_locSectorPos params ["_posX", "_posY"];
			if (_posX > 6000 && _posY > 8000) then {
			#endif
			FIX_LINE_NUMBERS()
			private _locSectorDir = getDir _locSector;
			private _locName = _locSector getVariable ["Name", ""];
			private _locType = _locSector getVariable ["Type", ""];
			private _locBorder = _locSector getVariable ["objectArea", [50, 50, 0, true]];

			// Create a new location
			private _args = [_locSectorPos, CIVILIAN]; // Location created by noone
			private _loc = NEW_PUBLIC("Location", _args);
			CALLM1(_loc, "setName", _locName);
			CALLM1(_loc, "setType", _locType);
			CALLM1(_loc, "setBorder", _locBorder);
			CALLM0(_loc, "findAllObjects");

			// Create police stations in cities
			if (_locType == LOCATION_TYPE_CITY and (random 10 < 4 or CALLM0(_loc, "getCapacityCiv") >= 25)) then {
				// TODO: Add some visual/designs to this
				private _posPolice = +GETV(_loc, "pos");
				_posPolice = _posPolice vectorAdd [-200 + random 400, -200 + random 400, 0];
				// Find first building which is one of the police building types
				private _possiblePoliceBuildings = (_posPolice nearObjects 200) select { _x isKindOf "House" } select { typeOf _x in location_bt_police };

				if ((count _possiblePoliceBuildings) > 0) then {
					private _policeStationBuilding = selectRandom _possiblePoliceBuildings;
					private _args = [getPos _policeStationBuilding, CIVILIAN]; // Location created by noone
					private _policeStation = NEW_PUBLIC("Location", _args);
					CALLM1(_policeStation, "setBorderCircle", 10);
					CALLM1(_policeStation, "processObjectsInArea", "House"); // We must add buildings to the array
					CALLM0(_policeStation, "addSpawnPosFromBuildings");
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

			#ifdef PARTIAL_MAP_POPULATION
			};
			#endif
			FIX_LINE_NUMBERS()
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
			private _id0 = _roadblockPositionsAroundLocations findIf { !(_x isEqualTo _newPos) && (_x distance2D _newPos < 700)};
			private _id1 = _predefinedRoadblockPositions findIf { !(_x isEqualTo _newPos) && (_x distance2D _newPos < 700) };
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
			private _roads = (_pos nearRoads 300) apply {[_x distance2D _pos, _x]};
			if(count _roads == 0) then {
				diag_log format ["Roadblock at %1 doesn't have nearby roads?!", _pos];
			};
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
			FIX_LINE_NUMBERS()
		} forEach _roadblockPositionsFinal;
	ENDMETHOD;
	
	#define ADD_TRUCKS
	#define ADD_UNARMED_MRAPS
	#define ADD_HELIS
	//#define ADD_ARMED_MRAPS
	//#define ADD_ARMOR
	#define ADD_STATICS
	METHOD(createMilitaryGarrison)
		params [P_THISOBJECT, P_STRING("_locationType"), P_SIDE("_side"), P_NUMBER("_cInf"), P_NUMBER("_cVehGround"), P_NUMBER("_cHMGGMG"), P_NUMBER("_cCargoBoxes"), P_NUMBER("_buildResources")];

		private _faction = "military";
		private _templateName = CALLM2(gGameMode, "getTemplateName", _side, _faction);
		private _template = [_templateName] call t_fnc_getTemplate;

		private _args = [GARRISON_TYPE_GENERAL, _side, [], _faction, _templateName];
		private _gar = NEW("Garrison", _args);

		// Add default units to the garrison

		// Specification for groups to add to the garrison
		private _infSpec = [
			//|Min groups of this type
			//|    |Max groups of this type
			//|    |    |Group template
			//|    |    |                          |Group behaviour
			[ 2,   5,   T_GROUP_inf_rifle_squad,   GROUP_TYPE_INF]
		];
		// Officers at airports and bases only
		if(_locationType == LOCATION_TYPE_AIRPORT) then {
			_infSpec = _infSpec +
				[
					[  2,  2,   T_GROUP_inf_AT_team,       GROUP_TYPE_INF],
					[  2,  2,   T_GROUP_inf_sniper_team,   GROUP_TYPE_INF],
					[  3,  3,   T_GROUP_inf_officer,       GROUP_TYPE_INF],
					[  2,  2,   T_GROUP_inf_recon_squad,   GROUP_TYPE_INF]
				];
		};
		// Officers at airports and bases only
		if(_locationType == LOCATION_TYPE_BASE) then {
			_infSpec = _infSpec +
				[
					[  1,  1,   T_GROUP_inf_AT_team,       GROUP_TYPE_INF],
					[  1,  1,   T_GROUP_inf_sniper_team,   GROUP_TYPE_INF],
					[  1,  1,   T_GROUP_inf_officer,       GROUP_TYPE_INF],
					[  1,  1,   T_GROUP_inf_recon_squad,   GROUP_TYPE_INF]
				];
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
				CALLM3(_gar, "createAddInfGroup", _side, _groupTemplate, _groupBehaviour)
					params ["_newGroup", "_unitCount"];
				OOP_INFO_MSG("%1: Created inf group %2 with %3 units", [_gar ARG _newGroup ARG _unitCount]);
				_cInf = _cInf - _unitCount;
				_i = _i + 1;
			};
		} forEach _infSpec;

		// Add default vehicles
		// Some trucks
		private _i = 0;
		#ifdef ADD_TRUCKS
		while {_cVehGround > 0 && _i < 4} do {
			private _newUnit = NEW("Unit", [_template ARG T_VEH ARG T_VEH_truck_inf ARG -1 ARG ""]);
			if (CALLM0(_newUnit, "isValid")) then {
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
		FIX_LINE_NUMBERS()

		// Unarmed MRAPs
		private _i = 0;
		#ifdef ADD_UNARMED_MRAPS
		while {_cVehGround > 0 && _i < 1} do  {
			private _newUnit = NEW("Unit", [_template ARG T_VEH ARG T_VEH_MRAP_unarmed ARG -1 ARG ""]);
			if (CALLM0(_newUnit, "isValid")) then {
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
		FIX_LINE_NUMBERS()

		// APCs, IFVs, tanks, MRAPs
		#ifdef ADD_ARMOR
		{
			_x params ["_chance", "_min", "_max", "_type"];
			if(random 1 <= _chance) then {
				private _i = 0;
				while{(_cVehGround > 0 or _i < _min) and (_max == -1 or _i < _max)} do {
					private _newGroup = CALLM4(_gar, "createAddVehGroup", _side, T_VEH, _type, -1);
					OOP_INFO_MSG("%1: Created armor group %2", [_gar ARG _newGroup]);
					_cVehGround = _cVehGround - 1;
					_i = _i + 1;
				};
			};
		} forEach _vehGroupSpec;
		#endif
		FIX_LINE_NUMBERS()

		// Static weapons
		if (_cHMGGMG > 0) then {
			// Cap of amount of static guns
			_cHMGGMG = CLAMP(_cHMGGMG, 0, 6);

			private _staticGroup = NEW("Group", [_side ARG GROUP_TYPE_STATIC]);
			private _tGMG = _template # T_VEH # T_VEH_stat_GMG_high;
			if !(isNil "_tGMG") then {
				private _gmgs = 0;
				while {_cHMGGMG > 3 && _gmgs < 2} do {
					private _newUnit = NEW("Unit", [_template ARG T_VEH ARG T_VEH_stat_GMG_high ARG -1 ARG _staticGroup]);
					CALLM(_newUnit, "createDefaultCrew", [_template]);
					_cHMGGMG = _cHMGGMG - 1;
					_gmgs = _gmgs + 1;
				}
			};
			while {_cHMGGMG > 0} do {
				private _newUnit = NEW("Unit", [_template ARG T_VEH ARG T_VEH_stat_HMG_high ARG -1 ARG _staticGroup]);
				CALLM1(_newUnit, "createDefaultCrew", _template);
				_cHMGGMG = _cHMGGMG - 1;
			};
			OOP_INFO_MSG("%1: Added static group %2", [_gar ARG _staticGroup]);
			if(canSuspend) then {
				CALLM2(_gar, "postMethodSync", "addGroup", [_staticGroup]);
			} else {
				CALLM1(_gar, "addGroup", _staticGroup);
			};
		};

		// Cargo boxes
		private _i = 0;
		while {_cCargoBoxes > 0 && _i < 3} do {
			private _newUnit = NEW("Unit", [_template ARG T_CARGO ARG T_CARGO_box_medium ARG -1 ARG ""]);
			CALLM1(_newUnit, "setBuildResources", _buildResources);
			//CALLM1(_newUnit, "limitedArsenalEnable", true); // Make them all limited arsenals
			if (CALLM0(_newUnit, "isValid")) then {
				if(canSuspend) then {
					CALLM2(_gar, "postMethodSync", "addUnit", [_newUnit]);
				} else {
					CALLM1(_gar, "addUnit", _newUnit);
				};
				OOP_INFO_MSG("%1: Added cargo box %2", [_gar ARG _newUnit]);
				_cCargoBoxes = _cCargoBoxes - 1;
			} else {
				DELETE(_newUnit);
			};
			_i = _i + 1;
		};

		_gar
	ENDMETHOD;
	
	#define ADD_HELIS
	#define ADD_PLANES
	METHOD(createAirGarrison)
		params [P_THISOBJECT, P_SIDE("_side"), P_NUMBER("_cVehHeli"), P_NUMBER("_cVehPlane")];

		private _templateName = CALLM2(gGameMode, "getTemplateName", _side, _faction);
		//private _template = [_templateName] call t_fnc_getTemplate;

		private _args = [GARRISON_TYPE_AIR, _side, [], _faction, _templateName];
		private _gar = NEW("Garrison", _args);

		// Helis 
		#ifdef ADD_HELIS
		for "_i" from 0 to _cVehHeli - 1 do {
			private _type = T_VEH_heli_attack; 
			// selectRandomWeighted [
			// 	T_VEH_heli_light,	1,
			// 	T_VEH_heli_heavy,	1,
			// 	T_VEH_heli_attack,	1
			// ];
			private _newGroup = CALLM(_gar, "createAddVehGroup", [_side ARG T_VEH ARG _type ARG -1]);
			OOP_INFO_MSG("%1: Created heli group %2", [_gar ARG _newGroup]);
		};
		#endif
		FIX_LINE_NUMBERS()

		// Planes 
		#ifdef ADD_PLANES
		// TODO
		// for "_i" from 0 to _cVehPlane - 1 do {
		// 	private _type = T_VEH_heli_attack; 
		// 	// selectRandomWeighted [
		// 	// 	T_VEH_heli_light,	1,
		// 	// 	T_VEH_heli_heavy,	1,
		// 	// 	T_VEH_heli_attack,	1
		// 	// ];
		// 	private _newGroup = CALLM(_gar, "createAddVehGroup", [_side ARG T_VEH ARG _type ARG -1]);
		// 	OOP_INFO_MSG("%1: Created heli group %2", [_gar ARG _newGroup]);
		// };
		#endif
		FIX_LINE_NUMBERS()

		_gar
	ENDMETHOD;

	METHOD(createPoliceGarrison)
		params [P_THISOBJECT, P_SIDE("_side"), P_NUMBER("_cInf"), P_NUMBER("_cVehGround"), P_NUMBER("_cCargoBoxes"), P_NUMBER("_buildResources")];
		
		private _faction = "police";
		private _templateName = CALLM2(gGameMode, "getTemplateName", _side, _faction);
		private _template = [_templateName] call t_fnc_getTemplate;

		private _args = [GARRISON_TYPE_GENERAL, _side, [], _faction, _templateName];
		private _gar = NEW("Garrison", _args);

		private _nInfGroups = CLAMP(_cInf * 0.5, 2, 6);
		for "_i" from 1 to _nInfGroups do {
			private _infGroup = NEW("Group", [_side ARG GROUP_TYPE_INF]);
			for "_i" from 0 to 1 do {
				private _variant = selectRandom [T_INF_SL, T_INF_officer, T_INF_officer];
				NEW("Unit", [_template ARG 0 ARG _variant ARG -1 ARG _infGroup]);
			};
			OOP_INFO_MSG("%1: Created police group %2", [_gar ARG _infGroup]);
			if(canSuspend) then {
				CALLM2(_gar, "postMethodSync", "addGroup", [_infGroup]);
			} else {
				CALLM(_gar, "addGroup", [_infGroup]);
			};
		};

		// Patrol vehicles
		for "_i" from 1 to CLAMP(_cVehGround, 2, 6) do {
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
			private _newUnit = NEW("Unit", [_template ARG T_CARGO ARG T_CARGO_box_small ARG -1 ARG ""]);
			CALLM1(_newUnit, "setBuildResources", _buildResources);
			if (CALLM0(_newUnit, "isValid")) then {
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
	ENDMETHOD;

	// Create SideStats
	/* private */ METHOD(initSideStats)
		params [P_THISOBJECT];
		
		private _args = [EAST, 5];
		SideStatWest = NEW("SideStat", _args);
		gSideStatWestHR = CALLM0(SideStatWest, "getHumanResources");
		PUBLIC_VARIABLE "gSideStatWestHR";
	ENDMETHOD;

	// create MissionEventHandlers
	/* private */ METHOD(initMissionEventHandlers)
		params [P_THISOBJECT];
		call compile preprocessFileLineNumbers "Init\initMissionEH.sqf";
	ENDMETHOD;

	// Initialize dynamic simulation
	METHOD(initDynamicSimulation)
		#ifndef _SQF_VM
		params [P_THISOBJECT];

		// Don't remove spawn{}! For some reason without spawning it doesn't apply the values.
		// Probably it's because we currently have this executed inside isNil {} block

		[] spawn {
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
		FIX_LINE_NUMBERS()
	ENDMETHOD;

	// Returns the side of player faction
	/* public virtual */ METHOD(getPlayerSide)
		WEST
	ENDMETHOD;

	/* public virtual */ METHOD(getEnemySide)
		independent
	ENDMETHOD;

	METHOD(doSpawning)
		params [P_THISOBJECT];

		if(T_GETV("lastSpawn") + T_GETV("spawningInterval") > GAME_TIME) exitWith {};
		T_SETV("lastSpawn", GAME_TIME);

		{
			private _loc = _x;
			private _side = GETV(_loc, "side");
			private _template = CALLM2(gGameMode, "getTemplate", _side, "");

			private _targetCInf = CALLM(_loc, "getUnitCapacity", [T_INF ARG [GROUP_TYPE_INF]]);

			private _garrisons = CALLM(_loc, "getGarrisons", [_side]);
			if (count _garrisons == 0) exitWith {};
			private _garrison = _garrisons#0;
			if(not CALLM0(_garrison, "isSpawned")) then {
				private _infCount = count CALLM0(_garrison, "getInfantryUnits");
				if(_infCount < _targetCInf) then {
					private _remaining = _targetCInf - _infCount;
					systemChat format["Spawning %1 units at %2", _remaining, _loc];
					while {_remaining > 0} do {
						CALLM2(_garrison, "postMethodSync", "createAddInfGroup", [_side ARG T_GROUP_inf_sentry ARG GROUP_TYPE_INF])
							params ["_newGroup", "_unitCount"];
						_remaining = _remaining - _unitCount;
					};
				};

				private _cVehGround = CALLM(_loc, "getUnitCapacity", [T_PL_tracked_wheeled ARG GROUP_TYPE_ALL]);
				private _vehCount = count CALLM0(_garrison, "getVehicleUnits");
				
				if(_vehCount < _cVehGround) then {
					systemChat format["Spawning %1 trucks at %2", _cVehGround - _vehCount, _loc];
				};

				while {_vehCount < _cVehGround} do {
					private _newUnit = NEW("Unit", [_template ARG T_VEH ARG T_VEH_truck_inf ARG -1 ARG ""]);
					if (CALLM0(_newUnit, "isValid")) then {
						CALLM2(_garrison, "postMethodSync", "addUnit", [_newUnit]);
						_vehCount = _vehCount + 1;
					} else {
						DELETE(_newUnit);
					};
				};
			};
		} forEach (GET_STATIC_VAR("Location", "all") select { GETV(_x, "type") in [LOCATION_TYPE_BASE] });
	ENDMETHOD;

	// Registers location here
	// All locations must be registered at game mode so that it can save/load them
	METHOD(registerLocation)
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];
		T_GETV("locations") pushBackUnique _loc;
	ENDMETHOD;

	METHOD(getMessageLoop)
		gMessageLoopGameMode;
	ENDMETHOD;

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

	METHOD(savePlayerInfo)
		params [P_THISOBJECT, P_STRING("_uid"), P_OBJECT("_player"), P_STRING("_name")];
		private _playerInfo = T_CALLM4("_savePlayerInfoTo", T_GETV("playerInfoArray"), _uid, _player, _name);
		[_playerInfo, { gPlayerRestoreData = _this }] remoteExecCall ["call", owner _player, NO_JIP];
	ENDMETHOD;

	METHOD(_savePlayerInfoTo)
		params [P_THISOBJECT, P_ARRAY("_array"), P_STRING("_uid"), P_OBJECT("_player"), P_STRING("_name")];
		private _playerInfo = [_uid, _player, _name] call GameMode_fnc_getPlayerInfo;
		private _existing = _array findIf {
			_x#0 isEqualTo _uid
		};
		if(_existing == NOT_FOUND) then {
			_array pushBack _playerInfo;
		} else {
			_array set [_existing, _playerInfo];
		};
		_playerInfo
	ENDMETHOD;

	METHOD(syncPlayerInfo)
		params [P_THISOBJECT, P_OBJECT("_player")];
		private _playerInfoArray = T_GETV("playerInfoArray");
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
		[_playerInfo, { gPlayerRestoreData = _this }] remoteExecCall ["call", owner _player, NO_JIP];
	ENDMETHOD;

	METHOD(clearPlayerInfo)
		params [P_THISOBJECT, P_OBJECT("_player")];
		private _playerInfoArray = T_GETV("playerInfoArray");
		private _uid = getPlayerUID _player;
		private _existing = _playerInfoArray findIf {
			_x#0 isEqualTo _uid
		};
		if(_existing != NOT_FOUND) then {
			_playerInfoArray deleteAt _existing;
		};
		diag_log format["Clearing player info for %1", name _player];
		[[], { gPlayerRestoreData = [] }] remoteExecCall ["call", owner _player, NO_JIP];
	ENDMETHOD;

	METHOD(getPlayerInfo)
		params [P_THISOBJECT, P_OBJECT("_player")];
		private _playerInfoArray = T_GETV("playerInfoArray");
		private _uid = getPlayerUID _player;
		private _existing = _playerInfoArray findIf {
			_x#0 isEqualTo _uid
		};
		if(_existing != NOT_FOUND) then {
			_playerInfoArray#_existing
		} else {
			[]
		}
	ENDMETHOD;

	STATIC_METHOD(startLoadingScreen)
		params [P_THISCLASS, P_STRING("_id"), P_STRING("_message")];

		uiNamespace setVariable ["vin_loadingScreenTitle", _message];
		uiNamespace setVariable ["vin_loadingScreenSubtitle", ''];
		uiNamespace setVariable ["vin_loadingScreenSubprogress", 0];

		["vindicta_" + _id, _message] call BIS_fnc_startLoadingScreen;
		private _display = uiNamespace getVariable ["vin_loadingScreen", displayNull];
		if(!(_display isEqualTo displayNull)) then {
			(_display displayCtrl 666) ctrlSetText _message;
			(_display displayCtrl 666) ctrlCommit 0;
		};

		CALLSM0("GameModeBase", "setLoadingProgress");
	ENDMETHOD;

	STATIC_METHOD(setLoadingProgress)
		params [P_THISCLASS, P_STRING("_message"), P_NUMBER("_amount"), P_NUMBER("_total")];
		PROGRESS_LOADING_SCREEN 0;
		private _subprogress = if(_total == 0) then {
			0
		} else {
			SATURATE(_amount / _total)
		};
		uiNamespace setVariable ["vin_loadingScreenSubtitle", _message];
		uiNamespace setVariable ["vin_loadingScreenSubprogress", _subprogress];
		private _display = uiNamespace getVariable ["vin_loadingScreen", displayNull];
		if(!(_display isEqualTo displayNull)) then {
			(_display displayCtrl 667) ctrlSetText _message;
			(_display displayCtrl 667) ctrlCommit 0;
			(_display displayCtrl 668) progressSetPosition _subprogress;
			(_display displayCtrl 668) ctrlCommit 0;
		};
	ENDMETHOD;

	STATIC_METHOD(endLoadingScreen)
		params [P_THISCLASS, P_STRING("_id")];
		uiNamespace setVariable ["vin_loadingScreenTitle", ''];
		uiNamespace setVariable ["vin_loadingScreenSubtitle", ''];
		uiNamespace setVariable ["vin_loadingScreenSubprogress", 0];
		CALLSM0("GameModeBase", "setLoadingProgress");
		("vindicta_" + _id) call BIS_fnc_endLoadingScreen;
	ENDMETHOD;

	// Suspend the game.
	METHOD(suspend)
		params [P_THISOBJECT, P_STRING("_message"), P_NUMBER_DEFAULT("_timeout", 120)];

		if(!IS_SERVER) exitWith {
			OOP_ERROR_0("suspend should only be called on the server");
		};

		gGameSuspended = gGameSuspended + 1;
		PUBLIC_VARIABLE "gGameSuspended";

		if(gGameSuspended > 1) exitWith {
			// already suspended
			true
		};

		CALLSM2("GameModeBase", "startLoadingScreen", "suspend", _message);

		T_SETV("startSuspendTime", time);
		CALLM0(gTimerServiceMain, "suspend");

		// Freeze the current date while suspended (just spam set it)
		[DATE_NOW] spawn {
			params ["_dateFrozen"];
			while{gGameSuspended > 0} do {
				SET_DATE(_dateFrozen);
				UI_SLEEP(1);
			};
		};

		// Disable all units and vehicles
		// Don't remove spawn{}! For some reason without spawning it doesn't apply the values.
		// Probably it's because we currently have this executed inside isNil {} block
		// Save the script handle for the unsuspend code
		gSuspendUnitsHS = [] spawn {
			ENABLE_DYNAMIC_SIMULATION_SYSTEM(false);
			{
				_x setVariable ["vin_simWasEnabled", SIMULATION_ENABLED(_x)];
				ENABLE_SIMULATION_GLOBAL(_x, false);
			} forEach (allUnits - HUMAN_PLAYERS + ALL_VEHICLES);
		};

		// Flush all message queues, we do this so we make sure all pending spawns/despawns are done before freezing all objects
		private _suspendedCorrectly = T_CALLM1("_flushMessageQueuesNoSuspend", _timeout);

		CHAT_MSG_FMT("Mission suspended: %1", [_message]);

		_suspendedCorrectly
	ENDMETHOD;

	// Resume game after suspend
	METHOD(resume)
		params [P_THISOBJECT];

		if(!IS_SERVER) exitWith {
			OOP_ERROR_0("resume should only be called on the server");
		};

		if(gGameSuspended == 0) exitWith {
			OOP_ERROR_0("resume doesn't match suspend");
		};
		gGameSuspended = gGameSuspended - 1;
		PUBLIC_VARIABLE "gGameSuspended";

		if(gGameSuspended == 0) then {
			// Free all the units we previously froze
			_thisObject spawn {
				private _thisObject = _this;

				// Wait for the suspend command to complate or we might have problems
				waitUntil { isNil "gSuspendUnitsHS" || { isNull gSuspendUnitsHS } || { scriptDone gSuspendUnitsHS } };

				{
					ENABLE_SIMULATION_GLOBAL(_x, true);
				} forEach ((allUnits - HUMAN_PLAYERS + ALL_VEHICLES) select { _x getVariable ["vin_simWasEnabled", false] });

				T_CALLM0("initDynamicSimulation");
			};

			// Offset the game time
			private _timeSuspended = time - T_GETV("startSuspendTime");
			gGameFreezeTime = gGameFreezeTime + _timeSuspended;
			PUBLIC_VARIABLE "gGameFreezeTime";

			CALLM0(gTimerServiceMain, "resume");

			CALLSM1("GameModeBase", "endLoadingScreen", "suspend");

			CHAT_MSG_FMT("Mission resumed after %1 seconds", [_timeSuspended]);
		};
	ENDMETHOD;

	METHOD(flushMessageQueues)
		params [P_THISOBJECT, P_NUMBER_DEFAULT("_timeout", 120)];
		private _success = T_CALLM1("suspend", "Flushing message queues...");
		T_CALLM0("resume");
		_success
	ENDMETHOD;
	
	METHOD(_flushMessageQueuesNoSuspend)
		params [P_THISOBJECT, P_NUMBER_DEFAULT("_timeout", 120)];

		CHAT_MSG("FLUSHING MESSAGE QUEUES");

		private _queuesToFlush = (ALL_MESSAGE_LOOPS - ["messageLoopGameMode"]) apply {
			private _msgLoop = T_GETV(_x);
			[
				_msgLoop, 
				GETV(_msgLoop, "name"),
				CALLM0(_msgLoop, "getLength")
			]
		} select {
			_x#2 > 0
		};

		private _totalMessagesToFlush = 0;
		{
			_totalMessagesToFlush = _totalMessagesToFlush + _x#2;
		} forEach _queuesToFlush;

		private _timeoutEnd = TIME_NOW + _timeout;
		while {count _queuesToFlush > 0 && {TIME_NOW < _timeoutEnd}}  do {
			private _remainingMessagesToFlush = 0;
			{
				_remainingMessagesToFlush = _remainingMessagesToFlush + _x#2;
			} forEach _queuesToFlush;
			private _msg = format ["%1 messages remaining", _remainingMessagesToFlush];
			CALLSM3("GameModeBase", "setLoadingProgress", "", _totalMessagesToFlush - _remainingMessagesToFlush, _totalMessagesToFlush);
			UI_SLEEP(1);
			private _loops = _queuesToFlush apply {
				_x params ["_msgLoop", "_name"];
				[_msgLoop, _name, CALLM0(_msgLoop, "getLength")]
			};
			{
				_x params ["_msgLoop", "_name", "_remaining"];
				CHAT_MSG_FMT("%1 has %2 messages remaining...", [_name ARG _remaining]);
			} forEach _loops;
			_queuesToFlush = _loops select { _x#2 > 0 };
		};

		if(TIME_NOW >= _timeoutEnd) then {
			CHAT_MSG_FMT("WARNING: flushing message queues timed out after %1 seconds!", [_timeout]);
			false
		} else {
			CHAT_MSG("MESSAGE QUEUES FLUSHED");
			true
		};
	ENDMETHOD;

	// -------------------------------------------------------------------------
	// |                             S T O R A G E                             |
	// -------------------------------------------------------------------------

	STATIC_METHOD(getSpawnedPlayers)
		params [P_THISCLASS];
		
		HUMAN_PLAYERS select {
			private _unit = CALLSM1("Unit", "getUnitFromObjectHandle", _x);
			IS_OOP_OBJECT(_unit)
		}
	ENDMETHOD;
	
	/* override */ METHOD(preSerialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		T_CALLM1("suspend", "Saving...");

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

		// Save player info for alive players
		// Copy existing player info (will include unspawned players with restore info)
		private _savedPlayerInfoArray = +T_GETV("playerInfoArray");
		{
			T_CALLM4("_savePlayerInfoTo", _savedPlayerInfoArray, getPlayerUID _x, _x, name _x);
		} forEach CALLSM0("GameModeBase", "getSpawnedPlayers");

		T_SETV("savedPlayerInfoArray", _savedPlayerInfoArray);

		T_CALLM0("flushMessageQueues");

		// Lock all message loops in specific order
		{
			_x params ["_loopName", "_timeout"];
			private _msgLoop = T_GETV(_loopName);
			CHAT_MSG_FMT("Locking thread %1, this could take up to %2 seconds -- be patient", [_loopName ARG _timeout]);
			if(!CALLM1(_msgLoop, "tryLockTimeout", _timeout)) then {
				CHAT_MSG_FMT("Warning: failed to lock message loop %1 in reasonable time, saving anyway.", [_loopName]);
			};
		} forEach ALL_MESSAGE_LOOPS_AND_TIMEOUTS;

		// We use critical sections below to force Arma to concede more
		// CPU time to the save operation as it is very slow.
		// Save message loops
		{
			CRITICAL_SECTION {
				private _msgLoop = T_GETV(_x);
				diag_log format ["Saving thread: %1", _x];
				CALLM1(_storage, "save", _msgLoop);
			};
		} forEach ALL_MESSAGE_LOOPS;

		// Save commanders
		// They will also save their garrisons
		{
			CRITICAL_SECTION {
				private _ai = T_GETV(_x);
				diag_log format ["Saving Commander AI: %1", _x];
				CALLM1(_storage, "save", _ai);
			};
		} forEach ["AICommanderInd", "AICommanderWest", "AICommanderEast"];

		// Save locations
		{
			CRITICAL_SECTION {
				private _loc = _x;
				diag_log format ["Saving location: %1", _loc];
				CALLM1(_storage, "save", _loc);
			};
		} forEach T_GETV("locations");

		T_CALLM1("_saveSpecialGarrisons", _storage);

		// Player custom markers
		private _userDefinedMarkers = allMapMarkers select {
			_x find "_USER_DEFINED" == 0
		} apply {
			[_x] call BIS_fnc_markerToString 
		};
		T_SETV("savedMarkers", _userDefinedMarkers);

		true
	ENDMETHOD;

	/* override */ METHOD(postSerialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		// Call method of all base classes
		CALL_CLASS_METHOD("MessageReceiverEx", _thisObject, "postSerialize", [_storage]);

		// Unlock all message loops
		{
			private _msgLoop = T_GETV(_x);
			diag_log format ["Unlocking message loop: %1", _x];
			CALLM0(_msgLoop, "unlock");
		} forEach ALL_MESSAGE_LOOPS;

		T_CALLM0("resume");

		diag_log format [" - - - - - - - - - - - - - - - - - - - - - - - - - -"];
		diag_log format [" FINISHED SAVING GAME MODE: %1", _thisObject];
		diag_log format [" - - - - - - - - - - - - - - - - - - - - - - - - - -"];

		true
	ENDMETHOD;

	/* override */ METHOD(preDeserialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];

		// Call method of all base classes
		CALL_CLASS_METHOD("MessageReceiverEx", _thisObject, "postDeserialize", [_storage]);

		T_SETV("savedMarkers", []);

		CALLSM2("GameModeBase", "startLoadingScreen", "load", "Loading...");
	ENDMETHOD;

	/* override */ METHOD(postDeserialize)
		params [P_THISOBJECT, P_OOP_OBJECT("_storage")];
		FIX_LINE_NUMBERS()

		diag_log format [" - - - - - - - - - - - - - - - - - - - - - - - - - -"];
		diag_log format [" LOADING GAME MODE: %1", _thisObject];
		diag_log format [" - - - - - - - - - - - - - - - - - - - - - - - - - -"];

		// Call method of all base classes
		CALL_CLASS_METHOD("MessageReceiverEx", _thisObject, "postDeserialize", [_storage]);

		// Set default values if they weren't loaded due to older save version
		private _savedPlayerInfoArray = T_GETV("savedPlayerInfoArray");
		if(isNil "_savedPlayerInfoArray") then {
			T_SETV("playerInfoArray", []);
		} else {
			T_SETV("playerInfoArray", _savedPlayerInfoArray);
		};

		if(isNil{T_GETV("savedSpecialGarrisons")}) then {
			T_SETV("savedSpecialGarrisons", []);
		};
		if(isNil{T_GETV("tNameCivilian")}) then {
			T_SETV("tNameCivilian", "tCivilian");
		};
		T_PUBLIC_VAR("tNameCivilian");

		// Create timer service
		gTimerServiceMain = NEW("TimerService", [TIMER_SERVICE_RESOLUTION]); // timer resolution

		// Restore static variables of classes
		CALLSM1("Garrison", "loadStaticVariables", _storage);
		CALLSM1("Location", "loadStaticVariables", _storage);
		CALLSM1("Unit", "loadStaticVariables", _storage);
		CALLSM1("MessageReceiver", "loadStaticVariables", _storage);

		// Restore some variables
		T_SETV("lastSpawn", GAME_TIME);

		// Load message loops
		{
			CRITICAL_SECTION {
				private _msgLoop = T_GETV(_x);
				diag_log format ["Loading message loop: %1", _x];
				CALLM1(_storage, "load", _msgLoop);
				CALLM0(_msgLoop, "lock"); // We lock the message loops during the game load process
			};
		} forEach ALL_MESSAGE_LOOPS;

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

		// Load locations
		private _toLoad = count T_GETV("locations");
		{
			private _loc = _x;
			OOP_INFO_1("Loading location: %1", _loc);
			private _msg = format ["Loading location %1/%2", _forEachIndex + 1, _toLoad];
			CALLSM3("GameModeBase", "setLoadingProgress", _msg, _forEachIndex, _toLoad);
			CRITICAL_SECTION {
				CALLM1(_storage, "load", _loc);
			};
		} forEach T_GETV("locations");

		// Special garrisons
		T_CALLM1("_loadSpecialGarrisons", _storage);

		// Player custom markers
		{
			_x call BIS_fnc_stringToMarker;
		} forEach T_GETV("savedMarkers");
		T_SETV("savedMarkers", []);

		// Load commanders
		private _toLoad = 3;
		{
			private _ai = T_GETV(_x);
			OOP_INFO_1("Loading Commander AI: %1", _x);
			private _msg = format ["Loading commander %1", _x];
			CALLSM3("GameModeBase", "setLoadingProgress", _msg, _forEachIndex, _toLoad);
			CRITICAL_SECTION {
				CALLM1(_storage, "load", _ai);
			};
		} forEach ["AICommanderInd", "AICommanderWest", "AICommanderEast"];

		// Set global variables
		gAICommanderInd = T_GETV("AICommanderInd");
		PUBLIC_VARIABLE("gAICommanderInd");
		gAICommanderWest = T_GETV("AICommanderWest");
		PUBLIC_VARIABLE("gAICommanderWest");
		gAICommanderEast = T_GETV("AICommanderEast");
		PUBLIC_VARIABLE("gAICommanderEast");

		// Refresh locations
		CALLSM3("GameModeBase", "setLoadingProgress", "Updating locations...", 0, 5);
		CALLSM0("Location", "postLoad");

		// Cleanup dirty garrisons etc.
		CALLSM3("GameModeBase", "setLoadingProgress", "Cleaning broken garrisons...", 2, 5);
		// Cleanup broken garrisons
		private _nonSpecialGarrisons = GETSV("Garrison", "all") - gSpecialGarrisons;
		private _brokenCivilianGarrisons = _nonSpecialGarrisons select {
			// Civilian garrisons should be at a location only, and autoSpawn if they are of certain types
			GETV(_x, "side") == civilian && { GETV(_x, "location") == NULL_OBJECT || { !((GETV(_x, "type") in GARRISON_TYPES_AUTOSPAWN) isEqualTo GETV(_x, "autoSpawn")) } }
		};
		private _brokenMilitaryGarrisons = _nonSpecialGarrisons select {
			// Non civilian garrisons should be at a location or position, and autoSpawn if they are of certain types
			GETV(_x, "side") != civilian && 
			{ GETV(_x, "location") == NULL_OBJECT && CALLM0(_x, "getPos") isEqualTo [0,0,0]
			|| { !((GETV(_x, "type") in GARRISON_TYPES_AUTOSPAWN) isEqualTo GETV(_x, "autoSpawn")) } }
		};

		// Delete the units, the garrisons should get cleaned up automatically
		{
			private _gar = _x;
			{
				DELETE(_x);
			} forEach GETV(_gar, "units");
		} forEach (_brokenCivilianGarrisons + _brokenMilitaryGarrisons);

		private _brokenSpecialGarrisonUnits = gSpecialGarrisons apply {
			GETV(_x, "units") select {
				// groups aren't allowed in special garrisons!
				!IS_NULL_OBJECT(CALLM0(_x, "getGroup")) || 
				// inf isn't allowed in special garrisons (on load, players are in it obviously after load)
				CALLM0(_x, "isInfantry")
			}
		};

		// Delete the units in broken garrisons
		{
			private _units = _x;
			{
				DELETE(_x);
			} forEach _units;
		} forEach _brokenSpecialGarrisonUnits;

		// Delete editor's special objects, after all initialization is complete
		//CALLSM0("Location", "deleteEditorAllowedAreaMarkers");
		// CALLSM0("Location", "deleteEditorObjects");

		CALLSM3("GameModeBase", "setLoadingProgress", "Starting game...", 4, 5);

		// Perform post load init
		T_CALLM0("postLoadServerOnly");

		// Unlock all message loops
		{
			private _msgLoop = T_GETV(_x);
			diag_log format ["Unlocking message loop: %1", _x];
			CALLM0(_msgLoop, "unlock");
		} forEach ALL_MESSAGE_LOOPS;

		// Start commanders
		T_CALLM0("startCommanders");

		// Init dynamic simulation
		T_CALLM0("initDynamicSimulation");

		// Send players their restore points from this save, if they have any
		{
			T_CALLM1("syncPlayerInfo", _x);
		} forEach allPlayers;

		diag_log format [" - - - - - - - - - - - - - - - - - - - - - - - - - -"];
		diag_log format [" FINISHED LOADING GAME MODE: %1", _thisObject];
		diag_log format [" - - - - - - - - - - - - - - - - - - - - - - - - - -"];

		CALLSM1("GameModeBase", "endLoadingScreen", "load");

		true
	ENDMETHOD;

ENDCLASS;

if(IS_SERVER && isNil "gGameSuspended") then {
	gGameSuspended = 0;
	PUBLIC_VARIABLE "gGameSuspended";
};
