/*
Dirty init.sqf
add inits here until it's so fucked up, then redo it all over again
*/

//==== Locations initialization
//player allowDamage false;
/*

// Old init code
call compile preprocessFileLineNumbers "initModules.sqf";
if(isServer) then
{
	allLocations = call compile preprocessFileLineNumbers "Init\createAllLocations.sqf";
	[allLocations] call compile preprocessFileLineNumbers "Init\initAllGarrisons.sqf";
	
	//Init some HQ modules
	call (compile (preprocessFileLineNumbers "Init\initHQ.sqf"));

	HCGarrisonWEST = [] call gar_fnc_createGarrison;
	[HCGarrisonWEST, "HC WEST"] call gar_fnc_setName;
	[HCGarrisonWEST, WEST] call gar_fnc_setSide;
	//[HCGarrisonWEST, G_AS_none] call gar_fnc_setAlertState;
	[HCGarrisonWEST] call gar_fnc_spawnGarrison;

	HCGarrisonEAST = [] call gar_fnc_createGarrison;
	[HCGarrisonEAST, "HC EAST"] call gar_fnc_setName;
	[HCGarrisonEAST, EAST] call gar_fnc_setSide;
	//[HCGarrisonEAST, G_AS_none] call gar_fnc_setAlertState;
	[HCGarrisonEAST] call gar_fnc_spawnGarrison;

	//Global garrison for garbage collection
	gGarbageGarrison = [] call gar_fnc_createGarrison;
	[gGarbageGarrison, "Garbage"] call gar_fnc_setName;
	[gGarbageGarrison, WEST] call gar_fnc_setSide;
	[gGarbageGarrison] call gar_fnc_spawnGarrison;

	publicVariable "allLocations";
};


//Commander's map
UI_fnc_onMapSingleClick =
compile preprocessfilelinenumbers "UI\onMapSingleClick.sqf";
onMapSingleClick {call UI_fnc_onMapSingleClick;};
*/

#include "OOP_Light\OOP_Light.h"
#include "Message\Message.hpp"

diag_log "Init.sqf: Calling initModules...";

call compile preprocessFileLineNumbers "initModules.sqf";

diag_log "Init.sqf: Creating global objects...";

// Init global objects
// Main timer service
gTimerServiceMain = NEW("TimerService", [0.2]); // timer resolution

// Main message loop for garrisons
gMessageLoopMain = NEW("MessageLoop", []);
CALL_METHOD(gMessageLoopMain, "setDebugName", ["Main thread"]);

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

// Global debug printer for tests
private _args = ["TestDebugPrinter", gMessageLoopMain];
gDebugPrinter = NEW("DebugPrinter", _args);

// Location unit array provider
if (isServer) then {
	gLUAP = NEW("LocationUnitArrayProvider", []);
	// Create a timer for gLUAP
	private _msg = MESSAGE_NEW();
	_msg set [MESSAGE_ID_DESTINATION, gLUAP];
	_msg set [MESSAGE_ID_SOURCE, ""];
	_msg set [MESSAGE_ID_DATA, 666];
	_msg set [MESSAGE_ID_TYPE, 666];
	private _args = [gLUAP, 2, _msg, gTimerServiceMain]; // message receiver, interval, message, timer service
	private _LUAPTimer = NEW("Timer", _args);
	
	diag_log "Init.sqf: Calling initWorld...";

	call compile preprocessFileLineNumbers "Init\initWorld.sqf";
};

// Headless Clients only
if (!hasInterface && !isDedicated) then {
	private _str = format ["Mission: I am a headless client! My player object is: %1. I have just connected! My owner ID is: %2", player, clientOwner];
	diag_log _str;
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
};

// Only players
if (hasInterface) then {
	[] spawn {
		waitUntil {!((finddisplay 12) isEqualTo displayNull)};
		[] spawn compile preprocessfilelinenumbers "onPlayerSpawn.sqf";
	};
};

diag_log "Init.sqf: Init done!";