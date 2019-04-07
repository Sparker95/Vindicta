#define OOP_INFO
#define OOP_DEBUG
#include "OOP_Light\OOP_Light.h"
#include "Message\Message.hpp"
#include "CriticalSection\CriticalSection.hpp"
#include "AI\Commander\AICommander.hpp"
#include "AI\Commander\LocationData.hpp"

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

#ifndef _SQF_VM
	// Create a timer for gLUAP
	private _msg = MESSAGE_NEW();
	_msg set [MESSAGE_ID_DESTINATION, gLUAP];
	_msg set [MESSAGE_ID_SOURCE, ""];
	_msg set [MESSAGE_ID_DATA, 666];
	_msg set [MESSAGE_ID_TYPE, 666];
	private _args = [gLUAP, 2, _msg, gTimerServiceMain]; // message receiver, interval, message, timer service
	private _LUAPTimer = NEW("Timer", _args);
#endif
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

	// Message loops for commander AI
	gMessageLoopCommanderWest = NEW("MessageLoop", []);
	gMessageLoopCommanderInd = NEW("MessageLoop", []);
	gMessageLoopCommanderEast = NEW("MessageLoop", []);

	// Commander AIs
	// West
	gCommanderWest = NEW("Commander", []);
	private _args = [gCommanderWest, WEST, gMessageLoopCommanderWest];
	gAICommanderWest = NEW_PUBLIC("AICommander", _args);
	publicVariable "gAICommanderWest";
	// Independent
	gCommanderInd = NEW("Commander", []);
	private _args = [gCommanderInd, INDEPENDENT, gMessageLoopCommanderInd];
	gAICommanderInd = NEW_PUBLIC("AICommander", _args);
	publicVariable "gAICommanderInd";
	// East
	gCommanderEast = NEW("Commander", []);
	private _args = [gCommanderEast, EAST, gMessageLoopCommanderEast];
	gAICommanderEast = NEW_PUBLIC("AICommander", _args);
	publicVariable "gAICommanderEast";


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
	private _allLocs = CALLSM0("Location", "getAll");
	{
		private _AI = _x;
		private _side = GETV(_x, "side");
		{
			private _loc = _x;
			private _locSide = CALLM0(_loc, "getSide");
			private _updateLevel = if (_locSide == _side || _locSide == CIVILIAN) then {
				CLD_UPDATE_LEVEL_UNITS // Know about all units at this place
			} else {
				CLD_UPDATE_LEVEL_TYPE_UNKNOWN // Only know that there's something unexplored over here
			};
			CALLM2(_AI, "updateLocationData", _loc, _updateLevel);
			
			private _gar = CALLM0(_loc, "getGarrisonMilitaryMain");
			if (_gar != "") then { // Just to be even more safe
				CALLM1(_AI, "registerGarrison", _gar);
			};
		} forEach _allLocs;

		//CALLM0(_x, "updateFriendlyLocationsData");
		
		CALLM1(_x, "setProcessInterval", 10);
		CALLM0(_x, "start");
	} forEach [gAICommanderWest, gAICommanderInd, gAICommanderEast];
};

#endif