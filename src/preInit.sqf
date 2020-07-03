#include "common.h"

/*
This file is called in preinit through cfgFunctions
preInit is executed before JIP functions and before init.sqf.
*/


// Log some stuff

// We need these functions right now, before anything else
misc_fnc_getVersion = COMPILE_COMMON("Misc\fn_getVersion.sqf");
misc_fnc_getSaveVersion = COMPILE_COMMON("Misc\fn_getSaveVersion.sqf");
misc_fnc_getSaveBreakVersion = COMPILE_COMMON("Misc\fn_getSaveBreakVersion.sqf");

private _lines = [
"",
"",
"",
"MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM",
"MM   MBILLWM    M    MM  MMMMMMMM    MM            MMMM    MMM$        ,MMM             MMMM  MMMMMMMM",
"MM    MMMMM    MM    MM   MMMMMMM    MM             MMM    MM            MM             MMMM  MMMMMMMM",
"MM    MMMMM    MM    MM    OMMMMM    MM    MMMMM     MM    M,    MMMMM    MMMMM    MMMMMMMM    MMSENMM",
"MMM    MMM    MMM    MM      NMMM    MM    MMMMMM    OM    M    MMMMMMMMMMMMMMM    MARVISMM    MMMMMMM",
"MMM,    M    ,MMM    MM       MMM    MM    MMMMMMM    M    M   =MMMMMMMMMMMMMMM    MMMMMMM      MMMMMM",
"MMMM    M    MMMM    MM        =M    MM    MMMMMMM    M    ,   +MMMSPARKERMMMMM    MMMMMM        MMMMM",
"MMMM        MMMMM    MM    Z         MM    MMMMMMM    M    ,   +MMMMMMMMMMMMMMM    MMMMMM   A    MMMMM",
"MMMMM       MMMMM    MM    MM        MM    MMMMMMM    M    ,   +MMSEBASTIANMMMM    MMMMM    MM    MMMM",
"MMMMMM     MMMMMM    MM    MMM       MM    MMMMMMM    M    M   +MMMMMMMMMMMMMMM    MMMM    MMMM    MMM",
"MMMMMM     MMMMMM    MM    MMMMD     MM    MMMMMM    OM    M    MMJEROENMMMMMMM    MMMM    MMMM    MMM",
"MMMMMMM   MMMMMMM    MM    MMMMMM    MM    MMMMM     MM    M     MMMM:    MMMMM    MMM    MMMMMN    MM",
"MMMMMMM   MBILLWM    MM    MMMMMMM   MM             MMM    MM            NMMMMM    MM8    MMMMMM    MM",
"MMMMMMMM MMMMMMMM    MM    MMMMMMMMM MM            MMMM    MMMZ        ,MMMMMMM    MM    MMMMMMMM    M",
"MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNMMMMMMMMMMMMMM",
"",
"",
""
];

{diag_log _x} forEach _lines;

// Log some useful stuff
diag_log "";
diag_log "";
diag_log "";
diag_log format ["VINDICTA PREINIT SQF"];
diag_log format ["VERSION:              %1", call misc_fnc_getVersion];
diag_log format ["SAVE VERSION:         %1", call misc_fnc_getSaveVersion];
diag_log format ["SAVE BREAK VERSION:   %1", call misc_fnc_getSaveBreakVersion];
diag_log format ["IS SERVER:            %1", isServer];
diag_log format ["IS MULTIPLAYER:       %1", isMultiplayer];
diag_log format ["HAS INTERFACE:        %1", hasInterface];
diag_log format ["WORLD NAME:           %1", worldName];
diag_log format ["PROFILE NAME:         %1", profileName];
//diag_log format ["UID:            %1", getPlayerUID player]; // Returns empty string anyway
diag_log "";
diag_log "";
diag_log "";

// Initialize classes and other things
CALL_COMPILE_COMMON("initModules.sqf");

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

CALLM0(gGameManager, "preInit");