
#include "common.hpp"

CLASS("GameModeBase", "")
	VARIABLE("name");

	METHOD("new") {
		params [P_THISOBJECT];
		T_SETV("name", "unnamed");

	} ENDMETHOD;

	METHOD("delete") {
		params [P_THISOBJECT];

	} ENDMETHOD;

	METHOD("init") {
		params [P_THISOBJECT];
		
		// Global flags
		gFlagAllCommanders = true; //false;
		// Main timer service
		gTimerServiceMain = NEW("TimerService", [0.2]); // timer resolution

		T_CALLM("preInitAll", []);

		if(isServer || IS_HEADLESSCLIENT) then {
			// Main message loop for garrisons
			gMessageLoopMain = NEW("MessageLoop", []);
			CALL_METHOD(gMessageLoopMain, "setDebugName", ["Main thread"]);

			// Global debug printer for tests
			private _args = ["TestDebugPrinter", gMessageLoopMain];
			gDebugPrinter = NEW("DebugPrinter", _args);

			// Message loop for group AI
			gMessageLoopGroupAI = NEW("MessageLoop", []);
			CALL_METHOD(gMessageLoopGroupAI, "setDebugName", ["Group AI thread"]);

			// Message loop for Stimulus Manager
			gMessageLoopStimulusManager = NEW("MessageLoop", []);
			CALL_METHOD(gMessageLoopStimulusManager, "setDebugName", ["Stimulus Manager thread"]);

			// Global Stimulus Manager
			gStimulusManager = NEW("StimulusManager", []);

			// Message loop for locations
			gMessageLoopLocation = NEW("MessageLoop", []);
			CALL_METHOD(gMessageLoopLocation, "setDebugName", ["Location thread"]);

			// Location unit array provider
			gLUAP = NEW("LocationUnitArrayProvider", []);

			T_CALLM("initServerOrHC", []);
		};
		if(isServer) then {
			T_CALLM("initCommanders", []);
			T_CALLM("initWorld", []);
			T_CALLM("initSideStats", []);
			T_CALLM("initMissionEventHandlers", []);
			T_CALLM("registerKnownLocations", []);

			T_CALLM("initServerOnly", []);
		};
		if (hasInterface || IS_HEADLESSCLIENT) then {
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
		if(hasInterface) then {
			diag_log "----- Player detected!";
			0 spawn {
				waitUntil {!((finddisplay 12) isEqualTo displayNull)};
				call compile preprocessfilelinenumbers "UI\initPlayerUI.sqf";
			};

			T_CALLM("initClientOnly", []);
		};
		T_CALLM("postInitAll", []);
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

	/* protected virtual */ METHOD("getLocationInitialForces") {
		params [P_THISOBJECT, P_OOP_OBJECT("_loc")];
		[0,0,0,0]
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

		gSpecialGarrisons = [gGarrisonPlayersWest, gGarrisonPlayersEast, gGarrisonPlayersInd, gGarrisonPlayersCiv, gGarrisonAmbient];

		// Message loops for commander AI
		gMessageLoopCommanderInd = NEW("MessageLoop", []);

		// Commander AIs
		gCommanders = [];

		// Independent
		gCommanderInd = NEW("Commander", []); // all commanders are equal
		private _args = [gCommanderInd, INDEPENDENT, gMessageLoopCommanderInd];
		gAICommanderInd = NEW_PUBLIC("AICommander", _args);
		publicVariable "gAICommanderInd";
		gCommanders pushBack gAICommanderInd;

		if(gFlagAllCommanders) then { // but some are more equal

			gMessageLoopCommanderWest = NEW("MessageLoop", []);
			gMessageLoopCommanderEast = NEW("MessageLoop", []);

			// West
			gCommanderWest = NEW("Commander", []);
			private _args = [gCommanderWest, WEST, gMessageLoopCommanderWest];
			gAICommanderWest = NEW_PUBLIC("AICommander", _args);
			publicVariable "gAICommanderWest";
			gCommanders pushBack gAICommanderWest;

			// East
			gCommanderEast = NEW("Commander", []);
			private _args = [gCommanderEast, EAST, gMessageLoopCommanderEast];
			gAICommanderEast = NEW_PUBLIC("AICommander", _args);
			publicVariable "gAICommanderEast";
			gCommanders pushBack gAICommanderEast;
		};
	} ENDMETHOD;

	// Create locations
	/* private */ METHOD_FILE("initLocations", "GameMode\initLocations.sqf");

	// Create SideStats
	/* private */ METHOD("initSideStats") {
		params [P_THISOBJECT];
		
		private _args = [EAST, 5];
		SideStatWest = NEW("SideStat", _args);
		gSideStatWestHR = CALLM0(SideStatWest, "getHumanResources");
		publicVariable "gSideStatWestHR";
	} ENDMETHOD;

	// create MissionEventHandlers
	/* private */ METHOD("initMissionEventHandlers") {
		params [P_THISOBJECT];
		call compile preprocessFileLineNumbers "Init\initMissionEH.sqf";
	} ENDMETHOD;

	// Add friendly locations to commanders
	/* private */ METHOD("registerKnownLocations") {
		params [P_THISOBJECT];
		// Register garrisons of friendly locations
		// And start them
		private _allGars = CALLSM0("Garrison", "getAll") - gSpecialGarrisons;
		{
			private _AI = _x;
			private _side = GETV(_x, "side");
			{
				private _loc = CALLM0(_x, "getLocation");
				
				private _updateLevel = CLD_UPDATE_LEVEL_TYPE_UNKNOWN; // Only know that there's something unexplored over here
				if (CALLM0(_x, "getSide") == _side) then { // If this garrison should belong to this commander	
					// Activate the Garrison
					CALLM(_x, "activate", []);
					_updateLevel = CLD_UPDATE_LEVEL_UNITS; // Know about all units at this place
				};

				if (_loc != "") then {
					CALLM4(_AI, "updateLocationData", _loc, _updateLevel, sideUnknown, false); // false - don't show notification
				};
			} forEach _allGars;

			CALLM1(_x, "setProcessInterval", 10);
			CALLM0(_x, "start");
		} forEach gCommanders;
	} ENDMETHOD;

	/* private */ METHOD("fn") {
		params [P_THISOBJECT];

	} ENDMETHOD;
ENDCLASS;