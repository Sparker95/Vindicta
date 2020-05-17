#include "..\common.h"

#ifndef _SQF_VM

#define DIK_DELETE 0xD3

g_debug_menu = [
	["Debug Menu", "Debug Menu", "popup"],
	[]
];
pr0_fnc_debug_menu = { g_debug_menu };

pr0_fnc_addDebugMenuItem = {
	params ["_menu", "_text", "_code"];
	// private _idx = g_debug_menu findIf { _x#0 isEqualTo _menu };
	// if(_idx == -1) then {
	// 	g_debug_menu pushBack [_menu, _menu, "popup"];
	// 	g_debug_menu pushBack [];
	// 	_idx = count g_debug_menu - 2;
	// };
	// g_debug_menu#(_idx+1) pushBack [_text, _code, "", "", [], -1, true, true ];
	g_debug_menu#1 pushBack [
		format["%1>%2", _menu, _text],
		_code, "", "", [], -1, true, true 
	];
};

pr0_fnc_initDebugMenu = {
	// [
	// 	"Vindicta",
	// 	"Open Menu",
	// 	["player", [], -100, "_this call pr0_fnc_debug_menu"],
	// 	[DIK_6, false, false, false]
	// ] call CBA_fnc_registerKeybindToFleximenu;
	[
		"Vindicta",
		"Open_Menu",
		"Open Menu",
		["player", [], -100, "_this call pr0_fnc_debug_menu"],
		[DIK_DELETE, false, true, false]
	] call CBA_fnc_addKeybindToFleximenu
};

["Player", "Kill self", {
	player setDamage 1;
	systemChat "I KILL U!";
}] call pr0_fnc_addDebugMenuItem;

["Player", "Toggle god mode", {
	if(isDamageAllowed player) then {
		player allowDamage false;
		player enableFatigue false;
		systemChat "GOD MODE ENABLED!";
	} else {
		player allowDamage false;
		player enableFatigue false;
		systemChat "GOD MODE DISABLED!";
	};
}] call pr0_fnc_addDebugMenuItem;

["Player", "Open Infinite Arsenal", {
	["Open", true] call bis_fnc_arsenal;
}] call pr0_fnc_addDebugMenuItem;

// if(isServer) then {
// 	gLocationMarkersOn = true;
// 	gGarrisonMarkersOn = true;
// };

// pr0_fnc_toggleMarkers = {
// 	params ["_state", "_prefix"];
// 	{
// 		if(_state) then {
// 			_x setMarkerAlpha 1;
// 		} else {
// 			_x setMarkerAlpha 0;
// 		};
// 	} foreach ( allMapMarkers select { _x find _prefix == 0 } ) ;
// };

// ["Map", "Toggle location markers", {
// 	[[], { gLocationMarkersOn = !gLocationMarkersOn; [gLocationMarkersOn, "o_Location_N"] call pr0_fnc_toggleMarkers; } ] remoteExec ["call", 2];
// }] call pr0_fnc_addDebugMenuItem;
// ["Map", "Toggle garrison markers", {
// 	[[], { gGarrisonMarkersOn = !gGarrisonMarkersOn; [gGarrisonMarkersOn, "o_AIGarrison_N"] call pr0_fnc_toggleMarkers; } ] remoteExec ["call", 2];
// }] call pr0_fnc_addDebugMenuItem;
// ["Map", "Dump garrison from map", {
// 	onMapSingleClick  {
// 		[[_pos], {	 
// 			{

// 			} forEach
// 		} ] remoteExec ["call", 2];

// 		onMapSingleClick "";
// 	};
// 	openMap true;

	
// }] call pr0_fnc_addDebugMenuItem;

// ["Dump", "All garrisons", {
// 	[[], {
// 		// {
// 		// 	_x call OOP_dumpAsJson;
// 		// } forEach CALLSM0("Garrison", "getAllNotEmpty");
// 		CALLSM0("Garrison", "getAllNotEmpty") call OOP_dumpAsJson;
// 	} ] remoteExec ["call", 2];
// }] call pr0_fnc_addDebugMenuItem;

// ["Dump", "All locations", {
// 	[[], {
// 		// {
// 		// 	_x call OOP_dumpAsJson;
// 		// } forEach CALLSM0("Location", "getAll");
// 		CALLSM0("Location", "getAll") call OOP_dumpAsJson;
// 	} ] remoteExec ["call", 2];
// }] call pr0_fnc_addDebugMenuItem;

