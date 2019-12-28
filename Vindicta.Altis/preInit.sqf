#include "OOP_Light\OOP_Light.h"

/*
This file is called in preinit through cfgFunctions
preInit is executed before JIP functions and before init.sqf.
*/

// Initialize classes and other things
call compile preprocessFileLineNumbers "initModules.sqf";

if (IS_SERVER) then {
	gGameManagerServer = NEW_PUBLIC("GameManager", []);
	gGameManager = gGameManagerServer;
	publicVariable "gGameManagerServer";			// Public object at the server, clients can send data to gGameManager
} else {
	gGameManagerClient = NEW("GameManager", []);	// Local object for clients
	gGameManager = gGameManagerClient;

	// Must be called once player's game mode is initialized
	/*
	0 spawn {
		waitUntil {count (getPlayerUID player) > 1}; // Sometimes it might be ""
		private _uid = profileNamespace getVariable ["p0_uid", getPlayerUID player]; // Alternative UID for testing purposes
		[_uid, profileName, clientOwner, playerSide] remoteExecCall ["fnc_onPlayerInitializedServer", 2];
	};
	*/
};

CALLM0(gGameManager, "init");