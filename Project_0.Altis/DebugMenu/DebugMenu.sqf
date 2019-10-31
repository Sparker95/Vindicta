#include "..\OOP_Light\OOP_Light.h"

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
	// 	"Project 0",
	// 	"Open Menu",
	// 	["player", [], -100, "_this call pr0_fnc_debug_menu"],
	// 	[DIK_6, false, false, false]
	// ] call CBA_fnc_registerKeybindToFleximenu;
	[
		"Project 0",
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

if(isServer) then {
	gLocationMarkersOn = true;
	gGarrisonMarkersOn = true;
};

pr0_fnc_toggleMarkers = {
	params ["_state", "_prefix"];
	{
		if(_state) then {
			_x setMarkerAlpha 1;
		} else {
			_x setMarkerAlpha 0;
		};
	} foreach ( allMapMarkers select { _x find _prefix == 0 } ) ;
};

["Map", "Toggle location markers", {
	[[], { gLocationMarkersOn = !gLocationMarkersOn; [gLocationMarkersOn, "o_Location_N"] call pr0_fnc_toggleMarkers; } ] remoteExec ["call", 2];
}] call pr0_fnc_addDebugMenuItem;
["Map", "Toggle garrison markers", {
	[[], { gGarrisonMarkersOn = !gGarrisonMarkersOn; [gGarrisonMarkersOn, "o_AIGarrison_N"] call pr0_fnc_toggleMarkers; } ] remoteExec ["call", 2];
}] call pr0_fnc_addDebugMenuItem;
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

["Dump", "All garrisons", {
	[[], {
		// {
		// 	_x call OOP_dumpAsJson;
		// } forEach CALLSM0("Garrison", "getAllNotEmpty");
		CALLSM0("Garrison", "getAllNotEmpty") call OOP_dumpAsJson;
	} ] remoteExec ["call", 2];
}] call pr0_fnc_addDebugMenuItem;

["Dump", "All locations", {
	[[], {
		// {
		// 	_x call OOP_dumpAsJson;
		// } forEach CALLSM0("Location", "getAll");
		CALLSM0("Location", "getAll") call OOP_dumpAsJson;
	} ] remoteExec ["call", 2];
}] call pr0_fnc_addDebugMenuItem;

["Dump", "All locations", {
	[[], {
		// {
		// 	_x call OOP_dumpAsJson;
		// } forEach CALLSM0("Location", "getAll");
		CALLSM0("Location", "getAll") call OOP_dumpAsJson;
	} ] remoteExec ["call", 2];
}] call pr0_fnc_addDebugMenuItem;

["Add", "Add friendly inf to this location", {
	private _loc = CALLSM1("Location", "getLocationAtPos", getpos player);
	if (!IS_NULL_OBJECT(_loc)) then {
		private _AI = CALLSM1("AICommander", "getCommanderAIOfSide", playerSide);
		CALLM2(_AI, "postMethodAsync", "addGroupToLocation", [_loc]);
	};
}] call pr0_fnc_addDebugMenuItem;

#else

pr0_fnc_addDebugMenuItem = {};
pr0_fnc_initDebugMenu = {};

#endif