["Add", "New group", {
	private _AI = CALLSM1("AICommander", "getAICommander", playerSide);
	CALLM2(_AI, "postMethodAsync", "debugCreateGarrison", [getpos player]);
}] call pr0_fnc_addDebugMenuItem;

["Add", "New group in location", {
	private _loc = CALLSM1("Location", "getLocationAtPos", getpos player);
	if (!IS_NULL_OBJECT(_loc)) then {
		private _AI = CALLSM1("AICommander", "getAICommander", playerSide);
		CALLM2(_AI, "postMethodAsync", "debugAddGroupToLocation", [_loc]);
	};
}] call pr0_fnc_addDebugMenuItem;

["Construction", "+25% construction", {
	private _loc = CALLSM1("Location", "getLocationAtPos", getpos player);
	if (!IS_NULL_OBJECT(_loc)) then {
		CALLM2(_loc, "postMethodAsync", "debugAddBuildProgress", [0.25]);
	};
}] call pr0_fnc_addDebugMenuItem;

["Construction", "-25% construction", {
	private _loc = CALLSM1("Location", "getLocationAtPos", getpos player);
	if (!IS_NULL_OBJECT(_loc)) then {
		CALLM2(_loc, "postMethodAsync", "debugAddBuildProgress", [-0.25]);
	};
}] call pr0_fnc_addDebugMenuItem;

["Add", "Kill all enemy nearby", {
	private _nearbyEnemy = player nearEntities ["Man", 100] select { side _x isEqualTo CALLM0(gGameMode, "getEnemySide") };
	{
		_x setDamage 1;
	} forEach _nearbyEnemy;
}] call pr0_fnc_addDebugMenuItem;

["Commander", "Enable Radio Intel Interception Cheat", {
	[[], {
		// {
		// 	_x call OOP_dumpAsJson;
		// } forEach CALLSM0("Location", "getAll");
		systemChat "Radio intel will be always intercepted now, regardless of cryptokeys or actual owned antennas.";
		{
			if (!isNil "_x") then {
				SETV(_x, "cheatIntelInterception", true);
			};
		} forEach [gAICommanderEast, gAICommanderInd, gAICommanderWest];
	} ] remoteExec ["call", 2];
}] call pr0_fnc_addDebugMenuItem;

["Location", "Add 20 recruits to city", {
	private _pos = getPos player;
	[[_pos], {
		params ["_pos"];

		// get location at player position
		
		private _loc = CALL_STATIC_METHOD("Location", "getLocationAtPos", [_pos]); // It will return the lowermost location, so if it's a police station in a city, it will return police station, not a city.
		
		if (_loc != "") then { 	

				private _recruits = 20;
				private _gmdata = GETV(_loc, "gameModeData");
				CALLM2(_gmdata, "addRecruits", _loc, _recruits);
				systemChat "Added 20 recruits to current location.";

		} else {
			systemChat "Invalid location.";
		};

	} ] remoteExec ["call", 2];
}] call pr0_fnc_addDebugMenuItem;

["BuildUI", "100 ConRes > cursorObject", {

		private _cursorObj = cursorObject;

		if !(isNil "_cursorObj") then {

			_cursorObj addMagazineCargoGlobal ["vin_build_res_0", 100];
			systemChat "Added 100 construction resource to cursorObject.";

		} else {
			systemChat "Not looking at an object.";
		};
		
}] call pr0_fnc_addDebugMenuItem;

["Undercover", "Toggle captive", {

		private _thisObject = player getVariable ["undercoverMonitor", ""];
		if (_thisObject != "") then {
			if (T_GETV("debugOverride")) then {
				T_SETV("debugOverride", false);
			} else {
				T_SETV("debugOverride", true);
			};
		};
		
}] call pr0_fnc_addDebugMenuItem;

// shows unit and group actions and goals in an overlay text
["AI", "Toggle draw3D goals", {

	call compile preprocessFileLineNumbers "DebugMenu\fn_draw3dUnitDetails.sqf";
		
}] call pr0_fnc_addDebugMenuItem;

#else

pr0_fnc_addDebugMenuItem = {};
pr0_fnc_initDebugMenu = {};

#endif