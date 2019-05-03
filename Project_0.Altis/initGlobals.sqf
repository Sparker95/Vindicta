#define OOP_INFO
#define OOP_DEBUG
#include "OOP_Light\OOP_Light.h"
#include "Message\Message.hpp"
#include "CriticalSection\CriticalSection.hpp"
#include "AI\Commander\AICommander.hpp"
#include "AI\Commander\LocationData.hpp"

// Global flags
gFlagAllCommanders = true; //false;

// Main timer service
gTimerServiceMain = NEW("TimerService", [0.2]); // timer resolution

// Headless clients and server only
if (
#ifndef _SQF_VM
	isServer || (!hasInterface && !isDedicated)
#else 
	true
#endif
	) then {
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
};

// Server only
#ifndef _SQF_VM

if (isServer) then {

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

	// Create locations and other things
	OOP_INFO_0("Init.sqf: Calling initWorld...");
	call compile preprocessFileLineNumbers "Init\initWorld.sqf";

	// Create SideStats
	private _args = [EAST, 5];
	SideStatWest = NEW("SideStat", _args);
	gSideStatWestHR = CALLM0(SideStatWest, "getHumanResources");
	publicVariable "gSideStatWestHR";

	// create MissionEventHandlers
	call compile preprocessFileLineNumbers "Init\initMissionEH.sqf";

	// Add friendly locations to commanders
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
				// Register at commander
				CALL_STATIC_METHOD("AICommander", "registerGarrison", [_x]);
				_updateLevel = CLD_UPDATE_LEVEL_UNITS; // Know about all units at this place
			};

			if (_loc != "") then {
				CALLM4(_AI, "updateLocationData", _loc, _updateLevel, sideUnknown, false); // false - don't show notification
			};
		} forEach _allGars;

		CALLM1(_x, "setProcessInterval", 10);
		CALLM0(_x, "start");
	} forEach gCommanders;
};

#endif