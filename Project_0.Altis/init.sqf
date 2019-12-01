#define OOP_INFO
#define OOP_DEBUG
#include "OOP_Light\OOP_Light.h"

// No saving
enableSaving [ false, false ]; // Saving disabled without autosave.

if (!CALLM0(gGameManager, "isGameModeInitialized")) exitWith {
	0 spawn {
		waitUntil {!isNull (findDisplay 46)};
    	CALLSM1("NotificationFactory", "createSystem", "Press [U] to setup the mission or load a saved game");
	};
};

if (true) exitWith {}; // Bail to avoid legacy code


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


// Disables initialization of game mode
// Used for testing of saving/loading features
#define GAME_MODE_NOINIT

// Disables the main sequence initialization completely
// Use it in case we want to not start the actual mission but to test some other code
//#define DISABLE_MISSION_INIT 


// If a client, wait for the server to finish its initialization
if (!IS_SERVER) then {
	private _str = format ["Waiting for server init, time: %1", diag_tickTime];
	systemChat _str;
	OOP_INFO_0(_str);

	waitUntil {! isNil "serverInitDone"};

	_str = format ["Server initialization completed at time: %1", diag_tickTime];
	systemChat _str;
	OOP_INFO_0(_str);
};

#ifdef DISABLE_MISSION_INIT
if(true) exitWith { 
	0 spawn {
		0 spawn {
			waitUntil {!(isNull (finddisplay 12)) && !(isNull (findDisplay 46))};
			gPlayerDatabaseClient = NEW("PlayerDatabaseClient", []);
			call compile preprocessfilelinenumbers "UI\initPlayerUI.sqf";
		};
		_i = 0;
		while {_i < 4} do { systemChat "!!! GAME MODE INIT WAS DISABLED !!! Check init.sqf"; sleep 4; _i = _i + 1; };
	};
};
#endif

if(IS_SERVER) then {
	gGameModeName = switch (PROFILE_NAME) do {
		case "Sparker": 	{ "CivilWarGameMode" };  // "RedVsGreenGameMode" }; //"CivilWarGameMode" }; // "EmptyGameMode"
		//case "Sparker": 	{ "EmptyGameMode" };
		case "billw": 		{ "CivilWarGameMode" };
		case "Jeroen not": 	{ "EmptyGameMode" };
		case "Marvis": 	{ "EmptyGameMode" };
		default 		{ "CivilWarGameMode" };
	};
	PUBLIC_VARIABLE "gGameModeName";
} else {
	waitUntil { !isNil "gGameModeName" };
};

CRITICAL_SECTION {
	#ifndef GAME_MODE_NOINIT
		gGameMode = NEW(gGameModeName, []);

		systemChat format["Initializing game mode %1", GETV(gGameMode, "name")];
		CALLM(gGameMode, "init", []);
		systemChat format["Initialized game mode %1", GETV(gGameMode, "name")];

		// If we're a server, broadcast to everyone that initialization has been completed, so that clients can initialize as well
		if (IS_SERVER) then {
			serverInitDone = 1;
			PUBLIC_VARIABLE "serverInitDone";
		} else {
			
		};
	#endif

	// Notify server that we have initialized everything and our systems are ready to interact with server
	if (HAS_INTERFACE) then {
		0 spawn {
			waitUntil {count (getPlayerUID player) > 1}; // Sometimes it might be ""
			private _uid = profileNamespace getVariable ["p0_uid", getPlayerUID player]; // Alternative UID for testing purposes
			[_uid, profileName, clientOwner, playerSide] remoteExecCall ["fnc_onPlayerInitializedServer", 2];
		};
	};
};
